require 'rubygems'
require 'sinatra'
require 'haml'
require 'linkedin'
require 'yaml'

#get your application key and secret at http://developer.linkedin.com
#and edit config.yml accordingly
CONFIG = YAML.load_file 'config.yml'
api_key = CONFIG['api_key']
secret_key = CONFIG['secret_key']
#this is where the app lives, e.g. "http://localhost:4567"
app_url = CONFIG['app_url']

use Rack::Session::Pool

get '/' do
  client = LinkedIn::Client.new(api_key, secret_key)
  if session[:credentials] == nil
    rtoken = client.request_token(:oauth_callback => app_url + "/authorize")
    rsecret = rtoken.secret
    session[:rtoken] = rtoken
    session[:rsecret] = rsecret
    redirect rtoken.authorize_url
  end
  people = session[:people]
  if people == nil
    #fetch the user's connections through the LinkedIn API
    people = []
    client.authorize_from_access(session[:credentials][0], session[:credentials][1])
    conns = client.connections
    conns[:all].each do |conn| 
      if conn[:picture_url] != nil and conn[:site_standard_profile_request] != nil
        people << {:first_name => conn[:first_name], :last_name => conn[:last_name], 
          :picture_url => conn[:picture_url], :url => conn[:site_standard_profile_request].url } 
      end  
    end
    session[:people] = people
  end
  if people.size > 0 
    @person= people[rand(people.size)]
    haml :index
  else
    "None of your contacts have pictures. Grow your network and come back!"
  end 
end 

get '/authorize' do
  pin = params[:oauth_verifier]
  client = LinkedIn::Client.new(api_key, secret_key)
  credentials = client.authorize_from_request(params[:oauth_token], session[:rsecret], pin)
  #we should be persisting the credentials instead of lazily stuffing them into the session
  session[:credentials] = credentials
  redirect '/'
end

