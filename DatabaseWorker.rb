require 'bunny'
require 'json'
require 'securerandom'
require_relative 'dao'

class DatabaseWorker
	def initialize()
		@uuid = SecureRandom.uuid
		conn = Bunny.new()
		conn.start
		ch = conn.create_channel
		q = ch.queue("database")
		ch.prefetch(1)
		begin
		  puts "DB Worker [#{@uuid}] starting"
		  q.subscribe(:block => true) do |delivery_info, properties, body|
		  	processDatabaseWork(body)
		end
		rescue Interrupt => _
		  conn.close
		end
	end

	def processDatabaseWork(jsonPackage)
	# Let's assume we get JSON that looks like this:
		parsedMessage = JSON.parse(jsonPackage)
		# Model: Either Message/User
		model = parsedMessage['model']
		attributes = JSON.parse(parsedMessage['attributes'])

		if model == 'message'
			db_message = Message.new
			db_message.attributes = attributes
			db_message['received_at'] = DateTime.now()
			db_message['read_at'] = DateTime.now()
			db_message.save
          # TODO: What should we do if the message wasn't persisted? Catch the error

		elsif model == 'user'
			puts "user"

		else
			puts "other"
		end

		# Attributes:
		puts "Database worker received work #{parsedMessage}"
	end
end

worker = DatabaseWorker.new()

