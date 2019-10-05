local assets =
{
	Asset("ANIM", "anim/staff.zip"),
}

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.Transform:SetFourFaced()
    anim:SetBank("staff_fx")
    anim:SetBuild("staff")
    anim:PlayAnimation("staff")
    inst:AddTag("fx")
    inst:ListenForEvent( "animover", function(inst) inst:Remove() end )
    return inst
end

return Prefab("common/fx/staffcastfx", fn, assets) 
