local assets =
{
	Asset("ANIM", "anim/balloons_empty.zip"),
	--Asset("SOUND", "sound/common.fsb"),
}
 
local prefabs =
{
	"balloon",
}    

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    local sound = inst.entity:AddSoundEmitter()
    anim:SetBank("balloons_empty")
    anim:SetBuild("balloons_empty")
    anim:PlayAnimation("idle")
    MakeInventoryPhysics(inst)

    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon( "balloons_empty.png" )
    
    
    inst:AddComponent("inventoryitem")
    -----------------------------------

    inst:AddComponent("characterspecific")
    inst.components.characterspecific:SetOwner("wes")
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("balloonmaker")
    inst:DoTaskInTime(0, function() if not GetPlayer() or GetPlayer().prefab ~= "wes" then inst:Remove() end end)
    return inst
end

return Prefab( "common/balloons_empty", fn, assets, prefabs) 
