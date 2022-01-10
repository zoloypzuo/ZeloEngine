-- grid.lua
-- created on 2022/1/10
-- author @zoloypzuo
local CreateEntity = CreateEntity
local LoadResource = LoadResource
local Prefab = Prefab

local assets = {
}

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst:AddTag("grid")

    inst.entity:AddGridRenderer()
    return inst
end

return Prefab("grid", fn, assets)
