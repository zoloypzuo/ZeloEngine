// Unity C# reference source
// Copyright (c) Unity Technologies. For terms of use, see
// https://unity3d.com/legal/licenses/Unity_Reference_Only_License

using System;
using System.Collections.Generic;
using UnityEngine.StyleSheets;

namespace UnityEngine.Experimental.UIElements.StyleSheets
{
    internal static class StyleSheetCache
    {
        struct SheetHandleKey
        {
            public readonly int sheetInstanceID;
            public readonly int index;

            public SheetHandleKey(StyleSheet sheet, int index)
            {
                this.sheetInstanceID = sheet.GetInstanceID();
                this.index = index;
            }
        }

        class SheetHandleKeyComparer : IEqualityComparer<SheetHandleKey>
        {
            public bool Equals(SheetHandleKey x, SheetHandleKey y)
            {
                return x.sheetInstanceID == y.sheetInstanceID && x.index == y.index;
            }

            public int GetHashCode(SheetHandleKey key)
            {
                unchecked
                {
                    return key.sheetInstanceID.GetHashCode() ^ key.index.GetHashCode();
                }
            }
        }

        static SheetHandleKeyComparer s_Comparer = new SheetHandleKeyComparer();

        // cache of parsed enums for a given sheet and string value index
        static Dictionary<SheetHandleKey, int> s_EnumToIntCache = new Dictionary<SheetHandleKey, int>(s_Comparer);

        // cache of ordered propertyIDs for properties of a given rule
        static Dictionary<SheetHandleKey, StylePropertyID[]> s_RulePropertyIDsCache = new Dictionary<SheetHandleKey, StylePropertyID[]>(s_Comparer);

        // cache of builtin properties (e.g. "margin-left" to their enum equivalent)
        // this is static data and never changes at runtime
        static Dictionary<string, StylePropertyID> s_NameToIDCache = new Dictionary<string, StylePropertyID>()
        {
            {"width", StylePropertyID.Width},
            {"height", StylePropertyID.Height},
            {"max-width", StylePropertyID.MaxWidth},
            {"max-height", StylePropertyID.MaxHeight},
            {"min-width", StylePropertyID.MinWidth},
            {"min-height", StylePropertyID.MinHeight},
            {"flex", StylePropertyID.Flex},
            {"flex-wrap", StylePropertyID.FlexWrap},
            {"flex-basis", StylePropertyID.FlexBasis},
            {"flex-grow", StylePropertyID.FlexGrow},
            {"flex-shrink", StylePropertyID.FlexShrink},
            {"overflow", StylePropertyID.Overflow},
            {"left", StylePropertyID.PositionLeft},
            {"top", StylePropertyID.PositionTop},
            {"right", StylePropertyID.PositionRight},
            {"bottom", StylePropertyID.PositionBottom},
            {"margin-left", StylePropertyID.MarginLeft},
            {"margin-top", StylePropertyID.MarginTop},
            {"margin-right", StylePropertyID.MarginRight},
            {"margin-bottom", StylePropertyID.MarginBottom},
            {"padding-left", StylePropertyID.PaddingLeft},
            {"padding-top", StylePropertyID.PaddingTop},
            {"padding-right", StylePropertyID.PaddingRight},
            {"padding-bottom", StylePropertyID.PaddingBottom},
            {"position", StylePropertyID.Position},
            {"-unity-position", StylePropertyID.PositionType},
            {"align-self", StylePropertyID.AlignSelf},
            {"-unity-text-align", StylePropertyID.UnityTextAlign},
            {"-unity-font-style", StylePropertyID.FontStyleAndWeight},
            {"-unity-clipping", StylePropertyID.TextClipping},
            {"-unity-font", StylePropertyID.Font},
            {"font-size", StylePropertyID.FontSize},
            {"-unity-word-wrap", StylePropertyID.WordWrap},
            {"color", StylePropertyID.Color},
            {"flex-direction", StylePropertyID.FlexDirection},
            {"background-color", StylePropertyID.BackgroundColor},
            {"border-color", StylePropertyID.BorderColor},
            {"background-image", StylePropertyID.BackgroundImage},
            {"-unity-background-scale-mode", StylePropertyID.BackgroundScaleMode},
            {"align-items", StylePropertyID.AlignItems},
            {"align-content", StylePropertyID.AlignContent},
            {"justify-content", StylePropertyID.JustifyContent},
            {"border-left-width", StylePropertyID.BorderLeftWidth},
            {"border-top-width", StylePropertyID.BorderTopWidth},
            {"border-right-width", StylePropertyID.BorderRightWidth},
            {"border-bottom-width", StylePropertyID.BorderBottomWidth},
            {"border-radius", StylePropertyID.BorderRadius},
            {"border-top-left-radius", StylePropertyID.BorderTopLeftRadius},
            {"border-top-right-radius", StylePropertyID.BorderTopRightRadius},
            {"border-bottom-right-radius", StylePropertyID.BorderBottomRightRadius},
            {"border-bottom-left-radius", StylePropertyID.BorderBottomLeftRadius},
            {"-unity-slice-left", StylePropertyID.SliceLeft},
            {"-unity-slice-top", StylePropertyID.SliceTop},
            {"-unity-slice-right", StylePropertyID.SliceRight},
            {"-unity-slice-bottom", StylePropertyID.SliceBottom},
            {"opacity", StylePropertyID.Opacity},
            {"cursor", StylePropertyID.Cursor},
            {"visibility", StylePropertyID.Visibility},
        };

        internal static void ClearCaches()
        {
            s_EnumToIntCache.Clear();
            s_RulePropertyIDsCache.Clear();
        }

        internal static int GetEnumValue<T>(StyleSheet sheet, StyleValueHandle handle)
        {
            Debug.Assert(handle.valueType == StyleValueType.Enum);

            SheetHandleKey key = new SheetHandleKey(sheet, handle.valueIndex);

            int value;
            if (!s_EnumToIntCache.TryGetValue(key, out value))
            {
                string enumValueName = sheet.ReadEnum(handle).Replace("-", string.Empty);
                object enumValue = Enum.Parse(typeof(T), enumValueName, true);
                value = (int)enumValue;
                s_EnumToIntCache.Add(key, value);
            }
            Debug.Assert(Enum.GetName(typeof(T), value) != null);
            return value;
        }

        internal static StylePropertyID[] GetPropertyIDs(StyleSheet sheet, int ruleIndex)
        {
            SheetHandleKey key = new SheetHandleKey(sheet, ruleIndex);

            StylePropertyID[] propertyIDs;
            if (!s_RulePropertyIDsCache.TryGetValue(key, out propertyIDs))
            {
                StyleRule rule = sheet.rules[ruleIndex];
                propertyIDs = new StylePropertyID[rule.properties.Length];
                for (int i = 0; i < propertyIDs.Length; i++)
                {
                    propertyIDs[i] = GetPropertyID(sheet, rule, i);
                }
                s_RulePropertyIDsCache.Add(key, propertyIDs);
            }
            return propertyIDs;
        }

        static Dictionary<string, string> s_DeprecatedNames = new Dictionary<string, string>()
        {
            {"position-left", "left"},
            {"position-top", "top"},
            {"position-right", "right"},
            {"position-bottom", "bottom"},
            {"text-color", "color"},
            {"slice-left", "-unity-slice-left" },
            {"slice-top", "-unity-slice-top" },
            {"slice-right", "-unity-slice-right" },
            {"slice-bottom", "-unity-slice-bottom" },
            {"text-alignment", "-unity-text-align" },
            {"word-wrap", "-unity-word-wrap" },
            {"font", "-unity-font" },
            {"background-size", "-unity-background-scale-mode" },
            {"font-style", "-unity-font-style" },
            {"position-type", "-unity-position" },
            {"text-clipping", "-unity-clipping" },
            {"border-left", "border-left-width"},
            {"border-top", "border-top-width"},
            {"border-right", "border-right-width"},
            {"border-bottom", "border-bottom-width"}
        };

        static string MapDeprecatedPropertyName(string name, string styleSheetName, int line)
        {
            string validName;
            s_DeprecatedNames.TryGetValue(name, out validName);


            return validName ?? name;
        }

        static StylePropertyID GetPropertyID(StyleSheet sheet, StyleRule rule, int index)
        {
            string name = rule.properties[index].name;
            StylePropertyID id;

            name = MapDeprecatedPropertyName(name, sheet.name, rule.line);
            if (!s_NameToIDCache.TryGetValue(name, out id))
            {
                id = StylePropertyID.Custom;
            }
            return id;
        }
    }
}
