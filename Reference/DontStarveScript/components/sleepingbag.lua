local SleepingBag = Class(function(self, inst)
    self.inst = inst
end)

function SleepingBag:CollectInventoryActions(doer, actions)

	if doer and doer:HasTag("player") and not doer:HasTag("insomniac") then
		table.insert(actions, ACTIONS.SLEEPIN)
	end
end

function SleepingBag:CollectSceneActions(doer, actions)
    if doer and doer:HasTag("player") and not doer:HasTag("insomniac") then
		table.insert(actions, ACTIONS.SLEEPIN)
    end
end



function SleepingBag:CollectUseActions(doer, target, actions)
    if target and target:HasTag("player") and not doer:HasTag("insomniac") then
		table.insert(actions, ACTIONS.SLEEPIN)
    end
end

function SleepingBag:DoSleep(doer)
	if self.onsleep then
		self.onsleep(self.inst, doer)
	end	
end

return SleepingBag