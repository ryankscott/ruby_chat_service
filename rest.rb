require 'sinatra'

get '/' do
  'Hello world!'
end
get '/hello/:name' do
  # matches "GET /hello/foo" and "GET /hello/bar"
  # params[:name] is 'foo' or 'bar'
  "Hello #{params[:name]}!"
end

get '/download/*' do
  params[:splat]
  puts params[:splat]
end

get '/posts' do
  # matches "GET /posts?title=foo&author=bar"
  title = params[:title]
  author = params[:author]
  puts params
	# uses title and author variables; query is optional to the /posts route
end
