local function onbrushable(self, value)
    if value then
        self.inst:AddTag("brushable")
    else
        self.inst:RemoveTag("brushable")
    end
end

local Brushable = Class(function(self, inst)
    self.inst = inst

    self.prize = nil
    self.max = 0
    self.cyclesperprize = 0
    self.lastbrushcycle = 0

    self.brushable = true

    self:SetBrushable(self.brushable)
end,
nil,
{
    brushable = onbrushable
})

function Brushable:SetBrushable(brushable, reset)
    self.brushable = brushable   
    if reset == true then
        self.lastbrushcycle = GetClock().numcycles
    end
end

function Brushable:SetOnBrushed(fn)
    self.onbrushfn = fn
end

function Brushable:CalculateNumPrizes()
    local elapsed = GetClock().numcycles - self.lastbrushcycle
    return elapsed <= 0 and 0 or math.min( math.floor(elapsed/self.cyclesperprize), self.max )
end

function Brushable:Brush(doer, brush)
    local numprizes = 0
    if self.brushable and self.prize ~= nil or self.max > 0 then
        numprizes = self:CalculateNumPrizes()
        self.lastbrushcycle = GetClock().numcycles

        for i=1,numprizes do
            local prize = SpawnPrefab(self.prize)
            if doer.components.inventory then
                doer.components.inventory:GiveItem(prize, nil, self.inst:GetPosition())
            else
                prize.Transform:SetPosition(doer.Transform:GetWorldPosition())
            end
        end
    end

    -- no callback, I'm just using the event...
    self.inst:PushEvent("brushed", {doer = doer, numprizes = numprizes})
    if self.onbrushfn ~= nil then
        self.onbrushfn(self.inst, doer, numprizes)
    end
end

function Brushable:OnSave()
    return {
        lastbrushcycle = self.lastbrushcycle,
        brushable = self.brushable,
    }
end

function Brushable:OnLoad(data)
    self.lastbrushcycle = data.lastbrushcycle or 0
    -- See comments in beard; because beard growth is controlled by SG, we need to save whether we were brushable at save or not.
    self.brushable = data.brushable == nil and true or data.brushable
    self:SetBrushable(self.brushable)
end

function Brushable:GetDebugString()
    return string.format(" %s lastcycle: %d prizes: %d", tostring(self.brushable), self.lastbrushcycle, self:CalculateNumPrizes())
end

return Brushable
