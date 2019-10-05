local Widget = require "widgets/widget"
local Image = require "widgets/image"

local TileBG = Class(Widget, function(self, atlas, tileim, sepim, endim, horizontal)
    Widget._ctor(self, "TileBG")
    
    self.atlas = atlas
    self.tileim = tileim
    self.sepim = sepim
    self.endim = endim
    self.horizontal = horizontal 
    self.numtiles = 0
    self.w = 0
    self.h = 0
    self.slotpos = {}
    self.stepsize = 0
    self.length = 0
	self.bgs = nil
	self.seps = nil
end)

function TileBG:GetSlotPos(k)
    return self.slotpos[k] or Vector3(0,0,0)
end

function TileBG:GetSepSize()
	return self.seps[1]:GetSize()
end

function TileBG:GetSlotSize()
	return self.bgs[1]:GetSize()
end

function TileBG:GetSize()
    return self.w, self.h
end

function TileBG:SetNumTiles(numtiles)
    self.numtiles = numtiles
    self:KillAllChildren()
    
    local end1, end2
    if self.endim then
        end1 = self:AddChild(Image(self.atlas, self.endim))
        end2 = self:AddChild(Image(self.atlas, self.endim))
    end
    
    self.bgs = {}
    for k = 1,numtiles do
        self.bgs[k] = self:AddChild(Image(self.atlas, self.tileim))
    end

    local sep_w, sep_h = 0, 0
    self.seps = {}
    if self.sepim then
        for k = 1,numtiles-1 do
            self.seps[k] = self:AddChild(Image(self.atlas, self.sepim))
        end
        sep_w, sep_h = self.seps[1]:GetSize()
    end
    
    local end_w, end_h = 0, 0
    
    if end1 then
        end_w, end_h = end1:GetSize()
    end
    
    local tile_w, tile_h = self.bgs[1]:GetSize()
    

    if self.horizontal then
        self.w = end_w*2 + tile_w*numtiles + sep_w*(numtiles-1)
        self.h = math.max(end_h, tile_h, sep_h)
        self.stepsize = tile_w + sep_w
        self.length = self.w
    else
        self.h = end_h*2 + tile_h*numtiles + sep_h*(numtiles-1)
        self.w = math.max(end_w, tile_w, sep_w)
        self.stepsize = tile_h + sep_h
        self.length = self.h
    end
    
    if end1 then
        if self.horizontal then
            end1:SetPosition(-self.w/2 + end_w/2, 0,0)
        else
            end1:SetPosition(0, -self.h/2 + end_h/2,0)
        end
    end
    
    if end2 then
        if self.horizontal then
            end2:SetPosition(self.w/2 - end_w/2, 0,0)
            end2:SetScale(-1,1,1)
        else
            end2:SetPosition(0, self.h/2 - end_h/2,0)
            end2:SetScale(0,-1,1)
        end
    end
    
    if self.horizontal then
        for k = 1, numtiles do
            local x = -self.w/2 + end_w + tile_w/2 + tile_w*(k-1)
            if k > 1 then
                x = x + (k-1)*sep_w
            end
            self.bgs[k]:SetPosition(x,0,0)
            self.slotpos[k] = Vector3(x,0,0)
        end

        if self.sepim then
            for k = 1, numtiles-1 do
                local x = -self.w/2 + end_w + tile_w*k + sep_w/2
                if k > 1 then
                    x = x + (k-1)*sep_w
                end
                self.seps[k]:SetPosition(x,0,0)
            end
        end
    else
        for k = 1, numtiles do
            local y = self.h/2 - end_h - tile_h/2 - tile_h*(k-1)
            if k > 1 then
                y = y - (k-1)*sep_h
            end
            self.bgs[k]:SetPosition(0,y,0)
            self.slotpos[k] = Vector3(0,y,0)
        end

        if self.sepim then
            for k = 1, numtiles-1 do
                local y = -self.h/2 + end_h + tile_h*k + sep_h/2
                if k > 1 then
                    y = y + (k-1)*sep_h
                end
                self.seps[k]:SetPosition(0,y,0)
            end
        end
    end
    
end

return TileBG