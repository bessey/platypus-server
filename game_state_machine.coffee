{ScoreCalculator} = require './score_calculator'

class GameStateMachine
  constructor: (player_cap = 5) ->
    @player_cap = player_cap
    @timeout_length = 3000
    @calc = new ScoreCalculator

  update: (game) => 
    @game = game.val()
    @id = game.name()
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
      @timeout_id = setTimeout(@_force_to_playing, @timeout_length)

  # transition on: time runs out
  # transition on: last colour picked
  _picking_colour: ->
    console.log("_picking_colour")
    if @_all_colours_picked()
      clearTimeout(@timeout_id)
      @_set_state("playing")
      @timeout_id = setTimeout(@_force_to_voting, @timeout_length)

  # transition on: correct guess
  # transition on: time runs out
  _playing: ->
    console.log("_playing")
    if @_correct_guess()
      clearTimeout(@timeout_id)
      @_set_state("voting")
      @timeout_id = setTimeout(@_force_to_summary, @timeout_length)

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
    state_node = new Firebase "https://platypus-launchhack.firebaseio.com/games/#{@id}/state"
    state_node.set(new_state)

  _force_to_playing: ->
    # set everyones colours
    @_set_state("playing")

exports.GameStateMachine = GameStateMachine