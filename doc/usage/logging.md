# Logging

The jlua.logging module implements a hierarchical logger. For those used to
python it should look familiar.

## Log messages

To log message, get a logger. Then log messages. Easy :

```lua
local logging = require("jlua.logging")

local logger = logging.get_logger(_REQUIREDNAME)
logger:log("I want to break {}", "free")
```

For more details on this method, check the
[api reference](/api/logging/#get_/log).
