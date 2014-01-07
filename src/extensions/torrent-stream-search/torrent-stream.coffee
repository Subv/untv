###
UNTV - torrent-stream class
Author: Gordon Hall
###

url            = require "url"
fs             = require "fs"
{EventEmitter} = require "events"
request        = require "request"
os             = require "os"
nt             = require "nt"
peerflix       = require "peerflix"
path           = require "path"

class TorrentStream extends EventEmitter
  constructor: (@torrent_location) ->
    # torrent_location may be a url to download
    # or it may be a local file path from which to read
    switch @determineType()
      when "remote" then do @download
      when "local" then do @read

  determineType: =>
    if (url.parse @torrent_location).host? then "remote" else "local"

  download: =>
    tmp_dir      = os.tmpDir()
    filename     = path.basename (url.parse @torrent_location).path
    @target_path = "#{tmp_dir}/#{filename}"
    download     = request @torrent_location
    file_target  = fs.createWriteStream @target_path
    # when ready, read from disk
    file_target.on "finish", => do @read
    # handle any errors
    download.on "error", (err) => @emit "error", err
    file_target.on "error", (err) => @emit "error", err
    # download the file
    download.pipe file_target

  read: =>
    nt.read @target_path, (err, torrent) =>
      if err then @emit "error", err
      else @emit "ready", 
        info: torrent.infoHash()
        metadata: torrent.metadata

  stream: =>
    peerflix @target_path, @options, (err) => 
      if err then @emit "error", err
      else
        @emit "stream", stream_url: "http://localhost:#{@options.port}"

  options:
    port: 8888

module.exports = TorrentStream
