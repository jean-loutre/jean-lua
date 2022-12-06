--- Mock object similar to python unittest.mock, usable in tests.
-- @module jlua.mock
local List = require("jlua.list")
local Map = require("jlua.map")
local Object = require("jlua.object")
local context_manager = require("jlua.context").context_manager

local Mock = Object:extend()

--- Initialize the mock
--
-- @param args: Table that can contain the following keys:
--                * return_value: value to return for each call.
function Mock:init(args)
	args = Map(args or {})
	self._calls = List()
	self._return_value = args:pop("return_value")
end

--- Patch an object field
--
-- A context manager in which the given field of the given object is patched
-- with the given mock value, or a new mock if not provided. When the context
-- manager exits, the original value is restored.
--
-- @param table: The table to patch.
-- @param field: Name of the field of the table to patch.
-- @param mock: An optional mock value. If not provided, a new mock will be
--              created
--
-- @return The mock .
Mock.patch = context_manager(function(table, field, mock)
	mock = mock or Mock()
	local old_field = table[field]
	-- bypass double definition checks on classes
	if getmetatable(table) == getmetatable(Object) then
		rawset(table._definition._metatable, field, mock)
	else
		table[field] = mock
	end
	coroutine.yield(mock)
	if getmetatable(table) == getmetatable(Object) then
		rawset(table._definition._metatable, field, old_field)
	else
		table[field] = old_field
	end
end)

--- Get an unique call for this mack
--
-- Will assert if more than one call was made
function Mock.properties.call:get()
	assert(#self._calls == 1, "Expected a single call, got " .. #self._calls)
	return unpack(self._calls[1])
end

--- Get th call list for this mock
--
-- Will return a list of list of arguments for every call that was made on
-- this mock.
function Mock.properties.calls:get()
	return self._calls
end

--- Call metamethod
--
-- Will save the calls that are made to this mock. If return_value was passed
-- to the init method, it is returned.
function Mock:__call(...)
	local side_effect = rawget(self, "side_effect")
	if side_effect then
		side_effect(...)
	end
	self._calls:push(List({ ... }))
	return self._return_value
end

--- Indexing metamethod
--
-- When a non-existent property is queried, a new mock is created, assigned to
-- this property and returned.
function Mock:__index(key)
	local new_mock = Mock()
	rawset(self, key, new_mock)
	return new_mock
end

--- Get a closure calling that mock.
--
-- Usefull to pass mock to method checking if the given value is a lua function.
--
-- Returns
-- -------
-- function(...) -> *
--     A function that will forward calls to this mock.
function Mock:as_function()
	return function(...)
		return self(...)
	end
end

--- Reset the call list for that mock
--
function Mock:reset()
	self._calls = List()
end

return Mock
