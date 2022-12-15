local Object = require("jlua.object")

local Suite = {}

function Suite.init()
	local called
	local Otter = Object:extend()

	function Otter.init(_, name)
		assert_equals(name, "peter")
		called = true
	end

	Otter("peter")
	assert(called)
end

function Suite.no_init()
	local Otter = Object:extend()
	local peter = Otter()
	assert_not_nil(peter)
end

function Suite.init_metatable()
	local peter

	local Otter = Object:extend()

	function Otter:throw_at(target)
		assert_equals(self, peter)
		assert_equals(target, "caiman")
		return "bretzel"
	end

	peter = Otter()
	assert_equals(peter:throw_at("caiman"), "bretzel")
end

function Suite.method_indexing()
	local function destroy() end
	local Otter = Object:extend()
	Otter.destroy = destroy

	assert(Otter.destroy == destroy)
end

function Suite.error_on_method_redefinition()
	local function destroy() end

	local Otter = Object:extend()
	Otter.destroy = destroy

	assert_error_msg_contains('member "destroy" is already defined.', function()
		function Otter.destroy() end
	end)

	assert(Otter.destroy == destroy)
end

function Suite.hide_class_operations_on_instances()
	local Otter = Object:extend()

	local peter = Otter()
	assert_is_nil(peter.extend)
end

function Suite.extend()
	local Otter = Object:extend()
	local SpaceOtter = Otter:extend()
	assert_not_nil(SpaceOtter ~= nil)
end

function Suite.call_base_class_method()
	local peter

	local Otter = Object:extend()

	function Otter:launch()
		assert(self == peter)
		return "bretzel"
	end

	local SpaceOtter = Otter:extend()

	peter = SpaceOtter()
	assert_equals(peter:launch(), "bretzel")
end

function Suite.call_overriden_method()
	local peter

	local Otter = Object:extend()
	function Otter.launch()
		assert(false)
	end

	local SpaceOtter = Otter:extend()
	function SpaceOtter:launch()
		assert(self == peter)
		return "bretzel"
	end

	peter = SpaceOtter()
	assert_equals(peter:launch(), "bretzel")
end

function Suite.call_parent_method_from_override()
	local parent_called, child_called, peter

	local Otter = Object:extend()
	function Otter:launch()
		assert(self == peter)
		assert(not parent_called)
		parent_called = true
	end

	local SpaceOtter = Otter:extend()
	function SpaceOtter:launch()
		assert(self == peter)
		assert(not parent_called)
		assert(not child_called)
		self:parent("launch")
		child_called = true
	end

	peter = SpaceOtter()
	peter:launch()
	assert(parent_called)
	assert(child_called)
end

-- stylua: ignore start
local meta_methods = {
	["__add"] = function(a, b) return a + b end,
	["__call"] = function(a, b) return a(b) end,
	["__concat"] = function(a, b) return a .. b end,
	["__div"] = function(a, b) return a / b end,
	["__eq"] = function(a, b) return a == b end,
	["__le"] = function(a, b) return a <= b end,
	["__lt"] = function(a, b) return a < b end,
	["__mod"] = function(a, b) return a % b end,
	["__mul"] = function(a, b) return a * b end,
	["__pow"] = function(a, b) return a ^ b end,
	["__sub"] = function(a, b) return a - b end,
	["__tostring"] = function(a) return tostring(a) end,
	["__unm"] = function(a) return -a end,
}
-- stylua: ignore end

function Suite.call_base_class_metamethods()
	for method, test_method in pairs(meta_methods) do
		local called, peter, steven

		local Otter = Object:extend()
		Otter[method] = function(a, b)
			assert(a == peter)
			if method ~= "__tostring" and method ~= "__unm" then
				assert_equals(b, steven)
			end
			called = true

			-- because tostring needs to be returned a string, other
			-- metamethods don't give a s**t
			return ""
		end

		local SpaceOtter = Otter:extend()

		peter = SpaceOtter()
		steven = SpaceOtter()
		test_method(peter, steven)
		assert(called)
	end
end

function Suite.call_overriden_metamethod()
	for method, test_method in pairs(meta_methods) do
		local called, peter, steven

		local Otter = Object:extend()
		Otter[method] = function()
			assert(false)
		end

		local SpaceOtter = Otter:extend()
		SpaceOtter[method] = function(a, b)
			assert(a == peter)
			if method ~= "__tostring" and method ~= "__unm" then
				assert(b == steven)
			end
			called = true

			-- because tostring needs to be returned a string, other
			-- metamethods don't give a s**t
			return ""
		end

		peter = SpaceOtter()
		steven = SpaceOtter()
		test_method(peter, steven)
		assert(called)
	end
end

function Suite.index()
	local Otter = Object:extend()

	function Otter.init() end -- to disable index lookup for init

	function Otter.__index(_, key)
		assert_equals(key, "speak_esperanto")
		return function(arg)
			assert_equals(arg, "Hej, samideano")
			return "I can't do that, moron."
		end
	end

	local otter = Otter()
	assert_equals(
		otter.speak_esperanto("Hej, samideano"),
		"I can't do that, moron."
	)
end

function Suite.index_called_first_in_child_class()
	local Otter = Object:extend()

	function Otter.__index()
		assert(false)
	end

	local SpaceOtter = Otter:extend()

	function SpaceOtter.init() end

	function SpaceOtter.__index(_, key)
		assert_equals(key, "speak_esperanto")
		return function(arg)
			assert_equals(arg, "Hej, samideano")
			return "I can't do that, moron."
		end
	end

	local otter = SpaceOtter()
	assert_equals(
		otter.speak_esperanto("Hej, samideano"),
		"I can't do that, moron."
	)
end

function Suite.properties()
	local Otter = Object:extend()
	function Otter.properties.last_name:get()
		return self._last_name or "Otterson"
	end

	function Otter.properties.last_name:set(value)
		self._last_name = value
	end

	local peter = Otter()
	assert_equals(peter.last_name, "Otterson")
	peter.last_name = "McOtter"
	assert_equals(peter.last_name, "McOtter")
	assert_is_nil(rawget(peter, "last_name"))
end

function Suite.set_readonly_property_error()
	local Otter = Object:extend()
	function Otter.properties.last_name.get()
		return "Otterson"
	end

	function Otter.properties.age.set() end

	local peter = Otter()
	assert_error_msg_contains("Setting read-only property last_name", function()
		peter.last_name = "McOtter"
	end)

	assert_error_msg_contains("Getting write-only property age", function()
		print(peter.age)
	end)
end

function Suite.base_class_property_get_set()
	local Otter = Object:extend()
	function Otter.properties.last_name:get()
		return self._last_name or "Otterson"
	end

	function Otter.properties.last_name:set(value)
		self._last_name = value
	end

	local SpaceOtter = Otter:extend()

	local peter = SpaceOtter()
	assert_equals(peter.last_name, "Otterson")
	peter.last_name = "McOtter"
	assert_equals(peter.last_name, "McOtter")
	assert_is_nil(rawget(peter, "last_name"))
end

function Suite.overriden_property_get_set()
	local Otter = Object:extend()
	function Otter.properties.last_name.get()
		return "Otterson"
	end

	function Otter.properties.last_name.set()
		assert(false)
	end

	local setter_called
	local SpaceOtter = Otter:extend()
	function SpaceOtter.properties.last_name.get()
		return "Ottersonson"
	end

	function SpaceOtter.properties.last_name.set(_, value)
		assert_equals(value, "McOtterson")
		setter_called = true
	end

	local peter = SpaceOtter()
	assert_equals(peter.last_name, "Ottersonson")
	peter.last_name = "McOtterson"
	assert(setter_called)
end

function Suite.error_on_bad_property_key_definition()
	local Otter = Object:extend()

	assert_error_msg_contains(
		"can only define get or set method on properties.",
		function()
			function Otter.properties.last_name.gut_fuck_i_made_a_typo() end
		end
	)
end

function Suite.error_on_property_redefinition()
	local Otter = Object:extend()
	function Otter.properties.last_name.get() end

	function Otter.properties.last_name.set() end

	assert_error_msg_contains("getter already defined on property.", function()
		function Otter.properties.last_name.get() end
	end)

	assert_error_msg_contains("setter already defined on property.", function()
		function Otter.properties.last_name.set() end
	end)
end

function Suite.is_class_of()
	local Otter = Object:extend()
	local SpaceOtter = Otter:extend()
	local Caiman = Object:extend()

	local otter = SpaceOtter()

	assert(not SpaceOtter:is_class_of(nil))
	assert(not SpaceOtter:is_class_of(0))
	assert(not SpaceOtter:is_class_of("otter"))
	assert(SpaceOtter:is_class_of(otter))
	assert(Otter:is_class_of(otter))
	assert(Object:is_class_of(otter))
	assert(not Caiman:is_class_of(otter))
end

function Suite.wrap()
	local Otter = Object:extend()

	function Otter.speak()
		return "kweekweekweekweek"
	end

	local otter_skeleton = {}
	local otter = Otter:wrap(otter_skeleton)

	assert(Otter:is_class_of(otter))
	assert_equals(otter:speak(), "kweekweekweekweek")
	assert_equals(otter, otter_skeleton)
end
return Suite
