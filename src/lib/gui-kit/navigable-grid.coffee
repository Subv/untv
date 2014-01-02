###
UNTV - navigrid
Author: Gordon Hall

Accepts an unordered list selector or element and creates
a navigable grid instance
###

$ = require "../../vendor/jquery-2.0.3"

module.exports = class NavigableGrid
  constructor: (@container) ->

  populate: (list) =>
    @container.html list
