local function DoGather(inst)
    if inst.components.herd then
        inst.components.herd:GatherNearbyMembers()
    end
end

local Herd = Class(function(self, inst)
    self.inst = inst
    self.maxsize = 12
    self.members = {}
    self.membercount = 0
    self.membertag = nil
    
    self.gatherrange = nil
    self.updaterange = nil
    
    self.onempty = nil
    self.onfull = nil
    self.addmember = nil
	self.automaticcleanup = true

    self.updatepos = true
    
    self.task = self.inst:DoPeriodicTask(6+math.random(), function() self:OnUpdate() end)
end)

function Herd:GetDebugString()
    local str = "{"
    for k,v in pairs(self.members) do
        str = str..k.GUID..","
    end
    str = str.."}"
    return str
end

function Herd:AutomaticCleanup(b)
	self.automaticcleanup = b
end

function Herd:SetMemberTag(tag)
    self.membertag = tag
end

function Herd:SetGatherRange(range)
    self.gatherrange = range
end

function Herd:SetUpdateRange(range)
    self.updaterange = range
end

function Herd:SetMaxSize(size)
    self.maxsize = size
end

function Herd:SetOnEmptyFn(fn)
    self.onempty = fn
end

function Herd:SetOnFullFn(fn)
    self.onfull = fn
end

function Herd:SetAddMemberFn(fn)
    self.addmember = fn
end

function Herd:IsFull()
    return self.membercount >= self.maxsize
end

function Herd:AddMember(inst)
    if not self.members[inst] then
        self.membercount = self.membercount + 1
        self.members[inst] = true
        if inst.components.knownlocations then
            inst.components.knownlocations:RememberLocation("herd", Vector3(self.inst.Transform:GetWorldPosition() ))
        end
        if inst.components.herdmember then
            if inst.components.herdmember:GetHerd() ~= nil then       
                inst.components.herdmember:GetHerd().components.herd.RemoveMember(inst)
            end
            inst.components.herdmember:SetHerd(self.inst)
        end
        if self.addmember then
            self.addmember(self.inst, inst)
        end
        self.inst:ListenForEvent("death", function(inst) self:RemoveMember(inst) end, inst)
        
        if self.onfull and self.membercount == self.maxsize then
            self.onfull(self.inst)
        end
    end
end

function Herd:RemoveMember(inst)
    if self.members and self.members[inst] then
        if inst.components.knownlocations then
            inst.components.knownlocations:RememberLocation("herd", nil)
        end
        if inst.components.herdmember then
            inst.components.herdmember:SetHerd(nil)
        end
        self.membercount = self.membercount - 1
        self.members[inst] = nil
        
        if self.onempty and not next(self.members) then
            self.onempty(self.inst)
        end
    end
end

function Herd:GatherNearbyMembers()
    if not self.gatherrange or self:IsFull() then
        return
    end
    
    local x,y,z = self.inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x,y,z, self.gatherrange, self.membertag and {self.membertag} or nil )

    for k,v in pairs(ents) do 
        if not self.members[v]
           and not (v.components.herdmember and v.components.herdmember.herd)
           and not (v.components.health and v.components.health:IsDead() )
           and (not self.membertag or v:HasTag(self.membertag) ) then
            self:AddMember(v)
        end
        if self:IsFull() then
            break
        end
    end
end

function Herd:MergeNearbyHerds()
    if not self.gatherrange or self:IsFull() then
        return
    end
    
    local x,y,z = self.inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x,y,z, self.gatherrange, {"herd"})

    for k,v in pairs(ents) do 
        if v ~= self.inst
           and v.components.herd
           and v.components.herd.gathertag == self.membertag
           and v.components.herd.membercount < 4 and (self.membercount + v.components.herd.membercount) <= self.maxsize then
            for k2,v2 in pairs(v.components.herd.members) do
                self:AddMember(k2)
            end
            v:Remove()
        end
    end
end

function Herd:OnUpdate()
    self:GatherNearbyMembers()
    self:MergeNearbyHerds()

    if self.automaticcleanup and self.membercount == 0 then
        self.inst:Remove()
        return
    end

    if self.membercount > 0 and self.updaterange then
        local updatedPos = nil
        local validMembers = 0
        for k,v in pairs(self.members) do
            if self.membertag and not k:HasTag(self.membertag) then
                self:RemoveMember(k)
            elseif (k.components.combat and not k.components.combat.target)
               and self.inst:GetDistanceSqToInst(k) <= self.updaterange*self.updaterange then
                if not updatedPos then
                    updatedPos = Vector3(k.Transform:GetWorldPosition())
                else
                    updatedPos = updatedPos + Vector3(k.Transform:GetWorldPosition())
                end
                validMembers = validMembers + 1
            end
        end
        if updatedPos and self.updatepos then
            updatedPos = updatedPos / validMembers
            self.inst.Transform:SetPosition(updatedPos:Get())
        end
    end
    for k,v in pairs(self.members) do
        if k.components.knownlocations then
            k.components.knownlocations:RememberLocation("herd", Vector3(self.inst.Transform:GetWorldPosition()))
        end
    end
end

function Herd:OnSave()
    local data = {}
    
    for k,v in pairs(self.members) do
        if not data.members then
            data.members = {k.GUID}
        else
            table.insert(data.members, k.GUID)
        end
    end
    
    return data, data.members
end


function Herd:LoadPostPass(newents, savedata)
    if savedata.members then
        for k,v in pairs(savedata.members) do
            local member = newents[v]
            if member then
                self:AddMember(member.entity)
            end
        end
    end
end

return Herd
