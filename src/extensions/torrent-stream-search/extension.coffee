###
UNTV - torrent-stream-search extension
Author: Gordon Hall

Enables user to search for torrents using the Yifi JSON API and
stream them directly to the global player instance
###

fs            = require "fs"
TorrentSearch = require "./torrent-search"

module.exports = (manifest, remote, player, notifier, view, gui) ->
  config   = manifest.config
  # show disclaimer on launch?
  disclaimer = (fs.readFileSync "#{__dirname}/disclaimer.html").toString()
  notifier.notify manifest.name, disclaimer if config.show_disclaimer

  # get torrent search interface
  torrents = new TorrentSearch()
  # then create a navigable grid
  grid = new gui.NavigableGrid (gui.$ "#torrent-list"), remote
  
  # default show list
  torrents.latest (err, list) -> 
    (gui.$ "#torrent-list").removeClass "loader"
    
    if err then return
    grid.populate list, torrents.compileTemplate "list"
    do grid.giveFocus
