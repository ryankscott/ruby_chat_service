require 'sinatra'
require 'sinatra/jsonp'
require 'json'
require 'net/http'
require_relative 'app'
require_relative 'dao'
require_relative 'ChatWebSocket'


set :server, 'webrick'
get '/register' do
  person_id = params[:attendee_id].to_i
  puts person_id
  # Make sure the person exists by calling the API 

  # uri = URI('http://example.com/index.html')
  # params = { :limit => 10, :page => 3 }
  # uri.query = URI.encode_www_form(params)

  # res = Net::HTTP.get_response(uri)
  # puts res.body if res.is_a?(Net::HTTPSuccess)



  cs = ChatService.new.create()
  data = {:chat_id => cs, :attendee_id => person_id, :time_created => Time.now.getutc.to_s}.to_json
  # We should persist it the mapping between chat_id and attendee_id
  user = User.create(
    :attendee_id => person_id,
    :chat_id    => cs,
    :status => "online",
    :last_seen_at => DateTime.now()
  )
  JSONP data
end


get '/status' do
  # It should return the staus of the attendee passed or an array with everyone if no id is passed
  person_id = params[:attendee_id].to_i
  puts person_id
  if person_id .nil? || person_id == 0
      person = User.all()
      puts "this is the person #{person}"      
  else
      person = User.all(:attendee_id => person_id)
      puts "this is the person #{person}"

  end
  puts person
  JSONP person  
end
