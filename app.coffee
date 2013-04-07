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
  
# schemas
revineSchema = new mongoose.Schema userId: Number
revineSchema.plugin(troop.timestamp)
Revine = mongoose.model('Revine', revineSchema)

postSchema = new mongoose.Schema
  avatarUrl: String
  userId: Number
  description: String
  location: String
  postId: Number
  shareUrl: String
  thumbnailUrl: String
  user: {}
  videoUrl: String
  foursquareVenueId: {}
  revines: [revineSchema]
Post = mongoose.model('Post', postSchema)

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
  post = req.body
  description = "RV: #{post.description}"
  client = new Vino(sessionId: req.session.sessionId)
  client.revine(post.videoUrl, post.thumbnailUrl, description)

  Post.findOne {videoUrl: post.videoUrl}, (err, doc) ->
    res.status(error: err, 500) if err?
    if doc?
      doc.revines.push(new Revine(userId: post.userId))
    else
      post.revines = [new Revine(userId: post.userId)]
      doc = new Post(post)
    doc.save (err) ->
      res.send(error: err, 500) if err?
      console.log('\n\n\n\n\n\n', doc, '\n\n\n\n\n\n')
      console.log('\n\n\n\n\n\n', err, '\n\n\n\n\n\n')
      res.send(doc, 200)

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
