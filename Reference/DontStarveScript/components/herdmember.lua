local function OnInit(inst)
    inst.components.herdmember.task = nil
    inst.components.herdmember:CreateHerd()
end

--- Tracks the herd that the object belongs to, and creates one if missing
local HerdMember = Class(function(self, inst)
    self.inst = inst

    self.enabled = true

    self.herd = nil
    self.herdprefab = "beefaloherd"

    self.task = self.inst:DoTaskInTime(5, OnInit)
end)

function HerdMember:SetHerd(herd)
    self.herd = herd
end

function HerdMember:SetHerdPrefab(prefab)
    self.herdprefab = prefab
end

function HerdMember:GetHerd()
    return self.herd
end

function HerdMember:CreateHerd()
    if not self.herd then
        self.herd = SpawnPrefab(self.herdprefab)

        if self.herd then
            self.herd.Transform:SetPosition(self.inst.Transform:GetWorldPosition())

            if self.createherdfn then
                self.createherdfn(self.inst, self.herd)
            end

            if self.herd.components.herd then
                self.herd.components.herd:AddMember(self.inst)
                self.herd.components.herd:GatherNearbyMembers()
            end
        end

        assert(self.herd ~= nil)
    end
end

function HerdMember:Enable(enabled)
    if not enabled and self.herd ~= nil then
        self.herd.components.herd:RemoveMember(self.inst)
    elseif enabled and self.herd == nil then
        self.task = self.inst:DoTaskInTime(5, OnInit)
    end
    self.enabled = enabled
end

function HerdMember:GetDebugString()
    return string.format("herd: %s", tostring(self.herd))
end


return HerdMember
