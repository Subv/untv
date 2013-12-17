###
UNTV - torrent-stream-search extension
Author: Gordon Hall

Enables user to search for torrents using the Yifi JSON API and
stream them directly to the global player instance
###

module.exports = (remote, player, PanelExtension) ->

  class InstantStream extends PanelExtension
    # figure out how to handle remote event listeners
    onactivated: ->
      # do panel initialization here
      alert "activated!"
