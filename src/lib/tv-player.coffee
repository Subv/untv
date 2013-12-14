###
UNTV - tv-player.coffee
Author: Gordon Hall

Defines a "player" instance that can be passed media for playback
###

{EventEmitter} = require "events"
$              = require "../vendor/jquery-2.0.3.js"

class Player extends EventEmitter
  constructor: ->
    # create player

module.exports = Player
