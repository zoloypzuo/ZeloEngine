// Mathf.cpp
// created on 2020/2/5
// author @zoloypzuo

#include <DirectXMath.h>
#include <cmath>  // for float computation
#include "Mathf.h"

using namespace DirectX;

float Mathf::Deg2Rad = 2 * XM_2PI / 360;
float Mathf::Epsilon = 1.401298e-45f;
float Mathf::Infinity = 1.0f / 0.0;
float Mathf::NegativeInfinity = -1.0f / 0.0;
float Mathf::PI = XM_PI;
float Mathf::Rad2Deg = 1 / Deg2Rad;

bool Mathf::Approximately(float a, float b) {
    return XMScalarNearEqual(a, b, Epsilon);
}

float Mathf::Clamp(float value, float min, float max) {
    return value < min ? min : value > max ? max : value;
}

float Mathf::Clamp01(float value) {
    return value < 0 ? 0 : value > 1 ? 1 : value;
}

float Mathf::Sin(float f) {
    return sinf(f);
}

float Mathf::Cos(float f) {
    return cosf(f);
}
