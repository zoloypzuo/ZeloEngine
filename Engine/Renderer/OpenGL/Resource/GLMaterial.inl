// GLMaterial.h
// created on 2021/8/1
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "Core/RHI/Resource/Material.h"
#include "Renderer/OpenGL/Resource/GLTexture.h"
#include "Renderer/OpenGL/Resource/GLSLShaderProgram.h"

namespace Zelo::Renderer::OpenGL {
template<typename T>
void GLMaterial::set(const std::string &key, const T &value) {
    if (hasShader()) {
        if (m_uniformsData.find(key) != m_uniformsData.end()) {
            m_uniformsData[key] = std::any(value);
        }
    } else {
        ZELO_ERROR("Material set failed: no attached shader");
    }
}

template<typename T>
const T &GLMaterial::get(const std::string &key) {
    if (m_uniformsData.find(key) != m_uniformsData.end()) {
        return T();
    } else {
        return std::any_cast<T>(m_uniformsData.at(key));
    }
}
}


