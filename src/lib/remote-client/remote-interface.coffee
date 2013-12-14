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
  controls = $ "#controls"

  trackpad.swipe
    fingers: "all"
    swipe: (event, direction, distance, duration, fingers) ->
      # handle number of fingers
      switch fingers
        # 2 finger swipes
        when 2
          socket.emit "menu:open" if direction is "right"
          socket.emit "menu:close" if direction is "left"
        # single finger swipes
        when 1
          socket.emit "scroll:up" if direction is "up"
          socket.emit "scroll:down" if direction is "down"
          socket.emit "go:next" if direction is "right"
          socket.emit "go:back" if direction is "left"

  ($ "button", controls).click (event) ->
    action = ($ @).data "action"
    socket.emit "player:#{action}"

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
