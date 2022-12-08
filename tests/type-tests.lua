local type_ = require("jlua.type")

local Suite = {}

function Suite.is_bool()
	assert(not type_.is_bool({}))
	assert(not type_.is_bool(0))
	assert(not type_.is_bool(""))
	assert(type_.is_bool(true))
	assert(type_.is_bool(false))
end

function Suite.is_table()
	assert(type_.is_table({}))
	assert(not type_.is_table(0))
	assert(not type_.is_table(""))
	assert(not type_.is_table(true))
	assert(not type_.is_table(false))
end

function Suite.is_iterable()
	assert(not type_.is_iterable({}))
	assert(not type_.is_iterable(0))
	assert(type_.is_iterable({
		__iter = function() end,
	}))
	assert(type_.is_iterable(setmetatable({}, {
		__index = { __iter = function() end },
	})))
	assert(not type_.is_iterable(true))
	assert(not type_.is_iterable(false))
end

function Suite.is_string()
	assert(not type_.is_string({}))
	assert(not type_.is_string(0))
	assert(type_.is_string(""))
	assert(not type_.is_string(true))
	assert(not type_.is_string(false))
end

return Suite
