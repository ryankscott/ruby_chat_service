require 'sinatra'
require 'sinatra/jsonp'
require 'json'
require 'net/http'
require_relative 'ChatServiceCreator'
require_relative 'dao'


class ChatServiceEndpoint < Sinatra::Base
  helpers Sinatra::Jsonp

  # set :server, 'webrick'
  get '/register' do
    person_id = params[:attendee_id].to_i
    # Make sure the person exists by calling the API 

    # uri = URI('http://example.com/index.html')
    # params = { :limit => 10, :page => 3 }
    # uri.query = URI.encode_www_form(params)

    # res = Net::HTTP.get_response(uri)
    # puts res.body if res.is_a?(Net::HTTPSuccess)


    # This should be changed to using queueing with a ChatServiceCreator
    chatService = ChatServiceCreator.new()
    chatServiceId = chatService.create()
    data = {:chat_id => chatServiceId, 
            :attendee_id => person_id, 
            :time_created => Time.now.getutc.to_s
            }.to_json
            
    # Persist the mapping between chat_id and attendee_id
    begin
      new_user = User.first_or_create(:attendee_id=>person_id).update(
        :chat_id    => chatServiceId,
        :status => "online",
        :last_seen_at => DateTime.now())
    rescue SaveFailureError => saveError
        puts "Error persisting user: #{saveError}"
    end

    JSONP data
  end


  get '/status' do
    # It should return the staus of the attendee passed or an array with everyone if no id is passed
    person_id = params[:attendee_id].to_i
    if person_id .nil? || person_id == 0
        person = User.all()
    else
        person = User.all(:attendee_id => person_id)
    end
    JSONP person  
  end
run ChatServiceEndpoint.run!

end


