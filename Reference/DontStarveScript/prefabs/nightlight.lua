local assets =
{
	Asset("ANIM", "anim/nightmare_torch.zip"),
}

local prefabs =
{
    "campfirefire",
    "collapse_small",
    "nightlight_flame",
}    

local function onhammered(inst, worker)
	inst.components.lootdropper:DropLoot()
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_metal")
	inst:Remove()
end

local function onhit(inst, worker)
	inst.AnimState:PlayAnimation("hit")
	inst.AnimState:PushAnimation("idle")
end

local function onextinguish(inst)
    if inst.components.fueled then
        inst.components.fueled:InitializeFuelLevel(0)
    end
end

local function getsanityaura(inst, observer)
    local lightRadius = inst.components.burnable and inst.components.burnable:GetLargestLightRadius()
    if lightRadius and inst:GetDistanceSqToInst(observer) < 0.5*lightRadius then
        return -.05
    end
    return 0
end

local function onbuilt(inst)
	inst.SoundEmitter:PlaySound("dontstarve/common/nightmareAddFuel")
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("idle", false)
end

local function fn(Sim)

	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "nightlight.png" )

    anim:SetBank("nightmare_torch")
    anim:SetBuild("nightmare_torch")
    anim:PlayAnimation("idle",false)
  
    inst:AddTag("structure")
    MakeObstaclePhysics(inst, .1)    

    -----------------------
    inst:AddComponent("burnable")
    inst.components.burnable:AddBurnFX("nightlight_flame", Vector3(0,0,0), "fire_marker")
    inst:ListenForEvent("onextinguish", onextinguish)
    
    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aurafn = getsanityaura
    
    -------------------------
    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)    

    -------------------------
    inst:AddComponent("fueled")
    inst.components.fueled.maxfuel = TUNING.NIGHTLIGHT_FUEL_MAX
    inst.components.fueled.accepting = true
    inst.components.fueled.fueltype = "NIGHTMARE"
    inst.components.fueled:SetSections(4)
    inst.components.fueled.ontakefuelfn = function() inst.SoundEmitter:PlaySound("dontstarve/common/nightmareAddFuel") end
    
    inst.components.fueled:SetUpdateFn( function()
        if inst.components.burnable and inst.components.fueled then
            inst.components.burnable:SetFXLevel(inst.components.fueled:GetCurrentSection(), inst.components.fueled:GetSectionPercent())
        end
    end)
        
    inst.components.fueled:SetSectionCallback( function(section)
        if section == 0 then
            inst.components.burnable:Extinguish() 
        else
            if not inst.components.burnable:IsBurning() then
                inst.components.burnable:Ignite()
            end
            
            inst.components.burnable:SetFXLevel(section, inst.components.fueled:GetSectionPercent())
            
        end
    end)
        
    inst.components.fueled:InitializeFuelLevel(TUNING.NIGHTLIGHT_FUEL_START)
    
    -----------------------------
    
    inst:AddComponent("inspectable")
    
    inst:ListenForEvent( "onbuilt", onbuilt)
    
    return inst
end

return Prefab( "common/objects/nightlight", fn, assets, prefabs),
		MakePlacer( "common/nightlight_placer", "nightmare_torch", "nightmare_torch", "idle" ) 
