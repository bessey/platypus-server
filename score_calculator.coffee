class ScoreCalculator
  constructor: (players, word_difficulty = 10) ->
  	@player_count = players
  	@word_difficulty = word_difficulty
  	@votes = {}

  add_score: (player, vote) ->
  	@votes[player] == null ? @votes[player] = 1 : @votes[player] += vote

  should_calculate: ->
  	Object.keys(@votes).length == @player_count

  _calculate: (player) ->
    (Math.pow((5 * votes[player]),2) + 10) * @word_difficulty 

exports.ScoreCalculator = ScoreCalculator	