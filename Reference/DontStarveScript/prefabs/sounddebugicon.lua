local assets =
{
	Asset("ANIM", "anim/sounddebug.zip"),
}

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.entity:AddLabel()

    inst.Label:SetFontSize(20)
    inst.Label:SetFont(DEFAULTFONT)
    inst.Label:SetPos(0,0,0)
    inst.Label:SetColour(.73, .05, .02)
    inst.Label:Enable(true)
	
    anim:SetBank("sound")
    anim:SetBuild("sounddebug")
    anim:PlayAnimation("idle")
    anim:SetFinalOffset(-1)
    inst:AddTag("fx")
    inst.persists = false
    
    inst.autokilltask = inst:DoTaskInTime(0.5, function(inst) inst:Remove() end)
    return inst
end

return Prefab("debug/sounddebugicon", fn, assets) 
