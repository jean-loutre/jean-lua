--- Utilities for type checking and conversion

-- @module gilbert.types

local value = {}

--- Check if a value is a boolean.
--
-- @param val The value to check
--
-- @return True if the value is a boolean
function value.is_bool(val)
	return val == true or val == false
end

--- Check if a value is a table
-- @param val The value to check
-- @return True if the value is a table
function value.is_table(val)
	return type(val) == "table"
end

--- Check if a value is an iterable
-- @param val The value to check
-- @return True if the value is a table with an __iter method
function value.is_iterable(val)
	return value.is_table(val) and type(val.__iter) == "function"
end

--- Check if a value is a string
-- @param val The value to check
-- @return True if the value is a string
function value.is_string(val)
	return type(val) == "string"
end

--- Check if a value is a number.
--
-- @param val The value to check
--
-- @return True if the value is a number
function value.is_number(val)
	return type(val) == "number"
end

--- Check if a value is callable
-- @param value To check
-- @return True if the value callable, false otherwise
function value.is_callable(val)
	return type(val) == "function" or type(val) == "table" and val.__call ~= nil
end

return value
