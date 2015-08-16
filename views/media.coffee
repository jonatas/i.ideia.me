class @Media
  constructor: (attributes) ->
    self = @
    for key,value of attributes
      self[key] = value
    @title = @caption?.text
    @date = new Date(parseInt(@created_time)*1000)
  matchWith: (other) ->
    return false if !other?
    return true if @tagSimilar(other).length > 0
    #return true if @locationSimilar(other).length > 0
    return true if @captionSimilar(other).length > 0
    return false
  #  similarity = @findSimilarity(other)
    #what for what, isSimilar of similarity when isSimilar?
  findSimilarity: (other) ->
    return false if !other?
    tag: @tagSimilar(other)
    location: @locationSimilar(other)
    caption: @captionSimilar(other)
  hasTagOrCaption: (name) ->
    return true if _word == name for _word in @tagsAndCaptions()
  tagSimilar: (other)->
    return [] if !other.tags? || !@tags?
    return false if other.tags is null || other.tags.length == 0 || @tags.length == 0
    tag for tag in @tags when tag in other.tags
  locationSimilar: (other)->
    return [] if @location == null || other.location == null
    @location.name == other.location.name # Use euclidian distance ratio condition
  captionWords: ->
    return [] if !@caption? || !@caption.text
    word for word in @caption.text.split(" ") when word.length > 3
  captionSimilar: (other)->
    word for word in @captionWords() when word in other.captionWords()
  tagsAndCaptions: ->
    result = @tags || []
    if @caption? && @caption.text?
      result.push word for word in @caption.text.split(" ") when word.length > 4
  d3ize: (selector, withImage) ->
    @d3 ||= selector
     .append("svg:image")
     .attr('x',@date.getYear()+@date.getMonth()+@date.getDay())
     .attr('y',likes.count)
     .attr('width', withImage.width)
     .attr('height', withImage.height)
     .attr("xlink:href",withImage.src)
