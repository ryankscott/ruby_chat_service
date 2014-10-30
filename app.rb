require 'em-websocket'
 
EM.run {
  @clients = []

  EM::WebSocket.run(:host => "0.0.0.0", :port => 3000) do |ws|
    ws.onopen do |handshake|
      puts "WebSocket connection open"
      @clients << ws

      # Access properties on the EM::WebSocket::Handshake object, e.g.
      # path, query_string, origin, headers

      # Publish message to the client
      ws.send "Hello Client, you connected to #{handshake.path}"
      puts @clients
    end

    ws.onclose do
      puts "Connection closed" 
      @clients.delete ws
    end
  

    ws.onmessage do |msg|
      puts "Received Message: #{msg}"
      @clients.each do |socket|
        socket.send msg
    end
  end
end
}
