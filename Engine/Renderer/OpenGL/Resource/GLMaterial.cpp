// GLMaterial.cpp
// created on 2021/8/1
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GLMaterial.h"

#include <utility>

using namespace Zelo::Renderer::OpenGL;

GLMaterial::~GLMaterial() = default;

void GLMaterial::bind() const {
    if (!hasShader())
        return;
    m_diffuseMap.bind(0);
    m_normalMap.bind(1);
    m_specularMap.bind(2);
    // TODO
    m_shader->bind();
    //
    //int textureSlot = 0;
    //
    //for (auto&[name, value] : m_uniformsData) {
    //    auto uniformData = m_shader->GetUniformInfo(name);
    //
    //    if (uniformData) {
    //        switch (uniformData->type) {
    //            case UniformType::UNIFORM_BOOL:
    //                if (value.type() == typeid(bool)) m_shader->SetUniformInt(name, std::any_cast<bool>(value));
    //                break;
    //            case UniformType::UNIFORM_INT:
    //                if (value.type() == typeid(int)) m_shader->SetUniformInt(name, std::any_cast<int>(value));
    //                break;
    //            case UniformType::UNIFORM_FLOAT:
    //                if (value.type() == typeid(float)) m_shader->SetUniformFloat(name, std::any_cast<float>(value));
    //                break;
    //            case UniformType::UNIFORM_FLOAT_VEC2:
    //                if (value.type() == typeid(FVector2))
    //                    m_shader->SetUniformVec2(name, std::any_cast<FVector2>(value));
    //                break;
    //            case UniformType::UNIFORM_FLOAT_VEC3:
    //                if (value.type() == typeid(FVector3))
    //                    m_shader->SetUniformVec3(name, std::any_cast<FVector3>(value));
    //                break;
    //            case UniformType::UNIFORM_FLOAT_VEC4:
    //                if (value.type() == typeid(FVector4))
    //                    m_shader->SetUniformVec4(name, std::any_cast<FVector4>(value));
    //                break;
    //            case UniformType::UNIFORM_SAMPLER_2D: {
    //                if (value.type() == typeid(Texture * )) {
    //                    if (auto tex = std::any_cast<Texture *>(value); tex) {
    //                        tex->Bind(textureSlot);
    //                        m_shader->SetUniformInt(uniformData->name, textureSlot++);
    //                    } else if (emptyTexture) {
    //                        emptyTexture->Bind(textureSlot);
    //                        m_shader->SetUniformInt(uniformData->name, textureSlot++);
    //                    }
    //                }
    //            }
    //        }
    //    }
    //}
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

void GLMaterial::setShader(std::shared_ptr<GLSLShaderProgram> shader) {
    m_shader = std::move(shader);
    if (m_shader) {
        // TODO
        //UniformBuffer::BindBlockToShader(*m_shader, "EngineUBO");
        //        FillUniform();
    } else {
        m_uniformsData.clear();
    }
}

bool GLMaterial::hasShader() const {
    return m_shader != nullptr;
}

void GLMaterial::fillUniforms() {
    m_uniformsData.clear();
    for (const auto &element : m_shader->m_uniforms) {
        m_uniformsData.emplace(element.name, element.defaultValue);
    }
}

std::map<std::string, std::any> GLMaterial::getUniformsData() const {
    return m_uniformsData;
}

