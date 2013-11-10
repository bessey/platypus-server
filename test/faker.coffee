Firebase    = require 'firebase'
{DummyPlayer} = require './dummy_player'

start_new_player = ->
  player = new DummyPlayer
  player.match_make (game_id) ->
    player.join_game(game_id)
    game_ref = new Firebase "http://#{process.env.FIREBASE_ENDPOINT}/games/#{game_id}/state"
    player.listen_on_state_change(player_state_machine)

player_state_machine = (new_state) ->
  console.log("state: #{new_state.val()}")

setInterval(start_new_player, 1000)