###
UNTV - torrent-stream-search extension
Author: Gordon Hall

Enables user to search for torrents using the Yifi JSON API and
stream them directly to the global player instance
###

fs            = require "fs"
TorrentSearch = require "./torrent-search"

module.exports = (manifest, remote, player, notifier, view, gui) ->
  config     = manifest.config
  disclaimer = (fs.readFileSync "#{__dirname}/disclaimer.html").toString()
  # show disclaimer
  notifier.notify manifest.name, disclaimer if config.show_disclaimer

  # get torrent search interface
  # then create a navigable grid
  torrents     = new TorrentSearch()
  container    = (gui.$ "#torrent-list")
  grid         = new gui.NavigableGrid container, remote, 0, window.height
  details_view = (gui.$ "#torrent-details")
  
  # default show list
  torrents.latest (err, list) -> 
    (gui.$ "#torrent-list").removeClass "loader"
    if err then return notifier.notify manifest.name, "Request Failed. :("
    grid.populate list, torrents.compileTemplate "list"
    do grid.giveFocus
    grid.emit "grid:item_focused", grid.getCurrentItem()

  ###
  Grid Event Handlers
  ###
  detail_request = null
  grid.on "grid:item_focused", (item) ->
    do detail_request?.abort
    movie_id = (gui.$ ".movie", item).data "id"
    # show details
    details_view.addClass "loading"
    detail_request = torrents.get movie_id, (err, data) ->
      details_view.removeClass "loading"
      if err then return
      details = torrents.compileTemplate "details"
      # render view
      (gui.$ "#torrent-details").html details data
