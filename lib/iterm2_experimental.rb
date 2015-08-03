
def show *pics
  pics.each do |pic|
    puts `curl -s #{pic} | imgcat` rescue nil
  end
end

#load "spec/load_images_from_cache_helper.rb"
#include LoadImagesFromCacheHelper
#images = load_user_media_from_fixtures
#show *images.first["likes"]["data"].map{|e|e["profile_picture"]}
