require "prefabutil"
require "recipes"

local assets =
{
	Asset("ANIM", "anim/rabbit_house.zip"),
    Asset("MINIMAP_IMAGE", "rabbit_house"),
}

local prefabs = 
{
	"bunnyman",
}


local function getstatus(inst)
    if inst.components.spawner and inst.components.spawner:IsOccupied() then
        if inst.lightson then
            return "FULL"
        end
    end
end

local function onoccupied(inst, child)
	--inst.SoundEmitter:PlaySound("dontstarve/pig/pig_in_hut", "pigsound")
    --inst.SoundEmitter:PlaySound("dontstarve/common/pighouse_door")
end

local function onvacate(inst, child)
    --inst.SoundEmitter:PlaySound("dontstarve/common/pighouse_door")
    --inst.SoundEmitter:KillSound("pigsound")
	
	if child then
		if child.components.health then
		    child.components.health:SetPercent(1)
		end
	end    
end
        
        
local function onhammered(inst, worker)

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


local function Empty(inst)
    --print(inst, "OnDay")
    if inst.components.spawner:IsOccupied() then
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
    inst.SoundEmitter:PlaySound("dontstarve/common/craftable/rabbit_hutch")
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    local light = inst.entity:AddLight()
    inst.entity:AddSoundEmitter()

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "rabbit_house.png" )
--{anim="level1", sound="dontstarve/common/campfire", radius=2, intensity=.75, falloff=.33, colour = {197/255,197/255,170/255}},
    light:SetFalloff(1)
    light:SetIntensity(.5)
    light:SetRadius(1)
    light:Enable(false)
    light:SetColour(180/255, 195/255, 50/255)
    
    MakeObstaclePhysics(inst, 1)

    anim:SetBank("rabbithouse")
    anim:SetBuild("rabbit_house")
    anim:PlayAnimation("idle", true)

    inst:AddTag("structure")
    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)
	
	inst:AddComponent( "spawner" )
    inst.components.spawner:Configure( "bunnyman", TUNING.TOTAL_DAY_TIME)
    inst.components.spawner.onoccupied = onoccupied
    inst.components.spawner.onvacate = onvacate
    inst:ListenForEvent( "dusktime", function() Empty(inst) end, GetWorld())    
    inst:ListenForEvent( "nighttime", function() Empty(inst) end, GetWorld())    
    
    inst:AddComponent("inspectable")
    
    inst.components.inspectable.getstatus = getstatus
	
	MakeSnowCovered(inst, .01)

	inst:ListenForEvent( "onbuilt", onbuilt)
    inst:DoTaskInTime(math.random(), function() 
        --print(inst, "spawn check day")
        if not GetClock():IsDay() then 
            Empty(inst)
        end 
    end)

    return inst
end

return Prefab( "common/objects/rabbithouse", fn, assets, prefabs ),
	   MakePlacer("common/rabbithouse_placer", "rabbithouse", "rabbit_house", "idle")  
