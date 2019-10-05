local Projectile = Class(function(self, inst)
    self.inst = inst
    self.owner = nil
    self.target = nil
    self.start = nil
    self.dest = nil
    self.cancatch = false
    
    self.speed = nil
    self.hitdist = 1
    self.homing = true
    self.range = nil
    self.onthrown = nil
    self.onhit = nil
    self.onmiss = nil
    self.oncaught = nil
    self.vertical = false 
end)

function Projectile:GetDebugString()
    return string.format("target: %s, owner %s", tostring(self.target), tostring(self.owner) )
end

function Projectile:SetSpeed(speed)
    self.speed = speed
end

function Projectile:SetRange(range)
    self.range = range
end

function Projectile:SetHitDist(dist)
    self.hitdist = dist
end

function Projectile:SetOnThrownFn(fn)
    self.onthrown = fn
end

function Projectile:SetOnHitFn(fn)
    self.onhit = fn
end

function Projectile:SetOnCaughtFn(fn)
    self.oncaught = fn
end

function Projectile:SetOnMissFn(fn)
    self.onmiss = fn
end

function Projectile:SetCanCatch(cancatch)
    self.cancatch = cancatch
end

function Projectile:SetHoming(homing)
    self.homing = homing
end

function Projectile:SetVertical(vertical)
    self.vertical = vertical
end 

function Projectile:SetLaunchOffset(offset)
    self.launchoffset = offset -- x is radius, y is height, z is ignored
end

function Projectile:IsThrown()
    return self.target ~= nil
end

function Projectile:Throw(owner, target, attacker)
    self.owner = owner
    self.target = target
    self.start = Vector3(owner.Transform:GetWorldPosition() )
    self.dest = Vector3(target.Transform:GetWorldPosition() )

    local offset = self.launchoffset
    if attacker and offset then
        local pos = self.inst:GetPosition()
        local facing_angle = attacker.Transform:GetRotation()*DEGREES
        local offset_vec = Vector3(offset.x * math.cos( facing_angle ), offset.y, -offset.x * math.sin( facing_angle ))
        print("facing", facing_angle)
        print("offset", offset)
        print("vec", offset_vec)
        pos = pos + offset_vec
        self.inst.Transform:SetPosition( pos:Get() )
    end
    if self.vertical then 
         self.inst.Physics:SetVel(0, self.speed, 0)
    else 
        self:RotateToTarget(self.dest)
        self.inst.Physics:SetMotorVel(self.speed,0,0)
    end 
    self.inst:StartUpdatingComponent(self)
    self.inst:PushEvent("onthrown", {thrower = owner, target = target})
    target:PushEvent("hostileprojectile",{thrower = owner, attacker = attacker, target = target})
    if self.onthrown then
        self.onthrown(self.inst, owner, target)
    end
    if self.cancatch and target.components.catcher then
        target.components.catcher:StartWatching(self.inst)
    end
end

function Projectile:CollectSceneActions(doer, actions)
    local catcher = doer.components.catcher
    if self.cancatch and self:IsThrown() and catcher and catcher:CanCatch() then
        table.insert(actions, ACTIONS.CATCH)
    end
end

function Projectile:Catch(catcher)
    if self.cancatch then
        self:Stop()
        self.inst.Physics:Stop()
        if self.oncaught then
            self.oncaught(self.inst, catcher)
        end
    end
end

function Projectile:Miss(target)
    local owner = self.owner
    self:Stop()
    if self.onmiss then
        self.onmiss(self.inst, owner, target)
    end
end

function Projectile:Stop()
    self.inst:StopUpdatingComponent(self)
    self.target = nil
    self.owner = nil
end

function Projectile:Hit(target)
    local attacker = self.owner
    local weapon = self.inst
    self:Stop()
    self.inst.Physics:Stop()
    if not attacker.components.combat and attacker.components.weapon and attacker.components.inventoryitem then
        weapon = attacker
        attacker = weapon.components.inventoryitem.owner
    end
    if attacker and attacker.components.combat then
        attacker.components.combat:DoAttack(target, weapon, self.inst)
    end
    
    if self.onhit then
        self.onhit(self.inst, attacker, target)
    end
end

function Projectile:OnUpdate(dt)
    local target = self.target
    if self.homing and target and target:IsValid() and not target:IsInLimbo() then
        self.dest = Vector3(target.Transform:GetWorldPosition() )
    end
    local dest = self.dest
    local current = Vector3(self.inst.Transform:GetWorldPosition() )
    local direction = (dest - current):GetNormalized()
    local projectedSpeed = self.speed*TheSim:GetTickTime()*TheSim:GetTimeScale()
    local projected = current + direction*projectedSpeed
    local coveredDistSq = distsq(self.start, current)
    if self.range and coveredDistSq > self.range*self.range then
        self:Miss(target)
    elseif self.homing then
        if target and target:IsValid() and not target:IsInLimbo() and self.inst:IsNear(target, self.hitdist + (target.Physics and target.Physics:GetRadius() or 0)) then
            self:Hit(target)
        else
			if direction:Dot(dest - projected) < 0 then
				if target and target:IsValid() and not target:IsInLimbo() then
					self:Hit(target)
				else
					self:Miss(target)
				end
			else
				self:RotateToTarget(dest)
			end
		end  
    elseif self.vertical then 

        if target and target:IsValid() and not target:IsInLimbo() then 

            local myPos = Vector3(self.inst.Transform:GetWorldPosition())
            local targetPos = Vector3(target.Transform:GetWorldPosition())

            local vx, vy, vx = self.inst.Physics:GetVelocity()
            if vy < 0 then 
                myPos.x = targetPos.x
                myPos.z = targetPos.z 
                self.inst.Transform:SetPosition(myPos.x, myPos.y, myPos.z)
            end 

            if  myPos.y < 1 then 
                self:Hit(target)       
            end 
        else
            self.target = nil 
            if myPos.y < 1 then 
                self:Miss(target)       
            end 
        end 
     
    else
        -- WARNING: IsNear specifically excludes vertical distance
        local targ_rad = (target:IsValid() and target.Physics and target.Physics:GetRadius() or 0)
        if target and target:IsValid() and not target:IsInLimbo() and self.inst:IsNear(target, self.hitdist + targ_rad) then
            self:Hit(target)
        end
    end
        
end

function Projectile:OnSave()
    if self:IsThrown() then
        return {target = self.target.GUID, owner = self.owner.GUID}, {self.target.GUID, self.owner.GUID}
    end
end

function Projectile:RotateToTarget(dest)
    local current = Vector3(self.inst.Transform:GetWorldPosition() )
    local direction = (dest - current):GetNormalized()
    local angle = math.acos(direction:Dot(Vector3(1, 0, 0) ) ) / DEGREES
    self.inst.Transform:SetRotation(angle)
    self.inst:FacePoint(dest)
end

function Projectile:LoadPostPass(newents, savedata)
    if savedata.target and savedata.owner then
        local target = newents[savedata.target]
        local owner = newents[savedata.owner]
        if target and owner then
            self:Throw(owner.entity, target.entity)
        end
    end
end

return Projectile
