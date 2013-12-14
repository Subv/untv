###
UNTV - untv.coffee
Author: Gordon Hall

Initializes application
###

fs         = require "fs"
$          = require "./vendor/jquery-2.0.3.js"
GlobalMenu = require "./lib/tv-globalmenu"
Player     = require "./lib/tv-player"
Remote     = require "./lib/remote-server"
config     = JSON.parse fs.readFileSync "#{__dirname}/config.json"
gui        = global.window.nwDispatcher.requireNwGui()
win        = gui.Window.get()

# debug log wrapper
debug = (message) -> console.debug "UNTV:", message

###
Register Remote Control
###
remote = new Remote()
remote.server.listen config.remote_port, -> 
  debug "remote listening on port #{config.remote_port}"

###
Setup Global Menu and Player
###
player = new Player ($ "#player-container")
menu   = new GlobalMenu ($ "#menu-container"), remote, player

###
Load Extensions
###
extPath    = "#{__dirname}/lib/extensions"
extDir     = fs.readdirSync extPath

checkExtension = (path) ->
  stats = fs.statSync path
  if stats.isDirectory()
    # check for manifest file and parse it
    if fs.existsSync "#{path}/manifest.json"
      return manifest = JSON.parse fs.readFileSync "#{path}/manifest.json"
  null  

registerExtension = (path) ->
  manifest = checkExtension path
  if not manifest then return
  debug "registered extension: #{manifest.name}"
  # register extension with menu
  menu.addExtension path, manifest

registerExtension "#{extPath}/#{directory}" for directory, index in extDir

###
Get User Notifications
###


# show user interface
do win.show
