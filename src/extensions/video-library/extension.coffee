###
UNTV - video-library extension
Author: Gordon Hall

Enables user to browse their local hard disk or attached
devices or mounted disks for videos and play them
###

module.exports = (manifest, remote, player, notifier, view, gui) ->

  ###
  Load FileSelector
  ###
  selector_container = (gui.$ "#files", view)
  file_selector      = new gui.FileSelector selector_container, remote, ["*"]
