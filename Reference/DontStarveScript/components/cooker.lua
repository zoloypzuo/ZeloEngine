local Cooker = Class(function(self, inst)
    self.inst = inst
end)


function Cooker:CookItem(item, chef)
    if item and item.components.cookable then

        
        local newitem = item.components.cookable:Cook(self.inst, chef)
        ProfileStatsAdd("cooked_"..item.prefab)

        if self.oncookitem then
            self.oncookitem(item, newitem)
        end
        
        if self.inst.SoundEmitter then
            self.inst.SoundEmitter:PlaySound("dontstarve/wilson/cook")        
        end

        item:Remove()
        return newitem
    end
end


return Cooker
