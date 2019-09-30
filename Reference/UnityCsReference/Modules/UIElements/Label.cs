// Unity C# reference source
// Copyright (c) Unity Technologies. For terms of use, see
// https://unity3d.com/legal/licenses/Unity_Reference_Only_License

using System;

namespace UnityEngine.Experimental.UIElements
{
    public class Label : TextElement
    {
        public new class UxmlFactory : UxmlFactory<Label, UxmlTraits> {}

        public new class UxmlTraits : TextElement.UxmlTraits {}

        public Label() : this(String.Empty) {}
        public Label(string text)
        {
            this.text = text;
        }
    }
}
