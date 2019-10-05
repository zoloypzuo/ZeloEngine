local Firebug = Class(function(self, inst)
    self.inst = inst
    self.time_to_fire = 60
    self.inst:StartUpdatingComponent(self)
end)


function Firebug:OnUpdate(dt)
    if self.inst.components.sanity and self.inst.components.sanity:GetPercent() < TUNING.WILLOW_LIGHTFIRE_SANITY_THRESH then
        self.time_to_fire = self.time_to_fire - dt

        if self.time_to_fire <= 0 then
            self.inst.components.talker:Say(GetString(self.inst.prefab, "ANNOUNCE_LIGHTFIRE"))      
            if self.prefab then
                local fire = SpawnPrefab(self.prefab)
                fire.Transform:SetPosition(self.inst.Transform:GetWorldPosition())
            end
            self.time_to_fire = 120*math.random()+120
        end
    end
end


function Firebug:GetDebugString()
    return string.format("%2.2f", self.time_to_fire)
end

return Firebug
