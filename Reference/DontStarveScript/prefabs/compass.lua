local assets=
{
	Asset("ANIM", "anim/compass.zip"),
}

local function GetDirection()
    
    
    local heading = TheCamera:GetHeading()--inst.Transform:GetRotation() 
    local dirs = 
    {
        N=0, S=180,
        NE=45, E=90, SE=135,
        NW=-45, W=-90, SW=-135, 
    }
    local dir, closest_diff = nil, nil

    for k,v in pairs(dirs) do
        local diff = math.abs(anglediff(heading, v))
        if not dir or diff < closest_diff then
            dir, closest_diff = k, diff
        end
    end
    return dir
end


local function GetStatus(inst, viewer)
    return GetDirection()
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    anim:SetBank("compass")
    anim:SetBuild("compass")
    anim:PlayAnimation("idle")
    
    MakeInventoryPhysics(inst)
    
    inst:AddComponent("inventoryitem")
    inst:AddComponent("inspectable")
    --inst.components.inspectable.noanim = true
    inst.components.inspectable.getstatus = GetStatus
    
    return inst
end

return Prefab( "common/inventory/compass", fn, assets)
