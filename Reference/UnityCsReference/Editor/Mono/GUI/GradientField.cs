// Unity C# reference source
// Copyright (c) Unity Technologies. For terms of use, see
// https://unity3d.com/legal/licenses/Unity_Reference_Only_License

using UnityEngine;
using UnityEditorInternal;

namespace UnityEditor
{
    public sealed partial class EditorGUILayout
    {
        // Gradient versions
        public static Gradient GradientField(Gradient value, params GUILayoutOption[] options)
        {
            Rect r = s_LastRect = GUILayoutUtility.GetRect(EditorGUIUtility.fieldWidth, kLabelFloatMaxW, EditorGUI.kSingleLineHeight, EditorGUI.kSingleLineHeight, EditorStyles.colorField, options);
            return EditorGUI.GradientField(r, value);
        }

        public static Gradient GradientField(string label, Gradient value, params GUILayoutOption[] options)
        {
            Rect r = s_LastRect = GUILayoutUtility.GetRect(kLabelFloatMinW, kLabelFloatMaxW, EditorGUI.kSingleLineHeight, EditorGUI.kSingleLineHeight, EditorStyles.colorField, options);
            return EditorGUI.GradientField(r, label, value);
        }

        public static Gradient GradientField(GUIContent label, Gradient value, params GUILayoutOption[] options)
        {
            Rect r = s_LastRect = GUILayoutUtility.GetRect(kLabelFloatMinW, kLabelFloatMaxW, EditorGUI.kSingleLineHeight, EditorGUI.kSingleLineHeight, EditorStyles.colorField, options);
            return EditorGUI.GradientField(r, label, value);
        }

        public static Gradient GradientField(GUIContent label, Gradient value, bool hdr, params GUILayoutOption[] options)
        {
            Rect r = s_LastRect = GUILayoutUtility.GetRect(kLabelFloatMinW, kLabelFloatMaxW, EditorGUI.kSingleLineHeight, EditorGUI.kSingleLineHeight, EditorStyles.colorField, options);
            return EditorGUI.GradientField(r, label, value, hdr);
        }

        // SerializedProperty versions
        internal static Gradient GradientField(SerializedProperty value, params GUILayoutOption[] options)
        {
            Rect r = s_LastRect = GUILayoutUtility.GetRect(kLabelFloatMinW, kLabelFloatMaxW, EditorGUI.kSingleLineHeight, EditorGUI.kSingleLineHeight, EditorStyles.colorField, options);
            return EditorGUI.GradientField(r, value);
        }

        internal static Gradient GradientField(string label, SerializedProperty value, params GUILayoutOption[] options)
        {
            Rect r = s_LastRect = GUILayoutUtility.GetRect(kLabelFloatMinW, kLabelFloatMaxW, EditorGUI.kSingleLineHeight, EditorGUI.kSingleLineHeight, EditorStyles.colorField, options);
            return EditorGUI.GradientField(r, label, value);
        }

        internal static Gradient GradientField(GUIContent label, SerializedProperty value, params GUILayoutOption[] options)
        {
            Rect r = s_LastRect = GUILayoutUtility.GetRect(kLabelFloatMinW, kLabelFloatMaxW, EditorGUI.kSingleLineHeight, EditorGUI.kSingleLineHeight, EditorStyles.colorField, options);
            return EditorGUI.GradientField(r, label, value);
        }
    }


    public sealed partial class EditorGUI
    {
        static readonly int s_GradientHash = "s_GradientHash".GetHashCode();
        static int s_GradientID;

        // Gradient versions
        public static Gradient GradientField(Rect position, Gradient gradient)
        {
            int id = EditorGUIUtility.GetControlID(s_GradientHash, FocusType.Keyboard, position);
            return DoGradientField(position, id, gradient, null, false);
        }

        public static Gradient GradientField(Rect position, string label, Gradient gradient)
        {
            return GradientField(position, EditorGUIUtility.TempContent(label), gradient);
        }

        public static Gradient GradientField(Rect position, GUIContent label, Gradient gradient)
        {
            return GradientField(position, label, gradient, false);
        }

        public static Gradient GradientField(Rect position, GUIContent label, Gradient gradient, bool hdr)
        {
            int id = EditorGUIUtility.GetControlID(s_GradientHash, FocusType.Keyboard, position);
            return DoGradientField(PrefixLabel(position, id, label), id, gradient, null, hdr);
        }

        // SerializedProperty versions
        internal static Gradient GradientField(Rect position, SerializedProperty property)
        {
            return GradientField(position, property, false);
        }

        internal static Gradient GradientField(Rect position, SerializedProperty property, bool hdr)
        {
            int id = EditorGUIUtility.GetControlID(s_GradientHash, FocusType.Keyboard, position);
            return DoGradientField(position, id, null, property, hdr);
        }

        internal static Gradient GradientField(Rect position, string label, SerializedProperty property)
        {
            return GradientField(position, EditorGUIUtility.TempContent(label), property);
        }

        internal static Gradient GradientField(Rect position, GUIContent label, SerializedProperty property)
        {
            int id = EditorGUIUtility.GetControlID(s_GradientHash, FocusType.Keyboard, position);
            return DoGradientField(PrefixLabel(position, id, label), id, null, property, false);
        }

        internal static Gradient DoGradientField(Rect position, int id, Gradient value, SerializedProperty property, bool hdr)
        {
            Event evt = Event.current;

            switch (evt.GetTypeForControl(id))
            {
                case EventType.MouseDown:
                    if (position.Contains(evt.mousePosition))
                    {
                        if (evt.button == 0)
                        {
                            s_GradientID = id;
                            GUIUtility.keyboardControl = id;
                            Gradient gradient = property != null ? property.gradientValue : value;
                            GradientPicker.Show(gradient, hdr);
                            GUIUtility.ExitGUI();
                        }
                        else if (evt.button == 1)
                        {
                            if (property != null)
                                GradientContextMenu.Show(property.Copy());
                            // TODO: make work for Gradient value
                        }
                    }
                    break;
                case EventType.Repaint:
                {
                    Rect r2 = new Rect(position.x + 1, position.y + 1, position.width - 2, position.height - 2);    // Adjust for box drawn on top
                    if (property != null)
                        GradientEditor.DrawGradientSwatch(r2, property, Color.white);
                    else
                        GradientEditor.DrawGradientSwatch(r2, value, Color.white);
                    EditorStyles.colorPickerBox.Draw(position, GUIContent.none, id);
                    break;
                }
                case EventType.ExecuteCommand:
                    if (s_GradientID == id && evt.commandName == GradientPicker.GradientPickerChangedCommand)
                    {
                        GUI.changed = true;
                        GradientPreviewCache.ClearCache();
                        HandleUtility.Repaint();
                        if (property != null)
                            property.gradientValue = GradientPicker.gradient;

                        return GradientPicker.gradient;
                    }
                    break;
                case EventType.ValidateCommand:
                    if (s_GradientID == id && evt.commandName == EventCommandNames.UndoRedoPerformed)
                    {
                        if (property != null)
                            GradientPicker.SetCurrentGradient(property.gradientValue);
                        GradientPreviewCache.ClearCache();
                        return value;
                    }
                    break;
                case EventType.KeyDown:
                    if (GUIUtility.keyboardControl == id && (evt.keyCode == KeyCode.Space || evt.keyCode == KeyCode.Return || evt.keyCode == KeyCode.KeypadEnter))
                    {
                        Event.current.Use();
                        Gradient gradient = property != null ? property.gradientValue : value;
                        GradientPicker.Show(gradient, hdr);
                        GUIUtility.ExitGUI();
                    }
                    break;
            }
            return value;
        }
    }
}
