class @Media
  constructor: (attributes) ->
    self = @
    for key,value of attributes
      self[key] = value
    @date = new Date(parseInt(@created_time)*1000)
  matchWith: (filter) ->
    return false if !filter?
    found = false
    self = @
    for currentTag in filter
      if self.tags?
        for tag in self.tags
          if tag == currentTag
            found = true
            console.log("trueeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee")
            console.log  tag, currentTag
      if self.caption? && self.caption.text? && self.caption.text.includes(currentTag)
        console.log("trueeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee")
        console.log self.caption.text, currentTag, self.caption.text.includes(currentTag)
        found = true
    return found
