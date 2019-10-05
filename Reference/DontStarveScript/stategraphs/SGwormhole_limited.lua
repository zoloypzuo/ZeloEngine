require("stategraphs/commonstates")

local actionhandlers=
{

}

local events=
{

}

local states=
{
	State{
		name = "idle",
		tags = {"idle"},
		onenter = function(inst)
			inst.AnimState:PlayAnimation("idle_loop", true)

			inst.sg:SetTimeout(math.random()*6 + 2)
		end,

		ontimeout = function(inst)
			inst.sg:GoToState("idlecough")
		end,

	},

	State{

		name = "idlecough",
		tags = {"idle"},

		onenter = function(inst)
			inst.AnimState:PlayAnimation("cough")
					
		end,

		timeline=
		{
			TimeEvent(6*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/common/teleportworm/sick_cough")	end),
			TimeEvent(18*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/common/teleportworm/sick_cough") end),	
		},

		events=
		{
			EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
		},

	},

	State{
		name = "open",
		tags = {"idle", "open"},
		onenter = function(inst)
			inst.AnimState:PlayAnimation("open_loop", true)
			-- since we can jump right to the open state, retrigger this sound.
			inst.SoundEmitter:PlaySound("dontstarve/common/teleportworm/idle", "wormhole_open")
		end,

		onexit = function(inst)
			inst.SoundEmitter:KillSound("wormhole_open")
		end,
	},

	State{
		name = "opening",
		tags = {"busy", "open"},
		onenter = function(inst)
			inst.AnimState:PlayAnimation("open_pre")
			inst.SoundEmitter:PlaySound("dontstarve/common/teleportworm/open", "wormhole_opening")
		end,

		events=
		{
			EventHandler("animover", function(inst)
				inst.sg:GoToState("open")
			end),
		},
	},
		
	State{
		name = "closing",
		tags = {"busy"},
		onenter = function(inst)
			inst.AnimState:PlayAnimation("open_pst")
			inst.SoundEmitter:PlaySound("dontstarve/common/teleportworm/close", "wormhole_closing")
		end,

		events=
		{
			EventHandler("animover", function(inst)
				inst.sg:GoToState("idle")
			end),
		},
	},


	State{
		name = "death",
		tags = {"busy"},

		onenter = function(inst)
			inst.AnimState:PlayAnimation("death")
			inst.SoundEmitter:PlaySound("dontstarve/common/teleportworm/sick_die")
			--play death sound
		end,

		timeline=
		{
			TimeEvent(39*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/common/teleportworm/sick_splat")	end),
			
		},

		events =
		{
			EventHandler("animover", function(inst)
				--remove worm from world
				inst:Remove()
			 end),
		},

	},
}

return StateGraph("wormhole", states, events, "idle", actionhandlers)
