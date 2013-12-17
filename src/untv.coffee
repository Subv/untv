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

###
Setup Remote, Global Menu, and Player
###
remote = new Remote()
player = new Player ($ "#player-container"), remote
menu   = new GlobalMenu ($ "#menu-container"), remote, player

###
Register Remote Control Server
###
remote.server.listen config.remote_port, -> 
  console.log "remote listening on port #{config.remote_port}"

###
Load Extensions
###
ext_path = "#{__dirname}/lib/extensions"
ext_dir  = fs.readdirSync ext_path

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
  console.log "registered extension: #{manifest.name}"
  # register extension with menu
  menu.addExtension path, manifest

registerExtension "#{ext_path}/#{directory}" for directory, index in ext_dir

###
Get User Notifications
###

status_bar = $ "#status-bar"
# here we want to listen for remote connections to alert
# the user when a remote is connected
remote.on "remote:connected", ->
  ($ ".remote-connection span", status_bar).html "Remote: Connected"
  do ($ ".remote-connection .notification", status_bar).hide

remote.on "remote:disconnected", ->
  ($ ".remote-connection span", status_bar).html "Remote: Disonnected"
  do ($ ".remote-connection .notification", status_bar).show

# we also want to show the current time, whether or not
# there is a network connection, and the remote control 
# ip to use to connect to

# show user interface
do win.show
