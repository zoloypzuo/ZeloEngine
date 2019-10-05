
local trace = function() end

local assets=
{
    Asset("ANIM", "anim/koalefant_tracks.zip"),
    Asset("ANIM", "anim/smoke_puff_small.zip"),
}

local prefabs =
{
    "small_puff"
}

local AUDIO_HINT_MIN = 10
local AUDIO_HINT_MAX = 60

local function GetVerb(inst)
    return "INVESTIGATE"
end

local function OnInvestigated(inst, doer)
    local pt = Vector3(inst.Transform:GetWorldPosition())
    trace("dirtpile - OnInvestigated", pt)
	if GetWorld().components.hunter then
		GetWorld().components.hunter:OnDirtInvestigated(pt)
	end

    local fx = SpawnPrefab("small_puff")
    local pos = inst:GetPosition()
    fx.Transform:SetPosition(pos.x, pos.y, pos.z)
    --PlayFX(Vector3(inst.Transform:GetWorldPosition()), "small_puff", "smoke_puff_small", "puff", "dontstarve/common/deathpoof", nil, Vector3(216/255, 154/255, 132/255))
    inst:Remove()
end

local function OnAudioHint(inst)
    trace("dirtpile - OnAudioHint")

    local MainCharacter = GetPlayer()
    local distsq = inst:GetDistanceSqToInst(MainCharacter)
    if distsq > AUDIO_HINT_MIN*AUDIO_HINT_MIN and distsq < AUDIO_HINT_MAX*AUDIO_HINT_MAX then
        trace("    playing hint")
        inst.SoundEmitter:PlaySound("dontstarve/creatures/koalefant/grunt")
    end

    inst:DoTaskInTime(math.random(7, 14), function() OnAudioHint(inst) end)
end

local function create(sim)
    trace("dirtpile - create")

    local inst = CreateEntity()
    inst.entity:AddTransform()
    
    inst:AddTag("dirtpile")
    
    inst.entity:AddAnimState()
    inst.AnimState:SetBank("track")
    inst.AnimState:SetBuild("koalefant_tracks")
    --inst.AnimState:SetOrientation( ANIM_ORIENTATION.OnGround )
    --inst.AnimState:SetLayer( LAYER_BACKGROUND )
    --inst.AnimState:SetSortOrder( 3 )
    inst.AnimState:SetRayTestOnBB(true);
    inst.AnimState:PlayAnimation("idle_pile")

    inst.entity:AddPhysics()
    MakeInventoryPhysics(inst)

    --inst.Transform:SetRotation(math.random(360))
    
    inst:AddComponent("inspectable")
    --inst.components.inspectable.getstatus = GetStatus
    
    inst:AddComponent("activatable")    
    
    -- set required
    inst.components.activatable.OnActivate = OnInvestigated
    inst.components.activatable.inactive = true
    inst.components.activatable.getverb = GetVerb

    -- inst.entity:AddSoundEmitter()
    -- inst:DoTaskInTime(1, function() OnAudioHint(inst) end)

    --inst.persists = false
    return inst
end

return Prefab( "forest/objects/dirtpile", create, assets, prefabs) 
