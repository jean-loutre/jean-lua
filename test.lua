#!/usr/bin/lua
package.path = package.path .. ";lua/?.lua;./third-party/?.lua;./tests/?.lua"

local suites = {
	"collection-tests",
	"context-tests",
	"iterator-tests",
	"list-tests",
	"map-tests",
	"test-mock-tests",
	"object-tests",
	"path-tests",
	"value-tests",
}

-- To make assert functions globally accessible
for key, value in pairs(require("luaunit")) do
	_G[key] = value
end

for _, suite in ipairs(suites) do
	_G[suite] = require(suite)
end

function LuaUnit.isMethodTestName()
	return true
end

function LuaUnit.isTestName(name)
	for _, suite in ipairs(suites) do
		if suite == name then
			return true
		end
	end
	return false
end

os.exit(LuaUnit.run())
