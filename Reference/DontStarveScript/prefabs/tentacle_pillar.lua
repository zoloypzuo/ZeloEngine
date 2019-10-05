-- Prefab:  tentacle_pillar
--          Large tentacle pillar reaching up through the roof of the cave
--          Causes short quake if killed
-- Prefab:  Tentacle_garden
--          tentacle_pillar with extra loot
--          If attacked, a large number of small tentacles spring up around pillar
--
-- Keeps track of total number of arms to reduce overhead
--
-- 

local all_active_arms = {}         -- 
local global_loot_drops = { spikedone=false, skeletondone=false, turfcount=0 }
local global_reset = 0
local global_time = false
local function SpawnArms() end

local prefabs = 
{
    "tentaclespike",
    "tentaclespots",
    "lightbulb",
    "skeleton",
	"slurtleslime",
    "turf_marsh",
    "rocks",
}

local assets =
{
    Asset("ANIM", "anim/tentacle_pillar.zip"),
    Asset("SOUND", "sound/tentacle.fsb"),
    Asset("MINIMAP_IMAGE", "tentapillar"),
}

--  Don't keep arms around on save
local function OnLoad(inst, data)
    if data then
        inst.reloadTime = data.reloadTime or 0
        inst.retracted = data.retracted or false
        inst.nextEmerge = data.nextEmerge or 0
        global_loot_drops.spikedone    = data.lootdrops.spikes
        global_loot_drops.skeletondone = data.lootdrops.skel
        global_loot_drops.turfcount    = data.lootdrops.turf
        if inst.retracted then
            --MakeObstaclePhysics(inst, 3, 1)
            -- inst.Physics:SetCollisionGroup(COLLISION.GROUND)
            inst.SoundEmitter:KillSound("loop")
            inst.AnimState:PlayAnimation("idle_hole",true)
	        inst.AnimState:SetTime(math.random()*2)    
            inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentapiller_hiddenidle_LP","loop") 
            inst:RemoveTag("wet")
            inst:AddTag("rocky")
        else
            inst.SoundEmitter:KillSound("loop")
            inst.AnimState:PlayAnimation("idle",true)
	        inst.AnimState:SetTime(math.random()*2)    
            inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentapiller_idle_LP","loop") 
            inst:RemoveTag("rocky")
            inst:AddTag("wet")
        end
    end
end

local function OnSave(inst, data)
    data.reloadTime = inst.reloadTime or 0
    data.retracted = inst.retracted
    data.nextEmerge = inst.nextEmerge or 0
    data.lootdrops = {}
    data.lootdrops.spikes = global_loot_drops.spikedone
    data.lootdrops.skel   = global_loot_drops.skeletondone
    data.lootdrops.turf   = global_loot_drops.turfcount
    data.greset = global_reset
end

local function OnLongUpdate(inst, dt)

    -- dprint(inst,"LongUpdate:",dt)

    inst.reloadTime = (inst.reloadTime or 0) - dt
    global_reset = (global_reset or 0) - dt
    inst.nextEmerge = (inst.nextEmerge or 0) -dt

    if global_reset <= 0 then
        global_loot_drops = { spikedone=false, skeletondone=false, turfcount=0 }
        global_reset = 0
    end

end

local function ResetLoot(inst) 
    global_loot_drops = { spikedone=false, skeletondone=false, turfcount=0 }
    global_reset = 0
    inst.reloadTime = 0
end

local function DropLoot(inst) 
    local dt = GetTime() - (inst.lastDropTime or 0)
    inst.reloadTime = (inst.reloadTime or 0) - dt
    inst.lastDropTime = GetTime()

    dt = GetTime() - (global_time or 0)
    global_reset = (global_reset or 0) - dt
    global_time = GetTime()

    -- dprint("DropLoot: reload in:",inst.reloadTime," :glob_reset=",global_reset)

    -- We want lots of tentacles, but we don't want lots of loot dropped
    -- So keep a global track of what's been dropped today
    if global_reset <= 0 then
        -- dprint("--------------------- RESET GLOBAL LOOT")
        global_loot_drops = { spikedone=false, skeletondone=false, turfcount=0 }
        global_reset = GetRandomWithVariance(TUNING.TOTAL_DAY_TIME,TUNING.TOTAL_DAY_TIME/5)
    end

    if inst.reloadTime <=0 then
        inst.reloadTime = GetRandomWithVariance(TUNING.TOTAL_DAY_TIME*0.75,TUNING.TOTAL_DAY_TIME/4)

        -- g_loot_drops = { spikedone=false, skeletondone=false, turfcount=0 }
        local loot = {}
        if not global_loot_drops.spikedone and math.random() < 0.5 then
            loot[#loot+1] = "tentaclespike"
            global_loot_drops.spikedone = true
        end
        if not global_loot_drops.skeletondone and math.random() < 0.1 then
            loot[#loot+1] = "skeleton"
            global_loot_drops.skeletondone = true
        end
        if global_loot_drops.turfcount < 4 and math.random() < 0.25 then
            loot[#loot+1] = "turf_marsh"
            global_loot_drops.turfcount = global_loot_drops.turfcount + 1
        end

        inst.components.lootdropper:SetLoot(loot)
        -- SetLoot removes all random and chance loot definitions
        inst.components.lootdropper:AddChanceLoot("tentaclespots", 0.4)
        inst.components.lootdropper:AddChanceLoot("lightbulb", 0.8)
        inst.components.lootdropper:AddChanceLoot("slurtleslime", 0.1)
        --inst.components.lootdropper:AddChanceLoot("rocks", 0.1)

        inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))
    end
end


-- Kill off the arms in the garden, optionally just those furtherThan the given distance from the player
local function KillArms(inst,instant,fartherThan)
    if type(inst.arms) == "table" then
        if not fartherThan then
            for key,v in pairs(inst.arms) do
                if not instant then
                    key:PushEvent("pillardead")
                else
                    key:Remove()
                end
            end
            inst.arms = nil
        else
            local ff = fartherThan * fartherThan
            local player = GetPlayer()
            for key,v in pairs(inst.arms) do
                if key:GetDistanceSqToInst(player) > ff and key:GetDistanceSqToInst(inst) >= 16 then
                    key:PushEvent("pillardead")
                end
            end
        end
    end
end

-- Keep track of all arms - remove from tracking list upon death
local function ArmRemoveEntity(inst)
    all_active_arms[inst] = nil
end

local function GetNextEmergeTime(inst)
        return GetRandomWithVariance(TUNING.TENTACLE_PILLAR_ARM_EMERGE_TIME,50)
end

local function PillarChange(inst)

    if inst:HasTag("pillaremerging") then
        -- dprint("===================================  PillarEmerge")
        inst:RemoveTag("pillaremerging")
        inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentapiller_idle_LP","loop") 
        inst:RemoveEventCallback("animover", PillarChange)
        inst.retracted = false
        inst.components.health:SetMaxHealth(TUNING.TENTACLE_HEALTH)
    elseif inst:HasTag("pillarretracting") then
        -- dprint("===================================  PillarRetract")
        inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentapiller_hiddenidle_LP","loop") 
        inst:RemoveTag("pillarretracting")
        inst:RemoveEventCallback("animover", PillarChange)
        inst.retracted = true
        inst.components.health:SetMaxHealth(TUNING.TENTACLE_HEALTH)
    end

end

local function PillarEmerges(inst,withArms)

    local dt = GetTime() - (inst.lastEmergeCheck or 0)
    inst.lastEmergeCheck = GetTime()

    inst.nextEmerge = (inst.nextEmerge or 0) - dt
    -- dprint("time=",GetTime(),"  last=",inst.lastEmergeCheck," nextEmerge=",inst.nextEmerge)
    
    inst.components.health:SetMaxHealth(TUNING.TENTACLE_HEALTH)

    if inst.retracted and inst.nextEmerge <= 0 then
        inst.nextEmerge = GetNextEmergeTime(inst)
        inst.retractedHits = 0

        -- dprint("NEXT Emerge at: ",inst.nextEmerge)

        inst.AnimState:PlayAnimation("emerge") 
        inst.AnimState:PushAnimation("idle", true)
        inst:ListenForEvent("animover", PillarChange)
        inst:AddTag("pillaremerging")
        inst:RemoveTag("rocky")
        inst:AddTag("wet")

        --MakeObstaclePhysics(inst, 3, 24)
        --inst.Physics:SetCollisionGroup(COLLISION.GROUND)
        inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentapiller_emerge") 
        -- TheCamera:Shake(shakeType, duration, speed, scale)
        TheCamera:Shake("FULL", 5.0, 0.05, .2)

        if withArms then
            SpawnArms(inst,false,true)
        end

    end
end

local function DoShake(inst)
    local world = GetWorld()
    local quaker = world.components.quaker

    if quaker and math.random() > 0.3 then
        quaker:ForceQuake("tentacleQuake")
    else
        TheCamera:Shake("FULL", 5.0, 0.05, .2)
    end
end

local function OnDeath(inst)
    -- dprint("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ DEATH EVENT")
end

local function OnKilled(inst)

    -- dprint("ONKILLED: Health is:",inst.components.health.currenthealth)

    if inst.retracted then
        inst.retractedHits = 0
        PillarEmerges(inst,true)
        return
    end

    inst:DoTaskInTime(1.0,DoShake,inst)

    inst.retracted = true
    inst:AddTag("pillarretracting")

    inst.nextEmerge = GetNextEmergeTime(inst)
    inst.components.health:SetMaxHealth(TUNING.TENTACLE_HEALTH)

    inst.SoundEmitter:KillSound("loop")
    inst.AnimState:PlayAnimation("retract",false)
    inst:ListenForEvent("animover", PillarChange)
    inst.AnimState:PushAnimation("idle_hole",true)
    inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentapiller_die")
    inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentapiller_die_VO")

    inst:RemoveTag("wet")
    inst:AddTag("rocky")

    KillArms(inst)
    DropLoot(inst) 
end

local function ManageArms(inst)
    local numArms = 0
    for key, value in pairs(inst.arms) do
        if not key:IsValid() or key.components.health:IsDead() then
            inst.arms[key] = nil
        else
            numArms = numArms + 1
        end
    end
    -- Ok... kill off arms from any other tentacle_pillar
    for key, value in pairs(all_active_arms) do
        if not inst.arms[key] then
            if inst:IsNear(GetPlayer(),25) then
                Dbg(key,true,"ManageArms: pillardead")
                key:PushEvent("pillardead")
            else
                key:Remove()
            end
        end
    end
    return numArms
end

local function OnEntityWake(inst)
    if inst.retracted then
        inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentapiller_hiddenidle_LP","loop") 
        inst:RemoveTag("wet")
        inst:AddTag("rocky")
    else
        inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentapiller_idle_LP","loop") 
        inst:RemoveTag("rocky")
        inst:AddTag("wet")
    end
end

local function OnEntitySleep(inst)
	inst.SoundEmitter:KillSound("loop")
    KillArms(inst,true)
end

local function onfar(inst)
    -- dprint(inst,"FAR")
    if not inst.components.health:IsDead() then
        --inst.AnimState:SetMultColour(.1, .1, .1, 0.)
        KillArms(inst,false)
    end
end

local function onnear(inst)
    if not inst.components.health:IsDead() then
        -- inst.AnimState:SetMultColour(1, 1, 1, 1)
    end
    -- dprint(inst,"NEAR")
    if inst.retracted then
        if math.random() > .75 then
            -- dprint("ON_NEAR: Resurrect")
            PillarEmerges(inst,true)
        end
    end
end

local function Emerge (inst)
   		if inst and inst.brain then
       		inst.brain.followtarget = GetPlayer()
        end
        -- inst.sg:GoToState("emerge")
        Dbg(inst,true,"Pillar says emerge")
        inst:PushEvent("emerge")
end

SpawnArms =  function(inst,attacker,forcelocal)

    if not inst.garden then return end

    attacker = attacker or GetPlayer()

	--spawn tentacles to spring the trap
	local pt = Vector3(inst.Transform:GetWorldPosition())
    local pillarLoc = pt
    local theta 
    local minRadius = 3
    local ringdelta = 1.5
    local rings = 3
    local steps = math.floor((TUNING.TENTACLE_PILLAR_ARMS / rings)+0.5)
    local ground = GetWorld()
    local player = GetPlayer()
    local numArms = 0

    -- Walk the circle trying to find a valid spawn point 
    inst.arms = inst.arms or {}    -- list of arms
    inst.totalArms = inst.totalArms or 0  -- total # of arms spawned for this pillar

    numArms = ManageArms(inst)
    inst.totalArms = numArms

    if inst.totalArms >= (TUNING.TENTACLE_PILLAR_ARMS_TOTAL-3) then
        KillArms(inst,false,6)  -- despawn tentacles away from player
        inst.spawnLocal = true
        return
    end

    if not forcelocal and inst.spawnLocal then
	    pt = Vector3(attacker.Transform:GetWorldPosition())
        minRadius = 1
        ringdelta = 1
        rings = 3
        steps = 4
        inst.spawnLocal = nil
    end

    for r=1, rings do
        theta = GetRandomWithVariance(0.0,PI/2) -- randomize starting angle
        -- dprint("Starting theta:",theta)
        for i = 1, steps do
            local radius = GetRandomWithVariance(ringdelta,ringdelta/3) + minRadius
            local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))
            local wander_point = pt + offset
            local pillars = TheSim:FindEntities(wander_point.x, wander_point.y,wander_point.z,3.5,{"tentacle_pillar"})
            if next(pillars) then
                -- dprint("FoundPillar",pillars[1])
	            pillarLoc = Vector3(pillars[1].Transform:GetWorldPosition())
            end
           
            if ground.Map    
               and ground.Map:GetTileAtPoint(wander_point.x, wander_point.y, wander_point.z) ~= GROUND.IMPASSABLE 
               and ground.Map:GetTileAtPoint(wander_point.x, wander_point.y, wander_point.z) < GROUND.UNDERGROUND 
               and distsq(pillarLoc,wander_point) > 8
               and numArms < TUNING.TENTACLE_PILLAR_ARMS_TOTAL then

                local arm = SpawnPrefab("tentacle_pillar_arm")
                if arm then
                    inst.arms[arm] = true           -- keep track of arms this pillar has
                    all_active_arms[arm] = true     -- keep track of all active arms in the cave
                    numArms = numArms + 1
                    inst.totalArms = inst.totalArms + 1
                    inst.OnRemoveEntity = ArmRemoveEntity
                    arm.Transform:SetPosition( wander_point.x, wander_point.y, wander_point.z )
                    arm:DoTaskInTime(GetRandomWithVariance(0.3,0.2), Emerge )
                    -- Make them do more damage when bigger???
                    --arm.components.combat:SetDefaultDamage(TUNING.TENTACLE_PILLAR_ARM_DAMAGE)
                end
            end
            theta = theta - (2 * PI / steps)
        end
        minRadius = minRadius + ringdelta
    end
end

local function OnHit(inst, attacker, damage) 
        
    -- dprint(damage," Hit: Health->",inst.components.health.currenthealth," from:",attacker)
    if attacker.components.combat and attacker ~= GetPlayer() and math.random() > 0.5 then
        -- Followers should stop hitting the pillar
        -- dprint(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>RESETTING ATTACKER TARGET")
        attacker.components.combat:SetTarget(nil)
        if inst.components.health.currenthealth and inst.components.health.currenthealth <0 then
            inst.components.health:DoDelta(damage*.6, false, attacker)
        end
    end
    if not inst.components.health:IsDead() and not inst.retracted then
        inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentapiller_hurt_VO")
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation("idle", true)
        -- :Shake(shakeType, duration, speed, scale)
        if attacker == GetPlayer() then
    	    TheCamera:Shake("SIDE", 0.5, 0.05, .2)
        end
        SpawnArms(inst,attacker)
    elseif inst.retracted and not inst:HasTag("pillaremerging") and not inst:HasTag("pillarretracting") then
        inst.retractedHits = inst.retractedHits or 0
        inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentapiller_hiddenhurt_VO")
        inst.AnimState:PlayAnimation("hit_hole")
        inst.AnimState:PushAnimation("idle_hole", true)
        if attacker:HasTag("character") then
            inst.retractedHits = inst.retractedHits + 1
            -- dprint("HITS:",inst.retractedHits)
            -- Hitting the hole randomly attracts another tentacle
            if inst.retractedHits > math.random(9,18) then
                -- dprint("Hit calls cthulu")
                PillarEmerges(inst)
                inst.retractedHits = 0
            end
        end
    end
end


local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    --inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentapiller_idle_LP","loop")
	
    inst.OnLoad = OnLoad
    inst.OnSave = OnSave

    inst.garden = false    -- by default make this a simple pillar
    inst.nextEmerge = 0
    inst.lastEmergeCheck = 0
    inst.reloadTime = 0
    inst.retracted = false
    inst.OnLongUpdate = OnLongUpdate

    MakeObstaclePhysics(inst, 3, 24)
    inst.Physics:SetCollisionGroup(COLLISION.GROUND)
    trans:SetScale(1,1,1)
    inst:AddTag("tentacle_pillar")    
    inst:AddTag("wet")
    inst:AddTag("WORM_DANGER")

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "tentapillar.png" )

	anim:SetBank("tentaclepillar")     -- flash animation .fla 
	anim:SetBuild("tentacle_pillar")   -- art files
    -- anim:SetMultColour(.2, 1, .2, 1.0)

    -------------------
	inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.TENTACLE_HEALTH)
    inst.components.health:SetMinHealth(10)
    -------------------
    
    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(10, 30)
    inst.components.playerprox:SetOnPlayerNear(onnear)
    inst.components.playerprox:SetOnPlayerFar(onfar)

    -------------------
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({})
    inst.components.lootdropper:AddChanceLoot("tentaclespots", 0.2)
    inst.components.lootdropper:AddChanceLoot("turf_marsh", 0.1)
    inst.components.lootdropper:AddChanceLoot("lightbulb", 0.2)
    ---------------------  

    inst:AddComponent("combat")
    inst.components.combat:SetOnHit(OnHit)
    inst:ListenForEvent("death", OnDeath)
    inst:ListenForEvent("minhealth", OnKilled)
    inst:AddComponent("inspectable")
    
    -- HACK: this should really be in th ec side checking the maximum size of the anim or the _current_ size of the anim instead
    -- of frame 0
    inst.entity:SetAABB(60, 20)

   return inst
end

local function Garden(Sim)   -- prefab with garden of arms
    local inst = fn(Sim)

    inst.garden = true
    if math.random() < .2 then
        inst.retracted = true
	    inst.AnimState:SetTime(math.random()*2)    
        inst:DoTaskInTime(2*FRAMES, function()
                            inst.AnimState:PlayAnimation("idle_hole",true)
                            inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentapiller_hiddenidle_LP","loop") 
                            end)
    else
	    inst.AnimState:SetTime(math.random()*2)    
        inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentapiller_idle_LP","loop")
        inst:DoTaskInTime(2*FRAMES, function()
                            inst.AnimState:PlayAnimation("idle",true)
                            inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentapiller_hiddenidle_LP","loop") 
                            end)
    end

    return(inst)
end

return Prefab( "cave/monsters/tentacle_pillar", fn,     assets, prefabs ),
       Prefab( "cave/monsters/tentacle_garden", Garden, assets, prefabs )

