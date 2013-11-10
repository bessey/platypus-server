{ScoreCalculator} = require './score_calculator'
Firebase = require 'firebase'

class GameStateMachine
  constructor: (game_ref, player_cap = 5) ->
    @id = game_ref
    @player_cap = player_cap
    @timeout_length = 3000 # base length of a time (ms) within a state
    @matchmaking_factor = 1
    @playing_factor = 10 # how much longer is a round than the base as a factor
    @voting_factor = 2
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

  #### STATES ####

  # transition on: last player entering game
  _matchmaking: ->
    console.log("_matchmaking")
    if @game.player_count is @player_cap
      @_move_to_picking()

  # transition on: time runs out
  # transition on: last colour picked
  _picking_colour: ->
    console.log("_picking_colour")
    if @game.colours_picked is @player_cap - 1
      @_move_to_playing()

  # transition on: correct guess
  # transition on: time runs out
  _playing: ->
    console.log("_playing")
    if @_correct_guess()
      @_move_to_voting()

  # transition on: last player votes
  # transition on: time runs out
  _voting: ->
    console.log("_voting")
    if @_all_voted()
      @_move_to_summary()

  # transition on: player leaves
  _summary: ->
    console.log("_summary")
    @_calculate_scores()

  #### TRANSITITIONS ####

  _move_to_picking: ->
    @_set_state("picking_colour")
    @timeout_id = setTimeout(@_move_to_playing, @timeout_length * @matchmaking_factor)    

  _move_to_playing: ->
    clearTimeout(@timeout_id)
    @timeout_id = setTimeout(@_move_to_voting, @timeout_length * @playing_factor)
    guesses_node.on("child_added", @_check_guess)
    @_set_state("playing")

  _move_to_voting: ->
    clearTimeout(@timeout_id)
    @timeout_id = setTimeout(@_move_to_summary, @timeout_length * @voting_factor)
    guesses_node.off("child_added", @_check_guess)
    @_set_state("voting")

  _move_to_summary: ->
    clearTimeout(@timeout_id)
    @_set_state("summary")

  #### UTILITY ####

  _check_guess: (new_guess) -> 
    if new_guess.val().guess is @game.word
      @_move_to_voting()

  _set_state: (new_state) ->
    @state_node.set(new_state)

  _calculate_scores: ->
    # write me

exports.GameStateMachine = GameStateMachine