local assets=
{
	Asset("ANIM", "anim/gridplacer.zip"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.AnimState:SetBank("gridplacer")
	inst.AnimState:SetBuild("gridplacer")
	inst.AnimState:PlayAnimation("anim", true)
	
	inst:AddComponent("placer")
	inst.persists = false
	inst.components.placer.snap_to_tile = true
    inst.AnimState:SetLightOverride(1)
	inst.AnimState:SetOrientation( ANIM_ORIENTATION.OnGround )
	return inst
end
	
return Prefab( "common/gridplacer", fn, assets) 
 


