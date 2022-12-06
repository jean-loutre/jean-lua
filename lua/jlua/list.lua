--- A list of items, with random access
-- @module jlua.iterator
local Collection = require("jlua.collection")
local Iterator = require("jlua.iterator")
local is_iterable = require("jlua.type").is_iterable
local is_table = require("jlua.type").is_table

local List = Collection:extend("jlua.list")

--- Initialize a list from a table
-- @param ... A table, or anything that can be passed to Iterator.iter(...)
function List:init(...)
	local source = select(1, ...)
	if source ~= nil then
		if is_table(source) and not is_iterable(source) and not Iterator:is_class_of(source) then
			for _, item in ipairs(source) do
				table.insert(self, item)
			end
		else
			for item in Iterator.iter(...) do
				table.insert(self, item)
			end
		end
	end
end

--- Add an item into the list
-- @param item The item to add
function List:push(item)
	table.insert(self, item)
end

--- Remove the item at the end of the list
-- @return The removed item
function List:pop()
	assert(#self >= 1)
	return table.remove(self)
end

--- Remove the first occurence of an item from the list
-- @param item The item to remove
-- @return true if an item was removed, false otherwise
function List:remove(item)
	for id, it in ipairs(self) do
		if it == item then
			table.remove(self, id)
			return true
		end
	end
	return false
end

--- Sort the list
-- @param predicate predicate to use to sort the list
function List:sort(predicate)
	table.sort(self, predicate)
end

--- Return a jlua.iterator over a slice of this list
-- @param start Starting index of the slice
-- @param end_ End index of the slice. If nil, will return the elements until
--             the
-- @return a jlua.iterator over the elements of the slice
function List:slice(start, end_)
	assert(type(start) == "number", "Bad argument")

	local count = #self

	if end_ == nil then
		end_ = count
	end
	assert(type(end_) == "number", "Bad argument")

	assert(start <= count and end_ <= count, "Bad argument")

	local current = start - 1
	return Iterator(function()
		current = current + 1
		if current <= end_ then
			return self[current]
		end
	end)
end

--- Return a jlua.iterator on element of the list, in the reverse order
-- @return The created jlua.iterator
function List:reverse()
	local current = #self + 1
	return Iterator(function()
		current = current - 1
		if current >= 1 then
			return self[current]
		end
	end)
end

--- Create a list containing all elements of the iterator.
-- @return The created list
function Iterator:to_list()
	local result = List()
	for item in self do
		result:push(item)
	end
	return result
end

function List:__iter()
	local count = #self
	local current = 0
	return Iterator(function()
		current = current + 1
		if current <= count then
			return self[current]
		end
	end)
end

return List
