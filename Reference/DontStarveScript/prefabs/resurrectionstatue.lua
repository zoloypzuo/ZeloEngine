require "prefabutil"

local assets = {
    Asset("ANIM", "anim/wilsonstatue.zip"),
    Asset("MINIMAP_IMAGE", "resurrect"),
}

local function onhammered(inst, worker)
    if inst.components.lootdropper and not inst.components.resurrector.used then
        inst.components.lootdropper:DropLoot()
    end
    SpawnPrefab("collapse_big").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
    inst.components.resurrector.penalty = 0
    inst:Remove()

    -- Remove from save index
    SaveGameIndex:DeregisterResurrector(inst)

    if not inst.components.resurrector.used then
        local player = GetPlayer()
        if player then
            player.components.health:RecalculatePenalty()
        end
    end

end

local function makeused(inst)
    inst.AnimState:PlayAnimation("debris")
    inst.components.resurrector.penalty = 0
end

local function onhit(inst, worker)
    if not inst.components.resurrector.used then
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation("idle")
    end
end

local function doresurrect(inst, dude)
    inst:AddTag("busy")
    inst.persists = false
    inst:RemoveComponent("lootdropper")
    inst:RemoveComponent("workable")
    inst:RemoveComponent("inspectable")
    inst.MiniMapEntity:SetEnabled(false)
    if inst.Physics then
        RemovePhysicsColliders(inst)
    end

    GetClock():MakeNextDay()
    dude.Transform:SetPosition(inst.Transform:GetWorldPosition())
    dude:Hide()
    dude:ClearBufferedAction()

    if dude.HUD then
        dude.HUD:Hide()
    end
    if dude.components.playercontroller then
        dude.components.playercontroller:Enable(false)
    end

    TheCamera:SetDistance(12)
    dude.components.hunger:Pause()

    scheduler:ExecuteInTime(3, function()
        dude:Show()

        inst:Hide()
        inst.AnimState:PlayAnimation("debris")
        inst.components.resurrector.penalty = 0

        dude.sg:GoToState("rebirth")

        --SaveGameIndex:SaveCurrent()
        dude:DoTaskInTime(3, function()
            if dude.HUD then
                dude.HUD:Show()
            end
            if dude.components.hunger then
                dude.components.hunger:SetPercent(2 / 3)
            end

            if dude.components.health then
                dude.components.health:RecalculatePenalty()
                dude.components.health:Respawn(TUNING.RESURRECT_HEALTH)
                dude.components.health:SetInvincible(true)
            end

            if dude.components.sanity then
                dude.components.sanity:SetPercent(.5)
            end
            if dude.components.playercontroller then
                dude.components.playercontroller:Enable(true)
            end

            dude.components.hunger:Resume()

            TheCamera:SetDefault()
            inst:RemoveTag("busy")
        end)
        inst:DoTaskInTime(4, function()
            dude.components.health:SetInvincible(false)
            inst:Show()
        end)
        inst:DoTaskInTime(7, function()
            local tick_time = TheSim:GetTickTime()
            local time_to_erode = 4
            inst:StartThread(function()
                local ticks = 0
                while ticks * tick_time < time_to_erode do
                    local erode_amount = ticks * tick_time / time_to_erode
                    inst.AnimState:SetErosionParams(erode_amount, 0.1, 1.0)
                    ticks = ticks + 1
                    Yield()
                end
                inst:Remove()
            end)
        end)

    end)

end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle", false)
    inst.SoundEmitter:PlaySound("dontstarve/common/craftable/resurrectionstatue")
end

local function fn(Sim)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddSoundEmitter()

    MakeObstaclePhysics(inst, .3)

    inst.MiniMapEntity:SetIcon("resurrect.png")
    inst:AddTag("structure")

    inst.AnimState:SetBank("wilsonstatue")
    inst.AnimState:SetBuild("wilsonstatue")
    inst.AnimState:PlayAnimation("idle")

    inst:AddComponent("inspectable")
    inst:AddComponent("resurrector")
    inst.components.resurrector.active = true
    inst.components.resurrector.doresurrect = doresurrect
    inst.components.resurrector.makeusedfn = makeused
    inst.components.resurrector.penalty = 1

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)
    MakeSnowCovered(inst, .01)
    inst:ListenForEvent("onbuilt", onbuilt)

    return inst
end

return Prefab("common/objects/resurrectionstatue", fn, assets),
MakePlacer("common/resurrectionstatue_placer", "wilsonstatue", "wilsonstatue", "idle")
