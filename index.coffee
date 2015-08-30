_ = require 'underscore'
clone = require 'clone'


class ExpirationCache
  constructor: (options = {}) ->
    options = _.extend
      useClones: true # Store only cloned items
      maxAge: 60000 # Delay to make item as expired
      renewExpiration: true # Clear expiration on item if true

      # Default function to compute cache length
      length: ->
        return 1

      # Function to call when item expired
      dispose: (key, value) ->
        # Do nothing

    , options

    @_cache = {} # Store entries
    @_lengthComputer = options.length # Function to compute cache length
    @_maxAge = options.maxAge
    @_dispose = options.dispose
    
    @_length = 0
    @_itemCount = 0

    @reset()

  set: (key, value, maxAge) ->

  get: (key) ->

  # Does NOT renew expiration timeout
  peek: (key) ->
    console.log "gurehugioheroiguerh"
    
  mget: ->


  del: ->
  mdel: ->

  keys: ->
    return _.keys @_cache

  reset: ->

  has: (key) ->
    return _.has @_cache, key

  values: ->
    return _.values @_cache

  itemCount: ->
  length: ->

module.exports = ExpirationCache