require "behaviours/wander"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/panic"
require "behaviours/standstill"
require "behaviours/attackwall"
require "behaviours/leash"

local SEE_DIST = 30
local MIN_FOLLOW_DIST = 1
local TARGET_FOLLOW_DIST = 1
local MAX_FOLLOW_DIST = 5

local MAX_EGGS = 2  -- max number of eggs this penguin can lay

local STOP_RUN_DIST = 4
local SEE_PLAYER_DIST = 2.5
local SEE_FOOD_DIST = 20
local MAX_WANDER_DIST = 5
local MAX_CHASE_TIME = 10

local WANDER_DIST_NIGHT = 3
local WANDER_DIST_DAY = 5

local TOOCLOSE = 9

local MIN_TIME_TILL_NEXT_DROP = 60

local LEASH_RETURN_DIST = 5
local LEASH_MAX_DIST = 10

local PenguinBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function AtRookery(inst)
    if not inst then 
        return false
    end
    
    local homePos = inst.components.knownlocations.GetLocation and inst.components.knownlocations:GetLocation("rookery")

    if homePos and inst:GetDistanceSqToPoint(homePos) > 100 then
        return false
    else
        return true
    end
end

local function HasEgg(inst)
    return inst.components.inventory and inst.components.inventory:GetItemInSlot(1)
end

-- How's my egg doing? If the player has it or it is spoiled then forget about it
local function CheckMyEgg(inst)
    local egg = inst.myEgg

    if not egg then return nil end

    if egg:IsValid() and egg.components.inventoryitem:IsHeldBy(inst) then
        return egg
    end

    if not egg:IsValid() or egg.components.inventoryitem:IsHeld() then
        inst.myEgg = nil
        inst.laidEgg = false
        return nil
    end

    if egg.components.perishable and egg.components.perishable:IsSpoiled() then
        if HasEgg(inst) then
            egg.components.inventoryitem.nobounce = true
            inst.components.inventory:DropEverything()
        end
        inst.myEgg = nil
        inst.laidEgg = false
        return nil
    end
    inst.components.knownlocations:RememberLocation("myegg", Vector3(egg.Transform:GetWorldPosition()) )

    return egg
end

local function PrepareForNight(inst)
    return GetClock():IsNight() or (GetClock():IsDusk() and GetClock():GetNormEraTime() > .8) or inst.components.sleeper:IsAsleep() 
end

-- Return array of items within the given radius that satisfies the check function
local function FindItems(inst, radius, fn, tags)
    if inst and inst:IsValid() then
		local x,y,z = inst.Transform:GetWorldPosition()
		local ents = TheSim:FindEntities(x,y,z, radius, tags) 
        local lst = {}
		for k, v in ipairs(ents) do
			if v ~= inst and v:IsValid() and v.entity:IsVisible() and (not fn or fn(v)) then
                lst[#lst+1]=v
			end
		end
        return lst
	end
end

-- Go grab an egg if player gets too close to it
local function StealAction(inst)
    if not inst.components.inventory:IsFull() then
		local player = GetPlayer()
        -- Check that my egg exists and is not being held by someone else
        local target = CheckMyEgg(inst)
        local lst
        local char = GetClosestInstWithTag("scarytoprey", inst, TOOCLOSE) or player
        if not target then
		    lst = FindItems(inst, SEE_DIST/2, function(item) 
                                                    if  item.components.inventoryitem and 
                                                        item.components.inventoryitem.canbepickedup and 
                                                        not item.components.inventoryitem:IsHeld() and
                                                        item:IsOnValidGround() and 
                                                        (item.HasTag == "penguin_egg" or item.prefab == "bird_egg") then
                                                            return char:IsNear(item, TOOCLOSE)
                                                        end
                                                    end)
	    
            if #lst >= 1 then
                target = lst[math.random(1,#lst)]
            end
        end
		if target and not target:IsInLimbo() and char:IsNear(target, TOOCLOSE) then
            dprint("===== Steal:",target)
            if inst.components.knownlocations.ForgetLocation then
                inst.components.knownlocations:ForgetLocation("myegg")
            end
            inst.nextDropTime = GetTime() + GetRandomWithVariance(MIN_TIME_TILL_NEXT_DROP,5)
			return BufferedAction(inst, target, ACTIONS.PICKUP)
		end
	end
end


local function GetMigrateLeashPos(inst)
    if inst.components.teamattacker.teamleader or inst.components.combat.target then
        return nil
    end
    local homePos = inst.components.knownlocations and
        (inst.components.knownlocations:GetLocation("rookery") or 
        inst.components.knownlocations:GetLocation("home"))
    return homePos
end

local function EatFoodAction(inst)

    local target = nil

    if inst.sg:HasStateTag("busy") or inst.components.teamattacker.teamleader ~= nil then
        return
    end

    if not target then
        local lst = FindItems(inst, SEE_DIST/2, function(item)
                                            if item:GetTimeAlive() < 8 or item:HasTag("penguin_egg") or item.prefab == "rottenegg" then
                                                return false
                                            end
                                            if not item:IsOnValidGround() then
                                                return false
                                            end
                                            return inst.components.eater:CanEat(item)
                                       end)
        if #lst > 1 then
            target = lst[math.random(1,#lst)]
        end

        if target then
            -- dprint("========================================== FoodTarget:",target)
            local ba = BufferedAction(inst,target,ACTIONS.EAT)
            ba.distance = 1.5
            return ba
        end
    end
end

local function LayEggAction(inst)

    if inst.layingEgg then return end  -- not egg-laying season

    if (inst.nextDropTime or 0) - GetTime() > 0 then
        --IOprint("\rnextdrop:", (inst.nextDropTime or 0) - GetTime())
        return
    end

    local delay
    local egg = CheckMyEgg(inst)
    local nearest = GetClosestInstWithTag("scarytoprey", inst, TOOCLOSE) or GetPlayer()
    if nearest:IsNear(inst, TOOCLOSE) then
        -- IOprint("\rTOO CLOSE")
        return
    end
    -- IOprint("\r",inst," eggcheck:",egg)

    if (inst.components.inventory and inst.components.inventory:IsFull()) then
        local egg = inst.components.inventory:GetItemInSlot(1)
        if egg and egg.prefab ~= "rottenegg" then  -- may have egg from previous session, tags not saved with simple objects
            egg:AddTag("penguin_egg")
            egg.components.inventoryitem.nobounce = true
            inst.myEgg = egg
        end
        delay = GetRandomWithVariance(10,4)
        dprint(inst," drops egg in:",delay)
        inst.layingEgg = true
        inst:DoTaskInTime( delay,
                            function()
                                if not inst:IsValid() then return end
                                inst.layingEgg = false
                                nearest = GetClosestInstWithTag("scarytoprey", inst, TOOCLOSE) or GetPlayer()

                                if PrepareForNight(inst) or not AtRookery(inst) or                                   
                                nearest:IsNear(inst, TOOCLOSE) then
                                   return
                                end

                                dprint("drop egg")
                                inst.components.inventory:DropEverything()
                                inst.components.knownlocations:RememberLocation("myegg", Vector3(inst.Transform:GetWorldPosition()) )
                                inst.nextPickupTime = GetTime() + GetRandomWithVariance(MIN_TIME_TILL_NEXT_DROP,10)
                            end)
    elseif not egg then
        if not inst.nesting or (inst.eggsLayed and inst.eggsLayed > MAX_EGGS) then  -- egg laying season over
            return
        end
        delay = GetRandomWithVariance(TUNING.TOTAL_DAY_TIME/5,TUNING.TOTAL_DAY_TIME/6)
        dprint(inst," lays egg in:",delay)
        inst.layingEgg = true
        inst:DoTaskInTime( delay,
                            function()
                                if not inst:IsValid() then return end
                                inst.layingEgg = false
                                nearest = GetClosestInstWithTag("scarytoprey", inst, TOOCLOSE) or GetPlayer()

                                if PrepareForNight(inst) or not AtRookery(inst) or
                                   (GetSeasonManager():IsWinter() and GetSeasonManager():GetCurrentTemperature() <= -15) and
                                   nearest:IsNear(inst, TOOCLOSE) then
                                   return
                                end

                                local egg = SpawnPrefab("bird_egg")

                                if egg then
                                    dprint("lay egg")
                                    inst.myEgg = egg
                                    inst.eggsLayed = (inst.eggsLayed and inst.eggsLayed + 1) or 1
                                    egg:AddTag("penguin_egg")
                                    egg.components.inventoryitem.nobounce = true
		                            egg.Transform:SetPosition(inst.Transform:GetWorldPosition())		
                                    inst.components.knownlocations:RememberLocation("myegg", Vector3(inst.Transform:GetWorldPosition()) )

                                    inst.nextPickupTime = GetTime() + GetRandomWithVariance(MIN_TIME_TILL_NEXT_DROP,10)
                                end
                            end)
    end
end

local function PickUpEggAction(inst)
    if not inst.components.inventory:IsFull() then
        if not PrepareForNight(inst) and (inst.nextPickupTime or 0) - GetTime() > 0 then
            --dprint("nextdrop:", (inst.nextDropTime or 0) - GetTime())
            return
        end
        local lst
        local target = CheckMyEgg(inst)
        if not target then
            lst = FindItems(inst, SEE_DIST, function(item) 
                                                    if  item.components.inventoryitem and 
                                                        item.components.inventoryitem.canbepickedup and 
                                                        not item.components.inventoryitem:IsHeld() and
                                                        item:IsOnValidGround() and 
                                                        (item.HasTag == "penguin_egg" or item.prefab == "bird_egg") then
                                                            return inst:IsNear(item, 2)
                                                        end
                                                    end)
	    
            if #lst > 1 then
                target = lst[math.random(1,#lst)]
            end
        end
		if target and not target:IsInLimbo() then
            dprint("________________________________________ Pickup Egg:",target)
            if inst.components.knownlocations.GetLocation then
                inst.components.knownlocations:ForgetLocation("myegg")
            end
            inst.nextDropTime = GetTime() + GetRandomWithVariance(MIN_TIME_TILL_NEXT_DROP,5)
			return BufferedAction(inst, target, ACTIONS.PICKUP)
		end
	end
end

local function GetWanderDistFn(inst)
    local isWinter = (GetSeasonManager():IsWinter() and GetSeasonManager():GetCurrentTemperature() <= -10)

    -- keep close to your egg
    if inst.components.knownlocations.GetLocation and inst.components.knownlocations:GetLocation("myegg") then
        return 2
    end

    if isWinter or not GetClock():IsDay() then
        return WANDER_DIST_NIGHT
    else
        return WANDER_DIST_DAY
    end
end

local function ShouldRunAway(inst,hunter)
    local teamattacker = inst.components.teamattacker
    local hasLeader = inst.components.teamattacker.teamleader
    if hasLeader and (teamattacker.orders == "ATTACK" or teamattacker.orders == "HOLD")  then
        return false
    elseif hunter.sg and hunter.sg:HasStateTag("moving")
           -- or hunter.sg:HasStateTag("attack")
           then
        return true
    else
        return false
    end
end

local function HerdAtRookery(inst)
    local homePos = inst.components.knownlocations.GetLocation and inst.components.knownlocations:GetLocation("rookery")
    local herdPos = inst.components.knownlocations.GetLocation and inst.components.knownlocations:GetLocation("herd")

    if homePos and herdPos and distsq(homePos,herdPos) < 102 then
        return true
    else
        return false
    end
end

local function FlyAway(inst)
    --dprint("FLYAWAY EVENT")
    inst:PushEvent("flyaway")
end

function PenguinBrain:OnStart()
    local clock = GetClock()
    
    --[[
    local stealnode = PriorityNode(
	{
		DoAction(self.inst, function() return StealAction(self.inst) end, "steal", true ),        
	}, 2)
    --]] 
    local root = PriorityNode(
    {
        IfNode(function() return  self.inst.sg:HasStateTag("flying") end, "Flying",
            ActionNode(function() return FlyAway(self.inst) end)),

        WhileNode( function() return self.inst.components.health.takingfiredamage end, "OnFire", Panic(self.inst)),

        -- Penguins will panic and pick up eggs if player comes too close
		DoAction(self.inst, function() return StealAction(self.inst) end, "PickUp Egg Action", true ),        

        -- Scatter for a short distance if player gets too close
     -- RunAway(hunterparams, see_dist, safe_dist, shouldRunFn, runhome)
        RunAway(self.inst, "scarytoprey", SEE_PLAYER_DIST, STOP_RUN_DIST,
                    function(target) return ShouldRunAway(self.inst, target) end,
                    false),

     -- ChaseAndAttack( inst, max_chase_time, give_up_dist, max_attacks, findnewtargetfn)
        ChaseAndAttack(self.inst, MAX_CHASE_TIME, 15, 15),

        EventNode(self.inst, "gohome", 
            ActionNode(function() return FlyAway(self.inst) end)),

        -- Hungry, hungry penguins
     -- DoAction(inst, getactionfn, name, run)
        DoAction(self.inst, EatFoodAction,"Eating Food Action",false),

        AttackWall(self.inst),

        -- If not fighting or eating or protecting eggs, migrate to the rookery
        Leash(self.inst, GetMigrateLeashPos, LEASH_MAX_DIST, LEASH_RETURN_DIST),
        
        -- When at the rookery, lay egg - but not if it's too cold!
        WhileNode(function()
                        return  AtRookery(self.inst) and
                                not self.inst.layingEgg and
                                not GetClock():IsNight() and
                                self.inst.components.teamattacker.teamleader == nil
                        end,
                    "Laying Egg ", 
                    DoAction(self.inst, LayEggAction, "Laying Egg Action", false )),


        -- Don't leave the egg lying around to freeze
        WhileNode(function()
                        return AtRookery(self.inst) and
                               self.inst.components.teamattacker.teamleader == nil and
                               not HasEgg(self.inst) and
                               (((GetSeasonManager():IsWinter() and GetSeasonManager():GetCurrentTemperature() <= -10))  or
                                PrepareForNight(self.inst))
                        end,
                    "PickUp Egg", 
                    DoAction(self.inst, PickUpEggAction, "Pickup Egg", false )),

        -- When at the rookery with nothing else to do, wander around - but don't wander too far from your egg!
        WhileNode(  function()
                            return HerdAtRookery(self.inst) and self.inst.components.teamattacker.teamleader == nil
                        end,
                    "No Leader Wander Action", 
                    Wander(self.inst,
                            function()
                                return  self.inst.components.knownlocations:GetLocation("myegg") or
                                        self.inst.components.knownlocations:GetLocation("rookery") or
                                        self.inst.components.knownlocations:GetLocation("herd")
                            end,
                            GetWanderDistFn)),

        -- Penguins have leaders?
        Follow(self.inst, function(inst) return inst.components.follower and inst.components.follower.leader end ,
                    MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),

        Wander( self.inst,
                self.inst.components.knownlocations:GetLocation("myegg") or
                self.inst.components.knownlocations:GetLocation("rookery") or
                self.inst.components.knownlocations:GetLocation("herd") or
		        self.inst.Transform:GetWorldPosition(),		
                MAX_WANDER_DIST),

        StandStill(self.inst),
    }, .25)
    
    self.bt = BT(self.inst, root)
end

return PenguinBrain

