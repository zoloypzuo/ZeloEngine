require("stategraphs/commonstates")

local actionhandlers =
{
}

local events=
{
    EventHandler("attacked", function(inst) if not inst.components.health:IsDead() and not inst.sg:HasStateTag("nointerrupt") and not inst.sg:HasStateTag("attack") then inst.sg:GoToState("hit") end end),
    EventHandler("death", function(inst) inst.sg:GoToState("death") end),
    EventHandler("doattack", function(inst) if not inst.components.health:IsDead() and (inst.sg:HasStateTag("hit") or not inst.sg:HasStateTag("busy")) then inst.sg:GoToState("attack") end end),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnLocomote(false,true),
    CommonHandlers.OnFreeze(),
}

local states=
{

    State{
        name = "idle",
        tags = {"idle", "canrotate"},
        onenter = function(inst, playanim)
            inst.Physics:Stop()
			inst.AnimState:PlayAnimation("idle", true)
			if math.random() < .2 then
				inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/scream_short")
			end
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "attack",
        tags = {"attack", "nointerrupt"},

        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("atk")
        end,

        timeline=
        {
            TimeEvent(0*FRAMES, function(inst) inst:PerformBufferedAction() inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/attack") end),
            TimeEvent(25*FRAMES, function(inst) inst:PerformBufferedAction() inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/attack_grunt") end),
            TimeEvent(28*FRAMES, function(inst) inst:PerformBufferedAction() inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/swipe") end),
            TimeEvent(28*FRAMES, function(inst) inst.components.combat:DoAttack() end),
        },

        events=
        {
            EventHandler("animover", function(inst)inst.sg:GoToState("idle") end),
        },
    },

  	State{
		name = "hit",
        tags = {"busy", "hit"},

        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("hit")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/hurt")
        end,

        events=
        {
			EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

	State{
		name = "taunt",
        tags = {"busy"},

        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/scream")
        end,

        events=
        {
			EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

	State{
		name = "makenest",
        tags = {"busy", "nointerrupt"},

        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("cocoon")
            --inst.SoundEmitter:PlaySound("dontstarve/creatures/krampus/taunt")
        end,

		timeline=
        {
            TimeEvent(15*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/scream") end),
        },

        events=
        {
			EventHandler("animover", function(inst)
				inst.Physics:ClearCollisionMask()
				inst:Remove()
				local den = SpawnPrefab("spiderden")
				den.AnimState:PlayAnimation("cocoon_small")
				den.Transform:SetPosition(inst.Transform:GetWorldPosition())
			end),
        },
    },


	State{
		name = "birth",
        tags = {"busy", "nointerrupt"},

        onenter = function(inst, cb)
            inst.AnimState:PlayAnimation("enter")
			inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/emerge_voice")
			inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/emerge_foley")
		end,

		timeline=
        {
        },


        events=
        {
			EventHandler("animover", function(inst)
				inst.sg:GoToState("idle")
			end),
        },
    },

	State{
		name = "poop",
        tags = {"busy", "nointerrupt"},

        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.components.locomotor:Stop()
			local angle = TheCamera:GetHeadingTarget()*DEGREES -- -22.5*DEGREES
			inst.Transform:SetRotation(angle / DEGREES)
            inst.AnimState:PlayAnimation("poop")

        end,

		timeline=
        {
            TimeEvent(26*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/scream_short") end),
            TimeEvent(50*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/givebirth_voice") end),
            TimeEvent(60*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/givebirth_foley") end),
            TimeEvent(64*FRAMES, function(inst)

				local angle = inst.Transform:GetRotation()/DEGREES
				local prefab = (inst.components.combat.target and math.random() < .333) and "spider_warrior" or "spider"
				local spider = inst.components.lootdropper:SpawnLootPrefab(prefab)
		        local rad = spider.Physics:GetRadius()+inst.Physics:GetRadius()+.25;
		        local pt = Vector3(inst.Transform:GetWorldPosition())
				if spider then
					spider.Transform:SetPosition(pt.x + rad*math.cos(angle), pt.y, pt.z + rad*math.sin(angle))
					spider.sg:GoToState("taunt")
					inst.components.leader:AddFollower(spider)
					if inst.components.combat.target then
						spider.components.combat:SetTarget(inst.components.combat.target)
					end
				end
            end),
        },

        events=
        {
			EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

	State{
        name = "death",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/die")
            inst.AnimState:PlayAnimation("death")
            inst.components.locomotor:StopMoving()
            RemovePhysicsColliders(inst)            
            inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))            
        end,
        
    },

}

CommonStates.AddSleepStates(states,
	{
		sleeptimeline = {
	        TimeEvent(30*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/sleeping") end),
		},
	},
	{
		onsleep = function(inst)
			inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/fallasleep")
		end,
		onwake = function(inst)
			inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/wakeup")
		end
	}
)


CommonStates.AddWalkStates(states,
{
	walktimeline = {
		TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/walk_spiderqueen") end),
		TimeEvent(7*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/walk_spiderqueen") end),
		TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/walk_spiderqueen") end),
		TimeEvent(13*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/walk_spiderqueen") end),
		TimeEvent(17*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/walk_spiderqueen") end),
		TimeEvent(25*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/walk_spiderqueen") end),
		TimeEvent(32*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/walk_spiderqueen") end),
		TimeEvent(38*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/walk_spiderqueen") end),
	},
})

CommonStates.AddFrozenStates(states)


return StateGraph("spiderqueen", states, events, "idle", actionhandlers)

