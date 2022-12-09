formatter = "plain"
exclude_files = { "third-party" }

stds.luaunit = {
	globals = { "LuaUnit" },
	read_globals = {
		"assert_equals",
		"assert_error_msg_contains",
		"assert_is_false",
		"assert_is_nil",
		"assert_is_true",
		"assert_not_nil",
		"assert_str_contains",
	},
}

std = "max+luaunit"
