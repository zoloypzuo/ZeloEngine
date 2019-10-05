
local mine_test_fn = function(dude, inst) return dude.components.combat and not (dude.components.health and dude.components.health:IsDead() and dude.components.combat:CanBeAttacked(inst)) end
local mine_test_tags = {"monster", "character", "animal"}

local function MineTest(inst)
    local mine = inst.components.mine
    
    local notags = {"notraptrigger", "flying"}
    if mine.alignment then
		table.insert(notags, mine.alignment)
    end
    
    if mine and mine.radius then
        
        local target = FindEntity(inst, mine.radius, mine_test_fn, nil, notags, mine_test_tags)
        
        if target and (not target.sg or (target.sg and not target.sg:HasStateTag("flying"))) then
            mine:Explode(target)
        end
    end
end

local Mine = Class(function(self, inst)
    self.inst = inst
    
    self.radius = nil
    self.onexplode = nil
    self.onreset = nil
    self.onsetsprung = nil
    self.target = nil
    self.issprung = false
	self.inactive = true
	
	self.alignment = "player"
    self.inst:ListenForEvent("onputininventory", function(inst) self:Deactivate() end)
end)

function Mine:SetRadius(radius)
    self.radius = radius
end

function Mine:SetOnExplodeFn(fn)
    self.onexplode = fn
end

function Mine:SetOnSprungFn(fn)
    self.onsetsprung = fn
end

function Mine:SetOnResetFn(fn)
    self.onreset = fn
end

function Mine:SetOnDeactivateFn(fn)
    self.ondeactivate = fn
end

function Mine:SetAlignment(alignment)
	self.alignment = alignment
end

function Mine:SetReusable(reusable)
    self.canreset = reusable
end

function Mine:Reset()
    self:StopTesting()
    self.target = nil
    self.issprung = false
    self.inactive = false
    if self.onreset then
        self.onreset(self.inst)
    end
    self:StartTesting()
end

function Mine:StartTesting()
    self:StopTesting()
    self.testtask = self.inst:DoPeriodicTask(1 + math.random(), MineTest, math.random(.9, 1))
end

function Mine:StopTesting()
    if self.testtask then
        self.testtask:Cancel()
        self.testtask = nil
    end
end

function Mine:CollectSceneActions(doer, actions, right)
    if right and self.issprung then
        table.insert(actions, ACTIONS.RESETMINE)
    end
end


function Mine:Deactivate()
    self:StopTesting()
    self.issprung = false
	self.inactive = true    
    if self.ondeactivate then
        self.ondeactivate(self.inst)
    end
end

function Mine:GetTarget()
    return self.target
end

function Mine:Explode(target)
    self:StopTesting()
    self.target = target
    self.issprung = true
	self.inactive = false    
    ProfileStatsAdd("trap_sprung_" .. target.prefab)
    if self.onexplode then
        self.onexplode(self.inst, target)
    end
end

function Mine:OnSave()
    if self.issprung then
        return {sprung = true}
    elseif self.inactive then
		return {inactive = true}
    end
end

function Mine:OnLoad(data)
    if data.sprung then
		self.inactive = false
        self.issprung = true
        self:StopTesting()
        if self.onsetsprung then
            self.onsetsprung(self.inst)
        end
    elseif data.inactive then
		self:Deactivate()
    else
		self:Reset()
    end
end

function Mine:OnRemoveEntity()
    self:StopTesting()
end


return Mine
