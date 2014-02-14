###
UNTV - menu-actions.coffee
Author: Gordon Hall

Non-extension actions to add to global menu
###

module.exports = [

  # Quits UNTV
  {
    name: "Quit"
    icon: "assets/images/icons/quit.svg"
    list_priority: 9999
    description: "Close and Return to Operating System"
    handler: ->
      win = global.window.nwDispatcher.requireNwGui()?.Window.get()
      win?.close()
  }

]
