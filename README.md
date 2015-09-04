# Simple NodeJs internal caching
A simple in memory key/value cache with proactive cleaning. Actually, the cache is based on a single object.
Each item of the cache has their own timer to avoid setInterval on an empty cache.

## Usage:
```coffee
#TODO
```

## Options
* `useClones` *(default: `true`)*: Enable or disable cloning on variables. If `true`, all items will be deeply cloned before storing in the cache. Otherwise, only the reference will be saved.
* `expirationDelay` *(default: `60000`)*: Delay in ms before removing the item from the cache.
* `renewExpiration` *(default: `true`)*: Enable or disable the renewal of the delay when getting or storing an item
* `dispose(key, value)`: Function called when an item expired. This function will be synchronious

## API
TODO
