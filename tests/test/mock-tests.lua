local Mock = require("jlua.test.mock")
local Object = require("jlua.object")
local with = require("jlua.context").with

local Suite = {}

function Suite.call()
	local weasel = Mock()
	weasel("eat", "fish")
	assert_equals(weasel.call, { "eat", "fish" })
end

function Suite.return_value()
	local weasel = Mock({ return_value = "puke" })
	assert_equals(weasel("eat", "fish"), "puke")
end

function Suite.index()
	local weasel = Mock()
	weasel.eat("fish")
	assert(Mock:is_class_of(weasel.eat))
	assert_equals(weasel.eat.call, { "fish" })
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

function Suite.patch_class()
	local Otter = Object:extend()

	function Otter.cry()
		return "kweek kweek"
	end

	local otter = Otter()

	assert_equals(otter.cry(), "kweek kweek")
	with(
		Mock.patch(otter, "cry", function()
			return "shkeek"
		end),
		function()
			assert_equals(otter.cry(), "shkeek")
		end
	)
	assert_equals(otter.cry(), "kweek kweek")
end

function Suite.as_function()
	local otter = Mock()
	otter:as_function()("kweek kweek")
	assert_equals(otter.call, { "kweek kweek" })
end

function Suite.call()
	local weasel = Mock()
	weasel("eat", "fish")
	assert_equals(weasel.call, { "eat", "fish" })
end

function Suite.calls()
	local weasel = Mock()
	weasel("eat", "fish")
	weasel("fight", "badger")
	assert_equals(weasel.calls, {
		{ "eat", "fish" },
		{ "fight", "badger" },
	})
end

return Suite
