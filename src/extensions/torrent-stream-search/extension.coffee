###
UNTV - torrent-stream-search extension
Author: Gordon Hall

Enables user to search for torrents using the Yifi JSON API and
stream them directly to the global player instance
###

$             = require "../../vendor/jquery-2.0.3"
fs            = require "fs"
gui           = require "../../lib/gui-kit"
TorrentSearch = require "./torrent-search"

module.exports = (manifest, remote, player, notifier, view) ->
  config   = manifest.config
  # show disclaimer on launch?
  disclaimer = (fs.readFileSync "#{__dirname}/disclaimer.html").toString()
  notifier.notify manifest.name, disclaimer if config.show_disclaimer

  # get torrent search interface
  torrents = new TorrentSearch()
  # then create a navigable grid
  grid = new gui.NavigableGrid $ "#torrent-list", view
  
  # default show list
  torrents.latest (list) -> 
    (grid.populate list).removeClass "loader"    
