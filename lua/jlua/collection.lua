--- Base class for collections of single items (set, list)
-- @module jlua.collection
local Object = require("jlua.object")

local Collection = Object:extend("jlua.collection")

--- Get an iterator over collection items
-- @return A jlua.iterator over elements of the collection
function Collection:iter()
	return self:__iter()
end

--- Concatenate the values of this collection
-- @param delim Delimiter to insert between each element
function Collection:concat(delimiter)
	local result = ""
	for item in self:iter() do
		if result ~= "" then
			result = result .. delimiter .. item
		else
			result = item
		end
	end

	return result
end

--- Return a jlua.iterator over the element of the collection
-- This method shoud be implemented in child classes
-- @return A jlua.iterator over elements of the collection
function Collection.__iter()
	-- luacov: disable
	assert(false)
	-- luacov: enable
end

for _, method in ipairs({
	"any",
	"all",
	"chain",
	"filter",
	"first",
	"map",
	"flatten",
	"skip",
	"take",
}) do
	Collection[method] = function(self, ...)
		local iter = self:iter()
		return iter[method](iter, ...)
	end
end

return Collection
