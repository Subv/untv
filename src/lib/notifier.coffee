###
UNTV - notifier.coffee
Author: Gordon Hall

Provides an interface for showing notifications and alert messages
on the user's TV
###

{EventEmitter} = require "events"
fs             = require "fs"
jade           = require "jade"
$              = require "../vendor/jquery-2.0.3"

class Notifier extends EventEmitter
  constructor: (@container, @menu, @remote) ->

  view:
    large: fs.readFileSync "#{__dirname}/../views/notification-large.jade"
    small: fs.readFileSync "#{__dirname}/../views/notification-small.jade"

  stealRemoteFocus: =>
    # borrow from the menu proto
    @menu.cacheRemoteListeners.call @
    # get rid of listeners
    do @remote.removeAllListeners
    # bind our own
    @remote.on "go:select", => do @dismiss
    @remote.on "scroll:up", => do @scrollUp
    @remote.on "scroll:down", => do @scrollDown

  returnRemoteFocus: =>
    # kill our listeners
    do @remote.removeAllListeners
    # borrow from the menu proto and rebind cached ones
    @menu.rebindCachedListeners.call @

  dismiss: =>
    @menu.container.animate
      top: "0%"
      bottom: "0%"
    , @animation_time, => @menu.container.removeClass "notifier-open"

    ($ "> *", @menu.container).animate
      top: "0%"
      bottom: "0%"
    , @animation_time, => ($ "> *", @menu.container).removeClass "notifier-open"

    @container.animate
      top: "100%"
      bottom: "-100%"
    , @animation_time, => do @container.hide

    do @returnRemoteFocus

  notify: (from = "System Message", content, is_passive) =>
    view    = if is_passive then @view.small.toString() else @view.large.toString()
    view    = jade.compile view
    content = view 
      initiator: from
      message: content
    @container.html content
    # play sound
    @remote.playEventSound "notify"
    # handle non-passive behavior
    if not is_passive
      # move the menu outta heeereee
      @menu.container.animate
        top: "-90%"
        bottom: "90%"
      , @animation_time, => @menu.container.addClass "notifier-open"

      ($ "> *", @menu.container).animate
        top: "-90%"
        bottom: "90%"
      , @animation_time, => ($ "> *", @menu.container).addClass "notifier-open"

      do @container.show
      @container.animate
        top: "10%"
        bottom: "0%"
      , @animation_time

      # steal remote focus
      do @stealRemoteFocus

  animation_in: "" #"fadeInUp"
  animation_out: "" #"fadeOutDown"
  animation_time: 300

module.exports = Notifier
