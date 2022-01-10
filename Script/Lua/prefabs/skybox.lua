-- skybox.lua
-- created on 2022/1/10
-- author @zoloypzuo
local CreateEntity = CreateEntity
local LoadResource = LoadResource
local Prefab = Prefab

local assets = {
    envMap = "immenstadter_horn_2k.hdr";
    envMapIrradiance = "immenstadter_horn_2k_irradiance.hdr";
    brdfLUTFileName = "brdfLUT.ktx";
}

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst:AddTag("skybox")

    inst.entity:AddSkyboxRenderer(
            ZELO_PATH(assets.envMap),
            ZELO_PATH(assets.envMapIrradiance),
            ZELO_PATH(assets.brdfLUTFileName)
    )

    return inst
end

return Prefab("skybox", fn, assets)
