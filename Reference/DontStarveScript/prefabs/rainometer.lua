require "prefabutil"

local function onhammered(inst, worker)
	inst.components.lootdropper:DropLoot()
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
	inst:Remove()
end

local function CheckRain(inst)
    if not inst.task then
	    inst.task = inst:DoPeriodicTask(1, CheckRain)
	end
	inst.AnimState:SetPercent("meter", GetSeasonManager():GetPOP())
end

local function onhit(inst, worker)
    if inst.task then
        inst.task:Cancel()
        inst.task = nil
    end
	inst.AnimState:PlayAnimation("hit")
	--the global animover handler will restart the check task
end


local assets = 
{
	Asset("ANIM", "anim/rain_meter.zip"),
}

local function onbuilt(inst)
    if inst.task then
        inst.task:Cancel()
        inst.task = nil
    end
	inst.AnimState:PlayAnimation("place")
	inst.SoundEmitter:PlaySound("dontstarve/common/craftable/rain_meter")
	--the global animover handler will restart the check task
end


local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	
	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "rainometer.png" )
    
	MakeObstaclePhysics(inst, .4)
    
	anim:SetBank("rain_meter")
	anim:SetBuild("rain_meter")
	anim:SetPercent("meter", 0)

	inst:AddComponent("inspectable")
	
	inst:AddComponent("lootdropper")
	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)		
	MakeSnowCovered(inst, .01)
	inst:ListenForEvent("onbuilt", onbuilt)
	inst:ListenForEvent("animover", CheckRain)
	
	CheckRain(inst)
	
	return inst
end
return Prefab( "common/objects/rainometer", fn, assets),
	   MakePlacer("common/rainometer_placer", "rain_meter", "rain_meter", "idle" ) 


