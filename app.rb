require "sinatra"
require "sinatra/reloader" if development?
require "instagram"
require "awesome_print"

$: << File.dirname(__FILE__)

require "lib/instagram_user_media_fetch"
require "lib/instatistics"
require "lib/load_cache_helper"

include LoadCacheHelper

enable :sessions

CALLBACK_URL = ENV["INSTAGRAM_CALLBACK_URL"] || "http://localhost:4567/oauth/callback"

Instagram.configure do |config|
  config.client_id = ENV["INSTAGRAM_CLIENT_ID"]
  config.client_secret = ENV["INSTAGRAM_CLIENT_SECRET"]
  # For secured endpoints only
  #config.client_ips = '<Comma separated list of IPs>'
end

helpers do
  def client
    Instagram.client(:access_token => session[:access_token])
  end
end

Dir["views/*.coffee"].each do |file|
  name = file.split("/").last.split(".coffee").first
  get "/#{name}.js" do
    content_type 'application/javascript'
    coffee  name.to_sym
  end
end
get '/vendor.js' do
  content_type 'application/javascript'
  %w(jquery/dist/jquery d3/d3 instajam/dist/instajam).map do |file|
    IO.read("bower_components/#{file}.js")
  end.join("\n")
end

get "/" do
  '<a href="/oauth/connect">Connect with Instagram</a>'
end

get "/oauth/connect" do
  redirect Instagram.authorize_url(:redirect_uri => CALLBACK_URL)
end

get "/oauth/callback" do
  response = Instagram.get_access_token(params[:code], :redirect_uri => CALLBACK_URL)
  session[:access_token] = response.access_token
  redirect "/#{client.user.username}"
end

get "/:username" do
  erb :"instatistics.html"
end

get "/limits" do
  html = "<h1/>View API Rate Limit and calls remaining</h1>"
  response = client.utils_raw_response
  html << "Rate Limit = #{response.headers[:x_ratelimit_limit]}.  <br/>Calls Remaining = #{response.headers[:x_ratelimit_remaining]}"
  html
end
