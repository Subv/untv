###
UNTV - file-selector
Author: Gordon Hall

Accepts a starting path and creates a NavigableList
instance that allows for traversing the file system
###

fs             = require "fs"
path           = require "path"
jade           = require "jade"
NavigableList  = require "./navigable-list"
$              = require "../../vendor/jquer-2.0.3"
{EventEmitter} = require "events"

class FileSelector extends EventEmitter
  constructor: (@container, @remote, @ignore_types) ->
    ###
    ignore_types is an array or file extensions like ".txt"
    passing an empty string as an item will ignore all files
    and only honor directories
    ###
    home_env      = if process.platform is "win32" then "USERPROFILE" else "HOME"
    @home_dir     = process.env[home_env]
    @current_path = @home_dir
    @parent_dir   = path.join @current_path, "../"
    do @update

  # call this when selecting a directory item
  update: (@current_path = @current_path) =>
    @current_tree = fs.readdirSync @current_path
    @parent_dir   = path.join @current_path, "../"
    # add parent as item to current tree
    @current_tree.unshift @parent_dir
    # stat all the contents
    @current_tree = @current_tree.map (file) =>
      if (path.extname file) in @ignore_types then no
      else data = 
        path: "#{@current_path}/#{file}"
        name: file
        stats: fs.statSync "#{@current_path}/#{file}"
    # emit an event alerting listeners that we have file contents
    @emit "tree_loaded", files: @current_tree
    # render the instance
    do @render

  # draw interface
  render: =>
    ($ @container).html @template @current_tree
    # configure list
    selector_config = 
      adjust_y: 0
      adjust_x: details_view.width()
      smart_scroll: yes 
      leave_decoration: yes
    # create selector instance
    @selector = new NavigableList ($ "ul", @container), @remote, selector_config
    @selector.giveFocus 1
    do @subscribe
  
  # compiles view template
  template: (data) =>
    @template_file ?= fs.readFileSync "#{__dirname}/../../views/file-selector.jade"
    template        = jade.compile file.toString()
    # return compiled template
    template files: data or @current_tree

  # set up events
  subscribe: =>
    # subscribe to events from NavigableList instance
    if not @selector then throw """
      Cannot subscribe to NavigableList, because it has not yet been instantiated
    """
    # when a directory is selected, open that directory
    # repopulating the file selector list and emitting 
    # another `tree_loaded` event
    @selector.on "item_selected", (item) =>
      item_type = item.attr "data-type"
      item_path = item.attr "data-path"
      # if it's a directory, set the current path and update
      if item_type is "directory" then @update item_path
      # otherwise, notify listeners of the file selected
      else if item_type is "file" then @emit "file_selected", path: item_path
      else throw "'#{item_type}' is not a valid parameter"

module.exports = FileSelector
