local assets =
{
	Asset("ANIM", "anim/grass.zip"),
}
    
local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    
    anim:SetBank( "grass" )
    anim:SetBuild( "grass1" )
    anim:PlayAnimation( "idle", true )
    anim:SetTime(math.random()*2)
    
    return inst
end

return Prefab( "common/objects/portal_level", fn, assets) 

