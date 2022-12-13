--- Base class for class model
-- Allow to create very simple classes that only support single inheritance.

--- @class jlua.Class
--- @field properties any
--- Metatable for classes
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

local meta_methods_set = {}
for _, name in ipairs(meta_methods) do
	meta_methods_set[name] = true
end

-- Proxy forbidding definition of key different of get or set, and
-- checking for redefinitions
local PropertyGuard = {}

function PropertyGuard:__newindex(key, value)
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
local PropertiesGuard = {}

function PropertiesGuard:__index(key)
	if self._properties[key] == nil then
		self._properties[key] = {}
	end
	return setmetatable({ _property = self._properties[key] }, PropertyGuard)
end

function PropertiesGuard:__newindex(key, value)
	self._properties[key] = value
end

function Class:__index(key)
	local definition = self._definition

	if key == "properties" then
		return setmetatable({
			_properties = definition._properties,
		}, PropertiesGuard)
	end

	return definition._metatable[key] or definition._parent and definition._parent._metatable[key] or Class[key]
end

function Class:__newindex(key, value)
	local definition = self._definition

	if key == "__index" then
		if definition._index then
			error('metamethod "' .. key .. '" is already defined.')
		end
		definition._index = value
	elseif key == "__newindex" then
		if definition._newindex then
			error('metamethod "' .. key .. '" is already defined.')
		end
		definition._newindex = value
	elseif meta_methods_set[key] then
		if definition._defined_metamethods[key] then
			error('metamethod "' .. key .. '" is already defined.')
		end
		definition._metatable[key] = value
		definition._defined_metamethods[key] = true
	else
		if rawget(definition._metatable, key) ~= nil then
			error('member "' .. key .. '" is already defined.')
		end
		definition._metatable[key] = value
	end
end

--- Class "constructor", creating a new object.
--
-- Parameters passed to this method will be forwarded to the "init" method
-- of the class that is constructed.
--
-- @return A new instance of the class
function Class:__call(...)
	local instance = setmetatable({}, self._definition._metatable)
	instance:init(...)

	return instance
end

-- Override the "inheritance model" of lua to resolve in the correct order :
-- while the field is not found, for each class of the hierarchy
--   search raw fields of current class
--   search properties of current class
--   call __index override of current class
local function class_index(class_definition, instance, key)
	while class_definition ~= nil do
		local raw_value = rawget(class_definition._metatable, key)
		if raw_value then
			return raw_value
		end

		local property = rawget(class_definition, "_properties")[key]
		if property then
			if not property.get then
				error("Getting write-only property " .. key)
			end
			return property.get(instance)
		end

		local index_override = rawget(class_definition, "_index")
		if index_override then
			return index_override(instance, key)
		end

		class_definition = class_definition._parent
	end
end

local function class_newindex(class_definition, instance, key, value)
	while class_definition ~= nil do
		local property = class_definition._properties[key]

		if property then
			if not property.set then
				error("Setting read-only property " .. key)
			end
			property.set(instance, value)
			return
		end

		local newindex_override = rawget(class_definition, "_newindex")
		if newindex_override then
			newindex_override(instance, key, value)
			return
		end

		class_definition = class_definition._parent
	end

	rawset(instance, key, value)
end

--- Create a new child class of this class.
--
-- To create a base class, use Object:extend()
--
-- @param name       A unique name of the class. It will be returned when
--                   calling getmetatable, because of the use of __metatable
--                   field to lock metatable on created instance. If nil,
--                   tostring(metatable) will be used instead.
-- @param metatable  The metatable that will be set on instances of this class.
-- @param properties A table of { property_name = { get = getter(),
--                   set = setter() } entries.
--
-- @return jlua.Class The newly created class
function Class:extend(name)
	local parent_definition = self._definition
	local parent_metatable = parent_definition._metatable
	local metatable = {}

	local definition = {
		_defined_metamethods = {},
		_inheritors = {},
		_metatable = metatable,
		_parent = parent_definition,
		_properties = {},
	}

	for _, method in ipairs(meta_methods) do
		metatable[method] = metatable[method] or parent_metatable[method]
	end

	function metatable.__index(instance, key)
		return class_index(definition, instance, key)
	end

	function metatable.__newindex(instance, key, value)
		return class_newindex(definition, instance, key, value)
	end

	function metatable.parent(instance, method_name, ...)
		return class_index(parent_definition, instance, method_name)(instance, ...)
	end

	name = name or tostring(metatable)
	metatable.__metatable = name

	local it = definition
	while it ~= nil do
		it._inheritors[metatable.__metatable] = true
		it = it._parent
	end

	return setmetatable({
		_definition = definition,
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
	return self._definition._inheritors[metatable]
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
	return setmetatable(object, self._definition._metatable)
end

--- @class jlua.Object:jlua.Class
return setmetatable({
	_definition = {
		_defined_metamethods = {},
		_inheritors = {},
		_metatable = {
			init = function() end,
		},
		_properties = {},
	},
}, Class)
