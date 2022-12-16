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

!!! info

	Every time you call [get_logger](/api/logging/#get_logger) with the same
	name, the same instance of the logger is returned. It means that if you
	registered handlers or filters in this logger before, they will be
	in the instance you get, too.

