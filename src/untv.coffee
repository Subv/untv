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
Notifier   = require "./lib/notifier"
config     = JSON.parse fs.readFileSync "#{__dirname}/config.json"
gui        = global.window.nwDispatcher.requireNwGui()
win        = gui.Window.get()

###
Setup Remote, Global Menu, and Player
###
notifier = new Notifier()
remote   = new Remote config.remote_port
player   = new Player ($ "#player-container"), remote
menu     = new GlobalMenu ($ "#menu-container"), remote, player

###
Register Remote Control Server
###
remote.listen -> 
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

# show user interface
do menu.checkRemoteInterface
do menu.checkInternet
do ($ "#init-loader").hide
do menu.open
do win.show
