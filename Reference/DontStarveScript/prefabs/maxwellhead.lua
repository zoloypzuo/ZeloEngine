local assets = 
{
	Asset("ANIM", "anim/maxwell_floatinghead.zip"),
	Asset("SOUND", "sound/maxwell.fsb"),
}

local SPEECH =
{
	NULL_SPEECH=
	{
		--appearanim = "appear",
		idleanim= "idle_loop",
		--dialogpreanim = "dialog_pre",
		dialoganim="dialog_loop",
		--dialogpostanim = "dialog_pst",
		disappearanim = "disappear",
		{
			string = "You forgot to set a speech.",
			wait = 2
		},
		{
			string = "Go do it.",
			wait = 1
		},
	},
	SPEECH_1 =
	{
		--appearanim = "appear",
		idleanim= "idle_loop",
		--dialogpreanim = "dialog_pre",
		dialoganim="dialog_loop",
		--dialogpostanim = "dialog_pst",
		disappearanim = "disappear",
		{
			string = STRINGS.MAXWELL_ADVENTURE_HEAD.LEVEL_6.ONE,
			wait = 3
		},
	},
	SPEECH_2 =
	{
		--appearanim = "appear",
		idleanim= "idle_loop",
		--dialogpreanim = "dialog_pre",
		dialoganim="dialog_loop",
		--dialogpostanim = "dialog_pst",
		disappearanim = "disappear",
		{
			string = STRINGS.MAXWELL_ADVENTURE_HEAD.LEVEL_6.TWO.ONE,
			wait = 3
		},
		{
			string = STRINGS.MAXWELL_ADVENTURE_HEAD.LEVEL_6.TWO.TWO,
			wait = 3
		},
	},
	SPEECH_3 =
	{
		--appearanim = "appear",
		idleanim= "idle_loop",
		--dialogpreanim = "dialog_pre",
		dialoganim="dialog_loop",
		--dialogpostanim = "dialog_pst",
		disappearanim = "disappear",
		{
			string = STRINGS.MAXWELL_ADVENTURE_HEAD.LEVEL_6.THREE.ONE,
			wait = 3
		},
		{
			string = STRINGS.MAXWELL_ADVENTURE_HEAD.LEVEL_6.THREE.TWO,
			wait = 1
		},
	},
	SPEECH_4 =
	{
		--appearanim = "appear",
		idleanim= "idle_loop",
		--dialogpreanim = "dialog_pre",
		dialoganim="dialog_loop",
		--dialogpostanim = "dialog_pst",
		disappearanim = "disappear",
		{
			string = STRINGS.MAXWELL_ADVENTURE_HEAD.LEVEL_6.FOUR.ONE,
			wait = 3
		},
		{
			string = STRINGS.MAXWELL_ADVENTURE_HEAD.LEVEL_6.FOUR.TWO,
			wait = 4
		},
	},
}

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	local shadow = inst.entity:AddDynamicShadow()
	shadow:SetSize( 1.75, .75 )
    inst.Transform:SetTwoFaced()

    anim:SetBank("maxwell_floatinghead")
    anim:SetBuild("maxwell_floatinghead")
    --anim:PlayAnimation("appear")
    anim:PlayAnimation("idle_loop", true)
    --inst:DoTaskInTime(0.3, function() sound:PlaySound("dontstarve/maxwell/disappear") end)	

    inst.entity:AddLabel()
    inst.Label:SetFontSize(28)
    inst.Label:SetFont(TALKINGFONT)
    inst.Label:SetPos(0,5,0)    
    inst.Label:Enable(false)

	inst:AddComponent("talker")
	inst:AddComponent("inspectable")

	print(inst.speech)

	inst:AddComponent("maxwelltalker")
    inst.components.maxwelltalker.speeches = SPEECH
    inst.task = inst:StartThread(function()	inst.components.maxwelltalker:DoTalk() end)

	return inst
end

return Prefab("common/characters/maxwellhead", fn, assets) 
