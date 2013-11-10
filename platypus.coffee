express = require 'express'
Firebase = require 'firebase'
config = require './config'

app = express()
games_list = new Firebase "https://#{process.env.FIREBASE_ENDPOINT}/games"
games_list.set(null)
{MatchMaker} = require './match_maker'
matcher = new MatchMaker

app = express()
app.use express.bodyParser()

app.get '/', (req, res) ->
  res.send 'hello, platypus'

app.post '/match-make', (req, res) ->
  req.connection.setTimeout(60000 * 5)
  req.socket.setTimeout(60000 * 5);
  fb_id = req.body.fb_id || null
  matcher.match(fb_id, res)

update_unfilled_games_list = (snapshot) ->
  if snapshot.val().player_count < config.player_cap and snapshot.val().state = "match_maker"
    add_to_unfilled_games_list snapshot
  else if snapshot.val().player_count >= config.player_cap
    remove_from_unfilled_games_list snapshot

remove_from_unfilled_games_list = (snapshot) ->
  console.log "deleting shit"
  MatchMaker.UNFILLED_GAMES = MatchMaker.UNFILLED_GAMES.filter (word) -> word isnt snapshot.name()

add_to_unfilled_games_list = (snapshot) ->
  MatchMaker.UNFILLED_GAMES.push(snapshot.name()) if MatchMaker.UNFILLED_GAMES.indexOf(snapshot.name()) is -1

games_list.on 'child_added', (snapshot) -> 
  update_unfilled_games_list(snapshot)
  console.log("game added")
  console.log("unfilled games: #{MatchMaker.UNFILLED_GAMES}")

games_list.on 'child_changed', (snapshot) -> 
  update_unfilled_games_list(snapshot)
  console.log("game changed")
  console.log("unfilled games: #{MatchMaker.UNFILLED_GAMES}")

games_list.on 'child_removed', (snapshot) -> 
  remove_from_unfilled_games_list(snapshot)
  console.log("game removed")
  console.log("unfilled games: #{MatchMaker.UNFILLED_GAMES}")

app.listen 3000