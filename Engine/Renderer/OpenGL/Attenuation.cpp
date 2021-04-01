// Attenuation.cpp
// created on 2021/3/31
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "Attenuation.h"

Attenuation::Attenuation(float constant, float linear, float exponent) {
    m_constant = constant;
    m_linear = linear;
    m_exponent = exponent;
}

float Attenuation::getConstant() const {
    return m_constant;
}

float Attenuation::getLinear() const {
    return m_linear;
}

float Attenuation::getExponent() const {
    return m_exponent;
}
