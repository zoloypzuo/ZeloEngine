FUELTYPE = 
{
    "BURNABLE",
    "GASOLINE",
}


local Fuel = Class(function(self, inst)
    self.inst = inst
    self.fuelvalue = 1
    self.fueltype = "BURNABLE"
    self.ontaken = nil
end)

function Fuel:SetOnTakenFn(fn)
    self.ontaken = fn
end

function Fuel:Taken(taker)
    self.inst:PushEvent("fueltaken", {taker = taker})
    if self.ontaken then
        self.ontaken(self.inst, taker)
    end
end

function Fuel:CollectUseActions(doer, target, actions)
    if target.components.fueled and target.components.fueled:CanAcceptFuelItem(self.inst) then
        table.insert(actions, ACTIONS.ADDFUEL)
    end
end

-- function Fuel:CollectInventoryActions(doer, target, actions)
--     if target and target.components and target.components.fueled and target.components.fueled:CanAcceptFuelItem(self.inst) then
--         print("collect inventory actions")
--         table.insert(actions, ACTIONS.ADDFUEL)
--     end
-- end


return Fuel
