local List = require("gilbert.list")
local unpack = unpack or table.unpack

local Suite = {}

function Suite.init()
	local otters_table = { "didoo", "biloo", "baboo", "pierre-emmanuel" }

	local otters = List(otters_table)
	assert_equals(otters, otters_table)

	local current = 0
	local function iterator()
		current = current + 1
		return otters_table[current]
	end

	otters = List({
		__iter = function()
			return iterator
		end,
	})
	assert_equals(otters, otters_table)

	assert_error_msg_contains("Bad argument", function()
		List(0)
	end)

	assert_error_msg_contains("Bad argument", function()
		List("didoo")
	end)
end

function Suite.iter()
	local otters_source = { "didoo", "biloo", "baboo", "pierre-emmanuel" }
	local otters = List(otters_source)

	local n = 0
	for otter in otters:iter() do
		n = n + 1
		assert(otter == otters_source[n])
	end
	assert(n == 4)
end

function Suite.push_pop()
	local otters = List()
	otters:push("didoo")
	assert(otters[1] == "didoo")

	otters:push("biloo")
	assert(otters[2] == "biloo")

	assert(otters:pop() == "biloo")
	assert(otters[2] == nil)
	assert(otters:pop() == "didoo")
	assert(otters[1] == nil)
end

function Suite.remove_element()
	local otters = List({ "didoo", "biloo", "baboo", "biloo" })

	otters:remove("biloo")
	assert_equals(otters[1], "didoo")
	assert_equals(otters[2], "baboo")
	assert_equals(otters[3], "biloo")

	otters:remove("biloo")
	assert_equals(otters[1], "didoo")
	assert_equals(otters[2], "baboo")
end

function Suite.remove_return()
	local otters = List({ "didoo", "biloo", "baboo", "biloo" })

	assert(otters:remove("biloo"))
	assert(otters:remove("biloo"))
	assert(not otters:remove("biloo"))
end

function Suite.sort_default()
	local otters = List({ "didoo", "pierre-emmanuel", "biloo", "baboo" })
	otters:sort()

	assert_equals(otters, { "baboo", "biloo", "didoo", "pierre-emmanuel" })
end

function Suite.sort_with_predicate()
	local otters = List({ "didoo", "pierre-emmanuel", "biloo", "baboo" })

	otters:sort(function(a, b)
		return string.reverse(a) < string.reverse(b)
	end)

	assert_equals(otters, { "pierre-emmanuel", "baboo", "didoo", "biloo" })
end

function Suite.slice()
	local otters = List({ "didoo", "biloo", "baboo", "pierre-emmanuel" })

	assert_equals(otters:slice(1, 4):to_list(), { "didoo", "biloo", "baboo", "pierre-emmanuel" })
	assert_equals(otters:slice(1, 1):to_list(), { "didoo" })
	assert_equals(otters:slice(4, 3):to_list(), {})
	assert_equals(otters:slice(2, 3):to_list(), { "biloo", "baboo" })
	assert_equals(otters:slice(3):to_list(), { "baboo", "pierre-emmanuel" })

	for _, args in ipairs({ { "1", 4 }, { 1, "4" }, { 5, 3 }, { 3, 5 } }) do
		assert_error_msg_contains("Bad argument", function()
			otters:slice(unpack(args))
		end)
	end
end

function Suite.reverse()
	local otters = List({ "didoo", "biloo", "baboo", "pierre-emmanuel" })

	assert_equals(otters:reverse():to_list(), { "pierre-emmanuel", "baboo", "biloo", "didoo" })
end

function Suite.iterator_to_list()
	local otters = List({ "didoo", "biloo", "baboo", "pierre-emmanuel" })
	otters = otters:iter():to_list()
	assert_equals(otters, { "didoo", "biloo", "baboo", "pierre-emmanuel" })
end

return Suite
