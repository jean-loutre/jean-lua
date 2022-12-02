local Mock = require("jlua.mock")

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

return Suite
