
BrainWrangler = Class(function(self)
        self.instances = {}
        self.updaters = {}
        self.tickwaiters = {}
        self.hibernaters = {}
end)

BrainManager = BrainWrangler()

function BrainWrangler:OnRemoveEntity(inst)
    --print ("onremove", inst, debugstack())
    if inst.brain and self.instances[inst.brain] then
		self:RemoveInstance(inst.brain)
	end
end


function BrainWrangler:NameList(list)
    if not list then
        return "nil"
    elseif list == self.updaters then
        return "updaters"
    elseif list == self.hibernaters then
        return "hibernators"
    else
        for k,v in pairs(self.tickwaiters) do
            if list == v then
                return "tickwaiter "..tostring(k)
            end
        end
    end
    
    return "Unknown"

end

function BrainWrangler:SendToList(inst, list)
    
    local old_list = self.instances[inst]
--    print ("HI!", inst.inst, self:NameList(old_list), self:NameList(list))
    if old_list and old_list ~= list then
        if old_list then
            old_list[inst] = nil
        end
        
        self.instances[inst] = list
        
        if list then
            list[inst] = true
        end
    end
end

function BrainWrangler:Wake(inst)
    if self.instances[inst] then
        self:SendToList(inst, self.updaters)
    end
end

function BrainWrangler:Hibernate(inst)
    if self.instances[inst] then
        self:SendToList(inst, self.hibernaters)
    end
end

function BrainWrangler:Sleep(inst, time_to_wait)
    local sleep_ticks = time_to_wait/GetTickTime()
    if sleep_ticks == 0 then sleep_ticks = 1 end
    
    local target_tick = math.floor(GetTick() + sleep_ticks)
    
    if target_tick > GetTick() then
        local waiters = self.tickwaiters[target_tick]

        if not waiters then
            waiters = {}
            self.tickwaiters[target_tick] = waiters
        end
        
        --print ("BRAIN SLEEPS", inst.inst)
        self:SendToList(inst, waiters)
        
    end
end


function BrainWrangler:RemoveInstance(inst)
    self:SendToList(inst, nil)
    self.updaters[inst] = nil
    self.hibernaters[inst] = nil
    for k,v in pairs(self.tickwaiters) do
        v[inst] = nil
    end
    self.instances[inst] = nil
    
end

function BrainWrangler:AddInstance(inst)

    self.instances[inst] = self.updaters
    self.updaters[inst] = true
end

function BrainWrangler:Update(current_tick)
	
	--[[
	local num = 0;
	local types = {}
	for k,v in pairs(self.instances) do
		
		num = num + 1 
		types[k.inst.prefab] = types[k.inst.prefab] and types[k.inst.prefab] + 1 or 1
	end
	print ("NUM BRAINS:", num)
	for k,v in pairs(types) do
		print ("    ",k,v)
	end
	--]]
	
	
    local waiters = self.tickwaiters[current_tick]
    if waiters then
        for k,v in pairs(waiters) do
            --print ("BRAIN COMES ONLINE", k.inst)
            self.updaters[k] = true
            self.instances[k] = self.updaters
        end
        self.tickwaiters[current_tick] = nil
    end
    

    for k,v in pairs(self.updaters) do
        if k.inst:IsValid() and not k.inst:IsAsleep() then
			TheSim:ProfilerPush(k.inst.prefab)
			k:OnUpdate()
			TheSim:ProfilerPop()
			local sleep_amount = k:GetSleepTime()
			if sleep_amount then
				if sleep_amount > GetTickTime() then
					self:Sleep(k, sleep_amount)
				else
				end
			else
				self:Hibernate(k)
			end
        end
    end
end

Brain = Class(function(self)
    self.inst = nil
    self.currentbehaviour = nil
    self.behaviourqueue = {}
    self.events = {}
    self.thinkperiod = nil
    self.lastthinktime = nil
end)


function Brain:ForceUpdate()
    if self.bt then
        self.bt:ForceUpdate()
    end
    
    BrainManager:Wake(self)
end

function Brain:__tostring()
    
    if self.bt then
        return string.format("--brain--\nsleep time: %2.2f\n%s", self:GetSleepTime(), tostring(self.bt))
    end
    return "--brain--"
end

function Brain:AddEventHandler(event, fn)
    self.events[event] = fn
end

function Brain:GetSleepTime()
    if self.bt then
        return self.bt:GetSleepTime()
    end
    
    return 0
end

function Brain:Start()
    if self.OnStart then
        self:OnStart()
    end
    self.stopped = false
    BrainManager:AddInstance(self)
	if self.OnInitializationComplete then
		self:OnInitializationComplete()
	end

	-- apply mods
	if self.modpostinitfns then
		for i,modfn in ipairs(self.modpostinitfns) do
			modfn(self)
		end
	end
end

function Brain:OnUpdate()
    
    if self.DoUpdate then
		self:DoUpdate()
    end
    
    if self.bt then
        self.bt:Update()
    end
end


function Brain:Stop()
    if self.OnStop then
        self:OnStop()
    end
    if self.bt then
        self.bt:Stop()
    end
    self.stopped = true
    BrainManager:RemoveInstance(self)
end

function Brain:PushEvent(event, data)
    local handler = self.events[event]
    
    if handler then
        handler(data)
    end
end
