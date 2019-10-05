local assets =
{
	Asset("ANIM", "anim/slurtle_mound.zip"),
    Asset("MINIMAP_IMAGE", "slurtle_den"),
}

local prefabs =
{
	"slurtle",
	"snurtle",
	"slurtleslime",
	"slurtle_shellpieces",
    "explode_small"
}

local function OnEntityWake(inst)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/slurtle/mound_LP", "loop")
end

local function OnEntitySleep(inst)
    inst.SoundEmitter:KillSound("loop")
end

local function ReturnChildren(inst)
	for k,child in pairs(inst.components.childspawner.childrenoutside) do
		if child.components.homeseeker then
			child.components.homeseeker:GoHome()
		end
		child:PushEvent("gohome")
	end
end

local function OnKilled(inst)
    inst:RemoveComponent("childspawner")
    inst.AnimState:PlayAnimation("break")
    inst.AnimState:PushAnimation("idle_broken")
    inst.Physics:ClearCollisionMask()
    inst:DoTaskInTime(0.66, function()
        inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))
        inst.SoundEmitter:PlaySound("dontstarve/creatures/slurtle/mound_explode") 
    end)
end

local function OnIgniteFn(inst)
	inst.AnimState:PlayAnimation("shake", true)
    inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_fuse_LP", "hiss")
    if inst.components.childspawner then
        inst.components.childspawner:ReleaseAllChildren()
        inst:RemoveComponent("childspawner")
    end
end

local function OnExplodeFn(inst)
    local pos = Vector3(inst.Transform:GetWorldPosition())
    inst.SoundEmitter:KillSound("hiss")
    inst.SoundEmitter:PlaySound("dontstarve/creatures/slurtle/mound_explode")
    local explode = SpawnPrefab("explode_small")
    local pos = inst:GetPosition()
    explode.Transform:SetPosition(pos.x, pos.y, pos.z)
    explode.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )
    explode.AnimState:SetLightOverride(1)
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    MakeObstaclePhysics( inst, 2)

    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon("slurtle_den.png")

    anim:SetBuild("slurtle_mound")
    anim:SetBank("slurtle_mound")
    anim:PlayAnimation("idle", true)
    inst:AddTag("hostile")

	inst:AddComponent( "childspawner" )
	inst.components.childspawner:SetRegenPeriod(120)
	inst.components.childspawner:SetSpawnPeriod(3)
	inst.components.childspawner:SetMaxChildren(math.random(1,2))
	inst.components.childspawner:StartRegen()
	inst.components.childspawner.childname = "slurtle"
	inst.components.childspawner:SetRareChild("snurtle", 0.1)

	inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetLoot({"slurtleslime","slurtleslime","slurtleslime","slurtle_shellpieces"})

	inst:AddComponent("health")
    inst.components.health:SetMaxHealth(350)

	inst:AddComponent("combat")
    inst.components.combat:SetOnHit(
    function(inst, attacker, damage) 
        if inst.components.childspawner then
            inst.components.childspawner:SpawnChild(attacker)
        end
        if not inst.components.health:IsDead() then
            --inst.SoundEmitter:PlaySound("dontstarve/bee/beehive_hit")
            inst.AnimState:PlayAnimation("hit")
            inst.AnimState:PushAnimation("idle", true)
        end
    end)

    inst:ListenForEvent("death", OnKilled)

	--inst:ListenForEvent("startquake", function()  end, GetWorld())
	inst:ListenForEvent("endquake", function() 
        if inst.components.childspawner then
    		inst.components.childspawner:StartSpawning()
    		inst:DoTaskInTime(15, 
    			function()
					if inst.components.childspawner then
    					inst.components.childspawner:StopSpawning()
    				end
    			end)
		end 
        end, GetWorld())

    inst:AddComponent("inspectable")

    MakeLargeBurnable(inst)

    inst:AddComponent("explosive")
    inst.components.explosive:SetOnExplodeFn(OnExplodeFn)
    inst.components.explosive:SetOnIgniteFn(OnIgniteFn)
    inst.components.explosive.explosivedamage = 50
    inst.components.explosive.buildingdamage = 15
    inst.components.explosive.lightonexplode = false

    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake

	return inst
end

return Prefab( "cave/objects/slurtlehole", fn, assets, prefabs) 
