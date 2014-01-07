###
UNTV - torrent-stream-search extension
Author: Gordon Hall

Enables user to search for torrents using the Yifi JSON API and
stream them directly to the global player instance
###

fs            = require "fs"
TorrentSearch = require "./torrent-search"
torrents      = new TorrentSearch()
localStorage  = window.localStorage

###
Pre-emptively Load Latest Movies and Cache
###
torrents.latest (err, list) -> 
  if err then return
  # sort list by IMDB user rating
  localStorage.setItem "movies:latest:all", JSON.stringify list.sort (a, b) -> 
    (parseFloat b.MovieRating) > (parseFloat a.MovieRating)

###
Initialize Extension 
###
module.exports = (manifest, remote, player, notifier, view, gui) ->
  config     = manifest.config
  disclaimer = (fs.readFileSync "#{__dirname}/disclaimer.html").toString()
  # show disclaimer
  notifier.notify manifest.name, disclaimer if config.show_disclaimer

  # get dom containers
  container    = (gui.$ "#torrent-list")
  details_view = (gui.$ "#torrent-details")
  menu_view    = (gui.$ "#torrent-menu")
  search       = (gui.$ "#torrent-search")
  
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
    animation: "fadeInUp"
  # instantiate grid
  grid = window.grid = new gui.NavigableGrid container, remote, grid_config
  
  ###
  Configure Menu List
  ###
  menu_config  = 
    adjust_y: 0
    adjust_x: details_view.width()
    # enables scroll to top/bottom when scrolling past bottom/top
    smart_scroll: yes 
    # leaves the selection class on focus removal
    leave_decoration: yes
  # instantiate grid
  menu = new gui.NavigableList (gui.$ "ul", menu_view), remote, menu_config
  # auto give menu focus
  menu.giveFocus 1

  ###
  Auto Populate Newly Added (All Genres)
  ###
  list = JSON.parse localStorage.getItem "movies:latest:all" or []
  grid.populate list, torrents.compileTemplate "list"

  ###
  Menu List Event Handlers
  ###
  menu.on "item_focused", (item) ->
    input = (gui.$ "input", item)
    if input.length
      do input.focus
      remote.sockets.emit "prompt:ask", message: input.attr "placeholder"

  menu.on "item_selected", (item) ->
    do menu.lock
    key   = item.attr "data-param-name"
    param = item.attr "data-list-param"

    query = quality: "1080p", limit: 50
    query[key] = param
    # load torrent list
    details_view.addClass "loading"
    torrents.list query, (err, list) ->
      if err or not list
        notifier.notify manifest.name, err or "No Results", yes
      else
        do menu.unlock
        grid.populate list, torrents.compileTemplate "list"
        do grid.giveFocus
      details_view.removeClass "loading"

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
  search.bind "keydown", (e) ->
    if e.keyCode in [38, 40] then (gui.$ @).trigger "blur"

  search.bind "keyup", (e) -> 
    item = (gui.$ @).parent()
    item.attr "data-list-param", @value

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
    item_data    = (gui.$ ".movie", item).data()
    torrent_url  = item_data.torrent
    torrent_hash = item_data.hash

    window.alert "#{torrent_url}\n#{torrent_hash}"
    # call an external function from here...
    # show a status indicator for the following steps...
    # - download the torrent to a temp directory 
    # - get metadata, make sure filetype is supported
    # - hash check the torrent file
    # - start peerflix server
    # - wait for stream to become ready
    # - pass stream url to Player instance

  grid.on "out_of_bounds", (data) ->
    switch data.direction
      # when "up"
      # when "down"
      when "left"
        do grid.releaseFocus
        do menu.giveFocus
      # when "right"
