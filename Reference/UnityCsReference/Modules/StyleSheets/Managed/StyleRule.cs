// Unity C# reference source
// Copyright (c) Unity Technologies. For terms of use, see
// https://unity3d.com/legal/licenses/Unity_Reference_Only_License

using System;
using UnityEngine.Bindings;

namespace UnityEngine.StyleSheets
{
    [Serializable]
    [VisibleToOtherModules("UnityEngine.UIElementsModule")]
    internal class StyleRule
    {
        [SerializeField]
        StyleProperty[] m_Properties;

        [SerializeField]
        [VisibleToOtherModules("UnityEngine.UIElementsModule")]
        internal int line;

        public StyleProperty[] properties
        {
            get
            {
                return m_Properties;
            }
            internal set
            {
                m_Properties = value;
            }
        }
    }
}
