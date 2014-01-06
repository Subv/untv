###
UNTV - navigable-list
Author: Gordon Hall

Accepts an unordered list and create a navigable
list view
###

SmartAdjuster  = require "./smart-adjuster"
$              = require "../../vendor/jquery-2.0.3"
{EventEmitter} = require "events"

class NavigableList extends EventEmitter
  constructor: (@list_element, @remote, @config) ->
    # handle default config
    @config.adjust_y     ?= 0
    @config.adjust_x     ?= 0
    @config.smart_scroll ?= no
    # create scrolling wrapper
    @list_element = $ @list_element
    @scroller     = $ "<div class='navilist'/>"
    @scroller.css 
      overflow: "hidden"
      position: "fixed"
      width: "#{($ window).width() - @config.adjust_x}px"
      height: "#{($ window).height() - @config.adjust_y}px"
    @scroller = @list_element.wrap @scroller

    ($ window).bind "resize", => do @setScrollPosition
    do @bindRemoteControls

  bindRemoteControls: =>
    @remote.on "go:next", => (@emit "out_of_bounds", direction: "right") if @focused
    @remote.on "go:back", => (@emit "out_of_bounds", direction: "left") if @focused
    @remote.on "go:select", => (@emit "item_selected", @last_item) if @focused
    @remote.on "scroll:up", => do @prevItem if @focused
    @remote.on "scroll:down", => do @nextItem if @focused

  nextItem: =>
    if @last_item.next().length
      @last_item.removeClass @selected_item_classname
      @last_item = @last_item.next().addClass @selected_item_classname
    else
      if @config.smart_scroll
        @last_item.removeClass @selected_item_classname
        @last_item = ($ "li", @scroller).first().addClass @selected_item_classname
        @setScrollPosition @last_item
      else
        @emit "out_of_bounds", direction: "bottom"
    @emit "item_focused", @last_item

  prevItem: =>
    if @last_item.prev().length
      @last_item.removeClass @selected_item_classname
      @last_item = @last_item.prev().addClass @selected_item_classname
    else
      if @config.smart_scroll
        @last_item.removeClass @selected_item_classname
        @last_item = ($ "li", @scroller).last().addClass @selected_item_classname
        @setScrollPosition @last_item
      else
        @emit "out_of_bounds", direction: "top"
    @emit "item_focused", @last_item

  setScrollPosition: (pos) =>


  giveFocus: (index = 0)=>
    @focused = yes
    @scroller.addClass @focused_area_classname
    if index
      item = ($ "li", @scroller)[index]
      @last_item = ($ item).addClass @selected_item_classname if item
    else
      if @last_item then @last_item.addClass @selected_item_classname
      else @last_item = ($ "li", @scroller).first().addClass @selected_item_classname

  releaseFocus: =>
    @focused = no
    @scroller.removeClass @focused_area_classname
    if @last_item then @last_item.removeClass @selected_item_classname

  selected_item_classname: "navilist-selected"
  focused_area_classname: "navilist-focused"
  scroll_speed: 200

module.exports = NavigableList
