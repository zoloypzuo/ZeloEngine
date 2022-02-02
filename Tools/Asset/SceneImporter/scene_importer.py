import os

scenes = [
    # 'bistro', 'breakfast_room',
    # 'CornellBox',
    # 'mitsuba',
    'mori_knob',
    # 'sponza'
]

engineDir = "../../.."
exe_name = "SceneImporter.exe"
exe_dir = os.path.join(engineDir, "cmake-build-tool/bin/")
prefab_path = os.path.join(engineDir, "Script/Lua/prefabs/{{{scene_name}}}.lua")
scene_path = os.path.join(engineDir, "ResourceDB/Entities/Models/{{{scene_name}}}.scene.lua")
mat_path = os.path.join(engineDir, "ResourceDB/Entities/Materials/{{{scene_name}}}.mat.lua")

prefab_tpl = '''
local CreateEntity = CreateEntity
local LoadResource = LoadResource
local Prefab = Prefab

local assets = {
    scene = "{{{scene_name}}}.scene";
    mat = "{{{scene_name}}}.mat";
}

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst:AddTag("{{{scene_name}}}")

    inst:AddComponent("mesh_scene_renderer",
            LoadResource(assets.scene), LoadResource(assets.mat))

    return inst
end

return Prefab("{{{scene_name}}}", fn, assets)
'''.strip()

scene_tpl = '''
return {
    type = "SCENE";
    scene_file = "meshes/{{{scene_name}}}.meshes";
    mesh_file = "meshes/{{{scene_name}}}.scene";
    material_file = "meshes/{{{scene_name}}}.materials";
    dummy_texture_file = "const1.bmp";
}'''.strip()

mat_tpl = '''
return {
    type = "MATERIAL";
    diffuse = "bricks2.jpg";
    normal = "bricks2_normal.jpg";
    specular = "bricks2_specular.png";
    shader = "mesh.glsl";
}'''.strip()


def write(filename, content):
    print("write to =>", filename)
    with open(filename, "w") as fp:
        fp.write(content)


cwd = os.getcwd()
for scene in scenes:
    os.chdir(exe_dir)
    os.system(exe_name + " -i " + "%s.json" % scene)

    os.chdir(cwd)
    rep = lambda s: s.replace("{{{scene_name}}}", scene)
    write(rep(prefab_path), rep(prefab_tpl))
    write(rep(scene_path), rep(scene_tpl))
    write(rep(mat_path), rep(mat_tpl))
