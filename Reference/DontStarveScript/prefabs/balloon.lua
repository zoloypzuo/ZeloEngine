local assets=
{
    Asset("ANIM", "anim/balloon.zip"),
    Asset("ANIM", "anim/balloon_shapes.zip"),
}

local colours=
{
    {198/255,43/255,43/255},
    {79/255,153/255,68/255},
    {35/255,105/255,235/255},
    {233/255,208/255,69/255},
    {109/255,50/255,163/255},
    {222/255,126/255,39/255},
}

local function onsave(inst, data)
    data.num = inst.balloon_num
    data.colour_idx = inst.colour_idx
end

local function onload(inst, data)
    if data then
        if data.num then
            inst.balloon_num = data.num
            inst.AnimState:OverrideSymbol("swap_balloon", "balloon_shapes", "balloon_" .. tostring(inst.balloon_num))
        end
        
        if data.colour_idx then
            inst.colour_idx = math.min(#colours, data.colour_idx)
            inst.AnimState:SetMultColour(colours[inst.colour_idx][1],colours[inst.colour_idx][2],colours[inst.colour_idx][3],1)
        end
    end
end

local function OnDeath(inst)
    RemovePhysicsColliders(inst)
    inst.AnimState:PlayAnimation("pop")
    inst.SoundEmitter:PlaySound("dontstarve/common/balloon_pop")
    inst.DynamicShadow:Enable(false)
    inst:DoTaskInTime(.1+math.random()*.2, function() 
        inst.components.combat:DoAreaAttack(inst, 2)
    end)
end


local function oncollide(inst, other)
    
    local v1 = Vector3(inst.Physics:GetVelocity())
    local v2 = Vector3(other.Physics:GetVelocity()) 
    if v1:LengthSq() > .1 or v2:LengthSq() > .1 then
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation("idle", true)
        inst.SoundEmitter:PlaySound("dontstarve/common/balloon_bounce")
    end
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    MakeCharacterPhysics(inst, 10, .25)
    inst.Physics:SetFriction(.3)
    inst.Physics:SetDamping(0)
    inst.Physics:SetRestitution(1)
    inst.Physics:SetCollisionCallback(oncollide)

    anim:SetBank("balloon")
    anim:SetBuild("balloon")
    anim:PlayAnimation("idle", true)
    anim:SetTime(math.random()*2)
    anim:SetRayTestOnBB(true);

    inst.balloon_num = math.random(4)
    anim:OverrideSymbol("swap_balloon", "balloon_shapes", "balloon_" .. tostring(inst.balloon_num))
    inst.colour_idx = math.random(#colours)
    anim:SetMultColour(colours[inst.colour_idx][1],colours[inst.colour_idx][2],colours[inst.colour_idx][3],1)
    
    local shadow = inst.entity:AddDynamicShadow()
    shadow:SetSize( 1, .5 )

    inst:AddComponent("inspectable")

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(5)
    inst:ListenForEvent("death", OnDeath)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(1)


	--MakeSmallBurnable(inst, TUNING.MED_BURNTIME)
    inst.OnSave = onsave
    inst.OnLoad = onload
    return inst
end

return Prefab( "common/balloon", fn, assets) 
