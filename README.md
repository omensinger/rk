# rk
Ruby helper to generate keys for Redis, based on an idea by [@stockholmux](https://twitter.com/stockholmux) and [this implementation for Node.js](https://github.com/FGRibreau/rk).

Use this library to avoid typos when building Redis keys!

# Installation
```
gem install rk
```

# Usage
## Simple
Just use ```rk``` to build a key with the default separator ```:``` (colon).

```
require "redis"
require "rk"

redis = Redis.new

userid = 10
redis.set(rk("user", userid), "John Doe") # key is "user:10"
```

## Advanced
Use a prefix and/or suffix for keys.

```
require "redis"
require "rk"

redis = Redis.new

rk.prefix = "myapp"
rk.suffix = "test"

userid = 10
redis.set(rk("user", userid), "John Doe") # key is "myapp:user:10:test"
```

## Even more advanced
Define key elements with ```rk``` and avoid typos even in key names!

```
require "redis"
require "rk"

redis = Redis.new

rk.prefix = "myapp"
rk.suffix = "test"
rk.user = "user"

userid = 10
redis.set(rk(rk.user, userid), "John Doe") # key is "myapp:user:10:test"
```

This is what happens if you access a self defined key that does not exist (on typo):
```
require "redis"
require "rk"

redis = Redis.new

rk.stats = "stats"

redis.incr(rk(rk.stat, 1)) # typo here, accessing 'stat' instead of 'stats'
=> RuntimeError: 'rk.stat' is undefined
```

# Options
You may want to use these options:
|Option|Default value|Example|
|-|-|-|
|prefix|```""``` (empty)|```rk.prefix = "myapp"```|
|suffix|```""``` (empty)|```rk.suffix = "test"```|
|separator|```:```|```rk.separator = "|"``` (uses pipe as separator for parts of the key)|
|any other|```""``` (empty)|```rk.user = "user"``` or ```rk.status = "stat"```|

