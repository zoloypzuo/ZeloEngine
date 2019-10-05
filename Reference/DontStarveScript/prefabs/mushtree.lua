--[[
    Prefabs for 3 different mushtrees
--]]

local prefabs =
{
	"log",
	"blue_cap",
    "charcoal",
	"ash",
}

local function tree_burnt(inst)
	inst.persists = false
	inst.AnimState:PlayAnimation("chop_burnt")
	inst.SoundEmitter:PlaySound("dontstarve/forest/treeCrumble")          
	inst:ListenForEvent("animover", function() 
                                        inst.components.lootdropper:SpawnLootPrefab("ash")
                                        if (math.random() < 0.5) then
                                            inst.components.lootdropper:SpawnLootPrefab("charcoal")
                                        end
                                        inst:Remove()
                                    end)
end

local function stump_burnt(inst)
	inst.components.lootdropper:SpawnLootPrefab("ash") 
	inst:Remove() 	
end

local function dig_up_stump(inst)
	inst.components.lootdropper:SpawnLootPrefab("log")
	inst:Remove()
end

local function inspect_tree(inst)
    if inst:HasTag("burnt") then
        return "BURNT"
    elseif inst:HasTag("stump") then
        return "CHOPPED"
    end
end


local function makestump(inst)
    inst:RemoveComponent("burnable")
    inst:RemoveComponent("propagator")
    inst:RemoveComponent("workable")
	RemovePhysicsColliders(inst) 
	inst:AddTag("stump")
	MakeSmallPropagator(inst)
	MakeSmallBurnable(inst)
	inst.components.burnable:SetOnBurntFn(stump_burnt)	
    
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetOnFinishCallback(dig_up_stump)
	inst.components.workable:SetWorkLeft(1)
	inst.AnimState:PlayAnimation("idle_stump")
	inst.AnimState:ClearBloomEffectHandle()

	inst.Light:Enable(false)	
end

local function workcallback(inst, worker, workleft)
	local pt = Point(inst.Transform:GetWorldPosition())
    inst.SoundEmitter:PlaySound("dontstarve/wilson/use_axe_mushroom")          
	if workleft <= 0 then
		inst.SoundEmitter:PlaySound("dontstarve/forest/treefall")
		makestump(inst)
	    
        inst.AnimState:PlayAnimation("fall")

		inst.components.lootdropper:DropLoot(pt)
		inst.AnimState:PushAnimation("idle_stump")

	else			
		inst.AnimState:PlayAnimation("chop")
		inst.AnimState:PushAnimation("idle_loop", true)
	end
end

local loot = {
        small  = {"log", "green_cap"},
        medium = {"log", "red_cap"},
        tall   = {"log", "log", "blue_cap"},
        }


local function onsave(inst, data)
    if inst:HasTag("burnt") or inst:HasTag("fire") then
        data.burnt = true
    end
    
    if inst:HasTag("stump") then
        data.stump = true
    end
end
        
local function onload(inst, data)
    if data then

        if data.burnt then
            if data.stump then
            	stump_burnt(inst)
            else
            	tree_burnt(inst)
            end
        elseif data.stump then
        	makestump(inst)
        end
    end
end        

--[[
    Really should make these into one parameterized function - drf
--]]
--
local function tallfn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	
	MakeLargePropagator(inst)
	MakeLargeBurnable(inst)
    inst.components.burnable:SetFXLevel(5)
    inst.components.burnable:SetOnBurntFn(tree_burnt)

    local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon("mushroom_tree.png")
	MakeObstaclePhysics(inst, 1)

	anim:SetBuild("mushroom_tree_tall")
	anim:SetBank("mushroom_tree")
	anim:PlayAnimation("idle_loop", true)
	inst.AnimState:SetTime(math.random()*2)    
	
	inst:AddComponent("lootdropper") 
	    inst.components.lootdropper:SetLoot(loot.tall)
	inst:AddComponent("inspectable")
        inst.components.inspectable.getstatus = inspect_tree
	inst:AddComponent("workable")
	    inst.components.workable:SetWorkAction(ACTIONS.CHOP)
	    inst.components.workable:SetWorkLeft(TUNING.MUSHTREE_CHOPS_TALL)
	    inst.components.workable:SetOnWorkCallback(workcallback)

	--inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )

    local light = inst.entity:AddLight()
	light:SetFalloff(0.5)
	light:SetIntensity(.8)
	light:SetRadius(1.5)
	light:SetColour(111/255, 111/255, 227/255)
    light:Enable(true)

	inst.OnSave = onsave
	inst.OnLoad = onload
	return inst
end

local function mediumfn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	
	MakeLargePropagator(inst)
	MakeLargeBurnable(inst)
    inst.components.burnable:SetFXLevel(5)
    inst.components.burnable:SetOnBurntFn(tree_burnt)

    local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon("mushroom_tree_med.png")
	MakeObstaclePhysics(inst, 1)

	anim:SetBuild("mushroom_tree_med")
	anim:SetBank("mushroom_tree_med")
	anim:PlayAnimation("idle_loop", true)
	inst.AnimState:SetTime(math.random()*2) 
	
	inst:AddComponent("lootdropper") 
	    inst.components.lootdropper:SetLoot(loot.medium)
	inst:AddComponent("inspectable")
        inst.components.inspectable.getstatus = inspect_tree
	inst:AddComponent("workable")
	    inst.components.workable:SetWorkAction(ACTIONS.CHOP)
	    inst.components.workable:SetWorkLeft(TUNING.MUSHTREE_CHOPS_MEDIUM)
	    inst.components.workable:SetOnWorkCallback(workcallback)

	--inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )

    local light = inst.entity:AddLight()
	light:SetFalloff(0.5)
	light:SetIntensity(.8)
	light:SetRadius(1.25)
	light:SetColour(197/255, 126/255, 126/255)
    light:Enable(true)

	inst.OnSave = onsave
	inst.OnLoad = onload
	return inst
end


local function smallfn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	
	MakeLargePropagator(inst)
	MakeLargeBurnable(inst)
    inst.components.burnable:SetFXLevel(5)
    inst.components.burnable:SetOnBurntFn(tree_burnt)

    local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon("mushroom_tree_small.png")
	MakeObstaclePhysics(inst, 1)

	anim:SetBuild("mushroom_tree_small")
	anim:SetBank("mushroom_tree_small")
	anim:PlayAnimation("idle_loop", true)
	inst.AnimState:SetTime(math.random()*2)    
	
	inst:AddComponent("lootdropper") 
	    inst.components.lootdropper:SetLoot(loot.small)
	inst:AddComponent("inspectable")
        inst.components.inspectable.getstatus = inspect_tree
	inst:AddComponent("workable")
	    inst.components.workable:SetWorkAction(ACTIONS.CHOP)
	    inst.components.workable:SetWorkLeft(TUNING.MUSHTREE_CHOPS_SMALL)
	    inst.components.workable:SetOnWorkCallback(workcallback)

	-- inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )

    local light = inst.entity:AddLight()
	light:SetFalloff(0.5)
	light:SetIntensity(.8)
	light:SetRadius(1.0)
	light:SetColour(146/255, 225/255, 146/255)
    light:Enable(true)

	inst.OnSave = onsave
	inst.OnLoad = onload
	return inst
end

return Prefab("cave/objects/mushtree_tall", tallfn, { Asset("ANIM", "anim/mushroom_tree_tall.zip"), Asset("MINIMAP_IMAGE", "mushroom_tree"), }, prefabs),
       Prefab("cave/objects/mushtree_medium", mediumfn, { Asset("ANIM", "anim/mushroom_tree_med.zip"), Asset("MINIMAP_IMAGE", "mushroom_tree_med"), }, prefabs),
       Prefab("cave/objects/mushtree_small", smallfn, { Asset("ANIM", "anim/mushroom_tree_small.zip"), Asset("MINIMAP_IMAGE", "mushroom_tree_small"), }, prefabs) 

