'''struct in UnityEngine/Implemented in:UnityEngine.CoreModule
Description
A collection of common math functions.'''
import math


class Mathf():
    # region Static Properties
    Deg2Rad = 2.0 * math.pi / 360.0  # Degrees-to-radians conversion constant (Read Only).
    Epsilon = 1.401298e-45  # A tiny floating point value (Read Only).
    Infinity = 1.0 / 0.0  # A representation of positive infinity (Read Only).
    NegativeInfinity = -1.0 / 0.0  # A representation of negative infinity (Read Only).
    PI = math.pi  # The well-known 3.14159265358979... value (Read Only).
    Rad2Deg = None  # Radians-to-degrees conversion constant (Read Only).

    # endregion
    # region Static Methods
    @staticmethod
    def Abs(f):
        '''Returns the absolute value of f.'''
        return math.fabs(f)

    @staticmethod
    def Acos(f):
        '''Returns the arc-cosine of f - the angle in radians whose cosine is f.'''
        return math.acos(f)

    @staticmethod
    def Approximately(f):
        '''Compares two floating point values and returns true if they are similar.'''
        pass

    @staticmethod
    def Asin(f):
        '''Returns the arc-sine of f - the angle in radians whose sine is f.'''
        return math.asin(f)

    @staticmethod
    def Atan(f):
        '''Returns the arc-tangent of f - the angle in radians whose tangent is f.'''
        return math.atan(f)

    @staticmethod
    def Atan2(y, x):
        '''Returns the angle in radians whose Tan is y/x.'''
        return math.atan2(y, x)

    @staticmethod
    def Ceil():
        '''Returns the smallest integer greater to or equal to f.'''
        pass

    @staticmethod
    def CeilToInt():
        '''Returns the smallest integer greater to or equal to f.'''
        pass

    @staticmethod
    def Clamp():
        '''Clamps a value between a minimum float and maximum float value.'''
        pass

    @staticmethod
    def Clamp01():
        '''Clamps value between 0 and 1 and returns value.'''
        pass

    @staticmethod
    def ClosestPowerOfTwo():
        '''Returns the closest power of two value.'''
        pass

    @staticmethod
    def CorrelatedColorTemperatureToRGB():
        '''Convert a color temperature in Kelvin to RGB color.'''
        pass

    @staticmethod
    def Cos(f):
        '''Returns the cosine of angle f.'''
        return math.cos(f)

    @staticmethod
    def DeltaAngle():
        '''Calculates the shortest difference between two given angles given in degrees.'''
        pass

    @staticmethod
    def Exp(f):
        '''Returns e raised to the specified power.'''
        return math.exp(f)

    @staticmethod
    def Floor():
        '''Returns the largest integer smaller than or equal to f.'''
        pass

    @staticmethod
    def FloorToInt():
        '''Returns the largest integer smaller to or equal to f.'''
        pass

    @staticmethod
    def GammaToLinearSpace():
        '''Converts the given value from gamma (sRGB) to linear color space.'''
        pass

    @staticmethod
    def InverseLerp():
        '''Calculates the linear parameter t that produces the interpolant value within the range [a, b].'''
        pass

    @staticmethod
    def IsPowerOfTwo():
        '''Returns true if the value is power of two.'''
        pass

    @staticmethod
    def Lerp():
        '''Linearly interpolates between a and b by t.'''
        pass

    @staticmethod
    def LerpAngle():
        '''Same as Lerp but makes sure the values interpolate correctly when they wrap around 360 degrees.'''
        pass

    @staticmethod
    def LerpUnclamped():
        '''Linearly interpolates between a and b by t with no limit to t.'''
        pass

    @staticmethod
    def LinearToGammaSpace():
        '''Converts the given value from linear to gamma (sRGB) color space.'''
        pass

    @staticmethod
    def Log():
        '''Returns the logarithm of a specified number in a specified base.'''
        pass

    @staticmethod
    def Log10():
        '''Returns the base 10 logarithm of a specified number.'''
        pass

    @staticmethod
    def Max(*args, key=None):
        '''Returns largest of two or more values.'''
        return max(*args, key=key)

    @staticmethod
    def Min(*args, key=None):
        '''Returns the smallest of two or more values.'''
        return min(*args, key=key)

    @staticmethod
    def MoveTowards():
        '''Moves a value current towards target.'''
        pass

    @staticmethod
    def MoveTowardsAngle():
        '''Same as MoveTowards but makes sure the values interpolate correctly when they wrap around 360 degrees.'''
        pass

    @staticmethod
    def NextPowerOfTwo():
        '''Returns the next power of two that is equal to, or greater than, the argument.'''
        pass

    @staticmethod
    def PerlinNoise():
        '''Generate 2D Perlin noise.'''
        pass

    @staticmethod
    def PingPong():
        '''PingPongs the value t, so that it is never larger than length and never smaller than 0.'''
        pass

    @staticmethod
    def Pow():
        '''Returns f raised to power p.'''
        pass

    @staticmethod
    def Repeat():
        '''Loops the value t, so that it is never larger than length and never smaller than 0.'''
        pass

    @staticmethod
    def Round():
        '''Returns f rounded to the nearest integer.'''
        pass

    @staticmethod
    def RoundToInt():
        '''Returns f rounded to the nearest integer.'''
        pass

    @staticmethod
    def Sign():
        '''Returns the sign of f.'''
        pass

    @staticmethod
    def Sin(f):
        '''Returns the sine of angle f.'''
        return math.sin(f)

    @staticmethod
    def SmoothDamp():
        '''Gradually changes a value towards a desired goal over time.'''
        pass

    @staticmethod
    def SmoothDampAngle():
        '''Gradually changes an angle given in degrees towards a desired goal angle over time.'''
        pass

    @staticmethod
    def SmoothStep():
        '''Interpolates between min and max with smoothing at the limits.'''
        pass

    @staticmethod
    def Sqrt(f):
        '''Returns square root of f.'''
        return math.sqrt(f)

    @staticmethod
    def Tan(f):
        '''Returns the tangent of angle f in radians.'''
        return math.tan(f)

    # endregion


# region global initialization
Mathf.Rad2Deg = 1.0 / Mathf.Deg2Rad
# endregion
