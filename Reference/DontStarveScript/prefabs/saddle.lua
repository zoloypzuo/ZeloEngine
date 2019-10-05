
local function ondiscarded(inst)
    inst.components.finiteuses:Use()
end

local function onusedup(inst)
    SpawnPrefab("ground_chunks_breaking").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst:Remove()
end

local function MakeSaddle(name, data)
    local assets = {
        Asset("ANIM", "anim/"..name..".zip"),
    }

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("saddlebasic")
        inst.AnimState:SetBuild(name)
        inst.AnimState:PlayAnimation("idle")

        inst.mounted_foleysound = "dontstarve/beefalo/saddle/"..data.foley

        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")

        inst:AddComponent("saddler")
        inst.components.saddler:SetBonusDamage(data.bonusdamage)
        inst.components.saddler:SetBonusSpeedMult(data.speedmult)
        inst.components.saddler:SetSwaps(name, "swap_saddle")
        inst.components.saddler:SetDiscardedCallback(ondiscarded)

        inst:AddComponent("finiteuses")
        inst.components.finiteuses:SetMaxUses(data.uses)
        inst.components.finiteuses:SetUses(data.uses)
        inst.components.finiteuses:SetOnFinished(onusedup)

        return inst
    end

    return Prefab(name, fn, assets)
end

local data = {
    basic = {
        bonusdamage = TUNING.SADDLE_BASIC_BONUS_DAMAGE,
        foley = "regular_foley",
        uses = TUNING.SADDLE_BASIC_USES,
        speedmult = TUNING.SADDLE_BASIC_SPEEDMULT,
    },
    war = {
        bonusdamage = TUNING.SADDLE_WAR_BONUS_DAMAGE,
        foley = "war_foley",
        uses = TUNING.SADDLE_WAR_USES,
        speedmult = TUNING.SADDLE_WAR_SPEEDMULT,
    },
    race = {
        bonusdamage = TUNING.SADDLE_RACE_BONUS_DAMAGE,
        foley = "race_foley",
        uses = TUNING.SADDLE_RACE_USES,
        speedmult = TUNING.SADDLE_RACE_SPEEDMULT,
    },
}

return  MakeSaddle("saddle_basic", data.basic),
        MakeSaddle("saddle_war", data.war),
        MakeSaddle("saddle_race", data.race)
