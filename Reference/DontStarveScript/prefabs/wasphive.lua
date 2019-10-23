local prefabs = {
    "killerbee", --replace with wasp
}

local assets = {
    Asset("ANIM", "anim/wasphive.zip"),
    Asset("SOUND", "sound/bee.fsb"), --replace with wasp
}

local function OnIgnite(inst)
    if inst.components.childspawner then
        inst.components.childspawner:ReleaseAllChildren(nil, "killerbee")
        inst:RemoveComponent("childspawner")
    end
    inst.SoundEmitter:KillSound("loop")
    DefaultBurnFn(inst)
end

local function OnKilled(inst)
    inst:RemoveComponent("childspawner")
    inst.AnimState:PlayAnimation("cocoon_dead", true)
    inst.Physics:ClearCollisionMask()

    inst.SoundEmitter:KillSound("loop")

    inst.SoundEmitter:PlaySound("dontstarve/bee/beehive_destroy") --replace with wasp
    inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition())) --any loot drops?
end

local function onnear(inst)
    --hive pop open? Maybe rustle to indicate danger?
    --more and more come out the closer you get to the nest?
    if inst.components.childspawner then
        inst.components.childspawner:ReleaseAllChildren(GetPlayer(), "killerbee")
    end
end

local function onfar(inst)

end

local function onhitbyplayer(inst, attacker, damage)
    if inst.components.childspawner then
        inst.components.childspawner:ReleaseAllChildren(attacker, "killerbee")
    end
    if not inst.components.health:IsDead() then
        inst.SoundEmitter:PlaySound("dontstarve/bee/beehive_hit")
        inst.AnimState:PlayAnimation("cocoon_small_hit")
        inst.AnimState:PushAnimation("cocoon_small", true)
    end
end

local function OnEntityWake(inst)
    inst.SoundEmitter:PlaySound("dontstarve/bee/killerbee_hive_LP", "loop")
end

local function OnEntitySleep(inst)
    inst.SoundEmitter:KillSound("loop")
end

local function fn(Sim)
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    MakeObstaclePhysics(inst, 0.5)

    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon("wasphive.png") --replace with wasp version if there is one.

    anim:SetBank("wasphive")
    anim:SetBuild("wasphive")
    anim:PlayAnimation("cocoon_small", true)

    inst:AddTag("structure")
    inst:AddTag("hive")
    inst:AddTag("WORM_DANGER")

    -------------------------
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(250) --increase health?
    -------------------------
    inst:AddComponent("childspawner")
    --Set spawner to wasp. Change tuning values to wasp values.
    inst.components.childspawner.childspawner = "killerbee"
    inst.components.childspawner:SetMaxChildren(TUNING.WASPHIVE_WASPS)
    -------------------------
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({ "honey", "honey", "honey", "honeycomb" })
    -------------------------
    MakeLargeBurnable(inst)
    inst.components.burnable:SetOnIgniteFn(OnIgnite)
    -------------------------
    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(10, 13) --set specific values
    inst.components.playerprox:SetOnPlayerNear(onnear)
    inst.components.playerprox:Schedule()
    --inst.components.playerprox:SetOnPlayerFar(onfar)
    -------------------------
    inst:AddComponent("combat")
    --wasp hive should trigger on proximity, release wasps.
    inst.components.combat:SetOnHit(onhitbyplayer)
    inst:ListenForEvent("death", OnKilled)
    -------------------------
    MakeLargePropagator(inst)
    MakeSnowCovered(inst)
    -------------------------
    inst:AddComponent("inspectable")
    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake

    return inst
end

return Prefab("forest/monsters/wasphive", fn, assets, prefabs) 
