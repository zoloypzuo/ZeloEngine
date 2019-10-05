local assets=
{
	Asset("ANIM", "anim/diviningrod.zip"),
}

local function OnUnlock(inst)
    inst.components.lock.isstuck = true
    inst.AnimState:PlayAnimation("idle_full")
    inst.SoundEmitter:KillSound("pulse")
    inst.SoundEmitter:PlaySound("dontstarve/common/teleportato/teleportato_add_divining")
    local teleportato = TheSim:FindFirstEntityWithTag("teleportato")
    if teleportato then
        teleportato:PushEvent("powerup")
    end
end

local function OnLock(inst)
    inst.AnimState:PlayAnimation("idle_empty")
    inst.SoundEmitter:KillSound("pulse")
end

local function OnReady(inst)
    if inst.components.lock:IsLocked() then
        inst.AnimState:PlayAnimation("activate_loop", true)
        inst.SoundEmitter:PlaySound("dontstarve/common/teleportato/teleportato_pulse", "pulse")
        inst.components.lock.isstuck = false
    else
        OnUnlock(inst)
    end
end

local function describe(inst)
    if not inst.components.lock:IsStuck() then
        return "READY"
    elseif not inst.components.lock:IsLocked() then
        return "UNLOCKED"
    end
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)
    
    anim:SetBank("diviningrod")
    anim:SetBuild("diviningrod")
    anim:PlayAnimation("idle_empty")
    
    inst:AddTag("rodbase")
    
    inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = describe
    
    inst:AddComponent("lock")
    inst.components.lock.locktype = "maxwell"
    inst.components.lock.isstuck = true
    inst.components.lock:SetOnUnlockedFn(OnUnlock)
    inst.components.lock:SetOnLockedFn(OnLock)
    inst:ListenForEvent("ready", OnReady)
    
    return inst
end


return Prefab( "common/diviningrodbase", fn, assets) 

