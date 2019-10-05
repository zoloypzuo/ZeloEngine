local assets =
{
	Asset("ANIM", "anim/plant_normal.zip"),

	-- products for buildswap
    Asset("ANIM", "anim/durian.zip"),
    Asset("ANIM", "anim/eggplant.zip"),
    Asset("ANIM", "anim/dragonfruit.zip"),
    Asset("ANIM", "anim/pomegranate.zip"),
    Asset("ANIM", "anim/corn.zip"),
    Asset("ANIM", "anim/pumpkin.zip"),
    Asset("ANIM", "anim/carrot.zip"),

}

require "prefabs/veggies"
   
local prefabs = {}

for k,v in pairs(VEGGIES) do
    table.insert(prefabs, k)
end

local function onmatured(inst)
	inst.SoundEmitter:PlaySound("dontstarve/common/farm_harvestable")
	inst.AnimState:OverrideSymbol("swap_grown", inst.components.crop.product_prefab,inst.components.crop.product_prefab.."01")
end
    
local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
    
    anim:SetBank("plant_normal")
    anim:SetBuild("plant_normal")
    anim:PlayAnimation("grow")
    
    inst:AddComponent("crop")
    inst.components.crop:SetOnMatureFn(onmatured)
    
    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = function(inst)
        if inst.components.crop:IsReadyForHarvest() then
            return "READY"
        else
            return "GROWING"
        end
    end
    
    anim:SetFinalOffset(-1)
    
    return inst
end

return Prefab( "common/objects/plant_normal", fn, assets, prefabs) 
