###
UNTV - remote-server.coffee
Author: Gordon Hall

Sets up HTTP server for delivering the remote control interface 
and acts as the communication bus between the remote and tv player
###

{readFileSync} = require "fs"
{EventEmitter} = require "events"
{createServer} = require "http"
express        = require "express"
socket_io      = require "socket.io"
browserify     = require "browserify"
coffeeify      = require "coffeeify"

class Remote extends EventEmitter
  
  constructor: ->
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

  events: [
    # global menu events
    "menu:open"
    "menu:close"
    # navigation events
    "go:next"
    "go:back"
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
