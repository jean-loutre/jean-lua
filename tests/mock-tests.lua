local Mock = require("jlua.mock")
local with = require("jlua.context").with

local Suite = {}

function Suite.call()
	local weasel = Mock()
	weasel("eat", "fish")
	assert_equals(weasel.calls, { { "eat", "fish" } })
end

function Suite.return_value()
	local weasel = Mock({ return_value = "puke" })
	assert_equals(weasel("eat", "fish"), "puke")
end

function Suite.index()
	local weasel = Mock()
	weasel.eat("fish")
	assert(Mock:is_class_of(weasel.eat))
	assert_equals(weasel.eat.calls, { { "fish" } })
end

function Suite.patch()
	local otter = {
		cry = "kweek kweek",
	}

	with(Mock.patch(otter, "cry"), function(mock)
		assert(Mock:is_class_of(otter.cry))
		assert_equals(otter.cry, mock)
	end)

	assert_equals(otter.cry, "kweek kweek")

	with(Mock.patch(otter, "cry", "shkeek"), function(mock)
		assert_equals(otter.cry, "shkeek")
		assert_equals(mock, "shkeek")
	end)
	assert_equals(otter.cry, "kweek kweek")
end

return Suite
