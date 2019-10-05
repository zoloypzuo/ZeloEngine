require "brains/butterflybrain"
require "stategraphs/SGbutterfly"

local assets=
{
	Asset("ANIM", "anim/butterfly_basic.zip"),
}
    
local prefabs =
{
    "butterflywings",
    "butter",
    "flower",
}

local function TrackInSpawner(inst)
    local ground = GetWorld()
    if ground and ground.components.butterflyspawner then
        ground.components.butterflyspawner:StartTracking(inst)
    end
end

local function StopTrackingInSpawner(inst)
    local ground = GetWorld()
    if ground and ground.components.butterflyspawner then
        ground.components.butterflyspawner:StopTracking(inst)
    end
end

local function OnDropped(inst)
    inst.sg:GoToState("idle")
    TrackInSpawner(inst)
    if inst.components.workable then
        inst.components.workable:SetWorkLeft(1)
    end
	if inst.components.stackable then
	    while inst.components.stackable:StackSize() > 1 do
	        local item = inst.components.stackable:Get()
	        if item then
	            if item.components.inventoryitem then
	                item.components.inventoryitem:OnDropped()
	            end
	            item.Physics:Teleport(inst.Transform:GetWorldPosition() )
	        end
	    end
	end
end

local function OnPickedUp(inst)
    StopTrackingInSpawner(inst)
end

local function OnWorked(inst, worker)
    if worker.components.inventory then
        StopTrackingInSpawner(inst)
        worker.components.inventory:GiveItem(inst, nil, Vector3(TheSim:GetScreenPos(inst.Transform:GetWorldPosition())))
        worker.SoundEmitter:PlaySound("dontstarve/common/butterfly_trap")
    end
end


local function CanDeploy(inst) return true end

local function OnDeploy (inst, pt) 
    local flower = SpawnPrefab("flower")
    if flower then
        flower:PushEvent("growfrombutterfly")
		flower.Transform:SetPosition(pt.x, pt.y, pt.z)
        inst.components.stackable:Get():Remove()
    end
end

local function fn(Sim)
	local inst = CreateEntity()
	
    inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    inst.Transform:SetTwoFaced()
	inst.entity:AddDynamicShadow()
	inst.DynamicShadow:SetSize( .8, .5 )
    
    
    ----------
    
    inst:AddTag("butterfly")
    inst:AddTag("insect")
    inst:AddTag("smallcreature")
   
    MakeCharacterPhysics(inst, 1, .25)
    inst.Physics:SetCollisionGroup(COLLISION.FLYERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    
    
    inst.AnimState:SetBuild("butterfly_basic")
    inst.AnimState:SetBank("butterfly")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetRayTestOnBB(true);
    
    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor:EnableGroundSpeedMultiplier(false)
	inst.components.locomotor:SetTriggersCreep(false)
    inst:SetStateGraph("SGbutterfly")
    
    ---------------------       
    inst:AddComponent("inventoryitem")
    inst:AddComponent("stackable")
    inst.components.inventoryitem:SetOnDroppedFn(OnDropped)
    inst.components.inventoryitem:SetOnPickupFn(OnPickedUp)
	inst.components.inventoryitem.canbepickedup = false
	inst.components.inventoryitem.nobounce = true
    
    ------------------
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(1)


	inst:AddComponent("pollinator")
    ------------------
    
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "butterfly_body"
    ------------------

    inst:AddComponent("knownlocations")

    ------------------
    MakeSmallBurnableCharacter(inst, "butterfly_body")
    MakeTinyFreezableCharacter(inst, "butterfly_body")
    
    inst:AddComponent("inspectable")
    ------------------
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:AddRandomLoot("butter", 0.1)
    inst.components.lootdropper:AddRandomLoot("butterflywings", 5)   
    inst.components.lootdropper.numrandomloot = 1
    ------------------
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.NET)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(OnWorked)
    ------------------
    inst:AddComponent("deployable")
    inst.components.deployable.ondeploy = OnDeploy

    local brain = require "brains/butterflybrain"
    inst:SetBrain(brain)

    inst:ListenForEvent("onremove", StopTrackingInSpawner)

    return inst
end

return Prefab( "forest/common/butterfly", fn, assets, prefabs),
       MakePlacer("common/butterfly_placer", "flowers", "flowers", "f1" ) 
