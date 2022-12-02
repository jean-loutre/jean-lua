--- Base class for collections of single items (set, list)
-- @module jlua.collection
local Object = require("jlua.object")

local Collection = Object:extend("jlua.collection")

--- Get an iterator over collection items
-- @return A jlua.iterator over elements of the collection
function Collection:iter()
	return self:__iter()
end

--- Return true if any item in the collection matches the given predicate.
--
-- If no predicate is given, return true if the collection contains at least
-- one element.
--
-- @param predicate nil, or a predicate function taking a collection item as
--                  parameter and returning a boolean.
--
-- @return True if an element matches predicate, or predicate is ni and
--         collection is not empty, false otherwise.
function Collection:any(predicate)
	return self:iter():any(predicate)
end
--- Maps elements of this collection
-- Shortcut for collection:iter():map(...)
-- @param func The map function
-- @return Mapped jlua.iterator
function Collection:map(func)
	return self:iter():map(func)
end

--- Filters element of this collection
-- Shortcut for collection:iter():filter(...)
-- @param predicate The filter predicate
-- @return Filtered jlua.iterator
function Collection:filter(predicate)
	return self:iter():filter(predicate)
end

--- Return an iterator skipping the first count elements of this collection.
--
-- @param count Number of items to skip.
--
-- @return A jlua.iterator starting after count elements.
function Collection:skip(count)
	return self:iter():skip(count)
end

--- Return an iterator taking the first count elements of this collection.
--
-- @param count Number of items to take.
--
-- @return A jlua.iterator of the first count elements.
function Collection:take(count)
	return self:iter():take(count)
end

--- Returns first element matching a predicate
-- Shortcut for collection:iter():first(...)
-- @param predicate The predicate to apply to find items
-- @return The first item matching the predicate
function Collection:first(predicate)
	return self:iter():first(predicate)
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

--- Return an iterator chaining element of this collection with
--  given iterable or iterator
-- Shortcut for collection:iter():chain(...)
-- @param other The other iterator
function Collection:chain(other)
	return self:iter():chain(other)
end

--- Return a jlua.iterator over the element of the collection
-- This method shoud be implemented in child classes
-- @return A jlua.iterator over elements of the collection
function Collection.__iter()
	-- luacov: disable
	assert(false)
	-- luacov: enable
end

return Collection
