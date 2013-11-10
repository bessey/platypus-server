Firebase 		= require 'firebase'
querystring		= require 'querystring'
http 			= require 'http'
async			= require 'async'

## HELPERS
random_array = (length) ->
	[1..length].map (x) -> x = Math.floor(Math.random() * 100000000000000)

request = (generated_id) ->
	object = null
	post_data = querystring.stringify {'fb_id': generated_id}
	post_options = {
    	host: 'localhost',
    	port: '3000',
    	path: '/match-make',
    	method: 'POST',
    	headers: {
      		'Content-Type': 'application/x-www-form-urlencoded',
      		'Content-Length': post_data.length,
    	}
		}

	post_request = http.request(post_options, (result) ->
		result.setEncoding 'utf8'
		response_string = ''
		result.on 'data', (chunk) ->
			response_string = response_string + chunk
		result.on 'end', () ->
			object = JSON.parse response_string
			respond(object)
	)

	post_request.write post_data
	post_request.end

respond = (object) ->
	console.log object.game_id
	fb = new Firebase "https://platypus-launchhack-test.firebaseio.com/games/#{object.game_id}/player_count"
	fb.transaction (current_value) ->
		current_value + 1

## GAME STATES
matchmake = (generated_id) ->
	request(generated_id)

# run tests
matchmake player for player in random_array(10)