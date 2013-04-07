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
  timesRevined: Number
revineSchema.plugin(troop.timestamp)

Revine = mongoose.model('Revine', revineSchema)

# routes
app.post '/users/authenticate', (req, res) ->
  client = new Vino
    username: req.param('username')
    password: req.param('password')
  client.login (err, sessionId, userId) ->
    res.send(error: err, 500) if err?
    client.homeFeed (err, feed) ->
      res.send(error: err, 500) if err?
      # all succeeded, return user object with the homefeed
      res.json {feed: feed, userId: userId, sessionId: sessionId}

app.post '/revines', (req, res) ->
  videoUrl = req.param('videoUrl')
  description = req.param('description')
  thumbnailUrl = req.param('thumbnailUrl')
  client = new Vino(sessionId: req.param('sessionId'))
  client.revine(videoUrl, thumbnailUrl, description)
  Revine.findOne "originalPost.videoUrl": videoUrl, (err, doc) ->
    res.status(error: err, 500) if err?
    if doc?
      doc.reviners.push(req.param('userId'))
      doc.timesRevined++
      doc.save (err) ->
        res.send(error: err, 500) if err?
        res.send(doc, 200)
    else
      newRevine = new Revine
        originalPost: req.body
        reviners: [req.param('userId')]
        timesRevined: 1
      newRevine.save (err) ->
        res.send(error: err, 500) if err?
        res.send(newRevine, 200)

app.get '/revines', (req, res) ->
  Revine.find().sort(created_at: -1).limit(20).exec (err, docs) ->
    res.send(error: err, 500) if err?
    res.send(docs, 200)

# listen
app.listen app.get('port'), ->
  console.log "Listening on #{app.get('port')}"
