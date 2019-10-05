local assets=
{
	Asset("ANIM", "anim/slurtle_slime.zip"),
    Asset("ANIM", "anim/explode.zip"),
}

local prefabs =
{
    "explode_small"
}

local function OnIgniteFn(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_fuse_LP", "hiss")
end

local function OnExplodeFn(inst)
    local pos = Vector3(inst.Transform:GetWorldPosition())
    inst.SoundEmitter:KillSound("hiss")
    inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_explo")
    local explode = SpawnPrefab("explode_small")
    local pos = inst:GetPosition()
    explode.Transform:SetPosition(pos.x, pos.y, pos.z)
    explode.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )
    explode.AnimState:SetLightOverride(1)
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("slurtle_slime")
    inst.AnimState:SetBuild("slurtle_slime")
    inst.AnimState:PlayAnimation("idle")
    
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM    
    inst:AddComponent("inspectable")

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.MED_FUEL
    inst.components.fuel.fueltype = "CAVE"

    inst:AddComponent("inventoryitem")

    MakeSmallBurnable(inst, 3+math.random()*3)
    MakeSmallPropagator(inst)

    inst:AddComponent("explosive")
    inst.components.explosive:SetOnExplodeFn(OnExplodeFn)
    inst.components.explosive:SetOnIgniteFn(OnIgniteFn)
    inst.components.explosive.explosivedamage = TUNING.SLURTLESLIME_EXPLODE_DAMAGE
    inst.components.explosive.buildingdamage = 1
    inst.components.explosive.lightonexplode = false


    --[[local light = inst.entity:AddLight()
    light:SetFalloff(0.7)
    light:SetIntensity(.1)
    light:SetRadius(0.1)
    light:SetColour(237/255, 237/255, 209/255)
    light:Enable(true)
    --]]

	return inst
end

return Prefab( "common/inventory/slurtleslime", fn, assets, prefabs) 
