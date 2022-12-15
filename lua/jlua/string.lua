--- String function utilities
-- @module jlua.iterator
local string = {}

local get_expression_value

if setfenv ~= nil then
	get_expression_value = function(expression, environment)
		local expression_code = loadstring("return (" .. expression .. ")")
		if expression_code == nil then
			error("Malformed expression :" .. expression)
		end
		setfenv(expression_code, environment)
		return expression()
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
