class Reviner.Views.RevineView extends Backbone.View
  className: 'row vine-container'
  events:
    'click .revine-button': 'revine'
    'click .twitter-share': 'toggleShare'
  toggleShare: ->
    @model.toggleShare()
    @$el.toggleClass 'postToTwitter'
  revine: ->
    @model.revine()

  initialize: (options) ->
    @template = options.template
    @metadata_template = options.metadata_template
    @listenTo @model, 'change', @render_metadata

  render_video: ->
    @$el.find('.video').html(
      "<video src='#{@model.get("videoUrl")}' loop controls></video>"
    )
  render_metadata: ->
    compiled = _.template @metadata_template, @model.toJSON()
    @$el.find('.metadata').html compiled

  render: ->
    @$el.html @template
    @render_video()
    @render_metadata()
    return @
