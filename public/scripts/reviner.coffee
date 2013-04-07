sessionId = null
userId = null

class RevineView extends Backbone.View
  events:
    'click .revine-button': 'revine'
  revine: ->
    console.log "revining"
    return
    data = @model.toJSON()
    data.sessionId = sessionId
    data.userId = userId
    $.ajax(
      method: 'POST'
      url: '/revines'
      data: data
    ).done (data) ->
      console.log data

  initialize: (options) ->
    @template = options.template
  render: ->
    compiled = _.template @template, @model.toJSON()
    @$el.html compiled
    return @

$ ->
  post_template = $('#post-template').html()
  revines = new Backbone.Collection()

  revines.on 'reset', ->
    views = []
    revines.each (revine) ->
      revine_view = new RevineView(model: revine, template: post_template)
      views.push revine_view.render()
    viewEls = _.pluck views, 'el'
    $('#container').html viewEls

  render_topbar = ->
    topbar_template = $('#top-bar-template').html()
    $('#top').html topbar_template

  if sessionId
    # render timeline
    console.log "it exists"
  else
    login_template = $('#login-template').html()
    $('#container').html login_template

    login_form = $('#login')
    login_form.on 'submit', (e) ->
      e.preventDefault()
      $.ajax(
        method: 'POST'
        url: '/users/authenticate'
        data: login_form.serialize()
      ).done (data) ->
        sessionId = data.sessionId
        userId = data.userId
        render_topbar()
        revines.reset data.feed.records
