require("class")


SUCCESS = "SUCCESS"
FAILED = "FAILED"
READY = "READY"
RUNNING = "RUNNING"


---------------------------------------------------------------------------------------

local function profilewrapvisit(node)
	local oldvisit = node.Visit
	node.Visit = function(self)
		TheSim:ProfilerPush("node: "..tostring(node.name))
		oldvisit(self)
		TheSim:ProfilerPop()
	end
	if node.children then
		for i,child in ipairs(node.children) do
			profilewrapvisit(child)
		end
	end
end

BT = Class(function(self, inst, root)
    self.inst = inst
	--profilewrapvisit(root) -- uncomment for verbose brain profiling!
    self.root = root
end)

function BT:ForceUpdate()
    self.forceupdate = true
end
function BT:Update()

    self.root:Visit()
    self.root:SaveStatus()
    self.root:Step()

    self.forceupdate = false
end

function BT:Reset()
    self.root:Reset()
end

function BT:Stop()
    self.root:Stop()
end

function BT:GetSleepTime()
    if self.forceupdate then
        return 0
    end
    
    return self.root:GetTreeSleepTime()
end

function BT:__tostring()
    return self.root:GetTreeString()
end


---------------------------------------------------------------------------------------

BehaviourNode = Class(function (self, name, children) 
    self.name = name or ""
    self.children = children
    self.status = READY
    self.lastresult = READY
    if children then
        for i,k in pairs(children) do
            k.parent = self
        end
    end
end)

function BehaviourNode:DoToParents(fn)
    if self.parent then
        fn(self.parent)
        return self.parent:DoToParents(fn)
    end
end

function BehaviourNode:GetTreeString(indent)
    indent = indent or ""
    local str = string.format("%s%s>%2.2f\n", indent, self:GetString(), self:GetTreeSleepTime() or 0)
    if self.children then
        for k, v in ipairs(self.children) do
            str = str .. v:GetTreeString(indent .. "   >")
        end
    end
    return str
end

function BehaviourNode:DBString()
    return ""
end

function BehaviourNode:Sleep(t)
    self.nextupdatetime = GetTime() + t 
end

function BehaviourNode:GetSleepTime()
    
    if self.status == RUNNING and not self.children and not self:is_a(ConditionNode) then
        if self.nextupdatetime then
            local time_to = self.nextupdatetime - GetTime()
            if time_to < 0 then
                time_to = 0
            end
            return time_to
        end
        return 0
    end
    
    return nil
end

function BehaviourNode:GetTreeSleepTime()
    
    local sleeptime = nil
    if self.children then
        for k,v in ipairs(self.children) do
            if v.status == RUNNING then
                local t = v:GetTreeSleepTime()
                if t and (not sleeptime or sleeptime > t) then
                    sleeptime = t
                end
            end
        end
    end
    
    local my_t = self:GetSleepTime()
    
    if my_t and (not sleeptime or sleeptime > my_t) then
        sleeptime = my_t
    end
    
    return sleeptime
end

function BehaviourNode:GetString()
    local str = ""
    if self.status == RUNNING then
        str = self:DBString()
    end
    return string.format([[%s - %s <%s> (%s)]], self.name, self.status or "UNKNOWN", self.lastresult or "?", str)
end

function BehaviourNode:Visit()
    self.status = FAILED
end

function BehaviourNode:SaveStatus()
    self.lastresult = self.status
    if self.children then
        for k,v in pairs(self.children) do
            v:SaveStatus()
        end
    end
end

function BehaviourNode:Step()
    if self.status ~= RUNNING then
        self:Reset()
    elseif self.children then
        for k, v in ipairs(self.children) do
            v:Step()
        end
    end
end

function BehaviourNode:Reset()
    if self.status ~= READY then
        self.status = READY
        if self.children then
            for idx, child in ipairs(self.children) do
                child:Reset()
            end
        end
    end
end

function BehaviourNode:Stop()
    if self.OnStop then
        self:OnStop()
    end
    if self.children then
        for idx, child in ipairs(self.children) do
            child:Stop()
        end
    end
end


---------------------------------------------------------------------------------------
DecoratorNode = Class(BehaviourNode, function(self, name, child)
	BehaviourNode._ctor(self, name or "Decorator", {child})
end)

---------------------------------------------------------------------------------------


ConditionNode = Class(BehaviourNode, function(self, fn, name)
    BehaviourNode._ctor(self, name or "Condition")
    self.fn = fn
end)

function ConditionNode:Visit()
    if self.fn() then
        self.status = SUCCESS
    else
        self.status = FAILED
    end
end


---------------------------------------------------------------------------------------


ConditionWaitNode = Class(BehaviourNode, function(self, fn, name)
    BehaviourNode._ctor(self, name or "Wait")
    self.fn = fn
end)

function ConditionWaitNode:Visit()
    if self.fn() then
        self.status = SUCCESS
    else
        self.status = RUNNING
    end
end


---------------------------------------------------------------------------------------


ActionNode = Class(BehaviourNode, function(self, action, name)
    BehaviourNode._ctor(self, name or "ActionNode")
    self.action = action
end)

function ActionNode:Visit()
    self.action()
    self.status = SUCCESS
end


---------------------------------------------------------------------------------------


WaitNode = Class(BehaviourNode, function(self, time)
    BehaviourNode._ctor(self, "Wait")
    self.wait_time = time
end)

function WaitNode:DBString()
    local w = self.wake_time - GetTime()
    return string.format("%2.2f", w)
end

function WaitNode:Visit()
    local current_time = GetTime() 
    
    if self.status ~= RUNNING then
        self.wake_time = current_time + self.wait_time
        self.status = RUNNING
    end
    
    if self.status == RUNNING then
        if current_time >= self.wake_time then
            self.status = SUCCESS
        else
            self:Sleep(current_time - self.wake_time)
        end
    end
    
end


---------------------------------------------------------------------------------------

SequenceNode = Class(BehaviourNode, function(self, children)
    BehaviourNode._ctor(self, "Sequence", children)
    self.idx = 1
end)

function SequenceNode:DBString()
    return tostring(self.idx)
end


function SequenceNode:Reset()
    self._base.Reset(self)
    self.idx = 1
end

function SequenceNode:Visit()
    
    if self.status ~= RUNNING then
        self.idx = 1
    end
    
    local done = false
    while self.idx <= #self.children do
    
        local child = self.children[self.idx]
        child:Visit()
        if child.status == RUNNING or child.status == FAILED then
            self.status = child.status
            return
        end
        
        self.idx = self.idx + 1
    end 
    
    self.status = SUCCESS
end

---------------------------------------------------------------------------------------

SelectorNode = Class(BehaviourNode, function(self, children)
    BehaviourNode._ctor(self, "Selector", children)
    self.idx = 1
end)

function SelectorNode:DBString()
    return tostring(self.idx)
end


function SelectorNode:Reset()
    self._base.Reset(self)
    self.idx = 1
end

function SelectorNode:Visit()
    
    if self.status ~= RUNNING then
        self.idx = 1
    end
    
    local done = false
    while self.idx <= #self.children do
    
        local child = self.children[self.idx]
        child:Visit()
        if child.status == RUNNING or child.status == SUCCESS then
            self.status = child.status
            return
        end
        
        self.idx = self.idx + 1
    end 
    
    self.status = FAILED
end
---------------------------------------------------------------------------------------

NotDecorator = Class(DecoratorNode, function(self, child)
    DecoratorNode._ctor(self, "Not", child)
end)

function NotDecorator:Visit()
	local child = self.children[1]
	child:Visit()
	if child.status == SUCCESS then
		self.status = FAILED
	elseif child.status == FAILED then
		self.status = SUCCESS
	else
		self.status = child.status
	end
end
---------------------------------------------------------------------------------------

FailIfRunningDecorator = Class(DecoratorNode, function(self, child)
    DecoratorNode._ctor(self, "FailIfRunning", child)
end)

function FailIfRunningDecorator:Visit()
	local child = self.children[1]
	child:Visit()
	if child.status == RUNNING then
		self.status = FAILED
	else
		self.status = child.status
	end
end

---------------------------------------------------------------------------------------


LoopNode = Class(BehaviourNode, function(self, children, maxreps)
    BehaviourNode._ctor(self, "Sequence", children)
    self.idx = 1
    self.maxreps = maxreps
    self.rep = 0
end)

function LoopNode:DBString()
    return tostring(self.idx)
end


function LoopNode:Reset()
    self._base.Reset(self)
    self.idx = 1
    self.rep = 0
end

function LoopNode:Visit()
    
    if self.status ~= RUNNING then
        self.idx = 1
        self.rep = 0
    end
    
    local done = false
    while self.idx <= #self.children do
    
        local child = self.children[self.idx]
        child:Visit()
        if child.status == RUNNING or child.status == FAILED then
            if child.status == FAILED then
                --print("EXIT LOOP ON FAIL")
            end
            self.status = child.status
            return
        end
        
        self.idx = self.idx + 1
    end 
    
    self.idx = 1
    
    self.rep = self.rep + 1
    if self.maxreps and self.rep >= self.maxreps then
        --print("DONE LOOP")
        self.status = SUCCESS
    else
        for k,v in ipairs(self.children) do
            v:Reset()
        end
    
    end
end

---------------------------------------------------------------------------------------

RandomNode = Class(BehaviourNode, function(self, children)
    BehaviourNode._ctor(self, "Random", children)
end)


function RandomNode:Reset()
    self._base.Reset(self)
    self.idx = nil
end


function RandomNode:Visit()

    local done = false
    
    if self.status == READY then
        --pick a new child
        self.idx = math.random(#self.children)
        local start = inst.idx
        while true do
        
            local child = self.children[self.idx]
            child:Visit()
            
            if child.status ~= FAILED then
                self.status = child.status
                return
            end
            
            self.idx = self.idx + 1
            if self.idx == #self.children then
                self.idx = 1
            end
            
            if self.idx == start then
                inst.status = FAILED
                return
            end
        end
        
    else
        local child = self.children[self.idx]
        child:Visit()
        self.status = child.status
    end
    
end

---------------------------------------------------------------------------------------    

PriorityNode = Class(BehaviourNode, function(self, children, period)
    BehaviourNode._ctor(self, "Priority", children) 
    self.period = period or 1
end)

function PriorityNode:GetSleepTime()
    if self.status == RUNNING then
        
        if not self.period then
            return 0
        end
        
        
        local time_to = 0
        if self.lasttime then
            time_to = self.lasttime + self.period - GetTime()
            if time_to < 0 then
                time_to = 0
            end
        end
    
        return time_to
    elseif self.status == READY then
        return 0
    end
    
    return nil
    
end


function PriorityNode:DBString()
    local time_till = 0
    if self.period then
       time_till = (self.lasttime or 0) + self.period - GetTime()
    end
    
    return string.format("execute %d, eval in %2.2f", self.idx or -1, time_till)
end


function PriorityNode:Reset()
    self._base.Reset(self)
    self.idx = nil
end

function PriorityNode:Visit()
    
    local time = GetTime()
    local do_eval = not self.lasttime or not self.period or self.lasttime + self.period < time 
    local oldidx = self.idx
    
    
    if do_eval then
        
        local old_event = nil
        if self.idx and self.children[self.idx]:is_a(EventNode) then
            old_event = self.children[self.idx]
        end

        self.lasttime = time
        local found = false
        for idx, child in ipairs(self.children) do
        
            local should_test_anyway = old_event and child:is_a(EventNode) and old_event.priority <= child.priority
            if not found or should_test_anyway then
            
                if child.status == FAILED or child.status == SUCCESS then
                    child:Reset()
                end
                child:Visit()
                local cs = child.status
                if cs == SUCCESS or cs == RUNNING then
                    if should_test_anyway and self.idx ~= idx then
                        self.children[self.idx]:Reset()
                    end
                    self.status = cs
                    found = true
                    self.idx = idx
                end
            else
                
                child:Reset()
            end
        end
        if not found then
            self.status = FAILED
        end
        
    else
        if self.idx then
            local child = self.children[self.idx]
            if child.status == RUNNING then
                child:Visit()
                self.status = child.status
                if self.status ~= RUNNING then
                    self.lasttime = nil
                end
            end
        end
    end
    
end


---------------------------------------------------------------------------------------


ParallelNode = Class(BehaviourNode, function(self, children, name)
    BehaviourNode._ctor(self, name or "Parallel", children)
end)


function ParallelNode:Step()
    if self.status ~= RUNNING then
        self:Reset()
    elseif self.children then
        for k, v in ipairs(self.children) do
            if v.status == SUCCESS and v:is_a(ConditionNode) then
                v:Reset()
            end         
        end
    end
end

function ParallelNode:Visit()
    local done = true
    local any_done = false
    for idx, child in ipairs(self.children) do
        
        if child:is_a(ConditionNode) then
            child:Reset()
        end
        
        if child.status ~= SUCCESS then
            child:Visit()
            if child.status == FAILED then
                self.status = FAILED
                return
            end
        end
        
        if child.status == RUNNING then
            done = false
        else
            any_done = true
        end
        
        
    end

    if done or (self.stoponanycomplete and any_done) then
        self.status = SUCCESS
    else
        self.status = RUNNING
    end    
end

ParallelNodeAny = Class(ParallelNode, function(self, children)
    ParallelNode._ctor(self, children, "Parallel(Any)")
    self.stoponanycomplete = true
end)



---------------------------------------------------------------------------------------


EventNode = Class(BehaviourNode, function(self, inst, event, child, priority)
    BehaviourNode._ctor(self, "Event("..event..")", {child})
    self.inst = inst
    self.event = event
    self.priority = priority or 0

    self.eventfn = function(inst, data) self:OnEvent(data) end
    self.inst:ListenForEvent(self.event, self.eventfn)
    --print(self.inst, "EventNode()", self.event)
end)

function EventNode:OnStop()
    --print(self.inst, "EventNode:OnStop()", self.event)
    if self.eventfn then
        self.inst:RemoveEventCallback(self.event, self.eventfn)
        self.eventfn = nil
    end
end

function EventNode:OnEvent(data)
    --print(self.inst, "EventNode:OnEvent()", self.event)
    
    if self.status == RUNNING then
        self.children[1]:Reset()
    end
    self.triggered = true
    self.data = data
    
    if self.inst.brain then
        self.inst.brain:ForceUpdate()
    end
    
    self:DoToParents(function(node) if node:is_a(PriorityNode) then node.lasttime = nil end end)
    
    --wake the parent!
end

function EventNode:Step()
    self._base.Step(self)
    self.triggered = false
end

function EventNode:Reset()
    self.triggered = false
    self._base.Reset(self)
end

function EventNode:Visit()
    
    if self.status == READY and self.triggered then
        self.status = RUNNING
    end

    if self.status == RUNNING then
        if self.children and #self.children == 1 then
            local child = self.children[1]
            child:Visit()
            self.status = child.status
        else
            self.status = FAILED
        end
    end
    
end

---------------------------------------------------------------

function WhileNode(cond, name, node)
    return ParallelNode
        {
            ConditionNode( cond, name),
            node
        }
end

---------------------------------------------------------------

function IfNode(cond, name, node)
    return SequenceNode
        {
            ConditionNode( cond, name),
            node
        }
end
---------------------------------------------------------------

