// GLMaterial.cpp
// created on 2021/8/1
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GLMaterial.h"
#include "Renderer/OpenGL/Buffer/GLUniformBuffer.h"

using namespace Zelo::Core::RHI;
using namespace Zelo::Renderer::OpenGL;

GLMaterial::~GLMaterial() = default;

void GLMaterial::bind() const {
    m_diffuseMap.bind(0);
    m_normalMap.bind(1);
    m_specularMap.bind(2);
    if (!hasShader()) { return; }
    m_shader->bind();
//    int textureSlot = 0;
    for (const auto&[name, value]: m_uniformsData) {
        auto *uniformData = m_shader->getUniformInfo(name);
        if (!uniformData) { continue; }
        switch (uniformData->type) {
            case UniformType::UNIFORM_BOOL:
                if (value.type() == typeid(bool)) m_shader->setUniform1i(name, std::any_cast<bool>(value));
                break;
            case UniformType::UNIFORM_INT:
                if (value.type() == typeid(int)) m_shader->setUniform1i(name, std::any_cast<int>(value));
                break;
            case UniformType::UNIFORM_FLOAT:
                if (value.type() == typeid(float)) m_shader->setUniform1f(name, std::any_cast<float>(value));
                break;
            case UniformType::UNIFORM_FLOAT_VEC2:
// TODO
//                if (value.type() == typeid(FVector2))
//                    m_shader->set(name, std::any_cast<FVector2>(value));
                break;
            case UniformType::UNIFORM_FLOAT_VEC3:
                if (value.type() == typeid(glm::vec3))
                    m_shader->setUniformVec3f(name, std::any_cast<glm::vec3>(value));
                break;
            case UniformType::UNIFORM_FLOAT_VEC4:
                if (value.type() == typeid(glm::vec4))
                    m_shader->setUniformVec4f(name, std::any_cast<glm::vec4>(value));
                break;
            case UniformType::UNIFORM_SAMPLER_2D: {
// TODO
//                if (value.type() == typeid(Texture * )) {
//                    if (auto tex = std::any_cast<Texture *>(value); tex) {
//                        tex->Bind(textureSlot);
//                        m_shader->SetUniformInt(uniformData->name, textureSlot++);
//                    } else if (emptyTexture) {
//                        emptyTexture->Bind(textureSlot);
//                        m_shader->SetUniformInt(uniformData->name, textureSlot++);
//                    }
//                }
            }
            default:
//                ZELO_ERROR("not implemented");
                break;
        }
    }
}

GLMaterial::GLMaterial(GLTexture &diffuseMap, GLTexture &normalMap, GLTexture &specularMap) :
        m_diffuseMap(diffuseMap),
        m_normalMap(normalMap),
        m_specularMap(specularMap) {

}

void GLMaterial::unbind() {
    if (hasShader()) {
        m_shader->unbind();
    }
}

void GLMaterial::setShader(std::shared_ptr<Shader> shader) {
    m_shader = std::dynamic_pointer_cast<GLSLShaderProgram>(shader);
    ZELO_ASSERT(m_shader, "shader cast failed");
    if (m_shader) {
        GLUniformBuffer::bindBlockToShader(*m_shader, "EngineUBO");
        fillUniforms();
    } else {
        m_uniformsData.clear();
    }
}

bool GLMaterial::hasShader() const {
    return m_shader != nullptr;
}

void GLMaterial::fillUniforms() {
    m_uniformsData.clear();
    for (const auto &element: m_shader->m_uniforms) {
        m_uniformsData.emplace(element.name, element.defaultValue);
    }
}

std::map<std::string, std::any> GLMaterial::getUniformsData() const {
    return m_uniformsData;
}

