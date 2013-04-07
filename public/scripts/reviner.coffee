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
    $.ajax
      method: 'POST'
      url: '/revines'
      data: @model.toJSON()
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
