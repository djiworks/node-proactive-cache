// Generated by CoffeeScript 1.8.0
(function() {
  var ProactiveCache, clone, _;

  _ = require('underscore');

  clone = require('clone');

  ProactiveCache = (function() {
    function ProactiveCache(options) {
      if (options == null) {
        options = {};
      }
      options = _.extend({
        useClones: true,
        expirationDelay: 60000,
        renewExpiration: true,
        dispose: function(key, value) {}
      }, options);
      this._cache = {};
      this._expirationDelay = options.expirationDelay;
      this._dispose = options.dispose;
      this._renewExpiration = options.renewExpiration;
      this._useClones = options.useClones;
      this._itemCount = 0;
    }

    ProactiveCache.prototype.reset = function() {
      var self;
      self = this;
      _.each(this._cache, function(item, key) {
        return self._clearTimer(item, 'reset');
      });
      this._cache = {};
      return this._itemCount = 0;
    };

    ProactiveCache.prototype._addTimer = function(item, delay, useExisting) {
      var self;
      self = this;
      if (!useExisting) {
        item.delay = delay;
      } else {
        item.delay = item.delay || delay;
      }
      return item.timer = setTimeout(function() {
        self.del(item.key);
        return self._dispose(item.key, item.value);
      }, item.delay);
    };

    ProactiveCache.prototype._clearTimer = function(item) {
      return clearTimeout(item.timer);
    };

    ProactiveCache.prototype.set = function(key, value, expirationDelay) {
      var item, usedValue;
      expirationDelay = expirationDelay || this._expirationDelay;
      if (this._useClones && _.isObject(value)) {
        usedValue = clone(value);
      } else {
        usedValue = value;
      }
      if (this.has(key)) {
        item = this._cache[key];
        item.value = usedValue;
        this._cache[key] = item;
        if (this._renewExpiration) {
          this._clearTimer(item);
          this._addTimer(item, expirationDelay, false);
        }
      } else {
        item = {
          key: key,
          value: usedValue
        };
        this._cache[key] = item;
        this._itemCount++;
        this._addTimer(item, expirationDelay, false);
      }
      return true;
    };

    ProactiveCache.prototype.get = function(key) {
      var item;
      item = this._cache[key];
      if ((item != null) && this._renewExpiration) {
        this._clearTimer(item);
        this._addTimer(item, this._expirationDelay, true);
      }
      return (item != null ? item.value : void 0) || null;
    };

    ProactiveCache.prototype.peek = function(key) {
      var _ref;
      return ((_ref = this._cache[key]) != null ? _ref.value : void 0) || null;
    };

    ProactiveCache.prototype.mget = function(keys) {
      var results, self;
      self = this;
      if (!_.isArray(keys)) {
        throw new Error('Bad arguments. Waiting for Array type');
      }
      results = {};
      _.each(keys, function(key) {
        return results[key] = self.get(key);
      });
      return results;
    };

    ProactiveCache.prototype.del = function(key) {
      var item;
      if (this.has(key)) {
        item = this._cache[key];
        this._clearTimer(item);
        this._itemCount--;
        return delete this._cache[key];
      }
    };

    ProactiveCache.prototype.mdel = function(keys) {
      var self;
      self = this;
      if (!_.isArray(keys)) {
        throw new Error('Bad arguments. Waiting for Array type');
      }
      return _.each(keys, function(key) {
        return self.del(key);
      });
    };

    ProactiveCache.prototype.keys = function() {
      return _.keys(this._cache);
    };

    ProactiveCache.prototype.has = function(key) {
      return _.has(this._cache, key);
    };

    ProactiveCache.prototype.values = function() {
      return _.chain(this._cache).values().map(function(item) {
        return item.value;
      }).value();
    };

    ProactiveCache.prototype.itemCount = function() {
      return this._itemCount;
    };

    return ProactiveCache;

  })();

  module.exports = ProactiveCache;

}).call(this);
