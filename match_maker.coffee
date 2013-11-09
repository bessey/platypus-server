Firebase = require 'firebase'

class MatchMaker

  constructor: ->
    @game_list = new Firebase 'https://platypus-launchhack.firebaseio.com/games'

  match: (fb_id, response) ->
    @create_new_game(fb_id, response)

  create_new_game: (fb_id, response) ->
    game = {
      players: [],
      started_at: new Date().getTime(),
      state: "matchmaking",
      word: "svip"
    }
    push_ref = @game_list.push()
    push_ref.set(game)
    response.json { fb_id: fb_id, game_id: push_ref.name() } 

  find_unfilled_game: (fb_id) ->
    false

exports.MatchMaker = MatchMaker