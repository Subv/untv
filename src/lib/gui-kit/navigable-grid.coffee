###
UNTV - navigrid
Author: Gordon Hall

Accepts an unordered list selector or element and creates
a navigable grid instance
###

SmartAdjuster  = require "./smart-adjuster"
$              = require "../../vendor/jquery-2.0.3"
{EventEmitter} = require "events"

class NavigableGrid extends EventEmitter
  constructor: (@container, @remote, @adjust_x, @adjust_y) ->
    @container = $ @container
    @container.css overflow: "hidden"
    ($ window).bind "resize", => do @populate

  populate: (list_data, template_fn) =>
    @data   ?= list_data
    @render ?= template_fn or ->
    # use smart adjuster to size the container
    # first get x and y adjuster sizes
    adjuster = new SmartAdjuster @container, @adjust_x, @adjust_y
    # determine the size of a single list item template
    pseudo_item = $ "<li/>"
    pseudo_item.css opacity: 0
    pseudo_item.html @render @data[0]
    @container.append pseudo_item
    # determine size of container and items
    item_width   = pseudo_item.outerWidth()
    item_height  = pseudo_item.outerHeight()
    row_items    = Math.floor adjuster.width / item_width
    total_rows   = Math.ceil @data.length / row_items
    row_width    = item_width * row_items
    rows_visible = Math.floor adjuster.height / item_height
    row_height   = adjuster.height / rows_visible
    # create a set of <ul>'s containing <li>'s consistent
    # with the width of the container
    @container.empty()
    row_counter = 0
    # for every row we expect, create an <ul>
    @container.append $ "<ul/>" for row in [0..total_rows]
    # setup width and height of rows
    rows = $ "ul", @container
    rows.width row_width
    rows.height row_height

    for item, index in @data
      next_row = index isnt 0 and (index % row_items) is 0
      # determine whether or not to add to next row
      if next_row then row_counter++
      target_row = $ rows[row_counter]
      # append output to the target row
      target_row.append "<li>#{@render item}</li>"

module.exports = NavigableGrid
