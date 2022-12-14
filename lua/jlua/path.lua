--- Iterator, with map / filter functions and the like
-- @module jlua.iterator
local Iterator = require("jlua.iterator")
local List = require("jlua.list")
local Object = require("jlua.object")
local is_string = require("jlua.type").is_string

local Path = Object:extend("jlua.path")

local separator = "/"

--- Initialize a path
-- @param source Path as a string
function Path:init(source)
	self._parts = List()
	self._is_absolute = false
	if source ~= nil then
		if Path:is_class_of(source) then
			self._parts = List(source._parts)
			self._is_absolute = source._is_absolute
		else
			assert(is_string(source), "Bad argument")
			self._is_absolute = source:sub(1, 1) == "/"
			for part in string.gmatch(source, "([^" .. separator .. "]+)") do
				self._parts:push(part)
			end
		end
	end
end

--- Return the basename of this path
function Path.properties.basename:get()
	return self._parts[#self._parts]
end

--- Return the extension of the file
function Path.properties.extension:get()
	return self.basename:match("%.(%w+)$") or ""
end

--- True if the path is absolute
function Path.properties.is_absolute:get()
	return self._is_absolute
end

--- Return parents of this path
function Path.properties.parents:get()
	local count = #self._parts

	return Iterator(function()
		count = count - 1

		if count <= 0 then
			return nil
		end

		return Path:wrap({
			_is_absolute = self._is_absolute,
			_parts = self._parts:take(count):to_list(),
		})
	end)
end

--- Concatenate two paths.
--
-- An error will be raised if the right path is absolute.
--
-- @param right Path to concatenate, as a string or a Path instance.
--
-- @return A new instance of Path representing the concatenated path.
function Path:__div(right)
	if is_string(right) then
		right = Path(right)
	end
	assert(Path:is_class_of(right), "Bad argument")
	assert(
		not right.is_absolute,
		"Trying to concatenate an absolute path to another"
	)
	return Path:wrap({
		_is_absolute = self._is_absolute,
		_parts = self._parts:iter():chain(right._parts):to_list(),
	})
end

--- Returns the string representation of this path
function Path:__tostring()
	if not self._is_absolute then
		return self._parts:concat(separator)
	end

	return separator .. self._parts:concat(separator)
end

--- Open the file this path points to.
--
-- @param The mode to pass to io.open
--
-- @return A context manager, that will call the inner function with the
-- 		   opened file handle.
function Path:open(mode)
	-- TODO: Do something with coroutines for context managers
	return {
		__enter = function(context_manager)
			local handle, err_message, err_code = io.open(tostring(self), mode)
			if handle == nil then
				error(
					"Error while opening file "
						.. tostring(self)
						.. " : "
						.. err_message
						.. "("
						.. err_code
						.. ")"
				)
			end
			context_manager._handle = handle
			return handle
		end,
		__exit = function(context_manager)
			context_manager._handle:close()
		end,
	}
end

--- Get the current path relative to given path.
--
-- @param right The path to which make this path relative.
--
-- @return A new instance of Path
function Path:relative_to(right)
	if is_string(right) then
		right = Path(right)
	end
	assert(Path:is_class_of(right))
	assert(self._is_absolute == right._is_absolute)

	local idx = 1
	while self._parts[idx] == right._parts[idx] do
		idx = idx + 1
	end

	return Path:wrap({
		_is_absolute = false,
		_parts = right._parts
			:skip(idx - 1)
			:map(function()
				return ".."
			end)
			:chain(self._parts:skip(idx - 1))
			:to_list(),
	})
end

--- Return true if this path is a child of the given path
--
-- Parameters
-- ----------
-- parent : Path
--     Parent path to check
--
-- Returns
-- -------
-- bool
--     True if self is child of parent, false otherwise
function Path:is_child_of(parent)
	local parent_as_string = tostring(parent)
	return string.sub(tostring(self), 1, string.len(parent_as_string))
		== parent_as_string
end

return Path
