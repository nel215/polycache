# PolyCache [![Build Status](https://travis-ci.org/muddydixon/polycache.svg?branch=master)](https://travis-ci.org/muddydixon/polycache)

Library for cache multi drivers.

## Install

```bash
npm install polycache
```

## Usage

```coffeescript
PolyCache = require "polycache"

# PolyCache uses memory driver by default
# and if configuration exists, uses each driver
cache = new PolyCache

# use memory driver
cache.set("largeCsv:2014-06-01:2014-06-14", bigValue) # to memory
.then(->
  cache.get("largeCsv:2014-06-01:2014-06-14") # from memory
)
.then(->
  cahce.end()
)
```

## Driver Rules

Use memory for the keys frequently used and the values that size are small,
use redis or memcached for the keys used for multi hosts and
use file for large value size.

```coffeescript
PolyCache = require "polycache"

cache = new PolyCache
  file:
    dir: "/tmp"
  redis:
    host: "localhost"
    port: 6379

cache.addRule PolyCache.File, {key: /largeCsv/}
cache.addRule PolyCache.File, {val: {gt: 1024 * 1024}}
cache.addRule PolyCache.Redis, {key: "sharedSetting"}
# and if any rules do not match, use memory driver

cache.set("largeCsv:2014-06-01:2014-06-14", bigValue) # to file
.then(->
  cache.get("largeCsv:2014-06-01:2014-06-14") # from file
)
.then(->
  cahce.end()
)
```

## Author

Muddy Dixon <muddydixon@gmail.com>

## License

Apache License Version 2.0
