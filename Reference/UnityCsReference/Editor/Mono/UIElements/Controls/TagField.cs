// Unity C# reference source
// Copyright (c) Unity Technologies. For terms of use, see
// https://unity3d.com/legal/licenses/Unity_Reference_Only_License

using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Experimental.UIElements;
using UnityEditorInternal;

namespace UnityEditor.Experimental.UIElements
{
    public class TagField : PopupField<string>
    {
        public new class UxmlFactory : UxmlFactory<TagField, UxmlTraits> {}

        public new class UxmlTraits : PopupField<string>.UxmlTraits
        {
            UxmlStringAttributeDescription m_Value = new UxmlStringAttributeDescription { name = "value" };

            public override void Init(VisualElement ve, IUxmlAttributes bag, CreationContext cc)
            {
                base.Init(ve, bag, cc);

                var tagField = (TagField)ve;
                tagField.SetValueWithoutNotify(m_Value.GetValueFromBag(bag, cc));
            }
        }

        internal override string GetValueToDisplay()
        {
            return m_Value;
        }

        public override string value
        {
            get { return base.value; }
            set
            {
                // Allow the setting of value outside of Tags, but do nothing with them...
                if (m_Choices.Contains(value))
                {
                    base.value = value;
                }
            }
        }

        public override void SetValueWithoutNotify(string newValue)
        {
            // Allow the setting of value outside of Tags, but do nothing with them...
            if (m_Choices.Contains(newValue))
            {
                base.SetValueWithoutNotify(newValue);
            }
        }

        public override Func<string, string> formatSelectedValueCallback
        {
            get { return null; }
            set
            {
                Debug.LogWarning(L10n.Tr("TagField doesn't support the formatting of the selected value."));
                m_FormatSelectedValueCallback = null;
            }
        }

        public override Func<string, string> formatListItemCallback
        {
            get { return null; }
            set
            {
                Debug.LogWarning(L10n.Tr("TagField doesn't support the formatting of the list items."));
                m_FormatListItemCallback = null;
            }
        }

        static List<string> InitializeTags()
        {
            return new List<string>(InternalEditorUtility.tags);
        }

        public TagField() : base(InitializeTags()) {}

        public TagField(string defaultValue) : this()
        {
            SetValueWithoutNotify(defaultValue);
        }

        internal override void AddMenuItems(GenericMenu menu)
        {
            choices = InitializeTags();
            foreach (var menuItem in choices)
            {
                var isSelected = (menuItem == value);
                menu.AddItem(new GUIContent(menuItem), isSelected, () => ChangeValueFromMenu(menuItem));
            }
            menu.AddItem(new GUIContent(""), false, null); // This is a separator...
            menu.AddItem(new GUIContent(L10n.Tr("Add Tag...")), false, OpenTagInspector);
        }

        void ChangeValueFromMenu(string menuItem)
        {
            value = menuItem;
        }

        static void OpenTagInspector()
        {
            TagManagerInspector.ShowWithInitialExpansion(TagManagerInspector.InitialExpansionState.Tags);
        }
    }
}
