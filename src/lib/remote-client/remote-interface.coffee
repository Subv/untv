###
UNTV - remote-interface.coffee
Author: Gordon Hall

Sets up remote control bindings for publishing events to the
remote control bus for interception by the tv interface components
###

$        = window.jQuery
socket   = window.io.connect location.origin

###
Setup Interaction Bindings
###
($ document).ready ->

  trackpad = $ "#trackpad"
  dpad     = $ "#dpad"
  controls = $ "#controls"
  options  = $ "#options"

  swipe_threshold = 75
  swipe_distance  = 0

  #trackpad navigation
  trackpad.swipe
    fingers: "all"
    threshold: swipe_threshold
    maxTimeThreshold: 2500
    swipeStatus: (event, phase, direction, distance, duration, fingers) ->
      if phase is "move" and fingers is 1
        swipe_distance = distance
        if swipe_distance >= swipe_threshold
          swipe_distance = 0
          socket.emit "scroll:up" if direction is "up"
          socket.emit "scroll:down" if direction is "down"
          socket.emit "go:next" if direction is "right"
          socket.emit "go:back" if direction is "left" 

  selection_check = ->
    select_ok       = yes
    select_not_ok   = -> select_ok = no
    check_select_ok = ->
      if select_ok then socket.emit "go:select"
      trackpad.unbind "touchmove", select_not_ok
      trackpad.unbind "touchend", check_select_ok
      trackpad.bind "touchstart", bind_selection_checker
    trackpad.bind "touchmove", select_not_ok
    trackpad.bind "touchend", check_select_ok

  # trackpad selection
  trackpad.bind "touchstart", selection_check

  scroll_interval = null

  ($ "button").bind "touchstart", (event) ->
    button = $ @
    action = button.data "action"
    socket.emit action
    scroll_interval = setInterval -> 
      socket.emit action
    , 800
    button.addClass "active"

  ($ "button").bind "touchend", (event) ->
    button = $ @
    button.removeClass "active"
    do button.blur
    clearInterval scroll_interval

  # ($ "button").click (event) ->
  #   action = ($ @).data "action"
  #   socket.emit "player:#{action}"

  ($ "[type='range']", controls).change (event) ->
    value = @value
    socket.emit "player:seek", value: value

###
Setup Events from TV
###
socket.on "prompt:ask", (data) ->
  input = window.prompt data.message
  socket.emit "prompt:answer", value: input

socket.on "confirm:ask", (data) ->
  confirmation = window.confirm data.message
  socket.emit "confirm:answer", value: confirmation

socket.on "alert:show", (data) ->
  window.alert data.message
  socket.emit "alert:dismissed"
