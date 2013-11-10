Firebase    = require 'firebase'
{DummyPlayer} = require './dummy_player'

test_mass_join = ->
  players = []
  for i in [1..100]
    do ->
      player = new DummyPlayer
      player.match_make(player.join_game)
      players << player

test_mass_join()