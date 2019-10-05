function MakeGoggle(name)

	local fname = "hat_"..name
	local symname = name.."hat"
	local texture = symname..".tex"
	local prefabname = symname
	local assets =
		{
			Asset("ANIM", "anim/"..fname..".zip"),			
		}

    if name == "gogglesheat" then
        table.insert(assets, Asset("IMAGE", "images/colour_cubes/heat_vision_cc.tex"))
    end
    if name == "gogglesshoot" then
        table.insert(assets, Asset("IMAGE", "images/colour_cubes/shooting_goggles_cc.tex"))
    end    

    local function goggletalk(name, owner)    	    	
    	if owner == GetPlayer() and math.random()<0.2 and  owner.prefab == "wagstaff"  then
    		GetPlayer().components.talker:Say(GetString(GetPlayer().prefab, "ANNOUNCE_PUTONGOGGLES_"..name))
    	end
    end

	local function generic_perish(inst)
		inst:Remove()
	end

	local function onequip(inst, owner, fname_override)
		goggletalk(inst.prefab, owner)

		local build = fname_override or fname
		owner.AnimState:OverrideSymbol("swap_hat", build, "swap_hat")
		owner.AnimState:Show("HAT")
	--	owner.AnimState:Show("HAT_HAIR")
	--	owner.AnimState:Hide("HAIR_NOHAT")
	--	owner.AnimState:Hide("HAIR")

		if inst:HasTag("venting") then
			owner:AddTag("venting")
		end		

		if inst.components.fueled then
			inst.components.fueled:StartConsuming()        
		end
	end

	local function onunequip(inst, owner)
		owner.AnimState:Hide("HAT")
	--	owner.AnimState:Hide("HAT_HAIR")
	--	owner.AnimState:Show("HAIR_NOHAT")
	--	owner.AnimState:Show("HAIR")

		if inst:HasTag("venting") then
			owner:RemoveTag("venting")
		end	

		if inst.components.fueled then
			inst.components.fueled:StopConsuming()        
		end	
	end
	
	local function simple()
		local inst = CreateEntity()

		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		MakeInventoryPhysics(inst)

		inst.AnimState:SetBank(symname)
		inst.AnimState:SetBuild(fname)
		inst.AnimState:PlayAnimation("anim")

		inst:AddTag("goggles")
		inst:AddTag("venting")

		if GROUND.OCEAN_SHALLOW then
			MakeInventoryFloatable(inst, "idle_water", "anim")
		end

		inst:AddTag("hat") -- really these are just hats under a different name

		inst:AddTag("nearsighted_glasses")

		inst:AddComponent("inspectable")

		inst:AddComponent("inventoryitem")
		inst:AddComponent("tradable")

		inst:AddComponent("equippable")
		inst.components.equippable.equipslot = EQUIPSLOTS.HEAD

		inst.components.equippable:SetOnEquip( onequip )

		inst.components.equippable:SetOnUnequip( onunequip )

		return inst
	end

	local function normal_onequip(inst, owner)		
		onequip(inst, owner)
		if owner:HasTag("wagstaff_inventor") then
			owner:AddTag("revealtraps")	
			if owner.prefab == "wagstaff" then
				owner.AnimState:OverrideSymbol("face", "wagstaff_face_swap", "face")		
			end
		end
	end

	local function normal_onunequip(inst, owner)
		onunequip(inst, owner)
		if owner:HasTag("wagstaff_inventor") then
			owner:RemoveTag("revealtraps")
			owner.AnimState:ClearOverrideSymbol("face")
		end
	end

	local function normal()		
		local inst = simple()		

		inst.components.equippable:SetOnEquip(normal_onequip)
		inst.components.equippable:SetOnUnequip(normal_onunequip)

		inst:AddComponent("fueled")		
		inst.components.fueled.fueltype = "USAGE"
		
		inst.components.fueled:InitializeFuelLevel(TUNING.GOGGLES_NORMAL_PERISHTIME)
		inst.components.fueled:SetDepletedFn(generic_perish)

		inst:AddTag("no_sewing")
		inst:AddTag("magnifying_glass")
		inst:AddTag("sees_hiddendanger")
		
		if ACTIONS.SPY then
			inst:AddComponent("tool")
    		inst.components.tool:SetAction(ACTIONS.SPY)
    	end

		return inst
	end

    local function heat_onequip(inst, owner)
		onequip(inst, owner)
		if owner:HasTag("wagstaff_inventor") then
	        if owner ~= GetPlayer() then return end
	        owner.SoundEmitter:PlaySound("dontstarve_wagstaff/characters/wagstaff/goggles/heat_on")
	        if GetClock() and GetWorld() and GetWorld().components.colourcubemanager then
	            GetClock():SetNightVision(true)
	        end

	        --GetWorld().Map:SetMultColour(0.1,0.1,1,1)
	  		if GetWorld().components.globalcolourmodifier then
	        	local function fn(ent)	        		
	        		if ent == GetWorld() then
						local tuning = TUNING.GOGGLES_HEAT.GROUND
						ent.Map:SetMultColour(unpack(tuning.MULT_COLOUR))
						ent.Map:SetAddColour(unpack(tuning.ADD_COLOUR))

						local tuning = TUNING.GOGGLES_HEAT.WAVES
						local waves = ent.WaveComponent or ent.CloudComponent
						if waves then
							waves:SetMultColour(unpack(tuning.MULT_COLOUR))
							waves:SetAddColour(unpack(tuning.ADD_COLOUR))
						end
	        			return
	        		end
	        		if ent.AnimState then
	        			local tuning
		        		if not ent:HasTag("shadow") and ( ent:HasTag("monster") or ent:HasTag("animal") or ent:HasTag("character") or ent:HasTag("smallcreature") or ent:HasTag("seacreature") ) then	        			
							tuning = TUNING.GOGGLES_HEAT.HOT
						else
							tuning = TUNING.GOGGLES_HEAT.COLD
						end
						-- apply the tuning
						if tuning.BLOOM then
							ent.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )
						end
						ent.AnimState:SetDesaturation(tuning.DESATURATION)
						ent.AnimState:SetMultColour(unpack(tuning.MULT_COLOUR))
						ent:SetAddColour(unpack(tuning.ADD_COLOUR))
					end
	        	end
	            if owner:HasTag("outofworldprojected") then
	                owner.AnimState:SetDesaturation(0)
	                owner.AnimState:SetSepia(0)
	            end        	
				GetWorld().components.colourcubemanager:SetOverrideColourCube("images/colour_cubes/heat_vision_cc.tex", .25)
				GetWorld().components.globalcolourmodifier:SetModifyColourFn(fn)
			end
    	end
    end

    local function heat_onunequip(inst, owner)
        onunequip(inst, owner)
        if owner:HasTag("wagstaff_inventor") then
	        if owner ~= GetPlayer() then return end
	        owner.SoundEmitter:PlaySound("dontstarve_wagstaff/characters/wagstaff/goggles/heat_off")
	        if GetClock() then
	            GetClock():SetNightVision(false)
	        end
	        if GetWorld() and GetWorld().components.colourcubemanager then
	            GetWorld().components.colourcubemanager:SetOverrideColourCube(nil, .5)
	        end
	 		GetWorld().Map:SetMultColour(1,1,1,1)
	      	GetWorld().Map:SetAddColour(0,0,0,1)

			local waves = GetWorld().WaveComponent or GetWorld().CloudComponent
			if waves then
				waves:SetMultColour(1,1,1,1)
				waves:SetAddColour(0,0,0,1)
			end

	        if GetWorld().components.globalcolourmodifier then
	        	GetWorld().components.globalcolourmodifier:Reset()
	    	end

	        if owner:HasTag("outofworldprojected") then
	        	owner.checkfilters(owner)
	        end    
        end   	
    end

    local function heat_perish(inst)
        if inst.components.inventoryitem:GetGrandOwner() == GetPlayer() and inst.components.equippable and inst.components.equippable:IsEquipped() then
            if GetClock() then
                GetClock():SetNightVision(false)
            end
            if GetWorld() and GetWorld().components.colourcubemanager then
                GetWorld().components.colourcubemanager:SetOverrideColourCube(nil, .5)
            end
        end

        generic_perish(inst)
    end	

	local function heat()
		local inst = simple()
        inst.components.equippable:SetOnEquip( heat_onequip )
        inst.components.equippable:SetOnUnequip( heat_onunequip )

		inst:AddComponent("fueled")		
		inst.components.fueled.fueltype = "USAGE"
		inst.components.fueled:InitializeFuelLevel(TUNING.GOGGLES_HEAT_PERISHTIME)
		inst.components.fueled:SetDepletedFn(heat_perish)
		inst.components.fueled.accepting = true
		inst:AddTag("no_sewing")	
		inst:AddTag("clearfog")
		inst:AddTag("clearclouds")

		inst.CustomFocus = function(owner)
			if owner:HasTag("wagstaff_inventor") then
				local blur = TUNING.GOGGLES_HEAT.BLUR
				if blur.ENABLED then
					PostProcessor:SetBlurEnabled(true)
					PostProcessor:SetBlurParams(blur.START_RADIUS, blur.STRENGTH)
				end
			end
		end

		return inst
	end

    local function armor_onequip(inst, owner)
		if owner == GetPlayer() then
			GetWorld().components.ambientsoundmixer:SetReverbOveride("helmet") -- helmet
		end
		onequip(inst, owner)		
		if owner == GetPlayer() then
	    	owner.SoundEmitter:PlaySound("dontstarve_wagstaff/characters/wagstaff/goggles/armor_on")    		
		end
		owner.AnimState:Hide("HAIR_HAT")
		owner.AnimState:Hide("HAIR_NOHAT")
		owner.AnimState:Hide("HAIR")		
		owner.AnimState:Hide("HEAD")
    end

    local function armor_onunequip(inst, owner)
		if owner == GetPlayer() then
	    	GetWorld().components.ambientsoundmixer:ClearReverbOveride()
		end
        onunequip(inst, owner)
		if owner == GetPlayer() then
	    	owner.SoundEmitter:PlaySound("dontstarve_wagstaff/characters/wagstaff/goggles/armor_off")
		end
      	owner.AnimState:Show("HAIR_HAT")
		owner.AnimState:Show("HAIR_NOHAT")
		owner.AnimState:Show("HAIR")      	
		owner.AnimState:Show("HEAD")
    end

	local function armor()
		local inst = simple()
		inst.components.equippable:SetOnEquip( armor_onequip )
        inst.components.equippable:SetOnUnequip( armor_onunequip )

		inst:AddTag("visorvision")
		inst:AddComponent("armor")
    	inst.components.armor:InitCondition(TUNING.GOGGLES_ARMOR_ARMOR, TUNING.GOGGLES_ARMOR_ABSORPTION)

		return inst
	end	

	local function onattack_shoot(inst, attacker, target)

	    if target.components.burnable and not target.components.burnable:IsBurning() then
	        if target.components.freezable and target.components.freezable:IsFrozen() then           
	            target.components.freezable:Unfreeze()            
	        else            
	            if target.components.fueled and target:HasTag("campfire") and target:HasTag("structure") then
	                -- Rather than worrying about adding fuel cmp here, just spawn some fuel and immediately feed it to the fire
	                local fuel = SpawnPrefab("cutgrass")
	                if fuel then target.components.fueled:TakeFuelItem(fuel) end
	            else
	                target.components.burnable:Ignite(true)
	            end
	        end   
	    end

	    if target:HasTag("aquatic") and not target.components.burnable then 
	        local pt = target:GetPosition()
	        local smoke = SpawnPrefab("smoke_out")
	        smoke.Transform:SetPosition(pt:Get())

	         if target.SoundEmitter then 
	            target.SoundEmitter:PlaySound("dontstarve_DLC002/common/fire_weapon_out") 
	        end 
	    end 

	    if target.components.freezable then
	        target.components.freezable:AddColdness(-1) --Does this break ice staff?
	        if target.components.freezable:IsFrozen() then
	            target.components.freezable:Unfreeze()            
	        end
	    end

	    if target.components.sleeper and target.components.sleeper:IsAsleep() then
	        target.components.sleeper:WakeUp()
	    end
	end


    local function shoot_onequip(inst, owner)
		onequip(inst, owner)
		if owner:HasTag("wagstaff_inventor") then
			if owner == GetPlayer() and GetWorld() and GetWorld().components.colourcubemanager then
	        	GetWorld().components.colourcubemanager:SetOverrideColourCube("images/colour_cubes/shooting_goggles_cc.tex", .25)
		    end			
			inst.components.weapon:SetCanAttack(function() return true end)
	    	--inst.components.weapon:SetProjectile("fryfocals_charge")
	    else
	    	--inst.components.weapon:SetProjectile()
	    	inst.components.weapon:SetCanAttack(function() return false end)
	    end
    end

    local function shoot_onunequip(inst, owner)
        onunequip(inst, owner)
        if owner == GetPlayer() and GetWorld() and GetWorld().components.colourcubemanager then
            GetWorld().components.colourcubemanager:SetOverrideColourCube(nil, .5)
        end        
    end

	local function shoot()	
		local inst = simple()
        inst.components.equippable:SetOnEquip( shoot_onequip )
        inst.components.equippable:SetOnUnequip( shoot_onunequip )

	    inst:AddComponent("weapon")
    	inst.components.weapon:SetDamage(50)
    	inst.components.weapon:SetRange(8, 10)    	
    	inst.components.weapon:SetProjectile("fryfocals_charge")
    	inst.components.weapon:SetOnAttack(onattack_shoot)
		
		inst:AddComponent("finiteuses")
		inst:AddTag("Shockwhenwet")
		inst.components.finiteuses:SetMaxUses(TUNING.GOGGLES_SHOOT_USES)
		inst.components.finiteuses:SetUses(TUNING.GOGGLES_SHOOT_USES)
		inst.components.finiteuses:SetOnFinished( generic_perish )
		
		--inst.components.fueled:InitializeFuelLevel(TUNING.GOGGLES_NORMAL_PERISHTIME)
		--inst.components.fueled:SetDepletedFn(generic_perish)

		return inst
	end			

	local fn = nil
	local prefabs = {
		"hiddendanger_fx",
		"fryfocals_charge",
	}

	if name == "gogglesnormal" then
		fn = normal
	elseif name == "gogglesheat" then
		fn = heat
	elseif name == "gogglesarmor" then
		fn = armor
	elseif name == "gogglesshoot" then
		fn = shoot		
	end

	return Prefab( "common/inventory/"..prefabname, fn or simple, assets, prefabs)
end

return  MakeGoggle("gogglesnormal"),
		MakeGoggle("gogglesheat"),
		MakeGoggle("gogglesarmor"),
		MakeGoggle("gogglesshoot")