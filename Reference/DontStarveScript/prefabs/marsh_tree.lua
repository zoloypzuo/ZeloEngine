local assets =
{
    Asset("ANIM", "anim/tree_marsh.zip"),
    Asset("MINIMAP_IMAGE", "marshtree"),
}

local prefabs =
{
    "log",
    "twigs",
    "charcoal",
}

SetSharedLootTable( 'marsh_tree',
{
    {'twigs',  1.0},
    {'log',    0.2},
})

local function sway(inst)
    inst.AnimState:PushAnimation("sway"..math.random(4).."_loop", true)
end

local function chop_tree(inst, chopper, chops)
    inst.SoundEmitter:PlaySound("dontstarve/wilson/use_axe_tree")          
    inst.AnimState:PlayAnimation("chop")
    sway(inst)
end

local function set_stump(inst)
    inst:RemoveComponent("workable")
    inst:RemoveComponent("burnable")
    inst:RemoveComponent("propagator")
    RemovePhysicsColliders(inst)
    inst:AddTag("stump")
end

local function dig_up_stump(inst, chopper)
    inst:Remove()
    inst.components.lootdropper:SpawnLootPrefab("log")
end


local function chop_down_tree(inst, chopper)
    inst.SoundEmitter:PlaySound("dontstarve/forest/treeCrumble")          
    inst.SoundEmitter:PlaySound("dontstarve/wilson/use_axe_tree")
    inst.AnimState:PlayAnimation("fall")
    inst.AnimState:PushAnimation("stump", false)
    set_stump(inst)
    inst.components.lootdropper:DropLoot()
    
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetOnFinishCallback(dig_up_stump)
    inst.components.workable:SetWorkLeft(1)
end

local function chop_down_burnt_tree(inst, chopper)
    inst.SoundEmitter:PlaySound("dontstarve/forest/treeCrumble")          
    inst.SoundEmitter:PlaySound("dontstarve/wilson/use_axe_tree")          
    inst.AnimState:PlayAnimation("burnt_chop")
    set_stump(inst)
    inst.Physics:ClearCollisionMask()
    inst:ListenForEvent("animover", function() inst:Remove() end)
    inst.components.lootdropper:DropLoot()
end


local function OnBurnt(inst)
    inst:RemoveComponent("burnable")
    inst:RemoveComponent("propagator")
    
    inst.components.lootdropper:SetLoot({"charcoal"})
    
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnWorkCallback(nil)
    inst.components.workable:SetOnFinishCallback(chop_down_burnt_tree)
    inst.AnimState:PlayAnimation("burnt_idle", true)
    inst:AddTag("burnt")
end

local function tree_burnt(inst)
    OnBurnt(inst)
end

local function inspect_tree(inst)
    if inst:HasTag("burnt") then
        return "BURNT"
    elseif inst:HasTag("stump") then
        return "CHOPPED"
    elseif inst.components.burnable and inst.components.burnable:IsBurning() then
        return "BURNING"
    end
end

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
            OnBurnt(inst)
        elseif data.stump then
            inst:RemoveComponent("workable")
            inst:RemoveComponent("burnable")
            inst:RemoveComponent("propagator")
            inst:RemoveComponent("growable")
            RemovePhysicsColliders(inst)
            inst.AnimState:PlayAnimation("stump", false)
            inst:AddTag("stump")
            
            inst:AddComponent("workable")
            inst.components.workable:SetWorkAction(ACTIONS.DIG)
            inst.components.workable:SetOnFinishCallback(dig_up_stump)
            inst.components.workable:SetWorkLeft(1)
        end
    end
end   

local function fn(Sim)
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    local shadow = inst.entity:AddDynamicShadow()
    local sound = inst.entity:AddSoundEmitter()

    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon( "marshtree.png" )
    minimap:SetPriority(-1)

    MakeObstaclePhysics(inst, .25)   
    inst:AddTag("tree")

    MakeLargeBurnable(inst)
    inst.components.burnable:SetOnBurntFn(tree_burnt)
    MakeSmallPropagator(inst)
    
    inst:AddComponent("lootdropper") 
    inst.components.lootdropper:SetChanceLootTable('marsh_tree')
    
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.CHOP)
    inst.components.workable:SetWorkLeft(10)
    inst.components.workable:SetOnWorkCallback(chop_tree)
    inst.components.workable:SetOnFinishCallback(chop_down_tree)

    anim:SetBuild("tree_marsh")
    anim:SetBank("marsh_tree")
    local color = 0.5 + math.random() * 0.5
    anim:SetMultColour(color, color, color, 1)
    sway(inst)
    anim:SetTime(math.random()*2)
    
    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = inspect_tree
    
    inst.OnSave = onsave
    inst.OnLoad = onload
    MakeSnowCovered(inst, .01)
    return inst
end

return Prefab( "marsh/objects/marsh_tree", fn, assets) 