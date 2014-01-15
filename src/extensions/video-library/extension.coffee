###
UNTV - video-library extension
Author: Gordon Hall

Enables user to browse their local hard disk or attached
devices or mounted disks for videos and play them
###

ffmpeg    = require "fluent-ffmpeg"
{MetaLib} = ffmpeg
fs        = require "fs"
jade      = require "jade"
async     = require "async"

module.exports = (manifest, remote, player, notifier, view, gui) ->

  ###
  Supported File Type
  ###
  supported_types = [
    ".mp4"
    ".m4v"
    ".mov"
    ".mkv"
    ".avi"
    ".webm"
  ]

  ###
  Movie File Data Retrieval
  ###
  getMovieData = (movie, done) ->
    # get metadata
    meta = new MetaLib movie.path, (data, err) ->
      if err then return done err
      movie.metadata = data
      # generate thumbnail
      proc = new ffmpeg source: movie.path
      proc.withSize "150x100"
      proc.takeScreenshots
        count: 3
        timemarks: ["0.25", "0.5", "0.75"]
      , os.tmpdir(), (err, filenames) ->
        if err then return done err
        movie.screenshots = filenames
        done null, movie

  ###
  Load FileSelector
  ###
  selector_container = (gui.$ "#files", view)
  file_selector      = new gui.FileSelector selector_container, remote, ["*"]

  # when a directory is opened, we should load up the videos
  # in another NavigableList, and use ffmpeg to generate thumbs
  file_selector.on "dir_selected", (data) ->
    dir_path = data.path
    # load movie list and get it's metadata
    contents = fs.readdirSync dir_path
    # filter by supported types
    movies   = contents.filter (mov) -> path.extname file in supported_types
    # transform movie data to get more info
    movies.map (movie) ->
      stats: fs.statSync movie
      name: path.basename movie
      path: movie

    # now build an async map to add screenshots and metadata, before passing to
    # the movie grid's populate template
    async.map movies, getMovieData, (err, list_data) ->
      if err then return err
      # compile template and replace container contents
      movie_grid.populate list_data, grid_template
    
  # when navigating right, switch focus to the movie grid
  file_selector.on "out_of_bounds", (data) ->
    switch data.direction
      when "right"
        do file_selector.selector.releaseFocus
        do movie_list?.giveFocus

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

  # when selecting a movie file, go ahead and load it and pass it's 
  # absolute path to the player instance
  movie_grid.on "item_selected", (item) ->
    movie_file_path = item.attr "data-movie-path"
    player.play movie_file_path, "video"

  # when navigating out of bounds left from movie grid, focus on the
  # file selector
  movie_grid.on "out_of_bounds", (data) ->
    switch data.direction
      when "left"
        do movie_grid.releaseFocus
        do file_selector.selector.giveFocus 1
