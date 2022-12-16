--- Hierarchical logging facility.
---
--- This module is heavily inspired from Python's logging facility.
---
--- @module jlua.logging
local Object = require("jlua.object")
local List = require("jlua.list")
local Map = require("jlua.map")

local logging = {}

--- Logging level for messages & filters.
---
--- Can be used to set the level of a message when calling
--- jlua.logging.Logger.log. Message emmited can then be filtered by using this
--- enum.
---
--- @enum LOG_LEVEL
--- @field DEBUG     number Verbose diagnostics.
--- @field INFO      number Important informations to show to the user.
--- @field WARNING   number Handled errors.
--- @field ERROR     number Recoverable errors.
--- @field CRITICAL  number Failures.
logging.LOG_LEVEL = {
	DEBUG = 1,
	INFO = 2,
	WARNING = 3,
	ERROR = 4,
	CRITICAL = 5,
}

--- A logger, allowing to emit log message.
---
--- To create a new logger, use jlua.logging.get_logger, this class isn't meant
--- to be contsructed directly.
--- @class Logger
local Logger = Object:extend()

--- Add a log handler to this logger.
---
--- Add an handler to this logger. It will be called for every log record that
--- is emitted by this logger or one of it's child, and that passes the log
--- filters.
---
--- If a handler is added multiple times, it will be called multiple times when
--- a LogRecord is emitted.
---
--- @usage
--- logger = get_logger(_REQUIRED_NAME)
--- local function print_log(record)
--- 	print(format(record.format, record.args))
--- end
--- logger:add_handler(print_log)
---
--- @tparam function(LogRecord) -> nil The handler to add.
function Logger:add_handler(handler)
	self._handlers:push(handler)
end

--- Remove a previously added handle of this logger.
---
--- If the hanlder was added multiple times, remove only the first occurence.
---
--- @tparam function(LogRecord) -> nil The handler to remove.
function Logger:remove_handler(handler)
	self._handlers:remove(handler)
end

--- Emmit a log message on this handler.
---
--- Create a LogRecord from the given arguments, emit the LogRecord on parents
--- of this logger, and call the handlers registered on this logger if the
--- record passes the filter.
---
--- @usage
--- logger = get_logger(_REQUIRED_NAME)
--- ...
--- logger:log(LOG_LEVEL.ERROR, "An error occured")
---
--- @tparam jlua.logging.LOG_LEVEL log_level The log level of the log entry.
--- @tparam string                 fmt       The format string for the message
---                                          of the log entry.
--  @vararg any                              Format arguments.
function Logger:log(log_level, fmt, ...)
	local record = {
		logger = self._name,
		level = log_level,
		format = fmt,
		args = { ... },
	}
	self:handle(record)
end

--- Emmit a debug log message on this logger.
---
--- Will forward call to jlua.logging.Logger.log with level set to
--- LOG_LEVEL.DEBUG.
--
--- @tparam fmt       string    The format string for the message of the log
--                              entry.
--  @vararg any                 Format arguments.
function Logger:debug(fmt, ...)
	self:log(logging.LOG_LEVEL.DEBUG, fmt, ...)
end

--- Emmit an info log message on this logger.
---
--- Will forward call to jlua.logging.Logger.log with level set to
--- LOG_LEVEL.INFO.
--
--- @tparam fmt       string    The format string for the message of the log
--                              entry.
--  @vararg any                 Format arguments.
function Logger:info(fmt, ...)
	self:log(logging.LOG_LEVEL.INFO, fmt, ...)
end

--- Emmit a warning log message on this logger.
---
--- Will forward call to jlua.logging.Logger.log with level set to
--- LOG_LEVEL.WARNING.
--
--- @tparam fmt       string    The format string for the message of the log
--                              entry.
--  @vararg any                 Format arguments.
function Logger:warning(fmt, ...)
	self:log(logging.LOG_LEVEL.WARNING, fmt, ...)
end

--- Emmit an error log message on this logger.
---
--- Will forward call to jlua.logging.Logger.log with level set to
--- LOG_LEVEL.ERROR.
--
--- @tparam fmt       string    The format string for the message of the log
--                              entry.
--  @vararg any                 Format arguments.
function Logger:error(fmt, ...)
	self:log(logging.LOG_LEVEL.ERROR, fmt, ...)
end

--- Emmit a critical log message on this logger.
---
--- Will forward call to jlua.logging.Logger.log with level set to
--- jlua.logging.LOG_LEVEL.CRITICAL.
--
--- @tparam fmt       string    The format string for the message of the log
--                              entry.
--  @vararg any                 Format arguments.
function Logger:critical(fmt, ...)
	self:log(logging.LOG_LEVEL.CRITICAL, fmt, ...)
end

--- @private
function Logger:handle(log_record)
	if self._parent then
		self._parent:handle(log_record)
	end
	for handler in self._handlers:iter() do
		handler(log_record)
	end
end

-- This method isn't meant to be called directly, use logging.get_logger to
-- create a logger.
--- @private
function Logger:init(name, parent)
	self._name = name
	self._parent = parent
	self._children = Map()
	self._handlers = List()
end

-- This method isn't meant to be called directly, use logging.get_logger to
-- create a logger.
--- @private
function Logger:get_or_create_child(child_name)
	local child = self._children[child_name]
	if child then
		return child
	end
	self._children[child_name] = Logger(child_name, self)
	return self._children[child_name]
end

local ROOT_LOGGER = Logger()

--- Get a jlua.logging.Logger instance.
---
--- If a logger with the given name already exists, will return the same
--- instance. Separate the level of hierarchy with dots. i.e if you create a
--- logger named "jean.jacques", all messages logged to it will be forwarded
--- to the logger named "jean".
---
--- @usage
---
--- @tparam string name The name of the logger.
--- @return jlua.logging.Logger Logger instance.
function logging.get_logger(name)
	if not name then
		return ROOT_LOGGER
	end

	local current_logger = ROOT_LOGGER
	local current_name = nil
	for name_part in name:gmatch("([^%.]+)") do
		if not current_name then
			current_name = name_part
		else
			current_name = current_name .. "." .. name_part
		end
		current_logger = current_logger:get_or_create_child(current_name)
	end
	return current_logger
end

return logging
