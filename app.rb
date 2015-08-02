require "sinatra"
require "instagram"
require "awesome_print"

$: << File.dirname(__FILE__)
require "lib/instagram_user_media_fetch"
require "lib/instatistics"
require "sinatra/reloader" if development?

enable :sessions

CALLBACK_URL = "http://localhost:4567/oauth/callback"

require "spec/load_images_from_cache_helper"
include LoadImagesFromCacheHelper
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

get "/" do
  '<a href="/oauth/connect">Connect with Instagram</a>'
end

get "/oauth/connect" do
  redirect Instagram.authorize_url(:redirect_uri => CALLBACK_URL)
end

get "/oauth/callback" do
  response = Instagram.get_access_token(params[:code], :redirect_uri => CALLBACK_URL)
  puts session[:access_token] = response.access_token
  redirect "/instatistics/#{client.user.username}"
end

get "/instatistics/:username" do
  filter = "cache/#{params[:username]}"
  cache_files = Dir["#{filter}*.json"]
  images =
    if cache_files.empty?
      fetcher = InstagramUserMediaFetch.new(session[:access_token], params[:username])
      fetcher.fetch_all_media_history
      fetcher.all_pics
    else
      load_user_media(filter)
    end
  @stats = Instatistics.new(images)
  erb :"instatistics.html"
end

get "/limits" do
  html = "<h1/>View API Rate Limit and calls remaining</h1>"
  response = client.utils_raw_response
  html << "Rate Limit = #{response.headers[:x_ratelimit_limit]}.  <br/>Calls Remaining = #{response.headers[:x_ratelimit_remaining]}"
  html
end