local assets =
{
    Asset("ANIM", "anim/beeswax.zip"),
}

local function _OnFireMelt(inst, StartFireMelt, StopFireMelt)
    inst.firemelttask = nil
    inst:RemoveEventCallback("firemelt", StartFireMelt)
    inst:RemoveEventCallback("stopfiremelt", StopFireMelt)
    if not inst.melted then
        if inst:IsAsleep() then
            inst:Remove()
        else
            inst.melted = true
            inst.persists = false
            inst.components.inventoryitem.canbepickedup = false
            inst:AddTag("NOCLICK")
            inst.AnimState:PlayAnimation("melt")
            inst:ListenForEvent("animover", inst.Remove)
            inst:ListenForEvent("entitysleep", inst.Remove)
        end
    end
end

local function StopFireMelt(inst)
    if inst.firemelttask ~= nil then 
        inst.firemelttask:Cancel()
        inst.firemelttask = nil
    end
end

local function StartFireMelt(inst)
    if inst.firemelttask == nil then
        inst.firemelttask = inst:DoTaskInTime(10, _OnFireMelt, StartFireMelt, StopFireMelt)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBuild("beeswax")
    inst.AnimState:SetBank("beeswax")
    inst.AnimState:PlayAnimation("idle")

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:ListenForEvent("firemelt", StartFireMelt)
    inst:ListenForEvent("stopfiremelt", StopFireMelt)
    inst:ListenForEvent("onputininventory", StopFireMelt)

    return inst
end

return Prefab("beeswax", fn, assets)