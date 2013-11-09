class ScoreCalculator
  constructor: ->
  calculate: (favourites, word_difficulty = 1) ->
    (Math.pow((5 * favourites),2) + 10) * word_difficulty 

exports.ScoreCalculator = ScoreCalculator