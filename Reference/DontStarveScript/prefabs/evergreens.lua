local assets =
{
    Asset("ANIM", "anim/evergreen_new.zip"), --build
    Asset("ANIM", "anim/evergreen_new_2.zip"), --build
    Asset("ANIM", "anim/evergreen_tall_old.zip"),
    Asset("ANIM", "anim/evergreen_short_normal.zip"),
    Asset("ANIM", "anim/dust_fx.zip"),
    Asset("SOUND", "sound/forest.fsb"),
    Asset("MINIMAP_IMAGE", "evergreen_lumpy"),
}

local prefabs =
{
    "log",
    "twigs",
    "pinecone",
    "charcoal",
    "leif",
    "leif_sparse",
    "pine_needles"
}

local builds = 
{
	normal = {
		file="evergreen_new",
		prefab_name="evergreen",
		normal_loot = {"log", "log", "pinecone"},
		short_loot = {"log"},
		tall_loot = {"log", "log", "log", "pinecone", "pinecone"},
		drop_pinecones=true,
		leif="leif",
    },
	sparse = {
		file="evergreen_new_2",
		prefab_name="evergreen_sparse",
		normal_loot = {"log","log"},
		short_loot = {"log"},
		tall_loot = {"log", "log","log"},
		drop_pinecones=false,
		leif="leif_sparse",
    },
}

local function makeanims(stage)
    return {
        idle="idle_"..stage,
        sway1="sway1_loop_"..stage,
        sway2="sway2_loop_"..stage,
        chop="chop_"..stage,
        fallleft="fallleft_"..stage,
        fallright="fallright_"..stage,
        stump="stump_"..stage,
        burning="burning_loop_"..stage,
        burnt="burnt_"..stage,
        chop_burnt="chop_burnt_"..stage,
        idle_chop_burnt="idle_chop_burnt_"..stage
    }
end

local short_anims = makeanims("short")
local tall_anims = makeanims("tall")
local normal_anims = makeanims("normal")
local old_anims =
{
	idle="idle_old",
    sway1="idle_old",
    sway2="idle_old",
    chop="chop_old",
    fallleft="chop_old",
    fallright="chop_old",
    stump="stump_old",
    burning="idle_olds",
    burnt="burnt_tall",
    chop_burnt="chop_burnt_tall",
    idle_chop_burnt="idle_chop_burnt_tall",
}

local function dig_up_stump(inst, chopper)
	inst:Remove()
	inst.components.lootdropper:SpawnLootPrefab("log")
end

local function chop_down_burnt_tree(inst, chopper)
    inst:RemoveComponent("workable")
    inst.SoundEmitter:PlaySound("dontstarve/forest/treeCrumble")          
    inst.SoundEmitter:PlaySound("dontstarve/wilson/use_axe_tree")          
	inst.AnimState:PlayAnimation(inst.anims.chop_burnt)
    RemovePhysicsColliders(inst)
	inst:ListenForEvent("animover", function() inst:Remove() end)
    inst.components.lootdropper:SpawnLootPrefab("charcoal")
    inst.components.lootdropper:DropLoot()
    if inst.pineconetask then
        inst.pineconetask:Cancel()
        inst.pineconetask = nil
    end
end

local function GetBuild(inst)
	local build = builds[inst.build]
	if build == nil then
		return builds["normal"]
	end
	return build
end

local burnt_highlight_override = {.5,.5,.5}
local function OnBurnt(inst, imm)
	
	local function changes()
	    if inst.components.burnable then
		    inst.components.burnable:Extinguish()
		end
		inst:RemoveComponent("burnable")
		inst:RemoveComponent("propagator")
		inst:RemoveComponent("growable")
        inst:RemoveTag("fire")

		inst.components.lootdropper:SetLoot({})
		if GetBuild(inst).drop_pinecones then
			inst.components.lootdropper:AddChanceLoot("pinecone", 0.1)
		end
		
		if inst.components.workable then
			inst.components.workable:SetWorkLeft(1)
			inst.components.workable:SetOnWorkCallback(nil)
			inst.components.workable:SetOnFinishCallback(chop_down_burnt_tree)
		end
	end
		
	if imm then
		changes()
	else
		inst:DoTaskInTime( 0.5, changes)
	end    
	inst.AnimState:PlayAnimation(inst.anims.burnt, true)
    inst.AnimState:SetRayTestOnBB(true);
    inst:AddTag("burnt")

    inst.highlight_override = burnt_highlight_override
end

local function PushSway(inst)
    if math.random() > .5 then
        inst.AnimState:PushAnimation(inst.anims.sway1, true)
    else
        inst.AnimState:PushAnimation(inst.anims.sway2, true)
    end
end

local function Sway(inst)
    if math.random() > .5 then
        inst.AnimState:PlayAnimation(inst.anims.sway1, true)
    else
        inst.AnimState:PlayAnimation(inst.anims.sway2, true)
    end
end

local function SetShort(inst)
    inst.anims = short_anims
    
    if inst.components.workable then
	    inst.components.workable:SetWorkLeft(TUNING.EVERGREEN_CHOPS_SMALL)
	end
		    
    inst.components.lootdropper:SetLoot(GetBuild(inst).short_loot)
    Sway(inst)
end

local function GrowShort(inst)
    inst.AnimState:PlayAnimation("grow_old_to_short")
    inst.SoundEmitter:PlaySound("dontstarve/forest/treeGrowFromWilt")          
    PushSway(inst)
end

local function SetNormal(inst)
    inst.anims = normal_anims
    
    if inst.components.workable then
	    inst.components.workable:SetWorkLeft(TUNING.EVERGREEN_CHOPS_NORMAL)
	end
	
    inst.components.lootdropper:SetLoot(GetBuild(inst).normal_loot)
    Sway(inst)
end

local function GrowNormal(inst)
    inst.AnimState:PlayAnimation("grow_short_to_normal")
    inst.SoundEmitter:PlaySound("dontstarve/forest/treeGrow")          
    PushSway(inst)
end

local function SetTall(inst)
    inst.anims = tall_anims
	if inst.components.workable then
		inst.components.workable:SetWorkLeft(TUNING.EVERGREEN_CHOPS_TALL)
	end
	
    inst.components.lootdropper:SetLoot(GetBuild(inst).tall_loot)
    Sway(inst)
end

local function GrowTall(inst)
    inst.AnimState:PlayAnimation("grow_normal_to_tall")
    inst.SoundEmitter:PlaySound("dontstarve/forest/treeGrow")          
    PushSway(inst)
end

local function SetOld(inst)
    inst.anims = old_anims
	
	if inst.components.workable then
	    inst.components.workable:SetWorkLeft(1)
	end
	
	if GetBuild(inst).drop_pinecones then
		inst.components.lootdropper:SetLoot({"pinecone"})
	else
        inst.components.lootdropper:SetLoot({})
    end

    Sway(inst)
end

local function GrowOld(inst)
    inst.AnimState:PlayAnimation("grow_tall_to_old")
    inst.SoundEmitter:PlaySound("dontstarve/forest/treeWilt")          
    PushSway(inst)
end

local function inspect_tree(inst)
    if inst:HasTag("burnt") then
        return "BURNT"
    elseif inst:HasTag("stump") then
        return "CHOPPED"
    end
end

local growth_stages =
{
    {name="short", time = function(inst) return GetRandomWithVariance(TUNING.EVERGREEN_GROW_TIME[1].base, TUNING.EVERGREEN_GROW_TIME[1].random) end, fn = function(inst) SetShort(inst) end,  growfn = function(inst) GrowShort(inst) end , leifscale=.7 },
    {name="normal", time = function(inst) return GetRandomWithVariance(TUNING.EVERGREEN_GROW_TIME[2].base, TUNING.EVERGREEN_GROW_TIME[2].random) end, fn = function(inst) SetNormal(inst) end, growfn = function(inst) GrowNormal(inst) end, leifscale=1 },
    {name="tall", time = function(inst) return GetRandomWithVariance(TUNING.EVERGREEN_GROW_TIME[3].base, TUNING.EVERGREEN_GROW_TIME[3].random) end, fn = function(inst) SetTall(inst) end, growfn = function(inst) GrowTall(inst) end, leifscale=1.25 },
    {name="old", time = function(inst) return GetRandomWithVariance(TUNING.EVERGREEN_GROW_TIME[4].base, TUNING.EVERGREEN_GROW_TIME[4].random) end, fn = function(inst) SetOld(inst) end, growfn = function(inst) GrowOld(inst) end },
}


local function chop_tree(inst, chopper, chops)
    
    if chopper and chopper.components.beaverness and chopper.components.beaverness:IsBeaver() then
		inst.SoundEmitter:PlaySound("dontstarve/characters/woodie/beaver_chop_tree")          
	else
		inst.SoundEmitter:PlaySound("dontstarve/wilson/use_axe_tree")          
	end

    local fx = SpawnPrefab("pine_needles")
    local x, y, z= inst.Transform:GetWorldPosition()
    fx.Transform:SetPosition(x,y + math.random()*2,z)

    inst.AnimState:PlayAnimation(inst.anims.chop)
    inst.AnimState:PushAnimation(inst.anims.sway1, true)
    
	--tell any nearby leifs to wake up
	local pt = Vector3(inst.Transform:GetWorldPosition())
	local ents = TheSim:FindEntities(pt.x,pt.y,pt.z, TUNING.LEIF_REAWAKEN_RADIUS, {"leif"})
	for k,v in pairs(ents) do
		if v.components.sleeper and v.components.sleeper:IsAsleep() then
			v:DoTaskInTime(math.random(), function() v.components.sleeper:WakeUp() end)
		end
		v.components.combat:SuggestTarget(chopper)
	end
end

local function chop_down_tree(inst, chopper)
    inst:RemoveComponent("burnable")
    MakeSmallBurnable(inst)
    inst:RemoveComponent("propagator")
    MakeSmallPropagator(inst)
    inst:RemoveComponent("workable")
    inst.SoundEmitter:PlaySound("dontstarve/forest/treefall")
    local pt = Vector3(inst.Transform:GetWorldPosition())
    local hispos = Vector3(chopper.Transform:GetWorldPosition())

    local he_right = (hispos - pt):Dot(TheCamera:GetRightVec()) > 0
    
    if he_right then
        inst.AnimState:PlayAnimation(inst.anims.fallleft)
        inst.components.lootdropper:DropLoot(pt - TheCamera:GetRightVec())
    else
        inst.AnimState:PlayAnimation(inst.anims.fallright)
        inst.components.lootdropper:DropLoot(pt + TheCamera:GetRightVec())
    end

    inst:DoTaskInTime(.4, function() 
		local sz = (inst.components.growable and inst.components.growable.stage > 2) and .5 or .25
		GetPlayer().components.playercontroller:ShakeCamera(inst, "FULL", 0.25, 0.03, sz, 6)
    end)
    
    RemovePhysicsColliders(inst)
    inst.AnimState:PushAnimation(inst.anims.stump)
	
	inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetOnFinishCallback(dig_up_stump)
    inst.components.workable:SetWorkLeft(1)
    
    inst:AddTag("stump")
    if inst.components.growable then
        inst.components.growable:StopGrowing()
    end

    inst:AddTag("NOCLICK")
    inst:DoTaskInTime(2, function() inst:RemoveTag("NOCLICK") end)
    
    local days_survived = GetClock().numcycles
    if days_survived >= TUNING.LEIF_MIN_DAY then
		if math.random() <= TUNING.LEIF_PERCENT_CHANCE then
				
			local numleifs = 1
			if days_survived > 30 then
				numleifs = math.random(2)
			elseif days_survived > 80 then
				numleifs = math.random(3)
			end
			
			for k = 1,numleifs do
				
				local target = FindEntity(inst, TUNING.LEIF_MAXSPAWNDIST, 
					function(item) 
						if item.components.growable and item.components.growable.stage <= 3 then
							return item:HasTag("tree") and (not item:HasTag("stump")) and (not item:HasTag("burnt")) and not item.noleif
						end
						return false
					end)
					
				if target  then
					target.noleif = true
					target.leifscale = growth_stages[target.components.growable.stage].leifscale or 1
					target:DoTaskInTime(1 + math.random()*3, function() 
                        if target and not target:HasTag("stump") and not target:HasTag("burnt") and
                            target.components.growable and target.components.growable.stage <= 3 then
    						local target = target
    						if builds[target.build] and builds[target.build].leif then
                                local leif = SpawnPrefab(builds[target.build].leif)
                                if leif then
            						local scale = target.leifscale
            						local r,g,b,a = target.AnimState:GetMultColour()
            						leif.AnimState:SetMultColour(r,g,b,a)
            						
            						--we should serialize this?
            						leif.components.locomotor.walkspeed = leif.components.locomotor.walkspeed*scale
            						leif.components.combat.defaultdamage = leif.components.combat.defaultdamage*scale
            						leif.components.health.maxhealth = leif.components.health.maxhealth*scale
            						leif.components.health.currenthealth = leif.components.health.currenthealth*scale
            						leif.components.combat.hitrange = leif.components.combat.hitrange*scale
            						leif.components.combat.attackrange = leif.components.combat.attackrange*scale
            						
            						leif.Transform:SetScale(scale,scale,scale) 
            						leif.components.combat:SuggestTarget(chopper)
            						leif.sg:GoToState("spawn")
            						target:Remove()
            						
            						leif.Transform:SetPosition(target.Transform:GetWorldPosition())
                                end
                            end
                        end
					end)
				end
			end
		end
    end
end

local function tree_burnt(inst)
	OnBurnt(inst)
	inst.pineconetask = inst:DoTaskInTime(10,
		function()
			local pt = Vector3(inst.Transform:GetWorldPosition())
			if math.random(0, 1) == 1 then
				pt = pt + TheCamera:GetRightVec()
			else
				pt = pt - TheCamera:GetRightVec()
			end
			inst.components.lootdropper:DropLoot(pt)
			inst.pineconetask = nil
		end)
end



local function handler_growfromseed (inst)
	inst.components.growable:SetStage(1)
	inst.AnimState:PlayAnimation("grow_seed_to_short")
    inst.SoundEmitter:PlaySound("dontstarve/forest/treeGrow")          
	PushSway(inst)
end

local function onsave(inst, data)
    if inst:HasTag("burnt") or inst:HasTag("fire") then
        data.burnt = true
    end
    
    if inst:HasTag("stump") then
        data.stump = true
    end

	if inst.build ~= "normal" then
		data.build = inst.build
	end
end
        
local function onload(inst, data)
    if data then
		if not data.build or builds[data.build] == nil then
			inst.build = "normal"
		else
			inst.build = data.build
		end

        if data.burnt then
            inst:AddTag("fire") -- Add the fire tag here: OnEntityWake will handle it actually doing burnt logic
        elseif data.stump then
            inst:RemoveComponent("burnable")
            MakeSmallBurnable(inst)
            inst:RemoveComponent("workable")
            inst:RemoveComponent("propagator")
            MakeSmallPropagator(inst)
            inst:RemoveComponent("growable")
            RemovePhysicsColliders(inst)
            inst.AnimState:PlayAnimation(inst.anims.stump)
            inst:AddTag("stump")
            
    		inst:AddComponent("workable")
    	    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    	    inst.components.workable:SetOnFinishCallback(dig_up_stump)
    	    inst.components.workable:SetWorkLeft(1)
        end
    end
end        

local function OnEntitySleep(inst)
    local fire = false
    if inst:HasTag("fire") then
        fire = true
    end
    inst:RemoveComponent("burnable")
    inst:RemoveComponent("propagator")
    inst:RemoveComponent("inspectable")
    if fire then
        inst:AddTag("fire")
    end
end

local function OnEntityWake(inst)

    if not inst:HasTag("burnt") and not inst:HasTag("fire") then
        if not inst.components.burnable then
            if inst:HasTag("stump") then
                MakeSmallBurnable(inst) 
            else
                MakeLargeBurnable(inst)
                inst.components.burnable:SetFXLevel(5)
                inst.components.burnable:SetOnBurntFn(tree_burnt)
            end
        end

        if not inst.components.propagator then
            if inst:HasTag("stump") then
                MakeSmallPropagator(inst)
            else
                MakeLargePropagator(inst)
            end
        end
    elseif not inst:HasTag("burnt") and inst:HasTag("fire") then
        OnBurnt(inst, true)
    end

    if not inst.components.inspectable then
        inst:AddComponent("inspectable")
        inst.components.inspectable.getstatus = inspect_tree
    end

end

local function makefn(build, stage, data)
	
    local function fn(Sim)
		local l_stage = stage
		if l_stage == 0 then
			l_stage = math.random(1,3)
		end

        local inst = CreateEntity()
        local trans = inst.entity:AddTransform()
        local anim = inst.entity:AddAnimState()
        
        local sound = inst.entity:AddSoundEmitter()

        MakeObstaclePhysics(inst, .25)   

		local minimap = inst.entity:AddMiniMapEntity()
		if build == "normal" then
			minimap:SetIcon("evergreen.png")
		elseif build == "sparse" then
			minimap:SetIcon("evergreen_lumpy.png")
		end
		minimap:SetPriority(-1)
       
        inst:AddTag("tree")
        inst:AddTag("workable")
        
        inst.build = build
        anim:SetBuild(GetBuild(inst).file)
        anim:SetBank("evergreen_short")
        local color = 0.5 + math.random() * 0.5
        anim:SetMultColour(color, color, color, 1)
        
        -------------------        
        MakeLargeBurnable(inst)
        inst.components.burnable:SetFXLevel(5)
        inst.components.burnable:SetOnBurntFn(tree_burnt)
        
        MakeLargePropagator(inst)
        
        -------------------        
        inst:AddComponent("inspectable")
        inst.components.inspectable.getstatus = inspect_tree

        
        -------------------
        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.CHOP)
        inst.components.workable:SetOnWorkCallback(chop_tree)
        inst.components.workable:SetOnFinishCallback(chop_down_tree)
        
        -------------------
        inst:AddComponent("lootdropper") 
        
        ---------------------        
        
        ---------------------        
        inst:AddComponent("growable")
        inst.components.growable.stages = growth_stages
        inst.components.growable:SetStage(l_stage)
        inst.components.growable.loopstages = true
        inst.components.growable:StartGrowing()
        
        inst.growfromseed = handler_growfromseed

        ---------------------        
        --PushSway(inst)
        inst.AnimState:SetTime(math.random()*2)

        ---------------------        
     
        inst.OnSave = onsave 
        inst.OnLoad = onload
        
		MakeSnowCovered(inst, .01)
        ---------------------        

		inst:SetPrefabName( GetBuild(inst).prefab_name )

        if data =="burnt"  then
            OnBurnt(inst)
        end
        
        if data =="stump"  then
            inst:RemoveComponent("burnable")
            MakeSmallBurnable(inst)            
            inst:RemoveComponent("workable")
            inst:RemoveComponent("propagator")
            MakeSmallPropagator(inst)
            inst:RemoveComponent("growable")
            RemovePhysicsColliders(inst)
            inst.AnimState:PlayAnimation(inst.anims.stump)
            inst:AddTag("stump")
            inst:AddComponent("workable")
            inst.components.workable:SetWorkAction(ACTIONS.DIG)
            inst.components.workable:SetOnFinishCallback(dig_up_stump)
            inst.components.workable:SetWorkLeft(1)
        end


        inst.OnEntitySleep = OnEntitySleep
        inst.OnEntityWake = OnEntityWake


        return inst
    end
    return fn
end    

local function tree(name, build, stage, data)
    return Prefab("forest/objects/trees/"..name, makefn(build, stage, data), assets, prefabs)
end

return tree("evergreen", "normal", 0),
		tree("evergreen_normal", "normal", 2),
        tree("evergreen_tall", "normal", 3),
        tree("evergreen_short", "normal", 1),
		tree("evergreen_sparse", "sparse", 0),
		tree("evergreen_sparse_normal", "sparse", 2),
        tree("evergreen_sparse_tall", "sparse", 3),
        tree("evergreen_sparse_short", "sparse", 1),
        tree("evergreen_burnt", "normal", 0, "burnt"),
        tree("evergreen_stump", "normal", 0, "stump") 
