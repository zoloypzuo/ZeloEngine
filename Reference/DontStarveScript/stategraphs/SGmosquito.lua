require("stategraphs/commonstates")

local WALK_SPEED = 5

local actionhandlers =
{
    ActionHandler(ACTIONS.GOHOME, "action"),
    ActionHandler(ACTIONS.POLLINATE, function(inst)
		if inst.sg:HasStateTag("landed") then
			return "pollinate"
		else
			return "land"
		end
    end),
}

local events=
{
    EventHandler("attacked", function(inst) if inst.components.health:GetPercent() > 0 then inst.sg:GoToState("hit") end end),
    EventHandler("doattack", function(inst) if inst.components.health:GetPercent() > 0 and not inst.sg:HasStateTag("busy") then inst.sg:GoToState("attack") end end),
    EventHandler("death", function(inst) inst.sg:GoToState("death") end),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),


    EventHandler("locomote", function(inst)
        if not inst.sg:HasStateTag("busy") then
			local wants_to_move = inst.components.locomotor:WantsToMoveForward()
			if not inst.sg:HasStateTag("attack") then
				if wants_to_move then
					inst.sg:GoToState("moving")
				else
					inst.sg:GoToState("idle")
				end
			end
        end
    end),
}


local states=
{

    State{
        name = "splat",
        tags = {"busy"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("explode")
			inst.SoundEmitter:PlaySound(inst.sounds.explode) 
        end,
        timeline=
        {
            TimeEvent(11*FRAMES, function(inst) 
				local pt = Vector3(inst.Transform:GetWorldPosition())
				local ents = TheSim:FindEntities(pt.x,pt.y,pt.z, TUNING.MOSQUITO_BURST_RANGE, nil, {'insect'})
				for i,ent in ipairs(ents) do
					if ent.components.combat then
						ent.components.combat:GetAttacked(inst, TUNING.MOSQUITO_BURST_DAMAGE, nil)
					end
				end
			end),
        },
		events=
        {
            EventHandler("animover", function(inst) inst:Remove() end),
        },
    },

    State{
        name = "death",
        tags = {"busy"},

        onenter = function(inst)

			inst.SoundEmitter:KillSound("buzz")
			if not inst.toofat then
				inst.SoundEmitter:PlaySound(inst.sounds.death)
				inst.AnimState:PlayAnimation("death")
			else
				inst.SoundEmitter:PlaySound(inst.sounds.death)
				inst.AnimState:PlayAnimation("explode_pre")
			end
			inst.Physics:Stop()
			RemovePhysicsColliders(inst)
			if inst.components.lootdropper then
				inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))
			end
        end,

		events=
        {
            EventHandler("animover", function(inst) if inst.toofat then inst.sg:GoToState("splat") end end),
        },
    },

    State{
        name = "action",
        onenter = function(inst, playanim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle", true)
            inst:PerformBufferedAction()
        end,
        events=
        {
            EventHandler("animover", function (inst)
                inst.sg:GoToState("idle")
            end),
        }
    },

    State{
        name = "moving",
        tags = {"moving", "canrotate"},

        onenter = function(inst)
            inst.components.locomotor:WalkForward()
            inst.AnimState:PlayAnimation("walk_loop", true)
        end,

        ontimeout = function(inst)
			inst.sg:GoToState("moving")
        end,
    },


    State{
        name = "idle",
        tags = {"idle", "canrotate"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("walk_loop", true)
        end,
    },

    State{
        name = "attack",
        tags = {"attack"},

        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("atk")
        end,

        timeline=
        {
            TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.attack) end),
            TimeEvent(15*FRAMES, function(inst) inst.components.combat:DoAttack() end),
        },

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "hit",
        tags = {"busy"},

        onenter = function(inst)
            inst.SoundEmitter:PlaySound(inst.sounds.hit)
            inst.AnimState:PlayAnimation("hit")
            inst.Physics:Stop()
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },
    },

}
CommonStates.AddSleepStates(states,
{
    starttimeline =
    {
        TimeEvent(23*FRAMES, function(inst) inst.SoundEmitter:KillSound("buzz") end)
    },
    waketimeline =
    {
        TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.buzz, "buzz") end)
    },
})
CommonStates.AddFrozenStates(states)

return StateGraph("mosquito", states, events, "idle", actionhandlers)

