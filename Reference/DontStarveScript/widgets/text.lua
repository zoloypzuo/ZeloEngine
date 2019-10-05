local Widget = require "widgets/widget"

local Text = Class(Widget, function(self, font, size, text)
    Widget._ctor(self, "Text")
   
    self.inst.entity:AddTextWidget()
    
    self.inst.TextWidget:SetFont(font)
    self.inst.TextWidget:SetSize(size)

	if text then
		self:SetString( text )
	end
end)

function Text:__tostring()
    return string.format("%s - %s", self.name, self.string or "")
end


function Text:SetColour(r,g,b,a)
    if type(r) == "number" then
        self.inst.TextWidget:SetColour(r, g, b, a)
    else
        self.inst.TextWidget:SetColour(r[1], r[2], r[3], r[4])
    end
end

function Text:SetHorizontalSqueeze( squeeze )
    self.inst.TextWidget:SetHorizontalSqueeze(squeeze)
end

function Text:SetAlpha(a)
    self.inst.TextWidget:SetColour(1,1,1, a)
end

function Text:SetFont(font)
    self.inst.TextWidget:SetFont(font)
end

function Text:SetSize(sz)
	if LOC then
		sz = sz * LOC.GetTextScale()
	end
    self.inst.TextWidget:SetSize(sz)
    self.size = sz
end

function Text:SetSize(sz)
	return self.size
end

function Text:SetRegionSize(w,h)
    self.inst.TextWidget:SetRegionSize(w,h)
end

function Text:GetRegionSize()
    return self.inst.TextWidget:GetRegionSize()
end

function Text:SetString(str)
    if( type(str) == "table" ) then 
        print("*** Error - SetString called with a table")
        for i,v in pairs(str) do
            print("",i,v)
        end
    end
    self.string = str
    self.inst.TextWidget:SetString(str or "")
end

function Text:GetString()
	--print("Text:GetString()", self.inst.TextWidget:GetString())
    return self.inst.TextWidget:GetString() or ""
end

function Text:SetVAlign(anchor)
    self.inst.TextWidget:SetVAnchor(anchor)
end

function Text:SetHAlign(anchor)
    self.inst.TextWidget:SetHAnchor(anchor)
end

function Text:EnableWordWrap(enable)
	self.inst.TextWidget:EnableWordWrap(enable)
end

return Text