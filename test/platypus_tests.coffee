Firebase    = require 'firebase'
querystring = require 'querystring'
http        = require 'http'
{DummyPlayer} = require './dummy_player'

stress_test_room_creation = ->

_connect_to_game = (game_id, player_count = 1) ->
  game = new Firebase "#{process.env.FIREBASE_TEST_ENDPOINT}/games/#{game_id}"
  game.set({player_count: player_count})

_match_make =  ->
  # Build the post string from an object
  post_data = querystring.stringify({
    'fb_id' : 'testarooni',
    })

  # An object of options to indicate where to post to
  post_options = {
    host: 'localhost',
    port: '3000',
    path: '/match-make',
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Content-Length': post_data.length
    }
  }

  # Set up the request
  post_req = http.request(post_options, (res) -> \
    res.setEncoding('utf8')
    res.on('data', (chunk) -> 
      console.log('Response: ' + chunk)
    )
  )

  # post the data
  post_req.write(post_data);
  post_req.end();
