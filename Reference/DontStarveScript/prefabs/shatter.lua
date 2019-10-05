local assets =
{
	Asset("ANIM", "anim/frozen_shatter.zip"),
}

local shatterlevels = 
{
    {anim="tiny"},
    {anim="small"},
    {anim="medium"},
	{anim="large"},        
	{anim="huge"},
}

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    inst.Transform:SetTwoFaced()
	
    anim:SetBank("frozen_shatter")
    anim:SetBuild("frozen_shatter")
    anim:SetFinalOffset(-1)
    inst:AddTag("fx")
    
    inst:AddComponent("shatterfx")
    inst.components.shatterfx.levels = shatterlevels
    
    inst:ListenForEvent("animover", function(inst) inst:Remove() end)
    
    inst.SoundEmitter:PlaySound("dontstarve/common/break_iceblock")
    return inst
end

return Prefab("common/fx/shatter", fn, assets) 
