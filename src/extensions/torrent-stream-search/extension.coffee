###
UNTV - torrent-stream-search extension
Author: Gordon Hall

Enables user to search for torrents using the Yifi JSON API and
stream them directly to the global player instance
###

gui           = require "../../lib/gui-kit"
TorrentSearch = require "./torrent-search"

module.exports = (manifest, remote, player, notifier, view) ->
  # get torrent search interface
  torrents = new TorrentSearch()
  # default show list
  torrents.latest (list) -> view.html list
  # show disclaimer on launch
  notifier.notify manifest.name, """
    Test test test test.
  """
