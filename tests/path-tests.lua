local Path = require("jlua.path")
local with = require("jlua.context").with

local Suite = {}

function Suite.init()
	local otter = Path("europe/france/dumb_ones/peter")
	assert_not_nil(otter)

	local otter_copy = Path(otter)
	assert(not otter.is_absolute)
	assert_equals(tostring(otter_copy), "europe/france/dumb_ones/peter")

	otter = Path()
	assert_not_nil(otter)
	assert(not otter.is_absolute)
end

function Suite.is_absolute()
	local otter = Path()
	assert(not otter.is_absolute)

	otter = Path("europe/france/dumb_ones/peter")
	assert(not otter.is_absolute)

	otter = Path("/world/europe/france/dumb_ones/peter")
	assert(otter.is_absolute)
end

function Suite.basename()
	local otter = Path("europe/france/dumb_ones/peter")
	assert_equals(otter.basename, "peter")
end

function Suite.parents()
	local otter = Path("europe/france/dumb_ones/peter")
	assert_equals(otter.parents:map(tostring):to_list(), { "europe/france/dumb_ones", "europe/france", "europe" })
	assert_equals(Path().parents:to_list(), {})
end

function Suite.__div()
	local otter

	otter = Path("europe/france") / Path("dumb_ones/peter")
	assert_equals(tostring(otter), "europe/france/dumb_ones/peter")

	otter = Path("europe/france") / "dumb_ones/peter"
	assert_equals(tostring(otter), "europe/france/dumb_ones/peter")

	otter = Path("/world/europe/france") / "dumb_ones/peter"
	assert_equals(tostring(otter), "/world/europe/france/dumb_ones/peter")
end

function Suite.__tostring()
	local otter = Path("europe/france/dumb_ones/peter")
	assert_equals(tostring(otter), "europe/france/dumb_ones/peter")

	otter = Path("/world/europe/france/dumb_ones/peter")
	assert_equals(tostring(otter), "/world/europe/france/dumb_ones/peter")
end

function Suite.open()
	local squeak = Path(os.tmpname())

	with(squeak:open("w"), function(file)
		file:write("Kweek kweek")
	end)

	with(squeak:open("r"), function(file)
		assert_equals(file:read(), "Kweek kweek")
	end)

	os.remove(tostring(squeak))
end

function Suite.relative_to()
	local otter
	otter = Path("europe/france/dumb_ones/peter")
	otter = otter:relative_to("europe/germany/smart_ones")
	assert_equals(tostring(otter), "../../france/dumb_ones/peter")

	otter = Path("/world/europe/france/dumb_ones/peter")
	otter = otter:relative_to("/world/europe/germany/smart_ones")
	assert_equals(tostring(otter), "../../france/dumb_ones/peter")
end
return Suite
