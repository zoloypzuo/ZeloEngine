// Unity C# reference source
// Copyright (c) Unity Technologies. For terms of use, see
// https://unity3d.com/legal/licenses/Unity_Reference_Only_License

using System;

namespace UnityEngine.Experimental.Rendering
{
    public abstract class RenderPipeline : IRenderPipeline
    {
        public static event Action<Camera[]> beginFrameRendering;
        public static event Action<Camera> beginCameraRendering;

        public virtual void Render(ScriptableRenderContext renderContext, Camera[] cameras)
        {
            if (disposed)
                throw new ObjectDisposedException(string.Format("{0} has been disposed. Do not call Render on disposed RenderLoops.", this));
        }

        public bool disposed { get; private set; }

        public virtual void Dispose()
        {
            disposed = true;
        }

        public static void BeginFrameRendering(Camera[] cameras)
        {
            beginFrameRendering?.Invoke(cameras);
        }

        public static void BeginCameraRendering(Camera camera)
        {
            beginCameraRendering?.Invoke(camera);
        }
    }
}
