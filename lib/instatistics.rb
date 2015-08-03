require "benchmark"
class Array
  def to_hash
    inject({}) {|h,kv| h[kv.first] = kv.last;h}
  end
end

module Enumerable
  def usage sort=true
    h = map{|k,v|[k,v.size]}
    sort ? h.sort_by{|k,v|v} : h
  end
end

class Instatistics
  attr_accessor :media, :tags, :fans, :fan_tags
   def initialize media, add_words_as_tags=nil
     @media = media
     @tags = {}
     @fans = {}
     @frame = {hour: {}, week_day: {}, month: {}, year: {}}
     @days_in_week = {}
     @add_words_as_tags = add_words_as_tags
     @media.each do |media_entry|
       normalize_words_to_tags media_entry
       process_tags media_entry
       process_top_fans media_entry
       process_timeframes media_entry
     end
     process_fan_tags
   end

   def normalize_words_to_tags media_entry
     if media_entry["caption"] && @add_words_as_tags && media_entry["caption"]["text"] =~ @add_words_as_tags
       media_entry["tags"] << $1
     end
   end

   def process_tags media
     media["tags"].each do |tag|
       (tags[tag] ||= []) << media
     end
   end

   def process_top_fans media
     media["likes"]["data"].each do |like|
       (@fans[like["username"]] ||= []) << media
     end
   end

  def top_fans limit=10
    @fans.sort_by{|k,v|v.size}.reverse[0,limit]
  end

  def top_tags limit=10
    @tags.sort_by{|k,v|v.size}.reverse[0,limit]
  end

  def process_fan_tags limit=10
    @fan_tags = {}
    @fans.map{|t|[t[0],t[1].map{|e|e['tags'] rescue nil}.delete_if(&:empty?)]}.each do |fan, tags|
      counter ||= {}
      tags.flatten.each do |tag|
        counter[tag] ||= 0
        counter[tag] += 1
      end
      tags = counter.delete_if{|k,v|v < 2 }.sort_by{|k,v|v}.reverse[0,limit]
      @fan_tags[fan] = tags.to_hash if not tags.empty?
    end
    @fan_tags
  end

  def process_timeframes media_entry
    time = Time.at media_entry['created_time'].to_i
    (@frame[:hour][time.hour] ||= []) << media_entry
    (@frame[:week_day][time.strftime("%a")] ||= []) << media_entry
    (@frame[:month][time.strftime("%B")] ||= []) << media_entry
    (@frame[:year][time.year] ||= []) << media_entry
  end

  def timeframes
    @frame
  end

  def usage
    {
      hours: @frame[:hour].usage.sort_by{|k,v|k},
      week_day:  @frame[:week_day].to_hash.usage(false),
      month:  @frame[:month].usage.to_hash,
      year:  @frame[:year].usage.to_hash
    }
  end
  
  def to_hash
    {
      total_media: @media.size,
      total_tags: @tags.size,
      top_fans: top_fans.usage.to_hash,
      #fan_tags: @fan_tags,
      top_tags: top_tags.usage.to_hash
      #usage: usage
    }
  end
end

