require "thread"
require_relative 'ChatWebSocket'


class ChatServiceCreator
	def initialize()
		@@open_chatsockets = []
		@@numberOfChatSockets = 0 
	end

	def create()
		port_number = 3000 + @@numberOfChatSockets
		cs = ChatWebSocket.new(port_number)
		cs.start()
		@@open_chatsockets << cs
		return port_number
	end
end
