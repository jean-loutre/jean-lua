--- Base class for collections of key, value pairs (dict, orderedmap)
-- @module jlua.collection
local Collection = require("jlua.collection")
local Iterator = require("jlua.iterator")
local is_table = require("jlua.type").is_table

local Map = Collection:extend("jlua.map")

--- Initialize a map from lua table
--
-- @param ... : Anything that can be passed to Iterator.from to create a
--              key / value pair iterator.
function Map:init(...)
	self:parent("init")
	if select(1, ...) ~= nil then
		for key, value in Iterator.from(...) do
			self[key] = value
		end
	end
end

--- Get a jlua.iterator of the values of the map.
function Map.properties.keys:get()
	local key = nil
	return Iterator(function()
		key = next(self, key)
		return key
	end)
end

--- Get a jlua.iterator of the values of the map.
function Map.properties.values:get()
	local key = nil
	return Iterator(function()
		key = next(self, key)
		if key == nil then
			return nil
		end

		return self[key]
	end)
end

--- Return a jlua.pair_iterator over the element of the collection
-- This method shoud be implemented in child classes
--
-- @return A jlua.pair_iterator over elements of the collection
function Map:__iter()
	return Iterator(pairs(self))
end

--- Update values in this map with given values, recursively.
--
-- @param ... Anything that can be converted to a key / value iterator through
--            the Iterator.from methods (Iterator, lua iterator function,
--            table with an __iter method or metamethod)
function Map:deep_update(...)
	for key, value in Iterator.from(...) do
		if is_table(value) and is_table(self[key] or false) then
			self[key] = self[key] or {}
			Map.deep_update(self[key], value)
		else
			self[key] = value
		end
	end
end

--- Create a new map with values of self updated with values of given map.
--
-- @param ... Anything that can be converted to a key / value iterator through
--            the Iterator.from methods (Iterator, lua iterator function,
--            table with an __iter method or metamethod)
function Map:merge(...)
	local result = Map(self)
	result:update(...)
	return result
end

--- Update values in this map with given values.
--
-- @param ... Anything that can be converted to a key / value iterator through
--            the Iterator.from methods (Iterator, lua iterator function,
--            table with an __iter method or metamethod)
function Map:update(...)
	for key, value in Iterator.from(...) do
		self[key] = value
	end
end

--- Return a map containing elements of this iterator
--
-- @param key_getter Function returning a key from an element.
--                   if not provided, assumes that the iterator
--                   returns tuples of key, value elements
--
-- @return A jlua.map containing elements of the iterator
function Iterator:to_map(key_getter)
	local result = Map()
	if key_getter ~= nil then
		for item in self do
			result[key_getter(item)] = item
		end
	else
		for key, value in self do
			result[key] = value
		end
	end

	return result
end

return Map
