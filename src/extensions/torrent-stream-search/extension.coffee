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

  # get torrent search interface and dom containers
  torrents     = new TorrentSearch()
  container    = (gui.$ "#torrent-list")
  details_view = (gui.$ "#torrent-details")
  menu_view    = (gui.$ "#torrent-menu")
  
  ###
  Configure Movie Grid
  ###
  grid_config  = 
    adjust_x: menu_view.width()
    adjust_y: details_view.height()
    # prevents auto row switch on bounds reached left/right
    smart_scroll: no 
    # prevents auto row sizing based on visibility of items
    smart_rows: no
  # instantiate grid
  grid = new gui.NavigableGrid container, remote, grid_config
  
  ###
  Configure Menu List
  ###
  menu_config  = 
    adjust_y: 0
    adjust_x: details_view.width()
    # enables scroll to top/bottom when scrolling past bottom/top
    smart_scroll: yes 
  # instantiate grid
  menu = new gui.NavigableList (gui.$ "ul", menu_view), remote, menu_config
  # auto give menu focus
  menu.giveFocus 1

  ###
  Auto Load Newly Added (All Genres)
  ###
  torrents.latest (err, list) -> 
    (gui.$ "#torrent-list").removeClass "loader"
    if err then return notifier.notify manifest.name, "Request Failed."
    # sort list by IMDB user rating
    list = list.sort (a, b) -> 
      (parseFloat b.MovieRating) > (parseFloat a.MovieRating)
    # populate grid view
    grid.populate list, torrents.compileTemplate "list"

  ###
  Menu List Event Handlers
  ###
  menu.on "item_focused", (item) ->
    input = (gui.$ "input", item)
    if input.length then do input.focus

  menu.on "item_selected", (item) ->
    # load torrent list

  menu.on "out_of_bounds", (data) ->
    switch data.direction
      # when "up"
      # when "down"
      when "right"
        do menu.releaseFocus
        do grid.giveFocus

  ###
  Menu Search Bindings
  ###
  (gui.$ "#torrent-search").bind "keydown", (e) ->
    if e.keyCode in [38, 40] then (gui.$ @).trigger "blur"

  ###
  Grid Event Handlers
  ###
  detail_request = null
  grid.on "item_focused", (item) ->
    # kill any pending details request
    do detail_request?.abort
    movie_id = (gui.$ ".movie", item).data "id"
    # show details
    if movie_id
      details_view.addClass "loading"
      detail_request = torrents.get movie_id, (err, data) ->
        details_view.removeClass "loading"
        if err then return
        details = torrents.compileTemplate "details"
        # render view
        (gui.$ "#torrent-details").html details data

  grid.on "item_selected", (item) ->
    # load movie here?

  grid.on "out_of_bounds", (data) ->
    switch data.direction
      # when "up"
      # when "down"
      when "left"
        do grid.releaseFocus
        do menu.giveFocus
      # when "right"
