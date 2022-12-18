--- Higher-order functions utilities
--- @module jlua.functional
local is_callable = require("jlua.type").is_callable

local functional = {}

local unpack = unpack or table.unpack

--- Bind the given arguments to a function.
---
--- Given the function func_a(a, b, c), calling bind(func_a, 1, true) will
--- return a new function func_b such as calling  func_b("weasel") will call
--- func_a(1, true, "weasel")
---
--- @tparam func(...):any func The wrapped function.
--- @vararg any                Arguments to bind to the function.
--- @returns func(...)         The bound function
function functional.bind(func, ...)
	assert(is_callable(func))

	local bound_args = { n = select("#", ...), ... }

	return function(...)
		local args = { n = select("#", ...), ... }
		local merged_args = {}
		local merged_arg_id = 0

		for i = 1, bound_args.n do
			merged_arg_id = merged_arg_id + 1
			merged_args[merged_arg_id] = bound_args[i]
		end

		for i = 1, args.n do
			merged_arg_id = merged_arg_id + 1
			merged_args[merged_arg_id] = args[i]
		end

		return func(unpack(merged_args, 1, 4))
	end
end

return functional
