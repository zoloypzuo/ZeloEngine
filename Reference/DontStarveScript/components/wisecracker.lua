local Wisecracker = Class(function(self, inst)
    self.inst = inst
    self.time_in_lightstate = 0
    self.inlight = true

    inst:ListenForEvent("oneatsomething", 
        function(inst, data) 
            if data.food and data.food.components.edible then
				
				
				if data.food.prefab == "spoiled_food" then
					inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_EAT", "SPOILED"))
				elseif data.food.components.edible:GetHealth(inst) < 0 and data.food.components.edible:GetSanity(inst) <= 0 then
					inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_EAT", "PAINFUL"))
				elseif data.food.components.perishable and not data.food.components.perishable:IsFresh() then
					if data.food.components.perishable:IsStale() then
						inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_EAT", "STALE"))
					elseif data.food.components.perishable:IsSpoiled() then
						inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_EAT", "SPOILED"))
					end
				end
			end
        end)


	inst:StartUpdatingComponent(self)
        
        
    inst:ListenForEvent( "dusktime", function(it, data) 
            if it:IsCave() then
                return 
            end
            inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_DUSK"))
        end, GetWorld())        
    

    inst:ListenForEvent("torchranout", function(inst, data)
            inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_TORCH_OUT"))
    end)

    inst:ListenForEvent("heargrue", function(inst, data)
            inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_CHARLIE"))
    end)

    inst:ListenForEvent("accomplishment", function(inst, data)
            inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_ACCOMPLISHMENT"))
    end)
    inst:ListenForEvent("accomplishment_done", function(inst, data)
            inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_ACCOMPLISHMENT_DONE"))
    end)

    inst:ListenForEvent("attacked", function(inst, data)
		if data.weapon and data.weapon.prefab == "boomerang" then
			inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_BOOMERANG"))
		end
    end)

    
    inst:ListenForEvent("attackedbygrue", function(inst, data)
            inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_CHARLIE_ATTACK"))
    end)
    
    inst:ListenForEvent("thorns", function(inst, data)
            inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_THORNS"))
    end)
    
    inst:ListenForEvent("hungerdelta", 
        function(inst, data) 
            if (data.newpercent > TUNING.HUNGRY_THRESH) ~= (data.oldpercent > TUNING.HUNGRY_THRESH) then
                if data.newpercent <= TUNING.HUNGRY_THRESH then
            inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_HUNGRY"))
                end
            end    
        end)

    inst:ListenForEvent("startfreezing", 
        function(inst, data) 
			inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_COLD"))
        end)
    
    inst:ListenForEvent( "inventoryfull", function(it, data) 
			if inst.components.inventory:IsFull() then
				inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_INV_FULL"))
			end
        end)  
        
    inst:ListenForEvent("coveredinbees", function(inst, data)
		inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_BEES"))
    end)
    
    inst:ListenForEvent("wormholespit", function(inst, data)
        inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_WORMHOLE"))
    end)

    inst:ListenForEvent("huntlosttrail", function(inst, data)
        inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_HUNT_LOST_TRAIL"))
    end)
        
    inst:ListenForEvent("huntbeastnearby", function(inst, data)
        inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_HUNT_BEAST_NEARBY"))
    end)
        
end)

function Wisecracker:OnUpdate(dt)
	
	
	local light_thresh = .5
	local dark_thresh = .5

	if self.inst.LightWatcher:IsInLight() then
		if not self.inlight then
			if self.inst.LightWatcher:GetTimeInLight() >= light_thresh then
				self.inlight = true
				self.inst.components.talker:Say(GetString(self.inst.prefab, "ANNOUNCE_ENTER_LIGHT"))
			end
		end
	else
		if self.inlight then
			if self.inst.LightWatcher:GetTimeInDark() >= dark_thresh then
				self.inlight = false
				self.inst.components.talker:Say(GetString(self.inst.prefab, "ANNOUNCE_ENTER_DARK"))
			end
		end
	end
end


return Wisecracker
