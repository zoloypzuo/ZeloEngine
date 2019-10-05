local assets =
{
	Asset("ANIM", "anim/marsh_bush.zip"),
	Asset("INV_IMAGE", "thorns_marsh"),
	Asset("MINIMAP_IMAGE", "thorns_marsh"),
}

local prefabs = 
{
    "twigs",
    "dug_marsh_bush",
}
local function ontransplantfn(inst)
	inst.components.pickable:MakeEmpty()
end


local function dig_up(inst, chopper)
	if inst.components.pickable and inst.components.pickable:CanBePicked() then
		inst.components.lootdropper:SpawnLootPrefab("twigs")
	end
	inst:Remove()
	local bush = inst.components.lootdropper:SpawnLootPrefab("dug_marsh_bush")
end

local function onpickedfn(inst, picker)
	inst.AnimState:PlayAnimation("picking") 
	inst.AnimState:PushAnimation("picked", false)
	if picker.components.combat and not picker:HasTag("bramble_resistant") then
        picker.components.combat:GetAttacked(inst, TUNING.MARSHBUSH_DAMAGE)
        picker:PushEvent("thorns")
	end
end

local function onregenfn(inst)
	inst.AnimState:PlayAnimation("grow") 
	inst.AnimState:PushAnimation("idle", true)
end

local function makeemptyfn(inst)
	inst.AnimState:PlayAnimation("idle_dead")
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()

	inst.entity:AddMiniMapEntity()
	inst.MiniMapEntity:SetIcon( "thorns_marsh.png" )

    anim:SetBuild("marsh_bush")
    anim:SetBank("marsh_bush")
    anim:PlayAnimation("idle", true)
    anim:SetTime(math.random()*2)

    local color = 0.5 + math.random() * 0.5
    anim:SetMultColour(color, color, color, 1)

    inst:AddComponent("pickable")
    inst.components.pickable.picksound = "dontstarve/wilson/harvest_sticks"
    
    inst.components.pickable:SetUp("twigs", TUNING.MARSHBUSH_REGROW_TIME)
	inst.components.pickable.onregenfn = onregenfn
	inst.components.pickable.onpickedfn = onpickedfn
    inst.components.pickable.makeemptyfn = makeemptyfn
	inst.components.pickable.ontransplantfn = ontransplantfn

	inst:AddComponent("lootdropper")
	inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetOnFinishCallback(dig_up)
    inst.components.workable:SetWorkLeft(1)
    
    inst:AddComponent("inspectable")
    
    MakeLargeBurnable(inst)
    MakeLargePropagator(inst)

    return inst
end

return Prefab( "marsh/objects/marsh_bush", fn, assets, prefabs) 
