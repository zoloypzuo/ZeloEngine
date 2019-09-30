// Unity C# reference source
// Copyright (c) Unity Technologies. For terms of use, see
// https://unity3d.com/legal/licenses/Unity_Reference_Only_License

using System;
using System.Collections.ObjectModel;
using System.Runtime.InteropServices;
using UnityEngine.Bindings;
using UnityEngine.Scripting;

namespace UnityEditor.Build.Content
{
    [Serializable]
    [UsedByNativeCode]
    [StructLayout(LayoutKind.Sequential)]
    public struct SceneDependencyInfo
    {
        [NativeName("scene")]
        internal string m_Scene;
        public string scene { get { return m_Scene; } }

        [NativeName("processedScene")]
        internal string m_ProcessedScene;
        public string processedScene { get { return m_ProcessedScene; } }

        [NativeName("referencedObjects")]
        internal ObjectIdentifier[] m_ReferencedObjects;
        public ReadOnlyCollection<ObjectIdentifier> referencedObjects { get { return Array.AsReadOnly(m_ReferencedObjects); } }

        [NativeName("globalUsage")]
        internal BuildUsageTagGlobal m_GlobalUsage;
        public BuildUsageTagGlobal globalUsage { get { return m_GlobalUsage; } }
    }
}
