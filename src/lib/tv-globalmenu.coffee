###
UNTV - tv-globalmenu.coffee
Author: Gordon Hall

Injects the global menu interface and subscribes to events from
the remote control bus
###

$              = require "../vendor/jquery-2.0.3.js"
{EventEmitter} = require "events"
jade           = require "jade"
fs             = require "fs"

class GlobalMenu extends EventEmitter

  constructor: (@container, @remote) ->
    @items   = []
    @visible = no
    # subscribe to remote events
    @remote.on "menu:open", @open
    @remote.on "menu:close", @close
    @remote.on "menu:select", @select
    @remote.on "scroll:up", @focusPrev
    @remote.on "scroll:down", @focusNext

  render: =>
    view_path = "#{__dirname}/../views/globalmenu.jade"
    compiled  = jade.compile fs.readFileSync view_path
    html      = compiled items: @items
    @container.html? html
    ($ "li:first-of-type", @container).addClass "has-focus"

  addItem: (item) =>
    @items.push item if item and item.name
    do @render

  open: =>
    @container.addClass "visible" if not @visible
    @visible = yes

  close: =>
    @container.removeClass "visible" if @visible
    @visible = no

  focusNext: =>
    next_item = @current().next()
    if next_item.length
      @current().removeClass "has-focus"
      next_item.addClass "has-focus"

  focusPrev: =>
    previous_item = @current().prev()
    if previous_item.length
      @current().removeClass "has-focus"
      previous_item.addClass "has-focus"

  select: =>
    # load extension

  current: => $ "li.has-focus", @container

module.exports = GlobalMenu
