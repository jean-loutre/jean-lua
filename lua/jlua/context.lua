--- Sort of Python-like context manager
-- @module jlua.context
local unpack = rawget(_G, "unpack") or table.unpack

local context = {}

--- Run inner function in the given context.
--
-- Calls context.__enter(), calls inner with the result of this call. Then, if
-- inner raised an error, calls __exit with the error. If __exit return true,
-- the error is ignored, and nil is returned. Else the error is re-raised. If
-- no error occured in inner, return the result of the call.
--
-- @param context_manager: The context manager.
-- @param inner:           Function to run in the given context.
--
-- @return: The result of inner, or nil if an error occured and was ignored.
function context.with(context_manager, inner)
	local context_variable = { context_manager:__enter() }

	local result = { pcall(function()
		return inner(unpack(context_variable))
	end) }
	local status = result[1]
	if not status then
		local err = result[2]
		if not context_manager:__exit(err) then
			error(err)
		end

		return nil
	end

	context_manager:__exit()
	table.remove(result, 1)
	return unpack(result)
end

return context
