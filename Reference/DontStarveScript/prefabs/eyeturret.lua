require "prefabutil"
require "brains/eyeturretbrain"
require "stategraphs/SGeyeturret"

local assets=
{
	Asset("ANIM", "anim/eyeball_turret.zip"),
    Asset("ANIM", "anim/eyeball_turret_object.zip"),
    Asset("MINIMAP_IMAGE", "eyeball_turret"),
}

local prefabs = 
{
    "eye_charge",
    "eyeturret_base",
}

local function retargetfn(inst)
    local newtarget = FindEntity(inst, 20, function(guy)
            return  guy.components.combat and 
                    inst.components.combat:CanTarget(guy) and
                    (guy.components.combat.target == GetPlayer() or GetPlayer().components.combat.target == guy)
    end)

    return newtarget
end


local function shouldKeepTarget(inst, target)
    if target and target:IsValid() and
        (target.components.health and not target.components.health:IsDead()) then
        local distsq = target:GetDistanceSqToInst(inst)
        return distsq < 20*20
    else
        return false
    end
end

local function OnAttacked(inst, data)
    local attacker = data and data.attacker
    if attacker == GetPlayer() then
        return
    end
    inst.components.combat:SetTarget(attacker)
    inst.components.combat:ShareTarget(attacker, 15, function(dude) return dude:HasTag("eyeturret") end, 10)
end

local function WeaponDropped(inst)
    inst:Remove()
end

local function EquipWeapon(inst)
    if inst.components.inventory and not inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
        local weapon = CreateEntity()
        weapon.entity:AddTransform()
        weapon:AddComponent("weapon")
        weapon.components.weapon:SetDamage(inst.components.combat.defaultdamage)
        weapon.components.weapon:SetRange(inst.components.combat.attackrange, inst.components.combat.attackrange+4)
        weapon.components.weapon:SetProjectile("eye_charge")
        weapon:AddComponent("inventoryitem")
        weapon.persists = false
        weapon.components.inventoryitem:SetOnDroppedFn(WeaponDropped)
        weapon:AddComponent("equippable")
        
        inst.components.inventory:Equip(weapon)
    end
end

local function ondeploy(inst, pt, deployer)
    local turret = SpawnPrefab("eyeturret") 
    if turret then 
        pt = Vector3(pt.x, 0, pt.z)
        turret.Physics:SetCollides(false)
        turret.Physics:Teleport(pt.x, pt.y, pt.z) 
        turret.Physics:SetCollides(true)
        turret.syncanim("place")
        turret.syncanimpush("idle_loop", true)
        turret.SoundEmitter:PlaySound("dontstarve/common/place_structure_stone")
        inst:Remove()
    end         
end

local function dotweenin(inst, l)
    inst.components.lighttweener:StartTween(nil, 0, .65, .7, nil, 0.15, 
        function(i, light) if light then light:Enable(false) end end)
end

local function syncanim(inst, animname, loop)
    inst.AnimState:PlayAnimation(animname, loop)
    inst.base.AnimState:PlayAnimation(animname, loop)
end

local function syncanimpush(inst, animname, loop)
    inst.AnimState:PushAnimation(animname, loop)
    inst.base.AnimState:PushAnimation(animname, loop)
end

local function itemfn(Sim)
    local inst = CreateEntity()
   
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("eyeball_turret_object")
    inst.AnimState:SetBuild("eyeball_turret_object")
    inst.AnimState:PlayAnimation("idle")

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    
    inst:AddTag("eyeturret")

    --Tag to make proper sound effects play on hit.
    inst:AddTag("largecreature")

    inst:AddComponent("deployable")
    inst.components.deployable.ondeploy = ondeploy
    inst.components.deployable.placer = "eyeturret_placer"
    
    return inst
end


local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
 	inst.entity:AddSoundEmitter()
    inst.Transform:SetFourFaced()

    MakeObstaclePhysics(inst, 1)
        
    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon("eyeball_turret.png")

	inst.base = inst:SpawnChild("eyeturret_base")

    inst:AddTag("eyeturret")
    inst:AddTag("companion")

    inst.syncanim = function(name, loop) syncanim(inst, name, loop) end
    inst.syncanimpush = function(name, loop) syncanimpush(inst, name, loop) end

    inst.AnimState:SetBank("eyeball_turret")
    inst.AnimState:SetBuild("eyeball_turret")
    
    inst.syncanim("idle_loop")

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.EYETURRET_HEALTH) 
    inst.components.health:StartRegen(TUNING.EYETURRET_REGEN, 1)
    
    inst:AddComponent("combat")
    inst.components.combat:SetRange(TUNING.EYETURRET_RANGE)
    inst.components.combat:SetDefaultDamage(TUNING.EYETURRET_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.EYETURRET_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(1, retargetfn)
    inst.components.combat:SetKeepTargetFunction(shouldKeepTarget)
    

    inst:AddComponent("lighttweener")
    local light = inst.entity:AddLight()
    inst.components.lighttweener:StartTween(light, 0, .65, .7, {251/255, 234/255, 234/255}, 0, 
        function(inst, light) if light then light:Enable(false) end end)

    inst.dotweenin = dotweenin

    MakeLargeFreezableCharacter(inst)
    
    inst:AddComponent("inventory")
    inst:DoTaskInTime(1, EquipWeapon)

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_TINY    
    
    inst:AddComponent("inspectable")
    inst:AddComponent("lootdropper")
    
    inst:ListenForEvent("attacked", OnAttacked)

    inst:SetStateGraph("SGeyeturret")
    local brain = require "brains/eyeturretbrain"
    inst:SetBrain(brain)

    return inst
end

local baseassets=
{
    Asset("ANIM", "anim/eyeball_turret_base.zip"),
}

local function basefn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("eyeball_turret_base")
    inst.AnimState:SetBuild("eyeball_turret_base")
    inst.AnimState:PlayAnimation("idle_loop")
    return inst
end


return Prefab( "common/eyeturret", fn, assets, prefabs),
Prefab("common/eyeturret_item", itemfn, assets, prefabs),
MakePlacer("common/eyeturret_placer", "eyeball_turret", "eyeball_turret", "idle_place"),
Prefab( "common/eyeturret_base", basefn, baseassets)