$(document).ready ->
  window.api = Instajam.init
    clientId: INSTAGRAM_CLIENT_ID,
    redirectUri: INSTAGRAM_REDIRECT_URI,
    scope: ['basic']

  window.allMedia = []
  window.instatistics = new Instatistics()
  svg = d3.select("#graphics").append("svg")
  svg
    .attr("width", window.innerWidth)
    .attr("height", 100)
  window.myChart = new dimple.chart(svg, allMedia)
  x = myChart.addTimeAxis("x",  "date")
  x.timeInterval = 4
  myChart.addMeasureAxis("y", "reactions")
  myChart.addSeries(null, dimple.plot.bar)
  myChart.draw()

  $("central-image").on "click", ->
    $("img").show()
    resizeToFit()
  window.idealSize = 50
  parseResult = (result) ->
    if entries = result.data
      for entry in entries
        _media = new Media(entry)
        allMedia.push(_media)
        publishMedia(_media)
        myChart.draw() if allMedia.length < 100 || allMedia.length % 50 == 0

  fetchRecentUserMedia = (opts)->
    try
      api.user.media parseInt(user.id), opts, (result) ->
        parseResult(result)
        if result.pagination.next_max_id?
          fetchRecentUserMedia(max_id: result.pagination.next_max_id)
        else
          myChart.draw() 
          $("#status").remove()
    catch e
      console.log "error", e, this
      fetchRecentUserMedia(opts)
      
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
    imgs = $("img:visible")
    defaultSize = 320
    ww = window.innerWidth
    wh = window.innerHeight
    areaInPixels = ww * wh
    window.idealSize = parseInt(Math.sqrt( areaInPixels / imgs.length ))
    imgs.attr(width: idealSize, height: idealSize)
    $("#central-image").attr(width: defaultSize, height: defaultSize)

  window.onresize = resizeToFit
  publishMedia = (media) ->
    year = media.date.getFullYear()
    if !instatistics[year]?
      #console.log("happy new year #{year}")
      window.instatistics[year] = new Instatistics()
    lowImage = media.images.low_resolution
    image = new Image()
    image.width = idealSize
    image.height = idealSize
    image.src = lowImage.url
    image.media = media
    image.onload = ->
      $("body").append(image)
      $("#central-image").attr("src",image.src)
      $("#caption").text(media.caption.text) if media.caption?.text?
      $("#status").text("#{allMedia.length} (#{Math.round(allMedia.length / user.counts.media * 100)}%)")
      if media.tags?
        $("#tags").attr("src", media.tags.join(","))
        $("#tags").attr("href", "##{media.tags.join(",")}")
      resizeToFit()
      if selectedImage?
        $(image).toggle(image.media.matchWith(selectedImage.media))
      $(image).on "mouseover", ->
        $("#central-image").attr("src", @src)
        $("#caption").attr("src", @media.caption)
        $("#tags").attr("src", @media.tags.join(","))
        $("#tags").attr("href", "##{@media.tags.join(",")}")
      $(image).on "click", ->
        window.selectedImage = @
        filterSelectedImage()

        #window.open @media.link, '_blank'

      #graphicId = "graphic-#{year}"
      #plotUsage(current.usage.hours, "(#{year}) per hour", graphicId)
      #plotUsage(current.usage.weekDay, "(#{year}) per week day", graphicId)
      #plotUsage(current.usage.month, "(#{year}) per month", graphicId)
      instatistics[year].process media, ->
        rowId = "year-#{year}"
        html = renderColumnsInstatistics(instatistics[year])
        row = $("##{rowId}")
        if row[0]?
          row.html(html)
        else
          newRow = $("<tr id='#{rowId}'>#{html}</tr>")[0].outerHTML
          #$("#statistics > table").append(newRow)


  username = window.location.pathname.substr(1)
  api.user.get username, (data) ->
    window.user = data.data
    fetchRecentUserMedia()
  #window.years = ([year,size] for year,size of usage.year)
