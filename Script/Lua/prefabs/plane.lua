-- plane
-- created on 2021/8/9
-- author @zoloypzuo
local assets = {
    mesh_gen = "plane";
    diffuse  = "bricks2";
    normal   = "bricks2_normal";
    specular = "bricks2_specular";
}

local function fn()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    inst:AddTag("plane")
    return inst
end

return Prefab("plane", fn, assets)
