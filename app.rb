require 'rubygems'
require 'sinatra'
require 'haml'
require 'linkedin'
require 'yaml'

CONFIG = YAML.load_file 'config.yml'
api_key = CONFIG['api_key']
secret_key = CONFIG['secret_key']

enable :sessions

get '/' do
  client = LinkedIn::Client.new(api_key, secret_key)
  rtoken = client.request_token(:oauth_callback => "http://nametheface.heroku.com/name")
  rsecret = rtoken.secret
  session[:rtoken] = rtoken
  session[:rsecret] = rsecret
  redirect rtoken.authorize_url
  
end 

get '/name' do
  pin = params['oauth_verifier']
  client = LinkedIn::Client.new(api_key, secret_key)
  credentials = client.authorize_from_request(params['oauth_token'], session[:rsecret], pin)
  session[:credentials] = credentials
  #client.connections['all'][10]
  client.connections

end
