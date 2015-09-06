class @MozaicRender
  @thumbnail: (d) -> d.images.thumbnail.url
  @low_resolution: (d) -> d.images.low_resolution.url
  constructor: (@allMedia) ->
    @mozaic = d3.select("body").append("div")
      .attr("width", window.innerWidth - 320)
      .attr("height",  window.innerHeight - 320 - 100)
    @xRule = d3.select("body").append("svg")
      .attr("width", window.innerWidth )
      .attr("height",  130)
    @yRule = d3.select("body").append("svg")
      .attr("width", window.innerHeight)
      .attr("height",  150)

  createMozaic: ->
    @selection = @mozaic
      .selectAll("img")
      .data(@allMedia)
      .enter()
      .append("img")
      .attr("src", MozaicRender.thumbnail)
      .attr("width", (d) ->"#{idealSize}px" )
      .attr("height", (d) ->"#{idealSize}px" )

  createAxes: ->
    @x = d3.time.scale().domain(d3.extent(@allMedia, (d) -> d.date)).range([0,window.innerWidth])
    @y = d3.scale.linear().domain(d3.extent(@allMedia, (d) -> d.date.getHours())).range([0,window.innerHeight])
    @xAxis = d3.svg.axis().scale(@x).orient('top')
    @yAxis = d3.svg.axis().scale(@y).orient('left')
    @xRule.selectAll("g.x axis").append('g').attr('class', 'x axis').call(@xAxis)
    @yRule.selectAll("g.y axis").append('g').attr('class', 'y axis').call(@yAxis)
  disposedByHour: ->
    @createMozaic()
    @createAxes()
    self = @
    @selection.attr("style", (d) -> "position: relative; display:block; top: #{self.x(d.date)}px; left:#{320+self.y(d.date.getHours())}px")
    document.body.scrollTop = document.body.scrollHeight
  defaultView: ->
    @createMozaic()
    window.idealSize = Math.round(Math.sqrt(areaInPixels / user.counts.media))
    $("img")
      .attr("style", "")
      .attr("width",  "#{idealSize}px")
      .attr("height",  "#{idealSize}px")
    document.body.scrollTop = 0

$(document).ready ->
  window.api = Instajam.init
    clientId: INSTAGRAM_CLIENT_ID,
    redirectUri: INSTAGRAM_REDIRECT_URI,
    scope: ['basic']

  window.startedAt = new Date()
  window.allMedia = []
  window.mozaic = new MozaicRender(allMedia)
  window.instatistics = new Instatistics()

  setupMouseOver = ->
    $(".dimple-series-0").on "mouseover", (e) ->
      date = e.toElement.__data__.date
      return if !date?
      for media in allMedia
        if media? and date.getTime() is media.date.getTime()
          $('#central-image').attr('src', img.src)

  $("#central-image").on "click", ->
    $("img").show()
    resizeToFit()
  window.idealSize = 50
  parseResult = (result) ->
    if entries = result.data
      for entry in entries
        _media = new Media(entry)
        publishMedia(_media)
        if allMedia.length < 100 || allMedia.length % 50 == 0
          setupMouseOver()


  fetchRecentUserMedia = (opts)->
    onSuccess = (result) ->
      parseResult(result)
      if result.pagination.next_max_id?
        fetchRecentUserMedia(max_id: result.pagination.next_max_id)

    onError = -> fetchRecentUserMedia(opts)
    api.user.media parseInt(user.id), opts, onSuccess, onError

  renderColumnsInstatistics = (instatistics) ->
    html = ""
    columns = [
      instatistics.year,
      instatistics.counter.pics,
      instatistics.counter.videos,
      instatistics.counter.likes,
      instatistics.counter.comments,
      instatistics.counter.locations
    ]

    html += $("<td>#{info}</td>")[0].outerHTML for info in columns
    html
  window.filterSelectedImage = ->
    if selectedImage?
      media = selectedImage.media
      for _img in $("img")
        if _img.media?
          $(_img).toggle(media.matchWith(_img.media))
      resizeToFit()
  window.resizeToFit = ->
    defaultSize = 320
    ww = window.innerWidth
    wh = window.innerHeight
    window.areaInPixels = ww * wh
    window.idealSize = ww / 18  # 18 useful hours in a day
    $("#central-image").attr(width: defaultSize, height: defaultSize)

  window.onresize = resizeToFit

  publishMedia = (media) ->
    image = new Image()
    #image.src = media.images.low_resolution.url
    image.src = MozaicRender.thumbnail(media)
    image.onload = ->
      allMedia.push(media)
      $("#central-image").attr("src",image.src)
      mozaic.disposedByHour()
      $("#caption").text(media.caption.text) if media.caption?.text?
      percent = Math.round(allMedia.length / user.counts.media * 100)
      $("#status").text("#{allMedia.length} (#{percent}%)")
      if percent == 100
        $("#status").text("#{allMedia.length} files in #{((new Date()).getTime() - startedAt.getTime()) / 1000} seconds")
        mozaic.defaultView()
      if media.tags?
        $("#tags").attr("src", media.tags.join(","))
        $("#tags").attr("href", "##{media.tags.join(",")}")
      resizeToFit()
      if selectedImage?
        $(image).toggle(image.media.matchWith(selectedImage.media))
      $(image).on "mouseover", ->
        $("#central-image").attr("src", @src)
        $("#caption").text(@media.caption.text) if @media.caption?.text?
        $("#tags").attr("href", "##{@media.tags.join(",")}")
      $(image).on "click", ->
        window.selectedImage = @
        filterSelectedImage()



  username = window.location.pathname.substr(1)
  api.user.get username, (data) ->
    window.user = data.data
    fetchRecentUserMedia()
  #window.years = ([year,size] for year,size of usage.year)
