local assets=
{
    Asset("ANIM", "anim/sparks.zip"),
}

local prefabs = 
{
    "sparks_fx"
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.persists = false
    
    inst.AnimState:SetBank("sparks")
    inst.AnimState:SetBuild("sparks")
    inst.AnimState:PlayAnimation("sparks_" .. tostring(math.random(3)))
    inst.Transform:SetScale(2,2,2)
    inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )

    inst:AddTag("FX")
    
    inst.Light:Enable(true)
    inst.Light:SetRadius(2)
    inst.Light:SetFalloff(1)
    inst.Light:SetIntensity(.9)
    inst.Light:SetColour(235/255,121/255,12/255)
    
    --local fx = PlayFX(pos, "sparks", "sparks", "sparks_" .. math.random(3))
    local fx = SpawnPrefab("sparks_fx")
    fx.Transform:SetPosition(inst:GetPosition():Get())
    local i = .9

    local dt = 1/20
    local sound = true
    inst:DoPeriodicTask(dt, function() 
        if sound then inst.SoundEmitter:PlaySound("dontstarve/characters/wx78/spark") sound = false end
        inst.Light:SetIntensity(i)
        i =i - dt*2
        --r = r - dt*3
        if i <= 0 then
            inst:Remove()
        end
    end)

    return inst
end

return Prefab( "common/sparks", fn, assets, prefabs) 

