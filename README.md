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
rk.separator = "-"

userid = 10
redis.set(rk("user", userid), "John Doe") # key is "myapp-user-10-test"
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

Use ```rk.keys``` to assign multiple keys with a hash (for example loaded from a configuration file):
```
require "redis"
require "rk"

redis = Redis.new

rk.keys = { user: "user", "statistics" => "stats", "session" => :sess }

rk.user # => "user"
rk.statistics # => "stats"
rk.session # => "sess"

userid = 10
redis.set(rk(rk.session, 10), "a3nc4E1f") # key is "sess:10"

```

# Options
You may want to use these options (methods):

|Method|Default value|Example|
|---|---|---|
|`prefix` or `prefix=`|`""` (empty)|`rk.prefix => ""` or `rk.prefix = "myapp"`|
|`suffix` or `suffix=`|`""` (empty)|`rk.suffix => ""` or `rk.suffix = "test"`|
|`separator` or `separator=`|`:`|`rk.separator => ":"` or `rk.separator = "-"` (use minus as separator for parts of the key)|
|`keys` or `keys=`|`[]` (empty)|`rk.keys = { user: "user", group: "grp" }; rk.user => "usr"` and `rk.group => grp` and `rk.keys => { "user" => "usr", "group" => "grp" }`|
|any other|RuntimeError (if undefined)|`rk.user = "user"; rk.user => "user"` or `rk.something => RuntimeError: 'rk.something' is undefined`|

