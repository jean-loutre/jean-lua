--- Mock object similar to python unittest.mock, usable in tests.
-- @module jlua.mock
local List = require("jlua.list")
local Map = require("jlua.map")
local Object = require("jlua.object")

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
