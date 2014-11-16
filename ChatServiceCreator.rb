require "thread"
require_relative 'ChatWebSocket'


class ChatServiceCreator
	def initialize()
		@@open_chatsockets = []
	end

	def create()
		port_number = rand(3000..4000)
		cs = ChatWebSocket.new(port_number)
		cs.start()
		@@open_chatsockets << cs
		return port_number
	end
end
