local assets = 
{
    Asset("ANIM", "anim/staff_purple_base.zip"),
}

local function ItemTradeTest(inst, item)
    if item.prefab == "purplegem" then
        return true
    end
    return false
end

local function OnGemGiven(inst, giver, item)
--Disable trading, enable picking.
    
    inst.SoundEmitter:PlaySound("dontstarve/common/telebase_hum", "hover_loop")
    inst.SoundEmitter:PlaySound("dontstarve/common/telebase_gemplace")
    inst.components.trader:Disable()
    inst.components.pickable:SetUp("purplegem", 1000000)
    inst.components.pickable:Pause()
    inst.components.pickable.caninteractwith = true
    inst.AnimState:PlayAnimation("idle_full_loop", true)

end

local function OnGemTaken(inst)

    inst.SoundEmitter:KillSound("hover_loop")
    inst.components.trader:Enable()
    inst.components.pickable.caninteractwith = false
    inst.AnimState:PlayAnimation("idle_empty")

end

local function DestroyGem(inst)

    inst.components.trader:Enable()
    inst.components.pickable.caninteractwith = false
    inst:DoTaskInTime(math.random() * 0.5, function() 
        inst.SoundEmitter:KillSound("hover_loop")
        inst.AnimState:ClearBloomEffectHandle()
        inst.AnimState:PlayAnimation("shatter")
        inst.AnimState:PushAnimation("idle_empty")
        inst.SoundEmitter:PlaySound("dontstarve/common/gem_shatter")
    end)

end

local function OnLoad(inst, data)
    if not inst.components.pickable.caninteractwith then
        OnGemTaken(inst)  
    else
        OnGemGiven(inst)
    end
end

local function getstatus(inst)
    if inst.components.pickable.caninteractwith then
        return "VALID"
    else
        return "GEMS"
    end
end

local function fn()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    anim:SetBank("staff_purple_base")
    anim:SetBuild("staff_purple_base")
    anim:PlayAnimation("idle_empty")
    
    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("pickable")
    inst.components.pickable.caninteractwith = false
    inst.components.pickable.onpickedfn = OnGemTaken

    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(ItemTradeTest)
    inst.components.trader.onaccept = OnGemGiven

    inst.DestroyGemFn = DestroyGem

    inst.OnLoad = OnLoad

    return inst
end  

return Prefab( "forest/objects/telebase/gemsocket", fn, assets)


