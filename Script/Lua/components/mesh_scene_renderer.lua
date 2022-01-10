-- mesh_renderer.lua
-- created on 2022/1/8
-- author @zoloypzuo
local MeshSceneRenderer = Class(function(self, inst, scene, material)
    self.inst = inst
    self.mesh_scene = scene

    self.mesh_renderer_cxx = inst.entity:AddMeshRenderer(scene, material)
end)

local cattrs = {
    EnableGPUCulling = "boolean";
    FreezeCullingView = "boolean";
    DrawOpaque = "boolean";
    DrawTransparent = "boolean";
    DrawGrid = "boolean";
    EnableSSAO = "boolean";
    EnableBlur = "boolean";
    EnableHDR = "boolean";
    EnableShadows = "boolean";
    LightTheta = "float";
    LightPhi = "float";
}

local type2draw_fn = {
    boolean = "DrawBoolean";
    float = "DrawNumber"
}

local function Accessor(o, attr)
    -- @formatter:off
    return function() return o[attr] end, function(value) o[attr] = value end
    -- @formatter:on
end

function MeshSceneRenderer:OnGui(root, drawer)
    for attr_name, attr_type in pairs(cattrs) do
        draw_fn = drawer[type2draw_fn[attr_type]]
        draw_fn(drawer, root, attr_name, Accessor(self.mesh_scene, attr_name))
    end
end

return MeshSceneRenderer