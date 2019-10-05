require("class")

StateGraphWrangler = Class(function(self)
        self.instances = {}
        self.updaters = {}
        self.tickwaiters = {}
        self.hibernaters = {}
        self.idlers = {}
        self.haveEvents = {}
end)

SGManager = StateGraphWrangler()

function StateGraphWrangler:SendToList(inst, list, allowunhibernate)
    local old_list = self.instances[inst]
    if old_list then
        if not allowunhibernate and old_list == self.hibernaters then
            return
        end
        old_list[inst] = nil
    end
    
    self.instances[inst] = list
    
    if list then
        list[inst] = true
    end
end

function SGManager:OnEnterNewState(inst)
    if self.instances[inst] then
        self:SendToList(inst, self.updaters)
    end
end

function StateGraphWrangler:OnSetTimeout(inst)
    if self.instances[inst] then
        self:SendToList(inst, self.updaters)
    end
end

function StateGraphWrangler:OnPushEvent(inst)
    if self.instances[inst] then
        self.haveEvents[inst] = true
        return true
    end
    return false
end

function StateGraphWrangler:Hibernate(inst)
    if self.instances[inst] then
        self:SendToList(inst, self.hibernaters)
    end
end

function StateGraphWrangler:Idle(inst)
    if self.instances[inst] then
        self:SendToList(inst, self.idlers)
    end
end

function StateGraphWrangler:Wake(inst)
    if self.instances[inst] then
       self:SendToList(inst, self.updaters, true)
    end
end

function StateGraphWrangler:Sleep(inst, time_to_wait)
    if self.instances[inst] then
        local sleep_ticks = time_to_wait/GetTickTime()
        if sleep_ticks == 0 then sleep_ticks = 1 end

        local target_tick = math.floor(GetTick() + sleep_ticks) + 1
        local waiters = self.tickwaiters[target_tick]

        if not waiters then
            waiters = {}
            self.tickwaiters[target_tick] = waiters
        end
        self:SendToList(inst, waiters)
    end
end

function StateGraphWrangler:OnRemoveEntity(inst)
    if self.instances[inst.sg] then
        self:RemoveInstance(inst.sg)
    end
end

function StateGraphWrangler:RemoveInstance(inst)
    local old_list = self.instances[inst]
    if old_list ~= nil then
        old_list[inst] = nil
    end

    self.instances[inst] = nil
    self.updaters[inst] = nil
    self.tickwaiters[inst] = nil
    self.hibernaters[inst] = nil
    self.haveEvents[inst] = nil
end

function StateGraphWrangler:AddInstance(inst)
    self:SendToList(inst, self.updaters)
end

function StateGraphWrangler:Update(current_tick)
    local waiters = self.tickwaiters[current_tick]
    if waiters then
        for k,v in pairs(waiters) do
            self.updaters[k] = true
            self.instances[k] = self.updaters
        end
        self.tickwaiters[current_tick] = nil
    end

    local updaters = self.updaters
    self.updaters = {}
    
    TheSim:ProfilerPush("updaters")
    for k,v in pairs(updaters) do
        if k.inst:IsValid() then
            TheSim:ProfilerPush(tostring(k.inst.prefab) .. " > " .. tostring(k.currentstate.name) )
            local sleep_amount = k:Update()
            TheSim:ProfilerPop()
            if sleep_amount then
                if sleep_amount > 0 then
                  self:Sleep(k, sleep_amount)
                else
                    self.updaters[k] = true
                    self.instances[k] = self.updaters
                end
            else
                self:Idle(k)
            end
        end
    end
    TheSim:ProfilerPop()
    
    local evs = self.haveEvents
    self.haveEvents = {}
    
    TheSim:ProfilerPush("events")
    for k,v in pairs(evs) do
        k:HandleEvents()
    end
    TheSim:ProfilerPop()
end

ActionHandler = Class(
    function(self, action, state, condition)
        
        self.action = action
        
        if type(state) == "string" then
            self.deststate = function(inst) return state end
        else
            self.deststate = state
        end
        
        self.condition = condition
    end)

EventHandler = Class(
    function(self, name, fn)
        local info = debug.getinfo(3, "Sl")
        self.defline = string.format("%s:%d", info.short_src, info.currentline)
        assert (type(name) == "string")
        assert (type(fn) == "function")
        self.name = string.lower(name)
        self.fn = fn
    end)
    
TimeEvent = Class(
    function(self, time, fn)
        local info = debug.getinfo(3, "Sl")
        self.defline = string.format("%s:%d", info.short_src, info.currentline)
        assert (type(time) == "number")
        assert (type(fn) == "function")
        self.time = time
        self.fn = fn
    end)    
    
State = Class(
    function(self, args)
        local info = debug.getinfo(3, "Sl")
        self.defline = string.format("%s:%d", info.short_src, info.currentline)
        
        assert(args.name, "State needs name")
        self.name = args.name
        self.onenter = args.onenter
        self.onexit = args.onexit
        self.onupdate = args.onupdate
        self.ontimeout = args.ontimeout
        
        self.tags = {}
        if args.tags then
            for k, v in ipairs(args.tags) do
                self.tags[v] = true
            end
        end
        
        self.events = {}
        if args.events ~= nil then
            for k,v in pairs(args.events) do
                assert(v:is_a(EventHandler), "non-EventHandler in event list")
                self.events[v.name] = v
            end
        end
        
        self.timeline = {}
        if args.timeline ~= nil then
            for k,v in ipairs(args.timeline) do
                assert(v:is_a(TimeEvent), "non-TimeEvent in timeline")
                table.insert(self.timeline, v)
            end
        end
        
        local function pred(a,b)
            return a.time < b.time
        end
        table.sort(self.timeline, pred)
        
    end
)

function State:HandleEvent(sg, eventname, data)
    if not data or not data.state or data.state == self.name then
        local handler = self.events[eventname]
        if handler ~= nil then
            return handler.fn(sg.inst, data)
        end
    end
    return false
end
   



StateGraph = Class( function(self, name, states, events, defaultstate, actionhandlers)
    assert(name and type(name) == "string", "You must specify a name for this stategraph")
    local info = debug.getinfo(3, "Sl")
    self.defline = string.format("%s:%d", info.short_src, info.currentline)
    self.name = name
    self.defaultstate = defaultstate
    
    --reindex the tables
    self.actionhandlers = {}
    if actionhandlers then
        for k,v in pairs(actionhandlers) do
            assert( v:is_a(ActionHandler),"Non-action handler added in actionhandler table!")
            self.actionhandlers[v.action] = v
        end
    end
	for k,modhandlers in pairs(ModManager:GetPostInitData("StategraphActionHandler", self.name)) do
		for i,v in ipairs(modhandlers) do
			assert( v:is_a(ActionHandler),"Non-action handler added in mod actionhandler table!")
			self.actionhandlers[v.action] = v
		end
	end

    self.events = {}
    for k,v in pairs(events) do
        assert( v:is_a(EventHandler),"Non-event added in events table!")
        self.events[v.name] = v
    end
	for k,modhandlers in pairs(ModManager:GetPostInitData("StategraphEvent", self.name)) do
		for i,v in ipairs(modhandlers) do
			assert( v:is_a(EventHandler),"Non-event added in mod events table!")
			self.events[v.name] = v
		end
    end

    self.states = {}
    for k,v in pairs(states) do
        assert( v:is_a(State),"Non-state added in state table!")
        self.states[v.name] = v
    end
	for k,modhandlers in pairs(ModManager:GetPostInitData("StategraphState", self.name)) do
		for i,v in ipairs(modhandlers) do
			assert( v:is_a(State),"Non-state added in mod state table!")
			self.states[v.name] = v
		end
    end

	-- apply mods
	local modfns = ModManager:GetPostInitFns("StategraphPostInit", self.name)
	for i,modfn in ipairs(modfns) do
		modfn(self)
	end
end)

function StateGraph:__tostring()
    return "Stategraph : "..self.name--.. " (currentstate="..self.currentstate.name..":"..self.timeinstate..")"
end
    
    
StateGraphInstance = Class( function (self, stategraph, inst)
    self.sg = stategraph
    self.currentstate = nil
    self.timeinstate = 0
    self.lastupdatetime = 0
    self.timelineindex = nil
    self.prevstate = nil
    self.bufferedevents={}
    self.inst = inst
    self.statemem = {}
    self.mem = {}
    self.statestarttime = 0
end)

function StateGraphInstance:__tostring()
    local str =  string.format([[sg="%s", state="%s", time=%2.2f]], self.sg.name, self.currentstate and self.currentstate.name or "<nil>", GetTime() - self.statestarttime)
    str = str..[[, tags = "]]
	if self.tags ~= nil then
		for k,v in pairs(self.tags) do
			str = str..tostring(k)..","
		end
	end
    str = str..[["]]
    return str
end
    
function StateGraphInstance:GetTimeInState()
    return GetTime() - self.statestarttime
end

function StateGraphInstance:PlayRandomAnim(anims, loop)
    local idx = math.floor(math.random() * #anims)
    self.inst.AnimState:PlayAnimation(anims[idx+1], loop)
end

function StateGraphInstance:PushEvent(event, data)
    if data then
        data.state = self.currentstate.name
    else
        data = {state = self.currentstate.name}
    end
    table.insert(self.bufferedevents, {name=event, data=data})
end

function StateGraphInstance:IsListeningForEvent(event)
    return self.currentstate.events[event] ~= nil or self.sg.events[event] ~= nil
end


function StateGraphInstance:StartAction(bufferedaction)
    if self.sg.actionhandlers then
        local handler = self.sg.actionhandlers[bufferedaction.action]
        if handler then
            if not handler.condition or handler.condition(self.inst) then
                if handler.deststate then
                    local state = handler.deststate(self.inst, bufferedaction)
                    if state then
                        self:GoToState(state)
                    else
                        return
                    end
                else
                    self.inst:PerformBufferedAction()
                end
                    
                return true
            end
        end
    end
end

function StateGraphInstance:HandleEvents()
    assert(self.currentstate ~= nil, "we are not in a state!")
    
    if self.inst:IsValid() then
		for k, event in ipairs(self.bufferedevents) do
			if not self.currentstate:HandleEvent(self, event.name, event.data) then
				local handler = self.sg.events[event.name]
				if handler ~= nil then
					handler.fn(self.inst, event.data)
				end
			end
		end
	end
	
    self.bufferedevents = {}
end

function StateGraphInstance:InNewState()
	return self.laststate ~= self.currentstate
end

function StateGraphInstance:GoToState(statename, params)
    local state = self.sg.states[statename]
    
    if not state then
		print (self.inst, "TRIED TO GO TO INVALID STATE", statename)
		return 
    end
    --assert(state ~= nil, "State not found: " ..tostring(self.sg.name).."."..tostring(statename) )
    

    self.prevstate = self.currentstate
    if self.currentstate ~= nil and self.currentstate.onexit ~= nil then 
        self.currentstate.onexit(self.inst, statename)
    end

    -- Record stats
    if METRICS_ENABLED and self.inst == GetPlayer() and self.currentstate and not IsAwayFromKeyBoard() then
        local dt = GetTime() - self.statestarttime
        self.currentstate.totaltime = self.currentstate.totaltime and (self.currentstate.totaltime + dt) or dt  -- works even if currentstate.time is nil
        -- dprint(self.currentstate.name," time in state= ", self.currentstate.totaltime)
    end

    self.statemem = {}
    self.tags = {}
    if state.tags then
        for i,k in pairs(state.tags) do
            self.tags[i] = true
        end
    end
    self.timeout = nil
    self.laststate = self.currentstate
    self.currentstate = state
    self.timeinstate = 0

    if self.currentstate.timeline ~= nil then
        self.timelineindex = 1
    else
        self.timelineindex = nil
    end
    
    if self.currentstate.onenter ~= nil then
        self.currentstate.onenter(self.inst, params)
    end
    
    self.inst:PushEvent("newstate", {statename = statename})
    
    
    self.lastupdatetime = GetTime()
    self.statestarttime = self.lastupdatetime    
    SGManager:OnEnterNewState(self)

end

function StateGraphInstance:AddStateTag(tag)
    self.tags[tag] = true
end

function StateGraphInstance:RemoveStateTag(tag)
    self.tags[tag] = nil
end

function StateGraphInstance:HasStateTag(tag)
    return self.tags and (self.tags[tag] == true)
end

function StateGraphInstance:SetTimeout(time)
    SGManager:OnSetTimeout(self)
    self.timeout = time
end

function StateGraphInstance:UpdateState(dt)
    if not self.currentstate then 
        return
    end

    self.timeinstate = self.timeinstate + dt
    local startstate = self.currentstate
    
    
    if self.timeout then
        self.timeout = self.timeout - dt
        if self.timeout <= (1/30) then
            self.timeout = nil
            if self.currentstate.ontimeout then
                self.currentstate.ontimeout(self.inst)
                if startstate ~= self.currentstate then
                    return
                end
            end
        end
    end
    
    while self.timelineindex and self.currentstate.timeline[self.timelineindex] and self.currentstate.timeline[self.timelineindex].time <= self.timeinstate do

		local idx = self.timelineindex
        self.timelineindex = self.timelineindex + 1
        if self.timelineindex > #self.currentstate.timeline then
            self.timelineindex = nil
        end
        
        local old_time = self.timeinstate
        local extra_time = self.timeinstate - self.currentstate.timeline[idx].time
        self.currentstate.timeline[idx].fn(self.inst)
        
        
        if startstate ~= self.currentstate or old_time > self.timeinstate then
            self:Update(extra_time)
            return 0
        end
    end
    
    if self.currentstate.onupdate ~= nil then
        self.currentstate.onupdate(self.inst, dt)
    end
end

function StateGraphInstance:Start()
    if self.OnStart then
        self:OnStart()
    end
    self.stopped = false
    SGManager:AddInstance(self)
end

function StateGraphInstance:Stop()
    self:HandleEvents()
    if self.OnStop then
        self:OnStop()
    end
    self.stopped = true
    SGManager:RemoveInstance(self)
end

function StateGraphInstance:Update()
    local dt = 0
    if self.lastupdatetime then
        dt = GetTime() - self.lastupdatetime --+ GetTickTime()
    end
    self.lastupdatetime = GetTime()
	
	
    self:UpdateState(dt)
	
   
    local time_to_sleep = nil
    if self.timelineindex and self.currentstate.timeline and self.currentstate.timeline[self.timelineindex] then
        time_to_sleep = self.currentstate.timeline[self.timelineindex].time - self.timeinstate
    end
        
    
    if self.timeout and (not time_to_sleep or time_to_sleep > self.timeout) then
        time_to_sleep = self.timeout
    end
        
    if self.currentstate.onupdate then
        return 0
    elseif time_to_sleep then
        return time_to_sleep
    else
        return nil
    end
end

    
