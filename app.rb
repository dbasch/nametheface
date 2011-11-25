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
  rtoken = client.request_token(:oauth_callback => "/name")
  rsecret = rtoken.secret
  session[:rtoken] = rtoken
  session[:rsecret] = rsecret
  redirect rtoken.authorize_url
  
end 

get '/name' do
  #client.authorize_from_request(params['oauth_secret'], client.request_token.secret, params['oauth_verifier'])
  pin = params['oauth_verifier']
  client = LinkedIn::Client.new(api_key, secret_key)
  credentials = client.authorize_from_request(params['oauth_token'], session[:rsecret], pin)
  session[:credentials] = credentials
  client.connections['all'][10]
end
