local assets=
{
	Asset("ANIM", "anim/horn.zip"),
}

local function onfinished(inst)
    inst:Remove()
end

local function TryAddFollower(leader, follower)
    if leader.components.leader
       and follower.components.follower
       and follower:HasTag("beefalo") and not follower:HasTag("baby")
       and leader.components.leader:CountFollowers("beefalo") < TUNING.HORN_MAX_FOLLOWERS then
        leader.components.leader:AddFollower(follower)
        follower.components.follower:AddLoyaltyTime(TUNING.HORN_EFFECTIVE_TIME+math.random())
        if follower.components.combat and follower.components.combat.target and follower.components.combat.target == leader then
            follower.components.combat:SetTarget(nil)
        end
        follower:DoTaskInTime(math.random(), function() follower.sg:PushEvent("heardhorn", {musician = leader} )end)
    end
end

local function HearHorn(inst, musician, instrument)
    if musician.components.leader then
        local herd = nil
        if inst:HasTag("beefalo") and not inst:HasTag("baby") and inst.components.herdmember then
            if inst.components.combat and inst.components.combat.target then
                inst.components.combat:GiveUp()
            end
            TryAddFollower(musician, inst)
            herd = inst.components.herdmember:GetHerd()
        end
        if herd and herd.components.herd then
            for k,v in pairs(herd.components.herd.members) do
                TryAddFollower(musician, k)
            end
        end
    end
end


local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	
	inst:AddTag("horn")
    
    inst.AnimState:SetBank("horn")
    inst.AnimState:SetBuild("horn")
    inst.AnimState:PlayAnimation("idle")
    MakeInventoryPhysics(inst)
    
    inst:AddComponent("inspectable")
    inst:AddComponent("instrument")
    inst.components.instrument.range = TUNING.HORN_RANGE
    inst.components.instrument:SetOnHeardFn(HearHorn)
    
    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.PLAY)
    
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.HORN_USES)
    inst.components.finiteuses:SetUses(TUNING.HORN_USES)
    inst.components.finiteuses:SetOnFinished( onfinished)
    inst.components.finiteuses:SetConsumption(ACTIONS.PLAY, 1)
        
    inst:AddComponent("inventoryitem")
    
    return inst
end

return Prefab( "common/inventory/horn", fn, assets) 
