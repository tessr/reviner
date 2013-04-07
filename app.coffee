# app
express = require('express')
Vino = require('./vino')
app = express()

# app config
app.configure ->
  app.use(express.static("#{__dirname}/public"))
  app.set('env', process.env.NODE_ENV or 'development')
  app.set('port', process.env.PORT or 3000)
  app.use(express.bodyParser())

# routes
app.post '/users/authenticate', (req, res) ->
  client = new Vino(username: req.param('username'), password: req.param('password'))
  client.login (err, key, username) ->
    throw new Error(err) if err
    client.homeFeed (err, feed) ->
      throw new Error(err) if err
      # all succeeded, return user object with the homefeed
      console.log feed.records

# listen
app.listen app.get('port'), ->
  console.log "Listening on #{app.get('port')}"
