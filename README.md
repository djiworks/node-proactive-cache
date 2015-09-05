# Simple NodeJs internal caching
A simple in memory key/value cache with proactive cleaning. Actually, the cache is based on a single object (so the cache size limit depends on max size of a single object).
Each item of the cache has their own timer to avoid setInterval on an empty cache.

## Usage:
```javascript
var Cache = require("cache"); // To rename
var options = {
    expirationDelay: 5000, //ms
    dispose: function (key, value) { console.log('key:', key, 'value:', value); }
};
var myCache = new Cache(options);
cache.set('key', 'value');
cache.get("key");

```

## Options

* `useClones` *(default: `true`)*: Enable or disable cloning on variables. If `true`, all items will be deeply cloned before storing in the cache. Otherwise, only the reference will be saved.
* `expirationDelay` *(default: `60000`)*: Delay in ms before removing the item from the cache.
* `renewExpiration` *(default: `true`)*: Enable or disable the renewal of the delay when getting or storing an item
* `dispose(key, value)`: Function called when an item expired. This function will be synchronious

## API

* `set(key, value, [delay])` *(optional: `delay`)*
    
    Add or update an item in the cache. 
    Delay allow you to overwrite the global `expirationDelay` on a specific item.
    If it's an update, the expiration delay of this item will be renew.

* `get(key)`
    
    Returns the key value (or `null` if not found) renewing the expiration delay.

* `mget(keys)`

    Returns an object with keys as properties `{'key1': 'value1', 'key2': 'value2'}`
    (or an empty object `{}` if no keys found). For each key, the expiration delay will be renew.

* `peek(key)`
    
    Returns the key value (or `null` if not found) without renewal on expiration delay.

* `del(key)`

    Deletes a key out of the cache.

* `mdel(keys)`
  
    Deletes keys out of the cache.

* `reset()`

    Clears the cache entirely, throwing away all values and clearing all item timers 
    without calling dispose function.

* `has(key)`

    Checks if a key is in the cache, without renewing expiration delay.

* `keys()`

    Returns an array of the keys in the cache.

* `values()`

    Returns an array of the values in the cache.

* `itemCount()`

    Returns total quantity of objects currently in cache.

## Licence

The MIT License (MIT)

Copyright (c) 2015 Djothi Grondin

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
