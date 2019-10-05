require "prefabutil"

local function CheckTemp(inst)
    if not inst.task then
	    inst.task = inst:DoPeriodicTask(1, CheckTemp)
	end
	local temp = GetSeasonManager() and GetSeasonManager():GetCurrentTemperature() or 30
	local high_temp = 35
	local low_temp = 0
	
	temp = math.min( math.max(low_temp, temp), high_temp)
	local percent = (temp + low_temp) / (high_temp - low_temp)
	inst.AnimState:SetPercent("meter", 1-percent)
end

local function onhammered(inst, worker)
	inst.components.lootdropper:DropLoot()
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
	inst:Remove()
end

local function onhit(inst, worker)
    if inst.task then
        inst.task:Cancel()
        inst.task = nil
    end
	inst.AnimState:PlayAnimation("hit")
	--the global animover handler will restart the check task
end

local function onbuilt(inst)
    if inst.task then
        inst.task:Cancel()
        inst.task = nil
    end
	inst.AnimState:PlayAnimation("place")
	inst.SoundEmitter:PlaySound("dontstarve/common/craftable/winter_meter")
	--the global animover handler will restart the check task
end

local assets = 
{
	Asset("ANIM", "anim/winter_meter.zip"),
}

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	
	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "winterometer.png" )
    
	MakeObstaclePhysics(inst, .4)
    
	anim:SetBank("winter_meter")
	anim:SetBuild("winter_meter")
	anim:SetPercent("meter", 0)

	inst:AddComponent("inspectable")
	
	inst:AddComponent("lootdropper")
	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)		
	MakeSnowCovered(inst, .01)
	
	CheckTemp(inst)

	inst:ListenForEvent("onbuilt", onbuilt)
	inst:ListenForEvent("animover", CheckTemp)
	
	return inst
end
return Prefab( "common/objects/winterometer", fn, assets),
	   MakePlacer("common/winterometer_placer", "winter_meter", "winter_meter", "idle" ) 


