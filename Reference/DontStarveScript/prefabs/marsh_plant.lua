local assets =
{
	Asset("ANIM", "anim/marsh_plant.zip"),
    Asset("ANIM", "anim/pond_plant_cave.zip")
}

local function fn(bank, build)
    local func = function()
    	local inst = CreateEntity()
    	local trans = inst.entity:AddTransform()
    	local anim = inst.entity:AddAnimState()

        MakeMediumBurnable(inst)
        MakeSmallPropagator(inst)

        anim:SetBank(bank)
        anim:SetBuild(build)
        
        anim:PlayAnimation("idle")
        
        inst:AddComponent("inspectable")
        return inst
    end
    return func
end

return Prefab( "marsh/objects/marsh_plant", fn("marsh_plant", "marsh_plant"), assets),
Prefab("cave/objects/pond_algae", fn("pond_rock", "pond_plant_cave"), assets)
