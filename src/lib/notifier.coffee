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
hat            = require "hat"

class Notifier extends EventEmitter
  constructor: (@container, @menu, @remote) ->
    @passive_container = $ "<ul/>"
    @passive_container.attr "id", "passive-notifier"
    @passive_container.appendTo "body"
    # attach notifier instance to menu
    @menu.notifier = @

  view:
    large: fs.readFileSync "#{__dirname}/../views/notification-large.jade"
    small: fs.readFileSync "#{__dirname}/../views/notification-small.jade"

  stealRemoteFocus: =>
    # borrow from the menu proto
    @menu.cacheRemoteListeners.call @
    # get rid of listeners
    do @remote.removeAllListeners
    do @menu.listenForRemoteConnectivity
    # bind our own
    @remote.on "go:select", => do @dismiss
    @remote.on "scroll:up", => do @scrollUp
    @remote.on "scroll:down", => do @scrollDown

  returnRemoteFocus: =>
    # kill our listeners
    do @remote.removeAllListeners
    do @menu.listenForRemoteConnectivity
    # borrow from the menu proto and rebind cached ones
    @menu.rebindCachedListeners.call @
    do @menu.checkRemoteInterface

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

  adjustContentHeight: =>
    total  = @container.innerHeight()
    title  = ($ "> h2", @container).outerHeight()
    aside  = ($ "> aside", @container).outerHeight()
    height = total - (title + aside)
    ($ ".content", @container).height height

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
      , @animation_time, => do @adjustContentHeight

      # steal remote focus
      do @stealRemoteFocus
    # handle passive notifications
    else
      notif_id     = do hat
      notification = $ content
      notification.attr "data-id", notif_id

      @passive_container.append notification
      @passive_container.fadeIn 200
      setTimeout ->
        ($ "[data-id='#{notif_id}']").fadeOut 200, -> 
          do ($ "[data-id='#{notif_id}']").remove
      , @passive_timeout

  animation_in: "" #"fadeInUp"
  animation_out: "" #"fadeOutDown"
  animation_time: 300
  passive_timeout: 4000

module.exports = Notifier
