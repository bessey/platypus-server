{ScoreCalculator} = require './score_calculator'
Firebase = require 'firebase'

class GameStateMachine
  constructor: (game_ref, player_cap = 5) ->
    @id = game_ref
    @player_cap = player_cap
    @timeout_length = 3000
    @calc = new ScoreCalculator
    @guesses_node = new Firebase "https://platypus-launchhack.firebaseio.com/games/#{@id}/guesses"
    @state_node   = new Firebase "https://platypus-launchhack.firebaseio.com/games/#{@id}/state"
    @players_node = new Firebase "https://platypus-launchhack.firebaseio.com/games/#{@id}/players"

  update: (game) => 
    @game = game.val()
    switch @game.state
      when "matchmaking" then @_matchmaking()
      when "picking_colour" then @_picking_colour()
      when "playing" then @_playing()
      when "voting" then @_voting()
      when "summary" then @_summary()

  # transition on: last player entering game
  _matchmaking: ->
    console.log("_matchmaking")
    if @game.player_count is @player_cap
      @_set_state("picking_colour")
      @timeout_id = setTimeout(@_move_to_playing, @timeout_length)

  # transition on: time runs out
  # transition on: last colour picked
  _picking_colour: ->
    console.log("_picking_colour")
    if @game.colours_picked is @player_cap - 1
      clearTimeout(@timeout_id)
      @_move_to_playing()
      @timeout_id = setTimeout(@_move_to_voting, @timeout_length)

  # transition on: correct guess
  # transition on: time runs out
  _playing: ->
    console.log("_playing")
    if @_correct_guess()
      clearTimeout(@timeout_id)
      @_set_state("voting")
      @timeout_id = setTimeout(@_move_to_summary, @timeout_length)

  # transition on: last player votes
  # transition on: time runs out
  _voting: ->
    console.log("_voting")
    if @_all_voted()
      clearTimeout(@timeout_id)
      @_set_state("summary")

  # transition on: player leaves
  _summary: ->
    console.log("_summary")
    @_calculate_scores()

  _set_state: (new_state) ->
    @state_node.set(new_state)

  _move_to_playing: ->
    guesses_node.on("child_added", @_check_guess)
    @_set_state("playing")

  _move_to_voting: ->
    @_set_state("voting")

  _move_to_summary: ->
    @_set_state("summary")

  _correct_guess: ->

exports.GameStateMachine = GameStateMachine