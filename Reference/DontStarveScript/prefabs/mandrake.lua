require "brains/mandrakebrain"
require "stategraphs/SGMandrake"

local assets =
{
	Asset("ANIM", "anim/mandrake.zip"),
	Asset("SOUND", "sound/mandrake.fsb"),
}

local prefabs =
{
    "cookedmandrake",
}



local function MakeFollower(inst, leader)
    inst:AddTag("picked") 
    inst:RemoveComponent("pickable")
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(20)
    inst.components.health.nofadeout = true
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "mandrake_root"
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    inst:RestartBrain()

    inst:RemoveComponent("burnable")
    inst:RemoveComponent("propagator")
    MakeSmallBurnableCharacter(inst, "mandrake_root")
    
    inst.DynamicShadow:Enable(true)
    if leader and leader.components.leader then
        leader.components.leader:AddFollower(inst)
    end
    
end

local function LoadFollower(inst, leader)
    --For transitions between caves
    MakeFollower(inst,leader)
    inst.sg:GoToState("idle")
end

local function MakeItem(inst)
    inst:StopBrain()
	inst:RemoveTag("picked") 
	inst:AddTag("item") 
    inst.Physics:SetSphere(.5)
    inst.Physics:SetCollisionGroup(COLLISION.ITEMS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:SetMass(1)
    inst.Physics:SetFriction(.1)
    inst.Physics:SetDamping(0)
    inst.Physics:SetRestitution(.5)
	inst.DynamicShadow:Enable(false)
	if inst.components.inventoryitem then
	    inst.components.inventoryitem.canbepickedup = true
        inst.components.inventoryitem:SetOnPickupFn(function(inst) inst.sg:GoToState("item") end)
        inst.components.inventoryitem:SetOnPutInInventoryFn(function(inst) inst.sg:GoToState("item") end)
        inst.components.inventoryitem:SetOnDroppedFn(function(inst) inst.sg:GoToState("item") end)
    end
    
    inst:DoTaskInTime(0, function(inst)
	    inst:RemoveComponent("pickable")
	    inst:RemoveComponent("combat")
        inst:RemoveComponent("health")
    end)
    inst:RemoveComponent("burnable")
    inst:RemoveComponent("propagator")
	MakeSmallBurnable(inst)
    MakeSmallPropagator(inst)

end

local function MakePlanted(inst)
	inst:RemoveTag("picked") 
    inst:StopBrain()
	
	if not inst.components.pickable then
        inst:AddComponent("pickable")
    end
    inst.Physics:SetCollisionGroup(COLLISION.ITEMS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
	inst.DynamicShadow:Enable(false)
    inst.components.pickable.canbepicked = true
    inst.components.pickable.onpickedfn = function(inst, picker)
        if GetClock():IsDay() then
            MakeItem(inst)
        else
            MakeFollower(inst, picker)
        end
        inst.sg:GoToState("picked")
    end
	local leader = inst.components.follower and inst.components.follower.leader
	if leader and leader.components.leader and leader.components.leader:IsFollower(inst) then
		leader.components.leader:RemoveFollower(inst)
	end
	inst:RemoveComponent("combat")
    inst:RemoveComponent("health")
    inst:RemoveComponent("burnable")
    inst:RemoveComponent("propagator")
	MakeSmallBurnable(inst)
    MakeSmallPropagator(inst)
end

local function DoAreaEffect(inst, user, range, time, knockout)
    local pos = Vector3(user.Transform:GetWorldPosition())
    local ents = TheSim:FindEntities(pos.x,pos.y,pos.z, range)
    for k,v in pairs(ents) do
	    if v.components.sleeper then
		    v.components.sleeper:AddSleepiness(10, time)
		elseif v:HasTag("player") and knockout then
	        v.sg:GoToState("wakeup")
	        v.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_KNOCKEDOUT") )
	    end
    end
end

local function OnEaten(inst, eater)
	DoAreaEffect(inst, eater, TUNING.MANDRAKE_SLEEP_RANGE, TUNING.MANDRAKE_SLEEP_TIME)
	eater.SoundEmitter:PlaySound("dontstarve/creatures/mandrake/death")
end

local function OnEaten_cooked(inst, eater)
	eater.SoundEmitter:PlaySound("dontstarve/creatures/mandrake/death")
	TheFrontEnd:Fade(false,0.1)
	eater:DoTaskInTime(0.5, function() 
        DoAreaEffect(inst, eater, TUNING.MANDRAKE_SLEEP_RANGE_COOKED, TUNING.MANDRAKE_SLEEP_TIME, true)
		TheFrontEnd:Fade(true,1)
		GetClock():MakeNextDay()
	end)
end

local function OnCooked(inst, cooker, chef)
    inst.persists = false
	chef.SoundEmitter:PlaySound("dontstarve/creatures/mandrake/death")
	TheFrontEnd:Fade(false,0.1)
	chef:DoTaskInTime(0.5, function()
        DoAreaEffect(inst, chef, TUNING.MANDRAKE_SLEEP_RANGE_COOKED, TUNING.MANDRAKE_SLEEP_TIME, true)
		TheFrontEnd:Fade(true,1) 
        GetClock():NextPhase()
	end)
end

local function commonfn()
    
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	
    inst:AddTag("mandrake")
    
    anim:SetBank("mandrake")
    anim:SetBuild("mandrake")
    
    ------------------------------------------
    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = function(inst)
        if inst:HasTag("picked") then
            return "PICKED"
        elseif inst:HasTag("dead") then
            return "DEAD"
        end
    end
    inst:AddComponent("inventoryitem")
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("edible")
    inst.components.edible.foodtype = "VEGGIE"
    return inst
end

local function defaultfn()
	local inst = commonfn()
	
    inst:AddTag("character")
    inst:AddTag("small")
    
    inst.AnimState:PlayAnimation("ground")

	local sound = inst.entity:AddSoundEmitter()
	local shadow = inst.entity:AddDynamicShadow()
	shadow:SetSize( 1, .5 )
    inst.Transform:SetFourFaced()
	MakeCharacterPhysics(inst, 10, .25)

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.walkspeed = 6
    
    inst:AddComponent("follower")
    inst.MakeFollowerFn = LoadFollower

    inst:SetStateGraph("SGMandrake")
    local brain = require "brains/mandrakebrain"
	inst:SetBrain(brain)

	inst.components.inventoryitem.canbepickedup = false
    inst.components.stackable:SetOnDeStack(MakeItem)
    
    
    inst.components.edible.healthvalue = TUNING.HEALING_HUGE
    inst.components.edible.hungervalue = TUNING.CALORIES_HUGE
    inst.components.edible:SetOnEatenFn(OnEaten)
    
    inst:AddComponent("cookable")
    inst.components.cookable.product = "cookedmandrake"
    inst.components.cookable:SetOnCookedFn(OnCooked)
    
    ------------------------------------------
    
    inst.OnSave = function(inst, data)
		if inst:HasTag("picked") then
			data.picked = true
		elseif inst:HasTag("item") then
		    data.item = true
		end
    end
    
    inst.OnLoad = function(inst, data)
        if data then
    		if data.picked then
                if GetClock():IsDay() then
                    MakePlanted(inst)
                    inst.sg:GoToState("plant")
                else
    			    LoadFollower(inst)
                end
    		elseif data.item then
    		    MakeItem(inst)
    			inst.sg:GoToState("item")
    		end
        end
    end
   
    MakePlanted(inst)
    
	inst:ListenForEvent("death", MakeItem)
    inst:ListenForEvent( "daytime", function()
        if inst.components.health and not inst.components.health:IsDead() then
            MakePlanted(inst)
            inst.sg:GoToState("plant")
        end
    end, GetWorld())
    
	return inst
end

local function cookedfn()
	local inst = commonfn()
	
    inst.components.edible.healthvalue = TUNING.HEALING_SUPERHUGE
    inst.components.edible.hungervalue = TUNING.CALORIES_SUPERHUGE
    inst.components.edible.foodstate = "COOKED"
    inst.components.edible:SetOnEatenFn(OnEaten_cooked)

    inst:AddTag("cooked")
    inst:AddTag("dead")
    
    inst.AnimState:PlayAnimation("cooked")
	return inst
end

return Prefab( "common/mandrake", defaultfn, assets, prefabs),
		Prefab("common/cookedmandrake", cookedfn, assets) 
