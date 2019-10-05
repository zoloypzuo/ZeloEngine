local assets=
{
	Asset("ANIM", "anim/broken_tool.zip"),
}

local function fn(Sim)
    
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddPhysics()
    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("broketool")
    inst.AnimState:SetBuild("broken_tool")
    inst.AnimState:PlayAnimation("used")
    
    inst:ListenForEvent("animover", function() inst:Remove() end)
    
return inst
end

return Prefab( "common/inventory/brokentool", fn, assets) 
