require "json"
module LoadImagesFromCacheHelper
  def load_user_media from="spec/fixtures/page"
    info = []
    Dir["#{from}*.json" ].each do |file|
      info += JSON.load(IO.read(file))
    end
    info
  end
end
