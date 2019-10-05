local assets=
{
	Asset("ANIM", "anim/grass.zip"),
	Asset("ANIM", "anim/reeds.zip"),
	Asset("SOUND", "sound/common.fsb"),
}

local prefabs =
{
    "cutreeds",
}    

local function onpickedfn(inst)
    inst.SoundEmitter:PlaySound("dontstarve/wilson/pickup_reeds")
    inst.AnimState:PlayAnimation("picking")
    inst.AnimState:PushAnimation("picked")
end

local function onregenfn(inst)
    inst.AnimState:PlayAnimation("grow")
    inst.AnimState:PushAnimation("idle", true)
end

local function makeemptyfn(inst)
	inst.AnimState:PlayAnimation("picked")
end


local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    local sound = inst.entity:AddSoundEmitter()
	local minimap = inst.entity:AddMiniMapEntity()

	minimap:SetIcon( "reeds.png" )
    
    anim:SetBank("grass")
    anim:SetBuild("reeds")
    anim:PlayAnimation("idle",true)
    anim:SetTime(math.random()*2)
    local color = 0.75 + math.random() * 0.25
    anim:SetMultColour(color, color, color, 1)


    inst:AddComponent("pickable")
    inst.components.pickable.picksound = "dontstarve/wilson/pickup_reeds"
    inst.components.pickable:SetUp("cutreeds", TUNING.REEDS_REGROW_TIME)
	inst.components.pickable.onregenfn = onregenfn
	inst.components.pickable.onpickedfn = onpickedfn
    inst.components.pickable.makeemptyfn = makeemptyfn

    inst.components.pickable.SetRegenTime = 120

    inst:AddComponent("inspectable")
    
    
    ---------------------        
    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL
    
	MakeSmallBurnable(inst, TUNING.SMALL_FUEL)
    MakeSmallPropagator(inst)
	MakeNoGrowInWinter(inst)    
    ---------------------   
    
    return inst
end

return Prefab( "forest/objects/reeds", fn, assets, prefabs) 
