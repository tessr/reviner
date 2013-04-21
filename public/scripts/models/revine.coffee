class Reviner.Models.Revine extends Backbone.Model
  defaults: ->
    return {
      postToTwitter: 0
      revines: []
      created: new Date()
      timesRevined: 0
    }
  toggleShare: ->
    postToTwitter = if @get("postToTwitter") == 0 then 1 else 0
    @set(postToTwitter: postToTwitter)
  revine: ->
    r = @clone()
    timesRevined = @get('timesRevined')
    # TODO: change user of r to the current user
    # TODO: add r.userId to @get('revines')
    @set(timesRevined: timesRevined+1)
    @collection.create r
