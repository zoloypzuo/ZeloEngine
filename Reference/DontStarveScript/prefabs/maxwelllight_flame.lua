local assets =
{
	--Asset("ANIM", "anim/fire_large_character.zip"),
	Asset("ANIM", "anim/campfire_fire.zip"),
	Asset("SOUND", "sound/common.fsb"),
}

local firelevels = 
{
    {anim="level1", sound="dontstarve/common/maxlight", radius=1, intensity=.75, falloff= 1, colour = {207/255,234/255,245/255}, soundintensity=.1},
    {anim="level2", sound="dontstarve/common/maxlight", radius=1.5, intensity=.8, falloff=.9, colour = {207/255,234/255,245/255}, soundintensity=.3},
    {anim="level3", sound="dontstarve/common/maxlight", radius=2, intensity=.8, falloff=.8, colour = {207/255,234/255,245/255}, soundintensity=.6},
    {anim="level4", sound="dontstarve/common/maxlight", radius=2.5, intensity=.9, falloff=.7, colour = {207/255,234/255,245/255}, soundintensity=1},
    {anim="level1", sound="dontstarve/common/maxlight", radius=2, intensity=.75, falloff=.4, colour = {207/255,234/255,245/255}, soundintensity=.1},
    {anim="level2", sound="dontstarve/common/maxlight", radius=3, intensity=.8, falloff=.4, colour = {207/255,234/255,245/255}, soundintensity=.3},
    {anim="level3", sound="dontstarve/common/maxlight", radius=4, intensity=.8, falloff=.4, colour = {207/255,234/255,245/255}, soundintensity=.6},
    {anim="level4", sound="dontstarve/common/maxlight", radius=6, intensity=.9, falloff=.4, colour = {207/255,234/255,245/255}, soundintensity=1},
}

local function fn(Sim)

	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	local light = inst.entity:AddLight()

    inst:AddTag("NOCLICK")

    anim:SetBank("campfire_fire")
    anim:SetBuild("campfire_fire")
    anim:SetBloomEffectHandle( "shaders/anim.ksh" )
    inst.AnimState:SetRayTestOnBB(true)
    --inst.AnimState:SetMultColour(27/255,234/255,245/255, .6)
    
    inst:AddTag("fx")
    
    inst:AddComponent("firefx")
    inst.components.firefx.levels = firelevels
    inst.components.firefx.lightsound = "dontstarve/common/maxlightAddFuel"
    inst.components.firefx.extinguishsound =  "dontstarve/common/maxlightOut" 

    anim:SetFinalOffset(-1)
    return inst
end

return Prefab( "common/fx/maxwelllight_flame", fn, assets) 
