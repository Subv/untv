Extending the Remote
====================

All user interaction in UNTV is facilitated by use of an instance of `Remote`. 
This instance is created in `src/untv.coffee`. Nearly all components that will 
require any user interaction or input will likely depend upon this "global" 
instance of `Remote`.

The `Remote` is an `EventEmitter` and it is through it's event interface that 
you interact with it.

## Events

The `Remote` emits a standardized set of events to help you determine how to 
properly handle user input. These events are caught and handled like so:

```javascript
var remote = new Remote();
remote.on("namespace:action", function() {
  // handle event here
});
```

As you can see in the example above, events are namespaced to make it clear 
which subset of actions the event belongs to. The namespaces currently include:

* scroll
* go
* menu
* player
* prompt
* confirm
* alert

### Event: "menu:toggle"

This event is fired when the user indicates they would like to toggle the 
global menu off or on. This event is automatically handled via the `GlobalMenu` 
instance and it is rare that you will need to handle it yourself.

### Event: "go:next"

This event is fired when the user indicates they would like to proceed to the 
next in a series of options. An example of this usage is it's use in the 
`VirtualKeyboard`, where this action triggers showing the "next" keyboard, as 
in cycling through the alphanumeric keyboard to the symbols keyboard.

### Event: "go:back"

This event is fired when the user indicates they would like to perform the 
opposite action of `go:next` **or** they would like to back out of whatever the 
current view may be. To cite the `VirtualKeyboard` class again, this is used to 
hide the keyboard and return to the previous state.

### Event: "go:select"

This event is fired when the user indicates a selection of whatver the current 
focused item is. This is used to select a menu item, play a movie, and similar.

### Event: "scroll:up"

This event is fired when the user indicates they wish to move focus to an item 
above the current focused item.

### Event: "scroll:down"

This event is fired when the user indicates they wish to move focus to an item 
below the current focused item.

### Event: "scroll:left"

This event is fired when the user indicates they wish to move focus to an item 
left of the current focused item.

### Event: "scroll:right"

This event is fired when the user indicates they wish to move focus to an item 
right of the current focused item.

### Event: "player:toggle"

This event fires when the user wishes to pause/play the currently playing 
media. This is handled automatically in the global `Player` instance.

### Event: "player:next"

This event fires when the user wishes to skip ahead in the currently playing 
media. This is handled automatically in the global `Player` instance.

### Event: "player:prev"

This event fires when the user wishes to skip back in the the currently playing 
media. This is handled automatically in the global `Player` instance.

### Event: "player:seek"

This event fires when the user wishes to specify the time in the currently 
playing media. This is handled automatically in the global `Player` instance.

### Event: "prompt:answer"

This event is fired as a response to a `remote.sockets.emit("prompt:ask")` 
event sent to the Remote Interface (smartphone) and contains text data.

### Event: "confirm:answer"

This event is fired as a response to a `remote.sockets.emit("confirm:ask")` 
event sent to the Remote Interface (smartphone) and contains boolean data.

### Event: "alert:dismissed"

This event is fired as a response to a `remote.sockets.emit("alert:show")` 
event sent to the Remote Interface (smartphone).


