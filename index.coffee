_ = require 'underscore'
clone = require 'clone'


class ExpirationCache
  constructor: (options = {}) ->
    options = _.extend
      useClones: true # Store only cloned items
      expirationDelay: 60000 # Delay to make item as expired (ms)
      renewExpiration: true # Clear expiration on item if true

      ###
      # Default function to compute cache length
      length: ->
        return 1
      ###

      # Function to call when item expired
      # This is sync method
      dispose: (key, value) ->
        # Do nothing

    , options

    @_cache = {} # Store entries
    # @_lengthComputer = options.length # Function to compute cache length
    @_expirationDelay = options.expirationDelay
    @_dispose = options.dispose

    @_renewExpiration = options.renewExpiration
    @_useClones = options.useClones
    
    # @_length = 0
    @_itemCount = 0


  reset: ->
    self = this
    _.each @_cache, (value, key) ->
      self._dispose(key, self._cache[key].value)

    @_cache = {}
    # @_length = 0
    @_itemCount = 0


  # useExisting allows to keep the previous delay used on item
  _addTimer: (item, delay, useExisting) ->
    self = this

    if not useExisting
      item.delay = delay
    else
      item.delay = item.delay || delay
    
    item.timer = setTimeout ->
      self._dispose item.key, item.value
      self.del item.key
    , item.delay


  _clearTimer: (item) ->
    clearTimeout item.timer


  set: (key, value, expirationDelay) ->
    expirationDelay = expirationDelay || @_expirationDelay

    if @_useClones && _.isObject(value)
      usedValue = clone value
    else
      usedValue = value

    if @has(key)
      item = @get key
      item.value = usedValue
      @_cache[key] = item # Useful ? Actually, object is passed by ref
      
      # Is here the right place to do this ? It will be possible
      # that timer is called when set method is running
      if @_renewExpiration
        @_clearTimer item
        @_addTimer item, expirationDelay, false

    else
      item =
        key: key
        value: usedValue

      @_cache[key] = item
      @_itemCount++
      @_addTimer item, expirationDelay, false

    return true


  get: (key) ->
    item = @_cache[key]

    if item? && @_renewExpiration
      @_clearTimer item
      @_addTimer item, @_expirationDelay, true

    return item?.value || null


  # Does NOT renew expiration timeout
  peek: (key) ->
    return @_cache[key]?.value || null


  mget: (keys) ->
    self = this
    if not _.isArray(keys)
      throw new Error('Bad arguments. Waiting for Array type')

    results = {}
    _.each keys, (key) ->
      results[key] = self.get(key)

    return results

  del: (key) ->
    if @has(key)
      item = @get key
      @_clearTimer item
      @_itemCount--
      delete @_cache[key]


  mdel: (keys) ->
    self = this
    if not _.isArray(keys)
      throw new Error('Bad arguments. Waiting for Array type')

    _.each keys, (key) ->
      self.del key


  keys: ->
    return _.keys @_cache


  has: (key) ->
    return _.has @_cache, key


  values: ->
    return _.chain(@_cache)
            .values()
            .map (item) ->
              return item.value
            .value()


  itemCount: ->
    return @_itemCount


  ###
  length: ->
    return @_length
  ###

module.exports = ExpirationCache