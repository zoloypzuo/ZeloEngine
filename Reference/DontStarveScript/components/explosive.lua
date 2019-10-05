local Explosive = Class(function(self,inst)
	self.inst = inst
	self.explosiverange = 3
	self.explosivedamage = 200
	self.buildingdamage = 10
	self.lightonexplode = true
	self.onexplodefn = nil
	self.onignitefn = nil
end)

function Explosive:SetOnExplodeFn(fn)
	self.onexplodefn = fn
end

function Explosive:SetOnIgniteFn(fn)
	self.onignitefn = fn
end

function Explosive:OnIgnite()
    DefaultBurnFn(self.inst)
    if self.onignitefn then
    	self.onignitefn(self.inst)
    end
end

function Explosive:OnBurnt()   

    local pos = Vector3(self.inst.Transform:GetWorldPosition())
    
    GetClock():DoLightningLighting()
    
    GetPlayer().components.playercontroller:ShakeCamera(self.inst, "FULL", 0.7, 0.02, .5, 40)

    if self.onexplodefn then
    	self.onexplodefn(self.inst)
    end

    local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, self.explosiverange)

    for k,v in pairs(ents) do
        local inpocket = v.components.inventoryitem and v.components.inventoryitem:IsHeld()

        if not inpocket then

            if v.components.workable and not v:HasTag("busy") then --Haaaaaaack!
                v.components.workable:WorkedBy(self.inst, self.buildingdamage)
            elseif v.components.burnable and not v.components.fueled and self.lightonexplode then
                v.components.burnable:Ignite()
            end

            self.stacksize = 1

            if self.inst.components.stackable then
            	self.stacksize =  self.inst.components.stackable.stacksize
            end

            if v.components.combat and v ~= self.inst then
                v.components.combat:GetAttacked(self.inst, self.explosivedamage * self.stacksize or 1, nil)
            end

            v:PushEvent("explosion", {explosive = self.inst})
        end
    end

    local world = GetWorld()    --bleh, better way to do this?    
    for i=1,self.stacksize,1 do
        if world then
            world:PushEvent("explosion", {damage = self.explosivedamage})
        end
    end

    --self.inst:PushEvent("explosion")

    if self.inst.components.health then self.inst:PushEvent("death") end

    self.inst:Remove()
end

return Explosive