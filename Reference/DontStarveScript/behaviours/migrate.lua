Migrate = Class(BehaviourNode, function(self, inst, homelocation)
    BehaviourNode._ctor(self, "Migrate")
    self.homepos = homelocation
    self.inst = inst
end)


function Migrate:Visit()

    local MIGRATION_HOME_RADIUS_SQ = 8 * 8
    --print("Migrate:Visit for "..tostring(self))

    local distanceToHome = self:GetDistFromHomeSq()

    if distanceToHome and distanceToHome < MIGRATION_HOME_RADIUS_SQ then
        --print("RJL arrived at migration home!")
        self.inst.components.locomotor:RemoveSpeedModifier_Mult("migration")
        self.status = FAILED
    end

    if self.status == READY then
        local homePos = self:GetHomePos()
        -- run true, but rainbowjellyfish runspeed is purposefully slower than walking to take advantage of that mode for migration
        self.inst.components.locomotor:GoToPoint(self:GetHomePos())
        self.status = RUNNING
        self.inst.components.locomotor:AddSpeedModifier_Mult("migration", -0.8)
    elseif self.status == RUNNING then
        if distanceToHome and distanceToHome < MIGRATION_HOME_RADIUS_SQ then
            --print("RJL arrived at migration home!")
            self.status = SUCCESS
        end
    end
end

function Migrate:GetHomePos()
    return self.inst.components.knownlocations:GetLocation("migration")
    --if type(self.homepos) == "function" then
    --    return self.homepos(self.inst)
    --end
    --return self.homepos
end

function Migrate:GetDistFromHomeSq()
    local homepos = self:GetHomePos()
	if not homepos then
		return nil
	end
    local pos = Vector3(self.inst.Transform:GetWorldPosition())
    return distsq(homepos, pos)
end
