###
UNTV - remote-server.coffee
Author: Gordon Hall

Sets up HTTP server for delivering the remote control interface 
and acts as the communication bus between the remote and tv player
###

{readFileSync}  = require "fs"
{EventEmitter}  = require "events"
{createServer}  = require "http"
RemoteInterface = require "./remote-interface"
socket_io       = require "socket.io"
jade            = require "jade"

class RemoteServer extends EventEmitter
  constructor: (@port, data={}) ->
    @server = createServer (req, res) => 
      # compile view and serve up the new remote instance
      view       = readFileSync "../views/remote.jade"
      @interface = jade.compile view, data
      res.end @interface
    @sockets   = (socket_io.listen @server).sockets
    do @subscribe
  subscribe: =>
    @sockets.on "connection", (client) =>
      # inform any subscribers that the remote is connected
      @emit "remote_connected", client
      # global menu events
      client.on "menu:open", (data) => @emit "menu:open", data
      client.on "menu:close", (data) => @emit "menu:close", data
      client.on "menu:select", (data) => @emit "menu:select", data
      # navigation events
      client.on "scroll:left", (data) => @emit "scroll:left", data
      client.on "scroll:right", (data) => @emit "scroll:right", data
      client.on "scroll:up", (data) => @emit "scroll:up", data
      client.on "scroll:down", (data) => @emit "scroll:down", data
      # player events
      client.on "player:play", (data) => @emit "player:play", data
      client.on "player:pause", (data) => @emit "player:pause", data
      client.on "player:next", (data) => @emit "player:next", data
      client.on "player:prev", (data) => @emit "player:prev", data
      client.on "player:seek", (data) => @emit "player:seek", data

    

