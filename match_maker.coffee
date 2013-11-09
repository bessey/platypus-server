Firebase = require 'firebase'
{Dictionary} = require './dictionary'
{GameStateMachine} = require './game_state_machine'

class MatchMaker
  @UNFILLED_GAMES = []

  constructor: ->
    @game_list = new Firebase 'https://platypus-launchhack.firebaseio.com/games'
    @dict = new Dictionary

  match: (fb_id, response) ->
    unless @find_unfilled_game fb_id, response
      @create_new_game fb_id, response

  create_new_game: (fb_id, response) ->
    game = {
      player_count: 0,
      started_at: new Date().getTime(),
      state: "matchmaking"
    }
    game_ref = @game_list.push()
    game_ref.set(game)
    @dict.random_word(game_ref.name(), @_word_assigner)
    state_machine = new GameStateMachine(game_ref)
    game_ref.on('value', state_machine.update)

    response.json { fb_id: fb_id, game_id: game_ref.name() } 

  find_unfilled_game: (fb_id, response) ->
    if @constructor.UNFILLED_GAMES.length > 0
      response.json { fb_id: fb_id, game_id: @constructor.UNFILLED_GAMES[0] }
      true
    else
      false

  _word_assigner: (game_name, word) ->
    console.log(game_name, word)
    word_node = new Firebase "https://platypus-launchhack.firebaseio.com/games/#{game_name}/word"
    word_node.set(word)

exports.MatchMaker = MatchMaker