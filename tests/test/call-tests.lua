local Call = require("jlua.test.call")

local Suite = {}

function Suite.raw_equal()
	assert_is_true(Call("eat", "fish") == Call("eat", "fish"))
	assert_is_false(Call("eat", "fish") == Call("eat"))
end

function Suite.function_arg()
	local is_eating = function(arg)
		return arg == "eat"
	end
	assert_is_true(Call("eat", "fish") == Call(is_eating, "fish"))
	assert_is_false(Call("sleep", "fish") == Call(is_eating, "fish"))
end

function Suite.any_arg()
	assert_is_true(Call("eat", "fish") == Call(Call.any_arg, "fish"))
end

return Suite
