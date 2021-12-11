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
    enums = {}
    for enum_node in enum_nodes:
        enums[enum_node.spelling] = find_all_enum_items(enum_node)
    return enums


def main():
    enums = parse_header(ImGui_h_Path)

    print(len(enums))

    import pprint
    pprint.pp(enums)


if __name__ == '__main__':
    main()
