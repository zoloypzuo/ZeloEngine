local assets=
{
	Asset("ANIM", "anim/pan_flute.zip"),
}

local function onfinished(inst)
    inst:Remove()
end

local function HearPanFlute(inst, musician, instrument)
	if inst.components.sleeper then
	    inst.components.sleeper:AddSleepiness(10, TUNING.PANFLUTE_SLEEPTIME)
	end
end


local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	
	inst:AddTag("flute")
    
    inst.AnimState:SetBank("pan_flute")
    inst.AnimState:SetBuild("pan_flute")
    inst.AnimState:PlayAnimation("idle")
    MakeInventoryPhysics(inst)
    
    inst:AddComponent("inspectable")
    inst:AddComponent("instrument")
    inst.components.instrument.range = TUNING.PANFLUTE_SLEEPRANGE
    inst.components.instrument:SetOnHeardFn(HearPanFlute)
    
    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.PLAY)
    
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.PANFLUTE_USES)
    inst.components.finiteuses:SetUses(TUNING.PANFLUTE_USES)
    inst.components.finiteuses:SetOnFinished( onfinished)
    inst.components.finiteuses:SetConsumption(ACTIONS.PLAY, 1)
        
    inst:AddComponent("inventoryitem")
    
    return inst
end

return Prefab( "common/inventory/panflute", fn, assets) 
