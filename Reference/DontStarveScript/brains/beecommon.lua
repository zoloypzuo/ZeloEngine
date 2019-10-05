local RUN_AWAY_DIST = 10
local SEE_FLOWER_DIST = 10
local SEE_TARGET_DIST = 6

local MAX_CHASE_DIST = 7
local MAX_CHASE_TIME = 8
local MAX_WANDER_DIST = 32

local SHARE_TARGET_DIST = 30
local MAX_TARGET_SHARES = 10

local function OnAttacked(inst, data)
    local attacker = data and data.attacker
    inst.components.combat:SetTarget(attacker)
    local targetshares = MAX_TARGET_SHARES
    if inst.components.homeseeker and inst.components.homeseeker.home then
        local home = inst.components.homeseeker.home
        if home and home.components.childspawner then
            targetshares = targetshares - home.components.childspawner.childreninside
            home.components.childspawner:ReleaseAllChildren(attacker, "killerbee")
        end
    end
    inst.components.combat:ShareTarget(attacker, SHARE_TARGET_DIST, function(dude)
        if inst.components.homeseeker and dude.components.homeseeker then  --don't bring bees from other hives
            if dude.components.homeseeker.home and dude.components.homeseeker.home ~= inst.components.homeseeker.home then
                return false
            end
        end
        return dude:HasTag("bee") and not dude.components.health:IsDead()
    end, targetshares)
end

local function OnWorked(inst, data)
	--print("OnWorked")
	OnAttacked(inst, {attacker=data.worker})
end

local function GoHomeAction(inst)
    if inst.components.homeseeker and 
       inst.components.homeseeker.home and 
       inst.components.homeseeker.home:IsValid() and 
       inst.components.homeseeker.home.components.childspawner then 
        return BufferedAction(inst, inst.components.homeseeker.home, ACTIONS.GOHOME)
    end
end

return {
	GoHomeAction = GoHomeAction,
	OnAttacked = OnAttacked,
	OnWorked = OnWorked,
	RUN_AWAY_DIST = RUN_AWAY_DIST,
	SEE_FLOWER_DIST = SEE_FLOWER_DIST,
	SEE_TARGET_DIST = SEE_TARGET_DIST,
	MAX_CHASE_DIST = MAX_CHASE_DIST,
	MAX_CHASE_TIME = MAX_CHASE_TIME,
	MAX_WANDER_DIST = MAX_WANDER_DIST,
	SHARE_TARGET_DIST = SHARE_TARGET_DIST,
	MAX_TARGET_SHARES = MAX_TARGET_SHARES
}
