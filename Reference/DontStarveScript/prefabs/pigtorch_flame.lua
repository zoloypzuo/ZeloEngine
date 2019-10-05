local assets =
{
	--Asset("ANIM", "anim/fire_large_character.zip"),
	Asset("ANIM", "anim/campfire_fire.zip"),
	Asset("SOUND", "sound/common.fsb"),
}

local firelevels = 
{
    {anim="level1", sound="dontstarve/common/campfire", radius=3, intensity=.8, falloff=.44, colour = {255/255,255/255,192/255}, soundintensity=.1},
    {anim="level2", sound="dontstarve/common/campfire", radius=4, intensity=.8, falloff=.44, colour = {255/255,255/255,192/255}, soundintensity=.6},
    {anim="level3", sound="dontstarve/common/campfire", radius=5, intensity=.8, falloff=.44, colour = {255/255,255/255,192/255}, soundintensity=1},
}

local function fn(Sim)

	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	local light = inst.entity:AddLight()

    anim:SetBank("campfire_fire")
    anim:SetBuild("campfire_fire")
    anim:SetBloomEffectHandle( "shaders/anim.ksh" )
    inst.AnimState:SetRayTestOnBB(true)
    
    inst:AddTag("fx")
    
    inst:AddComponent("firefx")
    inst.components.firefx.levels = firelevels

    anim:SetFinalOffset(-1)
    return inst
end

return Prefab( "common/fx/pigtorch_flame", fn, assets) 
