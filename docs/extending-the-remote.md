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

## Remote Interface (Smartphone)

The UNTV `Remote` class is instantiated with a single argument which defines 
the port on which the instance will serve the smartphone interface. If the 
`Remote` is instantiated without this parameter it will default to `8080`.

This starts a web server that is accessible via the host machine's IP address 
and port, when your phone is connected to the same local network.

When the interface is accessed via HTTP (using your phone's web browser), it 
opens a socket connection back to the host machine to transmit events receieved 
from the user (you), back to the originating `Remote` instance. These events 
are essentially proxied through the `Remote` instance after filtering out any 
non-standard events and since `Remote` is an `EventEmitter`, it simply emits 
the same events back to the UNTV application, where they are handled by the 
different interface components.

Since using a smartphone buys us some functionality we would otherwise not have 
using an IR remote or otherwise, the Remote Interface supports a few events 
UNTV can actually send to **it**.

This can be done by emitting an event from the application back to the 
`sockets` object tied to the `Remote` instance:

```javascript
var remote = new Remote(8080)
// send alert to phone
remote.sockets.emit("alert:show", {
  message: "Hello, Remote Interface!"
});
```

All of these events should pass an object where `message` is a string that 
should indicate to the user, what action should be taken if any.

### Event: "alert:show"

Shows a notification on the remote interface similar to a traditional `alert`, 
and emits an "alert:dismissed" event back to the `Remote`, when the alert is 
dismissed.

### Event: "prompt:ask"

Shows a text prompt on the remote interface similar to a traditional `prompt`, 
and emits a "prompt:answer" event back to the `Remote`, passing along the value 
the user entered into the prompt.

### Event: "confirm:ask"

Shows a confirmation popup on the remote interface similar to a traditional 
`confirm`, and emits a "confirm:answer" event back to the `Remote`, passing 
along a boolean value indicating whether or not the user confirmed.
