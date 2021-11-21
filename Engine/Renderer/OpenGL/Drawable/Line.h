#ifndef ZELOENGINE_LINE_H
#define ZELOENGINE_LINE_H

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"
#include "Renderer/OpenGL/Resource/GLSLShaderProgram.h"

class Line {
public:
    Line(glm::vec3 v1, glm::vec3 v2);

    ~Line();

    void render() const;

private:
    GLuint vao{};
    GLuint vbo{};
};

#endif //ZELOENGINE_LINE_H
