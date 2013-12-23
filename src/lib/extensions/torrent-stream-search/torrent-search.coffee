###
UNTV - torrent-search class
Author: Gordon Hall
###

request = require "request"
jade    = require "jade"
fs      = require "fs"
qs      = require "querystring"

class TorrentSearch
  constructor: ->
    @history = []

  base_url: "http://yify-torrents.com/api/"
  data_type: "json"

  templates:
    upcoming: fs.readFileSync "#{__dirname}/views/upcoming-list.jade"
    list: fs.readFileSync "#{__dirname}/views/results-list.jade"

  upcoming: (callback) =>
    request "#{@base_url}upcoming.#{@data_type}", (err, response, body) =>
      if response.statusCode isnt 200 then return @error()
      data = results: JSON.parse body
      view = jade.compile @templates.upcoming
      if typeof callback is "function" then callback view data

  list: (data, callback) =>
    query = qs.stringify data or {}
    request "#{@base_url}list.#{@data_type}?#{query}", (err, response, body) =>
      data = JSON.parse body
      view = jade.compile @templates.list
      if typeof callback is "function" then callback view data

  # latest should get us the default sort 
  latest: (callback) => @list null, callback


  error: =>

module.exports = TorrentSearch
