###
UNTV - auto adjust height
Author: Gordon Hall

Listens on window resize and auto contrains the size of an element
minus the passed height and width
###

$ = require "../../vendor/jquery-2.0.3"

module.exports = class SmartAdjuster
  constructor: (@target, @less_y = 0, @less_x = 0) ->
    # unbind any previously bound smart adjuster
    # ($ window).unbind "resize", @adjust
    # and bind it back...
    # ($ window).bind "resize", @adjust
    do @adjust

  adjust: (event) =>
    win_height = ($ window).height()
    win_width  = ($ window).width()
    # set target height less specified 
    @width  = win_width - @less_x
    @height = win_height - @less_y
    # set it on the target
    ($ @target).height @height
    ($ @target).width @width
