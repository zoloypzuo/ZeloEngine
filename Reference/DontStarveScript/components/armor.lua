local function PercentChanged(inst, data)
    if inst.components.armor
       and data.percent and data.percent <= 0
       and inst.components.inventoryitem and inst.components.inventoryitem.owner then
        inst.components.inventoryitem.owner:PushEvent("armorbroke", {armor = inst})
        --ProfileStatsSet("armor_broke_" .. inst.prefab, true)
    end
end

local Armor = Class(function(self, inst)
    self.inst = inst
    self.condition = 100
    self.maxcondition = 100
    self.tags = nil
    self.inst:ListenForEvent("percentusedchange", PercentChanged)
end)

function Armor:InitCondition(amount, absorb_percent)
    self.condition = amount
	self.absorb_percent = absorb_percent
    self.maxcondition = amount
end

function Armor:GetPercent(amount)
    return self.condition / self.maxcondition
end


function Armor:SetTags(tags)
    self.tags = tags
end

function Armor:SetImmuneTags(tags)
    self.immunetags = tags
end

function Armor:SetAbsorption(absorb_percent)
    self.absorb_percent = absorb_percent
end

function Armor:SetPercent(amount)
    self:SetCondition(self.maxcondition * amount)
end

function Armor:SetCondition(amount)
    self.condition = amount
    self.inst:PushEvent("percentusedchange", {percent = self:GetPercent()})   
    
    if self.condition <= 0 then
        self.condition = 0
        ProfileStatsSet("armor_broke_" .. self.inst.prefab, true)
        ProfileStatsSet("armor", self.inst.prefab)
        
        if METRICS_ENABLED then
			FightStat_BrokenArmor(self.inst.prefab)
		end
		
        if self.onfinished then
            self.onfinished()
        end
        
        if not self.dontremove then
            self.inst:Remove()
        end
    end
end

function Armor:OnSave()
    if self.condition ~= self.maxcondition then
        return {condition = self.condition}
    end
end

function Armor:OnLoad(data)
    if data.condition then
        self:SetCondition(data.condition)
    end
end

function Armor:CanResist(attacker, weapon)
    if self.condition and self.condition <= 0 then
        return false
    end
    if attacker and self.immunetags then        
        for k,v in pairs(self.immunetags) do
            if attacker:HasTag(v) then
                return false
            end
        end
    end
    if attacker and self.tags then
	    for k,v in pairs(self.tags) do
		    if attacker:HasTag(v) then
			    return true
		    end
		    if weapon and weapon:HasTag(v) then
			    return true
		    end
	    end
	    return false
	else
	    return self.tags == nil
	end
end

function Armor:TakeDamage(damage_amount, attacker, weapon)

    if self:CanResist(attacker, weapon) then
        local leftover = damage_amount
        
        local max_absorbed = damage_amount * self.absorb_percent;
        local absorbed = math.floor(math.min(max_absorbed, self.condition))
        -- we said we were going to absorb something so we will
        if absorbed < 1 then
            absorbed = 1
        end
        leftover = damage_amount - absorbed
        ProfileStatsAdd("armor_absorb", absorbed)
        
        if METRICS_ENABLED then
			FightStat_Absorb(absorbed)
		end


        if self.bonussanitydamage then
            local sanitydamage = absorbed * self.bonussanitydamage
            if self.inst.components.equippable and self.inst.components.equippable:IsEquipped() and self.inst.components.equippable.equipper then
                self.inst.components.equippable.equipper.components.sanity:DoDelta(-sanitydamage)
            end                
        end

        self:SetCondition(self.condition - absorbed)
		if self.ontakedamage then
			self.ontakedamage(self.inst, damage_amount, absorbed, leftover)
		end


        self.inst:PushEvent("armorhit")

        if self.absorb_percent >= 1 then
            return 0
        end

        return leftover
    else
        return damage_amount
    end
   
end



return Armor
