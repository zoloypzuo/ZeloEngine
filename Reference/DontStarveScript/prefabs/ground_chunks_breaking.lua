local assets =
{
	Asset("ANIM", "anim/ground_chunks_breaking.zip"),
}

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	
    anim:SetBank("ground_breaking")
    anim:SetBuild("ground_chunks_breaking")
    anim:PlayAnimation("idle")
    anim:SetFinalOffset(-1)
    inst:AddTag("fx")
    
    inst:ListenForEvent("animover", function(inst) inst:Remove() end)
    return inst
end

return Prefab("common/fx/ground_chunks_breaking", fn, assets) 
