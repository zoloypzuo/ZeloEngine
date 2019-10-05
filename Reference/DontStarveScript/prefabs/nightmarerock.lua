--Down when sane, up when insane.
local assets = 
{
    Asset("ANIM", "anim/blocker_sanity.zip"),
    Asset("ANIM", "anim/blocker_sanity_fx.zip"),
    Asset("MINIMAP_IMAGE", "obelisk"),
}

local prefabs = 
{
    "sanity_raise",
    "sanity_lower"
}

local function getnearbypoints(inst, pt)
    local r_array = {}
    local arrayspot = 1
    for numPoints = -inst.collisionsize, inst.collisionsize do
        r_array[arrayspot] = pt + numPoints
        arrayspot = arrayspot + 1       
    end
    return r_array
end

local function turnonpathfinding(inst)
    local ground = GetWorld()
    if ground then
        if not inst.pftable then --There's no table of pathfinding values, create it
            inst.pftable = {}
        else --there was stored pathfinding values. Wipe it incase object has moved, we'll create new values.
            inst.pftable = nil
            inst.pftable = {}
        end 
        local pt = Point(inst.Transform:GetWorldPosition())       
        local nearbyX = getnearbypoints(inst, pt.x)
        local nearbyZ = getnearbypoints(inst, pt.z)        
        for x_counter = 1,#nearbyX do
            for z_counter = 1,#nearbyZ do
                local block = {nearbyX[x_counter], pt.y, nearbyZ[z_counter]}
                ground.Pathfinder:AddWall(block[1], block[2], block[3]) 
                table.insert(inst.pftable, block)                                 
            end
        end
    end
end

local function turnoffpathfinding(inst)
    local ground = GetWorld()
    if ground then
        if not inst.pftable then --there is no stored table of pathfinding locations, use world location
            local pt = Point(inst.Transform:GetWorldPosition())
            local nearbyX = getnearbypoints(inst, pt.x)
            local nearbyZ = getnearbypoints(inst, pt.z)                    
            for x_counter = 1,#nearbyX do
                for z_counter = 1,#nearbyZ do
                    ground.Pathfinder:RemoveWall(nearbyX[x_counter], pt.y, nearbyZ[z_counter])          
                end
            end
        else --there was a table of stored pathfinding locations, use them instead.            
            for pftable_counter = 1, #inst.pftable do
                ground.Pathfinder:RemoveWall(inst.pftable[pftable_counter][1], inst.pftable[pftable_counter][2], inst.pftable[pftable_counter][3])             
            end
        end

    end
end

local function setrockactive(inst)    
    inst.AnimState:PlayAnimation("raise")
    inst.AnimState:PushAnimation("idle_active", true)
    local fx = SpawnPrefab("sanity_raise")
    local pos = inst:GetPosition()
    fx.Transform:SetPosition(pos.x, pos.y, pos.z)
    
    inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.ITEMS)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    turnonpathfinding(inst)
    inst.SoundEmitter:PlaySound("dontstarve/sanity/shadowrock_up")
end

local function  setrockinactive(inst)    
    inst.AnimState:PlayAnimation("lower")
    inst.AnimState:PushAnimation("idle_inactive", true)
    local fx = SpawnPrefab("sanity_lower")
    local pos = inst:GetPosition()
    fx.Transform:SetPosition(pos.x, pos.y, pos.z)
    --PlayFX(inst:GetPosition(), "blocker_sanity_fx", "blocker_sanity_fx", "lower")    
    inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.ITEMS)
    turnoffpathfinding(inst)
    inst.SoundEmitter:PlaySound("dontstarve/sanity/shadowrock_down")
end

local function startrockactive(inst)
    if inst.task then
        inst.task:Cancel()
        inst.task = nil
    end
    inst.task = inst:DoTaskInTime(math.random(), setrockactive) 
end

local function startrockinactive(inst)
    if inst.task then
        inst.task:Cancel()
        inst.task = nil
    end
    inst.task = inst:DoTaskInTime(math.random(), setrockinactive)  
end

local function inspect_insanityrock(inst)
    local player = GetPlayer()    
    if player and player.components.sanity then
        if player.components.sanity:IsSane() then
            return "INACTIVE"
        else
            return "ACTIVE"
        end
    else
        return "INACTIVE"
    end
end

local function inspect_sanityrock(inst)
    local player = GetPlayer()    
    if player and player.components.sanity then
        if player.components.sanity:IsSane() then
            return "ACTIVE"
        else
            return "INACTIVE"
        end
    else
        return "ACTIVE"
    end
end

local function forcerockactive(inst)
    inst.AnimState:PlayAnimation("idle_active")
    inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.ITEMS)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    turnonpathfinding(inst)
end

local function forcerockinactive(inst)
    inst.AnimState:PlayAnimation("idle_inactive")
    inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.ITEMS)
    turnoffpathfinding(inst)
end

local function rockstartup(inst, player, ifinsanefn, ifsanefn)
    if player and player.components.sanity and player.components.sanity:IsSane() then
        ifsanefn(inst)
    elseif player and player.components.sanity and not player.components.sanity:IsSane() then
        ifinsanefn(inst)
    end
end

local function  onsave(inst, data)
    if inst.pftable then
        data.pftable = inst.pftable
    end   
end

local function onload(inst, data)

end

local function insanityrockonload(inst, data)
    if data and data.pftable then
        inst.pftable = data.pftable
    end
    rockstartup(inst, inst.player, forcerockactive, forcerockinactive)
end

local function sanityrockonload(inst, data)
    if data and data.pftable then
        inst.pftable = data.pftable
    end
    rockstartup(inst, inst.player, forcerockinactive, forcerockactive)
end

local function commonfn()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    inst.pftable = nil
    inst.collisionsize = 1 --must be an int for getnearbypoints()
    MakeObstaclePhysics(inst, inst.collisionsize)
    inst.entity:AddSoundEmitter()

    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon( "obelisk.png" )

    inst:AddComponent("inspectable")

    anim:SetBank("blocker_sanity")
    anim:SetBuild("blocker_sanity")
    anim:PlayAnimation("idle_inactive")

    inst.player = GetPlayer()

    inst.OnSave = onsave
    return inst
end

local function insanityrock()
    local inst = commonfn()
    inst.player:ListenForEvent("gosane",function() startrockinactive(inst) end)
    inst.player:ListenForEvent("goinsane", function() startrockactive(inst) end)
    rockstartup(inst, inst.player, forcerockactive, forcerockinactive)
    inst.components.inspectable.getstatus = inspect_insanityrock
    inst.OnLoad = insanityrockonload
    return inst
end

local function sanityrock()
    local inst = commonfn()
    inst.player:ListenForEvent("gosane",function() startrockactive(inst) end)
    inst.player:ListenForEvent("goinsane", function() startrockinactive(inst) end)
    rockstartup(inst, inst.player, forcerockinactive, forcerockactive)
    inst.components.inspectable.getstatus = inspect_sanityrock
    inst.OnLoad = sanityrockonload

    return inst
end

return Prefab("forest/objects/rocks/insanityrock", insanityrock, assets, prefabs),
       Prefab("forest/objects/rocks/sanityrock", sanityrock, assets, prefabs) 
