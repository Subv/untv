###
UNTV - settings extension
Author: Gordon Hall

Enables user to configure settings API
###

jade = require "jade"
fs   = require "fs"

module.exports = (env) ->
  
  $               = env.gui.$
  settings        = env.settings_registry.settings
  {NavigableList} = env.gui
  header          = $ "header", env.view

  console.log settings

  ###
  Get Settings List Template and Populate
  ###
  settings_tmpl = fs.readFileSync "#{__dirname}/views/settings-list.jade"
  settings_view = jade.compile settings_tmpl
  settings_cont = $ "#settings-container ul"
  # render inside container
  settings_cont.html settings_view extensions: settings

  ###
  Initialize Navigable List
  ###
  list_config = 
    adjust_y: header.outerHeight()
    smart_scroll: yes 
    leave_decoration: yes
  settings_menu = new NavigableList settings_cont, env.remote, list_config
  # auto give list focus
  settings_menu.giveFocus()

  ###
  Setup Event Handlers
  ###
  settings_menu.on "item_selected", (item) ->
    type      = item.attr "data-type"
    index     = item.attr "data-index"
    key       = item.attr "data-key"
    extension = settings[index]
    setting   = extension.config[key]

    # play sound
    env.remote.playEventSound "keypress"

    # filter action based on type
    switch type
      when "toggle"
        setting.toggle()
        ($ ".setting-toggle", item).attr "data-value", setting.value
      when "text"
        console.log type
      when "options"
        console.log type
