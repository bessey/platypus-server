class ScoreCalculator
  constructor: (players, word_difficulty = 10) ->
  	@player_count = players
  	@word_difficulty = word_difficulty
  	@votes = {}

  add_score: (player, vote = 1.0) ->
  	if @votes[player] is undefined
  		@votes[player] = vote
  	else
	  	@votes[player] = @votes[player] + vote

  should_calculate: ->
  	Object.keys(@votes).length == @player_count

  calculate: (player) ->
  	if @votes[player] is undefined
    	throw new Error("Player #{player} does not exist")

    (Math.pow((5 * @votes[player]),2) + 10) * @word_difficulty 

exports.ScoreCalculator = ScoreCalculator