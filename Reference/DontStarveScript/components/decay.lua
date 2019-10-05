local Decay = Class(function(self, inst)
    self.inst = inst
    self.maxhealth = 100
    self.decayrate = 1
    self.currenthealth = self.maxhealth
end)

function Decay:DoDelta(amount)

    local oldhealth = self.currenthealth
    
    self.currenthealth = self.currenthealth + amount
    
    if self.currenthealth <= 0 then
    	if oldhealth > 0 then
    		self.inst:PushEvent("spentfuel")
    	end
        self.currenthealth = 0
    end

    if self.currenthealth > self.maxhealth then
    	self.inst:PushEvent("addfuel")
    end

	--print ("Decay: Fuel: ", self.currenthealth, "State:",self.inst.sg.currentstate.name)

end


local function delta(health, amount, pause, num)
    while true do
        if not health.paused then
            health:DoDelta(amount)
            
            if num then
                num = num - self.decayrate
                if num <= 0 then
                    return
                end
            end
        end
        
        Sleep(pause)
    end


end

function Decay:SetTimeDelta(amount, pause, num)
	--print ("SetTimeDelta", amount, pause, num)
    if self.deltatask then
        KillThread(self.deltatask)
    end
    -- Only set the timer if we are going to need an update
    if pause >0 then
    	
    	self.deltatask = StartThread(function() delta(self, amount, pause, num) self.deltatask = nil end, self.inst.GUID)
    end
end



return Decay
