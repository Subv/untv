###
UNTV - tv-globalmenu.coffee
Author: Gordon Hall

Injects the global menu interface and subscribes to events from
the remote control bus
###

$              = require "../vendor/jquery-2.0.3.js"
{EventEmitter} = require "events"
jade           = require "jade"
fs             = require "fs"
extend         = require "node.extend"
path           = require "path"
dns            = require "dns"

class GlobalMenu extends EventEmitter

  constructor: (@container, @remote, @player) ->
    @extensions    = []
    @visible       = no
    @window_height = ($ window).height()
    @ready         = yes
    do @subscribe

    ($ window).bind "resize", => 
      @window_height = ($ window).height()
      do @render

  ###
  Remote Client Subscriptions
  ###
  subscribe: =>
    # subscribe to remote events
    # @remote.on "menu:open", @open
    # @remote.on "menu:close", @close
    @remote.on "menu:toggle", @toggle
    @remote.on "go:select", @select
    @remote.on "scroll:up", @focusPrev
    @remote.on "scroll:down", @focusNext

  ###
  Draw Menu Interface
  ###  
  render: =>
    view_path = "#{__dirname}/../views/globalmenu.jade"
    compiled  = jade.compile fs.readFileSync view_path
    html      = compiled items: @extensions
    @container.html? html
    ($ ".menu-list li", @container).height @window_height
    ($ ".menu-list li:first-of-type", @container).addClass "has-focus"
    do @setClock
    do @checkRemoteInterface
    do @checkInternet

  ###
  Extension Registration and Rendering
  ###
  extension_loaded: no

  addExtension: (path, manifest) =>
    # check manifest's main file here and store reference to it
    extension        = extend yes, {}, manifest
    extension.path   = path
    extension.icon   = "#{path}/#{extension.icon}"
    init_script_path = "#{path}/#{extension.main}"
    if fs.existsSync init_script_path
      ext_init       = require init_script_path
      extension.main = ext_init
      view_raw       = fs.readFileSync "#{path}/#{extension.view}"
      extension.view = jade.compile view_raw.toString()

    @extensions.push extension if manifest and manifest.name
    # filter the list by list priority
    @extensions.sort (ext1, ext2) -> ext2.list_priority < ext1.list_priority 
    do @render

  ###
  Behaviors
  ###
  open: =>
    @container.removeClass "#{@menu_animation_out_classname}" if not @visible
    @container.addClass "visible #{@menu_animation_in_classname}" if not @visible
    ($ "#app").addClass "blurred"
    @visible = yes

  close: =>
    @container.removeClass "#{@menu_animation_in_classname}" if @visible
    @container.addClass "#{@menu_animation_out_classname}" if @visible
    ($ "#app").removeClass "blurred"
    @visible = no

  toggle: =>
    @remote.playEventSound "swish"
    if @visible and @extension_loaded then do @close else do @open

  focusNext: =>
    next_item = @current().next()
    if next_item.length and @visible and @ready
      @current().removeClass "has-focus #{@item_animation_classname}"
      next_item.addClass "has-focus #{@item_animation_classname}"
      @animateScroll @current_offset() - @window_height

  focusPrev: =>
    previous_item = @current().prev()
    if previous_item.length and @visible and @ready
      @current().removeClass "has-focus #{@item_animation_classname}"
      previous_item.addClass "has-focus #{@item_animation_classname}"
      @animateScroll @current_offset() + @window_height

  current_offset: => parseInt ($ "ul.menu-list", @container).css "margin-top" 

  animateScroll: (pixels) =>
    @ready = no
    @remote.playEventSound "woosh"
    ($ "ul.menu-list", @container).animate
      "margin-top": "#{pixels}px"
    , 400, "swing", => 
      @remote.playEventSound "keypress"
      @ready = yes

  select: =>
    if not @visible then return
    @remote.playEventSound "open", 0.8
    index     = @current().index "li", @container
    extension = @extensions[index]
    # inject view
    @extension_container().html extension.view()
    # remove previous extension stylesheets
    do ($ "link[data-type='extension'][rel='stylesheet']").remove
    # inject new stylesheets for selected extension
    stylesheets = extension.stylesheets or []
    stylesheets.forEach (css_path) ->
      stylesheet_path = "#{extension.path}/#{css_path}"
      stylesheet_type = (path.extname stylesheet_path).substr 1
      stylesheet      = ($ "<link/>")
      stylesheet.attr "rel", "stylesheet"
      stylesheet.attr "type", "text/#{stylesheet_type}"
      stylesheet.attr "href", stylesheet_path
      stylesheet.data "type", "extension"
      ($ "head").append stylesheet

    # call init script and close menu
    @extension_container().html @extensions[index].view
    # animate the transition out of the current extension
    @extension_container().removeClass "visible #{@menu_animation_in_classname}"
    @extension_container().addClass "#{@menu_animation_out_classname}"
    do @extension_container().hide
    # after the animation duration, execute the main extension script and
    # animate the extension view back into the main view
    setTimeout (=> 
      @extensions[index].main extension, @remote, @player, @extension_container()
      @extension_container().removeClass "#{@menu_animation_out_classname}"
      @extension_container().addClass "visible #{@menu_animation_in_classname}"
    ), 400

    @extension_loaded = yes
    # now remove all the event listeners bound to remote 
    # this is to get rid of listeners from previously loaded
    # extensions
    do @remote.removeAllListeners
    # re-subscribe the menu so that we always have access to it
    do @subscribe
    # no show the rendered extension and hide the menu
    do @extension_container().show
    do @close

  current: => $ "li.has-focus", @container

  item_animation_classname: "pulse"
  menu_animation_in_classname: "fadeIn"
  menu_animation_out_classname: "fadeOut"
    
  extension_container: => $ "#extensions-container"

  ###
  Status Indicators
  ###
  time: ->
    time   = new Date do Date.now
    hour   = do time.getHours
    mins   = do time.getMinutes
    suffix = unless (hour > 11) then "AM" else "PM"
    # format time
    if hour > 12 then hour = hour - 12
    if mins.toString().length is 1 then mins = "0#{mins}"
    "#{hour}:#{mins} #{suffix}"

  setClock: =>
    ($ "#status-bar .clock").html @time()
    clearInterval @clock if @clock
    @clock = setInterval -> 
      ($ "#status-bar .clock").html @time()
    , 60000 

  internet_connected: no

  checkInternet: =>
    # show if there is a network connection
    dns.resolve "www.google.com", (err) ->
      ip_status = ($ ".internet-connection .status")
      if err then ip_status.html "Disconnected" else ip_status.html "Connected"

    setInterval @checkInternet, 15000

  status_bar: => $ "#status-bar"
  
  remote_url: null

  checkRemoteInterface: =>
    remote_iface = @remote.interfaces()[0]
    has_iface    = if remote_iface then yes else no

    if has_iface 
      @remote_url = "http://#{remote_iface.address}:#{@remote.port}/"
    else 
      @remote_url = "Unavailable"

    ($ ".remote-connection .address", @status_bar()).html @remote_url
    # here we want to listen for remote connections to alert
    # the user when a remote is connected
    @remote.on "remote:connected", ->
      ($ ".remote-connection .address", @status_bar()).html "Connected"
      # hide remote notification here

    @remote.on "remote:disconnected", ->
      ($ ".remote-connection .address", @status_bar()).html @remote_url
      # show remote notification here

module.exports = GlobalMenu
