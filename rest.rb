require 'sinatra'
require 'sinatra/jsonp'
require 'pg'
require 'json'
require_relative 'app'
require_relative 'ChatWebSocket'



get '/register' do
  person_id = params[:attendee_id].to_i
  puts person_id
  # TODO: Make sure the person exists by calling the API 
  cs = ChatService.new.create()
  data = {:chat_id => cs, :attendee_id => person_id, :time_created => Time.now.getutc.to_s}.to_json
  # We should persist it the mapping between chat_id and attendee_id
  
  JSONP data
end



# get '/message' do
#   event = params[:event_id]
#   person_id = params[:attendee_id]
#   puts params
#   # Here we check if the attendee is part of that event

#   # And if they have registered with the chat e.g online

#   # We then Create a new websocket for them to chat on, and send it back
# end



get '/status' do
  person_id = params[:attendee_id].to_i
  # here we would see if we have a record for them registering

  # and return it in JSON

end
