require "prefabutil"
require "recipes"

local assets =
{
	Asset("ANIM", "anim/pig_house.zip"),
    Asset("SOUND", "sound/pig.fsb"),
}

local prefabs = 
{
	"pigman",
}

local function LightsOn(inst)
    inst.Light:Enable(true)
    inst.AnimState:PlayAnimation("lit", true)
    inst.SoundEmitter:PlaySound("dontstarve/pig/pighut_lighton")
    inst.lightson = true
end

local function LightsOff(inst)
    inst.Light:Enable(false)
    inst.AnimState:PlayAnimation("idle", true)
    inst.SoundEmitter:PlaySound("dontstarve/pig/pighut_lightoff")
    inst.lightson = false
end

local function onfar(inst) 
    if inst.components.spawner:IsOccupied() then
        LightsOn(inst)
    end
end

local function getstatus(inst)
    if inst.components.spawner and inst.components.spawner:IsOccupied() then
        if inst.lightson then
            return "FULL"
        else
            return "LIGHTSOUT"
        end
    end
end

local function onnear(inst) 
    if inst.components.spawner:IsOccupied() then
        LightsOff(inst)
    end
end

local function onwere(child)
    if child.parent then
        child.parent.SoundEmitter:KillSound("pigsound")
        child.parent.SoundEmitter:PlaySound("dontstarve/pig/werepig_in_hut", "pigsound")
    end
end

local function onnormal(child)
    if child.parent then
        child.parent.SoundEmitter:KillSound("pigsound")
        child.parent.SoundEmitter:PlaySound("dontstarve/pig/pig_in_hut", "pigsound")
    end
end

local function onoccupied(inst, child)
	inst.SoundEmitter:PlaySound("dontstarve/pig/pig_in_hut", "pigsound")
    inst.SoundEmitter:PlaySound("dontstarve/common/pighouse_door")
	
    if inst.doortask then
        inst.doortask:Cancel()
        inst.doortask = nil
    end
	inst.doortask = inst:DoTaskInTime(1, function() if not inst.components.playerprox:IsPlayerClose() then LightsOn(inst) end end)
	if child then
	    inst:ListenForEvent("transformwere", onwere, child)
	    inst:ListenForEvent("transformnormal", onnormal, child)
	end
end

local function onvacate(inst, child)
    if inst.doortask then
        inst.doortask:Cancel()
        inst.doortask = nil
    end
    inst.SoundEmitter:PlaySound("dontstarve/common/pighouse_door")
    inst.SoundEmitter:KillSound("pigsound")
	
	if child then
	    inst:RemoveEventCallback("transformwere", onwere, child)
	    inst:RemoveEventCallback("transformnormal", onnormal, child)
        if child.components.werebeast then
		    child.components.werebeast:ResetTriggers()
		end
		if child.components.health then
		    child.components.health:SetPercent(1)
		end
	end    
end
        
        
local function onhammered(inst, worker)
    if inst.doortask then
        inst.doortask:Cancel()
        inst.doortask = nil
    end
	inst.components.spawner:ReleaseChild()
	inst.components.lootdropper:DropLoot()
	SpawnPrefab("collapse_big").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
	inst:Remove()
end

local function onhit(inst, worker)
	inst.AnimState:PlayAnimation("hit")
	inst.AnimState:PushAnimation("idle")
end

local function OnDay(inst)
    --print(inst, "OnDay")
    if inst.components.spawner:IsOccupied() then
        LightsOff(inst)
        if inst.doortask then
            inst.doortask:Cancel()
            inst.doortask = nil
        end
        inst.doortask = inst:DoTaskInTime(1 + math.random()*2, function() inst.components.spawner:ReleaseChild() end)
    end
end

local function onbuilt(inst)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("idle")
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    local light = inst.entity:AddLight()
    inst.entity:AddSoundEmitter()

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "pighouse.png" )
    light:SetFalloff(1)
    light:SetIntensity(.5)
    light:SetRadius(1)
    light:Enable(false)
    light:SetColour(180/255, 195/255, 50/255)
    
    MakeObstaclePhysics(inst, 1)

    anim:SetBank("pig_house")
    anim:SetBuild("pig_house")
    anim:PlayAnimation("idle", true)

    inst:AddTag("structure")
    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)
	
	inst:AddComponent( "spawner" )
    inst.components.spawner:Configure( "pigman", TUNING.TOTAL_DAY_TIME*4)
    inst.components.spawner.onoccupied = onoccupied
    inst.components.spawner.onvacate = onvacate
    inst:ListenForEvent( "daytime", function() OnDay(inst) end, GetWorld())    
    
	inst:AddComponent( "playerprox" )
    inst.components.playerprox:SetDist(10,13)
    inst.components.playerprox:SetOnPlayerNear(onnear)
    inst.components.playerprox:SetOnPlayerFar(onfar)
    
    inst:AddComponent("inspectable")
    
    inst.components.inspectable.getstatus = getstatus
	
	MakeSnowCovered(inst, .01)

	inst:ListenForEvent( "onbuilt", onbuilt)
    inst:DoTaskInTime(math.random(), function() 
        --print(inst, "spawn check day")
        if GetClock():IsDay() then 
            OnDay(inst)
        end 
    end)

    return inst
end

return Prefab( "common/objects/pighouse", fn, assets, prefabs ),
	   MakePlacer("common/pighouse_placer", "pig_house", "pig_house", "idle")  
