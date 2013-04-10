# http://stackoverflow.com/questions/3177836/how-to-format-time-since-xxx-e-g-4-minutes-ago-similar-to-stack-exchange-site
window.timeSince = (ts) ->
  now = new Date()
  ts = new Date(ts)
  delta = now.getTime() - ts.getTime()
  delta = delta / 1000 #us to s
  if delta <= 59
    return Math.floor(delta) + "s"
  if delta >= 60 and delta <= 3599
    min = Math.floor(delta / 60)
    return min + "m"
  if delta >= 3600 and delta <= 86399
    hou = Math.floor(delta / 3600)
    return hou + "h"
  if delta >= 86400
    days = Math.floor(delta / 86400)
    return days + "d"

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
    ).done (data) =>
      # should refactor into a subview
      if @model.get("revines").length
        count = @model.get("revines").length
        @$el.find('.revine-button').html("ReVine (#{count+1} RVs)")
      $('.overlay').show( 'slow' , ->
        $('.overlay').delay(1500).hide('slow')
      )
  initialize: (options) ->
    @model.set(postToTwitter: 0)
    @model.set(revines: []) if not @model.get("revines")
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

  $('.footer').on 'click', ->
    $('.shadow, .about').show()

  $('.shadow').on 'click', ->
    $('.shadow, .about').hide()
