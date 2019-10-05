local assets =
{
    Asset("ANIM", "anim/spat_basic.zip"),
    Asset("ANIM", "anim/spat_actions.zip"),
    Asset("ANIM", "anim/spat_build.zip"),
    Asset("ANIM", "anim/spat_phlegm.zip"),
    Asset("SOUND", "sound/beefalo.fsb"),
}

local prefabs =
{
    "meat",
    "poop",
    "steelwool",
    "phlegm",
    "spat_bomb",
}

local projectile_assets =
{
    Asset("ANIM", "anim/spat_bomb.zip"),
}

local projectile_prefabs =
{
    "spat_splat_fx",
    "spat_splash_fx_full",
    "spat_splash_fx_med",
    "spat_splash_fx_low",
    "spat_splash_fx_melted",
}

local brain = require("brains/spatbrain")

SetSharedLootTable( 'spat',
{
    {'meat',            1.00},
    {'meat',            1.00},
    {'meat',            1.00},
    {'meat',            1.00},
    {'steelwool',       1.00},
    {'steelwool',       1.00},
    {'steelwool',       0.50},
    {'phlegm',          1.00},
    {'phlegm',          0.50},
})

local sounds =
{
    walk = "dontstarve/creatures/spat/walk",
    grunt = "dontstarve/creatures/spat/grunt",
    yell = "dontstarve/creatures/spat/yell",
    hit = "dontstarve/creatures/spat/hurt",
    death = "dontstarve/creatures/spat/death",
    curious = "dontstarve/creatures/spat/curious",
    sleep = "dontstarve/creatures/spat/sleep",
    angry = "dontstarve/creatures/spat/angry",
    spit = "dontstarve/creatures/spat/spit",
    spit_hit = "dontstarve/creatures/spat/spit_hit",
}

local function Retarget(inst)
    return FindEntity(
        inst,
        TUNING.SPAT_TARGET_DIST,
        function(guy)
            return inst.components.combat:CanTarget(guy)
        end,
        nil,
        nil,
        { "player", "monster" }
    )
end

local function KeepTarget(inst, target)
    return target:IsNear(inst, TUNING.SPAT_CHASE_DIST)
end

local function OnAttacked(inst, data)
    local target = inst.components.combat.target
    if target ~= nil and target.components.pinnable ~= nil and target.components.pinnable:IsStuck() then
        -- if we've goo'd someone, stay attacking them!
        return
    end

    inst.components.combat:SetTarget(data.attacker)
end

local function EquipWeapons(inst)
    if inst.components.inventory ~= nil and not inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
        local snotbomb = CreateEntity()
        snotbomb.name = "Snotbomb"
        snotbomb.entity:AddTransform()
        MakeInventoryPhysics(snotbomb)
        snotbomb:AddComponent("weapon")
        snotbomb.components.weapon:SetDamage(TUNING.SPAT_PHLEGM_DAMAGE)
        snotbomb.components.weapon:SetRange(TUNING.SPAT_PHLEGM_ATTACKRANGE)
        snotbomb.components.weapon:SetProjectile("spat_bomb")
        snotbomb:AddComponent("inventoryitem")
        snotbomb.persists = false
        snotbomb.components.inventoryitem:SetOnDroppedFn(snotbomb.Remove)
        snotbomb:AddComponent("equippable")
        snotbomb:AddTag("snotbomb")

        inst.components.inventory:GiveItem(snotbomb)
        inst.weaponitems.snotbomb = snotbomb

        local meleeweapon = CreateEntity()
        meleeweapon.name = "Snaut Bash"
        meleeweapon.entity:AddTransform()
        MakeInventoryPhysics(meleeweapon)
        meleeweapon:AddComponent("weapon")
        meleeweapon.components.weapon:SetDamage(TUNING.SPAT_MELEE_DAMAGE)
        meleeweapon.components.weapon:SetRange(TUNING.SPAT_MELEE_ATTACKRANGE)
        meleeweapon:AddComponent("inventoryitem")
        meleeweapon.persists = false
        meleeweapon.components.inventoryitem:SetOnDroppedFn(meleeweapon.Remove)
        meleeweapon:AddComponent("equippable")
        meleeweapon:AddTag("meleeweapon")

        inst.components.inventory:GiveItem(meleeweapon)
        inst.weaponitems.meleeweapon = meleeweapon
    end
end

local function CustomOnHaunt(inst)
    inst.components.periodicspawner:TrySpawn()
    return true
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()

    MakeCharacterPhysics(inst, 100, .5)

    inst.DynamicShadow:SetSize(6, 2)
    inst.Transform:SetSixFaced()

    inst.AnimState:SetBank("spat")
    inst.AnimState:SetBuild("spat_build")
    inst.AnimState:PlayAnimation("idle_loop", true)

    inst:AddTag("spat")
    inst:AddTag("animal")
    inst:AddTag("largecreature")

    inst.sounds = sounds

    inst:AddComponent("eater")
    inst.components.eater.foodprefs = { "VEGGIE" }
    inst.components.eater.ablefoods = { "VEGGIE" }
    

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "spat_body"
    inst.components.combat:SetRetargetFunction(1, Retarget)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)
    inst.components.combat:SetAttackPeriod(3)
    inst.components.combat:SetHurtSound(sounds.hit)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.SPAT_HEALTH)

    inst:AddComponent("inventory")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('spat')    

    inst:AddComponent("inspectable")

    inst:ListenForEvent("attacked", OnAttacked)

    inst:AddComponent("periodicspawner")
    inst.components.periodicspawner:SetPrefab("poop")
    inst.components.periodicspawner:SetRandomTimes(40, 60)
    inst.components.periodicspawner:SetDensityInRange(20, 2)
    inst.components.periodicspawner:SetMinimumSpacing(8)
    inst.components.periodicspawner:Start()

    MakeLargeBurnableCharacter(inst, "spat_body")
    MakeLargeFreezableCharacter(inst, "spat_body")

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.walkspeed = 1.5
    inst.components.locomotor.runspeed = 7

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(3)

    inst:SetBrain(brain)
    inst:SetStateGraph("SGspat")

    inst.weaponitems = {}
    EquipWeapons(inst)

    return inst
end

local function doprojectilehit(inst, attacker, other)
    inst.SoundEmitter:PlaySound(sounds.spit_hit)
    local x, y, z = inst.Transform:GetWorldPosition()
    SpawnPrefab("spat_splat_fx").Transform:SetPosition(x, 0, z)

    if attacker ~= nil and not attacker:IsValid() then
        attacker = nil
    end

    -- stick whatever got actually hit by the projectile
    -- otherwise stick our target, if he was in splash radius
    if other == nil and attacker ~= nil then
        other = attacker.components.combat.target
        if other ~= nil and not (other:IsValid() and other:IsNear(inst, TUNING.SPAT_PHLEGM_RADIUS)) then
            other = nil
        end
    end

    if other ~= nil and other:IsValid() then
        if attacker ~= nil then
            attacker.components.combat:DoAttack(other, inst.components.complexprojectile.owningweapon, inst)
        end
        if other.components.pinnable then
            other.components.pinnable:Stick()
        end
    end

    return other
end

local function OnProjectileHit(inst, attacker, other)
    doprojectilehit(inst, attacker, other)
    inst:Remove()
end

local function oncollide(inst, other)
    -- If there is a physics collision, try to do some damage to that thing.
    -- This is so you can't hide forever behind walls etc.
    local attacker = inst.components.complexprojectile.attacker
    if other ~= doprojectilehit(inst, attacker, other) and
        other ~= nil and
        other:IsValid() and
        other.components.combat ~= nil then
        if attacker ~= nil and attacker:IsValid() then
            attacker.components.combat:DoAttack(other, inst.components.complexprojectile.owningweapon, inst)
        end
        if other.components.pinnable ~= nil then
            other.components.pinnable:Stick()
        end
    end

    inst:Remove()
end

local function projectilefn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    MakeCharacterPhysics(inst, 1, 0.02)
    inst.Physics:SetMass(1)
    inst.Physics:SetFriction(10)
    inst.Physics:SetCapsule(0.02, 0.02)

    inst.AnimState:SetBank("spat_bomb")
    inst.AnimState:SetBuild("spat_bomb")
    inst.AnimState:PlayAnimation("spin_loop", true)

    inst.Physics:SetCollisionCallback(oncollide)

    inst.persists = false

    inst:AddComponent("locomotor")
    inst:AddComponent("complexprojectile")
    inst.components.complexprojectile:SetOnHit(OnProjectileHit)
    inst.components.complexprojectile:SetHorizontalSpeed(30)
    inst.components.complexprojectile:SetLaunchOffset(Vector3(3, 2, 0))
    inst.components.complexprojectile.usehigharc = false

    return inst
end

return Prefab("spat", fn, assets, prefabs),
    Prefab("spat_bomb", projectilefn, projectile_assets, projectile_prefabs)
