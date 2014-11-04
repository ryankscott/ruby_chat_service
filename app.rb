require_relative 'ChatWebSocket'


class ChatService
  def initialize()
  end

  def create()
    port_number = rand(3000..4000)
    cs = ChatWebSocket.new(port_number)
    cs.start()
    return port_number
  end
end
