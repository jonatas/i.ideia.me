require "json"
module LoadImagesFromCacheHelper
  def load_user_media_from_fixtures
    info = []
    Dir["spec/fixtures/page*.json" ].each do |file|
      info += JSON.load(IO.read(file))
    end
    info
  end
end
