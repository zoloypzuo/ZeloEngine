local trace = function() end

local assets=
{
    Asset("ANIM", "anim/koalefant_tracks.zip"),
}

local function OnSave(inst, data)
    trace("animal_track - OnSave")

    data.direction = inst.Transform:GetRotation()
    trace("    direction", data.direction)
end
        
local function OnLoad(inst, data)
    trace("animal_track - OnLoad")

    if data and data.direction then
        trace("    direction", data.direction)
        inst.Transform:SetRotation(data.direction)
    end
end

local function create(sim)
    trace("animal_track - create")
    local inst = CreateEntity()
    inst.entity:AddTransform()
    
    inst:AddTag("track")
    
    inst.entity:AddAnimState()
    inst.AnimState:SetBank("track")
    inst.AnimState:SetBuild("koalefant_tracks")
    inst.AnimState:SetOrientation( ANIM_ORIENTATION.OnGround )
    inst.AnimState:SetLayer( LAYER_BACKGROUND )
    inst.AnimState:SetSortOrder( 3 )
    inst.AnimState:SetRayTestOnBB(true)
    inst.AnimState:PlayAnimation("idle")

    inst.entity:AddPhysics()
    MakeInventoryPhysics(inst)

    --inst.Transform:SetRotation(math.random(360))
    
    inst:AddComponent("inspectable")

    inst:StartThread(
        function ()
            Sleep(30)
            fadeout( inst, 15) 
            inst:Remove() 
        end 
    )

    inst.OnLoad = OnLoad
    inst.OnSave = OnSave

    -- inst:DoTaskInTime(10, function() fadeout(inst, 5) end)
    -- inst:ListenForEvent("fadecomplete", function() inst:Remove() end)

    --inst.persists = false
    return inst
end

return Prefab( "forest/objects/animal_track", create, assets) 
