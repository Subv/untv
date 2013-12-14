###
UNTV - tv-panelextension.coffee
Author: Gordon Hall

Create a "focusable" interface "panel", that can be controlled via a
specified remote instance if given focus.

This class should be used to inherit from when defining an extension
###

{EventEmitter} = require "events"
$              = require "../vendor/jquery-2.0.3.js"

class PanelExtension extends EventEmitter
  constructor: ->

  activate: ->
    @focused = yes
    do @onActivated if typeof @onActivated is "function"
    # figure out how to handle remote bindings here

  container: ($ "#extensions-container")
  focused: no
  onActivated: null


module.exports = PanelExtension
