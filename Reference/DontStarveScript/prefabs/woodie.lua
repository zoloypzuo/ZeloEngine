local MakePlayerCharacter = require "prefabs/player_common"
local Badge = require "widgets/badge"
local easing = require "easing"
require "stategraphs/SGwilson"
require "stategraphs/SGwerebeaver"

local prefabs=
{
	"lucy",
}

local assets = 
{
    Asset("ANIM", "anim/woodie.zip"),
	Asset("SOUND", "sound/woodie.fsb"),
    
    Asset("ANIM", "anim/werebeaver_build.zip"),
    Asset("ANIM", "anim/werebeaver_basic.zip"),
    Asset("ANIM", "anim/player_woodie.zip"),
    Asset("ATLAS", "images/woodie.xml"),
    Asset("IMAGE", "images/woodie.tex"),
    Asset("IMAGE", "images/colour_cubes/beaver_vision_cc.tex"),

}



local function BeaverActionButton(inst)

	local action_target = FindEntity(inst, 6, function(guy) return (guy.components.edible and inst.components.eater:CanEat(guy)) or
		 													 (guy.components.workable and inst.components.worker:CanDoAction(guy.components.workable.action)) end)
	
	if not inst.sg:HasStateTag("busy") and action_target then
		if (action_target.components.edible and inst.components.eater:CanEat(action_target)) then
			return BufferedAction(inst, action_target, ACTIONS.EAT)
		else
			return BufferedAction(inst, action_target, action_target.components.workable.action)
		end
	end
end

local function LeftClickPicker(inst, target_ent, pos)
    if inst.components.combat:CanTarget(target_ent) then
        return inst.components.playeractionpicker:SortActionList({ACTIONS.ATTACK}, target_ent, nil)
    end

	if target_ent and target_ent.components.edible and inst.components.eater:CanEat(target_ent) then
		return inst.components.playeractionpicker:SortActionList({ACTIONS.EAT}, target_ent, nil)
	end

    if target_ent and target_ent.components.workable and inst.components.worker:CanDoAction(target_ent.components.workable.action) then
        return inst.components.playeractionpicker:SortActionList({target_ent.components.workable.action}, target_ent, nil)
    end
end

local function RightClickPicker(inst, target_ent, pos)
	return {}
end


local BeaverBadge = Class(Badge, function(self, owner)
	Badge._ctor(self, "beaver_meter", owner)
end)


local function onbeavereat(inst, data)
	if data.food and data.food.components.edible.woodiness and inst.components.beaverness then
		inst.components.beaverness:DoDelta(data.food.components.edible.woodiness)
	end
end

local function beaveractionstring(inst, action)
	return STRINGS.ACTIONS.GNAW
end

local function beaverhurt(inst, delta)
	if delta < 0 then
		inst.sg:PushEvent("attacked")
		inst.components.beaverness:DoDelta(delta*.25)
		TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/health_down")
		inst.HUD.controls.beaverbadge:PulseRed()
		if inst.HUD.bloodover then
			inst.HUD.bloodover:Flash()
		end
	end
end


local function SetHUDState(inst)
	if inst.HUD then
		if inst.components.beaverness:IsBeaver() and not inst.HUD.controls.beaverbadge then
			inst.HUD.controls.beaverbadge = GetPlayer().HUD.controls.sidepanel:AddChild(BeaverBadge(inst))
			inst.HUD.controls.beaverbadge:SetPosition(0,-100,0)
		    inst.HUD.controls.beaverbadge:SetPercent(1)
			
			inst.HUD.controls.beaverbadge.inst:ListenForEvent("beavernessdelta", function(_, data) 
				inst.HUD.controls.beaverbadge:SetPercent(inst.components.beaverness:GetPercent(), inst.components.beaverness.max)
				if not data.overtime then
					if data.newpercent > data.oldpercent then
						inst.HUD.controls.beaverbadge:PulseGreen()
						TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/health_up")
					elseif data.newpercent < data.oldpercent then
						TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/health_down")
						inst.HUD.controls.beaverbadge:PulseRed()
					end
				end
			end, inst)
			inst.HUD.controls.crafttabs:Hide()
			inst.HUD.controls.inv:Hide()
			inst.HUD.controls.status:Hide()
			inst.HUD.controls.mapcontrols.minimapBtn:Hide()

		    inst.HUD.beaverOL = inst.HUD.under_root:AddChild(Image("images/woodie.xml", "beaver_vision_OL.tex"))
		    inst.HUD.beaverOL:SetVRegPoint(ANCHOR_MIDDLE)
		    inst.HUD.beaverOL:SetHRegPoint(ANCHOR_MIDDLE)
		    inst.HUD.beaverOL:SetVAnchor(ANCHOR_MIDDLE)
		    inst.HUD.beaverOL:SetHAnchor(ANCHOR_MIDDLE)
		    inst.HUD.beaverOL:SetScaleMode(SCALEMODE_FILLSCREEN)
		    inst.HUD.beaverOL:SetClickable(false)
		
		elseif not inst.components.beaverness:IsBeaver() and inst.HUD.controls.beaverbadge then
			if inst.HUD.controls.beaverbadge then
				inst.HUD.controls.beaverbadge:Kill()
				inst.HUD.controls.beaverbadge = nil
			end

			if inst.HUD.beaverOL then
				inst.HUD.beaverOL:Kill()
				inst.HUD.beaverOL = nil
			end

			inst.HUD.controls.crafttabs:Show()
			inst.HUD.controls.inv:Show()
			inst.HUD.controls.status:Show()
			inst.HUD.controls.mapcontrols.minimapBtn:Show()
		end
	end
end

local function BecomeWoodie(inst)
	inst.beaver = false
    inst.ActionStringOverride = nil
    inst.AnimState:SetBank("wilson")
	inst.AnimState:SetBuild("woodie")
	inst:SetStateGraph("SGwilson")
	inst:RemoveTag("beaver")
	
	inst:RemoveComponent("worker")
	inst.components.talker:StopIgnoringAll()
	inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED
	inst.components.combat:SetDefaultDamage(TUNING.UNARMED_DAMAGE)
	
	inst.components.playercontroller.actionbuttonoverride = nil
	inst.components.playeractionpicker.leftclickoverride = nil
	inst.components.playeractionpicker.rightclickoverride = nil
	inst.components.eater:SetOmnivore()


	inst.components.hunger:Resume()
	inst.components.sanity.ignore = false
	inst.components.health.redirect = nil

	inst.components.beaverness:StartTimeEffect(2, -1)

	inst:RemoveEventCallback("oneatsomething", onbeavereat)
	inst.Light:Enable(false)
    inst.components.dynamicmusic:Enable()
    inst.SoundEmitter:KillSound("beavermusic")
    GetWorld().components.colourcubemanager:SetOverrideColourCube(nil)
	inst.components.temperature:SetTemp(nil)
	inst:DoTaskInTime(0, function() SetHUDState(inst) end)
	
end

local function onworked(inst, data)
	if not inst.components.beaverness:IsBeaver() and data.target and data.target.components.workable and data.target.components.workable.action == ACTIONS.CHOP then
		inst.components.beaverness:DoDelta(3)
		--local dist = easing.linear(inst.components.beaverness:GetPercent(), 0, .1, 1)
		--TheCamera:Shake("SIDE", .15, .05, dist*.66)
	--else
		--TheCamera:Shake("SIDE", .15, .05, .1)
	end
end


local function BecomeBeaver(inst)
	inst.beaver = true
	inst.ActionStringOverride = beaveractionstring
	inst:AddTag("beaver")
	inst.AnimState:SetBuild("werebeaver_build")
	inst.AnimState:SetBank("werebeaver")
	inst:SetStateGraph("SGwerebeaver")
	inst.components.talker:IgnoreAll()
	inst.components.combat:SetDefaultDamage(TUNING.BEAVER_DAMAGE)

	inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED*1.1
	inst.components.inventory:DropEverything()
	
	inst.components.playercontroller.actionbuttonoverride = BeaverActionButton
	inst.components.playeractionpicker.leftclickoverride = LeftClickPicker
	inst.components.playeractionpicker.rightclickoverride = RightClickPicker
	inst.components.eater:SetBeaver()

	inst:AddComponent("worker")
	inst.components.worker:SetAction(ACTIONS.DIG, 1)
	inst.components.worker:SetAction(ACTIONS.CHOP, 4)
	inst.components.worker:SetAction(ACTIONS.MINE, 1)
	inst.components.worker:SetAction(ACTIONS.HAMMER, 1)
	inst:ListenForEvent("oneatsomething", onbeavereat)

	inst.components.sanity:SetPercent(1)
	inst.components.health:SetPercent(1)
	inst.components.hunger:SetPercent(1)

	inst.components.hunger:Pause()
	inst.components.sanity.ignore = true
	inst.components.health.redirect = beaverhurt
	inst.components.health.redirect_percent = .25


	local dt = 3
	local BEAVER_DRAIN_TIME = 120
	inst.components.beaverness:StartTimeEffect(dt, (-100/BEAVER_DRAIN_TIME)*dt)
	inst.Light:Enable(true)
    inst.components.dynamicmusic:Disable()
	inst.SoundEmitter:PlaySound("dontstarve/music/music_hoedown", "beavermusic")
    GetWorld().components.colourcubemanager:SetOverrideColourCube("images/colour_cubes/beaver_vision_cc.tex")
    inst.components.temperature:SetTemp(20)
	inst:DoTaskInTime(0, function() SetHUDState(inst) end)
    
end



local fn = function(inst)
	--inst:ListenForEvent("transform", function() if inst.beaver then BecomeWoodie(inst) else BecomeBeaver(inst) end end)
	
	inst:AddComponent("beaverness")
	inst.components.beaverness.makeperson = BecomeWoodie
	inst.components.beaverness.makebeaver = BecomeBeaver
	
	inst.components.beaverness.onbecomeperson = function()
		inst:PushEvent("transform_person")
	end

	inst.components.beaverness.onbecomebeaver = function()
		inst:PushEvent("transform_werebeaver")
		--BecomeBeaver(inst)
	end

    inst.entity:AddLight()
    inst.Light:Enable(false)
	inst.Light:SetRadius(5)
    inst.Light:SetFalloff(.5)
    inst.Light:SetIntensity(.6)
    inst.Light:SetColour(245/255,40/255,0/255)
    inst:DoTaskInTime(0,function()
        if inst:HasTag("lightsource") then       
            inst:RemoveTag("lightsource")    
        end
    end)    
	

	inst:ListenForEvent("working", onworked)
	inst.components.inventory:GuaranteeItems(prefabs)

	BecomeWoodie(inst)

    inst:ListenForEvent("nighttime", function(global, data)
	    if GetClock():GetMoonPhase() == "full" and not inst.components.beaverness:IsBeaver() and not inst.components.beaverness.ignoremoon then
	        if not inst.components.beaverness.doing_transform then
				inst.components.beaverness:SetPercent(1)
			end
	    end
	end, GetWorld())


end

return MakePlayerCharacter("woodie", prefabs, assets, fn, prefabs) 
