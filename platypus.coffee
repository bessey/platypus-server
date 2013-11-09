express = require 'express'
Firebase = require 'firebase'

app = express()
db = new Firebase 'https://platypus-launchhack.firebaseio.com/'

{ScoreCalculator} = require './score_calculator'
{Dictionary} = require './dictionary'
{MatchMaker} = require './match_maker'

calc = new ScoreCalculator
dic = new Dictionary
matcher = new MatchMaker

exports.unfilled_games = []

app = express()
app.use express.bodyParser()

app.get '/', (req, res) ->
  res.send 'hello world'

app.post '/match-make', (req, res) ->
  fb_id = req.body.fb_id || null
  matcher.match(fb_id, res)


app.listen 3000