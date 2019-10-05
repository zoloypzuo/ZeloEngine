local assets =
{
	Asset("ANIM", "anim/maxwell_build.zip"),
    Asset("ANIM", "anim/max_fx.zip"),
    Asset("ANIM", "anim/maxwell_basic.zip"),
	Asset("ANIM", "anim/maxwell_adventure.zip"),
	Asset("SOUND", "sound/maxwell.fsb"),
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
}

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	local shadow = inst.entity:AddDynamicShadow()
	shadow:SetSize( 1.75, .75 )
    inst.Transform:SetTwoFaced()

    anim:SetBank("maxwell")
    anim:SetBuild("maxwell_build")
    anim:PlayAnimation("appear")

    
    inst:AddComponent("talker")
    inst.components.talker.fontsize = 28
    inst.components.talker.font = TALKINGFONT
    inst.components.talker.colour = Vector3(133/255, 140/255, 167/255)
    inst.components.talker.offset = Vector3(0,-600,0)

    
    inst:AddComponent("inspectable")

    --inst:ListenForEvent( "ontalk", function(inst, data) inst.AnimState:PlayAnimation("dialog_pre") inst.AnimState:PushAnimation("dial_loop", true) end)
    --inst:ListenForEvent( "donetalking", function(inst, data) inst.AnimState:PlayAnimation("dialog_pst") inst.AnimState:PushAnimation("idle", true) end)
	inst.persists = false
    return inst
end

return Prefab( "common/characters/maxwell", fn, assets) 
