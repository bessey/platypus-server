Firebase = require 'firebase'

class MatchMaker
  @UNFILLED_GAMES = []

  constructor: ->
    @game_list = new Firebase 'https://platypus-launchhack.firebaseio.com/games'

  match: (fb_id, response) ->
    unless @find_unfilled_game fb_id, response
      @create_new_game fb_id, response

  create_new_game: (fb_id, response) ->
    game = {
      player_count: 0,
      started_at: new Date().getTime(),
      state: "matchmaking",
      word: "svip"
    }
    push_ref = @game_list.push()
    push_ref.set(game)
    response.json { fb_id: fb_id, game_id: push_ref.name() } 

  find_unfilled_game: (fb_id, response) ->
    if exports.unfilled_games.length > 0
      response.json { fb_id: fb_id, game_id: @constructor.UNFILLED_GAMES[0] }
      true
    else
      false

exports.MatchMaker = MatchMaker