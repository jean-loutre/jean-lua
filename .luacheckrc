formatter = "plain"
exclude_files = { "third-party" }

stds.luaunit = {
	globals = { "LuaUnit" },
	read_globals = {
		"assert_equals",
		"assert_error_msg_contains",
		"assert_is_nil",
		"assert_not_nil",
	},
}

std = "max+luaunit"
