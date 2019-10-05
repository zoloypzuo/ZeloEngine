local assets =
{
	Asset("ANIM", "anim/pumpkin_lantern.zip"),
    Asset("INV_IMAGE", "pumpkin_lantern"),
}

local prefabs = 
{
	"fireflies",
}

local INTENSITY = .8

local function flicker_stop(inst)
    if inst.flickertask then
		inst.flickertask:Cancel()
		inst.flickertask = nil
	end
end

local function flicker_update(inst)
    local time = GetTime()*30
	local flicker = ( math.sin( time ) + math.sin( time + 2 ) + math.sin( time + 0.7777 ) ) / 2.0 -- range = [-1 , 1]
	flicker = ( 1.0 + flicker ) / 2.0 -- range = 0:1
    inst.Light:SetRadius( 1.5 + 0.1 * flicker)
    inst.flickertask = inst:DoTaskInTime(0.1, function() flicker_update(inst) end)
end

local function fade_in(inst)
    inst.components.fader:StopAll()
    inst.AnimState:PlayAnimation("idle_night_pre")
    inst.AnimState:PushAnimation("idle_night_loop", true)
    inst.Light:Enable(true)
    flicker_stop(inst)
    flicker_update(inst)
    inst.components.fader:Fade(0, INTENSITY, 5*FRAMES, function(v) inst.Light:SetIntensity(v) end)
end

local function fade_out(inst)
    inst.components.fader:StopAll()
    inst.AnimState:PlayAnimation("idle_night_pst")
    inst.AnimState:PushAnimation("idle_day", false)
    flicker_stop(inst)
    inst.components.fader:Fade(INTENSITY, 0, 5*FRAMES, function(v) inst.Light:SetIntensity(v) end, function() inst.Light:Enable(false) end)
end

local function ondeath(inst)
	inst.components.fader:StopAll()
	inst.Light:Enable(false)
	inst.components.perishable:StopPerishing()
    if not inst:HasTag("rotten") then
        inst.AnimState:PlayAnimation("broken")
        inst.SoundEmitter:PlaySound("dontstarve/common/vegi_smash")
		inst.components.lootdropper:SpawnLootPrefab("fireflies")
    end
end

local function onperish(inst)
	inst:AddTag("rotten")
	inst.components.health:Kill()
	inst.AnimState:PlayAnimation("rotten")
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	
	inst:AddTag("veggie")
    
    local isday = GetClock():IsDay()
    inst.entity:AddPhysics()
    MakeInventoryPhysics(inst)
 
    local light = inst.entity:AddLight()
    light:SetFalloff(.5)
    light:SetIntensity(INTENSITY)
    light:SetRadius(1.5)
    light:Enable(false)
    light:SetColour(200/255, 100/255, 170/255)
    
    inst.AnimState:SetBank("pumpkin")
    inst.AnimState:SetBuild("pumpkin_lantern")
    inst.AnimState:PlayAnimation("idle_day")
    
    inst:AddComponent("fader")

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.nobounce = true
    
    inst:AddComponent("combat")
    inst:AddComponent("health")
    inst.components.health.canmurder = false
    inst:AddComponent("lootdropper")
    inst.components.health:SetMaxHealth(1)
    inst:ListenForEvent("death", ondeath)
    

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(30*TUNING.SEG_TIME)
    inst.components.perishable:SetOnPerishFn(onperish)
    inst.components.inventoryitem:SetOnDroppedFn(function(inst)
		inst.components.perishable:StartPerishing()
		if not GetClock():IsDay() then
			fade_in(inst)
		end
    end)
    inst.components.inventoryitem:SetOnPutInInventoryFn(function(inst)
		inst.components.perishable:StopPerishing()
		fade_out(inst)
    end)
    
    inst:ListenForEvent( "daytime", function()
        if not inst.components.inventoryitem.owner and not inst.components.health:IsDead() and not inst:HasTag("rotten") then
            inst:DoTaskInTime(2+math.random()*1, function() fade_out(inst) end)
        end
    end, GetWorld())
    
    inst:ListenForEvent( "dusktime", function()
        if not inst.components.inventoryitem.owner and not inst.components.health:IsDead() and not inst:HasTag("rotten") then
            inst:DoTaskInTime(2+math.random()*1, function() if not inst.components.inventoryitem.owner then fade_in(inst) end end)
        end
    end, GetWorld())
        
    if not inst.components.inventoryitem.owner and not isday then
        fade_in(inst)
    end
    
    return inst
end

return Prefab( "common/objects/pumpkin_lantern", fn, assets, prefabs) 

