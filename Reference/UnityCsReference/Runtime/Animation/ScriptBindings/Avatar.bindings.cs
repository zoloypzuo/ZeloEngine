// Unity C# reference source
// Copyright (c) Unity Technologies. For terms of use, see
// https://unity3d.com/legal/licenses/Unity_Reference_Only_License

using System;
using UnityEngine.Bindings;
using UnityEngine.Scripting;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;
using System.Collections;

namespace UnityEngine
{
    public enum BodyDof
    {
        SpineFrontBack = 0,
        SpineLeftRight,
        SpineRollLeftRight,
        ChestFrontBack,
        ChestLeftRight,
        ChestRollLeftRight,
        UpperChestFrontBack,
        UpperChestLeftRight,
        UpperChestRollLeftRight,
        LastBodyDof
    }

    public enum HeadDof
    {
        NeckFrontBack = 0,
        NeckLeftRight,
        NeckRollLeftRight,
        HeadFrontBack,
        HeadLeftRight,
        HeadRollLeftRight,
        LeftEyeDownUp,
        LeftEyeInOut,
        RightEyeDownUp,
        RightEyeInOut,
        JawDownUp,
        JawLeftRight,
        LastHeadDof
    }

    public enum LegDof
    {
        UpperLegFrontBack = 0,
        UpperLegInOut,
        UpperLegRollInOut,
        LegCloseOpen,
        LegRollInOut,
        FootCloseOpen,
        FootInOut,
        ToesUpDown,
        LastLegDof
    }

    public enum ArmDof
    {
        ShoulderDownUp = 0,
        ShoulderFrontBack,
        ArmDownUp,
        ArmFrontBack,
        ArmRollInOut,
        ForeArmCloseOpen,
        ForeArmRollInOut,
        HandDownUp,
        HandInOut,
        LastArmDof
    }

    public enum FingerDof
    {
        ProximalDownUp = 0,
        ProximalInOut,
        IntermediateCloseOpen,
        DistalCloseOpen,
        LastFingerDof
    }

    public enum HumanPartDof
    {
        Body = 0,
        Head,
        LeftLeg,
        RightLeg,
        LeftArm,
        RightArm,
        LeftThumb,
        LeftIndex,
        LeftMiddle,
        LeftRing,
        LeftLittle,
        RightThumb,
        RightIndex,
        RightMiddle,
        RightRing,
        RightLittle,
        LastHumanPartDof
    }

    internal enum Dof
    {
        BodyDofStart = 0,
        HeadDofStart = (int)BodyDofStart + (int)BodyDof.LastBodyDof,
        LeftLegDofStart = (int)HeadDofStart + (int)HeadDof.LastHeadDof,
        RightLegDofStart = (int)LeftLegDofStart + (int)LegDof.LastLegDof,
        LeftArmDofStart = (int)RightLegDofStart + (int)LegDof.LastLegDof,
        RightArmDofStart = (int)LeftArmDofStart + (int)ArmDof.LastArmDof,

        LeftThumbDofStart = (int)RightArmDofStart + (int)ArmDof.LastArmDof,
        LeftIndexDofStart = (int)LeftThumbDofStart + (int)FingerDof.LastFingerDof,
        LeftMiddleDofStart = (int)LeftIndexDofStart + (int)FingerDof.LastFingerDof,

        LeftRingDofStart = (int)LeftMiddleDofStart + (int)FingerDof.LastFingerDof,
        LeftLittleDofStart = (int)LeftRingDofStart + (int)FingerDof.LastFingerDof,

        RightThumbDofStart = (int)LeftLittleDofStart + (int)FingerDof.LastFingerDof,
        RightIndexDofStart = (int)RightThumbDofStart + (int)FingerDof.LastFingerDof,
        RightMiddleDofStart = (int)RightIndexDofStart + (int)FingerDof.LastFingerDof,
        RightRingDofStart = (int)RightMiddleDofStart + (int)FingerDof.LastFingerDof,
        RightLittleDofStart = (int)RightRingDofStart + (int)FingerDof.LastFingerDof,

        LastDof = (int)RightLittleDofStart + (int)FingerDof.LastFingerDof
    }

    // Human Body Bones
    public enum HumanBodyBones
    {
        // This is the Hips bone
        Hips = 0,

        // This is the Left Upper Leg bone
        LeftUpperLeg = 1,

        // This is the Right Upper Leg bone
        RightUpperLeg = 2,

        // This is the Left Knee bone
        LeftLowerLeg = 3,

        // This is the Right Knee bone
        RightLowerLeg = 4,

        // This is the Left Ankle bone
        LeftFoot = 5,

        // This is the Right Ankle bone
        RightFoot = 6,

        // This is the first Spine bone
        Spine = 7,

        // This is the Chest bone
        Chest = 8,

        // This is the UpperChest bone
        UpperChest = 54,

        // This is the Neck bone
        Neck = 9,

        // This is the Head bone
        Head = 10,

        // This is the Left Shoulder bone
        LeftShoulder = 11,

        // This is the Right Shoulder bone
        RightShoulder = 12,

        // This is the Left Upper Arm bone
        LeftUpperArm = 13,

        // This is the Right Upper Arm bone
        RightUpperArm = 14,

        // This is the Left Elbow bone
        LeftLowerArm = 15,

        // This is the Right Elbow bone
        RightLowerArm = 16,

        // This is the Left Wrist bone
        LeftHand = 17,

        // This is the Right Wrist bone
        RightHand = 18,

        // This is the Left Toes bone
        LeftToes = 19,

        // This is the Right Toes bone
        RightToes = 20,

        // This is the Left Eye bone
        LeftEye = 21,

        // This is the Right Eye bone
        RightEye = 22,

        // This is the Jaw bone
        Jaw = 23,

        LeftThumbProximal = 24,
        LeftThumbIntermediate = 25,
        LeftThumbDistal = 26,

        LeftIndexProximal = 27,
        LeftIndexIntermediate = 28,
        LeftIndexDistal = 29,

        LeftMiddleProximal = 30,
        LeftMiddleIntermediate = 31,
        LeftMiddleDistal = 32,

        LeftRingProximal = 33,
        LeftRingIntermediate = 34,
        LeftRingDistal = 35,

        LeftLittleProximal = 36,
        LeftLittleIntermediate = 37,
        LeftLittleDistal = 38,

        RightThumbProximal = 39,
        RightThumbIntermediate = 40,
        RightThumbDistal = 41,

        RightIndexProximal = 42,
        RightIndexIntermediate = 43,
        RightIndexDistal = 44,

        RightMiddleProximal = 45,
        RightMiddleIntermediate = 46,
        RightMiddleDistal = 47,

        RightRingProximal = 48,
        RightRingIntermediate = 49,
        RightRingDistal = 50,

        RightLittleProximal = 51,
        RightLittleIntermediate = 52,
        RightLittleDistal = 53,

        // UpperChest = 54

        // This is the Last bone index delimiter
        LastBone = 55
    }

    internal enum  HumanParameter
    {
        UpperArmTwist = 0,
        LowerArmTwist,
        UpperLegTwist,
        LowerLegTwist,
        ArmStretch,
        LegStretch,
        FeetSpacing
    }

    [NativeHeader("Runtime/Animation/Avatar.h")]
    [UsedByNativeCode]
    public class Avatar : Object
    {
        private Avatar()
        {
        }

        // Return true if this avatar is a valid mecanim avatar. It can be a generic avatar or a human avatar.
        extern public bool isValid
        {
            [NativeMethod("IsValid")]
            get;
        }

        // Return true if this avatar is a valid human avatar.
        extern public bool isHuman
        {
            [NativeMethod("IsHuman")]
            get;
        }

        extern internal void SetMuscleMinMax(int muscleId, float min, float max);

        extern internal void SetParameter(int parameterId, float value);

        internal float GetAxisLength(int humanId)
        {
            return Internal_GetAxisLength(HumanTrait.GetBoneIndexFromMono(humanId));
        }

        internal Quaternion GetPreRotation(int humanId)
        {
            return Internal_GetPreRotation(HumanTrait.GetBoneIndexFromMono(humanId));
        }

        internal Quaternion GetPostRotation(int humanId)
        {
            return Internal_GetPostRotation(HumanTrait.GetBoneIndexFromMono(humanId));
        }

        internal Quaternion GetZYPostQ(int humanId, Quaternion parentQ, Quaternion q)
        {
            return Internal_GetZYPostQ(HumanTrait.GetBoneIndexFromMono(humanId), parentQ, q);
        }

        internal Quaternion GetZYRoll(int humanId, Vector3 uvw)
        {
            return Internal_GetZYRoll(HumanTrait.GetBoneIndexFromMono(humanId), uvw);
        }

        internal Vector3 GetLimitSign(int humanId)
        {
            return Internal_GetLimitSign(HumanTrait.GetBoneIndexFromMono(humanId));
        }

        [NativeMethod("GetAxisLength")]
        extern internal float Internal_GetAxisLength(int humanId);

        [NativeMethod("GetPreRotation")]
        extern internal Quaternion Internal_GetPreRotation(int humanId);

        [NativeMethod("GetPostRotation")]
        extern internal Quaternion Internal_GetPostRotation(int humanId);

        [NativeMethod("GetZYPostQ")]
        extern internal Quaternion Internal_GetZYPostQ(int humanId, Quaternion parentQ, Quaternion q);

        [NativeMethod("GetZYRoll")]
        extern internal Quaternion Internal_GetZYRoll(int humanId, Vector3 uvw);

        [NativeMethod("GetLimitSign")]
        extern internal Vector3 Internal_GetLimitSign(int humanId);
    }
}
