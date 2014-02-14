Extensions
==========

This directory contains the core set of bundled extensions for UNTV. These 6 
extensions provide the functionality supported by the UNTV core team. The 
extensions are outlined below.

## Instant Streaming

The Instant Streaming extension enables users to search and browse movies that 
have been added to the [Yify Torrents](http://yify-torrents.com) website. The 
content is delivered via BitTorrent and streamed to the global `Player` for 
viewing.

## Video Library

The Video Library extension enables users to watch videos on their hard drive 
or connected devices. The extension provides access to the file system so that 
users can store their media however they please. Thumbnails are generated via 
FFMPEG, so the user must have FFMPEG installed on their system to take 
advantage of this feature.

## Music Player

> This extension was removed from the bundled scope, but is being developed as a third-party extension found [here](https://github.com/gordonwritescode/untv-music-player).

The Music Player extension enables the user to play music stored on their hard 
drive or connected device. They may also create custom playlists. Cover art is 
shown using the `musicmetadata` module as well as artist and album information 
if it is available. The user selects a directory to use as their music library 
so it may be indexed upon first use and may change this via the Settings 
extension at any time.

## Photo Gallery

The Photo Gallery extension provides a simple way to to view photos stored on 
the user's local disk or connected device. Full filesystem access is given to 
the user and directories are loaded upon selection and photos are organized in 
a pleasant cover-flow style interface.

## Extension Manager

The Extension Manager extension allows users to search and browse third party 
extensions, install or remove them, and keep them up to date.

## Settings & Preferences

All extensions that hook into the Settings API can have their configuration 
modified from this extension. Also provides global system configuration like 
network connections, etc.
