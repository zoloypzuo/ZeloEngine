local function oncandraw(self, candraw)
    if candraw then
        self.inst:AddTag("drawable")
    else
        self.inst:RemoveTag("drawable")
    end
end

local Drawable = Class(function(self, inst)
    self.inst = inst

    self.candraw = true
    self.imagename = nil
    self.ondrawnfn = nil

    --V2C: Recommended to explicitly add tags to prefab pristine state
    --On construciton, "drawable" tag is added by default
end,
nil,
{
    candraw = oncandraw,
})

function Drawable:OnRemoveFromEntity()
    self.inst:RemoveTag("drawable")
end

function Drawable:SetCanDraw(candraw)
    self.candraw = candraw
end

function Drawable:CanDraw()
    return self.candraw
end

function Drawable:SetOnDrawnFn(fn)
    self.ondrawnfn = fn
end

function Drawable:OnDrawn(imagename, imagesource)
    if imagename == "" then
        imagename = nil
    end
    if self.imagename ~= imagename then
        self.imagename = imagename
        if self.ondrawnfn ~= nil then
            self.ondrawnfn(self.inst, imagename, imagesource)
        end
    end
end

function Drawable:GetImage()
    return self.imagename
end

function Drawable:OnSave()
    return self.imagename ~= nil
        and { image = self.imagename }
        or nil
end

function Drawable:OnLoad(data)
    if data.image ~= nil then
        self:OnDrawn(data.image)
    end
end

return Drawable
