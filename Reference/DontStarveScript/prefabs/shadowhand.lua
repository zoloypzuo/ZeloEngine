local assets=
{
	Asset("ANIM", "anim/shadow_creatures_ground.zip"),
}

local prefabs = 
{
    "shadowhand_arm",
}

function GoHome(inst)
    if inst.arm then
        local gohome = BufferedAction(inst, inst.arm, ACTIONS.GOHOME, nil, Vector3(inst.arm.Transform:GetWorldPosition() ) )
        inst.components.locomotor:PushAction(gohome)
    end
end

local function Retreat(inst)
    inst.AnimState:PlayAnimation("scared_loop", true)
	inst.SoundEmitter:KillSound("creeping")
    inst.SoundEmitter:PlaySound("dontstarve/sanity/shadowhand_retreat", "retreat")
    inst.components.locomotor:Clear()
    inst.components.locomotor.walkspeed = -8
    GoHome(inst)
end

local function Dissipate(inst)
    inst.SoundEmitter:PlaySound("dontstarve/sanity/shadowhand_snuff")
	inst.SoundEmitter:KillSound("creeping")
	inst.SoundEmitter:KillSound("retreat")
    inst.AnimState:PlayAnimation("hand_scare")
    if inst.components.playerprox then
        inst:RemoveComponent("playerprox")
    end
    if inst.arm then
        inst.arm.AnimState:PlayAnimation("arm_scare")
    end
    inst:ListenForEvent("animover", function(inst) inst:Remove() end)
end

local function Retract(inst)
    if inst.components.playerprox then
        inst:RemoveComponent("playerprox")
    end
	inst.SoundEmitter:KillSound("creeping")
    inst.components.locomotor:Clear()
    inst.components.locomotor.walkspeed = -10
    inst.AnimState:PlayAnimation("grab_pst")
    if inst.arm then
        inst.components.locomotor:GoToEntity(inst.arm)
    end
    inst:ListenForEvent("animover", function(inst) inst:Remove() end)
end

local function SeekFire(inst)
    local fire = FindEntity(inst, 40, function(ent)
        return ent.components.burnable
               and ent.components.burnable:IsBurning()
               and ent.components.fueled
               and not ent.components.equippable
    end)
    if fire then
        if inst.firetask then
            inst.firetask:Cancel()
            inst.firetask = nil
        end
        inst.SoundEmitter:PlaySound("dontstarve/sanity/shadowhand_creep", "creeping")
        if not inst.arm then
            inst.components.knownlocations:RememberLocation("origin", Vector3(inst.Transform:GetWorldPosition() ) )
	        inst.arm = SpawnPrefab("shadowhand_arm")
	        inst.arm.Transform:SetPosition(inst.Transform:GetWorldPosition() )
	        inst.arm:FacePoint(Vector3(fire.Transform:GetWorldPosition() ) )
	        inst.arm.components.stretcher:SetStretchTarget(inst)
	        inst.arm:ListenForEvent("enterlight", function() Dissipate(inst) end)
        end
        inst.arm:PushEvent("onfoundfire", {fire = fire, hand = inst})
        inst.components.locomotor.walkspeed = 2
        inst.components.locomotor:PushAction(BufferedAction(inst, fire, ACTIONS.EXTINGUISH), false)
        inst:ListenForEvent("onextinguish", inst.dissipatefn, fire)
    end
end

local function ExtinguishFire(inst, target)
    if target then
        inst.AnimState:PlayAnimation("grab")
        inst.AnimState:PushAnimation("grab_pst", false)
        inst:RemoveEventCallback("onextinguish", inst.dissipatefn, target)
        inst:RemoveComponent("playerprox")
        inst:DoTaskInTime(17*FRAMES, function(inst)
            inst:PerformBufferedAction()
            inst.SoundEmitter:PlaySound("dontstarve/sanity/shadowhand_snuff")
            Retract(inst)
        end)
    end
end

local function StartLookingForFire(inst, delay)
    if inst.firetask then
        inst.firetask:Cancel()
        inst.firetask = nil
    end
    inst.firetask = inst:DoPeriodicTask(1, SeekFire, delay)
end

local function Regroup(inst)
    inst.AnimState:PushAnimation("hand_in_loop", true)
    inst.components.locomotor:Clear()
    inst.components.locomotor:Stop()
	inst.SoundEmitter:KillSound("retreat")
    local delay = math.random()*3+2-- or 1*FRAMES
    StartLookingForFire(inst, delay)
end

local function HandleAction(inst, data)
    if data.action then
        if data.action.action == ACTIONS.EXTINGUISH then
            ExtinguishFire(inst, data.action.target)
        elseif data.action.action == ACTIONS.GOHOME then
            Dissipate(inst)
        end
    end
end


local function onremoveentity(inst)
    inst.SoundEmitter:KillAllSounds()
end


local function create_hand()
	local inst = CreateEntity()
	inst:AddTag("shadowhand")
	
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    inst.entity:AddPhysics()
	inst.entity:AddLightWatcher()
    inst.LightWatcher:SetLightThresh(.2)
    inst.LightWatcher:SetDarkThresh(.19)

    if IsDLCEnabled(PORKLAND_DLC) then
        MakeSpecialGhostPhysics(inst, 10, .5)
    else
        MakeCharacterPhysics(inst, 10, .5)
    end
    
    inst.dissipatefn = function() Dissipate(inst) end
    inst:ListenForEvent( "daytime", inst.dissipatefn, GetWorld())
    
    inst.AnimState:SetBank("shadowcreatures")
    inst.AnimState:SetBuild("shadow_creatures_ground")
	inst.AnimState:SetOrientation( ANIM_ORIENTATION.OnGround )
	inst.AnimState:SetLayer( LAYER_BACKGROUND )
	inst.AnimState:SetSortOrder( 3 )
    inst.AnimState:PlayAnimation("hand_in")
    inst.AnimState:PushAnimation("hand_in_loop", true)
    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(2,6)
    inst.components.playerprox:SetOnPlayerNear(Retreat)
    inst.components.playerprox:SetOnPlayerFar(Regroup)
    
    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.walkspeed = 2
    inst.components.locomotor.directdrive = true
	inst.components.locomotor.slowmultiplier = 1
	inst.components.locomotor.fastmultiplier = 1
	
	inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_MED
	    
    inst:AddComponent("knownlocations")
    inst:ListenForEvent("startaction", HandleAction)
    inst.OnRemoveEntity = onremoveentity
    
    return inst
end

local function ArmFoundFire(inst, data)
    if data and data.hand then
        if data.hand and data.fire then
            data.hand:RemoveEventCallback("onextinguish", data.hand.dissipatefn, data.fire)
        end
        inst.hand = data.hand
        inst:ListenForEvent("onremove", function() inst:Remove() end, inst.hand)
    end
end



local function create_arm()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.persists = false
	inst.entity:AddLightWatcher()
    inst.LightWatcher:SetLightThresh(.2)
    inst.LightWatcher:SetDarkThresh(.19)
    inst.AnimState:SetBank("shadowcreatures")
    inst.AnimState:SetBuild("shadow_creatures_ground")
	inst.AnimState:SetOrientation( ANIM_ORIENTATION.OnGround )
	inst.AnimState:SetLayer( LAYER_BACKGROUND )
	inst.AnimState:SetSortOrder( 3 )
	
	
    inst.AnimState:PlayAnimation("arm_loop", true)
    
    inst:AddComponent("stretcher")
    inst.components.stretcher:SetRestingLength(4.75)
    inst.components.stretcher:SetWidthRatio(.35)
    inst:ListenForEvent("onfoundfire", ArmFoundFire)

    return inst
end

return Prefab("common/shadowhand", create_hand, assets, prefabs),
       Prefab("common/shadowhand_arm", create_arm, assets) 
