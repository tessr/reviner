root = exports ? this

# http://webdesign.onyou.ch/2010/08/04/javascript-time-ago-pretty-date/
root.prettyDate = (date_str) ->
  time_formats = [
    [60, "just now", 1]
    [120, "1m", "1 minute from now"]
    [3600, "m", 60]
    [7200, "1h", "1 hour from now"]
    [86400, "h", 3600]
    [172800, "yesterday", "tomorrow"]
    [604800, "d", 86400]
    [1209600, "last week", "next week"]
    [2419200, "weeks", 604800]
    [4838400, "last month", "next month"]
    [29030400, "months", 2419200]
    [58060800, "last year", "next year"]
    [2903040000, "years", 29030400]
    [5806080000, "last century", "next century"]
    [58060800000, "centuries", 2903040000]
  ]
  time = ("" + date_str).replace(/-/g, "/").replace(/[TZ]/g, " ").replace(/^\s\s*/, "").replace(/\s\s*$/, "")
  time = time.substr(0, time.length - 4) if time.substr(time.length - 4, 1) is "."
  seconds = (new Date - new Date(time)) / 1000
  token = "ago"
  list_choice = 1
  if seconds < 0
    seconds = Math.abs(seconds)
    token = "from now"
    list_choice = 2
  i = 0

  format = undefined
  while format = time_formats[i++]
    if seconds < format[0]
      if typeof format[2] is "string"
        return format[list_choice]
      else
        return Math.floor(seconds / format[2]) + format[1]
  return time

class RevineView extends Backbone.View
  className: 'row vine-container'
  events:
    'click .revine-button': 'revine'
    'click .twitter-share': 'toggleShare'
  toggleShare: ->
    postToTwitter = if @model.get("postToTwitter") == 0 then 1 else 0
    @model.set(postToTwitter: postToTwitter)
    @$el.toggleClass 'postToTwitter'
  revine: ->
    $.ajax(
      method: 'POST'
      url: '/revines'
      data: @model.toJSON()
    ).done (data) ->
      $('.overlay').show( 'slow' , ->
        $('.overlay').delay(1500).hide('slow')
      )
  initialize: (options) ->
    @model.set(postToTwitter: 0)
    @template = options.template
  render: ->
    compiled = _.template @template, @model.toJSON()
    @$el.html compiled
    return @

$ ->
  post_template = $('#post-template').html()
  revines = new Backbone.Collection(Data.records)

  views = []
  revines.each (revine) ->
    revine_view = new RevineView(model: revine, template: post_template)
    views.push revine_view.render()
  viewEls = _.pluck views, 'el'
  $('#container').html viewEls
