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
REFL_AUTO(
    type(WindowSettings),
    field(title),
    field(width),
    field(height),
    field(minimumWidth),
    field(minimumHeight),
    field(maximumWidth),
    field(maximumHeight),
    field(fullscreen),
    field(decorated),
    field(resizable),
    field(focused),
    field(maximized),
    field(floating),
    field(visible),
    field(autoIconify),
    field(refreshRate),
    field(samples)
)
'''

def refl(op, *args, root=False):
    return op + "(" + ",".join(args) + ")"

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

def gen_refl_decl(struct):
    struct_name, struct_fields = struct
    return refl("REFL_AUTO", refl("type", struct_name), *[refl("field", field) for field in struct_fields], root=True)

def gen_include(struct):
    struct_name, struct_fields = struct
    return "#include \""  "Config/" + struct_name + ".h\""

def gen_impl(struct):
    struct_name, struct_fields = struct
    return "L->registerType<" + struct_name + ">();"

def main():
    decl_buffer = []
    impl_buffer = []
    for file in iter_files(EngineConfigDir, lambda file: True, []):
        structs = parse_header(file)
        for struct in structs:
            decl_buffer.append(gen_include(struct))
            decl_buffer.append(gen_refl_decl(struct))
            impl_buffer.append(gen_impl(struct))

    write("../../LuaBind/Config/ConfigDecl.inl", "\n".join(decl_buffer))
    write("../../LuaBind/Config/ConfigImpl.inl", "\n".join(impl_buffer))

if __name__ == '__main__':
    main()
