local prefabs =
{
    "spider_dropper",
}

local function SpawnInvestigators(inst, data)
    if inst.components.childspawner then
        local num_to_release = math.min(2, inst.components.childspawner.childreninside)          
        for k = 1,num_to_release do
            local spider = inst.components.childspawner:SpawnChild(data.target, nil, 3)
            if spider then 
                spider.sg:GoToState("dropper_enter")
            end
        end
    end
end

local function fn()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    inst.entity:AddGroundCreepEntity()
    inst.GroundCreepEntity:SetRadius( 5 )
    inst:ListenForEvent("creepactivate", SpawnInvestigators)

    inst:AddTag("spiderden")
    inst:AddComponent("health")

    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon("whitespider_den.png")

    inst:AddComponent( "childspawner" )
    inst.components.childspawner:SetRegenPeriod(120)
    inst.components.childspawner:SetSpawnPeriod(240)
    inst.components.childspawner:SetMaxChildren(math.random(2,3))
    inst.components.childspawner:StartRegen()
    inst.components.childspawner.childname = "spider_dropper"

    return inst
end

return Prefab( "cave/objects/dropperweb", fn, {Asset("MINIMAP_IMAGE", "whitespider_den")},prefabs) 
