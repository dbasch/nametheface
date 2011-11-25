require 'rubygems'
require 'sinatra'
require 'haml'
require 'linkedin'
require 'yaml'
require 'sqlite3'

CONFIG = YAML.load_file 'config.yml'
api_key = CONFIG['api_key']
secret_key = CONFIG['secret_key']

enable :sessions

get '/' do
  client = LinkedIn::Client.new(api_key, secret_key)
  if session[:credentials] == nil
    rtoken = client.request_token(:oauth_callback => "http://nametheface.heroku.com/authorize")
    rsecret = rtoken.secret
    session[:rtoken] = rtoken
    session[:rsecret] = rsecret
    redirect rtoken.authorize_url
  else
    client.authorize_from_access(session[:credentials][0], session[:credentials][1])
    conns = client.connections
    pic = nil
    while pic == nil
      @c= conns[:all][rand(conns[:total])]
      pic = @c[:picture_url]
    end
    haml :index
  end  
end 

get '/authorize' do
  pin = params[:oauth_verifier]
  client = LinkedIn::Client.new(api_key, secret_key)
  credentials = client.authorize_from_request(params[:oauth_token], session[:rsecret], pin)
  session[:credentials] = credentials
end

