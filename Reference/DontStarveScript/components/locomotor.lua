Dest = Class(function(self, inst, world_offset)
    self.inst = inst
    self.world_offset = world_offset
end)

local PATHFIND_PERIOD = 1
local PATHFIND_MAX_RANGE = 40

local STATUS_CALCULATING = 0
local STATUS_FOUNDPATH = 1
local STATUS_NOPATH = 2

local NO_ISLAND = 127

local ARRIVE_STEP = .15

function Dest:IsValid()
    if self.inst then
        if not self.inst:IsValid() then
            return false
        end
    end
    
    return true

end

function Dest:__tostring()
    if self.inst then
        return "Going to Entity: " .. tostring(self.inst)
    elseif self.world_offset then
        return "Heading to Point: " .. tostring(self.world_offset)
    else
        return "No Dest"
    end
    
end

function Dest:GetPoint()
    local pt = nil
    
    if self.inst and self.inst.components.inventoryitem and self.inst.components.inventoryitem.owner then
        return self.inst.components.inventoryitem.owner.Transform:GetWorldPosition()
    elseif self.inst then
        return self.inst.Transform:GetWorldPosition()
    elseif self.world_offset then
        return self.world_offset.x,self.world_offset.y,self.world_offset.z
    else
        return 0, 0, 0
    end
end



local LocoMotor = Class(function(self, inst)
    self.inst = inst
    self.dest = nil
    self.atdestfn = nil
    self.bufferedaction = nil
    self.arrive_step_dist = ARRIVE_STEP
    self.arrive_dist = ARRIVE_STEP
    self.walkspeed = TUNING.WILSON_WALK_SPEED -- 4
    self.runspeed = TUNING.WILSON_RUN_SPEED -- 6
    self.bonusspeed = 0
    self.throttle = 1
	self.creep_check_timeout = 0
	self.slowmultiplier = 0.6
	self.fastmultiplier = 1.3
	
	self.groundspeedmultiplier = 1.0
    self.enablegroundspeedmultiplier = true
	self.isrunning = false
	
	self.wasoncreep = false
	self.triggerscreep = true

	--self.isupdating = nil
end)

function LocoMotor:OnEntitySleep()
	self:Stop()
	self:SetBufferedAction(nil)
end

function LocoMotor:OnEntityWake()
	if self.isupdating then
		self.inst:StartUpdatingComponent(self)
	end
end

function LocoMotor:StartUpdatingInternal()
	self.isupdating = true
	if not self.inst:IsAsleep() then
		self.inst:StartUpdatingComponent(self)
	end
end

function LocoMotor:StopUpdatingInternal()
	self.isupdating = nil
	self.inst:StopUpdatingComponent(self)
end

function LocoMotor:StopMoving()
	self.isrunning = false
    self.inst.Physics:Stop()
end

function LocoMotor:SetSlowMultiplier(m)
	self.slowmultiplier = m
end

function LocoMotor:SetTriggersCreep(triggers)
	self.triggerscreep = triggers
end

function LocoMotor:EnableGroundSpeedMultiplier(enable)
    self.enablegroundspeedmultiplier = enable
    if not enable then
        self.groundspeedmultiplier = 1
    end
end

function LocoMotor:GetWalkSpeed()
    if self.inst.components.rider and self.inst.components.rider:IsRiding() and self.inst.components.rider:GetMount() then
        local mount = self.inst.components.rider:GetMount()
        return (mount.components.locomotor.walkspeed  + self:GetBonusSpeed()) * self:GetSpeedMultiplier()
    else
        return (self.walkspeed + self:GetBonusSpeed()) * self:GetSpeedMultiplier()
    end
end

function LocoMotor:GetRunSpeed()
    if self.inst.components.rider and self.inst.components.rider:IsRiding() and self.inst.components.rider:GetMount() then
        local mount = self.inst.components.rider:GetMount()
        return (mount.components.locomotor.runspeed  + self:GetBonusSpeed()) * self:GetSpeedMultiplier()
    else        
        return (self.runspeed  + self:GetBonusSpeed()) * self:GetSpeedMultiplier()
    end
end

function LocoMotor:GetBonusSpeed()
    return self.bonusspeed
end

function LocoMotor:GetSpeedMultiplier()
	local inv_mult = 1.0
	if self.inst.components.inventory then
		for k,v in pairs (self.inst.components.inventory.equipslots) do
			if v.components.equippable then
				inv_mult = inv_mult * v.components.equippable:GetWalkSpeedMult()
			end		
		end
	end

    if self.inst.components.rider and self.inst.components.rider:IsRiding() then           
        inv_mult = 1  --beefalo overrides 
        local saddle = self.inst.components.rider:GetSaddle()
        if saddle and saddle.components.saddler then
            inv_mult = saddle.components.saddler:GetBonusSpeedMult()
        end
    end

	return inv_mult * self.groundspeedmultiplier*self.throttle
end

function LocoMotor:UpdateGroundSpeedMultiplier()
	
	self.groundspeedmultiplier = 1
    local ground = GetWorld()
	local oncreep = ground ~= nil and ground.GroundCreep:OnCreep(self.inst.Transform:GetWorldPosition())
	local x,y,z = self.inst.Transform:GetWorldPosition()
	if oncreep then
        -- if this ever needs to happen when self.enablegroundspeedmultiplier is set, need to move the check for self.enablegroundspeedmultiplier above
	    if self.triggerscreep and not self.wasoncreep then
	        local triggered = ground.GroundCreep:GetTriggeredCreepSpawners(x, y, z)
	        for _,v in ipairs(triggered) do
	            v:PushEvent("creepactivate", {target = self.inst})
	        end
	        self.wasoncreep = true
	    end
		self.groundspeedmultiplier = self.slowmultiplier
	else
        self.wasoncreep = false
		if self.fasteronroad then
            --print(self.inst, "UpdateGroundSpeedMultiplier check road" )
			if RoadManager and RoadManager:IsOnRoad( x,0,z ) then
				self.groundspeedmultiplier = self.fastmultiplier
			elseif ground ~= nil then
				local tile = ground.Map:GetTileAtPoint(x,0,z)		
				if tile and tile == GROUND.ROAD then
					self.groundspeedmultiplier = self.fastmultiplier
				end
			end
		end
	end
	
end

function LocoMotor:WalkForward()
	self.isrunning = false
    self.inst.Physics:SetMotorVel(self:GetWalkSpeed(),0,0)
    self:StartUpdatingInternal()
end

function LocoMotor:RunForward()
	self.isrunning = true
    self.inst.Physics:SetMotorVel(self:GetRunSpeed(),0,0)
    self:StartUpdatingInternal()
end

function LocoMotor:Clear()
    --Print(VERBOSITY.DEBUG, "LocoMotor:Clear", self.inst.prefab)
    self.dest = nil
    self.atdestfn = nil
    self.wantstomoveforward = nil
    self.wantstorun = nil
    self.bufferedaction = nil
    --self:ResetPath()
end

function LocoMotor:ResetPath()
    --Print(VERBOSITY.DEBUG, "LocoMotor:ResetPath", self.inst.prefab)
    self:KillPathSearch()
    self.path = nil
end

function LocoMotor:KillPathSearch()
    --Print(VERBOSITY.DEBUG, "LocoMotor:KillPathSearch", self.inst.prefab)
    if self:WaitingForPathSearch() then
        GetWorld().Pathfinder:KillSearch(self.path.handle)
    end
end

function LocoMotor:SetReachDestinationCallback(fn)
    self.atdestfn = fn
end

function LocoMotor:PushAction(bufferedaction, run, try_instant)
	if not bufferedaction then return end
	
    self.throttle = 1
    local success, reason = bufferedaction:TestForStart()
    if not success then
        self.inst:PushEvent("actionfailed", {action = bufferedaction, reason = reason})
        return
    end
    
    self:Clear()
    if bufferedaction.action == ACTIONS.WALKTO then
        if bufferedaction.target then
            self:GoToEntity(bufferedaction.target, bufferedaction, run)
        elseif bufferedaction.pos then
            self:GoToPoint(bufferedaction.pos, bufferedaction, run)
        end
    elseif bufferedaction.action.instant then
        self.inst:PushBufferedAction(bufferedaction)
    else
        if bufferedaction.target then
            self:GoToEntity(bufferedaction.target, bufferedaction, run)
        elseif bufferedaction.pos then
            self:GoToPoint(bufferedaction.pos, bufferedaction, run)
        else
            self.inst:PushBufferedAction(bufferedaction)
        end
    end

end


function LocoMotor:GoToEntity(inst, bufferedaction, run)
    self.dest = Dest(inst)
    self.throttle = 1
    
    self:SetBufferedAction(bufferedaction)
    self.wantstomoveforward = true
    
    if bufferedaction and bufferedaction.distance then
		self.arrive_dist = bufferedaction.distance
	else
        self.arrive_dist = ARRIVE_STEP

		if inst.Physics then
			self.arrive_dist = self.arrive_dist + ( inst.Physics:GetRadius() or 0)
		end

		if self.inst.Physics then
			self.arrive_dist = self.arrive_dist + (self.inst.Physics:GetRadius() or 0)
		end
	end

    if self.directdrive then
        if run then
            self:RunForward()
        else
            self:WalkForward()
        end
    else
        self:FindPath()
    end
    
    self.wantstorun = run
    --self.arrive_step_dist = ARRIVE_STEP
    self:StartUpdatingInternal()
end

function LocoMotor:GoToPoint(pt, bufferedaction, run) 
    self.dest = Dest(nil, pt)
    self.throttle = 1

    if bufferedaction and bufferedaction.distance then
		self.arrive_dist = bufferedaction.distance
	else
		self.arrive_dist = ARRIVE_STEP
	end
    --self.arrive_step_dist = ARRIVE_STEP
    self.wantstorun = run
    
    if self.directdrive then
        if run then
            self:RunForward()
        else
            self:WalkForward()
        end
    else
        self:FindPath()
    end
    self.wantstomoveforward = true
    self:SetBufferedAction(bufferedaction)
    self:StartUpdatingInternal()
end


function LocoMotor:SetBufferedAction(act)
    if self.bufferedaction then
        self.bufferedaction:Fail()
    end
    self.bufferedaction = act
end

function LocoMotor:Stop()
    --Print(VERBOSITY.DEBUG, "LocoMotor:Stop", self.inst.prefab)
	self.isrunning = false
    self.dest = nil
    self:ResetPath()
    self.lastdesttile = nil
    --self.arrive_step_dist = 0

    --self:SetBufferedAction(nil)
    self.wantstomoveforward = false
    self.wantstorun = false
    
    self:StopMoving()

    self.inst:PushEvent("locomote")
	self:StopUpdatingInternal()
end

function LocoMotor:WalkInDirection(direction, should_run)
    --Print(VERBOSITY.DEBUG, "LocoMotor:WalkInDirection ", self.inst.prefab)
	self:SetBufferedAction(nil)
    if not self.inst.sg or self.inst.sg:HasStateTag("canrotate") then
        self.inst.Transform:SetRotation(direction)
    end
            
    self.wantstomoveforward = true
    self.wantstorun = should_run
    self:ResetPath()
    self.lastdesttile = nil
    
    if self.directdrive then
        self:WalkForward()
    end
    self.inst:PushEvent("locomote")
    self:StartUpdatingInternal()
end


function LocoMotor:RunInDirection(direction, throttle)
    --Print(VERBOSITY.DEBUG, "LocoMotor:RunInDirection ", self.inst.prefab)
    
    self.throttle = throttle or 1
    
    self:SetBufferedAction(nil)
    self.dest = nil
    self:ResetPath()
    self.lastdesttile = nil

    if not self.inst.sg or self.inst.sg:HasStateTag("canrotate") then
        self.inst.Transform:SetRotation(direction)
    end
            
    self.wantstomoveforward = true
    self.wantstorun = true

    if self.directdrive then
        self:RunForward()
    end
    self.inst:PushEvent("locomote")
    self:StartUpdatingInternal()
end

function LocoMotor:GetDebugString()
    local pathtile_x = -1
    local pathtile_y = -1
    local tile_x = -1
    local tile_y = -1
    local ground = GetWorld()
    if ground then
        pathtile_x, pathtile_y = ground.Pathfinder:GetPathTileIndexFromPoint(self.inst.Transform:GetWorldPosition())
        tile_x, tile_y = ground.Map:GetTileCoordsAtPoint(self.inst.Transform:GetWorldPosition())
    end

    local speed = self.wantstorun and "RUN" or "WALK"
    return string.format("%s [%s] [%s] (%u, %u):(%u, %u) +/-%2.2f", speed, tostring(self.dest), tostring(self.bufferedaction), tile_x, tile_y, pathtile_x, pathtile_y, self.arrive_step_dist or 0) 
end

function LocoMotor:HasDestination()
    return self.dest ~= nil
end

function LocoMotor:SetShouldRun(should_run)
    self.wantstorun = should_run
end

function LocoMotor:WantsToRun()
    return self.wantstorun == true
end

function LocoMotor:WantsToMoveForward()
    return self.wantstomoveforward == true
end

function LocoMotor:WaitingForPathSearch()
    return self.path and self.path.handle
end

function LocoMotor:OnUpdate(dt)
    if not self.inst:IsValid() then
        Print(VERBOSITY.DEBUG, "OnUpdate INVALID", self.inst.prefab)
        self:ResetPath()
		self.inst:StopUpdatingComponent(self)	
		return
    end
    
	if self.enablegroundspeedmultiplier then
		self.creep_check_timeout = self.creep_check_timeout - dt
		if self.creep_check_timeout < 0 then
			self:UpdateGroundSpeedMultiplier()
			self.creep_check_timeout = .5
		end
	end

    --Print(VERBOSITY.DEBUG, "OnUpdate", self.inst.prefab)
    if self.dest then
        --Print(VERBOSITY.DEBUG, "    w dest")
        if not self.dest:IsValid() or (self.bufferedaction and not self.bufferedaction:IsValid()) then
            self:Clear()
            return
        end
        
        if self.inst.components.health and self.inst.components.health:IsDead() then
            self:Clear()
            return
        end
        
        local destpos_x, destpos_y, destpos_z = self.dest:GetPoint()
        local mypos_x, mypos_y, mypos_z= self.inst.Transform:GetWorldPosition()
        local dsq = distsq(destpos_x, destpos_z, mypos_x, mypos_z)

		local run_dist = self:GetRunSpeed()*dt*.5
        if dsq <= math.max(run_dist*run_dist, self.arrive_dist*self.arrive_dist) then
            --Print(VERBOSITY.DEBUG, "REACH DEST")
            self.inst:PushEvent("onreachdestination", {target=self.dest.inst, pos=Point(destpos_x, destpos_y, destpos_z)})
            if self.atdestfn then
                self.atdestfn(self.inst)
            end

            if self.bufferedaction and self.bufferedaction ~= self.inst.bufferedaction then
            
                if self.bufferedaction.target and self.bufferedaction.target.Transform then
                    self.inst:FacePoint(self.bufferedaction.target.Transform:GetWorldPosition())
                end
                self.inst:PushBufferedAction(self.bufferedaction)
            end
            self:Stop()
            self:Clear()
        else
            --Print(VERBOSITY.DEBUG, "LOCOMOTING")
            if self:WaitingForPathSearch() then
                local pathstatus = GetWorld().Pathfinder:GetSearchStatus(self.path.handle)
                --Print(VERBOSITY.DEBUG, "HAS PATH SEARCH", pathstatus)
                if pathstatus ~= STATUS_CALCULATING then
                    --Print(VERBOSITY.DEBUG, "PATH CALCULATION complete", pathstatus)
                    if pathstatus == STATUS_FOUNDPATH then
                        --Print(VERBOSITY.DEBUG, "PATH FOUND")
                        local foundpath = GetWorld().Pathfinder:GetSearchResult(self.path.handle)
                        if foundpath then
                            --Print(VERBOSITY.DEBUG, string.format("PATH %d steps ", #foundpath.steps))

                            if #foundpath.steps > 2 then
                                self.path.steps = foundpath.steps
                                self.path.currentstep = 2

                                -- for k,v in ipairs(foundpath.steps) do
                                --     Print(VERBOSITY.DEBUG, string.format("%d, %s", k, tostring(Point(v.x, v.y, v.z))))
                                -- end

                            else
                                --Print(VERBOSITY.DEBUG, "DISCARDING straight line path")
                                self.path.steps = nil
                                self.path.currentstep = nil
                            end
                        else
                            Print(VERBOSITY.DEBUG, "EMPTY PATH")
                        end
                    else
                        if pathstatus == nil then
                            Print(VERBOSITY.DEBUG, string.format("LOST PATH SEARCH %u. Maybe it timed out?", self.path.handle))
                        else
                            Print(VERBOSITY.DEBUG, "NO PATH")
                        end
                    end

                    GetWorld().Pathfinder:KillSearch(self.path.handle)
                    self.path.handle = nil
                end
            end

            if not self.inst.sg or self.inst.sg:HasStateTag("canrotate") then
                --Print(VERBOSITY.DEBUG, "CANROTATE")
                local facepos_x, facepos_y, facepos_z = destpos_x, destpos_y, destpos_z

                if self.path and self.path.steps and self.path.currentstep < #self.path.steps then
                    --Print(VERBOSITY.DEBUG, "FOLLOW PATH")
                    local step = self.path.steps[self.path.currentstep]
                    local steppos_x, steppos_y, steppos_z = step.x, step.y, step.z

                    --Print(VERBOSITY.DEBUG, string.format("CURRENT STEP %d/%d - %s", self.path.currentstep, #self.path.steps, tostring(steppos)))

                    local step_distsq = distsq(mypos_x, mypos_z, steppos_x, steppos_z)
                    if step_distsq <= (self.arrive_step_dist)*(self.arrive_step_dist) then
                        self.path.currentstep = self.path.currentstep + 1

                        if self.path.currentstep < #self.path.steps then
                            step = self.path.steps[self.path.currentstep]
                            steppos_x, steppos_y, steppos_z = step.x, step.y, step.z

                            --Print(VERBOSITY.DEBUG, string.format("NEXT STEP %d/%d - %s", self.path.currentstep, #self.path.steps, tostring(steppos)))
                        else
                            --Print(VERBOSITY.DEBUG, string.format("LAST STEP %s", tostring(destpos)))
                            steppos_x, steppos_y, steppos_z = destpos_x, destpos_y, destpos_z
                        end
                    end
                    facepos_x, facepos_y, facepos_z = steppos_x, steppos_y, steppos_z
                end

                local x,y,z = self.inst.Physics:GetMotorVel()
                if x < 0 then
                    --Print(VERBOSITY.DEBUG, "SET ROT", facepos)
	                local angle = self.inst:GetAngleToPoint(facepos_x, facepos_y, facepos_z)
                    self.inst.Transform:SetRotation(180 + angle)
                else
                    --Print(VERBOSITY.DEBUG, "FACE PT", facepos)
                    self.inst:FacePoint(facepos_x, facepos_y, facepos_z)
                end

            end
            
            self.wantstomoveforward = self.wantstomoveforward or not self:WaitingForPathSearch()
        end
    end
    
    local is_moving = self.inst.sg and self.inst.sg:HasStateTag("moving")
    local is_running = self.inst.sg and self.inst.sg:HasStateTag("running")
    local should_locomote = (not is_moving ~= not self.wantstomoveforward) or (is_moving and (not is_running ~= not self.wantstorun)) -- 'not' is being used on this line as a cast-to-boolean operator
    if not self.inst:IsInLimbo() and should_locomote then
        self.inst:PushEvent("locomote")
    elseif not self.wantstomoveforward and not self:WaitingForPathSearch() then
        self:ResetPath()
        self.inst:StopUpdatingComponent(self)
    end
    
	local cur_speed = self.inst.Physics:GetMotorSpeed()
	if cur_speed > 0 then
		
		local speed_mult = self:GetSpeedMultiplier()
		local desired_speed = self.isrunning and self.runspeed or self.walkspeed
		if self.dest and self.dest:IsValid() then
			local destpos_x, destpos_y, destpos_z = self.dest:GetPoint()
			local mypos_x, mypos_y, mypos_z = self.inst.Transform:GetWorldPosition()
			local dsq = distsq(destpos_x, destpos_z, mypos_x, mypos_z)
			if dsq <= .25 then
				speed_mult = math.max(.33, math.sqrt(dsq))
			end
		end
		
		self.inst.Physics:SetMotorVel((desired_speed + self.bonusspeed) * speed_mult, 0, 0)
	end
end

function LocoMotor:FindPath()
    --Print(VERBOSITY.DEBUG, "LocoMotor:FindPath", self.inst.prefab)

    --if self.inst.prefab ~= "wilson" then return end
    
    if not self.dest:IsValid() then
        return
    end

    local p0 = Vector3(self.inst.Transform:GetWorldPosition())
    local p1 = Vector3(self.dest:GetPoint())
    local dist = math.sqrt(distsq(p0, p1))
    --Print(VERBOSITY.DEBUG, string.format("    %s -> %s distance %2.2f", tostring(p0), tostring(p1), dist))

    -- if dist > PATHFIND_MAX_RANGE then
    --     Print(VERBOSITY.DEBUG, string.format("TOO FAR to pathfind %2.2f > %2.2f", dist, PATHFIND_MAX_RANGE))
    --     return
    -- end

    local ground = GetWorld()
    if ground then
        --Print(VERBOSITY.DEBUG, "GROUND")

        local desttile_x, desttile_y = ground.Pathfinder:GetPathTileIndexFromPoint(p1.x, p1.y, p1.z)
        --Print(VERBOSITY.DEBUG, string.format("    dest tile %d, %d", desttile_x, desttile_y))

        if desttile_x and desttile_y and self.lastdesttile then
            --Print(VERBOSITY.DEBUG, string.format("    last dest tile %d, %d", self.lastdesttile.x, self.lastdesttile.y))
            if desttile_x == self.lastdesttile.x and desttile_y == self.lastdesttile.y then
                --Print(VERBOSITY.DEBUG, "SAME PATH")
                return
            end
        end

        self.lastdesttile = {x = desttile_x, y = desttile_y}

        --Print(VERBOSITY.DEBUG, string.format("CHECK LOS for [%s] %s -> %s", self.inst.prefab, tostring(p0), tostring(p1)))

        local isle0 = ground.Map:GetIslandAtPoint(p0:Get())
        local isle1 = ground.Map:GetIslandAtPoint(p1:Get())
        --print("Islands: ", isle0, isle1)

        if isle0 ~= NO_ISLAND and isle1 ~= NO_ISLAND and isle0 ~= isle1 then
            --print("NO PATH (different islands)", isle0, isle1)
            self:ResetPath()
        elseif ground.Pathfinder:IsClear(p0.x, p0.y, p0.z, p1.x, p1.y, p1.z, self.pathcaps) then
            --print("HAS LOS")
            self:ResetPath()
        else
            --print("NO LOS - PATHFIND")

            -- while chasing a moving target, the path may get reset frequently before any search completes
            -- only start a new search if we're not already waiting for the previous one to complete OR 
            -- we already have a completed path we can keep following until new search returns
            if (self.path and self.path.steps) or not self:WaitingForPathSearch() then

                self:KillPathSearch()

                local handle = ground.Pathfinder:SubmitSearch(p0.x, p0.y, p0.z, p1.x, p1.y, p1.z, self.pathcaps)
                if handle then
                    --Print(VERBOSITY.DEBUG, string.format("PATH handle %d ", handle))

                    --if we already had a path, just keep following it until we get our new one
                    self.path = self.path or {}
                    self.path.handle = handle

                else
                    Print(VERBOSITY.DEBUG, "SUBMIT PATH FAILED")
                end
            end
        end

    end
end

return LocoMotor

