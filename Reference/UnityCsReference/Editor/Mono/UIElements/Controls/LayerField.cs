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
    public class LayerField : PopupField<int>
    {
        public new class UxmlFactory : UxmlFactory<LayerField, UxmlTraits> {}

        public new class UxmlTraits : PopupField<int>.UxmlTraits
        {
            UxmlIntAttributeDescription m_Value = new UxmlIntAttributeDescription { name = "value" };

            public override void Init(VisualElement ve, IUxmlAttributes bag, CreationContext cc)
            {
                base.Init(ve, bag, cc);

                var lf = (LayerField)ve;
                lf.SetValueWithoutNotify(m_Value.GetValueFromBag(bag, cc));
            }
        }

        internal override string GetValueToDisplay()
        {
            return InternalEditorUtility.GetLayerName(m_Value);
        }

        public override int value
        {
            get { return base.value; }
            set
            {
                if (m_Choices.Contains(value))
                {
                    base.value = value;
                }
            }
        }

        public override Func<int, string> formatSelectedValueCallback
        {
            get { return null; }
            set
            {
                Debug.LogWarning(L10n.Tr("LayerField doesn't support the formatting of the selected value."));
                m_FormatSelectedValueCallback = null;
            }
        }

        public override Func<int, string> formatListItemCallback
        {
            get { return null; }
            set
            {
                Debug.LogWarning(L10n.Tr("LayerField doesn't support the formatting of the list items."));
                m_FormatListItemCallback = null;
            }
        }

        public override void SetValueWithoutNotify(int newValue)
        {
            if (m_Choices.Contains(newValue))
            {
                base.SetValueWithoutNotify(newValue);
            }
        }

        static List<int> InitializeLayers()
        {
            var listOfIndex = new List<int>();
            for (var i = 0; i < 32; i++)
            {
                if (InternalEditorUtility.GetLayerName(i).Length != 0)
                {
                    listOfIndex.Add(i);
                }
            }
            return listOfIndex;
        }

        public LayerField() : base(InitializeLayers())
        {
        }

        public LayerField(int defaultValue) : this()
        {
            SetValueWithoutNotify(defaultValue);
        }

        internal override void AddMenuItems(GenericMenu menu)
        {
            choices = InitializeLayers();
            string[] layerList = InternalEditorUtility.GetLayersWithId();
            for (var i = 0; i < layerList.Length; i++)
            {
                var item = layerList[i];
                var menuItemIndex = m_Choices[i];
                var isSelected = (menuItemIndex == value);
                menu.AddItem(new GUIContent(item), isSelected,
                    () => ChangeValueFromMenu(menuItemIndex));
            }
            menu.AddItem(new GUIContent(""), false, null);
            menu.AddItem(new GUIContent(L10n.Tr("Add Layer...")), false, OpenLayerInspector);
        }

        void ChangeValueFromMenu(int menuItemIndex)
        {
            value = menuItemIndex;
        }

        static void OpenLayerInspector()
        {
            TagManagerInspector.ShowWithInitialExpansion(TagManagerInspector.InitialExpansionState.Layers);
        }
    }
}
