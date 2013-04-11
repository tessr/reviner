class Reviner.Views.RevineView extends Backbone.View
  className: 'row vine-container'
  events:
    'click .revine-button': 'revine'
    'click .twitter-share': 'toggleShare'
  toggleShare: ->
    @model.toggleShare()
    @$el.toggleClass 'postToTwitter'
  revine: ->
    revine = @model.clone()
    # change user
    @model.collection.create revine

  initialize: (options) ->
    @template = options.template
  render: ->
    compiled = _.template @template, @model.toJSON()
    @$el.html compiled
    return @
