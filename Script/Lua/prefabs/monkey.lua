-- plane
-- created on 2021/8/9
-- author @zoloypzuo
local assets = {
    mesh     = Asset("MESH", "monkey3.obj");
    diffuse  = Asset("TEX", "bricks2.jpg");
    normal   = Asset("TEX", "bricks2_normal.jpg");
    specular = Asset("TEX", "bricks2_specular.png");
}

local function fn()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    inst:AddTag("monkey")
    return inst
end

return Prefab("monkey", fn, assets)
