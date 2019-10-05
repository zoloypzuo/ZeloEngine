local assets =
{
	Asset("ANIM", "anim/fire_large_character.zip"),
	Asset("SOUND", "sound/common.fsb"),
}


local heats = { 50, 65, 80}
local function GetHeatFn(inst)
	return heats[inst.components.firefx.level] or 40
end


local firelevels = 
{
    {anim="loop_small", pre="pre_small", pst="post_small", sound="dontstarve/common/campfire", radius=2, intensity=.6, falloff=.7, colour = {197/255,197/255,170/255}, soundintensity=1},
    {anim="loop_med", pre="pre_med", pst="post_med",  sound="dontstarve/common/treefire", radius=3, intensity=.75, falloff=.5, colour = {255/255,255/255,192/255}, soundintensity=1},
	{anim="loop_large", pre="pre_large", pst="post_large",  sound="dontstarve/common/forestfire", radius=4, intensity=.8, falloff=.33, colour = {197/255,197/255,170/255}, soundintensity=1},        
}

local function fn(Sim)

	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	local light = inst.entity:AddLight()

    anim:SetBank("fire_large_character")
    anim:SetBuild("fire_large_character")
    anim:SetBloomEffectHandle( "shaders/anim.ksh" )
    inst.AnimState:SetRayTestOnBB(true)
    
    inst:AddTag("fx")
    inst:AddTag("NOCLICK")
    
    inst:AddComponent("firefx")
    inst.components.firefx.levels = firelevels


    inst:AddComponent("heater")
    inst.components.heater.heatfn = GetHeatFn

    anim:SetFinalOffset(-1)
    return inst
end

return Prefab( "common/fx/character_fire", fn, assets) 
