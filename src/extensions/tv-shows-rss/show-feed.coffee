###
UNTV - show-feed class
Author: Gordon Hall
###

{EventEmitter} = require "events"
FeedParser     = require "feedparser"
request        = require "request"
cheerio        = require "cheerio"

class ShowFeed extends EventEmitter
  constructor: (showId) ->
    @shows = []
    @getShows()

  getFeed: (showId, callback) =>
    show = @getShowById showId
    self = this

    if show.episodes then return callback null, show.episodes

    show.feed     = request "http://showrss.info/feeds/#{show.id}.rss"
    show.parser   = new FeedParser()
    show.episodes = []

    show.feed.on "response", (res) ->
      stream = this
      if res.statusCode isnt 200
        return self.emit "error", new Error "Bad status code"
      stream.pipe show.parser

    show.parser.on "error", (error) -> callback error

    show.parser.on "readable", ->
      stream = this
      meta   = @meta

      while item = do stream.read
        show.episodes.push self.parse item 
        
    show.parser.on "end", ->
      callback null, show.episodes

  parse: (item) =>
    data = {} 
    parts        = item.title.split /([0-9]*x[0-9]*)/
    data.title   = item['showrss:showname']['#']
    data.season  = parts[1]?.split("x")[0]
    data.episode = 
      title: parts[2]?.split("720p")[0].trim()
      number: parts[1]?.split("x")[1]
    data.link    = item.link
    data.id      = item['showrss:showid']['#']
    data.date    = new Date item.pubdate
    return data

  getShowById: (showId) =>
    for show in @shows
      if show.id is showId then return show
    return null

  getShows: =>
    request "http://showrss.info/?cs=browse", (err, data) =>
      $    = cheerio.load(data.body);
      self = this

      ($ "#browse_show option").each ->
        self.shows.push 
          id: ($ this).val()
          title: ($ this).html()
      
      @emit "ready", @shows


module.exports = ShowFeed
