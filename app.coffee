# app
express = require('express')
Vino = require('./vino')
app = express()
mongoose = require('mongoose')
troop = require('mongoose-troop')

# connect db
mongoose.connect('mongodb://batman:robin@dharma.mongohq.com:10023/reviner')

# app config
app.configure ->
  app.use(express.static("#{__dirname}/public"))
  app.set('env', process.env.NODE_ENV or 'development')
  app.set('port', process.env.PORT or 3000)
  app.use(express.bodyParser())

# revine
revineSchema = new mongoose.Schema
  reviners: Array
  originalPost: {}
revineSchema.plugin(troop.timestamp) 

revineSchema.methods = {
  timesRevined: ->
    return reviners.length
}

Revine = mongoose.model('Revine', revineSchema)

# routes
app.post '/users/authenticate', (req, res) ->
  client = new Vino
    username: req.param('username')
    password: req.param('password')
  client.login (err, sessionId, userId) ->
    throw new Error(err) if err
    client.homeFeed (err, feed) ->
      throw new Error(err) if err
      # all succeeded, return user object with the homefeed
      res.json {feed: feed, userId: userId, sessionId: sessionId}

app.post '/revine', (req, res) ->
  videoUrl = req.param('videoUrl')
  description = req.param('description')
  thumbnailUrl = req.param('thumbnailUrl')

  client = new Vino(sessionId: req.param('sessionId'))

  client.revine(videoUrl, thumbnailUrl, description)
  Revine.findOne "originalPost.videoUrl": req.param('videoUrl'), (err, doc) ->
    if err?
      console.log(err)
      res.status(500)
    else if doc
      doc.reviners.push(req.param('userId'))
      doc.save (err) ->
        throw new Error(err) if err
    else
      newRevine = new Revine
        originalPost: req.body,
        reviners: [req.param('userId')]
      newRevine.save (err) ->
        throw new Error(err) if err

# listen
app.listen app.get('port'), ->
  console.log "Listening on #{app.get('port')}"
