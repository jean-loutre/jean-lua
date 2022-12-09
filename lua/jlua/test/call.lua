--- Allow comparison of call arguments
-- @classmod jlua.test.Call
local Object = require("jlua.object")
local iter = require("jlua.iterator").iter
local is_callable = require("jlua.type").is_callable

local Call = Object:extend()

--- Pass this function as argument of call to match any argument.
--
-- @return boolean true, no matter what.
function Call.any_arg()
	return true
end

--- Initialize the call
--
-- @vararg any values the call was made with
function Call:init(...)
	for argument in iter({ ... }) do
		table.insert(self, argument)
	end
end

--- Check if this call matches the given one.
--
-- Will check either if each argument is equal, or the right one is callable
-- end the result of calling it with the tested argument is true. This allow
-- this :
--
-- ```
-- assert(Call("otter", 10) == Call(Call.any_arg, 10))
-- ```
--
-- Eventually one can write custom function to check for special cases.
--
-- @vararg any values the call was made with.
--
-- @return boolean True if arguments match, false otherwise.
function Call:__eq(right)
	local left_iterator = iter(self)
	for right_arg in iter(right) do
		local left_arg = left_iterator()

		if left_arg ~= right_arg then
			if left_arg == nil or right_arg == nil then
				return false
			end

			if not is_callable(right_arg) or not right_arg(left_arg) then
				return false
			end
		end
	end

	return true
end

return Call
