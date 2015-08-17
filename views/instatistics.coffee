class @Instatistics
  constructor: ->
    @counter = {likes: 0, comments: 0, pics: 0, videos: 0, tags: 0, locations: 0}
    @usage = {hours: {}, weekDay: {}, month: {}}
    @tags = {}
    @fans = {}
    @locations = {}
  process: (mediaEntry, _callback) ->
    @year = mediaEntry.date.getFullYear()
    @counter.likes += mediaEntry.likes.count
    @counter.comments += mediaEntry.comments.count
    @counter.tags += mediaEntry.tags.length
    if mediaEntry.type is "video"
      @counter.videos += 1
    else
      @counter.pics += 1
    @processTags(mediaEntry)
    @processFans(mediaEntry)
    @processLocations(mediaEntry)
    @processUsage(mediaEntry)
    _callback()

  processTags: (media) ->
    self = @
    for tag in media.tags
      self.tags[tag] = 0 if !self.tags[tag]?
      self.tags[tag] += 1

  processFans: (media) ->
    self = @
    for like in media.likes.data
      self.fans[like["username"]] = 0 if ! self.fans[like["username"]]?
      self.fans[like["username"]] += 1
  processLocations: (mediaEntry) ->
    return if ! mediaEntry.location?
    if !@locations[mediaEntry.location.name]?
      @counter.locations += 1
      @locations[mediaEntry.location.name] = 1
    else
      @locations[mediaEntry.location.name] += 1

  processUsage: (mediaEntry) ->
    date = mediaEntry.date
    if @usage.hours[date.getHours()]?
      @usage.hours[date.getHours()] += 1
    else
      @usage.hours[date.getHours()] = 1

    if @usage.weekDay[date.getDay()]?
      @usage.weekDay[date.getDay()] += 1
    else
      @usage.weekDay[date.getDay()] = 1

    if @usage.month[date.getMonth()]?
      @usage.month[date.getMonth()] += 1
    else
      @usage.month[date.getMonth()] = 1
