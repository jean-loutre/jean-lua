--- Iterator, with map / filter functions and the like
-- @module jlua.iterator
local Object = require("jlua.object")
local is_callable = require("jlua.type").is_callable
local is_iterable = require("jlua.type").is_iterable
local is_number = require("jlua.type").is_number
local is_table = require("jlua.type").is_table
local unpack = unpack or table.unpack

local Iterator = Object:extend("jlua.iterator")

--- Initialize an iterator.
--
-- Can be initialized with a statefull iterator closure, or a stateless iterator
-- iterator. In the later case, invariant and control are the states needed by
-- the stateless iterator. For example, you can call :
--     Iterator(ipairs({"some", "list"}))
--
-- @param iterator  The iterator function.
-- @param invariant Invariant state passed to the iterator function.
-- @param control   Initial control variable passed to the iterator function.
function Iterator:init(iterator, invariant, control)
	assert(is_callable(iterator), "Bad argument")
	if invariant ~= nil then
		self._next = function()
			local item = { iterator(invariant, control) }
			control = unpack(item)
			return unpack(item)
		end
	else
		self._next = iterator
	end
end

--- Return an iterator object from a value.
-- If the value is an iterator, return the iterator itself. If the value is a
-- table with an __iter method, return an iterator over the function returned
-- by this __iter method, if it's a table, return an iterator over the
-- key / values of the given table, else try to construct an iterator with the
-- given iter method and states (see Iterator:init).
--
-- @param iterable  The iterator, iterable or iterator function.
-- @param invariant Invariant state passed to the iterator function, or nil
--                  if not applicable.
-- @param control   Initial control variable passed to the iterator function
--                  or nil if not applicable.
--
-- @return The created iterator, or iterable itself if it's already an
--         Iterator.
function Iterator.from(iterable, invariant, control)
	assert(table ~= Iterator, "You're calling Iterator:from, use Iterator.from.")
	if Iterator:is_class_of(iterable) then
		return iterable
	elseif is_iterable(iterable) then
		return Iterator(iterable:__iter())
	elseif is_table(iterable) then
		return Iterator(pairs(iterable))
	end

	return Iterator(iterable, invariant, control)
end

--- Return an iterator yielding all values of a lua table.
--
-- Equivalent to ipairs, but without returning the indices.
--
-- @param table The table to iterate.
--
-- @return An iterator upon elements in the table.
function Iterator.from_values(table)
	assert(is_table(table), "Bad argument")
	assert(table ~= Iterator, "You're calling Iterator:from_values, use Iterator.from_values.")
	local id = 0
	return Iterator(function()
		id = id + 1
		return table[id]
	end)
end

--- Return the next element of the iterator.
function Iterator:__call()
	return self._next()
end

--- Return true if any element in the iterator matches the given predicate.
--
-- If no predicate is given, return true if the iterator contains at least
-- one element.
--
-- @param predicate The predicate function taking iterator elements as
--                  parameter and returning a boolean, or nil.
--
-- @return True if an element matches predicate, false otherwise.
function Iterator:any(predicate)
	assert(predicate == nil or is_callable(predicate), "Bad argument")
	return self:first(predicate) ~= nil
end

--- Chain this iterator with elements of given iterable.
--
-- @param iterable An iterator, object with an __iter method or lua iterator.
--                 Will be passed to Iterator.from method and the result will
--                 be chained to current iterator.
--
-- @return An iterator yielding element of self Iterator with element of given
--         iterable.
function Iterator:chain(iterable, ...)
	local iterate_next = false
	local next_iterator = Iterator.from(iterable, ...)
	assert(next_iterator ~= self)
	return Iterator(function()
		if not iterate_next then
			local item = { self() }
			if item[1] ~= nil then
				return unpack(item)
			end
		end
		iterate_next = true
		return next_iterator()
	end)
end

--- Count number of element matching the given predicate.
--
-- If no predicate is given, count all elements in the iterator.
--
-- @param predicate The predicate function taking iterator elements as
--                  parameter and returning a boolean, or nil.
--
-- @return Number of elements counted
function Iterator:count(predicate)
	assert(predicate == nil or is_callable(predicate), "Bad argument")
	local count = 0
	while true do
		local item = { self() }
		if item[1] == nil then
			break
		end

		if predicate == nil or predicate(unpack(item)) then
			count = count + 1
		end
	end

	return count
end

--- Return an iterator yielding elements matching the given predicate.
--
-- @param predicate The predicate function taking iterator elements as
--                  parameter and returning a boolean.
--
-- @return The filtered iterator
function Iterator:filter(predicate)
	assert(is_callable(predicate), "Bad argument")
	return Iterator(function()
		return self:first(predicate)
	end)
end

--- Return the first element in the iterator matching the given predicate.
--
-- If no predicate is given, return the first element of the iterator.
--
-- @param predicate The predicate function taking iterator elements as
--                  parameter and returning a boolean, or nil.
--
-- @return The first element matching given predicate
function Iterator:first(predicate)
	assert(predicate == nil or is_callable(predicate), "Bad argument")
	local item
	repeat
		item = { self() }
	until unpack(item) == nil or predicate == nil or predicate(unpack(item))
	return unpack(item)
end

--- Return a new iterator yielding results of applying a function to all items.
--
-- @param mapper The function to apply to items.
--
-- @return The iterator of mapped elements.
function Iterator:map(mapper)
	assert(is_callable(mapper), "Bad argument")
	return Iterator(function()
		local item = { self() }
		if item[1] == nil then
			return nil
		end
		return mapper(unpack(item))
	end)
end

--- Returns elements of the nested iterator of an iterator of iterators.
--
-- @return An iterator of the elements of the iterators in this iterator.
function Iterator:flatten()
	local current_iterator = self()
	return Iterator(function()
		while current_iterator ~= nil do
			local item = { current_iterator() }
			if item[1] ~= nil then
				return unpack(item)
			end
			current_iterator = self()
		end
	end)
end

--- Skip the first count elements of an iterator.
--
-- @param count Number of elements to skip.
--
-- @return An iterator skipping the first count elements.
function Iterator:skip(count)
	assert(is_number(count), "Bad argument")
	return Iterator(function()
		while count > 0 do
			count = count - 1
			if self() == nil then
				return nil
			end
		end

		return self()
	end)
end

--- Return the first elements of an iterator.
--
-- @param count Number of elements to take.
--
-- @return An iterator yielding only the first n elements of this iterator.
function Iterator:take(count)
	assert(is_number(count), "Bad argument")
	return Iterator(function()
		if count > 0 then
			count = count - 1
			return self()
		end
	end)
end

return Iterator
