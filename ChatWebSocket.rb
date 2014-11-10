require 'em-websocket'
require_relative 'dao'

class ChatWebSocket
  def initialize(port)
    @port_number=port
  end

  def start()
    EM.run {
      @clients = []
      EM::WebSocket.run(:host => "0.0.0.0", :port => @port_number) do |ws|
        ws.onopen do |handshake|
          puts "WebSocket connection open on port #{@port_number}'}"
          @clients << ws

          # Publish message to the client
          messageText = {"timeSent"=> DateTime.now().to_s, "type" => "system", "messageText" => "Succesfully connected"}
          ws.send messageText.to_json
          puts @clients
        end

        ws.onclose do
          puts "Connection closed"
          @clients.delete ws

          user = User.all(:chat_id => @port_number)
          user.update(:status => "offline", :last_seen_at => DateTime.now())

        end

        ws.onmessage do |msg|
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

          # We should send a message to the queue ready to pick up


          

          @clients.each do |socket|
            socket.send msg
          end
        end
      end
    }
  end



end
