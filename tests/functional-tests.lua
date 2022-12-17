local Mock = require("jlua.test.mock")

local bind = require("jlua.functional").bind

local Suite = {}

function Suite.bind()
	local mock = Mock()
	local bound_mock = bind(mock, "weasel", nil, "badger")
	bound_mock("geranium")

	assert_equals(mock.call, { "weasel", nil, "badger", "geranium" })
end

return Suite
