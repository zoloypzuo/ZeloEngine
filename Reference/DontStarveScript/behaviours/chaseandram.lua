


ChaseAndRam = Class(BehaviourNode, function(self, inst, max_chase_time, give_up_dist, max_charge_dist, max_attacks)
    BehaviourNode._ctor(self, "ChaseAndRam")
    self.inst = inst
    self.max_chase_time = max_chase_time
    self.give_up_dist = give_up_dist
    self.max_charge_dist = max_charge_dist
    self.max_attacks = max_attacks
    self.numattacks = 0
        
    -- we need to store this function as a key to use to remove itself later
    self.onattackfn = function(inst, data)
        self:OnAttackOther(data.target) 
    end

    self.inst:ListenForEvent("onattackother", self.onattackfn)
    self.inst:ListenForEvent("onmissother", self.onattackfn)
end)


function ChaseAndRam:Reset()
    self._base.Reset(self)
    self.inst:RemoveTag("ChaseAndRam")
end


function ChaseAndRam:__tostring()
    return string.format("target %s", tostring(self.inst.components.combat.target))
end

function ChaseAndRam:OnStop()
    self.inst:RemoveEventCallback("onattackother", self.onattackfn)
    self.inst:RemoveEventCallback("onmissother", self.onattackfn)
end

function ChaseAndRam:OnAttackOther(target)
    self.numattacks = self.numattacks + 1
    self.startruntime = nil -- reset max chase time timer
end

function ChaseAndRam:Visit()
    
    local combat = self.inst.components.combat
    if self.status == READY then
                
        if combat.target and combat.target:IsValid() then
            self.inst.components.locomotor:Stop()
            self.inst.components.combat:BattleCry()
            self.startruntime = GetTime()
            self.numattacks = 0
            self.status = RUNNING
            self.startloc = self.inst:GetPosition()

            local hp = Point(combat.target.Transform:GetWorldPosition())
            local pt = Point(self.inst.Transform:GetWorldPosition())
            self.ram_angle = self.inst:GetAngleToPoint(hp)
            self.ram_vector = (hp-pt):GetNormalized()
            self.inst:AddTag("ChaseAndRam")
        else
            self.inst:RemoveTag("ChaseAndRam")
            self.status = FAILED
            self.ram_vector = nil
        end
        
    end

    if self.status == RUNNING then
        
        local is_attacking = self.inst.sg:HasStateTag("attack")
        
        if not combat.target or not combat.target:IsValid() then
            self.status = FAILED
            self.ram_vector = nil
            combat:SetTarget(nil)
            self.inst.components.locomotor:Stop()
            self.inst:RemoveTag("ChaseAndRam")

            return

        elseif combat.target.components.health and combat.target.components.health:IsDead() then
            self.status = SUCCESS
            combat:SetTarget(nil)
            self.inst.components.locomotor:Stop()
            self.inst:RemoveTag("ChaseAndRam")
            
            return
        else

            local hp = combat.target:GetPosition()
            local pt = self.inst:GetPosition()
            local dsq = distsq(hp, pt) --Distance to target.
            local angle = math.abs(self.inst:GetAngleToPoint(hp)) --Angle to target.

            if self.inst.sg and self.inst.sg:HasStateTag("canrotate") then
                --Line up charge here.
                self.ram_angle = self.inst:GetAngleToPoint(hp)
                self.ram_vector = (hp-pt):GetNormalized()
            end



            local r = self.inst.Physics:GetRadius() + combat.target.Physics:GetRadius() + .1
                        
            if math.abs(angle - math.abs(self.ram_angle)) <= 60 then                
                --Running action. This is the actual "Ram"
                self.inst.components.locomotor:RunInDirection(self.ram_angle)
            elseif math.abs(angle - math.abs(self.ram_angle)) > 60 and (dsq >= self.give_up_dist*self.give_up_dist) then
                --You have run past your target. Stop!
                self.inst.components.locomotor:Stop()
                self.status = FAILED
                self.ram_vector = nil
                if self.inst.sg:HasStateTag("canrotate") then
                    self.inst:FacePoint(hp)
                end
                self.inst.components.combat:ForceAttack()
                self.inst:RemoveTag("ChaseAndRam")

            end
                

            if (self.inst.sg and not self.inst.sg:HasStateTag("atk_pre")) and combat:TryAttack() then
                -- If you're not still in the telegraphing stage then try to attack. 
                self.inst:RemoveTag("ChaseAndRam")
            else
                if not self.startruntime then
                    self.startruntime = GetTime()
                    self.inst.components.combat:BattleCry()
                end
            end

            
            if self.max_attacks and self.numattacks >= self.max_attacks then
                self.status = SUCCESS
                self.inst.components.locomotor:Stop()
                self.inst:RemoveTag("ChaseAndRam")
                return
            end
            
            if self.max_charge_dist then
                if distsq(self.startloc, self.inst:GetPosition()) >= self.max_charge_dist*self.max_charge_dist then
                    self.status = FAILED
                    self.ram_vector = nil
                    self.inst.components.locomotor:Stop()
                    self.inst.components.combat:ForceAttack()
                    self.inst:RemoveTag("ChaseAndRam")
                    return
                end
            end
            
            if self.max_chase_time and self.startruntime then
                local time_running = GetTime() - self.startruntime
                if time_running > self.max_chase_time then
                    self.status = FAILED
                    self.ram_vector = nil
                    self.inst.components.locomotor:Stop()
                    self.inst.components.combat:ForceAttack()
                    self.inst:RemoveTag("ChaseAndRam")
                    return
                end
            end


            self:Sleep(.125)
            
        end
        
    end
end
