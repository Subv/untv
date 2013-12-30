###
UNTV - torrent-stream-search extension
Author: Gordon Hall

Enables user to search for torrents using the Yifi JSON API and
stream them directly to the global player instance
###

fs            = require "fs"
gui           = require "../../lib/gui-kit"
TorrentSearch = require "./torrent-search"

module.exports = (manifest, remote, player, notifier, view) ->
  # get torrent search interface
  torrents = new TorrentSearch()
  # default show list
  torrents.latest (list) -> view.html list
  # show disclaimer on launch
  disclaimer = (fs.readFileSync "#{__dirname}/disclaimer.html").toString()
  notifier.notify manifest.name, disclaimer

  # build out the damn thing here
