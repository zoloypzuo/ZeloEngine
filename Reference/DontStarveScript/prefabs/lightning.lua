local assets=
{
    Asset("ANIM", "anim/lightning.zip"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()

	inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )
	inst.AnimState:SetLightOverride(1)
	inst.Transform:SetScale(2,2,2)
    
    inst.AnimState:SetBank("lightning")
    inst.AnimState:SetBuild("lightning")
    inst.AnimState:PlayAnimation("anim")
    inst:AddTag("FX")
    inst.persists = false
    inst:ListenForEvent("animover", function() inst:Remove() end)

    inst:DoTaskInTime(0, function()
		GetClock():DoLightningLighting(.5)
		GetPlayer().SoundEmitter:PlaySound("dontstarve/rain/thunder_close")
		GetPlayer().components.playercontroller:ShakeCamera(inst, "FULL", 0.7, 0.02, .5, 40)
    end)

    return inst
end

return Prefab( "common/lightning", fn, assets) 
