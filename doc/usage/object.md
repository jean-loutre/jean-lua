# Object

The jlua.object module contains definition of an Object class, that can
be extended to create new classes. It supports single inheritance, methods,
properties with getters and setters and metamethod overriding, including
__index and __newindex.

## Defining a new class

A new class can be created by extending from another one. Derived class will
inherit the methods, metamethods and properties of it's parent. If your class
has no base class, extend the Object class.

```lua
local Object = require("jlua.object")

local Otter = Object:extend()
local SpaceOtter = Otter:extend()

```

## Constructors

Objects are constructed by calling the class. You can give arguments to the
constructor, they will be forwarded to the `init` method of the class, if it's
defined.

```lua
local Object = require("jlua.object")

local Otter = Object:extend()

function Otter:init(name)
	print("My name is " .. name)
end

local peter = Otter("Peter") -- -> "My name is Peter"
```

!!! warning

	If you override a base class init method, don't forget to
	[call the parent init method](#calling-parent-methods) by calling
	`self:super("init", ...)`.
 

## Methods

### Method Definition

Methods can be defined either by adding them on the class metatable before
calling the extend() method, or afterwards, by defining them on the class,
like you do on regular lua tables :

```lua
local Object = require("jlua.object")

local Otter = Object:extend({
	name = function()
		return "Peter"
	end
})

function Otter:last_name()
	return "Otterson"
end
```

!!! warning

	Defining twice the same method will assert. This is done to prevent unwanted
	method overwrites. If you really need to overwrite a method, you can do it
	by using ```rawset``` like this:

	```
	rawset(Otter._definition._metatable, "last_name", function() [...] end)
	```

### Calling Parent Methods

To call a parent method in a child class, use the super() method defined on
classes instances, with the method name as the first argument, arguments to
forward to the parent method next :

```lua
local Object = require("jlua.object")

local Otter = Object:extend()

function Otter:throw(distance)
	return "throwing otter at " .. distance .. "m"
end

local SpaceOtter = Otter:extend()
local SpaceOtter:throw(distance)
	self:super("throw", distance + 100)
end

local peter = SpaceOtter()
peter:throw_at(33) -- -> Throwing otter at 133m
```

## Properties

Properties are defined using the "properties" field of classes, accessing
the wanted property on it and defining a get or a set method :

```lua
local Object = require("jlua.object")

local Otter = Object:extend()

function Otter:init()
	self._age = 10
end

function Otter.properties.age:get() -- Notice the colon before get()
	return self._age
end

function Otter.properties.age:set(value) -- Notice the colon before set()
	self._age = value
end

local peter = Otter()
print(peter.age) -- 10
peter.age = 40
print(peter.age) -- 40
```

You can define properties with only a getter, or only a setter. You can define
a property with no getter nor setter, but in this case it will only be defined
in your head and will have no effect on the running program.

!!! warning

	Setting a property with no setter defined, or getting a property with no
	getter will raise an error at runtime. There is no default behavior for
	getters / setters once one of them is defined.

!!! warning

	Redefining a getter or a setter that was already defined on a property will
	raise an error. Same as for methods, this was made to prevent erroneous
	method overwriting.
