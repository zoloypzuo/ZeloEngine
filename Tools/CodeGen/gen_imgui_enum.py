"""
requirements: pip install libclang
"""
import os

import clang.cindex

EngineDir = "../../"
ImGuiSrcDir = os.path.join(EngineDir, "Dep", "src", "imgui")
ImGui_h_Path = os.path.join(ImGuiSrcDir, "imgui.h")


def filter_by_node_kind(nodes, kinds):
    return [node for node in nodes if node.kind in kinds]


def find_all_enum_items(cursor):
    return [(enum_decl.spelling, enum_decl.enum_value) for enum_decl in
            filter_by_node_kind(cursor.get_children(), [clang.cindex.CursorKind.ENUM_CONSTANT_DECL])]


def parse_header(filename):
    index = clang.cindex.Index.create()
    translation_unit = index.parse(filename, args=["-std=c++17"])
    source_nodes = translation_unit.cursor.get_children()
    enum_nodes = filter_by_node_kind(source_nodes, [clang.cindex.CursorKind.ENUM_DECL])
    enums = []
    for enum_node in enum_nodes:
        enums.append((enum_node.spelling, find_all_enum_items(enum_node)))
    return enums


def fix_enum_type_name(name):
    return name.strip("_")


def fix_enum_value_name(type_name, value_pairs):
    start = len(type_name)
    for name, value in value_pairs:
        yield name[start:].strip("_"), value


def fix_names(enums):
    for name, value_pairs in enums:
        yield fix_enum_type_name(name), fix_enum_value_name(name, value_pairs)


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


def main():
    enums = parse_header(ImGui_h_Path)
    enums = fix_names(enums)
    codes = list(gen_lua_enums(enums))
    write("../../Script/Lua/scriptlibs/imgui/imgui_consts.lua", "\n".join(codes))


if __name__ == '__main__':
    main()
