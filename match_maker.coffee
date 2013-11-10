Firebase = require 'firebase'
{Dictionary} = require './dictionary'
{GameStateMachine} = require './game_state_machine'
config = require './config'

class MatchMaker
  @UNFILLED_GAMES = []
  @UNMATCHED_PLAYERS = {}

  constructor: ->
    @game_list = new Firebase "https://#{process.env.FIREBASE_ENDPOINT}/games"
    @dict = new Dictionary

  match: (fb_id, response) ->
    @constructor.UNMATCHED_PLAYERS[fb_id] = response
    if Object.keys(@constructor.UNMATCHED_PLAYERS).length >= config.player_cap
      console.log "UNMATCHED_PLAYERS"
      console.log @constructor.UNMATCHED_PLAYERS
      @new_game()

  new_game: ->
    console.log("new game");

    game = {
      player_count: 0,
      started_at: new Date().getTime(),
      state: "matchmaking"
    }
    players = {}
    @p_c = 0
    for fb_id, response in @constructor.UNMATCHED_PLAYERS
      players[fb_id] = {
        fb_id: fb_id,
        role: @_role(),
      }
    game.players = players
    game_ref = @game_list.push()
    game_ref.set(game)
    @dict.random_word(game_ref.name(), @_word_assigner)
    state_machine = new GameStateMachine(game_ref)
    game_ref.on('value', state_machine.update)

    for fb_id, response of @constructor.UNMATCHED_PLAYERS
      @_respond_to fb_id, response, game_ref.name()

    @constructor.UNMATCHED_PLAYERS = {}

  _respond_to: (fb_id, response, game_id) ->
    response.json {fb_id: fb_id, game_id: game_id}
    
  find_unfilled_game: (fb_id, response) ->
    if @constructor.UNFILLED_GAMES.length > 0
      response.json { fb_id: fb_id, game_id: @constructor.UNFILLED_GAMES[0] }
      true
    else
      false

  _word_assigner: (game_name, word) ->
    console.log(game_name, word)
    word_node = new Firebase "https://#{process.env.FIREBASE_ENDPOINT}/games/#{game_name}/word"
    word_node.set(word)

  _role: ->
    @p_c =+ 1
    if not @guesser_set? and Math.random(1) > ((config.player_cap - 1) / config.player_cap)
      @guesser_set = true
      return 'guesser'
    else if not @guesser_set? and @players is config.player_cap
      return 'guesser'
    else
      return 'drawer'



exports.MatchMaker = MatchMaker