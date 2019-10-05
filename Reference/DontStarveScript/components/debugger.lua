local Debugger = Class(function(self, inst)
    self.inst = inst
    self.debugger = self.inst.entity:AddDebugRender()

    self.z = 0.5

    self.debuggerdraws = 
    {
        -- key = 
        -- {   
        --     c = {r = 0, g = 1, b = 0, a = 1},
        --     p1 = {x = 0, y = 0},
        --     p2 = {x = 0, y = 0},
        -- },
    }

    self.debugger:SetZ(self.z)
    self.debugger:SetRenderLoop(true)
    self.inst:StartUpdatingComponent(self)
end)

function Debugger:SetOrigin(key, x, y)
    if not self.debuggerdraws[key] then
        self.debuggerdraws[key] = {}
    end
    self.debuggerdraws[key].p1 = {x = x, y = y}
end

function Debugger:SetTarget(key, x, y)
    if not self.debuggerdraws[key] then
        self.debuggerdraws[key] = {}
    end
    self.debuggerdraws[key].p2 = {x = x, y = y}
end

function Debugger:SetColour(key, r, g, b, a)
    if not self.debuggerdraws[key] then
        self.debuggerdraws[key] = {}
    end
    self.debuggerdraws[key].c = {r = r, g = g, b = b, a = a}
end

function Debugger:SetAll(key, origin, tar, colour)

    --For this to work you have to pass in properly formatted tables.
    -- origin/ tar = {x = #, y = #}
    -- colour = {r = #, g = #, b = #, a = #}

    if not self.debuggerdraws[key] then
        self.debuggerdraws[key] = {}
    end
    if origin then
        self.debuggerdraws[key].p1 = origin
    end

    if tar then
        self.debuggerdraws[key].p2 = tar
    end

    if colour then
        self.debuggerdraws[key].c = colour
    end
end

function Debugger:SetZ(val)
    self.debugger:SetZ(self.z)
end

function Debugger:OnUpdate()
    self.debugger:Flush()
    for k,v in pairs(self.debuggerdraws) do   

        local colour = v.c or {r = 0, g = 1, b = 0, a = 1}
        local p1 = v.p1 or {x = 0, y = 0}
        local p2 = v.p2 or {x = 100, y = 100}
        if p1 ~= nil and p2 ~= nil then
            self.debugger:Line(p1.x, p1.y, p2.x, p2.y, colour.r, colour.g, colour.b, colour.a)
        end
    end

end

return Debugger