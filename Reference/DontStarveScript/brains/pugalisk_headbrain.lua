require "behaviours/chaseandattack"
require "behaviours/standstill"
local pu = require ("prefabs/pugalisk_util")

local Pugalisk_headBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function doGazeTest(inst)

    if inst.components.combat.target and not self.inst:HasTag("tail") and inst:GetDistanceSqToInst(inst.components.combat.target) > 15*15 and not inst.sg:HasStateTag("busy") then
        inst:PushEvent("dogaze")
    end
    return true
end

local function customLocomotionTest(inst)    
    if not inst.movecommited then
        pu.DetermineAction(inst)        
    end
    if inst.movecommited then
        return false
    end
    return true
end

function Pugalisk_headBrain:OnStart()
    local root =
        PriorityNode(
        {  
            WhileNode(function() return customLocomotionTest(self.inst) and not self.inst.sg:HasStateTag("underground") end, "Be a head", 
                PriorityNode{
                    ChaseAndAttack(self.inst),            
                    StandStill(self.inst)
                }),
        },1)
    
    self.bt = BT(self.inst, root)        
end

function Pugalisk_headBrain:OnInitializationComplete()
    --[[
    local home = SpawnPrefab("rocks")
    home.Transform:SetPosition(  self.inst.Transform:GetWorldPosition() )
    self.inst.home = home
    ]]
end

return Pugalisk_headBrain
