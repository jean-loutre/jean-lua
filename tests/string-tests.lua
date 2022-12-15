local format = require("jlua.string").format

local Suite = {}

function Suite.format()
	local story

	story = format("{} is an otter.", "Jean-Jacques")
	assert_equals(story, "Jean-Jacques is an otter.")

	story = format("{name} is called {name}.", { name = "Jean-Jacques" })
	assert_equals(story, "Jean-Jacques is called Jean-Jacques.")

	story = format(
		"{id.name} has an otter identity.",
		{ id = { name = "Jean-Jacques" } }
	)
	assert_equals(story, "Jean-Jacques has an otter identity.")

	story = format(
		"{name} shredded {:.2f} caimans.",
		2.446,
		{ name = "Jean-Jacques" }
	)
	assert_equals(story, "Jean-Jacques shredded 2.45 caimans.")

	story = format("he likes to {{ escape {{ }} characters }}.")
	assert_equals(story, "he likes to { escape { } characters }.")

	local status, error
	status, error = pcall(function()
		format("he {messes} up it's arguments list.")
	end)

	assert_is_false(status)
	assert_str_contains(error, "Named arguments not provided")

	status, error = pcall(function()
		format("he messes up format too {name+2}.", { name = "Jean-Jacques" })
	end)

	assert_is_false(status)
	assert_str_contains(error, "name+2")
end

return Suite
