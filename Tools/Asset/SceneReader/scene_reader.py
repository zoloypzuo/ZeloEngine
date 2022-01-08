def get_objT(path, klass_name):
    """
    # from flatbuffers.Material import Material, MaterialT
    # buf = bytearray(open(path, "rb").read())
    # material = Material.GetRootAsMaterial(buf, 0)
    # materialT = MaterialT.InitFromObj(material)
    :param path:
    :param klass_name:
    :return:
    """
    import importlib

    with open(path, "rb") as fp:
        moduleT = importlib.import_module("flatbuffers." + klass_name)
        klass = getattr(moduleT, klass_name)
        klassT = getattr(moduleT, klass_name + "T")
        obj = getattr(klass, "GetRootAs" + klass_name)(bytearray(fp.read()), 0)
        objT = klassT.InitFromObj(obj)
        return objT


files = [
    'bistro_all.materials',
    # 'bistro_all.meshes',
    'bistro_all.scene',
    # 'test.materials',
    # 'test.meshes',
    # 'test.scene',
    # 'test2.materials',
    # 'test2.meshes',
    # 'test2.scene'
]

data_dir = "C:/Users/zoloypzuo/Documents/GitHub/ZeloEngine/cmake-build-tool/bin/data/meshes/"

file_ext2klass_name = {
    ".materials": "Material",
    ".meshes": "MeshData",
    ".scene": "SceneGraph"
}

import os

configs = []
for file in files:
    ext = os.path.splitext(file)[1]
    klass_name = file_ext2klass_name[ext]
    path = os.path.join(data_dir, file)
    configs.append((path, klass_name))

objTs = {}
for config in configs:
    objTs[config[0]] = get_objT(*config)

print()
