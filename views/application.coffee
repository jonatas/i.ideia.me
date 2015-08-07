$(document).ready ->
  window.api = Instajam.init
    clientId: INSTAGRAM_CLIENT_ID,
    redirectUri: INSTAGRAM_REDIRECT_URI,
    scope: ['basic', 'comments']

  window.allMedia = []
  window.instatistics = new Instatistics()
  window.filterTags = null

  $("table").on "click", -> $("img").show()

  parseResult = (result) ->
    if entries = result.data
      for entry in entries
        _media = new Media(entry)
        allMedia.push(_media)
        publishMedia(_media)

  fetchRecentUserMedia = (opts)->
    api.user.self.media opts, (result) ->
      parseResult(result)
      if result.pagination.next_max_id?
        #console.log(max_id: result.pagination.next_max_id)
        fetchRecentUserMedia(max_id: result.pagination.next_max_id)
          

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
    console.log 'selectedImage', selectedImage
    if selectedImage?
      media = selectedImage.media
      if media?
        if media.tags?
          filterTags = media.tags
          if filterTags? && filterTags.length > 0
            console.log "filtering: ", filterTags
            for _img in $("img")
              if _img.media? && !_img.media.matchWith(filterTags)
                $(_img).hide()
  publishMedia = (media) ->
    year = media.date.getFullYear() 
    if !instatistics[year]?
      #console.log("happy new year #{year}")
      window.instatistics[year] = new Instatistics()
    current = instatistics[year]
    lowImage = media.images.low_resolution
    image = new Image()
    image.width = lowImage.width / 10
    image.height = lowImage.height / 10
    image.src = lowImage.url
    image.media = media
    image.tags = media.tags if media.tags.length > 0
    image.onload = ->
      $("#central-image").attr("src",image.src)
      $("body").append(image)
      if filterTags? && image? && image.media? && !image.media.matchWith(filterTags)
        $(image).hide()
      $(image).on "mouseover", ->
        $("#central-image").attr("src", @src)
      $(image).on "click", ->
        window.selectedImage = @
        filterSelectedImage()

        #window.open @media.link, '_blank'

      #graphicId = "graphic-#{year}"
      #plotUsage(current.usage.hours, "(#{year}) per hour", graphicId)
      #plotUsage(current.usage.weekDay, "(#{year}) per week day", graphicId)
      #plotUsage(current.usage.month, "(#{year}) per month", graphicId)
      instatistics.process media, ->
        rowId = "year-#{instatistics.year}"
        html = renderColumnsInstatistics(instatistics)
        row = $("##{rowId}")
        if row[0]?
          row.html(html)
        else
          newRow = $("<tr id='#{rowId}'>#{html}</tr>")[0].outerHTML
          $("#statistics > table").append(newRow)
      
  fetchRecentUserMedia()
  window.years = ([year,size] for year,size of usage.year)
  plotUsage = (info, title, graphicId) ->
    selector = "#graphics > ##{graphicId}"
    if $(selector)[0]?
      $(selector).empty()
    else
      $("#graphics").append($("<div id='#{graphicId}'></div>")[0].outerHTML)
    h = 250
    w = 500
    padding = 2
    data = []
    x = []
    y = []
    maxY = 0
    for key,value of info
      data.push [key, value]
      x.push key
      y.push value
      maxY = value if maxY < value
    step = ((w - (data.length * padding)) / data.length)
    d3.select(selector).append("h3").text title
    svg = d3.select(selector).append("svg")
    svg
      .attr("width", w)
      .attr("height", h)

    svg.selectAll("rect")
      .data(data)
      .enter()
      .append("rect")
      .attr("y", (row) -> row[1] / maxY * h )
      .attr("x", (row,i) -> i * step)
      .attr("fill", "black")
      #.attr("width", 20)
      .attr("width", step - padding )
      .attr("height", h)

    svg.selectAll("text")
      .data(data)
      .enter()
      .append("text")
      .text((e) -> e[0])
      .attr("y", -> h - 20)
      .attr("x", (item,i) -> (i * step) + step / 3)
      .attr("fill", "white")
      .attr("font-family", "sans-serif")
      .attr("font-size", "11px")

