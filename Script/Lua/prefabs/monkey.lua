-- plane
-- created on 2021/8/9
-- author @zoloypzuo
local assets = {
    mesh = Asset("MESH", "monkey3.obj");
}

local function fn()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    inst:AddTag("monkey")
    return inst
end

return Prefab("monkey", fn, assets)
