class Dictionary
  ALL_WORDS: ["banana", "cat", "null pointer", "love", "sprite", "camera", "angry scotsman"]

  random_word: ->
    @ALL_WORDS[Math.floor(Math.random() * @ALL_WORDS.length)]


exports.Dictionary = Dictionary