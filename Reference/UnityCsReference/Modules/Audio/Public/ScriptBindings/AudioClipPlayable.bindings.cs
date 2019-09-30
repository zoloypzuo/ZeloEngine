// Unity C# reference source
// Copyright (c) Unity Technologies. For terms of use, see
// https://unity3d.com/legal/licenses/Unity_Reference_Only_License

using System;
using System.ComponentModel;
using UnityEngine.Bindings;
using UnityEngine.Scripting;
using UnityEngine.Playables;

using UnityObject = UnityEngine.Object;

namespace UnityEngine.Audio
{
    [NativeHeader("Modules/Audio/Public/ScriptBindings/AudioClipPlayable.bindings.h")]
    [NativeHeader("Modules/Audio/Public/Director/AudioClipPlayable.h")]
    [NativeHeader("Runtime/Director/Core/HPlayable.h")]
    [StaticAccessor("AudioClipPlayableBindings", StaticAccessorType.DoubleColon)]
    [RequiredByNativeCode]
    public struct AudioClipPlayable : IPlayable, IEquatable<AudioClipPlayable>
    {
        PlayableHandle m_Handle;

        public static AudioClipPlayable Create(PlayableGraph graph, AudioClip clip, bool looping)
        {
            var handle = CreateHandle(graph, clip, looping);
            var playable = new AudioClipPlayable(handle);
            if (clip != null)
                playable.SetDuration(clip.length);
            return playable;
        }

        private static PlayableHandle CreateHandle(PlayableGraph graph, AudioClip clip, bool looping)
        {
            PlayableHandle handle = PlayableHandle.Null;
            if (!InternalCreateAudioClipPlayable(ref graph, clip, looping, ref handle))
                return PlayableHandle.Null;
            return handle;
        }

        internal AudioClipPlayable(PlayableHandle handle)
        {
            if (handle.IsValid())
            {
                if (!handle.IsPlayableOfType<AudioClipPlayable>())
                    throw new InvalidCastException("Can't set handle: the playable is not an AudioClipPlayable.");
            }

            m_Handle = handle;
        }

        public PlayableHandle GetHandle()
        {
            return m_Handle;
        }

        public static implicit operator Playable(AudioClipPlayable playable)
        {
            return new Playable(playable.GetHandle());
        }

        public static explicit operator AudioClipPlayable(Playable playable)
        {
            return new AudioClipPlayable(playable.GetHandle());
        }

        public bool Equals(AudioClipPlayable other)
        {
            return GetHandle() == other.GetHandle();
        }


        public AudioClip GetClip()
        {
            return GetClipInternal(ref m_Handle);
        }

        public void SetClip(AudioClip value)
        {
            SetClipInternal(ref m_Handle, value);
        }

        public bool GetLooped()
        {
            return GetLoopedInternal(ref m_Handle);
        }

        public void SetLooped(bool value)
        {
            SetLoopedInternal(ref m_Handle, value);
        }

        [System.ComponentModel.EditorBrowsable(System.ComponentModel.EditorBrowsableState.Never)]
        [Obsolete("IsPlaying() has been deprecated. Use IsChannelPlaying() instead (UnityUpgradable) -> IsChannelPlaying()", true)]
        public bool IsPlaying()
        {
            return IsChannelPlaying();
        }

        public bool IsChannelPlaying()
        {
            return GetIsChannelPlayingInternal(ref m_Handle);
        }

        public double GetStartDelay()
        {
            return GetStartDelayInternal(ref m_Handle);
        }

        internal void SetStartDelay(double value)
        {
            SetStartDelayInternal(ref m_Handle, value);
        }

        public double GetPauseDelay()
        {
            return GetPauseDelayInternal(ref m_Handle);
        }

        internal void GetPauseDelay(double value)
        {
            double currentDelay = GetPauseDelayInternal(ref m_Handle);
            //FIXME Chanage 0.5 from arbitrary value to something that is dependent on sample rate and dsp buffer size
            if (m_Handle.GetPlayState() == PlayState.Playing &&
                (value < 0.05 || (currentDelay != 0.0 && currentDelay < 0.05)))
                throw new ArgumentException("AudioClipPlayable.pauseDelay: Setting new delay when existing delay is too small or 0.0 ("
                    + currentDelay + "), audio system will not be able to change in time");

            SetPauseDelayInternal(ref m_Handle, value);
        }

        public void Seek(double startTime, double startDelay)
        {
            Seek(startTime, startDelay, 0);
        }

        public void Seek(double startTime, double startDelay, [DefaultValue("0")] double duration)
        {
            SetStartDelayInternal(ref m_Handle, startDelay);
            if (duration > 0)
            {
                // playable duration is the local time (without speed modifier applied)
                //  that it stops, since it will not advance time until the delay is complete
                m_Handle.SetDuration(duration + startTime);
                // start delay is offset by the length of the clip that plays
                SetPauseDelayInternal(ref m_Handle, startDelay + duration);
            }
            else
            {
                m_Handle.SetDuration(double.MaxValue);
                SetPauseDelayInternal(ref m_Handle, 0);
            }

            m_Handle.SetTime(startTime);
            m_Handle.Play();
        }

        [NativeThrows]
        extern private static AudioClip GetClipInternal(ref PlayableHandle hdl);

        [NativeThrows]
        extern private static void SetClipInternal(ref PlayableHandle hdl, AudioClip clip);

        [NativeThrows]
        extern private static bool GetLoopedInternal(ref PlayableHandle hdl);

        [NativeThrows]
        extern private static void SetLoopedInternal(ref PlayableHandle hdl, bool looped);

        [NativeThrows]
        extern private static bool GetIsChannelPlayingInternal(ref PlayableHandle hdl);

        [NativeThrows]
        extern private static double GetStartDelayInternal(ref PlayableHandle hdl);

        [NativeThrows]
        extern private static void SetStartDelayInternal(ref PlayableHandle hdl, double delay);

        [NativeThrows]
        extern private static double GetPauseDelayInternal(ref PlayableHandle hdl);

        [NativeThrows]
        extern private static void SetPauseDelayInternal(ref PlayableHandle hdl, double delay);

        [NativeThrows]
        extern private static bool InternalCreateAudioClipPlayable(ref PlayableGraph graph, AudioClip clip, bool looping, ref PlayableHandle handle);

        [NativeThrows]
        extern private static bool ValidateType(ref PlayableHandle hdl);

    }
}
