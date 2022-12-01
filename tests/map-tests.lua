local Map = require("gilbert.map")
local Iterator = require("gilbert.iterator")

local Suite = {}

local hobbies = {
	didoo = "bathing",
	biloo = "eating",
	baboo = "playing",
	["pierre-emmanuel"] = "working class exploitation",
}

function Suite.init_from_nil()
	local map = Map()
	assert_equals(map, {})
end

function Suite.init_from_table()
	local map = Map({ didoo = "bathing", biloo = "eating" })
	assert_equals(map, { didoo = "bathing", biloo = "eating" })
end

function Suite.init_from_lua_iterator()
	local map = Map(pairs({ didoo = "bathing", biloo = "eating" }))
	assert_equals(map, { didoo = "bathing", biloo = "eating" })
end

function Suite.init_from_iterator()
	local map = Map(Iterator.from(pairs({ didoo = "bathing", biloo = "eating" })))
	assert_equals(map, { didoo = "bathing", biloo = "eating" })
end

function Suite.keys()
	local map = Map(Iterator.from(pairs({ didoo = "bathing", biloo = "eating" })))
	local keys = map.keys:to_list()
	keys:sort()
	assert_equals(keys, { "biloo", "didoo" })
end

function Suite.values()
	local map = Map(Iterator.from(pairs({ didoo = "bathing", biloo = "eating" })))
	local values = map.values:to_list()
	values:sort()
	assert_equals(values, { "bathing", "eating" })
end

function Suite.iterate()
	local it = Map({
		didoo = "bathing",
		biloo = "eating",
		baboo = "playing",
		["pierre-emmanuel"] = "working class exploitation",
	}):iter()

	for _ = 1, 4 do
		local key, value = it()
		assert_not_nil(key)
		assert(hobbies[key] == value)
	end
	assert_is_nil(it())
end

function Suite.deep_update()
	local otters = Map({
		gentles = {
			didoo = "bathing",
			biloo = "ball-trap",
		},
	})

	otters:deep_update({
		gentles = {
			biloo = "eating",
		},
		evils = {
			baboo = "playing",
			["pierre-emmanuel"] = "working class exploitation",
		},
	})

	assert_equals(otters, {
		gentles = {
			didoo = "bathing",
			biloo = "eating",
		},
		evils = {
			baboo = "playing",
			["pierre-emmanuel"] = "working class exploitation",
		},
	})
end

function Suite.merge()
	local base_hobbies = Map({
		["didoo"] = "bathing",
		["biloo"] = "eating",
		["baboo"] = "baby seal killing",
	})

	local all_hobbies = base_hobbies:merge(pairs({
		["baboo"] = "playing",
		["pierre-emmanuel"] = "working class exploitation",
	}))

	assert_equals(base_hobbies, {
		["didoo"] = "bathing",
		["biloo"] = "eating",
		["baboo"] = "baby seal killing",
	})

	assert_equals(all_hobbies, {
		["didoo"] = "bathing",
		["biloo"] = "eating",
		["baboo"] = "playing",
		["pierre-emmanuel"] = "working class exploitation",
	})
end

function Suite.update()
	local otter_hobbies = Map({
		["didoo"] = "bathing",
		["biloo"] = "eating",
		["baboo"] = "baby seal killing",
	})

	otter_hobbies:update(pairs({
		["baboo"] = "playing",
		["pierre-emmanuel"] = "working class exploitation",
	}))

	assert_equals(otter_hobbies, {
		["didoo"] = "bathing",
		["biloo"] = "eating",
		["baboo"] = "playing",
		["pierre-emmanuel"] = "working class exploitation",
	})
end

function Suite.to_map()
	local map = Iterator(pairs(hobbies)):to_map()
	assert_equals(map, hobbies)

	map = Iterator.from_values({ "bathing", "eating", "playing", "working class exploitation" }):to_map(function(hobby)
		return ({
			bathing = "didoo",
			eating = "biloo",
			playing = "baboo",
			["working class exploitation"] = "pierre-emmanuel",
		})[hobby]
	end)
	assert_equals(map, hobbies)
end

return Suite
