{ScoreCalculator} = require './score_calculator'
Firebase = require 'firebase'
config = require './config'

class GameStateMachine
  constructor: (game_ref, player_cap = 5) ->
    @id = game_ref.name()
    @player_cap = player_cap
    @timeout_length = 3000 # base length of a time (ms) within a state
    @matchmaking_factor = 1
    @playing_factor = 10 # how much longer is a round than the base as a factor
    @voting_factor = 2
    @first_run = true

    @calc = new ScoreCalculator(@player_cap)
    @guesses_node = new Firebase "https://#{process.env.FIREBASE_ENDPOINT}/games/#{@id}/guesses"
    @state_node   = new Firebase "https://#{process.env.FIREBASE_ENDPOINT}/games/#{@id}/state"
    @players_node = new Firebase "https://#{process.env.FIREBASE_ENDPOINT}/games/#{@id}/players"
    @votes_node   = new Firebase "https://#{process.env.FIREBASE_ENDPOINT}/games/#{@id}/votes"

  update: (game) => 
    @game = game.val()
    if @first_run
      @first_run = false
      @players_node.on('child_added', @_assign_role)

    switch @game.state
      when "matchmaking" then @_matchmaking()
      when "picking_colour" then @_picking_colour()
      when "playing" then @_playing()
      when "voting" then @_voting()
      when "summary" then @_summary()

  #### STATES ####

  # transition on: last player entering game
  _matchmaking: =>
    console.log("_matchmaking")
    if @game.player_count is @player_cap
      @_move_to_picking()

  # transition on: time runs out
  # transition on: last colour picked
  _picking_colour: =>
    console.log("_picking_colour")
    if @game.colours_picked is @player_cap - 1
      @_move_to_playing()

  # transition on: correct guess
  # transition on: time runs out
  _playing: =>
    console.log("_playing")

  # transition on: last player votes
  # transition on: time runs out
  _voting: =>
    console.log("_voting")

  # transition on: player leaves
  _summary: =>
    console.log("_summary")
    # not sure if we need this just yet
    #@_calculate_scores()

  #### TRANSITITIONS ####

  _move_to_picking: =>
    @players_node.off('child_added', @_assign_role)
    @_set_state("picking_colour")
    @timeout_id = setTimeout(@_move_to_playing, @timeout_length * @matchmaking_factor)    

  _move_to_playing: =>
    clearTimeout(@timeout_id)
    @timeout_id = setTimeout(@_move_to_voting, @timeout_length * @playing_factor)
    @guesses_node.on("child_added", @_check_guess)
    @_set_state("playing")

  _move_to_voting: =>
    clearTimeout(@timeout_id)
    @timeout_id = setTimeout(@_move_to_summary, @timeout_length * @voting_factor)
    guesses_node.off("child_added", @_check_guess)
    players_node.on('child_added', @_update_scores)
    @_set_state("voting")
    @votes_node.on("child_added", @_check_vote)

  _move_to_summary: =>
    @votes_node.off("child_added", @_check_vote)
    clearTimeout(@timeout_id)
    @_set_state("summary")

  #### UTILITY ####

  _assign_role: (new_player) ->
    if not @guesser_set? and Math.random(1) > ((config.player_cap - 1) / config.player_cap)
      @guesser_set = true
      new_player.ref().child('role').set('guesser')
    else
      new_player.ref().child('role').set('drawer')

  _check_guess: (new_guess) -> 
    if new_guess.val().guess is @game.word
      @_move_to_voting()

  _check_vote: (new_vote) ->
    new_vote.val().fb_id

  _set_state: (new_state) ->
    @state_node.set(new_state)

  _update_scores: (snapshot) ->
    @

exports.GameStateMachine = GameStateMachine