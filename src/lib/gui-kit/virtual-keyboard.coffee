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
common         = require "../common"

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
    compiled_view = @view hint: hint
    # remove any existing ui instance and replace with new one
    do @unbind
    # do @cacheRemoteListeners
    do @getView().remove
    ($ "body").append compiled_view
    do @bind

  view_id: "vkeyboard"

  getView: => ($ "##{@view_id}")

  value: => ($ ".vkeyboard-value", @getView()).val()

  bind: =>
    # setup remote and keyboard bindings
    for event in @events
      @remote.on event.name, @[event.handler]

  unbind: =>
    # remove remote listeners
    for event in @events
      @remote.removeListener event.name, @[event.handler]

  cacheRemoteListeners: common.cacheRemoteListeners 
  rebindCachedListeners: common.rebindCachedListeners

  moveUp: =>
    console.log "up"

  moveDown: =>
    console.log "down"

  moveLeft: =>
    console.log "left"

  moveRight: =>
    console.log "right"

  selectKey: =>
    console.log "select"

  confirm: =>
    console.log "confirm"
    do @unbind
    do @rebindCachedListeners
    @emit "input", @value()

  cancel: =>
    console.log "cancel"
    do @unbind
    # do @rebindCachedListeners
    @getView().fadeOut 200, => do @getView().remove
    @emit "input", null


  events: [
    { name: "scroll:up", handler: "moveUp" }
    { name: "scroll:down", handler: "moveDown" }
    { name: "scroll:left", handler: "moveLeft" }
    { name: "scroll:right", handler: "moveRight" }
    { name: "go:select", handler: "selectKey" }
    { name: "go:back", handler: "cancel" }
    { name: "menu:toggle", handler: "cancel" }
  ]

module.exports = VirtualKeyboard
