# app
express = require('express')
app = express()

# app config
app.configure ->
  app.use(express.static("#{__dirname}/public"))
  app.set('env', process.env.NODE_ENV or 'development')
  app.set('port', process.env.PORT or 3000)


  
  
  
# listen
server.listen app.get('port'), ->
  console.log "Listening on #{app.get('port')}"
