local events =
{
	EventHandler("gotosleep", function(inst)
		if inst:HasBird() then
        	if inst.sg:HasStateTag("sleeping") then
                inst.sg:GoToState("sleeping")
            else
                inst.sg:GoToState("sleep")
            end
		end
	end),


	EventHandler("getitem", function(inst)
		if inst:HasBird() then
			inst.sg:GoToState("accept_item")
		end
	end),

	EventHandler("rejectitem", function(inst)
		if inst:HasBird() then
			inst.sg:GoToState("reject_item")
		end
	end),

	EventHandler("losebird", function(inst)
		inst.sg:GoToState("idle")
	end),

	EventHandler("getbird", function(inst)
		inst.sg:GoToState("idle")
	end),

	EventHandler("worked", function(inst)
		inst.sg:GoToState("hit")
	end),

	EventHandler("ontalk", function(inst, data)
        if inst.sg:HasStateTag("idle") then
			inst.sg:GoToState("talk", data.noanim)
		end
	end)
}

local actionhandlers = {}

local states =
{
	State{
		name = "idle",
		tags = {"idle"},

		onenter = function(inst)
			if inst:HasBird() then
				inst.AnimState:PlayAnimation("idle", true)
	            inst.sg:SetTimeout(math.random()*4+2)
			else
				inst.AnimState:PlayAnimation("idle_empty")
			end
		end,


        ontimeout= function(inst)
        	if math.random () > 0.13 then
                inst.sg:GoToState("idle_peck")
            else
				inst.components.talker.colour = Vector3(1 ,1, 1)
				local str = inst.SquawkScript(STRINGS.SUNKEN_BOAT_IDLE[math.random(#STRINGS.SUNKEN_BOAT_IDLE)])
                inst.components.talker:Say(str)
	        end
        end,
	},

	State{
		name = "idle_peck",
		tags = {"idle"},

		onenter = function(inst)
			if inst:HasBird() then
				inst.AnimState:PlayAnimation("idle_peck")
			end
		end,

		timeline =
		{
			TimeEvent(6*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/teasertheparrot/peck") end),
			TimeEvent(11*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/teasertheparrot/peck") end),
		},

        events=
        {
            EventHandler("animover", function(inst)
            	inst.sg:GoToState("idle")
            end),
        },
	},


	State{
		name = "talk",
		tags = {"idle", "talking"},

		onenter = function(inst)
			if inst:HasBird() then
				inst.AnimState:PlayAnimation("speak", true)
			end

            inst.sg:SetTimeout(1.5 + math.random()*.5)
		end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle")
        end,

		timeline =
		{
			--This is a bit silly, but we're doing it because the
			--talk sound doesn't actually loop and we don't know
			--how long the event needs to play.
			TimeEvent(06*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/teasertheparrot/speak") end),
			TimeEvent(24*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/teasertheparrot/speak") end),
			TimeEvent(38*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/teasertheparrot/speak") end),
			TimeEvent(52*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/teasertheparrot/speak") end),
			TimeEvent(66*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/teasertheparrot/speak") end),
			TimeEvent(70*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/teasertheparrot/speak") end),
		},

        events=
        {
            EventHandler("donetalking", function(inst) inst.sg:GoToState("idle") end),
        },
	},

	State{
		name = "hit",
		tags = {"busy"},

		onenter = function(inst)
			if inst:HasBird() then
				inst.AnimState:PlayAnimation("hit")
				inst.SoundEmitter:PlaySound("dontstarve/creatures/teasertheparrot/alarmed")
			else
				inst.AnimState:PlayAnimation("hit_empty")
			end
		end,

        events=
        {
            EventHandler("animover", function(inst)
            	--If bird, fly away.
            	if inst:HasBird() then
            		inst:TakeOff()
            	end

            	inst.sg:GoToState("idle")

            end),
        },
	},

	State{
		name = "accept_item",
		tags = {"busy"},

		onenter = function(inst)
			inst.AnimState:PlayAnimation("accept_pre") --6
			inst.AnimState:PushAnimation("accept") --30 (36 frames in)
			inst.AnimState:PushAnimation("accept_post", false)
		end,

		timeline =
		{
			TimeEvent(6*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/birds/wingflap_cage") end),
			TimeEvent(12*FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/birds/wingflap_cage")
				inst.SoundEmitter:PlaySound("dontstarve/creatures/teasertheparrot/speak")
			end),

			TimeEvent(18*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/birds/wingflap_cage") end),
			TimeEvent(24*FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/birds/wingflap_cage")
				inst.SoundEmitter:PlaySound("dontstarve/creatures/teasertheparrot/speak")
			end),

			TimeEvent(30*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/birds/wingflap_cage") end),
			TimeEvent(36*FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/birds/wingflap_cage")
				inst.SoundEmitter:PlaySound("dontstarve/creatures/teasertheparrot/speak")
			end),
		},

		events=
		{
			EventHandler("animqueueover", function(inst)
				inst.sg:GoToState("idle")
			end),
		},
	},

	State{
		name = "reject_item",
		tags = {"busy"},

		onenter = function(inst)
			inst.AnimState:PlayAnimation("reject")
			inst.SoundEmitter:PlaySound("dontstarve/creatures/teasertheparrot/reject")
		end,

		events=
		{
			EventHandler("animover", function(inst)
				inst.sg:GoToState("idle")
			end),
		},
	},

	State{
		name = "speak",
		tags = {"busy"},

		onenter = function(inst)
			inst.AnimState:PlayAnimation("speak")
		end,

		events=
		{
			EventHandler("animover", function(inst)
				inst.sg:GoToState("idle")
			end),
		},
	},
}

CommonStates.AddSleepStates(states,
{
	starttimeline =
	{
		TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/teasertheparrot/sleep") end),
	},
	sleeptimeline =
	{
		TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/teasertheparrot/sleep") end),
	},
})

return StateGraph("sunken_boat", states, events, "idle", actionhandlers)