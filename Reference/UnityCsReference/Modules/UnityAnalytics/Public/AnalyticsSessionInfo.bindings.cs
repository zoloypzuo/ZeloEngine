// Unity C# reference source
// Copyright (c) Unity Technologies. For terms of use, see
// https://unity3d.com/legal/licenses/Unity_Reference_Only_License

using UnityEngine.Bindings;
using UnityEngine.Scripting;

namespace UnityEngine.Analytics
{
    [RequiredByNativeCode]
    public enum AnalyticsSessionState
    {
        kSessionStopped = 0,
        kSessionStarted = 1,
        kSessionPaused = 2,
        kSessionResumed = 3
    }

    [RequiredByNativeCode]
    [NativeHeader("UnityAnalyticsScriptingClasses.h")]
    [NativeHeader("Modules/UnityAnalytics/CoreStats/AnalyticsCoreStats.h")]
    public static class AnalyticsSessionInfo
    {
        public delegate void SessionStateChanged(AnalyticsSessionState sessionState, long sessionId, long sessionElapsedTime, bool sessionChanged);
        public static event SessionStateChanged sessionStateChanged;

        [RequiredByNativeCode]
        internal static void CallSessionStateChanged(AnalyticsSessionState sessionState, long sessionId, long sessionElapsedTime, bool sessionChanged)
        {
            var handler = sessionStateChanged;
            if (handler != null)
                handler(sessionState, sessionId, sessionElapsedTime, sessionChanged);
        }

        public extern static AnalyticsSessionState sessionState
        {
            [NativeMethod("GetPlayerSessionState")]
            get;
        }

        public extern static long sessionId
        {
            [NativeMethod("GetPlayerSessionId")]
            get;
        }

        public extern static long sessionCount
        {
            [NativeMethod("GetPlayerSessionCount")]
            get;
        }


        public extern static long sessionElapsedTime
        {
            [NativeMethod("GetPlayerSessionElapsedTime")]
            get;
        }

        public extern static bool sessionFirstRun
        {
            [NativeMethod("GetPlayerSessionFirstRun", false, true)]
            get;
        }

        public extern static string userId
        {
            [NativeMethod("GetUserId")]
            get;
        }
    }
}
