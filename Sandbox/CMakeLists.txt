include_directories(./)

add_subdirectory(_Template)
add_subdirectory(GLSLBook)
add_subdirectory(Craft)
add_subdirectory(GRCookbook)

set_target_properties(TemplateSandbox PROPERTIES FOLDER "Sandbox")
set_target_properties(GLSLBook PROPERTIES FOLDER "Sandbox")
set_target_properties(Craft PROPERTIES FOLDER "Sandbox")
set_target_properties(GRCookbook PROPERTIES FOLDER "Sandbox")
