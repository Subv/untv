# Authoring and Modifying Extensions

One of the key concepts I have tried to keep in mind is the way in which UNTV can be extended. UNTV comes bundled with 6 extensions (at the time of writing).

1. **Instant Streaming** - allowing for search and streaming of BitTorrent movies
2. **Video Library** - allowing for navigating a local directory of movies and playing them
3. **Music Player** - allowing for navigating a local directory of music and playing it
4. **Photo Slideshow** - allowing for navigating a local directory of photos and viewing them
5. **Extensions Manager** - allowing for installing/removing/updating third party extensions
6. **Settings & Preferences** - providing an interface for modifying configuration of UNTV and extensions

When UNTV starts, the first thing that happens after the `GlobalMenu` is initialized is that the bundled extensions are loaded, then third party extensions are loaded from `~/.untv/extensions`. UNTV decides how to load an extension based on the `manifest.json` file located in the root of the extension directory.

## Manifest Format

The manifest file must be a valid JSON document accepting the following properties:

* **name** - `String` name to appear in the menu
* **passive** - `Boolean` indicating whether or not the extension should be loaded passively
* **icon** - `String` relative path to icon to use (*SVG recommended*)
* **description** - `String` brief description of what the extension does (appears under name in menu)
* **main** - `String` relative path to the extension's main script (more information below)
* **view** - `String` relative path to the template file to render on load (before executing main script)
* **list_priority** - `Number` intended index in global menu
* **stylesheets** - `Array` of `String` relative paths to stylesheets to load (CSS and LESS supported)
* **config** - `Hash` of your extension configuration (optional - see [Using the Settings API](https://github.com/gordonwritescode/untv/wiki/Using-the-Settings-API))
* **locals** - `Hash` to compile with rendered view (optional)

Below is a sample manifest file from the instant streaming extension:

```json
{
  "name": "Instant Streaming",
  "icon": "icons/icon-white.svg",
  "description": "Search and browse BitTorrents and stream movies.",
  "main": "extension.coffee",
  "view": "view.jade",
  "list_priority": 0,
  "stylesheets": [
    "styles/extension.css"
  ],
  "config": {
    
  },
  "locals": {
  
  }
}
```

## Writing Your Extension

When UNTV registers your extension with the GlobalMenu, the script defined as `"main"` in your manifest file, gets `require`'d and stored in memory. When the user chooses to load your extension by selecting it from the menu, the return value of that script gets executed (this means your "main" module should export a function).

This buys us a couple things. For starters, any code we do not include in the exported function gets executed once during registration, so this makes it easy do do any preliminary setup work (however we have minimal access to UNTV components). More importantly, the function we export gets executed *every time the user selects the extension* (and this function has access to UNTV components).

Here is what a bare bones extension might look like:

```coffeescript
# gets executed once during registration
console.log "registered my extension!"
# gets executed on extension load
module.exports = (manifest, remote, player, notifier, view, gui) ->
  # access manifest file as object literal
  config = manifest.config
  # access the gui kit library
  my_grid = new gui.NavigableGrid view
  # use notification system
  notifier.notify manifest.name, "Loaded!", yes
  # access the view
  view.html "press select to watch a movie"
  # access the remote emitter
  remote.on "go:select", ->
    # access the global player
    player.play config.default_movie_path
```

## Passive Extensions

In many cases, your extension may not be an "application" in that there is no view and no entry into `GlobalMenu` for loading your extension. This might include **themes** or **remote interfaces**.

Setting the value of `passive` to `true` in your extension manifest will execute your extension code *once* upon the initial load of UNTV. A menu entry will not be created and stylesheets included in the manifest will not be purged when another extension in loaded.

### Themes

Creating a theme is easy - all you need is a valid manifest file and a stylesheet. Here is an example manifest for a theme:

```json
{
  "name": "My Theme",
  "passive": true,
  "stylesheets": [
    "path/to/stylesheet.css"
  ]
}
```

And your directory structure would look like this:

```
my_theme/
|- manifest.json
|- theme.css
```

### Tweaks and Remote Interfaces

Other passive extensions might seek to modify or embellish the behavior of UNTV altogether. One prime example might be to add support for different remotes. For example, if you wanted to add support for using an AppleTV remote via an IR module for the Raspberry Pi, you would need to hook into UNTV's `Remote` API.

In this case, you create your extension just as you normally would, but the function that you export from your `main` script only gets executed once at runtime. For example:

```coffeescript
module.exports = (manifest, remote, player, notifier, view, gui) ->
  # do crazy voodoo magic to get IR input
  ir_remote = magicallyGetAppleTVRemote()
  # then just force the remote to emit it's normal set of events
  ir_remote.on "input", (button) ->
    switch button
      when "left" then remote.emit "scroll:left"
      when "right" then remote.emit "scroll:right"
      when "up" then remote.emit "scroll:up"
      when "down" then remote.emit "scroll:down"
      when "select" then remote.emit "go:select"
```
