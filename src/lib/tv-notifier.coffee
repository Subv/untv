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

    # notification keyframe set
    $.keyframe.define
      name: @dismiss_keyframe_name
      from: "top: 10%; bottom: 0%;"
      to: "top: 100%; bottom: -100%;"

    # menu keyframe set
    $.keyframe.define
      name: @menu_reset_keyframe_name
      from: "top: -90%; bottom: 90%;"
      to: "top: 0%; bottom: 0%;"

    @container.playKeyframe
      name: @dismiss_keyframe_name
      duration: @animation_time

    @menu.container.playKeyframe
      name: @menu_reset_keyframe_name
      duration: @animation_time
      complete: => 
        @menu.container.removeClass "notifier-open"
        @menu.container.removeAttr "style"

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

      # notification keyframe set
      $.keyframe.define
        name: @notify_keyframe_name
        from: "top: 100%; bottom: -100%;"
        to: "top: 10%; bottom: 0%;"

      # menu keyframe set
      $.keyframe.define 
        name: @menu_aside_keyframe_name
        from: "top: 0%; bottom: 0%;"
        to: "top: -90%; bottom: 90%;"

      @container.playKeyframe
        name: @notify_keyframe_name
        duration: @animation_time
        complete: => do @adjustContentHeight

      @menu.container.playKeyframe
        name: @menu_aside_keyframe_name
        duration: @animation_time
        complete: => 
          @menu.container.addClass "notifier-open"

      # steal remote focus
      do @stealRemoteFocus
    # handle passive notifications
    else
      notif_id     = do hat
      notification = $ content
      notification.attr "data-id", notif_id

      @passive_container.html notification
      @passive_container.fadeIn 200

      clearTimeout @passive_timeout
      @passive_timeout = setTimeout ->
        ($ "[data-id='#{notif_id}']").fadeOut 200, -> 
          do ($ "[data-id='#{notif_id}']").remove
      , @passive_timeout_length

  animation_in: "" #"fadeInUp"
  animation_out: "" #"fadeOutDown"
  animation_time: 400
  passive_timeout_length: 4000
  dismiss_keyframe_name: "dismiss_notification"
  notify_keyframe_name: "show_notification"
  menu_reset_keyframe_name: "reset_menu"
  menu_aside_keyframe_name: "aside_menu"

module.exports = Notifier
