###
UNTV - tv-shows-rss extension
Author: Gordon Hall

Enables user to browse tv shows using rss and using
magnet link to torrent episodes
###


###
Initialize Extension 
###
module.exports = (env) ->

  
ShowFeed = require "./show-feed"
feed     = new ShowFeed() 

feed.on "ready", ->
  # got all shows!

  # now get available episodes for portlandia!
  feed.getFeed "329", (err, episodes) ->
    console.log err or episodes
