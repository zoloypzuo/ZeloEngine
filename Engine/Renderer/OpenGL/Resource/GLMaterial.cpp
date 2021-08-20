// GLMaterial.cpp
// created on 2021/8/1
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GLMaterial.h"

using namespace Zelo::Renderer::OpenGL;

GLMaterial::~GLMaterial() = default;

void GLMaterial::bind() const {
    m_diffuseMap.bind(0);
    m_normalMap.bind(1);
    m_specularMap.bind(2);
}

GLMaterial::GLMaterial(GLTexture &diffuseMap, GLTexture &normalMap, GLTexture &specularMap) :
        m_diffuseMap(diffuseMap),
        m_normalMap(normalMap),
        m_specularMap(specularMap) {

}

