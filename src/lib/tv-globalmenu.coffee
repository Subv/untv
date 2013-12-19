###
UNTV - tv-globalmenu.coffee
Author: Gordon Hall

Injects the global menu interface and subscribes to events from
the remote control bus
###

$              = require "../vendor/jquery-2.0.3.js"
{EventEmitter} = require "events"
jade           = require "jade"
fs             = require "fs"
extend         = require "node.extend"
path           = require "path"

class GlobalMenu extends EventEmitter

  constructor: (@container, @remote, @player) ->
    @extensions = []
    @visible    = no
    # subscribe to remote events
    @remote.on "menu:open", @open
    @remote.on "menu:close", @close
    @remote.on "go:next", @select
    @remote.on "scroll:up", @focusPrev
    @remote.on "scroll:down", @focusNext

  render: =>
    view_path = "#{__dirname}/../views/globalmenu.jade"
    compiled  = jade.compile fs.readFileSync view_path
    html      = compiled items: @extensions
    @container.html? html
    ($ "li:first-of-type", @container).addClass "has-focus"

  addExtension: (path, manifest) =>
    # check manifest's main file here and store reference to it
    extension        = extend yes, {}, manifest
    extension.path   = path
    init_script_path = "#{path}/#{extension.main}"
    if fs.existsSync init_script_path
      ext_init       = require init_script_path
      extension.main = ext_init
      view_raw       = fs.readFileSync "#{path}/#{extension.view}"
      extension.view = jade.compile view_raw.toString()

    @extensions.push extension if manifest and manifest.name
    do @render

  open: =>
    @container.removeClass "#{@menu_animation_out_classname}" if not @visible
    @container.addClass "visible #{@menu_animation_in_classname}" if not @visible
    @visible = yes

  close: =>
    @container.removeClass "#{@menu_animation_in_classname}" if @visible
    @container.addClass "#{@menu_animation_out_classname}" if @visible
    @visible = no

  focusNext: =>
    next_item = @current().next()
    if next_item.length and @visible
      @current().removeClass "has-focus #{@item_animation_classname}"
      next_item.addClass "has-focus #{@item_animation_classname}"

  focusPrev: =>
    previous_item = @current().prev()
    if previous_item.length and @visible
      @current().removeClass "has-focus #{@item_animation_classname}"
      previous_item.addClass "has-focus #{@item_animation_classname}"

  select: =>
    if not @visible then return
    index     = @current().index "li", @container
    extension = @extensions[index]
    # inject view
    @extension_container().html extension.view()
    # remove previous extension stylesheets
    do ($ "link[data-type='extension'][rel='stylesheet']").remove
    # inject new stylesheets for selected extension
    stylesheets = extension.stylesheets or []
    stylesheets.forEach (path) ->
      stylesheet_path  = "#{extension.path}/#{path}"
      stylesheet_type = (path.extname stylesheet_path).substr 1
      link            = ($ "<link/>")

      link.attr "rel", "stylesheet"
      link.attr "type", "text/#{stylesheet_type}"
      link.attr "href", stylesheet_path
      link.data "type", "extension"
      
      ($ "head").append link
    # call init script and close menu
    @extension_container().html @extensions[index].view
    @extensions[index].main extension, @remote, @player, @extension_container()
    do @close

  current: => $ "li.has-focus", @container

  item_animation_classname: "pulse"
  menu_animation_in_classname: "slideInLeft"
  menu_animation_out_classname: "slideOutLeft"
  extension_container: => $ "#extensions-container"

module.exports = GlobalMenu
