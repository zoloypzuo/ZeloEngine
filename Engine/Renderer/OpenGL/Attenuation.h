// Attenuation.h
// created on 2021/3/31
// author @zoloypzuo

#ifndef ZELOENGINE_ATTENUATION_H
#define ZELOENGINE_ATTENUATION_H

#include "ZeloPrerequisites.h"


class Attenuation {
public:
    Attenuation(float constant, float linear, float exponent);

    float getConstant() const;

    float getLinear() const;

    float getExponent() const;

// private:
    float m_constant;
    float m_linear;
    float m_exponent;
};


#endif //ZELOENGINE_ATTENUATION_H