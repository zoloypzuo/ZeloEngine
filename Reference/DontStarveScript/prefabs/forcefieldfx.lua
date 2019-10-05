local assets = 
{
   Asset("ANIM", "anim/forcefield.zip")
}

local function kill_fx(inst)
    inst.AnimState:PlayAnimation("close")
    inst.components.lighttweener:StartTween(nil, 0, .9, 0.9, nil, .2)
    inst:DoTaskInTime(0.6, function() inst:Remove() end)    
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    local sound = inst.entity:AddSoundEmitter()

    anim:SetBank("forcefield")
    anim:SetBuild("forcefield")
    anim:PlayAnimation("open")
    anim:PushAnimation("idle_loop", true)

    inst:AddComponent("lighttweener")
    local light = inst.entity:AddLight()
    inst.components.lighttweener:StartTween(light, 0, .9, 0.9, {1,1,1}, 0)
    inst.components.lighttweener:StartTween(nil, 3, .9, 0.9, nil, .2)

    inst.kill_fx = kill_fx

    sound:PlaySound("dontstarve/wilson/forcefield_LP", "loop")

    return inst
end

return Prefab( "common/forcefieldfx", fn, assets) 
