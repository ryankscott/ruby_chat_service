require 'em-websocket'
require 'bunny'
require_relative 'dao'

class ChatWebSocket
  def initialize(port)
    @port_number=port
    conn = Bunny.new()
    conn.start
    @ch   = conn.create_channel
    @q    = @ch.queue(@port_number.to_s)
  end


  def start()
    EM.run {
      EM::WebSocket.run(:host => "0.0.0.0", :port => @port_number) do |ws|

        ws.onopen { |handshake|
          puts "WebSocket connection open on port #{@port_number}'}"

          # Publish message to the client
          handshake_message = Message.new()
          handshake_message.attributes = {
            :sent_at => DateTime.now().to_s,
            :type => "system",
            :message => "Succesfully connected at: #{@port_number}"
          }
          ws.send handshake_message.to_json
        }

        ws.onclose {
          puts "Connection closed"
          user = User.all(:chat_id => @port_number)
          updated = user.update(
            :status => "offline",
            :last_seen_at => DateTime.now()
          )

          #TODO: What to do if the status was not updated
          if !updated
            puts "User not updated"
          end

        }

        ws.onmessage { |msg|
          puts "Received Message: #{msg}"
          # Parse and persist to the DB
          received_message = Message.new
          received_message.attributes = JSON.parse(msg)
          received_message['received_at'] = DateTime.now()
          received_message['read_at'] = DateTime.now()
          received_message.save

          # TODO: What should we do if the message wasn't persisted?
          if !received_message.saved?
            puts "error"
          end


          # Need to do the translation between attendee_id and chat socket
          recipient = User.first(:attendee_id => received_message['recipient'])
          if recipient
            # Add it to the queue (change the routing_key)
            @ch.default_exchange.publish(msg.to_s, :routing_key => recipient['chat_id'].to_s)
            ws.send "#{msg}"
            # TODO: What do we do if we can't find the recipient
          else
            puts "error"
          end
        }


        begin
          @q.subscribe(:block => false) do |delivery_info, properties, body|
            puts " [x] Received #{body}"
            ws.send "#{body}"
          end
        rescue Interrupt => _
          conn.close
        end
      end



    }
  end
end
