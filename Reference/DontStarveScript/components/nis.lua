local NIS = Class(function(self, inst)
    self.inst = inst
    self.playing = false
    self.skippable = false
    self.data = {}
    self.name = ""
    self.inputhandlers = {}
    table.insert(self.inputhandlers, TheInput:AddControlHandler(CONTROL_PRIMARY, function() self:OnClick() end))    
    table.insert(self.inputhandlers, TheInput:AddControlHandler(CONTROL_SECONDARY, function() self:OnClick() end))
    table.insert(self.inputhandlers, TheInput:AddControlHandler(CONTROL_ATTACK, function() self:OnClick() end))
    table.insert(self.inputhandlers, TheInput:AddControlHandler(CONTROL_INSPECT, function() self:OnClick() end))
    table.insert(self.inputhandlers, TheInput:AddControlHandler(CONTROL_ACTION, function() self:OnClick() end))    
    table.insert(self.inputhandlers, TheInput:AddControlHandler(CONTROL_CONTROLLER_ACTION, function() self:OnClick() end))    
end)


function NIS:OnRemoveEntity()
    for k,v in pairs(self.inputhandlers) do
        v:Remove()
    end
end


function NIS:SetName(name)
    self.name = name
end

function NIS:SetScript(fn)
    self.script = fn
end

function NIS:SetInit(fn)
    self.init = fn
end

function NIS:SetCancel(fn)
    self.cancel = fn
end

function NIS:OnFinish()
    self.playing = false
    self.task = nil
    self.inst:Remove()
end

function NIS:Cancel()

    IncTrackingStat(self.name, "nis_skip")

    if self.task then
        KillThread(self.task)
    end

    if self.cancel then
        self.cancel(self.data)
    end
    
    self:OnFinish()
end

function NIS:OnClick()
    if self.skippable then
        self:Cancel()
    end
end

function NIS:Play(lines)
    self.playing = true
    if self.init then
        self.init(self.data)
    end
    
    if self.script then
        self.task = self.inst:StartThread( 
            function() 
                self.script(self, self.data, lines)
                self:OnFinish()
            end)
        
    else
        self:OnFinish()
    end
    
end

return NIS