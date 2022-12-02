local Collection = require("jlua.collection")
local Iterator = require("jlua.iterator")

local OtterList = Collection:extend()

function OtterList:init(otters)
	for _, item in ipairs(otters) do
		table.insert(self, item)
	end
end

function OtterList:__iter()
	local current = 0
	return Iterator(function()
		current = current + 1
		return self[current]
	end)
end

local Suite = {}

function Suite.any()
	local otters = OtterList({ "didoo", "biloo", "baboo", "pierre-emmanuel" })
	assert(otters:any())
	assert(not OtterList({}):any())
	assert(otters:any(function(o)
		return o == "baboo"
	end))
	assert(not otters:any(function(o)
		return o == "roger"
	end))
end

function Suite.map()
	local otters = OtterList({ "didoo", "biloo", "baboo", "pierre-emmanuel" })
	local big_otters = otters:map(string.upper)
	assert_equals(big_otters(), "DIDOO")
	assert_equals(big_otters(), "BILOO")
	assert_equals(big_otters(), "BABOO")
	assert_equals(big_otters(), "PIERRE-EMMANUEL")
	assert_is_nil(big_otters())
end

function Suite.filter()
	local otters = OtterList({ "didoo", "biloo", "baboo", "pierre-emmanuel" })
	local rich_otters = otters:filter(function(o)
		return string.find(o, "-") -- compound names are a bourgeoisie trait
	end)
	assert_equals(rich_otters(), "pierre-emmanuel")
	assert_is_nil(rich_otters())
end

function Suite.first()
	local otters = OtterList({ "didoo", "biloo", "baboo", "pierre-emmanuel" })
	local rich_otter = otters:first(function(o)
		return string.find(o, "-") -- compound names are a bourgeoisie trait
	end)
	assert_equals(rich_otter, "pierre-emmanuel")
end

function Suite.chain()
	local otters = OtterList({ "didoo", "biloo" })
	local other_otters = OtterList({ "baboo", "pierre-emmanuel" })
	local all_otters = otters:chain(other_otters)
	assert_equals(all_otters(), "didoo")
	assert_equals(all_otters(), "biloo")
	assert_equals(all_otters(), "baboo")
	assert_equals(all_otters(), "pierre-emmanuel")
	assert_is_nil(all_otters())
end

function Suite.concat()
	local otters = OtterList({})
	local otter_centipede = otters:concat("<3")
	assert_equals(otter_centipede, "")

	otters = OtterList({ "didoo" })
	otter_centipede = otters:concat("<3")
	assert_equals(otter_centipede, "didoo")

	otters = OtterList({ "didoo", "biloo", "baboo", "pierre-emmanuel" })
	otter_centipede = otters:concat("<3")
	assert_equals(otter_centipede, "didoo<3biloo<3baboo<3pierre-emmanuel")
end

function Suite.skip()
	local otters = OtterList({ "didoo", "biloo", "baboo", "pierre-emmanuel" })
	local end_otters = otters:skip(2)
	assert_equals(end_otters(), "baboo")
	assert_equals(end_otters(), "pierre-emmanuel")
	assert_is_nil(end_otters())
end

function Suite.take()
	local otters = OtterList({ "didoo", "biloo", "baboo", "pierre-emmanuel" })
	local start_otters = otters:take(2)
	assert_equals(start_otters(), "didoo")
	assert_equals(start_otters(), "biloo")
	assert_is_nil(start_otters())
end

return Suite
