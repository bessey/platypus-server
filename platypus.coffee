express = require 'express'
Firebase = require 'firebase'

app = express()
root_reference = new Firebase 'https://platypus-launchhack.firebaseio.com/'

{ScoreCalculator} = require './score_calculator'
{Dictionary} = require './dictionary'
calc = new ScoreCalculator
dic = new Dictionary
app = express()
app.use express.bodyParser()

app.get '/', (req, res) ->
  res.send 'hello world'

app.post '/match-make', (req, res) ->
  fb_id = req.body.fb_id || null
  res.json { fb_id: fb_id, game_id: "i'll tell you later" } 

app.listen 3000