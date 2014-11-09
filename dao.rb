require 'rubygems'
require 'data_mapper'
require 'dm-migrations'

DataMapper::Logger.new($stdout, :debug)

# A Postgres connection:
DataMapper.setup(:default, 'postgres://chat_app:securepassword@localhost/chat_service')


class User
	include DataMapper::Resource
	property :id, 			Serial
	property :attendee_id, 	Integer
	property :chat_id,		Integer
	property :status, 		Enum[ :online, :offline], :default => :offline
	property :last_seen_at,	DateTime
end


class Message
  include DataMapper::Resource
  property :id,         	Serial  
  property :recipient,    	Integer 
  property :sender,       	Integer
  property :message,		Text    
  property :sent_at, 		DateTime
  property :received_at,	DateTime
  property :read_at,			DateTime 
end

# DataMapper.finalize
# DataMapper.auto_migrate!