require "thread"
require_relative 'ChatWebSocket'


class ChatServiceCreator
	@@open_chatsockets = []

	def create()
		port_number = 3000 + @@open_chatsockets.length
		cs = ChatWebSocket.new(port_number)
		cs.start()
		@@open_chatsockets.push(cs)
		return port_number
	end
end
