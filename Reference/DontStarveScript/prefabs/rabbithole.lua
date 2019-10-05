local assets =
{
	Asset("ANIM", "anim/rabbit_hole.zip"),
}

local prefabs = 
{
	"rabbit",
}


local function dig_up(inst, chopper)
	if inst.components.spawner:IsOccupied() then
		inst.components.lootdropper:SpawnLootPrefab("rabbit")
	end
	inst:Remove()
end

local function startspawning(inst)
    if inst.components.spawner then
        inst.components.spawner:SpawnWithDelay(60 + math.random(120) )
    end
end

local function stopspawning(inst)
    if inst.components.spawner then
        inst.components.spawner:CancelSpawning()
    end
end

local function onoccupied(inst)
    if GetClock():IsDay() then
        startspawning(inst)
    end
end

local function GetChild(inst)
	return "rabbit"
end

  
local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()

    anim:SetBank("rabbithole")
    anim:SetBuild("rabbit_hole")
    anim:PlayAnimation("idle")
	--anim:SetOrientation( ANIM_ORIENTATION.OnGround )
	anim:SetLayer( LAYER_BACKGROUND )
	anim:SetSortOrder( 3 )

	inst:AddComponent( "spawner" )
	inst.components.spawner:Configure( "rabbit", TUNING.RABBIT_RESPAWN_TIME)
	inst.components.spawner.childfn = GetChild
	
	inst.components.spawner:SetOnOccupiedFn(onoccupied)
	inst.components.spawner:SetOnVacateFn(stopspawning)
    
	inst:AddComponent("lootdropper")
	inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetOnFinishCallback(dig_up)
    inst.components.workable:SetWorkLeft(1)
    
	inst:ListenForEvent( "dusktime", function() stopspawning(inst) end, GetWorld())
	inst:ListenForEvent( "daytime", function() startspawning(inst) end, GetWorld())
	
    inst:AddComponent("inspectable")
	
    return inst
end

return Prefab( "common/objects/rabbithole", fn, assets, prefabs ) 
