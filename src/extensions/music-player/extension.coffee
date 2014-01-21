###
UNTV - music player extension
Author: Gordon Hall

Enables user to play music located on their local drive or
mounted disks
###

fs              = require "fs"
path            = require "path"
music_meta_data = require "musicmetadata"

module.exports = (manifest, remote, player, notifier, view, gui) ->
  # build extension here!
