require "stategraphs/SGeyeplant"

local assets =
{
	Asset("ANIM", "anim/eyeplant.zip"),
    Asset("SOUND", "sound/plant.fsb"),
}

local function checkmaster(tar, inst)
    if inst.minionlord then
        return tar == inst.minionlord
    end

    if tar.minionlord and inst.minionlord then
        return tar.minionlord == inst.minionlord
    else
        return false
    end
end

local function retargetfn(inst)
    return FindEntity(inst, TUNING.EYEPLANT_ATTACK_DIST, function(guy) 
        if guy.components.combat and guy.components.health and not guy.components.health:IsDead() then
            return (guy:HasTag("character") or guy:HasTag("monster") or guy:HasTag("animal") or guy:HasTag("prey") or guy:HasTag("eyeplant") or guy:HasTag("lureplant")) and not checkmaster(guy, inst) and not guy:HasTag("plantkin")
        end
    end)
end

local function shouldKeepTarget(inst, target)
    if target and target:IsValid() and target.components.health and not target.components.health:IsDead() then
        local distsq = target:GetDistanceSqToInst(inst)
        
        return distsq < TUNING.EYEPLANT_STOPATTACK_DIST*TUNING.EYEPLANT_STOPATTACK_DIST
    else
        return false
    end
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()

    inst.Transform:SetFourFaced()

    anim:SetBank("eyeplant")
    anim:SetBuild("eyeplant")
    anim:PlayAnimation("spawn")
    anim:PushAnimation("idle")

    inst:AddTag("eyeplant")
    inst:AddTag("veggie")
    inst:AddTag("smallcreature")
    inst:AddTag("hostile")

    MakeObstaclePhysics(inst, .1)

    inst:AddComponent("locomotor")
    inst.components.locomotor:SetSlowMultiplier( 1 )
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.pathcaps = { ignorecreep = true }
    inst.components.locomotor.walkspeed = 0

    inst:AddComponent("combat")
    inst.components.combat:SetAttackPeriod(TUNING.EYEPLANT_ATTACK_PERIOD)
    inst.components.combat:SetRange(TUNING.EYEPLANT_ATTACK_DIST)
    inst.components.combat:SetRetargetFunction(0.2, retargetfn)
    inst.components.combat:SetKeepTargetFunction(shouldKeepTarget)
    inst.components.combat:SetDefaultDamage(TUNING.EYEPLANT_DAMAGE)
    
    inst:ListenForEvent("newcombattarget", function(inst, data)
        if data.target and not inst.sg:HasStateTag("attack") and not inst.sg:HasStateTag("hit") and not inst.components.health:IsDead() then
            inst.sg:GoToState("attack")
        end
    end)

    inst:ListenForEvent("gotnewitem", function(inst, data)        
        --print ("got item", data.item)
        --print (debugstack())
        if data.item.components.health then
            inst:DoTaskInTime(0, function() local ba = BufferedAction(inst,data.item,ACTIONS.MURDER) 
            inst:PushBufferedAction(ba)
            end)
        end
    end)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.EYEPLANT_HEALTH)

    inst:AddComponent("eater")
    inst.components.eater:SetCarnivore()

    inst:AddComponent("inventory")

    inst:AddComponent("inspectable")

    inst:SetStateGraph("SGeyeplant")

    inst:AddComponent("lootdropper")

    MakeSmallBurnable(inst)
    MakeLargePropagator(inst)

	return inst
end

return Prefab("cave/eyeplant", fn, assets)
