---@class cat
---@field name string
local cat = {}
cat.__index = cat

---@param name string
---@return cat
function cat.new(name)
	local self = setmetatable({}, cat)

	self.name = name

	return self
end

--- executa umas miadas ai
function cat:roar()
	print(self.name .. " has meow!")
end

function cat:getX()
	
end


return cat