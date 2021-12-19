// LuaBind_ImGuiWidget.cpp
// created on 2021/12/6
// author @zoloypzuo
#include <imgui.h>
#include <string>
#include <sol/sol.hpp>

namespace sol_ImGui {
void LuaBind_ImGuiWidget(sol::table &ImGui);

// Widgets: Text
inline void TextUnformatted(const std::string &text) { ImGui::TextUnformatted(text.c_str()); }

inline void Text(const std::string &text) { ImGui::Text(text.c_str()); }

inline void TextColored(float colR, float colG, float colB, float colA, const std::string &text) {
    ImGui::TextColored({colR, colG, colB, colA}, text.c_str());
}

inline void TextDisabled(const std::string &text) { ImGui::TextDisabled(text.c_str()); }

inline void TextWrapped(const std::string &text) { ImGui::TextWrapped(text.c_str()); }

inline void LabelText(const std::string &label, const std::string &text) {
    ImGui::LabelText(label.c_str(), text.c_str());
}

inline void BulletText(const std::string &text) { ImGui::BulletText(text.c_str()); }

// Widgets: Main
inline bool Button(const std::string &label) { return ImGui::Button(label.c_str()); }

inline bool Button(const std::string &label, float sizeX, float sizeY) {
    return ImGui::Button(label.c_str(), {sizeX, sizeY});
}

inline bool SmallButton(const std::string &label) { return ImGui::SmallButton(label.c_str()); }

inline bool InvisibleButton(const std::string &stringID, float sizeX, float sizeY) {
    return ImGui::InvisibleButton(stringID.c_str(), {sizeX, sizeY});
}

inline bool ArrowButton(const std::string &stringID, int dir) {
    return ImGui::ArrowButton(stringID.c_str(), static_cast<ImGuiDir>(dir));
}

inline void Image(int textureID,
                  float sizeX, float sizeY,
                  float uv0X, float uv0Y,
                  float uv1X, float uv1Y) {
    ImGui::Image(reinterpret_cast<void *>(textureID), {sizeX, sizeY}, {uv0X, uv0Y}, {uv1X, uv1Y});
}

inline std::tuple<bool, bool> Checkbox(const std::string &label, bool v) {
    bool value{v};
    bool pressed = ImGui::Checkbox(label.c_str(), &value);

    return std::make_tuple(value, pressed);
}

inline bool RadioButton(const std::string &label, bool active) { return ImGui::RadioButton(label.c_str(), active); }

inline std::tuple<int, bool> RadioButton(const std::string &label, int v, int vButton) {
    bool ret{ImGui::RadioButton(label.c_str(), &v, vButton)};
    return std::make_tuple(v, ret);
}

inline void ProgressBar(float fraction) { ImGui::ProgressBar(fraction); }

inline void ProgressBar(float fraction, float sizeX, float sizeY) { ImGui::ProgressBar(fraction, {sizeX, sizeY}); }

inline void ProgressBar(float fraction, float sizeX, float sizeY, const std::string &overlay) {
    ImGui::ProgressBar(fraction, {sizeX, sizeY}, overlay.c_str());
}

inline void Bullet() { ImGui::Bullet(); }

// Widgets: Combo Box
inline bool BeginCombo(const std::string &label, const std::string &previewValue) {
    return ImGui::BeginCombo(label.c_str(), previewValue.c_str());
}

inline bool BeginCombo(const std::string &label, const std::string &previewValue, int flags) {
    return ImGui::BeginCombo(label.c_str(), previewValue.c_str(), static_cast<ImGuiComboFlags>(flags));
}

inline void EndCombo() { ImGui::EndCombo(); }

inline std::tuple<int, bool> Combo(const std::string &label, int currentItem, const sol::table &items, int itemsCount) {
    std::vector<std::string> strings;
    for (int i{1}; i <= itemsCount; i++) {
        const auto &stringItem = items.get<sol::optional<std::string>>(i);
        strings.push_back(stringItem.value_or("Missing"));
    }

    std::vector<const char *> cstrings;
    cstrings.reserve(strings.size());
    for (auto &string: strings) {
        cstrings.push_back(string.c_str());
    }

    bool clicked = ImGui::Combo(label.c_str(), &currentItem, cstrings.data(), itemsCount);
    return std::make_tuple(currentItem, clicked);
}

inline std::tuple<int, bool>
Combo(const std::string &label, int currentItem, const sol::table &items, int itemsCount, int popupMaxHeightInItems) {
    std::vector<std::string> strings;
    for (int i{1}; i <= itemsCount; i++) {
        const auto &stringItem = items.get<sol::optional<std::string>>(i);
        strings.push_back(stringItem.value_or("Missing"));
    }

    std::vector<const char *> cstrings;
    cstrings.reserve(strings.size());
    for (auto &string: strings) {
        cstrings.push_back(string.c_str());
    }

    bool clicked = ImGui::Combo(label.c_str(), &currentItem, cstrings.data(), itemsCount, popupMaxHeightInItems);
    return std::make_tuple(currentItem, clicked);
}

inline std::tuple<int, bool>
Combo(const std::string &label, int currentItem, const std::string &itemsSeparatedByZeros) {
    bool clicked = ImGui::Combo(label.c_str(), &currentItem, itemsSeparatedByZeros.c_str());
    return std::make_tuple(currentItem, clicked);
}

inline std::tuple<int, bool>
Combo(const std::string &label, int currentItem, const std::string &itemsSeparatedByZeros, int popupMaxHeightInItems) {
    bool clicked = ImGui::Combo(label.c_str(), &currentItem, itemsSeparatedByZeros.c_str(), popupMaxHeightInItems);
    return std::make_tuple(currentItem, clicked);
}

// Widgets: Drags
inline std::tuple<float, bool> DragFloat(const std::string &label, float v) {
    bool used = ImGui::DragFloat(label.c_str(), &v);
    return std::make_tuple(v, used);
}

inline std::tuple<float, bool> DragFloat(const std::string &label, float v, float v_speed) {
    bool used = ImGui::DragFloat(label.c_str(), &v, v_speed);
    return std::make_tuple(v, used);
}

inline std::tuple<float, bool> DragFloat(const std::string &label, float v, float v_speed, float v_min) {
    bool used = ImGui::DragFloat(label.c_str(), &v, v_speed, v_min);
    return std::make_tuple(v, used);
}

inline std::tuple<float, bool> DragFloat(const std::string &label, float v, float v_speed, float v_min, float v_max) {
    bool used = ImGui::DragFloat(label.c_str(), &v, v_speed, v_min, v_max);
    return std::make_tuple(v, used);
}

inline std::tuple<float, bool> DragFloat(const std::string &label, float v, float v_speed, float v_min, float v_max,
                                         const std::string &format) {
    bool used = ImGui::DragFloat(label.c_str(), &v, v_speed, v_min, v_max, format.c_str());
    return std::make_tuple(v, used);
}

inline std::tuple<float, bool>
DragFloat(const std::string &label, float v, float v_speed, float v_min, float v_max, const std::string &format,
          float power) {
    bool used = ImGui::DragFloat(label.c_str(), &v, v_speed, v_min, v_max, format.c_str(), power);
    return std::make_tuple(v, used);
}

inline std::tuple<sol::as_table_t<std::vector<float>>, bool> DragFloat2(const std::string &label, const sol::table &v) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    float value[2] = {float(v1), float(v2)};
    bool used = ImGui::DragFloat2(label.c_str(), value);

    sol::as_table_t float2 = sol::as_table(std::vector<float>{
            value[0], value[1]
    });

    return std::make_tuple(float2, used);
}

inline std::tuple<sol::as_table_t<std::vector<float>>, bool>
DragFloat2(const std::string &label, const sol::table &v, float v_speed) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    float value[2] = {float(v1), float(v2)};
    bool used = ImGui::DragFloat2(label.c_str(), value, v_speed);

    sol::as_table_t float2 = sol::as_table(std::vector<float>{
            value[0], value[1]
    });

    return std::make_tuple(float2, used);
}

inline std::tuple<sol::as_table_t<std::vector<float>>, bool>
DragFloat2(const std::string &label, const sol::table &v, float v_speed, float v_min) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    float value[2] = {float(v1), float(v2)};
    bool used = ImGui::DragFloat2(label.c_str(), value, v_speed, v_min);

    sol::as_table_t float2 = sol::as_table(std::vector<float>{
            value[0], value[1]
    });

    return std::make_tuple(float2, used);
}

inline std::tuple<sol::as_table_t<std::vector<float>>, bool>
DragFloat2(const std::string &label, const sol::table &v, float v_speed, float v_min, float v_max) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    float value[2] = {float(v1), float(v2)};
    bool used = ImGui::DragFloat2(label.c_str(), value, v_speed, v_min, v_max);

    sol::as_table_t float2 = sol::as_table(std::vector<float>{
            value[0], value[1]
    });

    return std::make_tuple(float2, used);
}

inline std::tuple<sol::as_table_t<std::vector<float>>, bool>
DragFloat2(const std::string &label, const sol::table &v, float v_speed, float v_min, float v_max,
           const std::string &format) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    float value[2] = {float(v1), float(v2)};
    bool used = ImGui::DragFloat2(label.c_str(), value, v_speed, v_min, v_max, format.c_str());

    sol::as_table_t float2 = sol::as_table(std::vector<float>{
            value[0], value[1]
    });

    return std::make_tuple(float2, used);
}

inline std::tuple<sol::as_table_t<std::vector<float>>, bool>
DragFloat2(const std::string &label, const sol::table &v, float v_speed, float v_min, float v_max,
           const std::string &format, float power) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    float value[2] = {float(v1), float(v2)};
    bool used = ImGui::DragFloat2(label.c_str(), value, v_speed, v_min, v_max, format.c_str(), power);

    sol::as_table_t float2 = sol::as_table(std::vector<float>{
            value[0], value[1]
    });

    return std::make_tuple(float2, used);
}

inline std::tuple<sol::as_table_t<std::vector<float>>, bool> DragFloat3(const std::string &label, const sol::table &v) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v3{v[3].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    float value[3] = {float(v1), float(v2), float(v3)};
    bool used = ImGui::DragFloat3(label.c_str(), value);

    sol::as_table_t float3 = sol::as_table(std::vector<float>{
            value[0], value[1], value[2]
    });

    return std::make_tuple(float3, used);
}

inline std::tuple<sol::as_table_t<std::vector<float>>, bool>
DragFloat3(const std::string &label, const sol::table &v, float v_speed) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v3{v[3].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    float value[3] = {float(v1), float(v2), float(v3)};
    bool used = ImGui::DragFloat3(label.c_str(), value, v_speed);

    sol::as_table_t float3 = sol::as_table(std::vector<float>{
            value[0], value[1], value[2]
    });

    return std::make_tuple(float3, used);
}

inline std::tuple<sol::as_table_t<std::vector<float>>, bool>
DragFloat3(const std::string &label, const sol::table &v, float v_speed, float v_min) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v3{v[3].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    float value[3] = {float(v1), float(v2), float(v3)};
    bool used = ImGui::DragFloat3(label.c_str(), value, v_speed, v_min);

    sol::as_table_t float3 = sol::as_table(std::vector<float>{
            value[0], value[1], value[2]
    });

    return std::make_tuple(float3, used);
}

inline std::tuple<sol::as_table_t<std::vector<float>>, bool>
DragFloat3(const std::string &label, const sol::table &v, float v_speed, float v_min, float v_max) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v3{v[3].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    float value[3] = {float(v1), float(v2), float(v3)};
    bool used = ImGui::DragFloat3(label.c_str(), value, v_speed, v_min, v_max);

    sol::as_table_t float3 = sol::as_table(std::vector<float>{
            value[0], value[1], value[2]
    });

    return std::make_tuple(float3, used);
}

inline std::tuple<sol::as_table_t<std::vector<float>>, bool>
DragFloat3(const std::string &label, const sol::table &v, float v_speed, float v_min, float v_max,
           const std::string &format) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v3{v[3].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    float value[3] = {float(v1), float(v2), float(v3)};
    bool used = ImGui::DragFloat3(label.c_str(), value, v_speed, v_min, v_max, format.c_str());

    sol::as_table_t float3 = sol::as_table(std::vector<float>{
            value[0], value[1], value[2]
    });

    return std::make_tuple(float3, used);
}

inline std::tuple<sol::as_table_t<std::vector<float>>, bool>
DragFloat3(const std::string &label, const sol::table &v, float v_speed, float v_min, float v_max,
           const std::string &format, float power) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v3{v[3].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    float value[3] = {float(v1), float(v2), float(v3)};
    bool used = ImGui::DragFloat3(label.c_str(), value, v_speed, v_min, v_max, format.c_str(), power);

    sol::as_table_t float3 = sol::as_table(std::vector<float>{
            value[0], value[1], value[2]
    });

    return std::make_tuple(float3, used);
}

inline std::tuple<sol::as_table_t<std::vector<float>>, bool> DragFloat4(const std::string &label, const sol::table &v) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v3{v[3].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v4{v[4].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    float value[4] = {float(v1), float(v2), float(v3), float(v4)};
    bool used = ImGui::DragFloat4(label.c_str(), value);

    sol::as_table_t float4 = sol::as_table(std::vector<float>{
            value[0], value[1], value[2], value[3]
    });

    return std::make_tuple(float4, used);
}

inline std::tuple<sol::as_table_t<std::vector<float>>, bool>
DragFloat4(const std::string &label, const sol::table &v, float v_speed) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v3{v[3].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v4{v[4].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    float value[4] = {float(v1), float(v2), float(v3), float(v4)};
    bool used = ImGui::DragFloat4(label.c_str(), value, v_speed);

    sol::as_table_t float4 = sol::as_table(std::vector<float>{
            value[0], value[1], value[2], value[3]
    });

    return std::make_tuple(float4, used);
}

inline std::tuple<sol::as_table_t<std::vector<float>>, bool>
DragFloat4(const std::string &label, const sol::table &v, float v_speed, float v_min) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v3{v[3].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v4{v[4].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    float value[4] = {float(v1), float(v2), float(v3), float(v4)};
    bool used = ImGui::DragFloat4(label.c_str(), value, v_speed, v_min);

    sol::as_table_t float4 = sol::as_table(std::vector<float>{
            value[0], value[1], value[2], value[3]
    });

    return std::make_tuple(float4, used);
}

inline std::tuple<sol::as_table_t<std::vector<float>>, bool>
DragFloat4(const std::string &label, const sol::table &v, float v_speed, float v_min, float v_max) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v3{v[3].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v4{v[4].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    float value[4] = {float(v1), float(v2), float(v3), float(v4)};
    bool used = ImGui::DragFloat4(label.c_str(), value, v_speed, v_min, v_max);

    sol::as_table_t float4 = sol::as_table(std::vector<float>{
            value[0], value[1], value[2], value[3]
    });

    return std::make_tuple(float4, used);
}

inline std::tuple<sol::as_table_t<std::vector<float>>, bool>
DragFloat4(const std::string &label, const sol::table &v, float v_speed, float v_min, float v_max,
           const std::string &format) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v3{v[3].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v4{v[4].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    float value[4] = {float(v1), float(v2), float(v3), float(v4)};
    bool used = ImGui::DragFloat4(label.c_str(), value, v_speed, v_min, v_max, format.c_str());

    sol::as_table_t float4 = sol::as_table(std::vector<float>{
            value[0], value[1], value[2], value[3]
    });

    return std::make_tuple(float4, used);
}

inline std::tuple<sol::as_table_t<std::vector<float>>, bool>
DragFloat4(const std::string &label, const sol::table &v, float v_speed, float v_min, float v_max,
           const std::string &format, float power) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v3{v[3].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v4{v[4].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    float value[4] = {float(v1), float(v2), float(v3), float(v4)};
    bool used = ImGui::DragFloat4(label.c_str(), value, v_speed, v_min, v_max, format.c_str(), power);

    sol::as_table_t float4 = sol::as_table(std::vector<float>{
            value[0], value[1], value[2], value[3]
    });

    return std::make_tuple(float4, used);
}

inline std::tuple<int, bool> DragInt(const std::string &label, int v) {
    bool used = ImGui::DragInt(label.c_str(), &v);
    return std::make_tuple(v, used);
}

inline std::tuple<int, bool> DragInt(const std::string &label, int v, float v_speed) {
    bool used = ImGui::DragInt(label.c_str(), &v, v_speed);
    return std::make_tuple(v, used);
}

inline std::tuple<int, bool> DragInt(const std::string &label, int v, float v_speed, int v_min) {
    bool used = ImGui::DragInt(label.c_str(), &v, v_speed, v_min);
    return std::make_tuple(v, used);
}

inline std::tuple<int, bool> DragInt(const std::string &label, int v, float v_speed, int v_min, int v_max) {
    bool used = ImGui::DragInt(label.c_str(), &v, v_speed, v_min, v_max);
    return std::make_tuple(v, used);
}

inline std::tuple<int, bool> DragInt(const std::string &label, int v, float v_speed, int v_min, int v_max,
                                     const std::string &format) {
    bool used = ImGui::DragInt(label.c_str(), &v, v_speed, v_min, v_max, format.c_str());
    return std::make_tuple(v, used);
}

inline std::tuple<sol::as_table_t<std::vector<int>>, bool> DragInt2(const std::string &label, const sol::table &v) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    int value[2] = {int(v1), int(v2)};
    bool used = ImGui::DragInt2(label.c_str(), value);

    sol::as_table_t int2 = sol::as_table(std::vector<int>{
            value[0], value[1]
    });

    return std::make_tuple(int2, used);
}

inline std::tuple<sol::as_table_t<std::vector<int>>, bool>
DragInt2(const std::string &label, const sol::table &v, float v_speed) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    int value[2] = {int(v1), int(v2)};
    bool used = ImGui::DragInt2(label.c_str(), value, v_speed);

    sol::as_table_t int2 = sol::as_table(std::vector<int>{
            value[0], value[1]
    });

    return std::make_tuple(int2, used);
}

inline std::tuple<sol::as_table_t<std::vector<int>>, bool>
DragInt2(const std::string &label, const sol::table &v, float v_speed, int v_min) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    int value[2] = {int(v1), int(v2)};
    bool used = ImGui::DragInt2(label.c_str(), value, v_speed, v_min);

    sol::as_table_t int2 = sol::as_table(std::vector<int>{
            value[0], value[1]
    });

    return std::make_tuple(int2, used);
}

inline std::tuple<sol::as_table_t<std::vector<int>>, bool>
DragInt2(const std::string &label, const sol::table &v, float v_speed, int v_min, int v_max) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    int value[2] = {int(v1), int(v2)};
    bool used = ImGui::DragInt2(label.c_str(), value, v_speed, v_min, v_max);

    sol::as_table_t int2 = sol::as_table(std::vector<int>{
            value[0], value[1]
    });

    return std::make_tuple(int2, used);
}

inline std::tuple<sol::as_table_t<std::vector<int>>, bool>
DragInt2(const std::string &label, const sol::table &v, float v_speed, int v_min, int v_max,
         const std::string &format) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    int value[2] = {int(v1), int(v2)};
    bool used = ImGui::DragInt2(label.c_str(), value, v_speed, v_min, v_max, format.c_str());

    sol::as_table_t int2 = sol::as_table(std::vector<int>{
            value[0], value[1]
    });

    return std::make_tuple(int2, used);
}

inline std::tuple<sol::as_table_t<std::vector<int>>, bool> DragInt3(const std::string &label, const sol::table &v) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v3{v[3].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    int value[3] = {int(v1), int(v2), int(v3)};
    bool used = ImGui::DragInt3(label.c_str(), value);

    sol::as_table_t int3 = sol::as_table(std::vector<int>{
            value[0], value[1], value[2]
    });

    return std::make_tuple(int3, used);
}

inline std::tuple<sol::as_table_t<std::vector<int>>, bool>
DragInt3(const std::string &label, const sol::table &v, float v_speed) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v3{v[3].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    int value[3] = {int(v1), int(v2), int(v3)};
    bool used = ImGui::DragInt3(label.c_str(), value, v_speed);

    sol::as_table_t int3 = sol::as_table(std::vector<int>{
            value[0], value[1], value[2]
    });

    return std::make_tuple(int3, used);
}

inline std::tuple<sol::as_table_t<std::vector<int>>, bool>
DragInt3(const std::string &label, const sol::table &v, float v_speed, int v_min) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v3{v[3].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    int value[3] = {int(v1), int(v2), int(v3)};
    bool used = ImGui::DragInt3(label.c_str(), value, v_speed, v_min);

    sol::as_table_t int3 = sol::as_table(std::vector<int>{
            value[0], value[1], value[2]
    });

    return std::make_tuple(int3, used);
}

inline std::tuple<sol::as_table_t<std::vector<int>>, bool>
DragInt3(const std::string &label, const sol::table &v, float v_speed, int v_min, int v_max) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v3{v[3].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    int value[3] = {int(v1), int(v2), int(v3)};
    bool used = ImGui::DragInt3(label.c_str(), value, v_speed, v_min, v_max);

    sol::as_table_t int3 = sol::as_table(std::vector<int>{
            value[0], value[1], value[2]
    });

    return std::make_tuple(int3, used);
}

inline std::tuple<sol::as_table_t<std::vector<int>>, bool>
DragInt3(const std::string &label, const sol::table &v, float v_speed, int v_min, int v_max,
         const std::string &format) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v3{v[3].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    int value[3] = {int(v1), int(v2), int(v3)};
    bool used = ImGui::DragInt3(label.c_str(), value, v_speed, v_min, v_max, format.c_str());

    sol::as_table_t int3 = sol::as_table(std::vector<int>{
            value[0], value[1], value[2]
    });

    return std::make_tuple(int3, used);
}

inline std::tuple<sol::as_table_t<std::vector<int>>, bool> DragInt4(const std::string &label, const sol::table &v) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v3{v[3].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v4{v[4].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    int value[4] = {int(v1), int(v2), int(v3), int(v4)};
    bool used = ImGui::DragInt4(label.c_str(), value);

    sol::as_table_t int4 = sol::as_table(std::vector<int>{
            value[0], value[1], value[2], value[3]
    });

    return std::make_tuple(int4, used);
}

inline std::tuple<sol::as_table_t<std::vector<int>>, bool>
DragInt4(const std::string &label, const sol::table &v, float v_speed) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v3{v[3].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v4{v[4].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    int value[4] = {int(v1), int(v2), int(v3), int(v4)};
    bool used = ImGui::DragInt4(label.c_str(), value, v_speed);

    sol::as_table_t int4 = sol::as_table(std::vector<int>{
            value[0], value[1], value[2], value[3]
    });

    return std::make_tuple(int4, used);
}

inline std::tuple<sol::as_table_t<std::vector<int>>, bool>
DragInt4(const std::string &label, const sol::table &v, float v_speed, int v_min) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v3{v[3].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v4{v[4].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    int value[4] = {int(v1), int(v2), int(v3), int(v4)};
    bool used = ImGui::DragInt4(label.c_str(), value, v_speed, v_min);

    sol::as_table_t int4 = sol::as_table(std::vector<int>{
            value[0], value[1], value[2], value[3]
    });

    return std::make_tuple(int4, used);
}

inline std::tuple<sol::as_table_t<std::vector<int>>, bool>
DragInt4(const std::string &label, const sol::table &v, float v_speed, int v_min, int v_max) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v3{v[3].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v4{v[4].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    int value[4] = {int(v1), int(v2), int(v3), int(v4)};
    bool used = ImGui::DragInt4(label.c_str(), value, v_speed, v_min, v_max);

    sol::as_table_t int4 = sol::as_table(std::vector<int>{
            value[0], value[1], value[2], value[3]
    });

    return std::make_tuple(int4, used);
}

inline std::tuple<sol::as_table_t<std::vector<int>>, bool>
DragInt4(const std::string &label, const sol::table &v, float v_speed, int v_min, int v_max,
         const std::string &format) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v3{v[3].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v4{v[4].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    int value[4] = {int(v1), int(v2), int(v3), int(v4)};
    bool used = ImGui::DragInt4(label.c_str(), value, v_speed, v_min, v_max, format.c_str());

    sol::as_table_t int4 = sol::as_table(std::vector<int>{
            value[0], value[1], value[2], value[3]
    });

    return std::make_tuple(int4, used);
}

// Widgets: Sliders
inline std::tuple<float, bool> SliderFloat(const std::string &label, float v, float v_min, float v_max) {
    bool used = ImGui::SliderFloat(label.c_str(), &v, v_min, v_max);
    return std::make_tuple(v, used);
}

inline std::tuple<float, bool> SliderFloat(const std::string &label, float v, float v_min, float v_max,
                                           const std::string &format) {
    bool used = ImGui::SliderFloat(label.c_str(), &v, v_min, v_max, format.c_str());
    return std::make_tuple(v, used);
}

inline std::tuple<float, bool>
SliderFloat(const std::string &label, float v, float v_min, float v_max, const std::string &format, float power) {
    bool used = ImGui::SliderFloat(label.c_str(), &v, v_min, v_max, format.c_str(), power);
    return std::make_tuple(v, used);
}

inline std::tuple<sol::as_table_t<std::vector<float>>, bool>
SliderFloat2(const std::string &label, const sol::table &v, float v_min, float v_max) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    float value[2] = {float(v1), float(v2)};
    bool used = ImGui::SliderFloat2(label.c_str(), value, v_min, v_max);

    sol::as_table_t float2 = sol::as_table(std::vector<float>{
            value[0], value[1]
    });

    return std::make_tuple(float2, used);
}

inline std::tuple<sol::as_table_t<std::vector<float>>, bool>
SliderFloat2(const std::string &label, const sol::table &v, float v_min, float v_max, const std::string &format) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    float value[2] = {float(v1), float(v2)};
    bool used = ImGui::SliderFloat2(label.c_str(), value, v_min, v_max, format.c_str());

    sol::as_table_t float2 = sol::as_table(std::vector<float>{
            value[0], value[1]
    });

    return std::make_tuple(float2, used);
}

inline std::tuple<sol::as_table_t<std::vector<float>>, bool>
SliderFloat2(const std::string &label, const sol::table &v, float v_min, float v_max, const std::string &format,
             float power) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    float value[2] = {float(v1), float(v2)};
    bool used = ImGui::SliderFloat2(label.c_str(), value, v_min, v_max, format.c_str(), power);

    sol::as_table_t float2 = sol::as_table(std::vector<float>{
            value[0], value[1]
    });

    return std::make_tuple(float2, used);
}

inline std::tuple<sol::as_table_t<std::vector<float>>, bool>
SliderFloat3(const std::string &label, const sol::table &v, float v_min, float v_max) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v3{v[3].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    float value[3] = {float(v1), float(v2), float(v3)};
    bool used = ImGui::SliderFloat3(label.c_str(), value, v_min, v_max);

    sol::as_table_t float3 = sol::as_table(std::vector<float>{
            value[0], value[1], value[3]
    });

    return std::make_tuple(float3, used);
}

inline std::tuple<sol::as_table_t<std::vector<float>>, bool>
SliderFloat3(const std::string &label, const sol::table &v, float v_min, float v_max, const std::string &format) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v3{v[3].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    float value[3] = {float(v1), float(v2), float(v3)};
    bool used = ImGui::SliderFloat3(label.c_str(), value, v_min, v_max, format.c_str());

    sol::as_table_t float3 = sol::as_table(std::vector<float>{
            value[0], value[1], value[3]
    });

    return std::make_tuple(float3, used);
}

inline std::tuple<sol::as_table_t<std::vector<float>>, bool>
SliderFloat3(const std::string &label, const sol::table &v, float v_min, float v_max, const std::string &format,
             float power) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v3{v[3].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    float value[3] = {float(v1), float(v2), float(v3)};
    bool used = ImGui::SliderFloat3(label.c_str(), value, v_min, v_max, format.c_str(), power);

    sol::as_table_t float3 = sol::as_table(std::vector<float>{
            value[0], value[1], value[3]
    });

    return std::make_tuple(float3, used);
}

inline std::tuple<sol::as_table_t<std::vector<float>>, bool>
SliderFloat4(const std::string &label, const sol::table &v, float v_min, float v_max) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v3{v[3].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v4{v[4].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    float value[4] = {float(v1), float(v2), float(v3), float(v4)};
    bool used = ImGui::SliderFloat4(label.c_str(), value, v_min, v_max);

    sol::as_table_t float4 = sol::as_table(std::vector<float>{
            value[0], value[1], value[2], value[3]
    });

    return std::make_tuple(float4, used);
}

inline std::tuple<sol::as_table_t<std::vector<float>>, bool>
SliderFloat4(const std::string &label, const sol::table &v, float v_min, float v_max, const std::string &format) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v3{v[3].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v4{v[4].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    float value[4] = {float(v1), float(v2), float(v3), float(v4)};
    bool used = ImGui::SliderFloat4(label.c_str(), value, v_min, v_max, format.c_str());

    sol::as_table_t float4 = sol::as_table(std::vector<float>{
            value[0], value[1], value[2], value[3]
    });

    return std::make_tuple(float4, used);
}

inline std::tuple<sol::as_table_t<std::vector<float>>, bool>
SliderFloat4(const std::string &label, const sol::table &v, float v_min, float v_max, const std::string &format,
             float power) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v3{v[3].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v4{v[4].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    float value[4] = {float(v1), float(v2), float(v3), float(v4)};
    bool used = ImGui::SliderFloat4(label.c_str(), value, v_min, v_max, format.c_str(), power);

    sol::as_table_t float4 = sol::as_table(std::vector<float>{
            value[0], value[1], value[2], value[3]
    });

    return std::make_tuple(float4, used);
}

inline std::tuple<float, bool> SliderAngle(const std::string &label, float v_rad) {
    bool used = ImGui::SliderAngle(label.c_str(), &v_rad);
    return std::make_tuple(v_rad, used);
}

inline std::tuple<float, bool> SliderAngle(const std::string &label, float v_rad, float v_degrees_min) {
    bool used = ImGui::SliderAngle(label.c_str(), &v_rad, v_degrees_min);
    return std::make_tuple(v_rad, used);
}

inline std::tuple<float, bool> SliderAngle(const std::string &label, float v_rad, float v_degrees_min,
                                           float v_degrees_max) {
    bool used = ImGui::SliderAngle(label.c_str(), &v_rad, v_degrees_min, v_degrees_max);
    return std::make_tuple(v_rad, used);
}

inline std::tuple<float, bool>
SliderAngle(const std::string &label, float v_rad, float v_degrees_min, float v_degrees_max,
            const std::string &format) {
    bool used = ImGui::SliderAngle(label.c_str(), &v_rad, v_degrees_min, v_degrees_max, format.c_str());
    return std::make_tuple(v_rad, used);
}

inline std::tuple<int, bool> SliderInt(const std::string &label, int v, int v_min, int v_max) {
    bool used = ImGui::SliderInt(label.c_str(), &v, v_min, v_max);
    return std::make_tuple(v, used);
}

inline std::tuple<int, bool> SliderInt(const std::string &label, int v, int v_min, int v_max,
                                       const std::string &format) {
    bool used = ImGui::SliderInt(label.c_str(), &v, v_min, v_max, format.c_str());
    return std::make_tuple(v, used);
}

inline std::tuple<sol::as_table_t<std::vector<int>>, bool>
SliderInt2(const std::string &label, const sol::table &v, int v_min, int v_max) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    int value[2] = {int(v1), int(v2)};
    bool used = ImGui::SliderInt2(label.c_str(), value, v_min, v_max);

    sol::as_table_t int2 = sol::as_table(std::vector<int>{
            value[0], value[1]
    });

    return std::make_tuple(int2, used);
}

inline std::tuple<sol::as_table_t<std::vector<int>>, bool>
SliderInt2(const std::string &label, const sol::table &v, int v_min, int v_max, const std::string &format) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    int value[2] = {int(v1), int(v2)};
    bool used = ImGui::SliderInt2(label.c_str(), value, v_min, v_max, format.c_str());

    sol::as_table_t int2 = sol::as_table(std::vector<int>{
            value[0], value[1]
    });

    return std::make_tuple(int2, used);
}

inline std::tuple<sol::as_table_t<std::vector<int>>, bool>
SliderInt3(const std::string &label, const sol::table &v, int v_min, int v_max) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v3{v[3].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    int value[3] = {int(v1), int(v2), int(v3)};
    bool used = ImGui::SliderInt3(label.c_str(), value, v_min, v_max);

    sol::as_table_t int3 = sol::as_table(std::vector<int>{
            value[0], value[1], value[2]
    });

    return std::make_tuple(int3, used);
}

inline std::tuple<sol::as_table_t<std::vector<int>>, bool>
SliderInt3(const std::string &label, const sol::table &v, int v_min, int v_max, const std::string &format) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v3{v[3].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    int value[3] = {int(v1), int(v2), int(v3)};
    bool used = ImGui::SliderInt3(label.c_str(), value, v_min, v_max, format.c_str());

    sol::as_table_t int3 = sol::as_table(std::vector<int>{
            value[0], value[1], value[2]
    });

    return std::make_tuple(int3, used);
}

inline std::tuple<sol::as_table_t<std::vector<int>>, bool>
SliderInt4(const std::string &label, const sol::table &v, int v_min, int v_max) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v3{v[3].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v4{v[4].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    int value[4] = {int(v1), int(v2), int(v3), int(v4)};
    bool used = ImGui::SliderInt4(label.c_str(), value, v_min, v_max);

    sol::as_table_t int4 = sol::as_table(std::vector<int>{
            value[0], value[1], value[2], value[3]
    });

    return std::make_tuple(int4, used);
}

inline std::tuple<sol::as_table_t<std::vector<int>>, bool>
SliderInt4(const std::string &label, const sol::table &v, int v_min, int v_max, const std::string &format) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v3{v[3].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v4{v[4].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    int value[4] = {int(v1), int(v2), int(v3), int(v4)};
    bool used = ImGui::SliderInt4(label.c_str(), value, v_min, v_max, format.c_str());

    sol::as_table_t int4 = sol::as_table(std::vector<int>{
            value[0], value[1], value[2], value[3]
    });

    return std::make_tuple(int4, used);
}

inline std::tuple<float, bool> VSliderFloat(const std::string &label, float sizeX, float sizeY, float v, float v_min,
                                            float v_max) {
    bool used = ImGui::VSliderFloat(label.c_str(), {sizeX, sizeY}, &v, v_min, v_max);
    return std::make_tuple(v, used);
}

inline std::tuple<float, bool>
VSliderFloat(const std::string &label, float sizeX, float sizeY, float v, float v_min, float v_max,
             const std::string &format) {
    bool used = ImGui::VSliderFloat(label.c_str(), {sizeX, sizeY}, &v, v_min, v_max, format.c_str());
    return std::make_tuple(v, used);
}

inline std::tuple<float, bool>
VSliderFloat(const std::string &label, float sizeX, float sizeY, float v, float v_min, float v_max,
             const std::string &format, int flags) {
    bool used = ImGui::VSliderFloat(label.c_str(), {sizeX, sizeY}, &v, v_min, v_max, format.c_str(), flags);
    return std::make_tuple(v, used);
}

inline std::tuple<int, bool> VSliderInt(const std::string &label, float sizeX, float sizeY, int v, int v_min,
                                        int v_max) {
    bool used = ImGui::VSliderInt(label.c_str(), {sizeX, sizeY}, &v, v_min, v_max);
    return std::make_tuple(v, used);
}

inline std::tuple<int, bool> VSliderInt(const std::string &label, float sizeX, float sizeY, int v, int v_min, int v_max,
                                        const std::string &format) {
    bool used = ImGui::VSliderInt(label.c_str(), {sizeX, sizeY}, &v, v_min, v_max, format.c_str());
    return std::make_tuple(v, used);
}

// Widgets: Input with Keyboard
inline std::tuple<std::string, bool> InputText(const std::string &label, std::string text, unsigned int buf_size) {
    bool selected = ImGui::InputText(label.c_str(), &text[0], buf_size);
    return std::make_tuple(text, selected);
}

inline std::tuple<std::string, bool> InputText(const std::string &label, std::string text, unsigned int buf_size,
                                               int flags) {
    bool selected = ImGui::InputText(label.c_str(), &text[0], buf_size, static_cast<ImGuiInputTextFlags>(flags));
    return std::make_tuple(text, selected);
}

inline std::tuple<std::string, bool> InputTextMultiline(const std::string &label, std::string text,
                                                        unsigned int buf_size) {
    bool selected = ImGui::InputTextMultiline(label.c_str(), &text[0], buf_size);
    return std::make_tuple(text, selected);
}

inline std::tuple<std::string, bool>
InputTextMultiline(const std::string &label, std::string text, unsigned int buf_size, float sizeX, float sizeY) {
    bool selected = ImGui::InputTextMultiline(label.c_str(), &text[0], buf_size, {sizeX, sizeY});
    return std::make_tuple(text, selected);
}

inline std::tuple<std::string, bool>
InputTextMultiline(const std::string &label, std::string text, unsigned int buf_size, float sizeX, float sizeY,
                   int flags) {
    bool selected = ImGui::InputTextMultiline(label.c_str(), &text[0], buf_size, {sizeX, sizeY},
                                              static_cast<ImGuiInputTextFlags>(flags));
    return std::make_tuple(text, selected);
}

inline std::tuple<std::string, bool>
InputTextWithHint(const std::string &label, const std::string &hint, std::string text, unsigned int buf_size) {
    bool selected = ImGui::InputTextWithHint(label.c_str(), hint.c_str(), &text[0], buf_size);
    return std::make_tuple(text, selected);
}

inline std::tuple<std::string, bool>
InputTextWithHint(const std::string &label, const std::string &hint, std::string text, unsigned int buf_size,
                  int flags) {
    bool selected = ImGui::InputTextWithHint(label.c_str(), hint.c_str(), &text[0], buf_size,
                                             static_cast<ImGuiInputTextFlags>(flags));
    return std::make_tuple(text, selected);
}

inline std::tuple<float, bool> InputFloat(const std::string &label, float v) {
    bool selected = ImGui::InputFloat(label.c_str(), &v);
    return std::make_tuple(v, selected);
}

inline std::tuple<float, bool> InputFloat(const std::string &label, float v, float step) {
    bool selected = ImGui::InputFloat(label.c_str(), &v, step);
    return std::make_tuple(v, selected);
}

inline std::tuple<float, bool> InputFloat(const std::string &label, float v, float step, float step_fast) {
    bool selected = ImGui::InputFloat(label.c_str(), &v, step, step_fast);
    return std::make_tuple(v, selected);
}

inline std::tuple<float, bool> InputFloat(const std::string &label, float v, float step, float step_fast,
                                          const std::string &format) {
    bool selected = ImGui::InputFloat(label.c_str(), &v, step, step_fast, format.c_str());
    return std::make_tuple(v, selected);
}

inline std::tuple<float, bool>
InputFloat(const std::string &label, float v, float step, float step_fast, const std::string &format, int flags) {
    bool selected = ImGui::InputFloat(label.c_str(), &v, step, step_fast, format.c_str(),
                                      static_cast<ImGuiInputTextFlags>(flags));
    return std::make_tuple(v, selected);
}

inline std::tuple<sol::as_table_t<std::vector<float>>, bool>
InputFloat2(const std::string &label, const sol::table &v) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    float value[2] = {float(v1), float(v2)};
    bool used = ImGui::InputFloat2(label.c_str(), value);

    sol::as_table_t float2 = sol::as_table(std::vector<float>{
            value[0], value[1]
    });

    return std::make_tuple(float2, used);
}

inline std::tuple<sol::as_table_t<std::vector<float>>, bool>
InputFloat2(const std::string &label, const sol::table &v, const std::string &format) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    float value[2] = {float(v1), float(v2)};
    bool used = ImGui::InputFloat2(label.c_str(), value, format.c_str());

    sol::as_table_t float2 = sol::as_table(std::vector<float>{
            value[0], value[1]
    });

    return std::make_tuple(float2, used);
}

inline std::tuple<sol::as_table_t<std::vector<float>>, bool>
InputFloat2(const std::string &label, const sol::table &v, const std::string &format, int flags) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    float value[2] = {float(v1), float(v2)};
    bool used = ImGui::InputFloat2(label.c_str(), value, format.c_str(), static_cast<ImGuiInputTextFlags>(flags));

    sol::as_table_t float2 = sol::as_table(std::vector<float>{
            value[0], value[1]
    });

    return std::make_tuple(float2, used);
}

inline std::tuple<sol::as_table_t<std::vector<float>>, bool>
InputFloat3(const std::string &label, const sol::table &v) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v3{v[3].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    float value[3] = {float(v1), float(v2), float(v3)};
    bool used = ImGui::InputFloat3(label.c_str(), value);

    sol::as_table_t float3 = sol::as_table(std::vector<float>{
            value[0], value[1], value[2]
    });

    return std::make_tuple(float3, used);
}

inline std::tuple<sol::as_table_t<std::vector<float>>, bool>
InputFloat3(const std::string &label, const sol::table &v, const std::string &format) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v3{v[3].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    float value[3] = {float(v1), float(v2), float(v3)};
    bool used = ImGui::InputFloat3(label.c_str(), value, format.c_str());

    sol::as_table_t float3 = sol::as_table(std::vector<float>{
            value[0], value[1], value[2]
    });

    return std::make_tuple(float3, used);
}

inline std::tuple<sol::as_table_t<std::vector<float>>, bool>
InputFloat3(const std::string &label, const sol::table &v, const std::string &format, int flags) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v3{v[3].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    float value[3] = {float(v1), float(v2), float(v3)};
    bool used = ImGui::InputFloat3(label.c_str(), value, format.c_str(), static_cast<ImGuiInputTextFlags>(flags));

    sol::as_table_t float3 = sol::as_table(std::vector<float>{
            value[0], value[1], value[2]
    });

    return std::make_tuple(float3, used);
}

inline std::tuple<sol::as_table_t<std::vector<float>>, bool>
InputFloat4(const std::string &label, const sol::table &v) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v3{v[3].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v4{v[4].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    float value[4] = {float(v1), float(v2), float(v3), float(v4)};
    bool used = ImGui::InputFloat4(label.c_str(), value);

    sol::as_table_t float4 = sol::as_table(std::vector<float>{
            value[0], value[1], value[2], value[3]
    });

    return std::make_tuple(float4, used);
}

inline std::tuple<sol::as_table_t<std::vector<float>>, bool>
InputFloat4(const std::string &label, const sol::table &v, const std::string &format) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v3{v[3].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v4{v[4].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    float value[4] = {float(v1), float(v2), float(v3), float(v4)};
    bool used = ImGui::InputFloat4(label.c_str(), value, format.c_str());

    sol::as_table_t float4 = sol::as_table(std::vector<float>{
            value[0], value[1], value[2], value[3]
    });

    return std::make_tuple(float4, used);
}

inline std::tuple<sol::as_table_t<std::vector<float>>, bool>
InputFloat4(const std::string &label, const sol::table &v, const std::string &format, int flags) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v3{v[3].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v4{v[4].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    float value[4] = {float(v1), float(v2), float(v3), float(v4)};
    bool used = ImGui::InputFloat4(label.c_str(), value, format.c_str(), static_cast<ImGuiInputTextFlags>(flags));

    sol::as_table_t float4 = sol::as_table(std::vector<float>{
            value[0], value[1], value[2], value[3]
    });

    return std::make_tuple(float4, used);
}

inline std::tuple<int, bool> InputInt(const std::string &label, int v) {
    bool selected = ImGui::InputInt(label.c_str(), &v);
    return std::make_tuple(v, selected);
}

inline std::tuple<int, bool> InputInt(const std::string &label, int v, int step) {
    bool selected = ImGui::InputInt(label.c_str(), &v, step);
    return std::make_tuple(v, selected);
}

inline std::tuple<int, bool> InputInt(const std::string &label, int v, int step, int step_fast) {
    bool selected = ImGui::InputInt(label.c_str(), &v, step, step_fast);
    return std::make_tuple(v, selected);
}

inline std::tuple<int, bool> InputInt(const std::string &label, int v, int step, int step_fast, int flags) {
    bool selected = ImGui::InputInt(label.c_str(), &v, step, step_fast, static_cast<ImGuiInputTextFlags>(flags));
    return std::make_tuple(v, selected);
}

inline std::tuple<sol::as_table_t<std::vector<int>>, bool> InputInt2(const std::string &label, const sol::table &v) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    int value[2] = {int(v1), int(v2)};
    bool used = ImGui::InputInt2(label.c_str(), value);

    sol::as_table_t int2 = sol::as_table(std::vector<int>{
            value[0], value[1]
    });

    return std::make_tuple(int2, used);
}

inline std::tuple<sol::as_table_t<std::vector<int>>, bool>
InputInt2(const std::string &label, const sol::table &v, int flags) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    int value[2] = {int(v1), int(v2)};
    bool used = ImGui::InputInt2(label.c_str(), value, static_cast<ImGuiInputTextFlags>(flags));

    sol::as_table_t int2 = sol::as_table(std::vector<int>{
            value[0], value[1]
    });

    return std::make_tuple(int2, used);
}

inline std::tuple<sol::as_table_t<std::vector<int>>, bool> InputInt3(const std::string &label, const sol::table &v) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v3{v[3].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    int value[3] = {int(v1), int(v2), int(v3)};
    bool used = ImGui::InputInt3(label.c_str(), value);

    sol::as_table_t int3 = sol::as_table(std::vector<int>{
            value[0], value[1], value[2]
    });

    return std::make_tuple(int3, used);
}

inline std::tuple<sol::as_table_t<std::vector<int>>, bool>
InputInt3(const std::string &label, const sol::table &v, int flags) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v3{v[3].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    int value[3] = {int(v1), int(v2), int(v3)};
    bool used = ImGui::InputInt3(label.c_str(), value, static_cast<ImGuiInputTextFlags>(flags));

    sol::as_table_t int3 = sol::as_table(std::vector<int>{
            value[0], value[1], value[2]
    });

    return std::make_tuple(int3, used);
}

inline std::tuple<sol::as_table_t<std::vector<int>>, bool> InputInt4(const std::string &label, const sol::table &v) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v3{v[3].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v4{v[4].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    int value[4] = {int(v1), int(v2), int(v3), int(v4)};
    bool used = ImGui::InputInt4(label.c_str(), value);

    sol::as_table_t int4 = sol::as_table(std::vector<int>{
            value[0], value[1], value[2], value[3]
    });

    return std::make_tuple(int4, used);
}

inline std::tuple<sol::as_table_t<std::vector<int>>, bool>
InputInt4(const std::string &label, const sol::table &v, int flags) {
    const lua_Number v1{v[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v2{v[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v3{v[3].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            v4{v[4].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    int value[4] = {int(v1), int(v2), int(v3), int(v4)};
    bool used = ImGui::InputInt4(label.c_str(), value, static_cast<ImGuiInputTextFlags>(flags));

    sol::as_table_t int4 = sol::as_table(std::vector<int>{
            value[0], value[1], value[2], value[3]
    });

    return std::make_tuple(int4, used);
}

inline std::tuple<double, bool> InputDouble(const std::string &label, double v) {
    bool selected = ImGui::InputDouble(label.c_str(), &v);
    return std::make_tuple(v, selected);
}

inline std::tuple<double, bool> InputDouble(const std::string &label, double v, double step) {
    bool selected = ImGui::InputDouble(label.c_str(), &v, step);
    return std::make_tuple(v, selected);
}

inline std::tuple<double, bool> InputDouble(const std::string &label, double v, double step, double step_fast) {
    bool selected = ImGui::InputDouble(label.c_str(), &v, step, step_fast);
    return std::make_tuple(v, selected);
}

inline std::tuple<double, bool> InputDouble(const std::string &label, double v, double step, double step_fast,
                                            const std::string &format) {
    bool selected = ImGui::InputDouble(label.c_str(), &v, step, step_fast, format.c_str());
    return std::make_tuple(v, selected);
}

inline std::tuple<double, bool>
InputDouble(const std::string &label, double v, double step, double step_fast, const std::string &format, int flags) {
    bool selected = ImGui::InputDouble(label.c_str(), &v, step, step_fast, format.c_str(),
                                       static_cast<ImGuiInputTextFlags>(flags));
    return std::make_tuple(v, selected);
}

// Widgets: Color Editor / Picker
inline std::tuple<sol::as_table_t<std::vector<float>>, bool>
ColorEdit3(const std::string &label, const sol::table &col) {
    const lua_Number r{col[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            g{col[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            b{col[3].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    float color[3] = {float(r), float(g), float(b)};
    bool used = ImGui::ColorEdit3(label.c_str(), color);

    sol::as_table_t rgb = sol::as_table(std::vector<float>{
            color[0], color[1], color[2]
    });

    return std::make_tuple(rgb, used);
}

inline std::tuple<sol::as_table_t<std::vector<float>>, bool>
ColorEdit3(const std::string &label, const sol::table &col, int flags) {
    const lua_Number r{col[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            g{col[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            b{col[3].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    float color[3] = {float(r), float(g), float(b)};
    bool used = ImGui::ColorEdit3(label.c_str(), color, static_cast<ImGuiColorEditFlags>(flags));

    sol::as_table_t rgb = sol::as_table(std::vector<float>{
            color[0], color[1], color[2]
    });

    return std::make_tuple(rgb, used);
}

inline std::tuple<sol::as_table_t<std::vector<float>>, bool>
ColorEdit4(const std::string &label, const sol::table &col) {
    const lua_Number r{col[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            g{col[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            b{col[3].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            a{col[4].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    float color[4] = {float(r), float(g), float(b), float(a)};
    bool used = ImGui::ColorEdit4(label.c_str(), color);

    sol::as_table_t rgba = sol::as_table(std::vector<float>{
            color[0], color[1], color[2], color[3]
    });

    return std::make_tuple(rgba, used);
}

inline std::tuple<sol::as_table_t<std::vector<float>>, bool>
ColorEdit4(const std::string &label, const sol::table &col, int flags) {
    const lua_Number r{col[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            g{col[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            b{col[3].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            a{col[4].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    float color[4] = {float(r), float(g), float(b), float(a)};
    bool used = ImGui::ColorEdit4(label.c_str(), color, static_cast<ImGuiColorEditFlags>(flags));

    sol::as_table_t rgba = sol::as_table(std::vector<float>{
            color[0], color[1], color[2], color[3]
    });

    return std::make_tuple(rgba, used);
}

inline std::tuple<sol::as_table_t<std::vector<float>>, bool>
ColorPicker3(const std::string &label, const sol::table &col) {
    const lua_Number r{col[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            g{col[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            b{col[3].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    float color[3] = {float(r), float(g), float(b)};
    bool used = ImGui::ColorPicker3(label.c_str(), color);

    sol::as_table_t rgb = sol::as_table(std::vector<float>{
            color[0], color[1], color[2]
    });

    return std::make_tuple(rgb, used);
}

inline std::tuple<sol::as_table_t<std::vector<float>>, bool>
ColorPicker3(const std::string &label, const sol::table &col, int flags) {
    const lua_Number r{col[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            g{col[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            b{col[3].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    float color[3] = {float(r), float(g), float(b)};
    bool used = ImGui::ColorPicker3(label.c_str(), color, static_cast<ImGuiColorEditFlags>(flags));

    sol::as_table_t rgb = sol::as_table(std::vector<float>{
            color[0], color[1], color[2]
    });

    return std::make_tuple(rgb, used);
}

inline std::tuple<sol::as_table_t<std::vector<float>>, bool>
ColorPicker4(const std::string &label, const sol::table &col) {
    const lua_Number r{col[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            g{col[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            b{col[3].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            a{col[4].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    float color[4] = {float(r), float(g), float(b), float(a)};
    bool used = ImGui::ColorPicker4(label.c_str(), color);

    sol::as_table_t rgba = sol::as_table(std::vector<float>{
            color[0], color[1], color[2], color[3]
    });

    return std::make_tuple(rgba, used);
}

inline std::tuple<sol::as_table_t<std::vector<float>>, bool>
ColorPicker4(const std::string &label, const sol::table &col, int flags) {
    const lua_Number r{col[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            g{col[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            b{col[3].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            a{col[4].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    float color[4] = {float(r), float(g), float(b), float(a)};
    bool used = ImGui::ColorPicker4(label.c_str(), color, static_cast<ImGuiColorEditFlags>(flags));

    sol::as_table_t rgba = sol::as_table(std::vector<float>{
            color[0], color[1], color[2], color[3]
    });

    return std::make_tuple(rgba, used);
}

inline bool ColorButton(const std::string &desc_id, const sol::table &col) {
    const lua_Number r{col[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            g{col[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            b{col[3].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            a{col[4].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    const ImVec4 color{float(r), float(g), float(b), float(a)};
    return ImGui::ColorButton(desc_id.c_str(), color);
}

inline bool ColorButton(const std::string &desc_id, const sol::table &col, int flags) {
    const lua_Number r{col[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            g{col[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            b{col[3].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            a{col[4].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    const ImVec4 color{float(r), float(g), float(b), float(a)};
    return ImGui::ColorButton(desc_id.c_str(), color, static_cast<ImGuiColorEditFlags>(flags));
}

inline bool ColorButton(const std::string &desc_id, const sol::table &col, int flags, float sizeX, float sizeY) {
    const lua_Number r{col[1].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            g{col[2].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            b{col[3].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))},
            a{col[4].get<std::optional<lua_Number>>().value_or(static_cast<lua_Number>(0))};
    const ImVec4 color{float(r), float(g), float(b), float(a)};
    return ImGui::ColorButton(desc_id.c_str(), color, static_cast<ImGuiColorEditFlags>(flags), {sizeX, sizeY});
}

inline void SetColorEditOptions(int flags) { ImGui::SetColorEditOptions(static_cast<ImGuiColorEditFlags>(flags)); }

// Widgets: Trees
inline bool TreeNode(const std::string &label) { return ImGui::TreeNode(label.c_str()); }

inline bool TreeNode(const std::string &label, const std::string &fmt) {
    return ImGui::TreeNode(label.c_str(), fmt.c_str());
}

inline bool TreeNodeEx(const std::string &label) { return ImGui::TreeNodeEx(label.c_str()); }

inline bool TreeNodeEx(const std::string &label, int flags) {
    return ImGui::TreeNodeEx(label.c_str(), static_cast<ImGuiTreeNodeFlags>(flags));
}

inline bool TreeNodeEx(const std::string &label, int flags, const std::string &fmt) {
    return ImGui::TreeNodeEx(label.c_str(), static_cast<ImGuiTreeNodeFlags>(flags), fmt.c_str());
}

inline void TreePush(const std::string &str_id) { ImGui::TreePush(str_id.c_str()); }

inline void TreePop() { ImGui::TreePop(); }

inline float GetTreeNodeToLabelSpacing() { return ImGui::GetTreeNodeToLabelSpacing(); }

inline bool CollapsingHeader(const std::string &label) { return ImGui::CollapsingHeader(label.c_str()); }

inline bool CollapsingHeader(const std::string &label, int flags) {
    return ImGui::CollapsingHeader(label.c_str(), static_cast<ImGuiTreeNodeFlags>(flags));
}

inline std::tuple<bool, bool> CollapsingHeader(const std::string &label, bool open) {
    bool notCollapsed = ImGui::CollapsingHeader(label.c_str(), &open);
    return std::make_tuple(open, notCollapsed);
}

inline std::tuple<bool, bool> CollapsingHeader(const std::string &label, bool open, int flags) {
    bool notCollapsed = ImGui::CollapsingHeader(label.c_str(), &open, static_cast<ImGuiTreeNodeFlags>(flags));
    return std::make_tuple(open, notCollapsed);
}

inline void SetNextItemOpen(bool is_open) { ImGui::SetNextItemOpen(is_open); }

inline void SetNextItemOpen(bool is_open, int cond) { ImGui::SetNextItemOpen(is_open, static_cast<ImGuiCond>(cond)); }

// Widgets: Selectables
inline bool Selectable(const std::string &label) { return ImGui::Selectable(label.c_str()); }

inline bool Selectable(const std::string &label, bool selected) {
    ImGui::Selectable(label.c_str(), &selected);
    return selected;
}

inline bool Selectable(const std::string &label, bool selected, int flags) {
    ImGui::Selectable(label.c_str(), &selected, static_cast<ImGuiSelectableFlags>(flags));
    return selected;
}

inline bool Selectable(const std::string &label, bool selected, int flags, float sizeX, float sizeY) {
    ImGui::Selectable(label.c_str(), &selected, static_cast<ImGuiSelectableFlags>(flags), {sizeX, sizeY});
    return selected;
}

// Widgets: List Boxes
inline std::tuple<int, bool>
ListBox(const std::string &label, int current_item, const sol::table &items, int items_count) {
    std::vector<std::string> strings;
    for (int i{1}; i <= items_count; i++) {
        const auto &stringItem = items.get<sol::optional<std::string>>(i);
        strings.push_back(stringItem.value_or("Missing"));
    }

    std::vector<const char *> cstrings;
    cstrings.reserve(strings.size());
    for (auto &string: strings) {
        cstrings.push_back(string.c_str());
    }

    bool clicked = ImGui::ListBox(label.c_str(), &current_item, cstrings.data(), items_count);
    return std::make_tuple(current_item, clicked);
}

inline std::tuple<int, bool>
ListBox(const std::string &label, int current_item, const sol::table &items, int items_count, int height_in_items) {
    std::vector<std::string> strings;
    for (int i{1}; i <= items_count; i++) {
        const auto &stringItem = items.get<sol::optional<std::string>>(i);
        strings.push_back(stringItem.value_or("Missing"));
    }

    std::vector<const char *> cstrings;
    cstrings.reserve(strings.size());
    for (auto &string: strings) {
        cstrings.push_back(string.c_str());
    }

    bool clicked = ImGui::ListBox(label.c_str(), &current_item, cstrings.data(), items_count, height_in_items);
    return std::make_tuple(current_item, clicked);
}

inline bool ListBoxHeader(const std::string &label, float sizeX, float sizeY) {
    return ImGui::ListBoxHeader(label.c_str(), {sizeX, sizeY});
}

inline bool ListBoxHeader(const std::string &label, int items_count) {
    return ImGui::ListBoxHeader(label.c_str(), items_count);
}

inline bool ListBoxHeader(const std::string &label, int items_count, int height_in_items) {
    return ImGui::ListBoxHeader(label.c_str(), items_count, height_in_items);
}

inline void ListBoxFooter() { ImGui::ListBoxFooter(); }

// Widgets: Data Plotting (barely used and quite long functions)

// Widgets: Value() helpers
inline void Value(const std::string &prefix, bool b) { ImGui::Value(prefix.c_str(), b); }

inline void Value(const std::string &prefix, int v) { ImGui::Value(prefix.c_str(), v); }

inline void Value(const std::string &prefix, unsigned int v) { ImGui::Value(prefix.c_str(), v); }

inline void Value(const std::string &prefix, float v) { ImGui::Value(prefix.c_str(), v); }

inline void Value(const std::string &prefix, float v, const std::string &float_format) {
    ImGui::Value(prefix.c_str(), v, float_format.c_str());
}

// Widgets: Menus
inline bool BeginMenuBar() { return ImGui::BeginMenuBar(); }

inline void EndMenuBar() { ImGui::EndMenuBar(); }

inline bool BeginMainMenuBar() { return ImGui::BeginMainMenuBar(); }

inline void EndMainMenuBar() { ImGui::EndMainMenuBar(); }

inline bool BeginMenu(const std::string &label) { return ImGui::BeginMenu(label.c_str()); }

inline bool BeginMenu(const std::string &label, bool enabled) { return ImGui::BeginMenu(label.c_str(), enabled); }

inline void EndMenu() { ImGui::EndMenu(); }

inline bool MenuItem(const std::string &label) { return ImGui::MenuItem(label.c_str()); }

inline bool MenuItem(const std::string &label, const std::string &shortcut) {
    return ImGui::MenuItem(label.c_str(), shortcut.c_str());
}

inline std::tuple<bool, bool> MenuItem(
        const std::string &label,
        const std::string &shortcut,
        bool selected,
        bool enabled) {
    bool activated = ImGui::MenuItem(label.c_str(), shortcut.c_str(), &selected, enabled);
    return std::make_tuple(selected, activated);
}

void LuaBind_ImGuiWidget(sol::table &ImGui) {
// @formatter:off
#pragma region Widgets: Text
ImGui.set_function("TextUnformatted", TextUnformatted);
ImGui.set_function("Text", Text);
ImGui.set_function("TextColored", TextColored);
ImGui.set_function("TextDisabled", TextDisabled);
ImGui.set_function("TextWrapped", TextWrapped);
ImGui.set_function("LabelText", LabelText);
ImGui.set_function("BulletText", BulletText);
#pragma endregion Widgets: Text

#pragma region Widgets: Main
ImGui.set_function("Button", sol::overload(
sol::resolve<bool(const std::string &)>(Button),
sol::resolve<bool(const std::string &, float, float)>(Button)
));
ImGui.set_function("SmallButton", SmallButton);
ImGui.set_function("InvisibleButton", InvisibleButton);
ImGui.set_function("ArrowButton", ArrowButton);
ImGui.set_function("Image", Image);
ImGui.set_function("Checkbox", Checkbox);
ImGui.set_function("RadioButton", sol::overload(
sol::resolve<bool(const std::string &, bool)>(RadioButton),
sol::resolve<std::tuple<int, bool>(const std::string &, int, int)>(RadioButton)
));
ImGui.set_function("ProgressBar", sol::overload(
sol::resolve<void(float)>(ProgressBar),
sol::resolve<void(float, float, float)>(ProgressBar),
sol::resolve<void(float, float, float, const std::string &)>(ProgressBar)
));
ImGui.set_function("Bullet", Bullet);
#pragma endregion Widgets: Main

#pragma region Widgets: Combo Box
ImGui.set_function("BeginCombo", sol::overload(
sol::resolve<bool(const std::string &, const std::string &)>(BeginCombo),
sol::resolve<bool(const std::string &, const std::string &, int)>(BeginCombo)
));
ImGui.set_function("EndCombo", EndCombo);
ImGui.set_function("Combo", sol::overload(
sol::resolve<std::tuple<int, bool>(const std::string &, int, const sol::table &, int)>(Combo),
sol::resolve<std::tuple<int, bool>(const std::string &, int, const sol::table &, int, int)>(Combo),
sol::resolve<std::tuple<int, bool>(const std::string &, int, const std::string &)>(Combo),
sol::resolve<std::tuple<int, bool>(const std::string &, int, const std::string &, int)>(Combo)
));
#pragma endregion Widgets: Combo Box
// @formatter:off
#pragma region Widgets: Drags
ImGui.set_function("DragFloat" , sol::overload(
sol::resolve<std::tuple<float, bool>(const std::string&, float)>(DragFloat),
sol::resolve<std::tuple<float, bool>(const std::string&, float, float)>(DragFloat),
sol::resolve<std::tuple<float, bool>(const std::string&, float, float, float)>(DragFloat),
sol::resolve<std::tuple<float, bool>(const std::string&, float, float, float, float)>(DragFloat),
sol::resolve<std::tuple<float, bool>(const std::string&, float, float, float, float, const std::string&)>(DragFloat),
sol::resolve<std::tuple<float, bool>(const std::string&, float, float, float, float, const std::string&, float)>(DragFloat)
));
ImGui.set_function("DragFloat2" , sol::overload(
sol::resolve<std::tuple<sol::as_table_t<std::vector<float>>, bool>(const std::string&, const sol::table&)>(DragFloat2),
sol::resolve<std::tuple<sol::as_table_t<std::vector<float>>, bool>(const std::string&, const sol::table&, float)>(DragFloat2),
sol::resolve<std::tuple<sol::as_table_t<std::vector<float>>, bool>(const std::string&, const sol::table&, float, float)>(DragFloat2),
sol::resolve<std::tuple<sol::as_table_t<std::vector<float>>, bool>(const std::string&, const sol::table&, float, float, float)>(DragFloat2),
sol::resolve<std::tuple<sol::as_table_t<std::vector<float>>, bool>(const std::string&, const sol::table&, float, float, float, const std::string&)>(DragFloat2),
sol::resolve<std::tuple<sol::as_table_t<std::vector<float>>, bool>(const std::string&, const sol::table&, float, float, float, const std::string&, float)>(DragFloat2)
));
ImGui.set_function("DragFloat3" , sol::overload(
sol::resolve<std::tuple<sol::as_table_t<std::vector<float>>, bool>(const std::string&, const sol::table&)>(DragFloat3),
sol::resolve<std::tuple<sol::as_table_t<std::vector<float>>, bool>(const std::string&, const sol::table&, float)>(DragFloat3),
sol::resolve<std::tuple<sol::as_table_t<std::vector<float>>, bool>(const std::string&, const sol::table&, float, float)>(DragFloat3),
sol::resolve<std::tuple<sol::as_table_t<std::vector<float>>, bool>(const std::string&, const sol::table&, float, float, float)>(DragFloat3),
sol::resolve<std::tuple<sol::as_table_t<std::vector<float>>, bool>(const std::string&, const sol::table&, float, float, float, const std::string&)>(DragFloat3),
sol::resolve<std::tuple<sol::as_table_t<std::vector<float>>, bool>(const std::string&, const sol::table&, float, float, float, const std::string&, float)>(DragFloat3)
));
ImGui.set_function("DragFloat4" , sol::overload(
sol::resolve<std::tuple<sol::as_table_t<std::vector<float>>, bool>(const std::string&, const sol::table&)>(DragFloat4),
sol::resolve<std::tuple<sol::as_table_t<std::vector<float>>, bool>(const std::string&, const sol::table&, float)>(DragFloat4),
sol::resolve<std::tuple<sol::as_table_t<std::vector<float>>, bool>(const std::string&, const sol::table&, float, float)>(DragFloat4),
sol::resolve<std::tuple<sol::as_table_t<std::vector<float>>, bool>(const std::string&, const sol::table&, float, float, float)>(DragFloat4),
sol::resolve<std::tuple<sol::as_table_t<std::vector<float>>, bool>(const std::string&, const sol::table&, float, float, float, const std::string&)>(DragFloat4),
sol::resolve<std::tuple<sol::as_table_t<std::vector<float>>, bool>(const std::string&, const sol::table&, float, float, float, const std::string&, float)>(DragFloat4)
));
ImGui.set_function("DragInt" , sol::overload(
sol::resolve<std::tuple<int, bool>(const std::string&, int)>(DragInt),
sol::resolve<std::tuple<int, bool>(const std::string&, int, float)>(DragInt),
sol::resolve<std::tuple<int, bool>(const std::string&, int, float, int)>(DragInt),
sol::resolve<std::tuple<int, bool>(const std::string&, int, float, int, int)>(DragInt),
sol::resolve<std::tuple<int, bool>(const std::string&, int, float, int, int, const std::string&)>(DragInt)
));
ImGui.set_function("DragInt2" , sol::overload(
sol::resolve<std::tuple<sol::as_table_t<std::vector<int>>, bool>(const std::string&, const sol::table&)>(DragInt2),
sol::resolve<std::tuple<sol::as_table_t<std::vector<int>>, bool>(const std::string&, const sol::table&, float)>(DragInt2),
sol::resolve<std::tuple<sol::as_table_t<std::vector<int>>, bool>(const std::string&, const sol::table&, float, int)>(DragInt2),
sol::resolve<std::tuple<sol::as_table_t<std::vector<int>>, bool>(const std::string&, const sol::table&, float, int, int)>(DragInt2),
sol::resolve<std::tuple<sol::as_table_t<std::vector<int>>, bool>(const std::string&, const sol::table&, float, int, int, const std::string&)>(DragInt2)
));
ImGui.set_function("DragInt3" , sol::overload(
sol::resolve<std::tuple<sol::as_table_t<std::vector<int>>, bool>(const std::string&, const sol::table&)>(DragInt3),
sol::resolve<std::tuple<sol::as_table_t<std::vector<int>>, bool>(const std::string&, const sol::table&, float)>(DragInt3),
sol::resolve<std::tuple<sol::as_table_t<std::vector<int>>, bool>(const std::string&, const sol::table&, float, int)>(DragInt3),
sol::resolve<std::tuple<sol::as_table_t<std::vector<int>>, bool>(const std::string&, const sol::table&, float, int, int)>(DragInt3),
sol::resolve<std::tuple<sol::as_table_t<std::vector<int>>, bool>(const std::string&, const sol::table&, float, int, int, const std::string&)>(DragInt3)
));
ImGui.set_function("DragInt4" , sol::overload(
sol::resolve<std::tuple<sol::as_table_t<std::vector<int>>, bool>(const std::string&, const sol::table&)>(DragInt4),
sol::resolve<std::tuple<sol::as_table_t<std::vector<int>>, bool>(const std::string&, const sol::table&, float)>(DragInt4),
sol::resolve<std::tuple<sol::as_table_t<std::vector<int>>, bool>(const std::string&, const sol::table&, float, int)>(DragInt4),
sol::resolve<std::tuple<sol::as_table_t<std::vector<int>>, bool>(const std::string&, const sol::table&, float, int, int)>(DragInt4),
sol::resolve<std::tuple<sol::as_table_t<std::vector<int>>, bool>(const std::string&, const sol::table&, float, int, int, const std::string&)>(DragInt4)
));
#pragma endregion Widgets: Drags

#pragma region Widgets: Sliders
ImGui.set_function("SliderFloat" , sol::overload(
sol::resolve<std::tuple<float, bool>(const std::string&, float, float, float)>(SliderFloat),
sol::resolve<std::tuple<float, bool>(const std::string&, float, float, float, const std::string&)>(SliderFloat),
sol::resolve<std::tuple<float, bool>(const std::string&, float, float, float, const std::string&, float)>(SliderFloat)
));
ImGui.set_function("SliderFloat2" , sol::overload(
sol::resolve<std::tuple<sol::as_table_t<std::vector<float>>, bool>(const std::string&, const sol::table&, float, float)>(SliderFloat2),
sol::resolve<std::tuple<sol::as_table_t<std::vector<float>>, bool>(const std::string&, const sol::table&, float, float, const std::string&)>(SliderFloat2),
sol::resolve<std::tuple<sol::as_table_t<std::vector<float>>, bool>(const std::string&, const sol::table&, float, float, const std::string&, float)>(SliderFloat2)
));
ImGui.set_function("SliderFloat3" , sol::overload(
sol::resolve<std::tuple<sol::as_table_t<std::vector<float>>, bool>(const std::string&, const sol::table&, float, float)>(SliderFloat3),
sol::resolve<std::tuple<sol::as_table_t<std::vector<float>>, bool>(const std::string&, const sol::table&, float, float, const std::string&)>(SliderFloat3),
sol::resolve<std::tuple<sol::as_table_t<std::vector<float>>, bool>(const std::string&, const sol::table&, float, float, const std::string&, float)>(SliderFloat3)
));
ImGui.set_function("SliderFloat4" , sol::overload(
sol::resolve<std::tuple<sol::as_table_t<std::vector<float>>, bool>(const std::string&, const sol::table&, float, float)>(SliderFloat4),
sol::resolve<std::tuple<sol::as_table_t<std::vector<float>>, bool>(const std::string&, const sol::table&, float, float, const std::string&)>(SliderFloat4),
sol::resolve<std::tuple<sol::as_table_t<std::vector<float>>, bool>(const std::string&, const sol::table&, float, float, const std::string&, float)>(SliderFloat4)
));
ImGui.set_function("SliderAngle" , sol::overload(
sol::resolve<std::tuple<float, bool>(const std::string&, float)>(SliderAngle),
sol::resolve<std::tuple<float, bool>(const std::string&, float, float)>(SliderAngle),
sol::resolve<std::tuple<float, bool>(const std::string&, float, float, float)>(SliderAngle),
sol::resolve<std::tuple<float, bool>(const std::string&, float, float, float, const std::string&)>(SliderAngle)
));
ImGui.set_function("SliderInt" , sol::overload(
sol::resolve<std::tuple<int, bool>(const std::string&, int, int, int)>(SliderInt),
sol::resolve<std::tuple<int, bool>(const std::string&, int, int, int, const std::string&)>(SliderInt)
));
ImGui.set_function("SliderInt2" , sol::overload(
sol::resolve<std::tuple<sol::as_table_t<std::vector<int>>, bool>(const std::string&, const sol::table&, int, int)>(SliderInt2),
sol::resolve<std::tuple<sol::as_table_t<std::vector<int>>, bool>(const std::string&, const sol::table&, int, int, const std::string&)>(SliderInt2)
));
ImGui.set_function("SliderInt3" , sol::overload(
sol::resolve<std::tuple<sol::as_table_t<std::vector<int>>, bool>(const std::string&, const sol::table&, int, int)>(SliderInt3),
sol::resolve<std::tuple<sol::as_table_t<std::vector<int>>, bool>(const std::string&, const sol::table&, int, int, const std::string&)>(SliderInt3)
));
ImGui.set_function("SliderInt4" , sol::overload(
sol::resolve<std::tuple<sol::as_table_t<std::vector<int>>, bool>(const std::string&, const sol::table&, int, int)>(SliderInt4),
sol::resolve<std::tuple<sol::as_table_t<std::vector<int>>, bool>(const std::string&, const sol::table&, int, int, const std::string&)>(SliderInt4)
));
ImGui.set_function("VSliderFloat" , sol::overload(
sol::resolve<std::tuple<float, bool>(const std::string&, float, float, float, float, float)>(VSliderFloat),
sol::resolve<std::tuple<float, bool>(const std::string&, float, float, float, float, float, const std::string&)>(VSliderFloat),
sol::resolve<std::tuple<float, bool>(const std::string&, float, float, float, float, float, const std::string&, int)>(VSliderFloat)
));
ImGui.set_function("VSliderInt" , sol::overload(
sol::resolve<std::tuple<int, bool>(const std::string&, float, float, int, int, int)>(VSliderInt),
sol::resolve<std::tuple<int, bool>(const std::string&, float, float, int, int, int, const std::string&)>(VSliderInt)
));
#pragma endregion Widgets: Sliders

#pragma region Widgets: Inputs using Keyboard
ImGui.set_function("InputText" , sol::overload(
sol::resolve<std::tuple<std::string, bool>(const std::string&, std::string, unsigned int)>(InputText),
sol::resolve<std::tuple<std::string, bool>(const std::string&, std::string, unsigned int, int)>(InputText)
));
ImGui.set_function("InputTextMultiline" , sol::overload(
sol::resolve<std::tuple<std::string, bool>(const std::string&, std::string, unsigned int)>(InputTextMultiline),
sol::resolve<std::tuple<std::string, bool>(const std::string&, std::string, unsigned int, float, float)>(InputTextMultiline),
sol::resolve<std::tuple<std::string, bool>(const std::string&, std::string, unsigned int, float, float, int)>(InputTextMultiline)
));
ImGui.set_function("InputTextWithHint"  , sol::overload(
sol::resolve<std::tuple<std::string, bool>(const std::string&, const std::string&, std::string, unsigned int)>(InputTextWithHint),
sol::resolve<std::tuple<std::string, bool>(const std::string&, const std::string&, std::string, unsigned int, int)>(InputTextWithHint)
));
ImGui.set_function("InputFloat" , sol::overload(
sol::resolve<std::tuple<float, bool>(const std::string&, float)>(InputFloat),
sol::resolve<std::tuple<float, bool>(const std::string&, float, float)>(InputFloat),
sol::resolve<std::tuple<float, bool>(const std::string&, float, float, float)>(InputFloat),
sol::resolve<std::tuple<float, bool>(const std::string&, float, float, float, const std::string&)>(InputFloat),
sol::resolve<std::tuple<float, bool>(const std::string&, float, float, float, const std::string&, int)>(InputFloat)
));
ImGui.set_function("InputFloat2" , sol::overload(
sol::resolve<std::tuple<sol::as_table_t<std::vector<float>>, bool>(const std::string&, const sol::table&)>(InputFloat2),
sol::resolve<std::tuple<sol::as_table_t<std::vector<float>>, bool>(const std::string&, const sol::table&, const std::string&)>(InputFloat2),
sol::resolve<std::tuple<sol::as_table_t<std::vector<float>>, bool>(const std::string&, const sol::table&, const std::string&, int)>(InputFloat2)
));
ImGui.set_function("InputFloat3" , sol::overload(
sol::resolve<std::tuple<sol::as_table_t<std::vector<float>>, bool>(const std::string&, const sol::table&)>(InputFloat3),
sol::resolve<std::tuple<sol::as_table_t<std::vector<float>>, bool>(const std::string&, const sol::table&, const std::string&)>(InputFloat3),
sol::resolve<std::tuple<sol::as_table_t<std::vector<float>>, bool>(const std::string&, const sol::table&, const std::string&, int)>(InputFloat3)
));
ImGui.set_function("InputFloat4" , sol::overload(
sol::resolve<std::tuple<sol::as_table_t<std::vector<float>>, bool>(const std::string&, const sol::table&)>(InputFloat4),
sol::resolve<std::tuple<sol::as_table_t<std::vector<float>>, bool>(const std::string&, const sol::table&, const std::string&)>(InputFloat4),
sol::resolve<std::tuple<sol::as_table_t<std::vector<float>>, bool>(const std::string&, const sol::table&, const std::string&, int)>(InputFloat4)
));
ImGui.set_function("InputInt" , sol::overload(
sol::resolve<std::tuple<int, bool>(const std::string&, int)>(InputInt),
sol::resolve<std::tuple<int, bool>(const std::string&, int, int)>(InputInt),
sol::resolve<std::tuple<int, bool>(const std::string&, int, int, int)>(InputInt),
sol::resolve<std::tuple<int, bool>(const std::string&, int, int, int)>(InputInt),
sol::resolve<std::tuple<int, bool>(const std::string&, int, int, int, int)>(InputInt)
));
ImGui.set_function("InputInt2" , sol::overload(
sol::resolve<std::tuple<sol::as_table_t<std::vector<int>>, bool>(const std::string&, const sol::table&)>(InputInt2),
sol::resolve<std::tuple<sol::as_table_t<std::vector<int>>, bool>(const std::string&, const sol::table&, int)>(InputInt2)
));
ImGui.set_function("InputInt3" , sol::overload(
sol::resolve<std::tuple<sol::as_table_t<std::vector<int>>, bool>(const std::string&, const sol::table&)>(InputInt3),
sol::resolve<std::tuple<sol::as_table_t<std::vector<int>>, bool>(const std::string&, const sol::table&, int)>(InputInt3)
));
ImGui.set_function("InputInt4" , sol::overload(
sol::resolve<std::tuple<sol::as_table_t<std::vector<int>>, bool>(const std::string&, const sol::table&)>(InputInt4),
sol::resolve<std::tuple<sol::as_table_t<std::vector<int>>, bool>(const std::string&, const sol::table&, int)>(InputInt4)
));
ImGui.set_function("InputDouble" , sol::overload(
sol::resolve<std::tuple<double, bool>(const std::string&, double)>(InputDouble),
sol::resolve<std::tuple<double, bool>(const std::string&, double, double)>(InputDouble),
sol::resolve<std::tuple<double, bool>(const std::string&, double, double, double)>(InputDouble),
sol::resolve<std::tuple<double, bool>(const std::string&, double, double, double, const std::string&)>(InputDouble),
sol::resolve<std::tuple<double, bool>(const std::string&, double, double, double, const std::string&, int)>(InputDouble)
));
#pragma endregion Widgets: Inputs using Keyboard

#pragma region Widgets: Color Editor / Picker
ImGui.set_function("ColorEdit3" , sol::overload(
sol::resolve<std::tuple <sol::as_table_t<std::vector<float>>, bool>(const std::string&, const sol::table&)>(ColorEdit3),
sol::resolve<std::tuple <sol::as_table_t<std::vector<float>>, bool>(const std::string&, const sol::table&, int)>(ColorEdit3)
));
ImGui.set_function("ColorEdit4" , sol::overload(
sol::resolve<std::tuple <sol::as_table_t<std::vector<float>>, bool>(const std::string&, const sol::table&)>(ColorEdit4),
sol::resolve<std::tuple <sol::as_table_t<std::vector<float>>, bool>(const std::string&, const sol::table&, int)>(ColorEdit4)
));
ImGui.set_function("ColorPicker3" , sol::overload(
sol::resolve<std::tuple <sol::as_table_t<std::vector<float>>, bool>(const std::string&, const sol::table&)>(ColorPicker3),
sol::resolve<std::tuple <sol::as_table_t<std::vector<float>>, bool>(const std::string&, const sol::table&, int)>(ColorPicker3)
));
ImGui.set_function("ColorPicker4" , sol::overload(
sol::resolve<std::tuple <sol::as_table_t<std::vector<float>>, bool>(const std::string&, const sol::table&)>(ColorPicker4),
sol::resolve<std::tuple <sol::as_table_t<std::vector<float>>, bool>(const std::string&, const sol::table&, int)>(ColorPicker4)
));
#pragma endregion Widgets: Color Editor / Picker
// @formatter:on

#pragma region Widgets: Trees
ImGui.set_function("TreeNode", sol::overload(
sol::resolve<bool(const std::string &)>(TreeNode),
sol::resolve<bool(const std::string &, const std::string &)>(TreeNode)
));
ImGui.set_function("TreeNodeEx", sol::overload(
sol::resolve<bool(const std::string &)>(TreeNodeEx),
sol::resolve<bool(const std::string &, int)>(TreeNodeEx),
sol::resolve<bool(const std::string &, int, const std::string &)>(TreeNodeEx)
));
ImGui.set_function("TreePush", TreePush);
ImGui.set_function("TreePop", TreePop);
ImGui.set_function("GetTreeNodeToLabelSpacing", GetTreeNodeToLabelSpacing);
ImGui.set_function("CollapsingHeader", sol::overload(
sol::resolve<bool(const std::string &)>(CollapsingHeader),
sol::resolve<bool(const std::string &, int)>(CollapsingHeader),
sol::resolve<std::tuple<bool, bool>(const std::string &, bool)>(CollapsingHeader),
sol::resolve<std::tuple<bool, bool>(const std::string &, bool, int)>(CollapsingHeader)
));
ImGui.set_function("SetNextItemOpen", sol::overload(
sol::resolve<void(bool)>(SetNextItemOpen),
sol::resolve<void(bool, int)>(SetNextItemOpen)
));
#pragma endregion Widgets: Trees

#pragma region Widgets: Selectables
ImGui.set_function("Selectable", sol::overload(
sol::resolve<bool(const std::string &)>(Selectable),
sol::resolve<bool(const std::string &, bool)>(Selectable),
sol::resolve<bool(const std::string &, bool, int)>(Selectable),
sol::resolve<bool(const std::string &, bool, int, float, float)>(Selectable)
));
#pragma endregion Widgets: Selectables

#pragma region Widgets: List Boxes
ImGui.set_function("ListBox", sol::overload(
sol::resolve<std::tuple<int, bool>(const std::string &, int, const sol::table &, int)>(ListBox),
sol::resolve<std::tuple<int, bool>(const std::string &, int, const sol::table &, int, int)>(ListBox)
));
ImGui.set_function("ListBoxHeader", sol::overload(
sol::resolve<bool(const std::string &, float, float)>(ListBoxHeader),
sol::resolve<bool(const std::string &, int)>(ListBoxHeader),
sol::resolve<bool(const std::string &, int, int)>(ListBoxHeader)
));
ImGui.set_function("ListBoxFooter", ListBoxFooter);
#pragma endregion Widgets: List Boxes

#pragma region Widgets: Value() Helpers
ImGui.set_function("Value", sol::overload(
sol::resolve<void(const std::string &, bool)>(Value),
sol::resolve<void(const std::string &, int)>(Value),
sol::resolve<void(const std::string &, unsigned int)>(Value),
sol::resolve<void(const std::string &, float)>(Value),
sol::resolve<void(const std::string &, float, const std::string &)>(Value)
));
#pragma endregion Widgets: Value() Helpers

#pragma region Widgets: Menu
ImGui.set_function("BeginMenuBar", BeginMenuBar);
ImGui.set_function("EndMenuBar", EndMenuBar);
ImGui.set_function("BeginMainMenuBar", BeginMainMenuBar);
ImGui.set_function("EndMainMenuBar", EndMainMenuBar);
ImGui.set_function("BeginMenu", sol::overload(
sol::resolve<bool(const std::string &)>(BeginMenu),
sol::resolve<bool(const std::string &, bool)>(BeginMenu)
));
ImGui.set_function("EndMenu", EndMenu);
ImGui.set_function("MenuItem", sol::overload(
sol::resolve<bool(const std::string &)>(MenuItem),
sol::resolve<bool(const std::string &, const std::string &)>(MenuItem),
sol::resolve<std::tuple<bool, bool>(const std::string &, const std::string &, bool, bool)>(MenuItem)
));
#pragma endregion Widgets: Menu
// @formatter:on
}
}