require "lib/load_cache_helper"
class InstagramUserMediaFetch
  attr_reader :media
  include LoadCacheHelper

  def initialize access_token, username
    @access_token =  access_token
    @media = []
    @username = username
    fetch_user
    filter = "cache/#{@username}_*.json"
    cache_files = Dir[filter]
    if not cache_files.empty?
      @media = load_all_user_media(filter)
    else
      fetch_all_media_history
    end
  end

  def client
    @client ||= Instagram.client(:access_token => @access_token)
  end

  def cached_user_info
    @cached_user_info ||= "cache/#@username.json"
  end

  def fetch_user
    if File.exists? cached_user_info
      @user = load_user_media(cached_user_info)
      p "from json local: {@user.class} -> #{@user.inspect}" 
      if @user.is_a? String
        File.remove cached_user_info
        fetch_user
      end
    else
      @user = client.user_search(@username).first
      p "from web: #{@user.class} -> #{@user.inspect}" 
      if @user.is_a? String
        @user = JSON.load @user
        puts "forcing json"
        p @user
      end
      File.open(cached_user_info, "w+") {|f|f.puts @user.to_json}
    end
  end

  def fetch_all_media_history
    puts "client.user_recent_media #{ @user["id"] } -> #{@user.inspect}"
    media_entries = client.user_recent_media @user["id"]
    page_count = 0
    while not media_entries.empty?
      @media += media_entries
      media_entries = client.user_recent_media @user["id"],  max_id: media_entries.last["id"]
      File.open("cache/#{@username}_#{page_count += 1}.json", "w+") {|f|f.puts media_entries.to_json}
    end
  end
end
