local value = require("gilbert.value")

local Suite = {}

function Suite.is_bool()
	assert(not value.is_bool({}))
	assert(not value.is_bool(0))
	assert(not value.is_bool(""))
	assert(value.is_bool(true))
	assert(value.is_bool(false))
end

function Suite.is_table()
	assert(value.is_table({}))
	assert(not value.is_table(0))
	assert(not value.is_table(""))
	assert(not value.is_table(true))
	assert(not value.is_table(false))
end

function Suite.is_iterable()
	assert(not value.is_iterable({}))
	assert(not value.is_iterable(0))
	assert(value.is_iterable({
		__iter = function() end,
	}))
	assert(value.is_iterable(setmetatable({}, {
		__index = { __iter = function() end },
	})))
	assert(not value.is_iterable(true))
	assert(not value.is_iterable(false))
end

function Suite.is_string()
	assert(not value.is_string({}))
	assert(not value.is_string(0))
	assert(value.is_string(""))
	assert(not value.is_string(true))
	assert(not value.is_string(false))
end

return Suite
