require 'em-websocket'
require 'bunny'
require_relative 'dao'

class ChatWebSocket
  def initialize(port)
    @port_number=port
    conn = Bunny.new()
    conn.start

    @ch   = conn.create_channel
    q    = @ch.queue(@port_number.to_s)
    begin
      q.subscribe(:block => false) do |delivery_info, properties, body|
        puts " [x] Received #{body}"

        # TODO fix this ws doesn't exist here...
        # ws.send "#{body}"
      end
    rescue Interrupt => _
      conn.close
    end

  end




  def start()
    EM.run {
      EM::WebSocket.run(:host => "0.0.0.0", :port => @port_number) do |ws|

        ws.onopen { |handshake|
          puts "WebSocket connection open on port #{@port_number}'}"
          # Publish message to the client
          messageText = {"timeSent"=> DateTime.now().to_s, "type" => "system", "messageText" => "Succesfully connected"}
          ws.send messageText.to_json
        }

        ws.onclose {
          puts "Connection closed"
          user = User.all(:chat_id => @port_number)
          user.update(:status => "offline", :last_seen_at => DateTime.now())
        }

        ws.onmessage { |msg|
          puts "Received Message: #{msg}"
          # Parse and persist to the DB
          messageHash = JSON.parse(msg)
          message = Message.create(
            :recipient => messageHash['recipient'],
            :sender =>  messageHash['sender'],
            :message => messageHash['messageText'],
            :sent_at =>  messageHash['timeSent'],
            :received_at => DateTime.now(),
            :read_at => DateTime.now()
          )
          # Add it to the queue (change the routing_key)
           @ch.default_exchange.publish(msg.to_s, :routing_key => messageHash['recipient'].to_s)
    

          ws.send "#{msg}"
        }
      end
    }
  end
end
