class Reviner.Models.Revine extends Backbone.Model
  defaults: ->
    return {
      postToTwitter: 0
      revines: []
      created: new Date()
    }
  toggleShare: ->
    postToTwitter = if @get("postToTwitter") == 0 then 1 else 0
    @set(postToTwitter: postToTwitter)
