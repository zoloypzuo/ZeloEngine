local assets =
{
	Asset("ANIM", "anim/campfire_fire.zip"),
	Asset("SOUND", "sound/common.fsb"),
}

local heats = { 70, 120, 180, 220 }
local function GetHeatFn(inst)
	return heats[inst.components.firefx.level] or 20
end

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

    inst:AddComponent("heater")
    inst.components.heater.heatfn = GetHeatFn

    inst:AddComponent("firefx")
    inst.components.firefx.levels =
    {
        {anim="level1", sound="dontstarve/common/campfire", radius=2, intensity=.8, falloff=.33, colour = {255/255,255/255,192/255}, soundintensity=.1},
        {anim="level2", sound="dontstarve/common/campfire", radius=3, intensity=.8, falloff=.33, colour = {255/255,255/255,192/255}, soundintensity=.3},
        {anim="level3", sound="dontstarve/common/campfire", radius=4, intensity=.8, falloff=.33, colour = {255/255,255/255,192/255}, soundintensity=.6},
        {anim="level4", sound="dontstarve/common/campfire", radius=5, intensity=.8, falloff=.33, colour = {255/255,255/255,192/255}, soundintensity=1},
    }
    
    anim:SetFinalOffset(-1)
    inst.components.firefx:SetLevel(1)
    inst.components.firefx.usedayparamforsound = true
    return inst
end

return Prefab( "common/fx/campfirefire", fn, assets) 
