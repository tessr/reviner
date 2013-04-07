sessionId = null

$ ->
  render_posts = (posts) ->
    post_template = _.template $('#post-template').html()
    compiled = _.map(posts, post_template).join('')
    $('#container').html compiled

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
        render_posts(data.feed.records)
