--- Base class for class model
-- Allow to create very simple classes that only support single inheritance.

-- @module gilbert.object
-- Metatable for classes
local Class = {}
Class.__index = Class

local meta_methods = {
	"__add",
	"__call",
	"__concat",
	"__div",
	"__eq",
	"__le",
	"__lt",
	"__mod",
	"__mul",
	"__pow",
	"__sub",
	"__tostring",
	"__unm",
}

-- Proxy forbidding definition of key different of get or set, and
-- checking for redefinitions
local PropertyProxy = {}

function PropertyProxy:__newindex(key, value)
	if key == "get" then
		assert(self._property.get == nil, "getter already defined on property.")
		self._property.get = value
	elseif key == "set" then
		assert(self._property.set == nil, "setter already defined on property.")
		self._property.set = value
	else
		error("can only define get or set method on properties.")
	end
	rawset(self, key, value)
end

-- Proxy automatically adding keys on requested indices
-- to allow to directly declare a property like :
-- function Otter:properties:last_name:get()
-- end
local PropertiesProxy = {}

function PropertiesProxy:__index(key)
	if self._properties[key] == nil then
		self._properties[key] = {}
	end
	return setmetatable({ _property = self._properties[key] }, PropertyProxy)
end

function PropertiesProxy:__newindex(key, value)
	self._properties[key] = value
end

function Class:__index(key)
	if key == "properties" then
		return self.__gb_properties
	end

	return Class[key] or self.__gb_metatable[key]
end

function Class:__newindex(key, value)
	if key == "__index" then
		key = "__gb_index"
	end

	if rawget(self.__gb_metatable, key) ~= nil then
		error('member "' .. key .. '" is already defined.')
	end
	self.__gb_metatable[key] = value
end

--- Class "constructor", creating a new object.
--
-- Parameters passed to this method will be forwarded to the "init" method
-- of the class that is constructed.
--
-- @return A new instance of the class
function Class:__call(...)
	local instance = setmetatable({}, self.__gb_metatable)
	instance:init(...)

	return instance
end

--- Create a new child class of this class.
--
-- To create a base class, use Object:extend()
--
-- @param metatable The metatable that will be set on instances of this class.
-- @param properties A table of { property_name = { get = getter(),
--                   set = setter() } entries.
--
-- @return The newly created class
function Class:extend(metatable, properties)
	metatable = metatable or {}
	properties = properties or {}

	for _, method in ipairs(meta_methods) do
		metatable[method] = metatable[method] or self.__gb_metatable[method]
	end

	function metatable.parent(instance, method_name, ...)
		self.__gb_metatable[method_name](instance, ...)
	end

	local function __gb_get_property(name)
		local prop = properties[name]
		if prop ~= nil then
			return prop
		end

		return self.__gb_get_property(name)
	end

	function metatable.__index(instance, key)
		local property = __gb_get_property(key)
		if property then
			if not property.get then
				error("Getting write-only property " .. key)
			end
			return property.get(instance)
		end

		return rawget(metatable, key)
			or (metatable.__gb_index and metatable.__gb_index(instance, key))
			or metatable[key]
	end

	function metatable.__newindex(instance, key, value)
		local property = __gb_get_property(key)
		if property then
			if not property.set then
				error("Setting read-only property " .. key)
			end
			property.set(instance, value)
			return
		end

		rawset(instance, key, value)
	end

	setmetatable(metatable, self.__gb_metatable)

	return setmetatable({
		__gb_get_property = __gb_get_property,
		__gb_metatable = metatable,
		__gb_properties = setmetatable({
			_properties = properties,
		}, PropertiesProxy),
	}, Class)
end

--- Return true if the given object is an instance of this class.
--
-- @param object The object to check.
--
-- @return true if object is an instance of self or a parent of self.
function Class:is_class_of(object)
	if object == nil or type(object) ~= "table" then
		return false
	end

	local metatable = getmetatable(object)
	while metatable ~= nil do
		if self.__gb_metatable == metatable then
			return true
		end
		metatable = getmetatable(metatable)
	end

	return false
end

--- Create an instance of this class by setting it's metatable.
--
-- This will not call the init function, and can be used to initialize an
-- object directly from it's fields, or make a table behave like a list or
-- map, for example.
--
-- @param object The table to set metetable
--
-- @return true if object is an instance of self or a parent of self
function Class:wrap(object)
	return setmetatable(object, self.__gb_metatable)
end

local object__gb_metatable = {
	init = function() end,
	__gb_get_property = function() end,
}
object__gb_metatable.__index = object__gb_metatable

return setmetatable({
	__gb_metatable = object__gb_metatable,
	__gb_properties = {},
}, Class)
