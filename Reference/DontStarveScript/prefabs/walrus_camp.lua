require "prefabutil"

local trace = function() end

local assets =
{
    Asset("ANIM", "anim/walrus_house.zip"),
    Asset("ANIM", "anim/igloo_track.zip"),
    Asset("SOUND", "sound/pig.fsb"), -- light on/off sounds
    Asset("MINIMAP_IMAGE", "igloo"),
}

local prefabs =
{
    "walrus",
    "little_walrus",
    "icehound",
}

local NUM_HOUNDS = 2
local AGGRO_SPAWN_PARTY_RADIUS = 10

local function GetSpawnPoint(inst)
    local rad = 2
    local pos = inst:GetPosition()
    trace("GetSpawnPoint", inst, pos)
    local angle = math.random()*2*PI
    pos = pos + Point(rad*math.cos(angle), 0, -rad*math.sin(angle))
    trace("    ", pos)
    return pos:Get()
end

local function GetStatus(inst)
    if not inst.data.occupied then
        return "EMPTY"
    end
end

local function UpdateLight(inst, on)
    if on then
        inst.Light:Enable(true)
        inst.AnimState:PlayAnimation("lit", true)
        if not inst.data.lighton then
            inst.SoundEmitter:PlaySound("dontstarve/pig/pighut_lighton")
        end
        inst.data.lighton = true
    else
        inst.Light:Enable(false)
        inst.AnimState:PlayAnimation("idle", true)
        if inst.data.lighton then
            inst.SoundEmitter:PlaySound("dontstarve/pig/pighut_lightoff")
        end
        inst.data.lighton = false
    end
end

local function SetOccupied(inst, occupied)
    trace("SetOccupied", inst, occupied)

    local anim = inst.AnimState

    inst.data.occupied = occupied

    if inst.data.occupied then

        anim:SetBank("walrus_house")
        anim:SetBuild("walrus_house")

        UpdateLight(inst, not GetClock():IsDay())

        anim:SetOrientation( ANIM_ORIENTATION.Default )
        anim:SetLayer( LAYER_WORLD )
        anim:SetSortOrder( 0 )

        MakeObstaclePhysics(inst, 3)
    else
        UpdateLight(inst, false)

        anim:SetBank("igloo_track")
        anim:SetBuild("igloo_track")
        anim:PlayAnimation("idle")
        anim:SetOrientation( ANIM_ORIENTATION.OnGround )
        anim:SetLayer( LAYER_BACKGROUND )
        anim:SetSortOrder( 3 )

        inst.Physics:ClearCollisionMask()
        inst.Physics:CollidesWith(COLLISION.WORLD)
    end
end

local function UpdateCampOccupied(inst)
    trace("UpdateCampOccupied", inst, inst:GetPosition())
    if inst.data.occupied and GetSeasonManager() and GetSeasonManager():IsSummer() then
        for k,v in pairs(inst.data.children) do
            if k:IsValid() and not k:IsAsleep() then
                -- don't go away while there are children alive in the world
                trace("    Child still awake", k)
                return
            end
        end
        for k,v in pairs(inst.data.children) do
            trace("    Removing sleeping child", k)
            k:Remove()
        end
        inst.data.children = {}
        SetOccupied(inst, false)
    elseif not inst.data.occupied and GetSeasonManager() and GetSeasonManager():IsWinter() then
        SetOccupied(inst, true)
    end
end


local function RemoveMember(inst, member)
    trace("RemoveMember", inst, member)

    inst.data.children[member] = nil

    if inst:IsAsleep() then
        UpdateCampOccupied(inst)
    end
end

local function OnMemberKilled(inst, member, data)
    trace("OnMemberKilled", inst, member, data)

    if not inst.data.regentime then
        inst.data.regentime = {}
    end

    inst.data.regentime[member.prefab] = GetTime() + TUNING.WALRUS_REGEN_PERIOD
    trace("    @", inst.data.regentime[member.prefab])

    RemoveMember(inst, member)
end

local OnMemberNewTarget -- forward declaration

local function TrackMember(inst, member)
    trace("TrackMember", inst, member)
    inst.data.children[member] = true
    inst:ListenForEvent( "death", function(...) OnMemberKilled(inst, ...) end, member )
    inst:ListenForEvent( "newcombattarget", function(...) OnMemberNewTarget(inst, ...) end, member)

    if not member.components.homeseeker then
        member:AddComponent("homeseeker")
    end
    member.components.homeseeker:SetHome(inst)
end

local function SpawnMember(inst, prefab)
    trace("SpawnMember", inst, prefab)
    local member = SpawnPrefab(prefab)

    TrackMember(inst, member)

    return member
end


local function GetMember(inst, prefab)
    for k,v in pairs(inst.data.children) do
        if k.prefab == prefab then
            return k
        end
    end
end

local function GetMembers(inst, prefab)
    local members = {}
    for k,v in pairs(inst.data.children) do
        if k.prefab == prefab then
            table.insert(members, k)
        end
    end
    return members
end

local function CanSpawn(inst, prefab)
    trace("CanSpawn", inst, prefab)
    local regentime = inst.data.regentime and inst.data.regentime[prefab]
    if regentime then
        local time = GetTime()
        local result = time > regentime
        trace("    ", time, ">", regentime, result)
        return result
    else
        trace("    ", true)
        return true
    end
end

local function OnWentHome(inst, data)
    trace("OnWentHome", inst, data and data.doer)
    RemoveMember(inst, data.doer)
    UpdateLight(inst, inst.data.occupied)
end


local function SpawnHuntingParty(inst, target, houndsonly)
    trace("SpawnHuntingParty", inst, target, houndsonly)
    local leader = GetMember(inst, "walrus")
    if not houndsonly and not leader and CanSpawn(inst, "walrus") then
        leader = SpawnMember(inst, "walrus")
        leader.Transform:SetPosition(GetSpawnPoint(inst))
        trace("spawn", leader)
    end

    local companion = GetMember(inst, "little_walrus")
    if not houndsonly and not companion and CanSpawn(inst, "little_walrus") then
        companion = SpawnMember(inst, "little_walrus")
        companion.Transform:SetPosition(GetSpawnPoint(inst))
        trace("spawn", companion)
    end
  
    if companion and leader then
        companion.components.follower:SetLeader(leader)
    end

    local existing_hounds = GetMembers(inst, "icehound")
    for i = 1,NUM_HOUNDS do
        trace("hound", i)

        local hound = existing_hounds[i]
        if not hound and CanSpawn(inst, "icehound") then
            trace("spawn new hound")
            hound = SpawnMember(inst, "icehound")
            hound:AddTag("pet_hound")
            hound.Transform:SetPosition(GetSpawnPoint(inst))

            hound.sg:GoToState("idle")
        else
            trace("use old hound")
        end

        if companion and hound then
            if not hound.components.follower then
                hound:AddComponent("follower")
            end
            hound.components.follower:SetLeader(companion)
        end
    end

    if target then
        if companion then
            companion.components.combat:SuggestTarget(target)
        end
        if leader then
            leader.components.combat:SuggestTarget(target)
        end
    end
end


local function CheckSpawnHuntingParty(inst, target, houndsonly)
    trace("CheckSpawnHuntingParty", inst, target)
    if inst.data.occupied and GetSeasonManager():IsWinter() then
        SpawnHuntingParty(inst, target, houndsonly)
        UpdateLight(inst, houndsonly) -- keep light on if hounds only, otherwise off
    end
end

-- assign value to forward declared local above
OnMemberNewTarget = function (inst, member, data)
    trace("OnMemberNewTarget", inst, member, data)
    if member:IsNear(inst, AGGRO_SPAWN_PARTY_RADIUS) then
        CheckSpawnHuntingParty(inst, data.target, false)
    end
end

local function OnEntitySleep(inst)
    trace("OnEntitySleep", inst)
    if not POPULATING then
	    UpdateCampOccupied(inst)
    	CheckSpawnHuntingParty(inst, nil, not GetClock():IsDay())
	end
end

local function OnEntityWake(inst)
    --trace("OnEntityWake", inst)
end

local function OnDay(inst)
    trace("OnDay", inst)
    CheckSpawnHuntingParty(inst, nil, false)
end

local function OnSeasonChange(inst)
    trace("OnSeasonChange", inst)
    if inst:IsAsleep() then
        UpdateCampOccupied(inst)
        CheckSpawnHuntingParty(inst, nil, not GetClock():IsDay())
    end
end

local function OnSave(inst, data)

    trace("OnSave", inst, GetTime())

    data.children = {}

    for k,v in pairs(inst.data.children) do
        trace("    ", k.prefab, k.GUID)
        table.insert(data.children, k.GUID)
    end

    if #data.children < 1 then
        data.children = nil
    end

    data.occupied = inst.data.occupied
    trace("    occupied ", data.occupied)

    if inst.data.regentime then
        local time = GetTime()
        data.regentimeremaining = {}
        for k,v in pairs(inst.data.regentime) do
            local remaining = v - time
            if remaining > 0 then
                data.regentimeremaining[k] = remaining
                trace("    ", k, remaining)
            end
        end
    end

    return data.children

end
        
local function OnLoad(inst, data)

    trace("OnLoad", inst, GetTime())
    if data then
    -- children loaded by OnLoadPostPass

        trace("    occupied", data.occupied)
        if data.occupied ~= nil then
            SetOccupied(inst, data.occupied)
        end

        inst.data.regentime = {}
        if data.regentimeremaining then
            local time = GetTime()
            for k,v in pairs(data.regentimeremaining) do
                inst.data.regentime[k] = time + v
                trace("    ", k, time + v)
            end
        end
    end
end

local function OnLoadPostPass(inst, newents, data)
--    print("OnLoadPostPass", inst, newents, data and data.children and #data.children)

    if data and data.children and #data.children > 0 then
        for k,v in pairs(data.children) do
            local child = newents[v]
            if child then
                print("Child Name: ", child.entity.prefab)
                child = child.entity
                trace("    ", child.prefab)
                TrackMember(inst, child)
            end
        end

    end
end


local function create(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()

    anim:SetBank("walrus_house")
    anim:SetBuild("walrus_house")

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "igloo.png" )
	
    inst.data = { children = {} }

	inst.entity:AddSoundEmitter()

	--inst:AddTag("tent")    
    
    MakeObstaclePhysics(inst, 3)

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus

    inst:ListenForEvent("daytime", function() OnDay(inst) end, GetWorld())
    inst:ListenForEvent("onwenthome", OnWentHome)

    local light = inst.entity:AddLight()
    light:SetFalloff(1)
    light:SetIntensity(.5)
    light:SetRadius(2)
    light:SetColour(180/255, 195/255, 50/255)

    inst.data.lighton = not GetClock():IsDay()
    light:Enable(inst.data.lighton)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.OnLoadPostPass = OnLoadPostPass

    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake

	SetOccupied(inst, GetSeasonManager() and GetSeasonManager():IsWinter() or false)

    inst:ListenForEvent("seasonChange", function() OnSeasonChange(inst) end, GetWorld())

    return inst
end

return Prefab( "common/objects/walrus_camp", create, assets, prefabs) 
