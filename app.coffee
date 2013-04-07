# app
express = require('express')
Vino = require('./vino')
app = express()
mongoose = require('mongoose')
troop = require('mongoose-troop')

# set up ejs to play nice with underscore
ejs = require('ejs')
ejs.open = '{{'
ejs.close = '}}'

# connect db
mongoose.connect('mongodb://batman:robin@dharma.mongohq.com:10023/reviner')

# app config
app.configure ->
  app.use(express.static("#{__dirname}/public"))
  app.set('env', process.env.NODE_ENV or 'development')
  app.set('port', process.env.PORT or 3000)
  app.use(express.bodyParser())
  app.set('views', __dirname + '/views')
  app.set('view engine', 'ejs')
  app.use(express.cookieParser('fuck this shit'))
  app.use(express.session())
  

# revine
revineSchema = new mongoose.Schema
  reviners: Array
  originalPost: {}
  timesRevined: Number
revineSchema.plugin(troop.timestamp)

Revine = mongoose.model('Revine', revineSchema)

# routes
app.get '/', (req, res) ->
  if req.session.sessionId
    client = new Vino(sessionId: req.session.sessionId)
    client.homeFeed (err, feed) ->
      res.send(error: err, 500) if err?
      # all succeeded, return user object with the homefeed
      res.render('index', {feed: feed})
  else
    res.redirect('/login.html')

app.get '/login', (req, res) ->
  res.redirect '/login.html'

app.post '/login', (req, res) ->
  client = new Vino
    username: req.param('username')
    password: req.param('password')
  client.login (err, sessionId, userId) ->
    res.send(error: err, 500) if err?
    req.session.sessionId = sessionId
    res.redirect('/')

app.post '/revines', (req, res) ->
  videoUrl = req.param('videoUrl')
  description = "RV: #{req.param('description')}"
  thumbnailUrl = req.param('thumbnailUrl')

  client = new Vino(sessionId: req.session.sessionId)
  client.revine(videoUrl, thumbnailUrl, description)

  Revine.findOne {"videoUrl": videoUrl}, (err, doc) ->
    res.status(error: err, 500) if err?
    if doc?
      doc.reviners.push(req.param('userId'))
      doc.timesRevined++
      doc.save (err) ->
        res.send(error: err, 500) if err?
        res.send(doc, 200)
    else
      # add new attributes
      req.body.timesRevined = 1
      req.body.reviners = [req.param('userId')]
      newRevine = new Revine req.body
      newRevine.save (err) ->
        res.send(error: err, 500) if err?
        res.send(newRevine, 200)

app.get '/revines', (req, res) ->
  Revine.find().sort(created_at: -1).limit(20).exec (err, docs) ->
    res.send(error: err, 500) if err?
    res.send(docs, 200)

app.get '/revines/top', (req, res) ->
  Revine.find().sort(timesRevined: -1).limit(20).exec (err, docs) ->
    res.send(error: err, 500) if err?
    res.send(docs)

app.get '/top', (req, res) ->
  Revine.find().sort(timesRevined: -1).limit(20).exec (err, docs) ->
    res.send(error: err, 500) if err?
    res.render 'top', {posts: docs}

# listen
app.listen app.get('port'), ->
  console.log "Listening on #{app.get('port')}"
