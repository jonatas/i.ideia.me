class InstagramUserMediaFetch
  attr_reader :all_pics

  def initialize access_token, username
    @access_token =  access_token
    @all_pics = []
    @username = username
  end

  def client
    @client ||= Instagram.client(:access_token => @access_token)
  end

  def user
    client.user
  end

  def user_id
    @user_id ||= client.user_search(@username).first.id
  end

  def fetch_all_media_history
    pics = client.user_recent_media user_id
    page_count = 0
    while not pics.empty?
      @all_pics += pics
      pics = client.user_recent_media user_id,  max_id: pics.last.id
      File.open("cache/#{@username}_#{page_count += 1}.json", "w+") {|f|f.puts pics.to_json}
    end
  end
end
