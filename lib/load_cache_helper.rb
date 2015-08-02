require "json"
module LoadCacheHelper
  def load_all_user_media from="spec/fixtures/page*.json"
    files = Dir[from]
    if files.size > 1
      info = []
      files.each do |file|
        info +=  load_user_media(file)
      end
    else
      info = load_user_media(files.first)
    end
    info
  end
  def load_user_media file
    JSON.load(IO.read(file))
  end
end
