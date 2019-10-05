local prefabs = 
{
	"bee",
	"killerbee",
    "honey",
    "honeycomb",
}

local assets =
{
    Asset("ANIM", "anim/beehive.zip"),
	Asset("SOUND", "sound/bee.fsb"),
}


local function OnEntityWake(inst)
    inst.SoundEmitter:PlaySound("dontstarve/bee/bee_hive_LP", "loop")
end

local function OnEntitySleep(inst)
	inst.SoundEmitter:KillSound("loop")
end

local function StartSpawning(inst)
	if inst.components.childspawner 
            and (GetSeasonManager() and GetSeasonManager():IsSummer()) 
            and not (inst.components.freezable and inst.components.freezable:IsFrozen()) then
		inst.components.childspawner:StartSpawning()
	end
end

local function StopSpawning(inst)
	if inst.components.childspawner then
		inst.components.childspawner:StopSpawning()
	end
end

local function OnIgnite(inst)
    if inst.components.childspawner then
        inst.components.childspawner:ReleaseAllChildren()
        inst:RemoveComponent("childspawner")
    end
    inst.SoundEmitter:KillSound("loop")
    DefaultBurnFn(inst)
end

local function OnFreeze(inst)
    print(inst, "OnFreeze")
    inst.SoundEmitter:PlaySound("dontstarve/common/freezecreature")
    inst.AnimState:PlayAnimation("frozen", true)
    inst.AnimState:OverrideSymbol("swap_frozen", "frozen", "frozen")

    StopSpawning(inst)
end

local function OnThaw(inst)
    print(inst, "OnThaw")
    inst.AnimState:PlayAnimation("frozen_loop_pst", true)
    inst.SoundEmitter:PlaySound("dontstarve/common/freezethaw", "thawing")
    inst.AnimState:OverrideSymbol("swap_frozen", "frozen", "frozen")
end

local function OnUnFreeze(inst)
    print(inst, "OnUnFreeze")
    inst.AnimState:PlayAnimation("cocoon_small", true)
    inst.SoundEmitter:KillSound("thawing")
    inst.AnimState:ClearOverrideSymbol("swap_frozen")

    StartSpawning(inst)
end

local function OnKilled(inst)
    inst:RemoveComponent("childspawner")
    inst.AnimState:PlayAnimation("cocoon_dead", true)
    inst.Physics:ClearCollisionMask()
    
    inst.SoundEmitter:KillSound("loop")
    
    inst.SoundEmitter:PlaySound("dontstarve/bee/beehive_destroy")
    inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))
end


local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
	
    MakeObstaclePhysics(inst, .5)

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "beehive.png" )

	anim:SetBank("beehive")
	anim:SetBuild("beehive")
	anim:PlayAnimation("cocoon_small", true)

    inst:AddTag("structure")
	inst:AddTag("hive")
    
    -------------------
	inst:AddComponent("health")
    inst.components.health:SetMaxHealth(200)

    -------------------
	inst:AddComponent("childspawner")
	inst.components.childspawner.childname = "bee"
	inst.components.childspawner:SetRegenPeriod(TUNING.BEEHIVE_REGEN_TIME)
	inst.components.childspawner:SetSpawnPeriod(TUNING.BEEHIVE_RELEASE_TIME)
	inst.components.childspawner:SetMaxChildren(TUNING.BEEHIVE_BEES)

    StartSpawning(inst)

    inst:ListenForEvent("dusktime", function() StopSpawning(inst) end, GetWorld())
    inst:ListenForEvent("daytime", function() StartSpawning(inst) end , GetWorld())
	
    ---------------------  
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({"honey","honey","honey","honeycomb"})
    ---------------------  

    ---------------------        
    MakeLargeBurnable(inst)
    inst.components.burnable:SetOnIgniteFn(OnIgnite)
    -------------------
    
    ---------------------
    MakeMediumFreezableCharacter(inst)
    inst:ListenForEvent("freeze", OnFreeze)
    inst:ListenForEvent("onthaw", OnThaw)
    inst:ListenForEvent("unfreeze", OnUnFreeze)
    -------------------

    inst:AddComponent("combat")
    inst.components.combat:SetOnHit(
        function(inst, attacker, damage) 
            if inst.components.childspawner then
                inst.components.childspawner:ReleaseAllChildren(attacker, "killerbee")
            end
            if not inst.components.health:IsDead() then
                inst.SoundEmitter:PlaySound("dontstarve/bee/beehive_hit")
                inst.AnimState:PlayAnimation("cocoon_small_hit")
                inst.AnimState:PushAnimation("cocoon_small", true)
            end
        end)
    inst:ListenForEvent("death", OnKilled)
    
    ---------------------       
    MakeLargePropagator(inst)
    MakeSnowCovered(inst)
    
    ---------------------
    
    inst:AddComponent("inspectable")
	inst.OnEntitySleep = OnEntitySleep
	inst.OnEntityWake = OnEntityWake
    
    
    
	return inst
end

return Prefab( "forest/monsters/beehive", fn, assets, prefabs ) 

