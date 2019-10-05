local Widget = require "widgets/widget"
local Image = require "widgets/image"

local ThreeSlice = Class(Widget, function(self, atlas, cap, filler)
    Widget._ctor(self, "ThreeSlice")
    self.inst.entity:AddImageWidget()

    self.atlas = atlas
    self.filler = filler
    self.cap = cap

	self.root = self:AddChild(Widget("root"))
    self.startcap = self.root:AddChild(Image(atlas, cap))
    self.endcap = self.root:AddChild(Image(atlas, cap))
    self.parts = {}
end)


function ThreeSlice:SetImages(atlas, cap, filler)
    self.atlas = atlas
    self.filler = filler
    self.cap = cap

	self.startcap:SetTexture(self.atlas, self.cap)
	self.endcap:SetTexture(self.atlas, self.cap)
	
	for k,v in pairs(self.parts) do
		v:SetTexture(self.atlas, self.filler)
	end
end


function ThreeSlice:RemoveParts()
	for k,v in pairs(self.parts) do
		v:Kill()
	end
	self.parts = {}
end


function ThreeSlice:Flow(width, height, horizontal)	
	self:RemoveParts()
	
	local dist = horizontal and width or height
	local capw, caph = self.startcap:GetSize()
	local capsize = horizontal and capw or caph
	local fill_dist = math.max(0, dist - capsize*2)
	
	if fill_dist > 0 then
		local cap_d = fill_dist/2 + capsize/ 2
		
		if horizontal then
			self.startcap:SetPosition(cap_d,0, 0)
			self.endcap:SetPosition(-cap_d,0, 0)
			self.endcap:SetScale(-1,1,1)
		else
			self.startcap:SetPosition(0, cap_d, 0)
			self.endcap:SetPosition(0, -cap_d, 0)
			self.endcap:SetScale(1,-1,1)
		end

		local filler = self.root:AddChild(Image(self.atlas, self.filler))
		
		local fillerw, fillerh = filler:GetSize()
		local filler_size = horizontal and fillerw or fillerh
		
		if horizontal then
			self.root:SetScale(1,height/fillerh,1)
		else
			self.root:SetScale(width/fillerw,1,1)
		end


		local num_filler = math.ceil(fill_dist / filler_size)
		local filler_scale = fill_dist / (num_filler*filler_size) 
		
		for k = 1, num_filler do
			if filler == nil then
				filler = self.root:AddChild(Image(self.atlas, self.filler))
			end
			
			if horizontal then
				filler:SetScale(filler_scale, 1, 1)
				filler:SetPosition(-fill_dist/2 + filler_scale*filler_size*(k-1+.5),0,0 )
			else
				filler:SetScale(1, filler_scale, 1)
				filler:SetPosition(0, -fill_dist/2 + filler_scale*filler_size*(k-1+.5),0 )
			end
			table.insert(self.parts, filler)
			filler = nil
		end
	else
		if horizontal then
			self.startcap:SetPosition((capsize)/2, 0, 0)
			self.endcap:SetPosition(-(capsize)/2, 0, 0)
			self.endcap:SetScale(-1,1,1)
		else
			self.startcap:SetPosition(0, (capsize)/2, 0)
			self.endcap:SetPosition(0, -(capsize)/2, 0)
			self.endcap:SetScale(1,-1,1)
		end
	end
end

return ThreeSlice
