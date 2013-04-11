root = exports ? this

root.Reviner =
  Models: {}
  Collections: {}
  Views: {}

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

$ ->
  post_template = $('#post-template').html()
  revines = new Reviner.Collections.Revines(Data.records)

  revines.on 'add', (revine) ->
    # revine_view = new Reviner.Views.RevineView(model: revine, template: post_template)
    # $('#container').prepend revine_view.render().el
    $('.overlay').show 'slow' , ->
      $('.overlay').delay(1500).hide('slow')

  views = []
  revines.each (revine) ->
    revine_view = new Reviner.Views.RevineView(model: revine, template: post_template)
    views.push revine_view.render()
  viewEls = _.pluck views, 'el'
  $('#container').html viewEls

  $('.footer').on 'click', ->
    $('.shadow, .about').show()

  $('.shadow').on 'click', ->
    $('.shadow, .about').hide()
