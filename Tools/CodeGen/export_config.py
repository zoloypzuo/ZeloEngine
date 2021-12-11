"""
requirements: pip install libclang
"""
import os

import clang.cindex

EngineDir = "../../"
ImGuiSrcDir = os.path.join(EngineDir, "Dep", "src", "imgui")
ImGui_h_Path = os.path.join(ImGuiSrcDir, "imgui.h")

EngineConfigDir = os.path.join(EngineDir, "Engine", "Config")


def filter_by_node_kind(nodes, kinds):
    return [node for node in nodes if node.kind in kinds]


def find_all_struct_items(cursor):
    return [field_decl.spelling for field_decl in
            filter_by_node_kind(cursor.get_children(), [clang.cindex.CursorKind.FIELD_DECL])]


def parse_header(filename):
    index = clang.cindex.Index.create()
    translation_unit = index.parse(filename, args=["-std=c++17"])
    source_nodes = translation_unit.cursor.get_children()
    struct_nodes = filter_by_node_kind(source_nodes, [clang.cindex.CursorKind.STRUCT_DECL])
    structs = []
    for struct_node in struct_nodes:
        structs.append((struct_node.spelling, find_all_struct_items(struct_node)))
    return structs


'''
ELightType = {
    POINT = 0,
    DIRECTIONAL = 1,
    SPOT = 2,
    AMBIENT_BOX = 3,
    AMBIENT_SPHERE = 4
};
'''


def lua_assign_stmt(l, r):
    return l + " = " + r


def lua_table_ctor(value_pairs):
    return "{\n\t" + ",\n\t".join(["{} = {}".format(first, second) for first, second in value_pairs]) + "\n}\n"


def lua_enum(name, value_pairs):
    return lua_assign_stmt(name, lua_table_ctor(value_pairs))


def gen_lua_enums(enums):
    for name, value_pairs in enums:
        yield lua_enum(name, value_pairs)


def write(filename, content):
    print("write to =>", filename)
    with open(filename, "w") as fp:
        fp.write(content)


def iter_files(root, predicate, ignore):
    for root, dirs, files in os.walk(root, topdown=True):
        dirs[:] = [d for d in dirs if d not in ignore]
        for file in files:
            if predicate(file):
                yield os.path.join(root, file)


def main():
    for file in iter_files(EngineConfigDir, lambda file: True, []):
        structs = parse_header(file)
        import pprint
        pprint.pprint(structs)


if __name__ == '__main__':
    main()
