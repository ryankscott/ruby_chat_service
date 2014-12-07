require 'rubygems'
require 'data_mapper'
require 'dm-migrations'

DataMapper::Logger.new($stdout, :debug)
DataMapper::Model.raise_on_save_failure = true

# A SQLite connection:
DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/my.db")

class User
  include DataMapper::Resource
  property :id,           Serial
  property :attendee_id,  Integer, :unique => true
  property :chat_id,      Integer
  property :status,       Enum[ :online, :offline], :default => :offline
  property :last_seen_at, DateTime
  storage_names[:default] = 'user'
end

class Message
  include DataMapper::Resource
  property :id,           Serial
  property :recipient,    Integer
  property :sender,       Integer
  property :message,      Text
  property :sent_at,      DateTime
  property :received_at,  DateTime
  property :read_at,      DateTime
  storage_names[:default] = 'message'
end

class EndpointUser
  include DataMapper::Resource
  property :id,           Serial
  property :user_name,    Text, :unique => true
  property :password,     BCryptHash
end


DataMapper.finalize
DataMapper.auto_upgrade!

# Create a default end-point user
default_user = EndpointUser.first_or_create({:user_name => "test"}, {:password => "testuser123"})
