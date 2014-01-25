###
UNTV - photo-slideshow extension
Author: Gordon Hall

Enables user to view and scroll through directory of photos
from their local disk or mounted drives
###

path         = require "path"
fs           = require "fs"
jade         = require "jade"
localStorage = window.localStorage

module.exports = (manifest, remote, player, notifier, view, gui) ->
  
  conf           = manifest.config
  selector_view  = (gui.$ "#files", view)
  grid_view      = (gui.$ "#photos", view)
  header         = (gui.$ "header", view)

  supported_types = [
    ".jpg"
    ".jpeg"
    ".png"
    ".gif"
    ".bmp"
  ]

  ###
  Load FileSelector
  ###
  file_config =
    adjust_y: 0
    adjust_x: grid_view.width()
    # enables scroll to top/bottom when scrolling past bottom/top
    smart_scroll: yes 
    # leaves the selection class on focus removal
    leave_decoration: yes
    # set initial path to last one
    initial_path: localStorage.getItem "photos:last_directory"
  file_selector = new gui.FileSelector selector_view, remote, ["*"], file_config

  # when a directory is opened, we should load up the videos
  # in another NavigableList, and use ffmpeg to generate thumbs
  file_selector.on "dir_selected", (data) ->
    # remember path
    localStorage.setItem "photos:last_directory", data.path
    # get photos from directory
    dir_path = data.path
    # load photo list
    contents = fs.readdirSync dir_path
    # filter by supported types
    photos   = contents.filter (pic) -> (path.extname pic) in supported_types
    # create a data object for the photos
    photos   = photos.map (pic) -> path: "#{dir_path}/#{pic}"
    # populate photo grid
    photo_grid.populate photos or [], grid_template

  # when navigating right, switch focus to the movie grid
  file_selector.on "out_of_bounds", (data) ->
    switch data.direction
      when "right"
        do file_selector.selector.releaseFocus
        do photo_grid?.giveFocus

  ###
  Load Photo Grid
  ###
  photo_grid_config = 
    adjust_y: header.outerHeight()
    adjust_x: selector_view.width()
    smart_scroll: no 
    smart_rows: no
  grid_view_raw  = fs.readFileSync "#{__dirname}/views/photos.jade"
  grid_template  = jade.compile grid_view_raw.toString()
  # create new movie_list
  photo_grid = new gui.NavigableGrid grid_view, remote, photo_grid_config

  # if we empty the grid by populating with no photos, then show an
  # appropriate message in the container
  photo_grid.on "emptied", (container) ->
    view = fs.readFileSync "#{__dirname}/views/no-photos.jade"
    container.html do jade.compile view

  photo_grid.on "item_focused", (item) ->
    source = (gui.$ "img", item).attr "src"
    grid_view.css "background-image", "url('#{source}')"

  # when navigating out of bounds left from photo grid, focus on the
  # file selector
  photo_grid.on "out_of_bounds", (data) ->
    switch data.direction
      when "left"
        do photo_grid.releaseFocus
        file_selector.selector.giveFocus 1

  # when the extension loads, go ahead and load the current directory movies
  file_selector.emit "dir_selected", 
    path: file_selector.current_path
