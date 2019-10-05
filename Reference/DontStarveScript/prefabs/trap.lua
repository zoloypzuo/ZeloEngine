require "stategraphs/SGtrap"

local assets=
{
	Asset("ANIM", "anim/trap.zip"),
    Asset("SOUND", "sound/common.fsb"),
    Asset("MINIMAP_IMAGE", "rabbittrap"),
}

local sounds = 
{
    close = "dontstarve/common/trap_close",
    rustle = "dontstarve/common/trap_rustle",
}

local function onfinished(inst)
    inst:Remove()
end

local function onharvested(inst)
    if inst.components.finiteuses then
	    inst.components.finiteuses:Use(1)
    end
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)
    
    inst.entity:AddMiniMapEntity()
    inst.MiniMapEntity:SetIcon( "rabbittrap.png" )
   
    anim:SetBank("trap")
    anim:SetBuild("trap")
    anim:PlayAnimation("idle")
    inst.sounds = sounds
    
    inst:AddTag("trap")
    
    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.TRAP_USES)
    inst.components.finiteuses:SetUses(TUNING.TRAP_USES)
    inst.components.finiteuses:SetOnFinished( onfinished )
    
    inst:AddComponent("trap")
    inst.components.trap.targettag = "canbetrapped"
    inst.components.trap:SetOnHarvestFn(onharvested)
    
    inst:SetStateGraph("SGtrap")

    return inst
end

return Prefab( "common/inventory/trap", fn, assets) 
