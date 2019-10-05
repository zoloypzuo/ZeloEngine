local Widget = require "widgets/widget"

local Grid = Class(Widget, function(self)
    Widget._ctor(self, "GRID")
    self.h_offset = 100
    self.v_offset = 100
    self.items_by_coords = {}
    self.rows = 0
    self.cols = 0
    self.num_children = 0
end)

function Grid:SetLooping(h, v)
	self.h_loop = h
	self.v_loop = v
	self:DoFocusHookups()
end

function Grid:InitSize(c,r, coffset, roffset)
	self:Clear()

	self.h_offset = coffset
	self.v_offset = roffset
	self.rows = r
	self.cols = c
	self.items_by_coords = {}
	for k = 1, r do
		local col = {}
		for k = 1,c do
			table.insert(col, nil)
		end
		table.insert(self.items_by_coords, col)
	end
end

function Grid:Clear()
	for k,v in pairs(self.items_by_coords) do
		for k,v in pairs(v) do
			v:Kill()
		end
	end
    self.items_by_coords = {}
    self.num_children = 0
end

function Grid:DoFocusHookups()
	for c = 1, self.cols do
		for r = 1, self.rows do
			local item = self:GetItemInSlot(c,r)
			if item then
				item:ClearFocusDirs()
				local up = r > 1 and self:GetItemInSlot(c,r-1)
				local down = r < self.rows and self:GetItemInSlot(c,r+1) 
				local left = c > 1 and self:GetItemInSlot(c-1,r)
				local right = c < self.cols and self:GetItemInSlot(c+1,r)

				if self.h_loop then
					if c == 1 then left = self:GetItemInSlot(self.cols,r) end
					if c == self.cols then right = self:GetItemInSlot(1,r) end
				end
				
				if self.v_loop then
					if r == 1 then up = self:GetItemInSlot(c,self.rows) end
					if r == self.rows then down = self:GetItemInSlot(c,1) end
				end

				if up then item:SetFocusChangeDir(MOVE_UP, up) end
				if down then item:SetFocusChangeDir(MOVE_DOWN, down) end
				if left then item:SetFocusChangeDir(MOVE_LEFT, left) end
				if right then item:SetFocusChangeDir(MOVE_RIGHT, right) end
			end
		end
	end	

end

function Grid:GetRowsInCol(c)
	if c <= self.cols then
		for r = self.rows, 1, -1 do
			if self.items_by_coords[r][c] ~= nil then
				return r
			end
		end
	end
	return 0
end

function Grid:SetFocus(c, r)
	r = r or 1
	c = c or 1

	if c < 0 then
		c = c + self.cols + 1
	end

	if r < 0 then
		r = r + self.rows + 1
	end

	local item = self:GetItemInSlot(c, r)
	if item then
		item:SetFocus()
	end
	
end

function Grid:GetItemInSlot(c,r)
	
	if r > self.rows or c > self.cols then return end

	if not self.items_by_coords[r] then
		return
	end

	return self.items_by_coords[r][c]
end


function Grid:AddItem(widget, c, r)

	
	if r > self.rows or c > self.cols then return end

	local old_item = self:GetItemInSlot(c,r)
	
	if old_item then
		old_item:Kill()
		self.items_by_coords[r][c] = nil
	end

	self:AddChild(widget)

	self.items_by_coords[r][c] = widget
	
	widget:SetPosition(Vector3(self.h_offset*(c-1), self.v_offset*(r-1), 0))

	self:DoFocusHookups()
	return widget
end


return Grid