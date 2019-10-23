local assets = {
    Asset("ANIM", "anim/maxwell_endgame.zip"),
    Asset("SOUND", "sound/maxwell.fsb"),
}

local function createconversationline(line)
    return {
        voice = "dontstarve/maxwell/talk_LP_world6",
        idleanim = "idle_loop",
        dialogpreanim = "dialog_pre",
        dialoganim = "dialog_loop",
        dialogpostanim = "dialog_pst",
        disableplayer = false,
        skippable = false,
        {
            string = line,
            wait = 2, --The time this segment will last for
            waitbetweenlines = 0,
            anim = nil, --If there's a different animation, the animation maxwell will play
            sound = nil, --if there's an extra sound, the sound that will play
        }
    }
end

local SPEECH = {
    NULL_SPEECH = {
        voice = "dontstarve/maxwell/talk_LP_world6",
        appearanim = "appear",
        idleanim = "idle",
        dialogpreanim = "dialog_pre",
        dialoganim = "dial_loop",
        dialogpostanim = "dialog_pst",
        disappearanim = "disappear",
        disableplayer = true,
        skippable = true,
        {
            string = "There is no speech number.", --The string maxwell will say
            wait = 2, --The time this segment will last for
            anim = nil, --If there's a different animation, the animation maxwell will play
            sound = nil, --if there's an extra sound, the sound that will play
        },
        {
            string = nil,
            wait = 0.5,
            anim = "smoke",
            sound = "dontstarve/common/destroy_metal",
        },
        {
            string = "Go set one.",
            wait = 2,
            anim = nil,
            sound = nil,
        },
        {
            string = "Goodbye",
            wait = 1,
            anim = nil,
            sound = "dontstarve/common/destroy_metal",
        },
    },

    INTRO = {
        voice = "dontstarve/maxwell/talk_LP_world6",
        --appearanim = "appear",
        idleanim = "idle_loop",
        dialogpreanim = "dialog_pre",
        dialoganim = "dialog_loop",
        dialogpostanim = "dialog_pst",
        --disappearanim = "disappear",
        disableplayer = false,
        skippable = false,
        {
            string = STRINGS.MAXWELL_ADVENTURETHRONE.LEVEL_6.INTRO.ONE,
            wait = 3,
            waitbetweenlines = 0,
            anim = nil,
            sound = nil,
        },
    },

    HIT = {
        voice = "dontstarve/maxwell/talk_LP_world6",
        --appearanim = "appear",
        idleanim = "idle_loop",
        dialogpreanim = "dialog_pre",
        dialoganim = "dialog_loop",
        dialogpostanim = "dialog_pst",
        --disappearanim = "disappear",
        disableplayer = false,
        skippable = false,
        {
            string = STRINGS.MAXWELL_ADVENTURETHRONE.LEVEL_6.HIT.ONE,
            wait = 3,
            waitbetweenlines = 0,
            anim = nil,
            sound = nil,
        },
    },

    NOUNLOCK = {
        voice = "dontstarve/maxwell/talk_LP_world6",
        idleanim = "idle_loop",
        dialogpreanim = "dialog_pre",
        dialoganim = "dialog_loop",
        dialogpostanim = "dialog_pst",
        disableplayer = false,
        skippable = false,
        {
            string = STRINGS.MAXWELL_ADVENTURETHRONE.LEVEL_6.NOUNLOCK.ONE,
            wait = 3,
            waitbetweenlines = 0,
            anim = nil,
            sound = nil,
        },
    },

    PHONOGRAPHON = {
        voice = "dontstarve/maxwell/talk_LP_world6",
        idleanim = "idle_loop",
        dialogpreanim = "dialog_pre",
        dialoganim = "dialog_loop",
        dialogpostanim = "dialog_pst",
        disableplayer = false,
        skippable = false,
        {
            --string = STRINGS.MAXWELL_ADVENTURETHRONE.LEVEL_6.PHONOGRAPHON.ONE,
            wait = 1,
            anim = nil,
            sound = nil,
        },
        {
            string = STRINGS.MAXWELL_ADVENTURETHRONE.LEVEL_6.PHONOGRAPHON.ONE,
            wait = 3,
            anim = nil,
            sound = nil,
        },
    },

    PHONOGRAPHOFF = {
        voice = "dontstarve/maxwell/talk_LP_world6",
        idleanim = "idle_loop",
        dialogpreanim = "dialog_pre",
        dialoganim = "dialog_loop",
        dialogpostanim = "dialog_pst",
        disableplayer = false,
        skippable = false,
        {
            --string = STRINGS.MAXWELL_ADVENTURETHRONE.LEVEL_6.PHONOGRAPHON.ONE,
            wait = 0.33,
            anim = nil,
            sound = nil,
        },
        {
            string = STRINGS.MAXWELL_ADVENTURETHRONE.LEVEL_6.PHONOGRAPHOFF.ONE,
            wait = 4,
            anim = nil,
            sound = nil,
        },
    },

    TELEPORTFAIL = {
        delay = 4,
        voice = "dontstarve/maxwell/talk_LP_world6",
        idleanim = "idle_loop",
        dialogpreanim = "dialog_pre",
        dialoganim = "dialog_loop",
        dialogpostanim = "dialog_pst",
        disableplayer = false,
        skippable = false,
        {
            string = STRINGS.MAXWELL_ADVENTUREINTROS.LEVEL_6.TELEPORTFAIL,
            wait = 3,
            anim = nil,
            sound = nil,
        },
        {
            string = STRINGS.MAXWELL_ADVENTUREINTROS.LEVEL_6.TELEPORTFAIL2,
            wait = 3,
            anim = nil,
            sound = nil,
        },
    },

}
for k, v in ipairs(STRINGS.MAXWELL_ADVENTUREINTROS.LEVEL_6.CONVERSATION) do
    table.insert(SPEECH, createconversationline(v))
end

local function activateintrospeech(inst)
    local conv_index = 1

    inst:DoTaskInTime(1.5, function()
        if inst.components.maxwelltalker then
            if inst.components.maxwelltalker:IsTalking() then
                inst.components.maxwelltalker:StopTalking()
            end
            inst.components.maxwelltalker.speech = "INTRO"
            inst.task = inst:StartThread(function()
                inst.components.maxwelltalker:DoTalk(inst)
            end)
            inst:RemoveComponent("playerprox")
        end
    end)

    inst:DoTaskInTime(4, function()
        if inst.components.maxwelltalker then
            inst.components.maxwelltalker.speech = conv_index
            inst:AddComponent("talkable")
        end
    end)

    inst:ListenForEvent("talkedto", function()
        if inst.components.maxwelltalker then
            conv_index = math.min(table.getn(SPEECH), conv_index + 1)
            inst.components.maxwelltalker.speech = conv_index
        end
    end)
end

local function OnHit(inst, attacker)
    local doer = attacker
    if doer then
        local pos = Vector3(doer.Transform:GetWorldPosition())
        GetSeasonManager():DoLightningStrike(pos)

        if doer.components.combat then
            doer.components.combat:GetAttacked(nil, TUNING.UNARMED_DAMAGE)
        end

        if doer.components.inventory then
            local tool = doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            if tool then
                if tool.prefab == "diviningrod" then
                    doer.components.inventory:DropItem(tool, true, true)
                else
                    tool:Remove()
                end
            end
        end
    end

    inst.components.maxwelltalker.speech = "HIT"

    if inst.components.maxwelltalker:IsTalking() then
        inst.components.maxwelltalker:StopTalking()
    end

    inst.task = inst:StartThread(function()
        inst.components.maxwelltalker:DoTalk(inst)
    end)

end

local function phonographon(inst)
    if inst.components.maxwelltalker then
        if inst.components.maxwelltalker:IsTalking() then
            inst.components.maxwelltalker:StopTalking()
        end
        inst.components.maxwelltalker.speech = "PHONOGRAPHON"
        inst.task = inst:StartThread(function()
            inst.components.maxwelltalker:DoTalk(inst)
        end)
    end
end

local function phonographoff(inst)
    if inst.components.maxwelltalker then
        if inst.components.maxwelltalker:IsTalking() then
            inst.components.maxwelltalker:StopTalking()
        end
        inst.components.maxwelltalker.speech = "PHONOGRAPHOFF"
        inst.task = inst:StartThread(function()
            inst.components.maxwelltalker:DoTalk(inst)
        end)
    end
end

local function teleportfail(inst)
    if inst.components.playerprox then
        inst:RemoveComponent("playerprox")
    end

    if inst.components.maxwelltalker then
        if inst.components.maxwelltalker:IsTalking() then
            inst.components.maxwelltalker:StopTalking()
        end
        inst.components.maxwelltalker.speech = "TELEPORTFAIL"
        inst.task = inst:StartThread(function()
            inst.components.maxwelltalker:DoTalk(inst)
        end)
    end
    if not inst.components.talkable then
        local conv_index = 1
        inst:DoTaskInTime(4, function()
            if inst.components.maxwelltalker then
                inst.components.maxwelltalker.speech = conv_index
                inst:AddComponent("talkable")
            end
        end)

        inst:ListenForEvent("talkedto", function()
            if inst.components.maxwelltalker then
                conv_index = math.min(table.getn(SPEECH), conv_index + 1)
                inst.components.maxwelltalker.speech = conv_index
            end
        end)
    end
end

local function fn()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    local sound = inst.entity:AddSoundEmitter()

    MakeObstaclePhysics(inst, 2)

    anim:SetBank("maxwellthrone")
    anim:SetBuild("maxwell_endgame")
    anim:PlayAnimation("idle_loop", true)

    inst:AddComponent("talker")
    inst.components.talker.fontsize = 40
    inst.components.talker.font = TALKINGFONT
    --inst.components.talker.colour = Vector3(133/255, 140/255, 167/255)
    inst.components.talker.offset = Vector3(0, -700, 0)

    inst:AddComponent("named")
    inst.components.named:SetName("Maxwell")

    inst:AddComponent("maxwelltalker")
    inst.components.maxwelltalker.speeches = SPEECH

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(12, 15)
    inst.components.playerprox:SetOnPlayerNear(activateintrospeech)

    inst.phonograph = TheSim:FindFirstEntityWithTag("maxwellphonograph")
    if inst.phonograph then
        inst:ListenForEvent("turnedon", function()
            phonographon(inst)
        end, inst.phonograph)
        inst:ListenForEvent("turnedoff", function()
            phonographoff(inst)
        end, inst.phonograph)
    end

    inst.telefail = teleportfail

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(10000000)

    inst:AddComponent("combat")
    inst.components.combat.onhitfn = OnHit

    return inst
end

return Prefab("characters/maxwellendgame", fn, assets) 
