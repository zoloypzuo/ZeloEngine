local Autosaver = Class(function(self, inst)
    self.inst = inst
    self.timeout = TUNING.AUTOSAVE_INTERVAL
    self.inst:StartUpdatingComponent(self)
end)

function Autosaver:DoSave()
    local enabled = true
    if PLATFORM == "PS4" then
        enabled = GetPlayer().profile:GetAutosaveEnabled()
    end
    
    if enabled then
        GetPlayer().HUD.controls.saving:StartSave()
        self.inst:DoTaskInTime(1, function() SaveGameIndex:SaveCurrent() end )
        self.inst:DoTaskInTime(3, function() GetPlayer().HUD.controls.saving:EndSave() end)
    end
    
    self.timeout = TUNING.AUTOSAVE_INTERVAL
end

function Autosaver:OnUpdate(dt)
    
    if self.timeout > 0 then 
        self.timeout = self.timeout - dt
    end

    if self.timeout <= 0 and GetClock():GetTimeInEra() > 10 then
        if self.inst.LightWatcher:IsInLight() and self.inst.components.health:GetPercent() > .1 then
            local danger = FindEntity(self.inst, 30, function(target) return target:HasTag("monster") or target.components.combat and target.components.combat.target == self.inst end)
            if not danger then
                self:DoSave()
            else
				self.timeout = self.timeout + math.random(20, 40)
            end
            
        end
    end

end

return Autosaver
