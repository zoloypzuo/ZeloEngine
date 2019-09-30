// Unity C# reference source
// Copyright (c) Unity Technologies. For terms of use, see
// https://unity3d.com/legal/licenses/Unity_Reference_Only_License

using UnityEngine.Bindings;

namespace UnityEngine.AI
{
    [NativeHeader("Modules/AI/NavMeshManager.h")]
    public static partial class NavMesh
    {
        [StaticAccessor("GetNavMeshManager()")]
        [NativeName("CleanupAfterCarving")]
        public static extern void RemoveAllNavMeshData();
    }
}
