Firebase     = require 'firebase'
querystring  = require 'querystring'
http         = require 'http'

class DummyPlayer
  constructor: ->
    @game_ref = null
    @fb_id = Math.floor(Math.random()*1000000).toString()

  match_make: (response_callback) ->
    # Build the post string from an object
    post_data = querystring.stringify({
        'fb_id' : @fb_id
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
    object = null
    post_req = http.request(post_options, (res) =>
      response_string = ''
      res.setEncoding('utf8')
      res.on('data', (chunk) -> 
        response_string += chunk
      )
      res.on('end', () =>
        object = JSON.parse(response_string)
        response_callback(object['game_id'])
      )
    )

    # post the data
    post_req.write(post_data);
    post_req.end();

  join_game: (game_id) =>
    @game_ref     = new Firebase "http://#{process.env.FIREBASE_ENDPOINT}/games/#{game_id}"
    @game_ref.once('value', @_inc_player_count)
    @players_ref  = @game_ref.child "players"
    @guesses_ref  = @game_ref.child "guesses"
    @votes_ref    = @game_ref.child "votes"
    @points_ref   = @game_ref.child "points"
    player = {
      fb_id: @fb_id
    }
    @my_ref = @players_ref.push()
    @my_ref.set(player)
    console.log ("#{@fb_id} \t has joined #{game_id} successfully")

  listen_on_state_change: (change_callback) =>
    @game_ref.child('state').on('value', change_callback)

  end_listen_on_state_change: (change_callback) =>
    @game_ref.child('state').off('value', change_callback)

  pick_colour: (colour) =>
    @my_ref.set(colour: colour)

  guess_word: (guess) =>
    @guesses_ref.push({guess: guess, fb_id: @fb_id})

  cast_vote: (voted_for) =>
    @votes_ref.push({guess: guess, fb_id: @fb_id})

  add_point: (x, y, player_id, color_id, is_end = false) =>
    @points_ref.push({
        x: x,
        y: y,
        player_id: player_id,
        color_id: color_id,
        is_end: is_end
      })

  _inc_player_count: (game_ref) ->
    incremented = game_ref.val().player_count + 1
    game_ref.ref().set(player_count: incremented)

exports.DummyPlayer = DummyPlayer
