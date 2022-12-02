# Object

The jlua.object module contains definition of an Object class, that can
be extended to create new classes. It supports single inheritance, method and
metamethod overriding, and properties getter and setters.

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

### Calling Parent Methods

To call a parent method in a child class, use the super() method defined on
classes instances :

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
