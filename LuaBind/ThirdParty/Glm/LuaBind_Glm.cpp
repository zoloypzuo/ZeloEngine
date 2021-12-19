#include <glm/glm.hpp>
#include <sol/sol.hpp>

void LuaBind_Glm(sol::state &luaState) {
// @formatter:off
luaState.new_usertype<glm::vec3>("vec3",
sol::constructors<
    glm::vec3(),
    glm::vec3(float),
    glm::vec3(float, float, float)>(),
"x", &glm::vec3::x,
"y", &glm::vec3::y,
"z", &glm::vec3::z,
sol::meta_function::multiplication, sol::overload(
    [](const glm::vec3 &v1, const glm::vec3 &v2) -> glm::vec3 { return v1 * v2; },
    [](const glm::vec3 &v1, float f) -> glm::vec3 { return v1 * f; },
    [](float f, const glm::vec3 &v1) -> glm::vec3 { return f * v1; }
),
"__Dummy", [] {}
);
// @formatter:on
}
