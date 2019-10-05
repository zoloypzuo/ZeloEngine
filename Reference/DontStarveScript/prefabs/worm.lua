--[[
    The worm should wander around looking for fights until it finds a "home".    
    A good home will look like a place with multiple other items that have the pickable
    component so the worm can set up a lure nearby.

    Once the worm has found a good home it will hang around that area and
    feed off of the plants and creatures that are nearby.

    If the player tries to interact with the worm's lure or
    approaches the worm while it isn't in a lure state it will strike.

    Spawn a dirt mound that must be dug up to get loot?
]]

require "brains/wormbrain"
require "stategraphs/SGworm"

local assets=
{
	Asset("ANIM", "anim/worm.zip"),
    Asset("SOUND", "sound/worm.fsb"),
}

local prefabs =
{
    "monstermeat",
    "wormlight",
}

local function retargetfn(inst)

    --Don't search for targets when you're luring. Targets will come to you.
    if inst.sg:HasStateTag("lure") then
        return
    end

    return FindEntity(inst, TUNING.WORM_TARGET_DIST, function(guy) 
        if guy.components.combat and guy.components.health and not guy.components.health:IsDead() then
            return ( guy:HasTag("character") or guy:HasTag("monster") or guy:HasTag("animal")) and not 
            guy:HasTag("prey") and not (guy.prefab == inst.prefab)
        end
    end)
end

local function shouldKeepTarget(inst, target)

    if inst.sg:HasStateTag("lure") then
        return false
    end

    local home = inst.components.knownlocations:GetLocation("home")
    
    if target and target:IsValid() and target.components.health and not target.components.health:IsDead() then
        if home then
            return distsq(home, target:GetPosition()) < TUNING.WORM_CHASE_DIST * TUNING.WORM_CHASE_DIST
        elseif not home then
            local distsq = target:GetDistanceSqToInst(inst)
            return distsq < TUNING.WORM_CHASE_DIST * TUNING.WORM_CHASE_DIST
        end
    else
        return false
    end
end

local function onpickedfn(inst, target)
    target = target or GetPlayer()
    if target then
        inst.components.combat:SetTarget(target)
        inst:FacePoint(target:GetPosition())
        inst.components.combat:TryAttack(target)
    end

    if inst.attacktask then
        inst.attacktask:Cancel()
        inst.attacktask = nil
    end
end

local function canbeattackedfn(inst, attacker)
    return not inst.sg:HasStateTag("invisible")
end

local function displaynamefn(inst)
    if inst.sg:HasStateTag("lure") then
        return STRINGS.NAMES.WORM_PLANT
    elseif inst.sg:HasStateTag("dirt") then
        return STRINGS.NAMES.WORM_DIRT
    end
    return STRINGS.NAMES.WORM 
end


local function getstatus(inst)
    if inst.sg:HasStateTag("lure") then
        return "PLANT"
    elseif inst.sg:HasStateTag("dirt") then
        return "DIRT"
    end
    return "WORM"
end


function LookForHome(inst)
    if inst.components.knownlocations:GetLocation("home") ~= nil then
        inst.HomeTask:Cancel()
        inst.HomeTask = nil
        return
    end

    local pt = inst:GetPosition()
    local ground = GetWorld()

    local validtile = function(pos)
        local tile_at_point = ground.Map and ground.Map:GetTileAtPoint(pos.x, pos.y, pos.z)
        return tile_at_point and 
        tile_at_point ~= GROUND.IMPASSABLE and
        tile_at_point < GROUND.UNDERGROUND
    end

    local areaislush = function(pos)
        local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, 7)
        local num_plants = 0
        for k,v in pairs(ents) do
            if v.components.pickable then
                num_plants = num_plants + 1
            end
        end
        return num_plants >= 3
    end

    local notclaimed = function(pos)
        local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, 30)
        for k,v in pairs(ents) do
            if v ~= inst and v.prefab == inst.prefab then
                return false
            end
        end
        return true
    end

    local positions = {}
    local distancemod = 30

    for i = 1, 30 do
        local s = i/32.0--(num/2) -- 32.0
        local a = math.sqrt(s*512.0)
        local b = math.sqrt(s)
        table.insert(positions, Vector3(math.sin(a)*b, 0, math.cos(a)*b))
    end

    for k,v in pairs(positions) do
        local offset = Vector3(v.x * distancemod, 0, v.z * distancemod)
        local pos = offset + pt
        if validtile(pos) and areaislush(pos) and notclaimed(pos) then
            --Yay! Set this as my home
            inst.components.knownlocations:RememberLocation("home", pos)
            break
        end
    end
end

local function playernear(inst)
    if not inst.attacktask and inst.sg:HasStateTag("lure") then
        inst.attacktask = inst:DoTaskInTime(2 + math.random(), onpickedfn)
    end
end

local function playerfar(inst)
    if inst.attacktask then
        inst.attacktask:Cancel()
        inst.attacktask = nil
    end
end

local function onattacked(inst, data)
    if data.attacker then
        inst.components.combat:SetTarget(data.attacker)
        inst.components.combat:ShareTarget(data.attacker, 40, function(dude) return dude:HasTag("worm") and not dude.components.health:IsDead() end, 3)
    end
end

local function fn()
	local inst = CreateEntity()
	
    inst.entity:AddTransform()
	inst.entity:AddAnimState()
 	inst.entity:AddSoundEmitter()
    inst.Transform:SetFourFaced()

    MakeCharacterPhysics(inst, 1000, .5)
    
    inst.AnimState:SetBank("worm")
    inst.AnimState:SetBuild("worm")
    inst.AnimState:PlayAnimation("idle_loop")

    inst:AddTag("monster")    
    inst:AddTag("hostile")
    inst:AddTag("wet")
    
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.WORM_HEALTH)
        
    inst:AddComponent("combat")
    inst.components.combat:SetRange(TUNING.WORM_ATTACK_DIST)
    inst.components.combat:SetDefaultDamage(TUNING.WORM_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.WORM_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(GetRandomWithVariance(2, 0.5), retargetfn)
    inst.components.combat:SetKeepTargetFunction(shouldKeepTarget)
    inst.components.combat.canbeattackedfn = canbeattackedfn
        
    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_SMALL

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 4
    inst.components.locomotor:SetSlowMultiplier( 1 )
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.pathcaps = { ignorecreep = true }

    inst:AddComponent("eater")
    inst.components.eater:SetOmnivore()

    inst:AddComponent("pickable")
    inst.components.pickable.canbepicked = false
    inst.components.pickable.onpickedfn = onpickedfn

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(2, 5)
    inst.components.playerprox:SetOnPlayerNear(playernear)
    inst.components.playerprox:SetOnPlayerFar(playerfar)

    local light = inst.entity:AddLight()
    inst:AddComponent("lighttweener")
    inst.components.lighttweener:StartTween(light, 0, 0.8, 0.5, {1,1,1}, 0, function(inst, light) if light then light:Enable(false) end end)

    inst:AddComponent("knownlocations")
    inst:AddComponent("inventory")
    inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({"monstermeat", "monstermeat", "monstermeat", "monstermeat", "wormlight"})

    inst.displaynamefn = displaynamefn  --Handles the changing names.
    --Disable this task for worm attacks
    inst.HomeTask = inst:DoPeriodicTask(3, LookForHome)
    inst.lastluretime = 0
    inst:ListenForEvent("attacked", onattacked)

    inst:SetStateGraph("SGworm")
    local brain = require"brains/wormbrain"
    inst:SetBrain(brain)


    return inst
end

return Prefab( "cave/monsters/worm", fn, assets, prefabs) 
