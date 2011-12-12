require "sinatra"
require "coffee-script"

get '/' do
  erb :index
end

get '/app.js' do
  status 200
  headers 'Content-Type' => 'application/javascript'
  body CoffeeScript.compile File.read("public/app.coffee")
end