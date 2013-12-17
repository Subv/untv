###
UNTV - tv-player.coffee
Author: Gordon Hall

Defines a "player" instance that can be passed media for playback
###

{EventEmitter} = require "events"
$              = require "../vendor/jquery-2.0.3.js"

class Player extends EventEmitter
  constructor: (@container, @remote) ->
    # create audio player
    @audio          = window.document.createElement "audio"
    @audio.controls = off
    @audio.autoplay = on
    @audio.src      = null

    # create video player
    @video          = window.document.createElement "video"
    @video.controls = off
    @video.autoplay = on
    @video.height   = @height
    @video.width    = @width
    @video.src      = null

    # listen for remote events
    do @subscribe

  width: 1920
  height: 1080
  active_player: null

  play: (src, media_type) =>
    # if src and media type are passed, then update the player
    if src and media_type
      if media_type not in @media_types then throw "#{media_type} not supported"
      # set the active player
      @active_player     = @[media_type]
      @active_player.src = src
      # inject the active player into the container
      if not (@container.children media_type).length
        @container.html @active_player
    # otherwise go ahead and resume from where we left off if
    # there is an active media source
    if @active_player.src
      do @container.show
      # play the media
      do @active_player.play
      # inform listeners
      @inform_interval = setInterval @informTime, 1000

  pause: (minimize) =>
    do @active_player?.pause
    clearInterval @inform_interval
    do @container.hide if minimize

  seek: (time) ->
    @active_player?.fastSeek time if time < duration

  next: =>
    # seek by increment forward

  prev: =>
    # seek by increment backward

  seek_increment: 12000 # 12 secs

  duration: =>
    @active_player?.duration

  informTime: =>
    time = @active_player?.currentTime
    @emit "player:progress", 
      duration: @duration()
      position: time

  inform_interval: null

  subscribe: =>
    @remote.on "player:play", @play
    @remote.on "player:pause", @pause
    @remote.on "player:next", @next
    @remote.on "player:prev", @prev
    # remote should pass a fastSeek parameter
    @remote.on "player:seek", (data) =>
      @active_player?.fastSeek data.position
      
  media_types: [
    "video"
    "audio"
  ]


module.exports = Player
