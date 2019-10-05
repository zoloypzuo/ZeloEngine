local assets =
{
	Asset("ANIM", "anim/splash_spiderweb.zip"),
}

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	
    anim:SetBank("splash_spiderweb")
    anim:SetBuild("splash_spiderweb")
    anim:PlayAnimation("idle")
    anim:SetFinalOffset(-1)
    inst:AddTag("fx")
    
    inst:ListenForEvent("animover", function(inst) inst:Remove() end)
    return inst
end

return Prefab("common/fx/splash_spiderweb", fn, assets) 
