local assets =
{
	--Asset("ANIM", "anim/fire_large_character.zip"),
	Asset("ANIM", "anim/campfire_fire.zip"),
	Asset("SOUND", "sound/common.fsb"),
}

local firelevels = 
{
    {anim="level1", sound="dontstarve/common/nightlight", radius=2, intensity=.8, falloff=.33, colour = {253/255,179/255,179/255}, soundintensity=.1},
    {anim="level2", sound="dontstarve/common/nightlight", radius=3, intensity=.8, falloff=.33, colour = {253/255,179/255,179/255}, soundintensity=.3},
    {anim="level3", sound="dontstarve/common/nightlight", radius=4, intensity=.8, falloff=.33, colour = {253/255,179/255,179/255}, soundintensity=.6},
    {anim="level4", sound="dontstarve/common/nightlight", radius=5, intensity=.8, falloff=.33, colour = {253/255,179/255,179/255}, soundintensity=1},
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
    inst.AnimState:SetMultColour(0/255, 0/255, 0/255, .6)
    
    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    
    inst:AddComponent("firefx")
    inst.components.firefx.levels = firelevels

    anim:SetFinalOffset(-1)
    return inst
end

return Prefab( "common/fx/nightlight_flame", fn, assets) 
