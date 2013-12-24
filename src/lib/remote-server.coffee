###
UNTV - remote-server.coffee
Author: Gordon Hall

Sets up HTTP server for delivering the remote control interface 
and acts as the communication bus between the remote and tv player
###

{readFileSync}      = require "fs"
{EventEmitter}      = require "events"
{createServer}      = require "http"
express             = require "express"
socket_io           = require "socket.io"
browserify          = require "browserify"
coffeeify           = require "coffeeify"
{networkInterfaces} = require "os"
$                   = require "../vendor/jquery-2.0.3"

class Remote extends EventEmitter
  
  constructor: (@port=8080) ->
    # create express server instance
    @app    = do express
    @server = createServer @app
    # setup express configuration
    @app.configure =>
      @app.set "views", "#{__dirname}/remote-client/views"
      @app.set "view engine", "jade"
      @app.use do express.bodyParser
      @app.use do express.methodOverride
      # @app.use express.favicon """
      #   #{__dirname}/remote-client/static/images/favicon.png
      # """
      @app.use express.static """
        #{__dirname}/remote-client/static
      """

    # bind application route
    @app.get "/", (req, res) ->
      res.render "remote"

    @app.get "/remote-interface.js", (req, res) ->
      bundle = browserify "#{__dirname}/remote-client/remote-interface.coffee"
      bundle.transform coffeeify
      bundle.bundle (err, file) ->
        bundle = if file then do file.toString else null
        res.send err or bundle

    # open socket connection to client
    @sockets = (socket_io.listen @server).sockets
    do @subscribe
    do @bindKeyboard

  listen: (callback) =>
    @server.listen @port, callback

  playEventSound: (sound = "keypress.ogg") =>
    player         = window.document.createElement "audio"
    player.src     = "#{@event_sounds}/#{sound}"
    player.name    = "remote-event-player"
    player.volume  = 0.2

    ($ player).bind "ended", -> do ($ player).remove
    ($ "body").append player
    do player.play

  event_sounds: "#{__dirname}/../assets/sounds"

  subscribe: =>
    @sockets.on "connection", (client) =>
      # inform any subscribers that the remote is connected
      @emit "remote:connected", client
      # inform when disconnected
      client.on "disconnect", => @emit "remote:disconnected"
      # proxy these events back up to our instance listeners
      bindings = @events.map (event) =>
        (=> client.on event, (data) => @emit event, data)
      bindings.forEach (bind) -> do bind

  bindKeyboard: =>
    keyboard = window.Mousetrap
    if "Mousetrap" not of window then return
    # setup keyboard bindings
    keyboard.bind "up", => @emit "scroll:up"
    keyboard.bind "down", => @emit "scroll:down"
    keyboard.bind "left", => @emit "go:back"
    keyboard.bind "right", => @emit "go:next"
    keyboard.bind "enter", => @emit "go:select"
    keyboard.bind "m", => @emit "menu:toggle"
    # keyboard.bind "escape", => @emit "menu:close"
    keyboard.bind "space", => @emit "player:play"
    keyboard.bind ">", => @emit "player:next"
    keyboard.bind "<", => @emit "player:prev"
    keyboard.bind "p", => @emit "player:pause"

  interfaces: =>
    interfaces = do networkInterfaces
    possible   = []
    for iface of interfaces
      for details in interfaces[iface]
        possible.push details if details.family is "IPv4" and not details.internal
    return possible

  events: [
    # global menu events
    # "menu:open"
    # "menu:close"
    "menu:toggle"
    # navigation events
    "go:next"
    "go:back"
    "go:select"
    # scroll events
    "scroll:up"
    "scroll:down"
    # player events
    "player:play"
    "player:pause"
    "player:next"
    "player:prev"
    "player:seek"
    # other actions
    "prompt:answer" # returned from `prompt:ask`
    "confirm:answer" # returned from `confirm:ask`
    "alert:dismissed" # returned from `alert:show`
  ]

module.exports = Remote
