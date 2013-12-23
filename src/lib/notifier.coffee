###
UNTV - notifier.coffee
Author: Gordon Hall

Provides an interface for showing notifications and alert messages
on the user's TV
###

{EventEmitter} = require "events"

class Notifier extends EventEmitter
  constructor: ->

module.exports = Notifier
