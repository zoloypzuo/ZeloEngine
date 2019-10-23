local Pickable = Class(function(self, inst)
    self.inst = inst
    self.canbepicked = nil
    self.regentime = nil
    self.product = nil
    self.onregenfn = nil
    self.onpickedfn = nil
    self.makeemptyfn = nil
    self.makefullfn = nil
    self.makebarrenfn = nil
    self.cycles_left = nil
    self.transplanted = false
    self.caninteractwith = true
    self.numtoharvest = 1

    self.paused = false
    self.pause_time = 0
end)

function Pickable:LongUpdate(dt)

    if not self.paused and self.targettime then

        if self.task then
            self.task:Cancel()
            self.task = nil
        end

        local time = GetTime()
        if self.targettime > time + dt then
            --resechedule
            local time_to_pickable = self.targettime - time - dt
            self.task = self.inst:DoTaskInTime(time_to_pickable, OnRegen, "regen")
            self.targettime = time + time_to_pickable
        else
            --become pickable right away
            self:Regen()
        end
    end
end

function Pickable:FinishGrowing()
    if not self.canbepicked then
        if self.task then
            self.task:Cancel()
            self.task = nil
            self:Regen()
        end
    end
end

function Pickable:Resume()
    if self.paused then
        self.paused = false
        if not self.canbepicked and (not self.cycles_left or self.cycles_left > 0) then

            if self.pause_time then
                self.task = self.inst:DoTaskInTime(self.pause_time, OnRegen, "regen")
                self.targettime = GetTime() + self.pause_time
            else
                self:MakeEmpty()
            end

        end
    end
end

function Pickable:Pause()

    if self.paused == false then
        self.pause_time = nil
        self.paused = true

        if self.task then
            self.task:Cancel()
            self.task = nil
        end

        if self.targettime then
            self.pause_time = math.max(0, self.targettime - GetTime())
        end
    end
end

function Pickable:GetDebugString()
    local time = GetTime()

    if self.caninteractwith then
        local str = "caninteractwith"
        return str
    elseif self.paused then
        local str = "paused"
        if self.pause_time then
            str = str .. string.format(" %2.2f", self.pause_time)
        end
        return str
    elseif self.transplanted then
        local str = "cycles:" .. tostring(self.cycles_left) .. " / " .. tostring(self.max_cycles)
        if self.targettime and self.targettime > time then
            str = str .. " Regen in:" .. tostring(math.floor(self.targettime - time))
        end
        return str
    else
        local str = "Not transplanted "
        if self.targettime and self.targettime > time then
            str = str .. " Regen in:" .. tostring(math.floor(self.targettime - time))
        end
        return str
    end
end

function Pickable:SetUp(product, regen, number)
    self.canbepicked = true
    self.product = product
    self.regentime = regen
    self.numtoharvest = number or 1
end

function Pickable:SetOnPickedFn(fn)
    self.onpickedfn = fn
end

function Pickable:SetOnRegenFn(fn)
    self.onregenfn = fn
end

function Pickable:SetMakeBarrenFn(fn)
    self.makebarrenfn = fn
end

function Pickable:SetMakeEmptyFn(fn)
    self.makeemptyfn = fn
end

function Pickable:CanBeFertilized()
    if self.fertilizable ~= false and self.cycles_left == 0 then
        return true
    end
end

function Pickable:Fertilize(fertilizer)
    fertilizer:Remove()
    self.cycles_left = self.max_cycles

    self:MakeEmpty()
end

function Pickable:OnSave()

    local data = {
        picked = not self.canbepicked and true or nil,
        transplanted = self.transplanted and true or nil,
        paused = self.paused and true or nil,
        caninteractwith = self.caninteractwith and true or nil,
        --pause_time = self.pause_time
    }

    if self.cycles_left ~= self.max_cycles then
        data.cycles_left = self.cycles_left
        data.max_cycles = self.max_cycles
    end

    if self.pause_time and self.pause_time > 0 then
        data.pause_time = self.pause_time
    end

    if self.targettime then
        local time = GetTime()
        if self.targettime > time then
            data.time = math.floor(self.targettime - time)
        end
    end

    if next(data) then
        return data
    end
end

function Pickable:OnLoad(data)

    self.transplanted = data.transplanted or false

    self.cycles_left = data.cycles_left or self.cycles_left
    self.max_cycles = data.max_cycles or self.max_cycles

    if data.picked or data.time then
        if self.cycles_left == 0 and self.makebarrenfn then
            self.makebarrenfn(self.inst)
        elseif self.makeemptyfn then
            self.makeemptyfn(self.inst)
        end
        self.canbepicked = false
    else
        if self.makefullfn then
            self.makefullfn(self.inst)
        end
    end

    if data.caninteractwith then
        self.caninteractwith = data.caninteractwith
    end

    if data.paused then
        self.paused = true
        self.pause_time = data.pause_time
    else
        if data.time then
            self.task = self.inst:DoTaskInTime(data.time, OnRegen, "regen")
            self.targettime = GetTime() + data.time
        end
    end

    if data.makealwaysbarren == 1 then
        if self.makebarrenfn then
            self:MakeBarren()
        end
    end
end

function Pickable:IsBarren()
    return self.cycles_left and self.cycles_left == 0
end

function Pickable:CanBePicked()
    return self.canbepicked
end

function OnRegen(inst)
    if inst.components.pickable then
        inst.components.pickable:Regen()
    end
end

function Pickable:Regen()

    self.canbepicked = true
    if self.onregenfn then
        self.onregenfn(self.inst)
    end
    self.targettime = nil
    self.task = nil
end

function Pickable:MakeBarren()

    self.cycles_left = 0
    self.canbepicked = false
    if self.task then
        self.task:Cancel()
    end

    if self.makebarrenfn then
        self.makebarrenfn(self.inst)
    end
end

function Pickable:OnTransplant()
    self.transplanted = true

    if self.ontransplantfn then
        self.ontransplantfn(self.inst)
    end
end

function Pickable:MakeEmpty()

    if self.task then
        self.task:Cancel()
    end

    if self.makeemptyfn then
        self.makeemptyfn(self.inst)
    end

    self.canbepicked = false

    if not self.paused then
        if self.regentime then
            local time = self.regentime

            if self.getregentimefn then
                time = self.getregentimefn(self.inst)
            end

            self.task = self.inst:DoTaskInTime(time, OnRegen, "regen")
            self.targettime = GetTime() + time
        end
    end
end

function Pickable:Pick(picker)

    if self.canbepicked and self.caninteractwith then

        if self.transplanted then
            if self.cycles_left ~= nil then
                self.cycles_left = self.cycles_left - 1
            end
        end

        local loot = nil
        if picker and picker.components.inventory and self.product then
            loot = SpawnPrefab(self.product)

            if loot then
                if self.numtoharvest > 1 and loot.components.stackable then
                    loot.components.stackable:SetStackSize(self.numtoharvest)
                end
                picker:PushEvent("picksomething", { object = self.inst, loot = loot })
                picker.components.inventory:GiveItem(loot, nil, Vector3(TheSim:GetScreenPos(self.inst.Transform:GetWorldPosition())))
            end
        end

        if self.onpickedfn then
            self.onpickedfn(self.inst, picker, loot)
        end

        self.canbepicked = false

        if not self.paused and self.regentime and (self.cycles_left == nil or self.cycles_left > 0) then
            self.task = self.inst:DoTaskInTime(self.regentime, OnRegen, "regen")
            self.targettime = GetTime() + self.regentime
        end

        self.inst:PushEvent("picked", { picker = picker, loot = loot })
    end
end

function Pickable:CollectSceneActions(doer, actions)
    if self.canbepicked and self.caninteractwith then
        table.insert(actions, ACTIONS.PICK)
    end
end

return Pickable
