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
	table[field] = mock
	coroutine.yield(mock)
	table[field] = old_field
end)

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

return Mock
