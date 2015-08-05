$(document).ready ->
  window.insta = Instajam.init
    clientId: INSTAGRAM_CLIENT_ID,
    redirectUri: INSTAGRAM_REDIRECT_URI,
    scope: ['basic', 'comments']
  window.years = ([year,size] for year,size of usage.year)
  plotUsage = (data, title) ->
    h = 250
    w = 500
    padding = 2
    y = (n[1] for n in data)
    maxY = y.reduce (a,b) -> Math.max a, b
    console.log " maxY: #{maxY}"
    step = ((w - (data.length * padding)) / data.length)
    d3.select("body").append("h2").text title
    svg = d3.select("body").append("svg")
    svg
      .attr("width", w)
      .attr("height", h)

    svg.selectAll("rect")
      .data(data)
      .enter()
      .append("rect")
      .attr("y", (item) -> item[1] / maxY * h )
      .attr("x", (item,i) -> i * step)
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


  plotUsage(usage.hours, "Usage per hour")
  plotUsage(years, "Pics per year")
  plotUsage(usage.week_day, "Pics per week day")

