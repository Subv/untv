Sending Media to the Player
===========================

Media playback is handled by an instance of `Player` that gets instantiated in `untv.coffee`. This instance is passed to the `GlobalMenu` and from there distibuted out to all non-passive extensions.

The player is automatically subscribed to a set of events from the `Remote` instance passed to it. This set of events is all events that are part of the "player:*" namespace. In addition, the player is subscribed to "menu:toggle", so it can be paused automatically, when the menu is opened.

## Events

The `Player` class is an `EventEmitter` and publishes a few events that may be of use, however, you will likely only use a few of the core methods.

### Event: "player:seek"

Fired when the user is seeking through the currently playing media, passing along with it the timestamp for each seek event. This may be useful for updating a custom seeker control or similar.

## Core Methods

#### play(source, media_type)

Sends the file at `source` to the player for playback. Specifiy a `media_type` of either "video" or "audio" to inform the player instance whether or not it needs to steal space in the interface.

#### pause(minimize)

Pauses the currently playing media. If the `minimize` flag is set, then if the player is currently visible, it will be hidden until the next time `play()` is called.

#### next()

Performs a `seek()` forward by the default `seek_increment`.

#### prev()

Performs a `seek()` backward by the default `seek_increment`.

#### seek(time)

Moves the current position of playback to the specified `time`.

## Playlists

The `Player` class exposes a `playlist` property which contains a subset of methods used for managing a playlist. Playlists can be any length of items with any combination of media types.

#### add(item, media_type)

Adds the specified `item` (source path) with the specified `media_type` to the end of the playlist.

#### remove(item)

Removes the specified `item` (source path) from the playlist.

#### next()

Skips to the next item in the playlist.

#### prev()

Skips to the previous item in the playlist.

#### empty()

Removes all items from the playlist.

## Example

Below is a basic example of how you might read the contents of a directorys and send the first movie file media to the player (a rather arbitrary and unlikely use case). 

```coffeescript
module.exports = (env) ->
    contents = fs.readdirSync "path/to/movies"
    for file in contents
        if path.extname(file) is ".mkv"
            return env.player.play(file, "video")
```
