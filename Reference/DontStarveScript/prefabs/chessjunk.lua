require "prefabutil"

local MAXHITS = 6

SetSharedLootTable('chessjunk',
{
    {'trinket_6',       1.0},
    {'trinket_6',       0.55},    
    {'gears',           0.25},
    {'trinket_1',       0.25},
    {'redgem',          0.05},
    {'greengem',        0.05},
    {'yellowgem',       0.05},
    {'purplegem',       0.05},
    {'orangegem',       0.05},
})

SetSharedLootTable('chessjunk_ruins',
{
    {'trinket_6',       1.0},
    {'trinket_6',       0.55},    
    {'gears',           0.25},
    {'trinket_1',       0.25},
    {'redgem',          0.05},
    {'greengem',        0.05},
    {'yellowgem',       0.05},
    {'purplegem',       0.05},
    {'orangegem',       0.05},
    {'thulecite',       0.01},    
})

local function SpawnScion(inst, friendly)
    local spawn = ""
    if inst.style == 1 then
        spawn = (math.random()<.5 and "bishop_nightmare") or "knight_nightmare"
    elseif inst.style == 2 then
        spawn = (math.random()<.3 and "rook_nightmare") or "knight_nightmare"
    else
        spawn = (math.random()<.3 and "rook_nightmare") or "bishop_nightmare"
    end

    SpawnAt("maxwell_smoke",inst)
    local it = SpawnAt(spawn,inst)
    if it and it.components.combat and not friendly then
        it.components.combat:SetTarget(GetPlayer())
    elseif it.components.follower then
        inst.SoundEmitter:PlaySound("dontstarve/common/makeFriend")
        it.components.follower:SetLeader(GetPlayer())
    end
end

local function OnRepaired(inst)
	if inst.components.workable.workleft < MAXHITS then
        inst.SoundEmitter:PlaySound("dontstarve/common/chesspile_repair")
        inst.AnimState:PlayAnimation("hit" .. inst.style )
	    inst.AnimState:PushAnimation("idle" .. inst.style )
    else
	    inst.AnimState:PlayAnimation("hit" .. inst.style )
	    inst.AnimState:PushAnimation("hit" .. inst.style )
        inst.SoundEmitter:PlaySound("dontstarve/common/chesspile_ressurect")
        inst.components.lootdropper:DropLoot()
	    GetPlayer():DoTaskInTime(0.7, function() 
                                        inst.components.lootdropper:AddChanceLoot("gears",     0.1) 
                                        if GetWorld() and GetWorld():IsCave() and GetWorld().topology.level_number == 2 then  -- ruins
                                            inst.components.lootdropper:AddChanceLoot("thulecite", 0.05)
                                        end
                                        inst.components.lootdropper:DropLoot()
                                        SpawnScion(inst, true)
                                        inst:Remove()
                                    end)
    end
end

local function SpawnCritter(critter, pos)
	GetPlayer():DoTaskInTime(GetRandomWithVariance(1,0.8), function() 
	                            GetSeasonManager():DoLightningStrike(pos)
                                SpawnAt("small_puff",pos,{2,2,2})
                                SpawnAt(critter,pos)
                           end)
end

local function OnHammered(inst, worker)
    SpawnAt("collapse_small",inst)
	inst.components.lootdropper:DropLoot()
    if math.random() <= .1 then
        local pt = Vector3(inst.Transform:GetWorldPosition())
        local spawn = ""
        GetSeasonManager():DoLightningStrike(pt)
        SpawnScion(inst)
    else
        inst.SoundEmitter:PlaySound("dontstarve/common/destroy_metal")
    end
	inst:Remove()
end

local function OnHit(inst, worker, workLeft)
	inst.AnimState:PlayAnimation("hit" .. inst.style )
	inst.AnimState:PushAnimation("idle" .. inst.style )
    inst.SoundEmitter:PlaySound("dontstarve/common/lightningrod")
end

local assets = 
{
    Asset("ANIM", "anim/chessmonster_ruins.zip"),
    Asset("MINIMAP_IMAGE", "chessjunk"),
}

local prefabs =
{
    "bishop",
    "rook",
    "knight",
    "gears",
	"redgem", 
	"greengem",
	"yellowgem",
	"purplegem",
	"orangegem",
}    


local function BasePile(Sim)
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()

    anim:SetBank("chessmonster_ruins")
    anim:SetBuild("chessmonster_ruins")

    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon("chessjunk.png")

    MakeObstaclePhysics(inst, 1.2)
    
    inst.entity:AddSoundEmitter()

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("chessjunk")

    if GetWorld() and GetWorld():IsCave() and GetWorld().topology.level_number == 2 then  -- ruins
        inst.components.lootdropper:SetChanceLootTable("chessjunk_ruins")
    end

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(MAXHITS/2)
    inst.components.workable:SetMaxWork(MAXHITS)
    inst.components.workable:SetOnFinishCallback(OnHammered)
    inst.components.workable:SetOnWorkCallback(OnHit)		

    inst:AddComponent("repairable")
    inst.components.repairable.repairmaterial = "gears"
    inst.components.repairable.onrepaired = OnRepaired
    inst:AddTag("chess")
    inst:AddTag("mech")

    inst:AddComponent("inspectable")

	return inst
end

local function Junk(style)
    return function(Sim)
        local inst = BasePile(Sim)

        inst.style = style
        inst.AnimState:PlayAnimation("idle" .. inst.style)

        return inst
    end
end
        
return  Prefab( "common/objects/chessjunk1", Junk(1), assets,prefabs),
        Prefab( "common/objects/chessjunk2", Junk(2), assets,prefabs),
        Prefab( "common/objects/chessjunk3", Junk(3), assets,prefabs)
