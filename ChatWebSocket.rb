require 'em-websocket'
require 'bunny'
require_relative 'dao'

class ChatWebSocket
  def initialize(port)
    @port_number=port
    conn = Bunny.new()
    conn.start
    @ch = conn.create_channel
    @x = @ch.direct("message")
    @message_queue = @ch.queue("", :exclusive => true)
    # Bind to both messages that come to you and system wide
    @message_queue.bind(@x, :routing_key => @port_number.to_s)
    @message_queue.bind(@x, :routing_key => "system")
    #@database_queue = @ch.queue("database")

  end


  def start()
    EM.run {
      EM::WebSocket.run(:host => "0.0.0.0", :port => @port_number) do |ws|

        ws.onopen { |handshake|
          puts "WebSocket connection opened on port #{@port_number}'}"
          # Publish message to the client
          handshake_message = Message.new()
          handshake_message.attributes = {
            :sent_at => DateTime.now().to_s,
            :message => "Succesfully connected at: #{@port_number}"
          }
          ws.send handshake_message.to_json
        }

        ws.onclose {
          puts "Connection closed"
          user = User.all(:chat_id => @port_number)
          begin
            updated = user.update(
              :status => "offline",
              :last_seen_at => DateTime.now()
            )
          rescue SaveFailureError => saveError
            puts "Error updating user: #{saveError}"
          end

          # Broadcast the offline messages
          recipient = User.first(:chat_id => @port_number)
          offline_message = Message.new
          offline_message['message'] = "#{recipient['attendee_id']} is now offline"
          offline_message['received_at'] = DateTime.now()
          offline_message['read_at'] = DateTime.now()
          offline_message['sent_at'] = DateTime.now()
          @x.publish(offline_message.to_json, :routing_key => "system")
        }

        ws.onmessage { |msg|

          # This code is for moving to a database worker model
          # database_message = {:model => 'message', :attributes => msg}.to_json
          # puts "trying to persist #{database_message} to the database queue"
          # @database_queue.publish(database_message)

          # Parse and persist to the DB
          begin
            received_message = Message.new
            received_message.attributes = JSON.parse(msg)
            received_message['received_at'] = DateTime.now()
            received_message['read_at'] = DateTime.now()
            received_message.save
          rescue SaveFailureError => saveError
            puts "Error persisting message: #{saveError}"
          end

          # Need to do the translation between attendee_id and chat socket
          recipient = User.first(:attendee_id => received_message['recipient'])
          if recipient
            # Add it to the queue (change the routing_key)
            puts "Sending message to port: #{recipient['chat_id']} attendee: #{recipient['attendee_id']}"
            @x.publish(msg.to_s, :routing_key => recipient['chat_id'].to_s)
            ws.send "#{msg}"
            # TODO: What do we do if we can't find the recipient
          else
            puts "error"
          end
        }


        begin
          @message_queue.subscribe(:block => false) do |delivery_info, properties, body|
            puts "Received message #{body}"
            ws.send "#{body}"
          end
        rescue Interrupt => _
          conn.close
        end
      end
    }
  end
end
