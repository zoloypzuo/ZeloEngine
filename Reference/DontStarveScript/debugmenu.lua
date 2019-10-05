require "class"

local MenuOption = Class(function(self, str)
	self.str = str
end)

function MenuOption:Left(menu)
end

function MenuOption:Right()
end

function MenuOption:Accept()
end

function MenuOption:Cancel(menu)
	return menu:Pop()
end


function MenuOption:__tostring()
	if type(self.str) == "string" then return self.str end

	if type(self.str) == "function" then return self.str() end

	return "???"
end

-----------------------------

local DoAction = Class(MenuOption, function(self, str, fn)
	MenuOption._ctor(self, str)
	self.fn = fn
end)

function DoAction:Accept(menu)
	self.fn(menu)
end

-----------------------------


local Submenu = Class(MenuOption, function(self, str, options, name)
	self.str = str
	self.name = name
	self.options = options
end)

function Submenu:Accept(menu)
	local opts = {}
	for k,v in pairs(self.options) do table.insert(opts, v) end

	table.insert(opts, DoAction("Back", function(menu) menu:Pop() end))
	menu:PushOptions(opts, self.name)
end

function Submenu:__tostring()
	return self.str .. "..."
end

-----------------------------

local NumericToggle = Class(MenuOption, function(self, str, min, max, getfn, setfn, step)
	MenuOption._ctor(self, str)
	self.step = step or 1
	self.min = min
	self.max = max
	self.setfn = setfn
	self.getfn = getfn
end)

function NumericToggle:__tostring()
	return self.str .. "    [ " .. tostring(self.getfn()) .. " ]"
end

function NumericToggle:Left(menu)
	local val = self.getfn()
	if val > self.min then
		self.setfn(math.max(self.min, val - self.step))
	end	
end

function NumericToggle:Right(menu)
	local val = self.getfn()
	if val < self.max then
		self.setfn(math.min(self.max, val + self.step))
	end	
end

-----------------------------


local CheckBox = Class(MenuOption, function(self, str, getfn, setfn)
	MenuOption._ctor(self, str)

	self.setfn = setfn
	self.getfn = getfn
end)

function CheckBox:__tostring()
	return self.str .. "    [" .. (self.getfn() and "true" or "false") .. "]"
end

function CheckBox:Left(menu)
	self.setfn(false)
end

function CheckBox:Right(menu)
	self.setfn(true)
end


-----------------------------

local TextMenu = Class(function(self, name)
	self.title = name or "MENU"
	self.optionsstack = {}
	self.cursor_index_stack = {}
	self.name_stack = {}
	self.index = 1
end)

function TextMenu:Create()
	
end

function TextMenu:__tostring()
	local t = {}
	table.insert(t, "***** ")
	table.insert(t, self.title)
	table.insert(t, " *****\n")

	
	if #self.optionsstack > 0 then
		
		
		for k,v in pairs(self.optionsstack[#self.optionsstack]) do
			local pre = "     "
			if k == self.index then
				pre = "   >"
			end

			table.insert(t, pre)
			table.insert(t, tostring(v))
			table.insert(t, "\n")
		end
	end
	return table.concat(t)
end


function TextMenu:PushOptions(options, name)
	
	table.insert(self.name_stack, self.name)
	self.name = name or self.name

	if #self.optionsstack > 0 then
		table.insert(self.cursor_index_stack, self.index)
	end
	self.index = 1
	table.insert(self.optionsstack, options)
end

function TextMenu:Right()
	local option = self:GetOption()
	if option then
		option:Right(self)
	end
end

function TextMenu:Left()
	local option = self:GetOption()
	if option then
		option:Left(self)
	end
end

function TextMenu:Cancel()
	local option = self:GetOption()
	if option then
		return option:Cancel(self)
	end
end

function TextMenu:Accept()
	local option = self:GetOption()
	if option then
		option:Accept(self)
	end
end

function TextMenu:GetOption()
	if #self.optionsstack > 0 then
		return self.optionsstack[#self.optionsstack][self.index]
	end
end

function TextMenu:Up()
	self.index = self.index - 1
	if self.index == 0 then
		if #self.optionsstack[#self.optionsstack] > 0 then
			self.index = #self.optionsstack[#self.optionsstack]
		else
			self.index = 1
		end
	end
end

function TextMenu:Down()
	if #self.optionsstack > 0 then
		self.index = self.index + 1
		if self.index > #self.optionsstack[#self.optionsstack] then
			self.index = 1
		end
	end
end

function TextMenu:AtRoot()
	return #self.optionsstack <= 1
end

function TextMenu:Pop()
	if #self.optionsstack > 1 then
		table.remove(self.optionsstack)
		
		if #self.cursor_index_stack > 0 then
			self.index = table.remove(self.cursor_index_stack)
		end

		if #self.name_stack > 0 then
			self.name = table.remove(self.name_stack)
		end
		return true
	end
end


--[[
local menu = TextMenu()

local num = 5
local godmode = true
quit = false

sub = {
	NumericToggle("number", 0, 10, function() return num end, function(v) num = v end),
	CheckBox("god mode", function() return godmode end, function(v) godmode = v end),
	DoAction("Back", function(menu) menu:Pop() end),
}

root = {
	Submenu("sub", sub, "SUBMENU"),
	DoAction("Quit", function(menu) quit = true end),
}

menu:PushOptions(root)
menu:Right()
menu:Left()
menu:Left()
menu:Right()
menu:Down()
menu:Right()
print(menu)
--]]

return {
	Submenu = Submenu,
	DoAction = DoAction,
	NumericToggle = NumericToggle,
	CheckBox = CheckBox,
	TextMenu = TextMenu
}

