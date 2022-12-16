--- String utilities.
--- This module contains various helpers related to string.
---
--- The metatable of string isn't replaced, meaning all methods declared here
--- have to be called explicitely.
---
--- @module jlua.string
local string = {}

local get_expression_value

if setfenv ~= nil then
	get_expression_value = function(expression, environment)
		local expression_code = loadstring("return (" .. expression .. ")")
		if expression_code == nil then
			error("Malformed expression :" .. expression)
		end
		setfenv(expression_code, environment)
		return expression_code()
	end
else
	get_expression_value = function(expression, environment)
		return load(
			"return (" .. expression .. ")",
			expression,
			"t",
			environment
		)()
	end
end

local unpack = unpack or table.unpack

--- Extended string format.
---
--- Replacement fields in the format string are delimited with braces {}. Each
--- replacement field can contains either a name of a a keyword argument,  the
--- index of a positionnal arguments or nothing. Each time a replacement field
--- with no name or index is provided, the next format argument is taken.
---
--- Field format can be sepcified after a colon : in a replacement field. This
--- format is passed to the lua format function, thus the format for C function
--- ``printf`` applies.
---
--- To escape braces, simply double them.
---
--- @usage
--- jlua.string.format("{} is an {species} called {0}", "Jean-Paul", { species = "otter"})
--- -- Jean-Paul is an otter called Jean-Paul
---
--- format("{} is {:.2f} years old", "Jean-Paul", 24.2342)
--- -- Jean-Paul is 24.23 years old
---
--- format("{name} is {age:.2f} years old", { name = "Jean-Paul", age = 24.2342})
--- -- Jean-Paul is 24.23 years old
---
--- @tparam string fmt String format.
--- @vararg any        Format arguments.
--- @return string    Formatted string.
function string.format(fmt, ...)
	local arguments = { ... }

	local named_arguments = nil
	if type(arguments[#arguments]) == "table" then
		named_arguments = arguments[#arguments]
	end

	local parsed_arguments = {}
	local index = 0

	local function push_argument(pattern)
		if pattern:sub(1, 1) == "{" then
			return pattern
		end

		local name, format = pattern:match("([^:]*):?(.*)")

		local argument_value
		if name == "" then
			index = index + 1
			argument_value = arguments[index]
		elseif named_arguments ~= nil then
			argument_value = get_expression_value(name, named_arguments)
		else
			error("Named arguments not provided")
		end

		parsed_arguments[#parsed_arguments + 1] = argument_value

		if format == "" then
			if type(argument_value) == "number" then
				format = "i"
			else
				format = "s"
			end
		end

		return "%" .. format
	end

	return fmt:gsub("%{([^%}]-)%}", push_argument)
		:gsub("%{%{", "{")
		:gsub("%}%}", "}")
		:format(unpack(parsed_arguments))
end

return string
