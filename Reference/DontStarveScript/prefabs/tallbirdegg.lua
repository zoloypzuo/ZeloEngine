local assets=
{
	Asset("ANIM", "anim/tallbird_egg.zip"),
}

local prefabs = 
{
	"smallbird",
	"tallbirdegg_cracked",
	"tallbirdegg_cooked",
	"spoiled_food",
}

local loot_hot = 
{
    "cookedsmallmeat",
}

local loot_cold = 
{
    "wetgoop",
}

local function Hatch(inst)
    --print("tallbirdegg - Hatch")
   
    local smallbird = SpawnPrefab("smallbird")
    smallbird.Transform:SetPosition(inst.Transform:GetWorldPosition())
    smallbird.sg:GoToState("hatch")

    inst:Remove()
end

local function CheckHatch(inst)
    --print("tallbirdegg - CheckHatch")
    if inst.playernear and inst.components.hatchable.state == "hatch" then
        Hatch(inst)
    end
end

local function PlayUncomfySound(inst)
    inst.SoundEmitter:KillSound("uncomfy")
    if inst.components.hatchable.toohot then
        inst.SoundEmitter:PlaySound("dontstarve/creatures/egg/egg_hot_steam_LP", "uncomfy")
    elseif inst.components.hatchable.toocold then
        inst.SoundEmitter:PlaySound("dontstarve/creatures/egg/egg_cold_shiver_LP", "uncomfy")
    end
end

local function OnNear(inst)
    --print("tallbirdegg - OnNear")
    inst.playernear = true
    CheckHatch(inst)
end

local function OnFar(inst)
    --print("tallbirdegg - OnFar")
    inst.playernear = false
end

local function OnDropped(inst)
    --print("tallbirdegg - OnDropped")
    inst.components.hatchable:StartUpdating()
    CheckHatch(inst)
    PlayUncomfySound(inst)
end

local function OnPutInInventory(inst)
    --print("tallbirdegg - OnPutInInventory")
    inst.components.hatchable:StopUpdating()
    inst.SoundEmitter:KillSound("uncomfy")
end

local function GetStatus(inst)
    if inst.components.hatchable then
        local state = inst.components.hatchable.state
        if state == "uncomfy" then
            if inst.components.hatchable.toohot then
                return "HOT"
            elseif inst.components.hatchable.toocold then
                return "COLD"
            end
        end
    end
end

local function DropLoot(inst)
    --print("tallbirdegg - DropLoot")
    
    inst:AddComponent("lootdropper")
    if inst.components.hatchable.toohot then
        inst.components.lootdropper:SetLoot(loot_hot)
    else
        inst.components.lootdropper:SetLoot(loot_cold)
    end
    inst.components.lootdropper:DropLoot()
end

local function OnHatchState(inst, state)
    --print("tallbirdegg - OnHatchState", state)
    
    inst.SoundEmitter:KillSound("uncomfy")

    if state == "crack" then
        local cracked = SpawnPrefab("tallbirdegg_cracked")
        cracked.Transform:SetPosition(inst.Transform:GetWorldPosition())
        cracked.AnimState:PlayAnimation("crack")
        cracked.AnimState:PushAnimation("idle_happy", true)
        cracked.SoundEmitter:PlaySound("dontstarve/creatures/egg/egg_hatch_crack")
        inst:Remove()
    elseif state == "uncomfy" then
        if inst.components.hatchable.toohot then
            inst.AnimState:PlayAnimation("idle_hot", true)
        elseif inst.components.hatchable.toocold then
            inst.AnimState:PlayAnimation("idle_cold", true)
        end
        PlayUncomfySound(inst)
    elseif state == "comfy" then
        inst.AnimState:PlayAnimation("idle_happy", true)
    elseif state == "hatch" then
        CheckHatch(inst)
    elseif state == "dead" then
        --print("   ACK! *splat*")
        if inst.components.hatchable.toohot then
            inst.SoundEmitter:PlaySound("dontstarve/creatures/egg/egg_hot_jump")
            inst:DoTaskInTime(20*FRAMES, function() inst.SoundEmitter:PlaySound("dontstarve/creatures/egg/egg_hot_explo") end)
            inst:DoTaskInTime(20*FRAMES, DropLoot)
            inst.AnimState:PlayAnimation("toohot")
        elseif inst.components.hatchable.toocold then
            inst:DoTaskInTime(15*FRAMES, function() inst.SoundEmitter:PlaySound("dontstarve/creatures/egg/egg_cold_freeze") end)
            inst:DoTaskInTime(30*FRAMES, DropLoot)
            inst.AnimState:PlayAnimation("toocold")
        end
        
        inst:ListenForEvent("animover", function(inst) inst:Remove() end)
    end
end

local function OnEaten(inst, eater)
    if eater.components.talker then
        eater.components.talker:Say( GetString(eater.prefab, "EAT_FOOD", "TALLBIRDEGG_CRACKED") )
    end
end


local function commonfn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    
    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBuild("tallbird_egg")
    inst.AnimState:SetBank("egg")
    inst.AnimState:PlayAnimation("egg")
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")

    inst:AddComponent("edible")

    inst:AddTag("cattoy")
    inst:AddComponent("tradable")
    
    return inst
end

local function defaultfn()
	local inst = commonfn()

	inst.entity:AddSoundEmitter()

    inst.AnimState:PlayAnimation("egg")
    inst.components.edible.healthvalue = TUNING.HEALING_SMALL
    inst.components.edible.hungervalue = TUNING.CALORIES_MED

    inst:AddComponent("hatchable")
    inst.components.hatchable:SetOnState(OnHatchState)
    inst.components.hatchable:SetCrackTime(TUNING.SMALLBIRD_HATCH_CRACK_TIME)
    inst.components.hatchable:SetHatchTime(TUNING.SMALLBIRD_HATCH_TIME)
    inst.components.hatchable:SetHatchFailTime(TUNING.SMALLBIRD_HATCH_FAIL_TIME)
    inst.components.hatchable:StartUpdating()

    inst:AddComponent("cookable")
    inst.components.cookable.product = "tallbirdegg_cooked"

    inst.components.inventoryitem:SetOnDroppedFn(OnDropped)
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)

    inst.components.inspectable.getstatus = GetStatus

    inst.playernear = false

	return inst
end

local function crackedfn()
    local inst = defaultfn()
    
    inst.components.hatchable.state = "comfy"
    inst.AnimState:PlayAnimation("idle_happy")

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(4, 6)
    inst.components.playerprox:SetOnPlayerNear(OnNear)
    inst.components.playerprox:SetOnPlayerFar(OnFar)
    
    inst.components.edible:SetOnEatenFn(OnEaten)

    return inst
end

local function cookedfn()
	local inst = commonfn()
    
    inst:AddComponent("stackable")

    inst.AnimState:PlayAnimation("cooked")
    inst.components.edible.healthvalue = 0
    inst.components.edible.hungervalue = TUNING.CALORIES_LARGE
    
	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
	inst.components.perishable:StartPerishing()
    inst.components.edible.foodstate = "COOKED"
	inst.components.perishable.onperishreplacement = "spoiled_food"
    
	return inst
end


return Prefab( "common/inventory/tallbirdegg", defaultfn, assets, prefabs),
		Prefab( "common/inventory/tallbirdegg_cracked", crackedfn, assets),
		Prefab( "common/inventory/tallbirdegg_cooked", cookedfn, assets) 
