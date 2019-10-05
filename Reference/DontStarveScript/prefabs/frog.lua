require "brains/frogbrain"
require "stategraphs/SGfrog"

local assets=
{
	Asset("ANIM", "anim/frog.zip"),
	Asset("SOUND", "sound/frog.fsb"),
}

local prefabs =
{
    "froglegs",
    "splash",
}
 

local function retargetfn(inst)
    if not inst.components.health:IsDead() and not inst.components.sleeper:IsAsleep() then
        return FindEntity(inst, TUNING.FROG_TARGET_DIST, function(guy) 
            if guy.components.combat and guy.components.health and not guy.components.health:IsDead() then
                return guy.components.inventory ~= nil
            end
        end)
    end
end

local function ShouldSleep(inst)
	return false -- frogs either go to their home, or just sit on the ground.
end


local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
    inst.components.combat:ShareTarget(data.attacker, 30, function(dude) return dude:HasTag("frog") and not dude.components.health:IsDead() end, 5)
end

local function OnGoingHome(inst)
    local fx = SpawnPrefab("splash")
    local pos = inst:GetPosition()
    fx.Transform:SetPosition(pos.x, pos.y, pos.z)

	--local splash = PlayFX(Vector3(inst.Transform:GetWorldPosition() ), "splash", "splash", "splash")
	inst.SoundEmitter:PlaySound("dontstarve/frog/splash")
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    local physics = inst.entity:AddPhysics()
	local sound = inst.entity:AddSoundEmitter()
	local shadow = inst.entity:AddDynamicShadow()
	shadow:SetSize( 1.5, .75 )
    inst.Transform:SetFourFaced()

    MakeCharacterPhysics(inst, 1, .3)
     
    anim:SetBank("frog")
    anim:SetBuild("frog")
    anim:PlayAnimation("idle")
    
	inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
	inst.components.locomotor.walkspeed = 4
	inst.components.locomotor.runspeed = 8

    inst:SetStateGraph("SGfrog")

    inst:AddTag("animal")
    inst:AddTag("prey")
    inst:AddTag("smallcreature")
    inst:AddTag("frog")
    inst:AddTag("canbetrapped")    

    local brain = require "brains/frogbrain"
    inst:SetBrain(brain)
    
    inst:AddComponent("sleeper")
	inst.components.sleeper:SetSleepTest(ShouldSleep)
    
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.FROG_HEALTH)
    
    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.FROG_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.FROG_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(3, retargetfn)

    inst.components.combat.onhitotherfn = function(inst, other, damage) inst.components.thief:StealItem(other) end
    
    inst:AddComponent("thief")
    
    MakeTinyFreezableCharacter(inst, "frogsack")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({"froglegs"})
    
    inst:AddComponent("knownlocations")
    inst:AddComponent("inspectable")

    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("goinghome", OnGoingHome)
    
    return inst
end

return Prefab( "forest/animals/frog", fn, assets, prefabs) 
