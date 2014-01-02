###
UNTV - auto adjust height
Author: Gordon Hall

Listens on window resize and auto contrains the size of an element
minus the passed height and width
###

module.exports = class SmartAdjuster
  constructor: (height, width) ->

