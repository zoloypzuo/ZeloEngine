local easing = require "easing"
local MakePlayerCharacter = require "prefabs/player_common"


local assets = 
{
    Asset("ANIM", "anim/wolfgang.zip"),
    Asset("ANIM", "anim/wolfgang_skinny.zip"),
    Asset("ANIM", "anim/wolfgang_mighty.zip"),
    Asset("ANIM", "anim/player_mount_wolfgang.zip"),
    Asset("ANIM", "anim/player_wolfgang.zip"),
	Asset("SOUND", "sound/wolfgang.fsb")    
}

local function applymightiness(inst)

	local percent = inst.components.hunger:GetPercent()
	
	local damage_mult = TUNING.WOLFGANG_ATTACKMULT_NORMAL
	local hunger_rate = TUNING.WOLFGANG_HUNGER_RATE_MULT_NORMAL
	local health_max = TUNING.WOLFGANG_HEALTH_NORMAL
	local scale = 1

	local mighty_scale = 1.25
	local wimpy_scale = .9


	if inst.strength == "mighty" then
		local mighty_start = (TUNING.WOLFGANG_START_MIGHTY_THRESH/TUNING.WOLFGANG_HUNGER)	
		local mighty_percent = math.max(0, (percent - mighty_start) / (1 - mighty_start))
		damage_mult = easing.linear(mighty_percent, TUNING.WOLFGANG_ATTACKMULT_MIGHTY_MIN, TUNING.WOLFGANG_ATTACKMULT_MIGHTY_MAX - TUNING.WOLFGANG_ATTACKMULT_MIGHTY_MIN, 1)
		health_max = easing.linear(mighty_percent, TUNING.WOLFGANG_HEALTH_NORMAL, TUNING.WOLFGANG_HEALTH_MIGHTY - TUNING.WOLFGANG_HEALTH_NORMAL, 1)	
		hunger_rate = easing.linear(mighty_percent, TUNING.WOLFGANG_HUNGER_RATE_MULT_NORMAL, TUNING.WOLFGANG_HUNGER_RATE_MULT_MIGHTY - TUNING.WOLFGANG_HUNGER_RATE_MULT_NORMAL, 1)	
		scale = easing.linear(mighty_percent, 1, mighty_scale - 1, 1)	
	elseif inst.strength == "wimpy" then
		local wimpy_start = (TUNING.WOLFGANG_START_WIMPY_THRESH/TUNING.WOLFGANG_HUNGER)	
		local wimpy_percent = math.min(1, percent/wimpy_start )
		damage_mult = easing.linear(wimpy_percent, TUNING.WOLFGANG_ATTACKMULT_WIMPY_MIN, TUNING.WOLFGANG_ATTACKMULT_WIMPY_MAX - TUNING.WOLFGANG_ATTACKMULT_WIMPY_MIN, 1)
		health_max = easing.linear(wimpy_percent, TUNING.WOLFGANG_HEALTH_WIMPY, TUNING.WOLFGANG_HEALTH_NORMAL - TUNING.WOLFGANG_HEALTH_WIMPY, 1)	
		hunger_rate = easing.linear(wimpy_percent, TUNING.WOLFGANG_HUNGER_RATE_MULT_WIMPY, TUNING.WOLFGANG_HUNGER_RATE_MULT_NORMAL - TUNING.WOLFGANG_HUNGER_RATE_MULT_WIMPY, 1)	
		scale = easing.linear(wimpy_percent, wimpy_scale, 1 - wimpy_scale, 1)	
	end
	
	inst.Transform:SetScale(scale,scale,scale)
	inst.components.hunger:SetRate(hunger_rate*TUNING.WILSON_HUNGER_RATE)
	inst.components.combat.damagemultiplier = damage_mult

	local health_percent = inst.components.health:GetPercent()
	inst.components.health.maxhealth = health_max
	inst.components.health:SetPercent(health_percent)
	inst.components.health:DoDelta(0, true)

end


local function onhungerchange(inst, data)

	local silent = POPULATING

	if inst.strength == "mighty" then
		if inst.components.hunger.current < TUNING.WOLFGANG_END_MIGHTY_THRESH then
			inst.strength = "normal"
			inst.AnimState:SetBuild("wolfgang")

			if not silent then
				inst.components.talker:Say(GetString("wolfgang", "ANNOUNCE_MIGHTYTONORMAL"))
				inst.sg:PushEvent("powerdown")
				inst.SoundEmitter:PlaySound("dontstarve/characters/wolfgang/shrink_lrgtomed")
			end
			inst.talksoundoverride = "dontstarve/characters/wolfgang/talk_LP"
			inst.hurtsoundoverride = "dontstarve/characters/wolfgang/hurt"
		end
	elseif inst.strength == "wimpy" then
		if inst.components.hunger.current > TUNING.WOLFGANG_END_WIMPY_THRESH then
			inst.strength = "normal"
			if not silent then
				inst.components.talker:Say(GetString("wolfgang", "ANNOUNCE_WIMPYTONORMAL"))
				inst.sg:PushEvent("powerup")
				inst.SoundEmitter:PlaySound("dontstarve/characters/wolfgang/grow_smtomed")	
			end
			inst.AnimState:SetBuild("wolfgang")
			inst.talksoundoverride = "dontstarve/characters/wolfgang/talk_LP"
			inst.hurtsoundoverride = "dontstarve/characters/wolfgang/hurt"
		end
	else
		if inst.components.hunger.current > TUNING.WOLFGANG_START_MIGHTY_THRESH then
			inst.strength = "mighty"
			inst.AnimState:SetBuild("wolfgang_mighty")
			if not silent then
				inst.components.talker:Say(GetString("wolfgang", "ANNOUNCE_NORMALTOMIGHTY"))
				inst.sg:PushEvent("powerup")
				inst.SoundEmitter:PlaySound("dontstarve/characters/wolfgang/grow_medtolrg")
			end
			inst.talksoundoverride = "dontstarve/characters/wolfgang/talk_large_LP"
			inst.hurtsoundoverride = "dontstarve/characters/wolfgang/hurt_large"

		elseif inst.components.hunger.current < TUNING.WOLFGANG_START_WIMPY_THRESH then
			inst.strength = "wimpy"
			inst.AnimState:SetBuild("wolfgang_skinny")
			if not silent then
				inst.sg:PushEvent("powerdown")
				inst.components.talker:Say(GetString("wolfgang", "ANNOUNCE_NORMALTOWIMPY"))
				inst.SoundEmitter:PlaySound("dontstarve/characters/wolfgang/shrink_medtosml")
			end
			inst.talksoundoverride = "dontstarve/characters/wolfgang/talk_small_LP"
			inst.hurtsoundoverride = "dontstarve/characters/wolfgang/hurt_small"
		end
	end

	applymightiness(inst)
end


local fn = function(inst)

	inst.strength = "normal"

	inst.components.hunger:SetMax(TUNING.WOLFGANG_HUNGER)
	inst.components.hunger.current = TUNING.WOLFGANG_START_HUNGER
	applymightiness(inst)
	
	inst.components.sanity.night_drain_mult = 1.1
	inst.components.sanity.neg_aura_mult = 1.1

	inst:ListenForEvent("hungerdelta", onhungerchange)

end


return MakePlayerCharacter("wolfgang", nil, assets, fn) 
