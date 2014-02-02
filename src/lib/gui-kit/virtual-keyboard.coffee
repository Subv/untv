###
UNTV - virtual-keyboard
Author: Gordon Hall

Creates an on-screen keyboard for capturing user text input
###

fs             = require "fs"
jade           = require "jade"
$              = require "../../vendor/jquery-2.0.3"
{EventEmitter} = require "events"
Remote         = require "../remote-server"

class VirtualKeyboard extends EventEmitter
  constructor: (@remote) -> 
    if @remote not instanceof Remote then throw new TypeError """
      Value 'remote' is not an instance of Remote
    """

  view: jade.compile fs.readFileSync "#{__dirname}/../../views/keyboard.jade"

  prompt: (hint = "Enter text:", callback) =>
    # if a callback is specified, bind to the input event
    if typeof callback is "function" then @once "input", callback
    # compile the view
    compiled_view = view hint: hint
    # remove any existing ui instance and replace with new one
    do @unbind
    ($ "##{view_id}").remove()
    ($ "body").append compiled_view
    do @bind

  bind: =>
    # setup remote and keyboard bindings
    for event in @events
      @remote.on event.name, event.handler

  unbind: =>
    # remove remote listeners
    for event in @events
      @remote.removeListener event.name, event.handler

  moveUp: =>


  moveDown: =>


  moveLeft: =>
    

  moveRight: =>


  selectKey: =>


  events: [
    { name: "scroll:up", handler: @moveUp }
    { name: "scroll:down", handler: @moveDown }
    { name: "go:back", handler: @moveLeft }
    { name: "go:next", handler: @moveRight }
    { name: "go:select", handler: @selectKey }
  ]

module.exports = VirtualKeyboard
