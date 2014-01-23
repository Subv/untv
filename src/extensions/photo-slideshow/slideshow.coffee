###
UNTV - slideshow class
Author: Gordon Hall

Creates a SlideShow instance accepting an array of photo objects and
allowing the user to navigate using the remote
###

path           = require "path"
jade           = require "jade"
fs             = require "fs"
{$}            = require "../../lib/gui-kit"
{EventEmitter} = require "events"

class SlideShow extends EventEmitter

  constructor: (@remote, @data) ->
    

  populate: (data, append_data=no) =>
    

  show: =>


  hide: =>


  next: =>


  prev: =>


  current_index: 0
  photo_out_keyframe_name: "slideshow_photo_out"
  photo_in_keyframe_name: "slideshow_photo_in"
  animation_time: 400
  view: jade.compile fs.readFileSync "#{__dirname}/views/slideshow.jade"

module.exports = SlideShow
