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


module.exports = NavigableList
