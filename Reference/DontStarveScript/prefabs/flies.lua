local assets =
{
	Asset("ANIM", "anim/flies.zip"),
}

local function onnear(inst)
    inst.SoundEmitter:KillSound("flies")
	inst.AnimState:PlayAnimation("swarm_pst")
end

local function onfar(inst)
    if not inst:IsInLimbo() then
        inst.SoundEmitter:PlaySound("dontstarve/common/flies", "flies")
	    inst.AnimState:PlayAnimation("swarm_pre")
        inst.AnimState:PushAnimation("swarm_loop", true)
    end
end        
        
local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    --inst.SoundEmitter:PlaySound("dontstarve/common/flies", "flies")
    
    inst.AnimState:SetBank("flies")
    inst.AnimState:SetBuild("flies")
    
    inst.AnimState:PlayAnimation("swarm_pre")
    inst.AnimState:PushAnimation("swarm_loop", true)
    
    inst:AddTag("NOCLICK")
    inst:AddTag("FX")
    
    inst:AddComponent("playerprox")
    
    inst.components.playerprox:SetDist(2,3)
    inst.components.playerprox:SetOnPlayerNear(onnear)
    inst.components.playerprox:SetOnPlayerFar(onfar)

    inst:ListenForEvent("enterlimbo", function() onnear(inst) end)

    return inst
end

return Prefab( "common/objects/flies", fn, assets) 

