--[[
Functions to keep track of fight statistics
--]]

local Overseer = Class(function(self, inst)
	self.previous_pos = nil
	self.inst = inst
    self.engaged = false
    self.data = {}
end)

function FightStat_GaveUp(attacker)
    GetPlayer().components.overseer:GaveUp(attacker)
end
function FightStat_EndFight()
    GetPlayer().components.overseer:EndFight()
end
function FightStat_Targeted(attacker)
    GetPlayer().components.overseer:Targeted(attacker)
end
function FightStat_Attack(targ,weapon,projectile,damage)
    GetPlayer().components.overseer:Attack(targ,weapon,projectile,damage)
end
function FightStat_AttackByFollower(targ,weapon,projectile,damage)
    GetPlayer().components.overseer:AttackByFollower(targ,weapon,projectile,damage)
end
function FightStat_Equip(item,slot)
    GetPlayer().components.overseer:Equip(item,slot)
end
function FightStat_TrapSprung(trap,target,damage)
    GetPlayer().components.overseer:TrapSprung(trap,target,damage)
end
function FightStat_Heal(amount)
    GetPlayer().components.overseer:Heal(amount)
end
function FightStat_AttackedBy(attacker,damage,absorbed)
    GetPlayer().components.overseer:AttackedBy(attacker,damage,absorbed)
end
function FightStat_AddKill(targ,damage,weapon)
    GetPlayer().components.overseer:AddKill(targ,damage,weapon)
end
function FightStat_AddKillByFollower(targ,damage,weapon)
    GetPlayer().components.overseer:AddKillByFollower(targ,damage,weapon)
end
function FightStat_AddKillByMine(targ,damage)
    GetPlayer().components.overseer:AddKillByMine(targ,damage)
end
function FightStat_Caught(attacker)
    GetPlayer().components.overseer:Caught(attacker)
end
function FightStat_BrokenArmor(prefab)
    GetPlayer().components.overseer:BrokenArmor(prefab)
end
function FightStat_Absorb(amount)
    GetPlayer().components.overseer:Absorb(amount)
end

function Overseer:TimeStamp()
    return math.floor(GetTime()) - self.data.startTime 
end

function Overseer:StartTime()
    self.data.startTime = math.floor(GetTime()) - 1
end

function Overseer:Caught(attacker)

    if not self.engaged then
        return
    end

    local data   = self.data
    local prefab = attacker.prefab or attacker.inst.prefab


    data.caught                          = self.data.caught or {}
    data.caught[prefab]                  = (self.data.caught[prefab] or 0) + 1

    -- local ts     = self:TimeStamp()
    -- dprint(ts,"OS: Caught:",attacker,prefab)
    -- data.fight                           = data.fight or {}
    -- data.fight[ts]                       = data.fight[ts] or {}
    -- data.fight[ts]["caught" .. prefab] = true
    -- data.fight[ts].acts                  = data.fight[ts].acts  or {}
    -- table.insert(data.fight[ts].acts, "CAUGHT")
end

function Overseer:GaveUp(attacker)

    if not self.engaged then
        return
    end

    -- Deal with opponents in teams
    --[[
    if attacker.components.teamattacker.inteam then
        local targ = attacker.components.combat.target
        local threat = attacker.components.teamattacker.teamleader.threat
        local player = GetPlayer()
	    if threat == player or threat.components.follower.leader == player then
            return
        end
    end
    --]]

    local data   = self.data
    local prefab = attacker.prefab or attacker.inst.prefab
    local ts     = self:TimeStamp()

    if prefab == "penguin" then return end   -- fix until I figure out why pengulls repeatedly target and give up
    if prefab == "NIL" then
        if data.foeList then
            data.foeList[prefab] = nil
            return
        end
    end  

    dprint(ts,"OS: GaveUp:",attacker,prefab)

    data.eluded                          = self.data.eluded or {}
    data.eluded_total                    = (self.data.eluded_total or 0) + 1
    data.eluded[prefab]                  = (self.data.eluded[prefab] or 0) + 1

    -- data.fight                           = data.fight or {}
    -- data.fight[ts]                       = data.fight[ts] or {}
    -- data.fight[ts]["eluded_" .. prefab]  = true
    -- data.fight[ts].acts                  = data.fight[ts].acts  or {}
    -- table.insert(data.fight[ts].acts, "ELUDE")
end

function Overseer:EndFight()
    --dprint("OS: EndFight:")
    self.data.foeList = {}
    self.engaged = false
end

function Overseer:InitFight()
        --dprint("OS InitFight: ****************** Start updating overseer")
        local player = GetPlayer()
        local inv = player.components.inventory

        self.inst:StartUpdatingComponent(self)    
        self.engaged = true

        self.data               = {}

        self:StartTime()
        self.data.targeted_by          = {}
        self.data.foeList       = {}
        self.data.fight         = {}
        self.data.eluded        = {}
        self.data.kills         = {}
        self.data.caught        = {}
        self.data.sanity_start  = math.floor(GetPlayer().components.sanity:GetPercent()*100)
        self.data.hunger_start  = math.floor(GetPlayer().components.hunger:GetPercent()*100)
        self.data.health_start  = math.floor(GetPlayer().components.health:GetPercent()*100)
        self.data.health_abs    = math.floor(player.components.health.currenthealth)
        self.data.armor_absorbed = 0
        self.data.trod          = (GetMap() and GetMap():GetNumVisitedTiles()) or 0
        self.data.wield         = inv.equipslots.hands and inv.equipslots.hands.name or nil
        self.data.wear          = inv.equipslots.body and inv.equipslots.body.name or nil
        self.data.head          = inv.equipslots.head and inv.equipslots.head.name or nil
        self.data.startAFK      = IsAwayFromKeyBoard()
        self.data.heal          = 0
        self.data.damage_taken  = 0
        self.data.damage_given  = 0
        self.data.duration      = 0
        self.data.eluded_total  = 0
        self.data.caught_total  = 0
        self.data.kill_total    = 0
        self.data.minion_kills  = 0
        self.data.minions       = player.components.leader.numfollowers

        if player.components.health:IsDead() then  -- don't start another record if the player is dead
            self.engaged = false
            return
        end

end

function Overseer:Targeted(attacker)

    local player = GetPlayer() 
    
    if not attacker or attacker == player or not player or
		not attacker:IsValid() or not player:IsValid() or
       (attacker.IsInLimbo and attacker:IsInLimbo()) or  -- Deal with bees that can be in the inventory
       (attacker.sg and attacker.sg:HasStateTag("hiding")) or -- Deal with animals that hide 
       (attacker.Transform and player:GetDistanceSqToInst(attacker) >= (15*15)) then  -- some target from a long distance
        return
    end

    IOprint("\rOS: TargetedBy:",attacker)

    if not self.engaged then
        self:InitFight()
    end

    local data   = self.data
    local prefab = attacker.prefab or attacker.inst.prefab
    local ts     = self:TimeStamp()

    if attacker then   -- attacker is nil if it's charlie
        data.foeList[attacker] = true
    end

    if prefab ~= "penguin" then  -- fix until I figure out why penguins repeately target and giveup
        --dprint("\nOS Targeted:",prefab)
        data.targeted_by           = data.targeted_by or {}
        data.targeted_by[prefab]   = (data.targeted_by[prefab] or 0) + 1
    end

    -- data.fight[ts]                           = data.fight[ts] or {}
    -- data.fight[ts]["targeted_by_" .. prefab] = (data.fight[ts]["targeted_by_" .. prefab] or 0) + 1 
    -- data.fight[ts].acts                      = data.fight[ts].acts  or {}
    -- table.insert(data.fight[ts].acts, "TARGETED")
end

function Overseer:Attack(targ,weapon,projectile,damage)

    if not targ.components.combat or targ:HasTag("structure") then
        return
    end

    if not self.engaged then
        self:InitFight()
    end
    -- dprint("OS: Attack:",targ,damage,weapon,projectile)

    local data   = self.data
    local prefab = targ.prefab or targ.inst.prefab
    local ts     = self:TimeStamp()

    damage = math.floor(damage)
    data.damage_given = (data.damage_given or 0) + damage

    --data.fight                          = data.fight or {}
    --data.fight[ts]                      = data.fight[ts] or { }
    -- data.fight[ts].acts                 = data.fight[ts].acts  or {}
    -- table.insert(data.fight[ts].acts, "ATTACK")
    --data.fight[ts]["attack_" .. prefab] = damage
    --data.fight[ts].atk_with             = weapon.prefab or nil
    --data.fight[ts].atk_dmg              = damage
    --data.fight[ts].atk_proj             = projectile.prefab
end

function Overseer:AttackByFollower(targ,weapon,projectile,damage)

    if not targ.components.combat or targ:HasTag("structure") then
        return
    end

    if not self.engaged then
        self:InitFight()
    end
    dprint("OS: AttackByFollower:",targ,damage,weapon,projectile)

    local data   = self.data
    local prefab = targ.prefab or targ.inst.prefab
    local ts     = self:TimeStamp()

    damage = math.floor(damage)
    data.minion_hits = (data.minion_hits or 0) + damage
end

function Overseer:Equip(prefab,slot)
    local data = self.data

    if self.engaged then
        dprint("OS: Equip:",prefab,slot)
        local ts = self:TimeStamp()

        data.used                       = self.data.used or {}
        data.used[prefab]               = (self.data.used[prefab] or 0) + 1

        -- data.fight                      = data.fight or {}
        -- data.fight[ts]                  = data.fight[ts] or {}
        -- data.fight[ts]["equip_".. prefab] = slot
        -- data.fight[ts].acts             = data.fight[ts].acts  or {}
        -- table.insert(data.fight[ts].acts, "EQUIP")
    end
end

function Overseer:Heal(amount)
    local data = self.data

    if self.engaged then
        data.heal = (data.heal or 0) + amount
        dprint("OS: Heal:",amount)
        -- local ts = self:TimeStamp()
        -- data.fight[ts]      = data.fight[ts] or {}
        -- data.fight[ts].heal = math.floor(amount)
        -- data.fight[ts].acts = data.fight[ts].acts  or {}
        -- table.insert(data.fight[ts].acts, "HEAL")
    end
end

function Overseer:Absorb(amount)
    local data = self.data

    if self.engaged then
        dprint("OS: Absorb:",amount)
        data.armor_absorbed = (data.armor_absorbed or 0) + amount
        local ts = self:TimeStamp()
        -- data.fight[ts]        = data.fight[ts] or {}
        -- data.fight[ts].absorb = math.floor(amount)
        -- data.fight[ts].acts = data.fight[ts].acts  or {}
        -- table.insert(data.fight[ts].acts, "HEAL")
    end
end

function Overseer:BrokenArmor(prefab)
    local data = self.data

    if self.engaged then
        dprint("OS: BrokenArmor:",prefab)
        data.armor_broken = (data.armor_broken or 0) + 1
        -- local ts = self:TimeStamp()
        -- data.fight[ts]                      = data.fight[ts] or {}
        -- data.fight[ts]["broken_" .. prefab] = true
        -- data.fight[ts].acts = data.fight[ts].acts  or {}
        -- table.insert(data.fight[ts].acts, "BROKEN_ARMOR")
    end
end

function Overseer:AttackedBy(attacker,damage,absorbed)

    if not self.engaged then
        self:InitFight()
    end

    --dprint("OS:AttackedBy:",attacker,damage,absorbed)

    local player = GetPlayer()
    local data   = self.data
    local prefab = attacker and (attacker.prefab or attacker.inst.prefab) or "NIL"
    local newHp  = math.floor(player.components.health.currenthealth - damage)
    local ts     = self:TimeStamp()


    if attacker then   -- attacker is nil if it's charlie
        data.foeList[attacker] = true
    end

    damage = math.floor(damage)

    data.damage_taken                  = (data.damage_taken or 0) + damage
    data.attacked_by                   = data.attacked_by or {}
    data.attacked_by[prefab]           = (data.attacked_by[prefab] or 0) + damage

    -- data.fight                         = data.fight or {}
    -- data.fight[ts]                     = data.fight[ts] or {}
    -- data.fight[ts]["hitby_" .. prefab] = damage
    -- data.fight[ts].hit_by              = prefab
    -- data.fight[ts].hit_dmg             = damage
    -- data.fight[ts].hit_hp              = newHp
    -- data.fight[ts].acts                = data.fight[ts].acts  or {}
    -- table.insert(data.fight[ts].acts, "HIT")
end

function Overseer:TrapSprung(trap,target,damage)

    dprint("OS: TrapSprung:",trap,target,damage)
    if not self.engaged then
        return
    end

    local player = GetPlayer()


    local data   = self.data
    local targName = (target and (target.prefab or target.inst.prefab)) or "none"
    local prefab = (trap and trap.prefab or trap.inst.prefab)

    data.traps_sprung                        = (data.traps_sprung or 0) + 1

    if target == player or (target and target.components.follower ~= nil and target.components.follower.leader == player) then
        data.trap_hit_minion = (data.trap_hit_minion or 0) + damage
    else
        data.trap_damage     = (data.traps_damage or 0) + damage
    end


    -- local ts     = self:TimeStamp()
    -- data.fight[ts]                           = data.fight[ts] or {}
    -- data.fight[ts]["trap_sprung_" .. prefab] = damage
    -- data.fight[ts].acts                = data.fight[ts].acts  or {}
    -- table.insert(data.fight[ts].acts, "KILL")
end

function Overseer:AddKillByFollower(targ,damage,weapon)
    if not targ.components.combat or targ:HasTag("structure") then
        return
    end

    if not self.engaged then
        return
    end

    local data   = self.data
    local prefab = targ.prefab or targ.inst.prefab
    local ts     = self:TimeStamp()

    data.minion_kills = (data.minion_kills or 0) + 1
    dprint("OS: KILL By FOLLOWER:",targ,data.minion_kills)

    -- data.fight[ts]                               = data.fight[ts] or {}
    -- data.fight[ts]["kill_by_follower" .. prefab] = true
    -- data.fight[ts].acts                = data.fight[ts].acts  or {}
    -- table.insert(data.fight[ts].acts, "KILL")
end

function Overseer:AddKillByMine(targ,damage)
    if not targ.components.combat or targ:HasTag("structure") then
        return
    end

    if not self.engaged then
        return
    end

    local data   = self.data
    local prefab = targ.prefab or targ.inst.prefab
    local player = GetPlayer()

    if targ == player or (targ.components.follower and targ.components.follower.leader == player) then
    else
        data.trap_kills = (data.trap_kills or 0) + 1
        data.kill_total = (data.kill_total or 0) + 1
    end
    dprint("OS: KILL By MINE:",targ,data.trap_kills)
end

function Overseer:AddKill(targ,damage,weapon)

    if not targ.components.combat or targ:HasTag("structure") then
        return
    end

    if not self.engaged then
        return
    end

    local data   = self.data
    local prefab = targ.prefab or targ.inst.prefab
    local ts     = self:TimeStamp()

    --dprint("OS: KILL:",prefab)

    data.kills                         = data.kills or {}
    data.kills[prefab]                 = (data.kills[prefab] or 0) + 1
    data.kill_total                    = (data.kill_total or 0) + 1

    -- data.fight[ts]                     = data.fight[ts] or {}
    -- data.fight[ts]["kill_" .. prefab]  = true
    -- data.fight[ts].with                = weapon.prefab
    -- data.fight[ts].acts                = data.fight[ts].acts  or {}
    -- table.insert(data.fight[ts].acts, "KILL")
end

function Overseer:Process()
    local data = self.data
    local duration = GetTime() - data.startTime
    local player = GetPlayer()

    data.duration       = math.floor(GetTime() - data.startTime)
    data.health_end     = math.floor(GetPlayer().components.health:GetPercent()*100)
    data.health_end_abs = math.floor(player.components.health.currenthealth)
    data.died           = player.components.health.currenthealth <= 0
    data.trod           = GetMap():GetNumVisitedTiles() - data.trod
    data.targeted_by    = (GetTableSize(data.targeted_by) > 0 and data.targeted_by) or nil
    data.foes_total     = GetTableSize(data.foeList)
    data.eluded         = (GetTableSize(data.eluded) > 0 and data.eluded) or nil
    data.kills          = (GetTableSize(data.kills) > 0 and data.kills) or nil
    data.AFK            = IsAwayFromKeyBoard()
    data.minions_lost   = data.minions - player.components.leader.numfollowers
    data.caught_total   = 0
    data.caught = data.caught or {}
    for name,num in pairs(data.caught) do
        data.caught_total = data.caught_total + num
    end

    if ( data.trod == 0 and
         duration < 3 and
         data.damage_given == 0 and
         data.trap_kills == 0 and 
         data.minion_hits  == 0 and 
         data.minion_kills == 0 and
         data.damage_taken == 0 ) then
         --dprint ("|||||||||| VALIDTESTS:", data.trod == 0, duration < 3, data.damage_given == 0, data.minion_kills == 0, data.damage_taken == 0 ) 
        return false
    end


	if GetTableSize(data.foeList) == 0 then
        --dprint("||||||||||| #foeList=0")
        return false
    end

    -- Fix until I figure out why penguins continually target and retarget the player
    for ent,v in pairs(data.foeList) do
        if ent.prefab == "penguin" then
            if ent.components.health and
                ent.components.health.currenthealth > 0 then
                data.eluded         = data.eluded or {}
                data.eluded_total   = (data.eluded_total or 0) + 1
                data.eluded[ent.prefab] = (data.eluded[ent.prefab] or 0) + 1
            end
        end
    end

    return true
end

--local charlie = {prefab="NIL"}

function Overseer:OnUpdate(dt)
	local player = GetPlayer()
    local data = self.data
    local targeted = false

    local function CheckAura(inst) -- is this thing (ghost) hurting the player with an aura? 
                if inst.components.aura then
                    if player:GetDistanceSqToInst(inst) <= (15*15) then
                        return true
                    end
                end
                return false
            end

    local function CheckTeam(inst)  -- is this thing in a team that is still targeting the player?
            if inst.components.teamattacker and inst.components.teamattacker.teamleader then
                local threat = inst.components.teamattacker.teamleader.threat
                -- See if the team (not just the particular enemy) is targeting the player or a follower
                if threat and (threat == player or (threat.components.follower and threat.components.follower.leader == player)) then
                    return true
                end
            end
            return false
        end

    for ent,v in pairs(data.foeList) do
        if type(ent) == "table" then
            local targ = ent.components and ent.components.combat and ent.components.combat.target
            --dprint("ent= ",ent,"::",targ)
            if targ and ent and (ent.IsValid and ent:IsValid()) and
              ( targ == player or (targ.components.follower and targ.components.follower.leader == player) or CheckAura(ent) or (ent.components.teamattacker and CheckTeam(ent)) )  and
              (ent.components.health and ent.components.health.currenthealth and ent.components.health.currenthealth > 0 ) and
              not ent:IsInLimbo() and
              not ent:HasTag("hidden") and
              not (ent.sg and ent.sg:HasStateTag("hiding") and player:GetDistanceSqToInst(ent) > (25*25)) then
                targeted = true
            end
        end
    end

--[[
    if not self.inst.LightWatcher:IsInLight() then
        targeted = true  -- Charlie will be coming
        self:Targeted(charlie)
        self.inDark = true
    elseif self.inDark then
        self:GaveUp(charlie)
        self.inDark = false
    end
--]]

    if not targeted and self.engaged then
        self.inst:StopUpdatingComponent(self)
        -- dprint("****************** Stop updating overseer")
        if self:Process() then
            RecordOverseerStats(data)
        end
        self:EndFight()
        self.engaged = false
    end

end

return Overseer

