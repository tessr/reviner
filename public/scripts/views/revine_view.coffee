class Reviner.Views.RevineView extends Backbone.View
  className: 'row vine-container'
  events:
    'click .revine-button': 'revine'
    'click .twitter-share': 'toggleShare'
  toggleShare: ->
    @model.toggleShare()
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
      $('.overlay').show 'slow' , ->
        $('.overlay').delay(1500).hide('slow')

  initialize: (options) ->
    @template = options.template
  render: ->
    compiled = _.template @template, @model.toJSON()
    @$el.html compiled
    return @
