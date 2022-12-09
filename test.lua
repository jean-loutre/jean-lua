#!/usr/bin/lua
package.path = package.path .. ";lua/?.lua;./third-party/?.lua;./tests/?.lua"

local suites = {
	"test.mock-tests",
	"test.call-tests",
	"collection-tests",
	"context-tests",
	"iterator-tests",
	"list-tests",
	"map-tests",
	"object-tests",
	"path-tests",
	"type-tests",
}

local function get_suite_id(suite_module)
	return suite_module:gsub("%.", "/")
end

-- To make assert functions globally accessible
for key, value in pairs(require("luaunit")) do
	_G[key] = value
end

for _, suite in ipairs(suites) do
	_G[get_suite_id(suite)] = require(suite)
end

function LuaUnit.isMethodTestName()
	return true
end

function LuaUnit.isTestName(name)
	for _, suite in ipairs(suites) do
		if get_suite_id(suite) == name then
			return true
		end
	end
	return false
end

os.exit(LuaUnit.run())
