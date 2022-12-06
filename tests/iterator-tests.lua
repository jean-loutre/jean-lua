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

function Suite.from_bad_arguments()
	check_bad_arguments(Iterator.from, nil, 10, {}, "")
end

function Suite.from_iterator()
	local it = Iterator.from_values({})
	assert(Iterator.from(it) == it)
end

function Suite.from_iterable()
	local iterable = {
		__iter = function()
			return ipairs({ "swim", "eat", "sleep" })
		end,
	}

	local it = Iterator.from(iterable)
	assert_equals({ it() }, { 1, "swim" })
	assert_equals({ it() }, { 2, "eat" })
	assert_equals({ it() }, { 3, "sleep" })
	assert_equals(it(), nil)
end

function Suite.from_table()
	local it = Iterator.from({ morning = "swim", noon = "eat", afternoon = "sleep" })
	local result = {}
	-- must store in a table then test that as table iteration order is not deterministic
	for key, value in it do
		result[key] = value
	end

	assert_equals(result, { morning = "swim", noon = "eat", afternoon = "sleep" })
end

function Suite.from_iterator_function()
	local it = Iterator.from(ipairs({ "swim", "eat", "sleep" }))
	assert_equals({ it() }, { 1, "swim" })
	assert_equals({ it() }, { 2, "eat" })
	assert_equals({ it() }, { 3, "sleep" })
	assert_equals(it(), nil)
end

function Suite.from_values()
	check_bad_arguments(Iterator.from_values, nil, 10, function() end, "")
	local it = Iterator.from_values({ "swim", "eat", "sleep" })
	assert_equals(it(), "swim")
	assert_equals(it(), "eat")
	assert_equals(it(), "sleep")
	assert_equals(it(), nil)
end

function Suite.iter()
	local it = iter({ "swim", "eat", "sleep" })
	assert_equals(it(), "swim")
	assert_equals(it(), "eat")
	assert_equals(it(), "sleep")
	assert_equals(it(), nil)

	it = iter({ morning = "swim", noon = "eat", afternoon = "sleep" })
	local result = {}
	-- must store in a table then test that as table iteration order is not deterministic
	for key, value in it do
		result[key] = value
	end

	assert_equals(result, { morning = "swim", noon = "eat", afternoon = "sleep" })
end

function Suite.all()
	local it = Iterator.from_values({ "swim", "eat", "sleep" })
	assert(false == it:all(function(item)
		return item == "swim" or item == "sleep"
	end))

	it = Iterator.from_values({ "swim", "sleep" })
	assert(true == it:all(function(item)
		return item == "swim" or item == "sleep"
	end))
end

function Suite.any()
	local it = Iterator(ipairs({ "swim", "eat", "sleep" }))
	assert(true == it:any(function(idx, item)
		return idx == 2 and item == "eat"
	end))

	it = Iterator.from_values({ "swim", "eat", "sleep" })
	assert(false == it:any(function(item)
		return item == "take drugs"
	end))

	assert(true == Iterator.from_values({ "swim" }):any())
	assert(false == Iterator.from_values({}):any())
end

function Suite.chain()
	local first = Iterator.from_values({ "swim", "eat", "sleep" })
	local second = Iterator.from_values({ "party", "kill baby seal" })
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

	it = Iterator(ipairs({}))
	assert_equals(it:count(), 0)

	it = Iterator(ipairs({ "swim", "eat", "sleep" }))
	assert_equals(it:count(), 3)

	it = Iterator(ipairs({ "swim", "eat", "sleep" }))
	local function predicate(idx, item)
		assert(idx ~= nil)
		return item == "swim" or item == "sleep"
	end

	assert_equals(it:count(predicate), 2)
end

function Suite.filter()
	local function predicate(item)
		return item == "eat" or item == "sleep"
	end
	local it = Iterator.from_values({ "swim", "eat", "sleep" }):filter(predicate)
	assert_equals(it(), "eat")
	assert_equals(it(), "sleep")
	assert_is_nil(it())
end

function Suite.first()
	local it

	it = Iterator.from_values({ "swim", "eat", "sleep" })
	assert_equals(it:first(), "swim")

	it = Iterator.from_values({ "swim", "eat", "sleep" })
	local function predicate(item)
		return item == "sleep"
	end

	assert_equals(it:first(predicate), "sleep")

	it = Iterator.from_values({ "swim", "eat", "sleep" })
	local function drugs(item)
		return item == "take drugs"
	end
	assert_is_nil(it:first(drugs))
	assert_is_nil(Iterator.from_values({}):first())
end

function Suite.map()
	local it = Iterator.from_values({ "swim", "eat", "sleep" }):map(string.upper)
	assert_equals(it(), "SWIM")
	assert_equals(it(), "EAT")
	assert_equals(it(), "SLEEP")
end

function Suite.flatten()
	local it = Iterator.from_values({
		Iterator.from_values({ "swim", "sleep" }),
		Iterator.from_values({ "eat", "kill baby seal" }),
	}):flatten()

	assert_equals(it(), "swim")
	assert_equals(it(), "sleep")
	assert_equals(it(), "eat")
	assert_equals(it(), "kill baby seal")
	assert_equals(it(), nil)
end

function Suite.skip()
	local it

	it = Iterator.from_values({ "swim", "sleep", "eat" }):skip(2)
	assert_equals(it(), "eat")
	assert_equals(it(), nil)

	it = Iterator.from_values({ "swim", "sleep", "eat" }):skip(0)
	assert_equals(it(), "swim")
	assert_equals(it(), "sleep")
	assert_equals(it(), "eat")
	assert_equals(it(), nil)

	it = Iterator.from_values({ "swim", "sleep", "eat" }):skip(4)
	assert_equals(it(), nil)
end

function Suite.take()
	local it

	it = Iterator.from_values({ "swim", "sleep", "eat" }):take(2)
	assert_equals(it(), "swim")
	assert_equals(it(), "sleep")
	assert_equals(it(), nil)

	it = Iterator.from_values({ "swim", "sleep", "eat" }):take(4)
	assert_equals(it(), "swim")
	assert_equals(it(), "sleep")
	assert_equals(it(), "eat")
	assert_equals(it(), nil)

	it = Iterator.from_values({ "swim", "sleep", "eat" }):take(0)
	assert_equals(it(), nil)
end

return Suite
