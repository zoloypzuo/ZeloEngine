// Mathf.h
// created on 2020/2/5
// author @zoloypzuo

#ifndef ZELOSPEED_MATHF_H
#define ZELOSPEED_MATHF_H

struct Mathf {
    static float Deg2Rad;  // Degrees-to-radians conversion constant (Read Only).
    static float Epsilon;  // A tiny floating point value (Read Only).
    static float Infinity;  // A representation of positive infinity (Read Only).
    static float NegativeInfinity;  // A representation of negative infinity (Read Only).
    static float PI;   // The well-known 3.14159265358979... value (Read Only).
    static float Rad2Deg;  // Radians-to-degrees conversion constant (Read Only).

    // Compares two floating point values and returns true if they are similar.
    static bool Approximately(float a, float b);

    static float Clamp(float value, float min, float max);

    static float Clamp01(float value);

    static float Sin(float f);

    static float Cos(float f);
};

#endif //ZELOSPEED_MATHF_H