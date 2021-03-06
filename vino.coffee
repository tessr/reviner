VINO_DEFAULT_OPTS =
  baseUrl: 'https://api.vineapp.com/'
  userAgent: 'com.vine.iphone/1.0.7 (unknown, iPhone OS 6.1.2, iPhone, Scale/2.000000)'

request = require("request")

extend = (target, source) ->
  keys = Object.keys source
  for name in keys
    target[name] = source[name]
  return target

class Vino
  constructor: (options) ->
    options ||= {}
    if 'sessionId' of options
      @sessionId = options.sessionId
    @opts = extend(VINO_DEFAULT_OPTS, options)
  homeFeed: (pageNumber, cb) ->
    throw new Error('must be logged in') if not ('sessionId' of @)
    if typeof pageNumber == 'function'
      cb = pageNumber
      pageNumber = null
    request(
      url: @opts.baseUrl + '/timelines/graph'
      qs:
        page: pageNumber || 1
      method: 'get'
      headers:
        'vine-session-id': @sessionId
        'User-Agent': @opts.userAgent
      , (err, resp, body) =>
        if err
          cb?(err, resp)
          return
        body = JSON.parse body
        if body.code
          cb?('homeFeed failure', body)
          return
        cb?(null, body.data)
    )
  login: (cb) ->
    if not ('username' of @opts and 'password' of @opts)
      throw new Error('username and pass required')
    request(
      url: @opts.baseUrl + 'users/authenticate'
      method: 'post'
      form:
        username: @opts.username
        password: @opts.password
      headers:
        'User-Agent': @opts.userAgent
      , (err, resp, body) =>
        body = JSON.parse body
        if not body.success
          cb?('login failure', body)
          return
        @sessionId = body.data.key
        @userId = body.data.userId
        cb?(null, @sessionId, @userId)
    )
  register: (username, email, password, cb) ->
    request(
      url: @opts.baseUrl + 'users'
      method: 'post'
      form:
        username: username
        email: email
        password: password
        authenticate: 1
      headers:
        'User-Agent': @opts.userAgent
      , (err, resp, body) =>
        body = JSON.parse body
        if not body.success
          cb?('register failure', body)
          return
        @sessionId = body.data.key
        @userId = body.data.userId
        cb?(null, @sessionId, @userId)
    )
  follow: (userId, cb) ->
    throw new Error('must be logged in') if not ('sessionId' of @)
    request(
      url: "#{@opts.baseUrl}users/#{userId}/followers"
      method: 'post'
      headers:
        'vine-session-id': @sessionId
        'user-agent': @opts.userAgent
      , (err, resp, body) =>
        body = JSON.parse body
        if not body.success
          cb?('follow failure', body)
          return
        cb?(null, body.data)
    )
  revine: (params, cb) ->
    throw new Error('must be logged in') if not ('sessionId' of @)
    request(
      url: "#{@opts.baseUrl}posts"
      method: 'post'
      form: params
      headers:
        'vine-session-id': @sessionId
        'user-agent': @opts.userAgent
      , (err, resp, body) =>
        body = JSON.parse body
        if not body.success
          cb?('revine failure', body)
          return
        cb?(null, body.data)
    )
  userSearch: (user, cb) ->
    throw new Error('must be logged in') if not ('sessionId' of @)
    request(
      url: "#{@opts.baseUrl}users/search/#{encodeURIComponent(user)}"
      method: 'get'
      headers:
        'vine-session-id': @sessionId
        'User-Agent': @opts.userAgent
      , (err, resp, body) =>
        if err
          cb?(err, resp)
          return
        body = JSON.parse body
        if body.code
          cb?('userSearch failure', body)
          return
        cb?(null, body.data)
    )
  tagSearch: (tag, cb) ->
    throw new Error('must be logged in') if not ('sessionId' of @)
    request(
      url: "#{@opts.baseUrl}timelines/tags/#{encodeURIComponent(tag)}"
      method: 'get'
      headers:
        'vine-session-id': @sessionId
        'User-Agent': @opts.userAgent
      , (err, resp, body) =>
        if err
          cb?(err, resp)
          return
        body = JSON.parse body
        if body.code
          cb?('tagSearch failure', body)
          return
        cb?(null, body.data)
    )

module.exports = Vino
