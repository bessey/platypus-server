express = require 'express'
Firebase = require 'firebase'

app = express()
root_reference = new Firebase 'https://platypus-launchhack.firebaseio.com/'

app.get '/', (req, res) ->
  res.send 'hello world'

app.listen 80