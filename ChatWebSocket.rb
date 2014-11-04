require 'em-websocket'

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
          messageText = {"timeSent"=> Time.now.getutc.to_s, "type" => "system", "messageText" => "Succesfully connected"}
          ws.send messageText.to_json
          puts @clients
        end

        ws.onclose do
          puts "Connection closed"
          @clients.delete ws
        end

        ws.onmessage do |msg|
          puts "Received Message: #{msg}"
          # Here we need to parse the JSON

          @clients.each do |socket|
            socket.send msg
          end
        end
      end
    }
  end



end
