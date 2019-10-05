-- TODO
--  Attack idle state needs to check to see if it attack
--      move newcombat event handling to stategraph
--
require("stategraphs/commonstates")

local EMERGE_MIN = 10
local EMERGE_MIN2 = EMERGE_MIN*EMERGE_MIN 
local EMERGE_MAX = 15
local EMERGE_MAX2 = EMERGE_MAX*EMERGE_MAX

local events=
{
   EventHandler("pillardead",
                    function(inst)
                        inst.remove = true
                    end),
    EventHandler("attacked",
                 function(inst) 
                        if inst.components.health:GetPercent() > 0 
                           and not inst.sg:HasStateTag("hit")
                           and not inst.sg:HasStateTag("attack") then 
                            inst.sg:GoToState("hit")
                        end
                 end),
    EventHandler("death",
                 function(inst)
                     inst.sg:GoToState("death")
                 end),
    CommonHandlers.OnFreeze(),
}

local function EmergeCheck(inst)
    if inst.remove then
        inst.sg:GoToState("pillardead")
    elseif inst:IsNear(GetPlayer(),TUNING.TENTACLE_PILLAR_ARM_STOPATTACK_DIST) then
        inst.sg:GoToState("attack")
    elseif inst.retract then
        inst.sg:GoToState("retract")
        inst.retract = nil
    else
        inst.sg:GoToState("attack_idle")
    end

end

function NewTarget(inst, data)
    dprint("Newtarget:",data.target)
    if data.target and not inst.sg:HasStateTag("attack") and not inst.sg:HasStateTag("hit") and not inst.components.health:IsDead() then
        inst.sg:GoToState("attack")
    else
        inst.sg:GoToState("attack_idle")
    end
end

local states=
{
    State{
        name = "idle",
        tags = {"idle"},
        onenter = function(inst)
            inst.AnimState:PushAnimation("breach_loop", true)
            inst.sg:SetTimeout(GetRandomWithVariance(7, 2) )
            inst.SoundEmitter:KillAllSounds()
        end,
                
        ontimeout = function(inst)
            local player = GetPlayer()
            if inst:IsNear(player,EMERGE_MIN) or (inst:IsNear(player,EMERGE_MAX) and math.random()>0.2) then
                inst.sg:GoToState("emerge")
            end
        end,

        events=
        {
            EventHandler("animqueueover",
                            function(inst)
                                inst.sg:GoToState("idle")
                            end),
            EventHandler("emerge",
                            function(inst)
                                inst.sg:GoToState("emerge")
                            end),
            EventHandler("attack",
                            function(inst)
                                inst.sg:GoToState("emerge")
                            end),
            EventHandler("pillardead",
                            function(inst)
                                inst.remove = true
                                inst:Remove()
                            end),
            EventHandler("newcombattarget",
                            function(inst)
                                inst.sg:GoToState("emerge")
                            end),
        },
    },
    
    State{
        name = "attack_idle",
        tags = {"attack_idle"},
        onenter = function(inst)
            local speed = GetRandomWithVariance(0.9, 0.1)
            inst.AnimState:PushAnimation("atk_idle", true)
            inst.AnimState:SetDeltaTimeMultiplier(speed)
            inst.sg:SetTimeout(GetRandomWithVariance(15, 10) )
            inst.SoundEmitter:KillAllSounds()
        end,
                
        ontimeout = function(inst)
            local dist2 = inst:GetDistanceSqToInst(GetPlayer())
            if dist2 > EMERGE_MAX2 or (dist2 > EMERGE_MIN2 and math.random()<0.1) then
                -- Dbg(inst,true,"attack_idle - gone far, retract")
                inst.sg:GoToState("retract")
            end
        end,

        events=
        {
            EventHandler("retract",
                            function(inst) 
                                inst.retract = true
                                inst.sg:GoToState("retract")
                            end),
            EventHandler("attacked",
                            function(inst) 
                                inst.sg:GoToState("hit")
                            end),
            EventHandler("pillardead",
                            function(inst)
                                inst.remove = true
                                inst.sg:GoToState("pillardead")
                            end),
            EventHandler("newcombattarget", NewTarget ),
            EventHandler("animqueueover",
                            function(inst)
                                local dist2 = inst:GetDistanceSqToInst(GetPlayer())
                                
                                if inst.remove then
                                    inst.sg:GoToState("pillardead")
                                elseif inst.retract or dist2 > EMERGE_MAX2 then
                                    inst.sg:GoToState("retract")
                                elseif dist2 <= (EMERGE_MIN2 and math.random()<0.1) then
                                    inst.sg:GoToState("attack")
                                else
                                    inst.sg:GoToState("attack_idle")
                                end
                            end),
        },
    },
    
    State{
        name ="emerge",
        tags = {"emerge"},
        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/tentacle/smalltentacle_emerge")
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("atk_pre")
            inst.AnimState:SetDeltaTimeMultiplier(GetRandomWithVariance(0.9, 0.1))
			inst.SoundEmitter:SetParameter( "tentacle", "state", 1)      
        end,
        events=
        {
            EventHandler("pillardead",
                            function(inst)
                                inst.remove = true
                            end),
            EventHandler("retract",
                            function(inst) 
                                inst.retract = true
                            end),
            EventHandler("animover", EmergeCheck)
        },
        timeline=
        {
            -- TimeEvent(20*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentacle_emerge_VO") end),
        }
        
    },
    
    State{ 
        name = "attack",
        tags = {"attack"},
        onenter = function(inst)
            inst.AnimState:PlayAnimation("atk_loop")
            inst.AnimState:PushAnimation("atk_idle", false)
            inst.AnimState:SetDeltaTimeMultiplier(GetRandomWithVariance(1.0, 0.05))
        end,
        
        timeline=
        {
            TimeEvent(2*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/tentacle/smalltentacle_attack") end),
			TimeEvent(7*FRAMES, function(inst) inst.components.combat:DoAttack() end),
            TimeEvent(15*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/tentacle/smalltentacle_attack") end),
            TimeEvent(17*FRAMES, function(inst) inst.components.combat:DoAttack() end),
            TimeEvent(18*FRAMES, function(inst) inst.sg:RemoveStateTag("attack") end),
        },
        
        events=
        {
            EventHandler("animqueueover",
                            function(inst)
                                Dbg(inst,true,"attack_idle: animover")
                                if inst.remove then
                                    inst.sg:GoToState("pillardead")
                                    inst.remove = nil
                                elseif inst.retract then
                                    inst.sg:GoToState("retract")
                                    inst.retract = nil
                                else
                                    inst.sg:GoToState("attack")
                                end
                            end),
            EventHandler("newcombattarget", NewTarget ),
            EventHandler("retract",
                            function(inst) 
                                inst.retract = true
                            end),
            EventHandler("pillardead",
                            function(inst)
                                Dbg(inst,true,"attack: GOT pillardead EVENT")
                                inst.remove = true
                                inst.sg:GoToState("pillardead")
                            end),
        },
    },
     
    State{
        name ="retract",
        tags = {"retract"},
        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/tentacle/smalltentacle_disappear")
            inst.AnimState:PlayAnimation("atk_pst")
            inst.AnimState:SetDeltaTimeMultiplier(GetRandomWithVariance(1.0, 0.05))
        end,
        events=
        {
            EventHandler("pillardead",
                            function(inst)
                                inst.remove = true
                            end),
            EventHandler("attacked",
                            function(inst) 
                                inst.sg:GoToState("hit")
                            end),
            EventHandler("animover", 
                            function(inst)
                                inst.SoundEmitter:KillAllSounds()
                                if inst.remove then
                                    inst:Remove()
                                else
                                    inst.sg:GoToState("idle")
                                end
                            end),
        },
    },
   
    State{  -- main pillar , so all the arms die as well
        name ="pillardead",
        tags = {"busy"},
        onenter = function(inst)
            inst.SoundEmitter:KillAllSounds() -- kill sound, may be a bunch of arms dying at the same time
            inst.AnimState:PlayAnimation("atk_pst")
            inst.AnimState:SetDeltaTimeMultiplier(GetRandomWithVariance(0.8, 0.2))
        end,
        events=
        {
            EventHandler("animover",
                            function(inst)
                                inst:Remove()
                            end),
        },
    },
    
    
	State{
        name = "death",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentapiller_hurt_VO")
            inst.AnimState:PlayAnimation("death")
            -- inst.AnimState:SetDeltaTimeMultiplier(.8)
            RemovePhysicsColliders(inst)            
            inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))            
        end,
        
        events =
        {
            EventHandler("animover",
                            function(inst) 
                                inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentacle_splat")
                                --inst:Remove()
                            end ),
        },        
    },
    
        
    State{
        name = "hit",
        tags = {"busy", "hit"},
        
        onenter = function(inst)
            inst.AnimState:PlayAnimation("hit")
            -- inst.AnimState:SetDeltaTimeMultiplier(GetRandomWithVariance(0.6, 0.15))
            inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentapiller_hurt_VO")
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("attack") end),
        },
        
    },    
    
}
CommonStates.AddFrozenStates(states)
    
return StateGraph("tentacle", states, events, "idle")

