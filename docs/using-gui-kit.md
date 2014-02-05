Using the GUI Kit to Build Extensions
=====================================

As part of the core libraries, UNTV ships with a toolkit, tentatively name 
`gui-kit`. The GUI kit provides access to classes which help develop extensions 
for common use cases. This toolkit gets passed to each extension, so it can be 
used to build your extension interface.

This gets passed as the last argument to your extension's main function 
(`gui`):

```coffeescript
module.exports = (manifest, remote, player, notifier, view, gui) ->
```

Each component in the GUI kit is relatively "plug-and-play" in that, while they 
generally have a fairly robust API, you will likely only need to make use of a 
few of their core methods. Only these core methods are documented here in the 
interest of saving you from the noise of long-winded documentation.

If you find yourself needing a more custom implementation then "use the source 
Luke."

## Class: NavigableGrid(container, remote, config)

Generates a grid of items, where each item may receive focus from the remote 
and may be selected to perform a specified action. 

#### Config

* adjust_y: `Number` - See `SmartAdjuster`
* adjust_x: `Number` - See `SmartAdjuster`
* smart_scroll: `Boolean` - Scroll when row when reaching beginning or end of a row
* smart_rows: `Boolean` - Automatically size rows based on viewport size
* animation: `String` - Animation name to add to items (from animate.css)

#### Events

* "out\_of\_bounds": user attempts to move focus outside of grid 
* "item_focused": user changes focus to new item
* "item_selected": user selects the current focused item

#### Core Methods

##### populate(data, template_fn)

Populates the grid and renders the interface using `data`, which should be an `Array` of values (usually objects), to compile with the `template_fn`.

The `template_fn` should be a function that is a "precompiled template". An example might be the function returned from `jade.compile()` or `handlebars.compile()`.

This iterates through the data, inserting the returned HTML value gained from `template_fn(data[i])` and inserting it into a generated list item element.

##### giveFocus()

Enables navigation of the grid, giving focus to either the item that was last focused or the first item in the grid if calling for the first time.

##### releaseFocus()

Disables navigation of the grid, storing a reference to the last focused item.

## Class: NavigableList(list_element, remote, config)

Converts a standard unordered list and enables navigation from the remote by 
allowing focus and selection of each list item.

#### Config

* adjust_y: `Number` - See `SmartAdjuster`
* adjust_x: `Number` - See `SmartAdjuster`
* smart_scroll: `Boolean` - Scroll to top/bottom of list when reaching beginning or end
* leave_decoration: `Boolean` - Leaves the "focused" class on the current item, even when focus is released from the element

#### Events

* "out\_of\_bounds": user attempts to move focus outside of list 
* "item_focused": user changes focus to new item
* "item_selected": user selects the current focused item

#### Core Methods

##### giveFocus(index)

Enables navigation of the list, giving focus to either the item that was last focused, the item at the specified index, or the first item in the grid if calling for the first time.

##### releaseFocus()

Disables navigation of the list.

##### lock()

Prevents giving focus to the list. Useful for asynchronous event handlers where you don't want the user to interact with the list while they are waiting.

##### unlock()

Re-enables giving focus to the list

## Class: FileSelector(container, remote, ignore_types, config)

A `NavigableList` instance that is prepopulated with the file system contents. 
The selection of an item is automatically bound to the action of loading the 
intended directory listing. You need only to specify a container and listen for events.

You can constrain which types of items show using the `ignore_types` argument. Pass an array of file extensions in the form of `[".txt", ".jpg"]` to exclude them from the listing. If you wish to show only directories, you can pass a wildcard as an item like `["*"]`.

#### Config

* initial_path: `String` - Directory path to start in. Defaults to home directory

#### Events

* "out\_of\_bounds": user attempts to move focus outside of list 
* "dir_selected": user selects a directory
* "file_selected": user selects a file

#### Core Methods

##### update(path)

Changes the contents of the instance to the specified path.

## Class: SmartAdjuster(target, less\_y, less\_x)

Attaches a listener to the `window` for the `resize` event as well as immediately forcing a fixed position and size of 100% of the containing element minus the specified `less_x` and `less_y`.

This is helpful when creating fixed sized elements for variable screen sizes based on the size of other elements.

## Class: VirtualKeyboard(remote, config)

Creates an on-screen keyboard that can be used to provide a way to get text input from the user.

#### Config

* default: `String` - The default keyboard to show. Defaults to `alphanum"
* allow: `Array` of `String`s - Which keyboards are allowed. Possible options:
    - "alphanum"
    - "symbols"

#### Events

* "input": user closes or submits data from the keyboard 

#### Core Methods

##### prompt(message, callback)

Shows the keyboard and automatically binds a one-time event listener to the "input" event, calling it when the action is complete.

##### value()

Returns the current value of the keyboard's input field.
