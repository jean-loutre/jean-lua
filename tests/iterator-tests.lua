local Iterator = require("jlua.iterator")
local iter = require("jlua.iterator").iter

local function check_bad_arguments(method, ...)
	for _, argument in ipairs({ ... }) do
		assert_error_msg_contains("Bad argument", function()
			method(argument)
		end)
	end
end

-- Test Suite
local Suite = {}

function Suite.init()
	check_bad_arguments(Iterator, nil, 10, {}, "")

	local it = Iterator(ipairs({ "swim", "eat", "sleep" }))

	assert_equals({ it() }, { 1, "swim" })
	assert_equals({ it() }, { 2, "eat" })
	assert_equals({ it() }, { 3, "sleep" })
	assert_equals(it(), nil)
end

function Suite.iter_bad_arguments()
	check_bad_arguments(iter, nil, 10, {}, "")
end

function Suite.iter_iterator()
	local it = iter({})
	assert(iter(it) == it)
end

function Suite.iter_iterable()
	local iterable = {
		__iter = function()
			return ipairs({ "swim", "eat", "sleep" })
		end,
	}

	local it = iter(iterable)
	assert_equals({ it() }, { 1, "swim" })
	assert_equals({ it() }, { 2, "eat" })
	assert_equals({ it() }, { 3, "sleep" })
	assert_equals(it(), nil)
end

function Suite.iter_values()
	check_bad_arguments(iter, nil, 10, function() end, "")
	local it = iter({ "swim", "eat", "sleep" })
	assert_equals(it(), "swim")
	assert_equals(it(), "eat")
	assert_equals(it(), "sleep")
	assert_equals(it(), nil)
end

function Suite.iter_table()
	local it = iter({ morning = "swim", noon = "eat", afternoon = "sleep" })
	local result = {}
	-- must store in a table then test that as table iteration order is not deterministic
	for key, value in it do
		result[key] = value
	end

	assert_equals(
		result,
		{ morning = "swim", noon = "eat", afternoon = "sleep" }
	)
end

function Suite.iter_iterator_function()
	local it = iter(ipairs({ "swim", "eat", "sleep" }))
	assert_equals({ it() }, { 1, "swim" })
	assert_equals({ it() }, { 2, "eat" })
	assert_equals({ it() }, { 3, "sleep" })
	assert_equals(it(), nil)
end

function Suite.all()
	local it = iter({ "swim", "eat", "sleep" })
	assert(false == it:all(function(item)
		return item == "swim" or item == "sleep"
	end))

	it = iter({ "swim", "sleep" })
	assert(true == it:all(function(item)
		return item == "swim" or item == "sleep"
	end))
end

function Suite.any()
	local it = iter({ "swim", "eat", "sleep" })
	assert(true == it:any(function(item)
		return item == "eat"
	end))

	it = iter({ "swim", "eat", "sleep" })
	assert(false == it:any(function(item)
		return item == "take drugs"
	end))

	assert(true == iter({ "swim" }):any())
	assert(false == iter({}):any())
end

function Suite.chain()
	local first = iter({ "swim", "eat", "sleep" })
	local second = iter({ "party", "kill baby seal" })
	local it = first:chain(second)
	assert_equals(it(), "swim")
	assert_equals(it(), "eat")
	assert_equals(it(), "sleep")
	assert_equals(it(), "party")
	assert_equals(it(), "kill baby seal")
	assert_equals(it(), nil)
end

function Suite.count()
	local it

	it = iter({})
	assert_equals(it:count(), 0)

	it = iter({ "swim", "eat", "sleep" })
	assert_equals(it:count(), 3)

	it = iter({ "swim", "eat", "sleep" })
	local function predicate(item)
		return item == "swim" or item == "sleep"
	end

	assert_equals(it:count(predicate), 2)
end

function Suite.filter()
	local it = iter({ "swim", false, "eat", "sleep", false }):filter()
	assert_equals(it(), "swim")
	assert_equals(it(), "eat")
	assert_equals(it(), "sleep")
	assert_is_nil(it())

	local function predicate(item)
		return item == "eat" or item == "sleep"
	end
	it = iter({ "swim", "eat", "sleep" }):filter(predicate)
	assert_equals(it(), "eat")
	assert_equals(it(), "sleep")
	assert_is_nil(it())
end

function Suite.first()
	local it

	it = iter({ "swim", "eat", "sleep" })
	assert_equals(it:first(), "swim")

	it = iter({ "swim", "eat", "sleep" })
	local function predicate(item)
		return item == "sleep"
	end

	assert_equals(it:first(predicate), "sleep")

	it = iter({ "swim", "eat", "sleep" })
	local function drugs(item)
		return item == "take drugs"
	end
	assert_is_nil(it:first(drugs))
	assert_is_nil(iter({}):first())
end

function Suite.map()
	local it = iter({ "swim", "eat", "sleep" }):map(string.upper)
	assert_equals(it(), "SWIM")
	assert_equals(it(), "EAT")
	assert_equals(it(), "SLEEP")
end

function Suite.flatten()
	local it = iter({
		iter({ "swim", "sleep" }),
		iter({ "eat", "kill baby seal" }),
	}):flatten()

	assert_equals(it(), "swim")
	assert_equals(it(), "sleep")
	assert_equals(it(), "eat")
	assert_equals(it(), "kill baby seal")
	assert_equals(it(), nil)
end

function Suite.reduce()
	local all_tasks = iter({ "swim", "sleep", "eat" }):reduce(
		function(result, item)
			return result .. " <3 " .. item
		end,
		""
	)
	assert_equals(all_tasks, " <3 swim <3 sleep <3 eat")
end

function Suite.skip()
	local it

	it = iter({ "swim", "sleep", "eat" }):skip(2)
	assert_equals(it(), "eat")
	assert_equals(it(), nil)

	it = iter({ "swim", "sleep", "eat" }):skip(0)
	assert_equals(it(), "swim")
	assert_equals(it(), "sleep")
	assert_equals(it(), "eat")
	assert_equals(it(), nil)

	it = iter({ "swim", "sleep", "eat" }):skip(4)
	assert_equals(it(), nil)
end

function Suite.take()
	local it

	it = iter({ "swim", "sleep", "eat" }):take(2)
	assert_equals(it(), "swim")
	assert_equals(it(), "sleep")
	assert_equals(it(), nil)

	it = iter({ "swim", "sleep", "eat" }):take(4)
	assert_equals(it(), "swim")
	assert_equals(it(), "sleep")
	assert_equals(it(), "eat")
	assert_equals(it(), nil)

	it = iter({ "swim", "sleep", "eat" }):take(0)
	assert_equals(it(), nil)
end

return Suite
