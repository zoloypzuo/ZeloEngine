local assets=
{
	Asset("ANIM", "anim/shadow_skittish.zip"),
}

local function Disappear(inst)
    if inst.deathtask then
        inst.deathtask:Cancel()
        inst.deathtask = nil
    end
    inst.AnimState:PlayAnimation("disappear")
    inst:ListenForEvent("animover", function() inst:Remove() end)
end

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    inst:AddTag("NOCLICK")
    inst.AnimState:SetBank("shadowcreatures")
    inst.AnimState:SetBuild("shadow_skittish")
    inst.AnimState:PlayAnimation("idle_loop", true)
    inst.AnimState:SetMultColour(1, 1, 1, 0)
    
    inst.deathtask = inst:DoTaskInTime(5 + 10*math.random(), Disappear)
    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(5,8)
    inst.components.playerprox:SetOnPlayerNear(Disappear)
    inst:AddComponent("transparentonsanity")

return inst
end

return Prefab( "common/shadowskittish", fn, assets) 
