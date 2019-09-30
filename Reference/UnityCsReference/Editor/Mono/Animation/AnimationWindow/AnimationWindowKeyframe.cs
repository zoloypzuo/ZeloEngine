// Unity C# reference source
// Copyright (c) Unity Technologies. For terms of use, see
// https://unity3d.com/legal/licenses/Unity_Reference_Only_License

using UnityEngine;
using UnityEditor;

namespace UnityEditorInternal
{
    internal class AnimationWindowKeyframe
    {
        public float            m_InTangent;
        public float            m_OutTangent;
        public float            m_InWeight;
        public float            m_OutWeight;
        public WeightedMode     m_WeightedMode;
        public int              m_TangentMode;
        public int              m_TimeHash;
        int                     m_Hash;

        float                   m_time;

        object                  m_value;

        AnimationWindowCurve    m_curve;
        public float time
        {
            get { return m_time; }
            set
            {
                m_time = value;
                m_Hash = 0;
                m_TimeHash = value.GetHashCode();
            }
        }

        public object value
        {
            get { return m_value; }
            set { m_value = value; }
        }

        public float inTangent
        {
            get { return m_InTangent; }
            set { m_InTangent = value; }
        }

        public float outTangent
        {
            get { return m_OutTangent; }
            set { m_OutTangent = value; }
        }

        public float inWeight
        {
            get { return m_InWeight; }
            set { m_InWeight = value; }
        }

        public float outWeight
        {
            get { return m_OutWeight; }
            set { m_OutWeight = value; }
        }

        public WeightedMode weightedMode
        {
            get { return m_WeightedMode; }
            set { m_WeightedMode = value; }
        }

        public AnimationWindowCurve curve
        {
            get { return m_curve; }
            set
            {
                m_curve = value;
                m_Hash = 0;
            }
        }

        public bool isPPtrCurve { get { return curve.isPPtrCurve; } }
        public bool isDiscreteCurve { get { return curve.isDiscreteCurve; } }

        public AnimationWindowKeyframe()
        {
        }

        public AnimationWindowKeyframe(AnimationWindowKeyframe key)
        {
            this.time = key.time;
            this.value = key.value;
            this.curve = key.curve;
            this.m_InTangent = key.m_InTangent;
            this.m_OutTangent = key.m_OutTangent;
            this.m_InWeight = key.inWeight;
            this.m_OutWeight = key.outWeight;
            this.m_WeightedMode = key.weightedMode;
            this.m_TangentMode = key.m_TangentMode;
            this.m_curve = key.m_curve;
        }

        public AnimationWindowKeyframe(AnimationWindowCurve curve, Keyframe key)
        {
            this.time = key.time;
            this.value = key.value;
            this.curve = curve;
            this.m_InTangent = key.inTangent;
            this.m_OutTangent = key.outTangent;
            this.m_InWeight = key.inWeight;
            this.m_OutWeight = key.outWeight;
            this.m_WeightedMode = key.weightedMode;
            this.m_TangentMode = key.tangentModeInternal;
            this.m_curve = curve;
        }

        public AnimationWindowKeyframe(AnimationWindowCurve curve, ObjectReferenceKeyframe key)
        {
            this.time = key.time;
            this.value = key.value;
            this.curve = curve;
        }

        public int GetHash()
        {
            if (m_Hash == 0)
            {
                // Berstein hash
                unchecked
                {
                    m_Hash = curve.GetHashCode();
                    m_Hash = 33 * m_Hash + time.GetHashCode();
                }
            }

            return m_Hash;
        }

        public int GetIndex()
        {
            for (int i = 0; i < curve.m_Keyframes.Count; i++)
            {
                if (curve.m_Keyframes[i] == this)
                {
                    return i;
                }
            }
            return -1;
        }

        public Keyframe ToKeyframe()
        {
            var keyframe = new Keyframe(time, (float)value, inTangent, outTangent);

            keyframe.tangentModeInternal = m_TangentMode;
            keyframe.weightedMode = weightedMode;
            keyframe.inWeight = inWeight;
            keyframe.outWeight = outWeight;

            return keyframe;
        }

        public ObjectReferenceKeyframe ToObjectReferenceKeyframe()
        {
            var keyframe = new ObjectReferenceKeyframe();

            keyframe.time = time;
            keyframe.value = (UnityEngine.Object)value;

            return keyframe;
        }
    }
}
