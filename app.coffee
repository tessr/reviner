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

# routes
app.post '/users/authenticate', (req, res) ->
  client = new Vino(username: req.param('username'), password: req.param('password'))
  client.login (err, key, username) ->
    throw new Error(err) if err
    client.homeFeed (err, feed) ->
      throw new Error(err) if err
      # all succeeded, return user object with the homefeed
      res.json feed.records

# revine
revineSchema = new mongoose Schema {
  reviners: Array
  originalPost: {}
}
revineSchema.plugin(troop.timestamp) 

revineSchema.methods = {
  timesRevined: ->
    return reviners.length
}

Revine = app.db.model('Revine', revineSchema)

# routes
app.post '/revine', (req, res) ->
  Revine.findOne "originalPost.videoUrl": req.param('videoUrl'), (err, doc) ->
    if err?
      console.log(err)
      res.status(500)
    else if doc
      doc.reviners.push(req.param('userId'))
      doc.save (err) ->
        console.log(err)
        res.status(500)
    else
      newRevine = new Revine
        originalPost: req.body,
        reviners: [req.param('userId')]
      newRevine.save (err) ->
        console.log(err)
        res.status(500)

# listen
app.listen app.get('port'), ->
  console.log "Listening on #{app.get('port')}"
