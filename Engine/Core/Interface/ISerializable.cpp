// ISerializable.cpp
// created on 2021/7/16
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "ISerializable.h"

#include <rttr/type>

namespace Zelo::Core::Interface {
void ISerializable::OnSerialize(YAML::Emitter &emitter) {
    emitter << YAML::BeginMap;
    auto t = rttr::type::get(*this);

    // type name
    emitter << YAML::Key<< "__type";
    emitter << YAML::Value << t.get_name().to_string();

    // iterate member
    for (const auto &prop:t.get_properties()) {
        emitter << YAML::Key << prop.get_name().to_string();
        auto value = prop.get_value(*this);
        emitter << YAML::Value << value.to_string();
    }
}

bool ISerializable::OnDeserialize(const YAML::Node &node) {
    if(!node["__type"])
        return false;

    auto type_name = node["__type"].as<std::string>();

    auto type = rttr::type::get_by_name(type_name);
    return true;
}
}

// register rttr serializer
#include <rttr/registration>

namespace Zelo{
std::string std_file_system_path_to_string(const std::filesystem::path& path, bool& ok){
    ok = true;
    return path.string();
}
}

RTTR_REGISTRATION {
    rttr::type::register_converter_func(Zelo::std_file_system_path_to_string);
}
