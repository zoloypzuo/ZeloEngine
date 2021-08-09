-- plane
-- created on 2021/8/9
-- author @zoloypzuo
local assets = {
    Asset("TEX", "bricks2.jpg");
    Asset("TEX", "bricks2_normal.jpg");
    Asset("TEX", "bricks2_specular.png");
}

local function fn(Sim)
    local inst = CreateEntity()
    inst:AddTag("plane")
    return inst
end

return Prefab("plane", fn, assets)