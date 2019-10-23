require("stategraphs/commonstates")

local actionhandlers = {
    ActionHandler(ACTIONS.GOHOME, "action"),
}

local events = {
    EventHandler("attacked", function(inst)
        if not inst.components.health:IsDead() and not inst.sg:HasStateTag("attack") then
            inst.sg:GoToState("hit")
        end
    end),
    EventHandler("death", function(inst)
        inst.sg:GoToState("death")
    end),
    EventHandler("doattack", function(inst, data)
        if not inst.components.health:IsDead() and (inst.sg:HasStateTag("hit") or not inst.sg:HasStateTag("busy")) then
            inst.sg:GoToState("attack", data.target)
        end
    end),
    CommonHandlers.OnLocomote(false, true),
}

local function GetVolume(inst)
    if inst.components.transparentonsanity then
        return inst.components.transparentonsanity:GetPercent()
    end
    return 1
end

local function GetSanity(inst)
    local player = GetPlayer()
    local sanity_level = 1
    if player.components.sanity ~= nil then
        sanity_level = player.components.sanity:GetPercent()
    end
    return sanity_level
end

local states = {
    State {
        name = "attack",
        tags = { "attack", "busy" },

        onenter = function(inst, target)
            inst.sg.statemem.target = target
            inst.Physics:Stop()
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("atk_pre")
            inst.AnimState:PushAnimation("atk", false)
            inst.SoundEmitter:PlaySound(inst.sounds.attack_grunt, nil, GetVolume(inst))
        end,

        timeline = {
            TimeEvent(14 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst.sounds.attack, nil, GetVolume(inst))
            end),
            TimeEvent(16 * FRAMES, function(inst)
                inst.components.combat:DoAttack(inst.sg.statemem.target)
            end),
        },

        events = {
            EventHandler("animqueueover", function(inst)
                if math.random() < .333 then
                    inst.components.combat:SetTarget(nil)
                    inst.sg:GoToState("taunt")
                else
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State {
        name = "hit",
        tags = { "busy", "hit" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("disappear")
        end,

        events = {
            EventHandler("animover", function(inst)
                if GetWorld().Map then

                    local max_tries = 4
                    for k = 1, max_tries do
                        local pos = Vector3(inst.Transform:GetWorldPosition())
                        local offset = 10
                        pos.x = pos.x + (math.random(2 * offset) - offset)
                        pos.z = pos.z + (math.random(2 * offset) - offset)
                        if GetWorld().Map:GetTileAtPoint(pos:Get()) ~= GROUND.IMPASSABLE then
                            inst.Transform:SetPosition(pos:Get())
                            break
                        end
                    end
                end

                inst.sg:GoToState("appear")

            end),

        },
    },

    State {
        name = "taunt",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
            inst.SoundEmitter:PlaySound(inst.sounds.taunt, nil, GetVolume(inst))
        end,

        --timeline=
        --{
        --TimeEvent(13*FRAMES, function(inst)  end),
        --},

        events = {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State {
        name = "appear",
        tags = { "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("appear")
            inst.Physics:Stop()
            inst.SoundEmitter:PlaySoundWithParams(inst.sounds.appear, { sanity = GetSanity(inst) - 1 })
        end,

        events = {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end)
        },
    },

    State {
        name = "death",
        tags = { "busy" },

        onenter = function(inst)
            inst.SoundEmitter:PlaySound(inst.sounds.death, nil, GetVolume(inst))
            inst.AnimState:PlayAnimation("disappear")
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)
            inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))
        end,


    },

    State {
        name = "disappear",
        tags = { "busy" },

        onenter = function(inst)
            inst.persists = false
            inst.SoundEmitter:PlaySound(inst.sounds.death, nil, GetVolume(inst))
            inst.AnimState:PlayAnimation("disappear")
            inst.Physics:Stop()
        end,

        events = {
            EventHandler("animover", function(inst)
                inst:Remove()
            end),
        },
    },

    State {

        name = "action",
        onenter = function(inst, playanim)
            inst.Physics:Stop()
            inst:PerformBufferedAction()
        end,

        events = {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end)
        },
    },
}
CommonStates.AddWalkStates(states)
CommonStates.AddIdle(states)

return StateGraph("shadowcreature", states, events, "appear", actionhandlers)

