local Mock = require("jlua.test.mock")

local get_logger = require("jlua.logging").get_logger
local LOG_LEVEL = require("jlua.logging").LOG_LEVEL

local Suite = {}

function Suite.handle()
	local logger = get_logger("jean")

	local handler = Mock()
	logger:add_handler(handler)

	logger:log(LOG_LEVEL.DEBUG, "Hello", "Jean-Jacques")
	assert_equals(handler.call, {
		{
			logger = "jean",
			level = LOG_LEVEL.DEBUG,
			format = "Hello",
			args = { "Jean-Jacques" },
		},
	})

	handler:reset()
	logger:remove_handler(handler)
	logger:log(LOG_LEVEL.DEBUG, "Hello", "Jean-Jacques")
	assert_equals(#handler.calls, 0)
end

function Suite.parent_handle()
	local parent_logger = get_logger("jean")
	local child_logger = get_logger("jean.jacques")

	local handler = Mock()
	parent_logger:add_handler(handler)

	child_logger:log(LOG_LEVEL.DEBUG, "Hello", "Jean-Jacques")
	assert_equals(handler.call, {
		{
			logger = "jean.jacques",
			level = LOG_LEVEL.DEBUG,
			format = "Hello",
			args = { "Jean-Jacques" },
		},
	})
end

function Suite.log_methods()
	local handler = Mock()
	local logger = get_logger("jean")
	logger:add_handler(handler)

	local function test_log_level(method, expected_level)
		method(logger, "Hello")
		assert_equals(handler.call[1].level, expected_level)
		handler:reset()
	end

	test_log_level(logger.debug, LOG_LEVEL.DEBUG)
	test_log_level(logger.info, LOG_LEVEL.INFO)
	test_log_level(logger.warning, LOG_LEVEL.WARNING)
	test_log_level(logger.error, LOG_LEVEL.ERROR)
	test_log_level(logger.critical, LOG_LEVEL.CRITICAL)
end

return Suite
