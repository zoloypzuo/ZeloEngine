local assets=
{
	Asset("ANIM", "anim/shadow_creatures_ground.zip"),
}

local function Disappear(inst)
    if inst.deathtask then
        inst.deathtask:Cancel()
        inst.deathtask = nil
    end
    inst.AnimState:PushAnimation("watcher_pst", false)
    inst:ListenForEvent("animqueueover", function() inst:Remove() end)
end

local function FindLight(inst)
    local light = FindEntity(inst, 40, function(ent)
        return ent.Light
               and ent.Light:IsEnabled()
    end)
    if light then
        if inst.lighttask then
            inst.lighttask:Cancel()
            inst.lighttask = nil
        end
        inst:FacePoint(Vector3(light.Transform:GetWorldPosition() ) )
    end
end



local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddLightWatcher()
    inst.LightWatcher:SetLightThresh(.2)
    inst.LightWatcher:SetDarkThresh(.19)
    
    inst.AnimState:SetBank("shadowcreatures")
    inst.AnimState:SetBuild("shadow_creatures_ground")
	inst.AnimState:SetOrientation( ANIM_ORIENTATION.OnGround )
	inst.AnimState:SetLayer( LAYER_BACKGROUND )
	inst.AnimState:SetSortOrder( 3 )
    inst.AnimState:PlayAnimation("watcher_pre")
    inst.AnimState:PushAnimation("watcher_loop", true)
    inst.AnimState:SetMultColour(1, 1, 1, 0.5)
    
    inst.deathtask = inst:DoTaskInTime(5 + 10*math.random(), Disappear)
    inst:ListenForEvent("enterlight", Disappear) 
    inst.lighttask = inst:DoPeriodicTask(1, FindLight, 1*FRAMES)
    
    inst.persists = false
 
return inst
end

return Prefab( "common/shadowwatcher", fn, assets) 
