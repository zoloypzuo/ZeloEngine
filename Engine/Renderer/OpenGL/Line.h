//
// Created by zuoyiping01 on 2021/3/31.
//

#ifndef ZELOENGINE_LINE_H
#define ZELOENGINE_LINE_H

#include "ZeloPrerequisites.h"
#include "GLSLShaderProgram.h"

class Line {
public:
    Line(glm::vec3 v1, glm::vec3 v2);

    ~Line();

    void render(GLSLShaderProgram *shader) const;

private:
#if !defined(GLES2)
    GLuint vao{};
#endif
    GLuint vbo{};
};


#endif //ZELOENGINE_LINE_H
