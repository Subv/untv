###
UNTV - video-library extension
Author: Gordon Hall

Enables user to browse their local hard disk or attached
devices or mounted disks for videos and play them
###

ffmpeg = require "fluent-ffmpeg"
fs     = require "fs"
jade   = require "jade"

module.exports = (manifest, remote, player, notifier, view, gui) ->

  ###
  Load FileSelector
  ###
  selector_container = (gui.$ "#files", view)
  file_selector      = new gui.FileSelector selector_container, remote, ["*"]

  ###
  Load Movie Grid
  ###
  movie_grid_config = 
    adjust_y: 0
    adjust_x: 0
    smart_scroll: yes 
    smart_rows: yes
  grid_container = (gui.$ "#movie_files")
  grid_view_raw  = fs.readFileSync "#{__dirname}/views/movie-files.jade"
  grid_template  = jade.compile grid_view_raw.toString()
  # create new movie_list
  movie_grid = new gui.NavigableGrid grid_container, remote, movie_grid_config

  # when navigating out of bounds left from movie grid, focus on the
  # file selector
  movie_grid.on "out_of_bounds", (data) ->
    switch data.direction
      when "left"
        do movie_grid.releaseFocus
        do file_selector.selector.giveFocus 1

  # when a directory is opened, we should load up the videos
  # in another NavigableList, and use ffmpeg to generate thumbs
  file_selector.on "dir_selected", (data) ->
    dir_path = data.path
    # load movie list
    list_data = []
    # compile template and replace container contents
    movie_grid.populate list_data, grid_template
    
  # when navigating right, switch focus to the movie grid
  file_selector.on "out_of_bounds", (data) ->
    switch data.direction
      when "right"
        do file_selector.selector.releaseFocus
        do movie_list?.giveFocus
