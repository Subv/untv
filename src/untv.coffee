###
UNTV - untv.coffee
Author: Gordon Hall

Initializes application
###

fs         = require "fs"
$ = jQuery = require "vendor/jquery-2.0.3"
GlobalMenu = require "lib/tv-globalmenu"
Player     = require "lib/tv-player"
Remote     = require "lib/remote-server"
Extension  = require "lib/tv-panelextension"

# load configuration
config = fs.readFileSync "#{__dirname}/config.json"

# create a debug log wrapper
debug = (message) -> console.debug "UNTV:", message

# create remote control instance
remote = new Remote()
remote.listen config.remote_port

# instantiate global menu and give it existing remote context
menu = new GlobalMenu ($ "#menu-container"), remote

# traverse lib/extensions and load each extension
extensions = {}
extDir     = fs.readdirSync "#{__dirname}/lib/extensions"

checkExtension = (path) ->
  stats = fs.statSync path
  if stats.isDirectory()
    # check for manifest file and parse it
    if fs.existsSync "#{path}/manifest.json"
      manifest = JSON.parse fs.readFileSync "#{path}/manifest.json"
  null  

loadExtension = (path) ->
  manifest = checkExtension path
  if not manifest then return
  debug "Loading extension #{manifest.name}..."
  # register extension

loadExtension "#{__dirname}/#{directory}" for directory, index in extDir
