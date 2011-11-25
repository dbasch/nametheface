require 'rubygems'
require 'sinatra'
require 'haml'
require 'linkedin'

#use Rack::Session::Cookie # OmniAuth requires sessions.
enable :sessions

get '/' do
  client = LinkedIn::Client.new('xu9jkkza9x6m', 'APd4ee71JhqKjgBm')
  rtoken = client.request_token(:oauth_callback => "http://localhost:4567/test")
  rsecret = rtoken.secret
  session[:rtoken] = rtoken
  session[:rsecret] = rsecret
  redirect rtoken.authorize_url
  
end 

get '/test' do
  #client.authorize_from_request(params['oauth_secret'], client.request_token.secret, params['oauth_verifier'])
  pin = params['oauth_verifier']
  client = LinkedIn::Client.new('xu9jkkza9x6m', 'APd4ee71JhqKjgBm')
  credentials = client.authorize_from_request(params['oauth_token'], session[:rsecret], pin)
  session[:credentials] = credentials
  client.connections['all'][10]
end