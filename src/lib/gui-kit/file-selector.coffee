###
UNTV - file-selector
Author: Gordon Hall

Accepts a starting path and creates a NavigableList
instance that allows for traversing the file system
###

fs            = require "fs"
path          = require "path"
jade          = require "jade"
NavigableList = require "./navigable-list"
$             = require "../../vendor/jquer-2.0.3"

class FileSelector
  constructor: (@container, @remote, @ignore_types, starting_path) ->
    home_env      = if process.platform is "win32" then "USERPROFILE" else "HOME"
    @home_dir     = process.env[home_env]
    @current_path = starting_path or home_dir
    @parent_dir   = path.join @current_path, "../"
    @current_tree = fs.readdirSync @current_path
    # add parent as item to current tree
    @current_tree.unshift @parent_dir
    # stat all the contents
    @current_tree = @current_tree.map (file) =>
      if (path.extname file) in @ignore_types then no
      else data = 
        path: "#{@current_path}/#{file}"
        name: file
        stats: fs.statSync "#{@current_path}/#{file}"
    # render the instance
    do @render

  render: =>
    ($ @container).html @compileTemplate @current_tree
    # configure list
    selector_config = 
      adjust_y: 0
      adjust_x: details_view.width()
      smart_scroll: yes 
      leave_decoration: yes
    # create selector instance
    @selector = new NavigableList ($ "ul", @container), remote, selector_config
    @selector.giveFocus 1
  
  compileTemplate: =>
    file     = fs.readFileSync "#{__dirname}/../../views/file-selector.jade"
    template = jade.compile file.toString()
    template files: @current_tree

module.exports = FileSelector
