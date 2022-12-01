local Object = require("gilbert.object")
local with = require("gilbert.context").with

local Suite = {}

local Afternoon = Object:extend()

function Afternoon:init(skip_error)
	self._skip_error = skip_error or false
	self.exit_called = false
end

function Afternoon.__enter()
	return "didoo", "smash caiman"
end

function Afternoon:__exit(err)
	self.exit_called = true
	self.err = err
	return self._skip_error
end

function Suite.inner_call_arguments()
	local afternoon = Afternoon()

	local name, status = with(afternoon, function(name, task)
		assert_equals(name, "didoo")
		assert_equals(task, "smash caiman")
		-- smash the caiman
		return "didoo", "done"
	end)

	assert_is_true(afternoon.exit_called)
	assert_is_nil(afternoon.err)
	assert_equals(name, "didoo")
	assert_equals(status, "done")
end

function Suite.re_raise_error()
	local afternoon = Afternoon()

	local _, err = pcall(function()
		with(afternoon, function()
			error("I'm asleep")
		end)
	end)

	assert_is_true(afternoon.exit_called)
	assert_str_contains(afternoon.err, "I'm asleep")
	assert_str_contains(err, afternoon.err)
end

function Suite.skip_error()
	local afternoon = Afternoon(true)

	local result = with(afternoon, function()
		error("I'm asleep")
	end)

	assert_is_nil(result)
	assert_is_true(afternoon.exit_called)
	assert_str_contains(afternoon.err, "I'm asleep")
end

return Suite
