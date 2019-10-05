StandAndAttack = Class(BehaviourNode, function(self, inst, findnewtargetfn)
    BehaviourNode._ctor(self, "StandAndAttack")
    self.inst = inst
    self.findnewtargetfn = findnewtargetfn
    self.numattacks = 0
    
    -- we need to store this function as a key to use to remove itself later
    self.onattackfn = function(inst, data)
        self:OnAttackOther(data.target) 
    end

    self.inst:ListenForEvent("onattackother", self.onattackfn)
    self.inst:ListenForEvent("onmissother", self.onattackfn)
end)

function StandAndAttack:__tostring()
    return string.format("target %s", tostring(self.inst.components.combat.target))
end

function StandAndAttack:OnStop()
    self.inst:RemoveEventCallback("onattackother", self.onattackfn)
    self.inst:RemoveEventCallback("onmissother", self.onattackfn)
end

function StandAndAttack:OnAttackOther(target)
    --print ("on attack other", target)
    self.numattacks = self.numattacks + 1
    self.startruntime = nil -- reset max chase time timer
end

function StandAndAttack:Visit()
    
    local combat = self.inst.components.combat
    if self.status == READY then
        
        combat:ValidateTarget()
        
        if not combat.target and self.findnewtargetfn then
            combat.target = self.findnewtargetfn(self.inst)
        end        
        
        if combat.target then
            self.inst.components.combat:BattleCry()
            self.status = RUNNING
        else
            self.status = FAILED
        end
        
    end

    if self.status == RUNNING then
        
       local is_attacking = self.inst.sg:HasStateTag("attack")
        
        if not combat.target or not combat.target:IsValid() then
            self.status = FAILED
            combat:SetTarget(nil)
        elseif combat.target.components.health and combat.target.components.health:IsDead() then
            self.status = SUCCESS
            combat:SetTarget(nil)
        else
                        
            local hp = Point(combat.target.Transform:GetWorldPosition())
            local pt = Point(self.inst.Transform:GetWorldPosition())
            local dsq = distsq(hp, pt)
            local angle = self.inst:GetAngleToPoint(hp)
            
            if self.inst.sg:HasStateTag("canrotate") then
                self.inst:FacePoint(hp)
            end   
                            
            combat:TryAttack()

            self:Sleep(.125)            
        end
        
    end
end
