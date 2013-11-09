# Firebase = require 'firebase'

class Dictionary
  ALL_WORDS: [
    "banana",
    "cat",
    "love",
    "sprite",
    "camera",
    "angry scotsman"
  ]

  constructor: ->
    # @word_list = new Firebase 'https://platypus-launchhack.firebaseio.com/words'
    # @word_list.on('value', @_fetch_dictionary)

  random_word: (game_name, callback) ->
    word = @ALL_WORDS[Math.floor(Math.random() * @ALL_WORDS.length)]
    callback(game_name, word)

  _fetch_dictionary: (snapshot) -> 
    @ALL_WORDS = snapshot.val()



exports.Dictionary = Dictionary