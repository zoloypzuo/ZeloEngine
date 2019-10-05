require "stategraphs/SGrabbit"

local assets=
{
	Asset("ANIM", "anim/ds_rabbit_basic.zip"),
	Asset("ANIM", "anim/rabbit_build.zip"),
	Asset("ANIM", "anim/beard_monster.zip"),
	Asset("ANIM", "anim/rabbit_winter_build.zip"),
	Asset("SOUND", "sound/rabbit.fsb"),
	Asset("INV_IMAGE", "beard_monster"),
	Asset("INV_IMAGE", "rabbit_winter"),
}

local prefabs =
{
    "smallmeat",
    "cookedsmallmeat",
    "beardhair",
}

local rabbitsounds = 
{
    scream = "dontstarve/rabbit/scream",
    hurt = "dontstarve/rabbit/scream_short",
}

local beardsounds = 
{
    scream = "dontstarve/rabbit/beardscream",
    hurt = "dontstarve/rabbit/beardscream_short",
}

local wintersounds = 
{
    scream = "dontstarve/rabbit/winterscream",
    hurt = "dontstarve/rabbit/winterscream_short",
}

local function onpickup(inst)
end

local brain = require "brains/rabbitbrain"

local function BecomeRabbit(inst)
	if not inst.israbbit or inst.iswinterrabbit then
		inst.AnimState:SetBuild("rabbit_build")
	    inst.components.lootdropper:SetLoot({"smallmeat"})
	    inst.israbbit = true
	    inst.iswinterrabbit = false
		inst.components.sanityaura.aura = 0
		inst.components.inventoryitem:ChangeImageName("rabbit")
		inst.sounds = rabbitsounds
	end
end

local function BecomeBeardling(inst)
	if inst.israbbit or inst.iswinterrabbit then
		inst.AnimState:SetBuild("beard_monster")
	    inst.components.lootdropper:SetLoot{}
		inst.components.lootdropper:AddRandomLoot("beardhair", .5)	    
		inst.components.lootdropper:AddRandomLoot("monstermeat", 1)	    
		inst.components.lootdropper:AddRandomLoot("nightmarefuel", 1)	  
		inst.components.lootdropper.numrandomloot = 1  
		inst.components.sanityaura.aura = -TUNING.SANITYAURA_MED		
	    inst.israbbit = false
	    inst.iswinterrabbit = false
	    inst.components.inventoryitem:ChangeImageName("beard_monster")
		inst.sounds = beardsounds
	end
end

local function DonWinterFur(inst)
	if not inst.iswinterrabbit or inst.israbbit then
		inst.AnimState:SetBuild("rabbit_winter_build")
		inst.components.lootdropper:SetLoot({"smallmeat"})
		inst.israbbit = false
	    inst.iswinterrabbit = true
		inst.components.sanityaura.aura = 0
		inst.components.inventoryitem:ChangeImageName("rabbit_winter")
		inst.sounds = wintersounds
	end
end

local function CheckTransformState(inst)
	if not inst.components.health:IsDead() then
		local player = GetPlayer()
		if player.components.sanity:GetPercent() > TUNING.BEARDLING_SANITY then
			if not GetSeasonManager() or GetSeasonManager():IsSummer() then
				BecomeRabbit(inst)
			else
				DonWinterFur(inst)
			end
		else
			BecomeBeardling(inst)			
		end
	end
end

local function ondrop(inst)
	inst.sg:GoToState("stunned")
	CheckTransformState(inst)
end


local function OnWake(inst)
	CheckTransformState(inst)
	inst.checktask = inst:DoPeriodicTask(10, CheckTransformState)
end

local function OnSleep(inst)
	 if inst.checktask then
	 	inst.checktask:Cancel()
	 	inst.checktask = nil
	 end
end

local function GetCookProductFn(inst)
	if inst.israbbit or inst.iswinterrabbit then
		return "cookedsmallmeat" 
	else 
		return "cookedmonstermeat"
	end
end

local function OnCookedFn(inst)
	inst.SoundEmitter:PlaySound("dontstarve/rabbit/scream_short")

end

local function OnAttacked(inst, data)
    local x,y,z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x,y,z, 30, {'rabbit'})
    
    local num_friends = 0
    local maxnum = 5
    for k,v in pairs(ents) do
        v:PushEvent("gohome")
        num_friends = num_friends + 1
        
        if num_friends > maxnum then
            break
        end
    end
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    local physics = inst.entity:AddPhysics()
	local sound = inst.entity:AddSoundEmitter()
	local shadow = inst.entity:AddDynamicShadow()
	shadow:SetSize( 1, .75 )
    inst.Transform:SetFourFaced()

    MakeCharacterPhysics(inst, 1, 0.5)

    anim:SetBank("rabbit")
    anim:SetBuild("rabbit_build")
    anim:PlayAnimation("idle")
    
    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.runspeed = TUNING.RABBIT_RUN_SPEED
    inst:SetStateGraph("SGrabbit")

    inst:AddTag("animal")
    inst:AddTag("prey")
    inst:AddTag("rabbit")
    inst:AddTag("smallcreature")
    inst:AddTag("canbetrapped")    

    inst:SetBrain(brain)
    
    inst.data = {}
    
    inst:AddComponent("eater")
    inst.components.eater:SetVegetarian()

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.nobounce = true
	inst.components.inventoryitem.canbepickedup = false
	inst.components.inventoryitem:SetOnPickupFn(onpickup)
	inst.components.inventoryitem:SetOnDroppedFn(ondrop)
	inst:AddComponent("sanityaura")
    

    inst:AddComponent("cookable")
    inst.components.cookable.product = GetCookProductFn
    inst.components.cookable:SetOnCookedFn(OnCookedFn)

    
    inst:AddComponent("knownlocations")
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "chest"
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.RABBIT_HEALTH)
    inst.components.health.murdersound = "dontstarve/rabbit/scream_short"
    
    MakeSmallBurnableCharacter(inst, "chest")
    MakeTinyFreezableCharacter(inst, "chest")

    inst:AddComponent("lootdropper")
    
    inst:AddComponent("inspectable")
    inst:AddComponent("sleeper")

	BecomeRabbit(inst)
    CheckTransformState(inst)
    inst.CheckTransformState = CheckTransformState
	
	inst.OnEntityWake = OnWake
	inst.OnEntitySleep = OnSleep    
    
    inst.OnSave = function(inst, data)
        if not inst.israbbit then
			data.israbbit = inst.israbbit
		end
        data.iswinterrabbit = inst.iswinterrabbit or nil
    end        
    
    inst.OnLoad = function(inst, data)
        if data then
				local israbbit = data.israbbit or true
		        if not israbbit and not data.iswinterrabbit then
					BecomeBeardling(inst)
				else if not israbbit and data.iswinterrabbit then
					DonWinterFur(inst)					
		        end
		    end
	    end 
    end
        
    inst:ListenForEvent("attacked", OnAttacked)

    return inst
end

return Prefab( "forest/animals/rabbit", fn, assets, prefabs) 
