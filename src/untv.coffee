###
UNTV - untv.coffee
Author: Gordon Hall

Initializes application
###

fs         = require "fs"
dns        = require "dns"
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
remote = new Remote config.remote_port
player = new Player ($ "#player-container"), remote
menu   = new GlobalMenu ($ "#menu-container"), remote, player

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

###
Get User Notifications
###

status_bar     = $ "#status-bar"
# first let's tell the user where they can connect their remote
remote_iface = remote.interfaces()[0]
has_iface    = if remote_iface then yes else no

if has_iface 
  remote_url = "http://#{remote_iface.address}:#{remote.port}/"
else 
  remote_url = "Unavailable"

($ ".remote-connection .address", status_bar).html remote_url
# here we want to listen for remote connections to alert
# the user when a remote is connected
remote.on "remote:connected", ->
  ($ ".remote-connection .address", status_bar).html "Connected"
  # hide remote notification here

remote.on "remote:disconnected", ->
  ($ ".remote-connection .address", status_bar).html remote_url
  # show remote notification here

# we also want to show the current time
clock = ->
  time   = new Date do Date.now
  hour   = do time.getHours
  mins   = do time.getMinutes
  suffix = unless (hour > 11) then "AM" else "PM"
  # format time
  if hour > 12 then hour = hour - 12
  if mins.toString().length is 1 then mins = "0#{mins}"
  clock = "#{hour}:#{mins} #{suffix}"

($ "#status-bar .clock").html do clock
setInterval -> 
    ($ "#status-bar .clock").html do clock
, 60000

# show if there is a network connection
dns.resolve "www.google.com", (err) ->
  ip_status = ($ ".internet-connection .status").html
  if err then ip_status "Disconnected" else ip_status "Connected"

# show user interface
do win.show
