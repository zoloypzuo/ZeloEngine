// Unity C# reference source
// Copyright (c) Unity Technologies. For terms of use, see
// https://unity3d.com/legal/licenses/Unity_Reference_Only_License


using System;
using UnityEngine;
using UnityEngine.Playables;

namespace UnityEngine.Experimental.Animations
{
    public interface IAnimationJobPlayable : IPlayable
    {
        T GetJobData<T>() where T : struct, IAnimationJob;
        void SetJobData<T>(T jobData) where T : struct, IAnimationJob;
    }
}

