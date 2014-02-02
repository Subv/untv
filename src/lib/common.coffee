###
UNTV - common.coffee
Author: Gordon Hall

Shared Methods between core classes
###

module.exports = 

  cacheRemoteListeners: ->
    cache = {}
    for event_type in @remote.events
      listeners = @remote.listeners event_type
      cache[event_type] = listeners if listeners.length
    @cached_remote_listeners = cache if (Object.keys cache).length

  rebindCachedListeners: ->
    if @cached_remote_listeners
      for event_type, listeners of @cached_remote_listeners
        for handler in listeners
          @remote.on event_type, handler
      @cached_remote_listeners = null
