// Unity C# reference source
// Copyright (c) Unity Technologies. For terms of use, see
// https://unity3d.com/legal/licenses/Unity_Reference_Only_License

using UnityEditor;
using UnityEngine;
using System;
using UnityEditor.Experimental.U2D;
using UnityEngine.U2D.Interface;
using UnityEvent = UnityEngine.Event;

namespace UnityEditorInternal
{
    [Serializable]
    internal class SpriteEditorMenuSetting : ScriptableObject
    {
        public enum SlicingType { Automatic = 0, GridByCellSize = 1, GridByCellCount = 2 }

        [SerializeField]
        public Vector2 gridCellCount = new Vector2(1, 1);
        [SerializeField]
        public Vector2 gridSpriteSize = new Vector2(64, 64);
        [SerializeField]
        public Vector2 gridSpriteOffset = new Vector2(0, 0);
        [SerializeField]
        public Vector2 gridSpritePadding = new Vector2(0, 0);
        [SerializeField]
        public Vector2 pivot = Vector2.zero;
        [SerializeField]
        public int autoSlicingMethod = (int)SpriteFrameModule.AutoSlicingMethod.DeleteAll;
        [SerializeField]
        public int spriteAlignment;
        [SerializeField]
        public SlicingType slicingType;
    }

    internal class SpriteEditorMenu : EditorWindow
    {
        private static Styles s_Styles;
        private static long s_LastClosedTime;
        private static SpriteEditorMenuSetting s_Setting;
        private ITextureDataProvider m_TextureDataProvider;
        private SpriteFrameModule m_SpriteFrameModule;

        private class Styles
        {
            public GUIStyle background = "grey_border";
            public GUIStyle notice;

            public Styles()
            {
                notice = new GUIStyle(GUI.skin.label);
                notice.alignment = TextAnchor.MiddleCenter;
                notice.wordWrap = true;
            }

            public readonly GUIContent[] spriteAlignmentOptions =
            {
                EditorGUIUtility.TrTextContent("Center"),
                EditorGUIUtility.TrTextContent("Top Left"),
                EditorGUIUtility.TrTextContent("Top"),
                EditorGUIUtility.TrTextContent("Top Right"),
                EditorGUIUtility.TrTextContent("Left"),
                EditorGUIUtility.TrTextContent("Right"),
                EditorGUIUtility.TrTextContent("Bottom Left"),
                EditorGUIUtility.TrTextContent("Bottom"),
                EditorGUIUtility.TrTextContent("Bottom Right"),
                EditorGUIUtility.TrTextContent("Custom")
            };

            public readonly GUIContent[] slicingMethodOptions =
            {
                EditorGUIUtility.TrTextContent("Delete Existing", "Delete all existing sprite assets before the slicing operation"),
                EditorGUIUtility.TrTextContent("Smart", "Try to match existing sprite rects to sliced rects from the slicing operation"),
                EditorGUIUtility.TrTextContent("Safe", "Keep existing sprite rects intact")
            };

            public readonly GUIContent methodLabel = EditorGUIUtility.TrTextContent("Method");
            public readonly GUIContent pivotLabel = EditorGUIUtility.TrTextContent("Pivot");
            public readonly GUIContent typeLabel = EditorGUIUtility.TrTextContent("Type");
            public readonly GUIContent sliceButtonLabel = EditorGUIUtility.TrTextContent("Slice");
            public readonly GUIContent columnAndRowLabel = EditorGUIUtility.TrTextContent("Column & Row");
            public readonly GUIContent columnLabel = EditorGUIUtility.TextContent("C");
            public readonly GUIContent rowLabel = EditorGUIUtility.TextContent("R");
            public readonly GUIContent pixelSizeLabel = EditorGUIUtility.TrTextContent("Pixel Size");
            public readonly GUIContent xLabel = EditorGUIUtility.TextContent("X");
            public readonly GUIContent yLabel = EditorGUIUtility.TextContent("Y");
            public readonly GUIContent offsetLabel = EditorGUIUtility.TrTextContent("Offset");
            public readonly GUIContent paddingLabel = EditorGUIUtility.TrTextContent("Padding");
            public readonly GUIContent automaticSlicingHintLabel = EditorGUIUtility.TrTextContent("To obtain more accurate slicing results, manual slicing is recommended!");
            public readonly GUIContent customPivotLabel = EditorGUIUtility.TrTextContent("Custom Pivot");
        }

        private void Init(Rect buttonRect, SpriteFrameModule sf, ITextureDataProvider dataProvider)
        {
            // Create for once if setting was not created before.
            if (s_Setting == null)
                s_Setting = CreateInstance<SpriteEditorMenuSetting>();

            m_SpriteFrameModule = sf;
            m_TextureDataProvider = dataProvider;

            buttonRect = GUIUtility.GUIToScreenRect(buttonRect);
            float windowHeight = 145;
            var windowSize = new Vector2(300, windowHeight);
            ShowAsDropDown(buttonRect, windowSize);

            Undo.undoRedoPerformed += UndoRedoPerformed;
        }

        private void UndoRedoPerformed()
        {
            Repaint();
        }

        void OnEnable()
        {
            AssemblyReloadEvents.beforeAssemblyReload += Close;
        }

        private void OnDisable()
        {
            AssemblyReloadEvents.beforeAssemblyReload -= Close;
            Undo.undoRedoPerformed -= UndoRedoPerformed;
            s_LastClosedTime = DateTime.Now.Ticks / TimeSpan.TicksPerMillisecond;
        }

        internal static bool ShowAtPosition(Rect buttonRect, SpriteFrameModule sf, ITextureDataProvider textureProvider)
        {
            // We could not use realtimeSinceStartUp since it is set to 0 when entering/exitting playmode, we assume an increasing time when comparing time.
            long nowMilliSeconds = DateTime.Now.Ticks / TimeSpan.TicksPerMillisecond;
            bool justClosed = nowMilliSeconds < s_LastClosedTime + 50;
            if (!justClosed)
            {
                if (UnityEvent.current != null) // Event.current can be null during integration test
                    UnityEvent.current.Use();

                SpriteEditorMenu spriteEditorMenu = CreateInstance<SpriteEditorMenu>();
                spriteEditorMenu.Init(buttonRect, sf, textureProvider);
                return true;
            }
            return false;
        }

        private void OnGUI()
        {
            if (s_Styles == null)
                s_Styles = new Styles();

            // Leave some space above the elements
            GUILayout.Space(4);

            EditorGUIUtility.labelWidth = 124f;
            EditorGUIUtility.wideMode = true;

            GUI.Label(new Rect(0, 0, position.width, position.height), GUIContent.none, s_Styles.background);

            EditorGUI.BeginChangeCheck();
            SpriteEditorMenuSetting.SlicingType slicingType = s_Setting.slicingType;
            slicingType = (SpriteEditorMenuSetting.SlicingType)EditorGUILayout.EnumPopup(s_Styles.typeLabel, slicingType);
            if (EditorGUI.EndChangeCheck())
            {
                Undo.RegisterCompleteObjectUndo(s_Setting, "Change slicing type");
                s_Setting.slicingType = slicingType;
            }
            switch (slicingType)
            {
                case SpriteEditorMenuSetting.SlicingType.GridByCellSize:
                case SpriteEditorMenuSetting.SlicingType.GridByCellCount:
                    OnGridGUI();
                    break;
                case SpriteEditorMenuSetting.SlicingType.Automatic:
                    OnAutomaticGUI();
                    break;
            }

            GUILayout.BeginHorizontal();
            GUILayout.Space(EditorGUIUtility.labelWidth + 4);
            if (GUILayout.Button(s_Styles.sliceButtonLabel))
                DoSlicing();
            GUILayout.EndHorizontal();
        }

        private void DoSlicing()
        {
            switch (s_Setting.slicingType)
            {
                case SpriteEditorMenuSetting.SlicingType.GridByCellCount:
                case SpriteEditorMenuSetting.SlicingType.GridByCellSize:
                    DoGridSlicing();
                    break;
                case SpriteEditorMenuSetting.SlicingType.Automatic:
                    DoAutomaticSlicing();
                    break;
            }
        }

        private void TwoIntFields(GUIContent label, GUIContent labelX, GUIContent labelY, ref int x, ref int y)
        {
            float height = EditorGUI.kSingleLineHeight;
            Rect rect = GUILayoutUtility.GetRect(EditorGUILayout.kLabelFloatMinW, EditorGUILayout.kLabelFloatMaxW, height, height, EditorStyles.numberField);

            Rect labelRect = rect;
            labelRect.width = EditorGUIUtility.labelWidth;
            labelRect.height = EditorGUI.kSingleLineHeight;

            GUI.Label(labelRect, label);

            Rect fieldRect = rect;
            fieldRect.width -= EditorGUIUtility.labelWidth;
            fieldRect.height = EditorGUI.kSingleLineHeight;
            fieldRect.x += EditorGUIUtility.labelWidth;
            fieldRect.width /= 2;
            fieldRect.width -= 2;

            EditorGUIUtility.labelWidth = 12;

            x = EditorGUI.IntField(fieldRect, labelX, x);
            fieldRect.x += fieldRect.width + 3;
            y = EditorGUI.IntField(fieldRect, labelY, y);

            EditorGUIUtility.labelWidth = labelRect.width;
        }

        private void OnGridGUI()
        {
            int width, height;
            m_TextureDataProvider.GetTextureActualWidthAndHeight(out width, out height);
            var texture = m_TextureDataProvider.GetReadableTexture2D();
            int maxWidth = texture != null ? width : 4096;
            int maxHeight = texture != null ? height : 4096;

            if (s_Setting.slicingType == SpriteEditorMenuSetting.SlicingType.GridByCellCount)
            {
                int x = (int)s_Setting.gridCellCount.x;
                int y = (int)s_Setting.gridCellCount.y;

                EditorGUI.BeginChangeCheck();
                TwoIntFields(s_Styles.columnAndRowLabel, s_Styles.columnLabel, s_Styles.rowLabel, ref x, ref y);
                if (EditorGUI.EndChangeCheck())
                {
                    Undo.RegisterCompleteObjectUndo(s_Setting, "Change column & row");

                    s_Setting.gridCellCount.x = Mathf.Clamp(x, 1, maxWidth);
                    s_Setting.gridCellCount.y = Mathf.Clamp(y, 1, maxHeight);
                }
            }
            else
            {
                int x = (int)s_Setting.gridSpriteSize.x;
                int y = (int)s_Setting.gridSpriteSize.y;

                EditorGUI.BeginChangeCheck();
                TwoIntFields(s_Styles.pixelSizeLabel, s_Styles.xLabel, s_Styles.yLabel, ref x, ref y);
                if (EditorGUI.EndChangeCheck())
                {
                    Undo.RegisterCompleteObjectUndo(s_Setting, "Change grid size");

                    s_Setting.gridSpriteSize.x = Mathf.Clamp(x, 1, maxWidth);
                    s_Setting.gridSpriteSize.y = Mathf.Clamp(y, 1, maxHeight);
                }
            }

            {
                int x = (int)s_Setting.gridSpriteOffset.x;
                int y = (int)s_Setting.gridSpriteOffset.y;

                EditorGUI.BeginChangeCheck();
                TwoIntFields(s_Styles.offsetLabel, s_Styles.xLabel, s_Styles.yLabel, ref x, ref y);
                if (EditorGUI.EndChangeCheck())
                {
                    Undo.RegisterCompleteObjectUndo(s_Setting, "Change grid offset");

                    s_Setting.gridSpriteOffset.x = Mathf.Clamp(x, 0, maxWidth - s_Setting.gridSpriteSize.x);
                    s_Setting.gridSpriteOffset.y = Mathf.Clamp(y, 0, maxHeight - s_Setting.gridSpriteSize.y);
                }
            }

            {
                int x = (int)s_Setting.gridSpritePadding.x;
                int y = (int)s_Setting.gridSpritePadding.y;

                EditorGUI.BeginChangeCheck();
                TwoIntFields(s_Styles.paddingLabel, s_Styles.xLabel, s_Styles.yLabel, ref x, ref y);
                if (EditorGUI.EndChangeCheck())
                {
                    Undo.RegisterCompleteObjectUndo(s_Setting, "Change grid padding");

                    s_Setting.gridSpritePadding.x = Mathf.Clamp(x, 0, maxWidth);
                    s_Setting.gridSpritePadding.y = Mathf.Clamp(y, 0, maxHeight);
                }
            }

            DoPivotGUI();

            GUILayout.Space(2f);
        }

        private void OnAutomaticGUI()
        {
            float spacing = 38f;
            var texture = m_TextureDataProvider.GetReadableTexture2D();
            if (texture != null && UnityEditor.TextureUtil.IsCompressedTextureFormat(texture.format))
            {
                EditorGUILayout.LabelField(s_Styles.automaticSlicingHintLabel, s_Styles.notice);
                spacing -= 31f;
            }

            DoPivotGUI();

            EditorGUI.BeginChangeCheck();
            int slicingMethod = s_Setting.autoSlicingMethod;
            slicingMethod = EditorGUILayout.Popup(s_Styles.methodLabel, slicingMethod, s_Styles.slicingMethodOptions);
            if (EditorGUI.EndChangeCheck())
            {
                Undo.RegisterCompleteObjectUndo(s_Setting, "Change Slicing Method");
                s_Setting.autoSlicingMethod = slicingMethod;
            }
            GUILayout.Space(spacing);
        }

        private void DoPivotGUI()
        {
            EditorGUI.BeginChangeCheck();
            int alignment = s_Setting.spriteAlignment;
            alignment = EditorGUILayout.Popup(s_Styles.pivotLabel, alignment, s_Styles.spriteAlignmentOptions);
            if (EditorGUI.EndChangeCheck())
            {
                Undo.RegisterCompleteObjectUndo(s_Setting, "Change Alignment");
                s_Setting.spriteAlignment = alignment;
                s_Setting.pivot = SpriteEditorUtility.GetPivotValue((SpriteAlignment)alignment, s_Setting.pivot);
            }

            Vector2 pivot = s_Setting.pivot;
            EditorGUI.BeginChangeCheck();
            using (new EditorGUI.DisabledScope(alignment != (int)SpriteAlignment.Custom))
            {
                pivot = EditorGUILayout.Vector2Field(s_Styles.customPivotLabel, pivot);
            }
            if (EditorGUI.EndChangeCheck())
            {
                Undo.RegisterCompleteObjectUndo(s_Setting, "Change custom pivot");

                s_Setting.pivot = pivot;
            }
        }

        private void DoAutomaticSlicing()
        {
            // 4 seems to be a pretty nice min size for a automatic sprite slicing. It used to be exposed to the slicing dialog, but it is actually better workflow to slice&crop manually than find a suitable size number
            m_SpriteFrameModule.DoAutomaticSlicing(4, s_Setting.spriteAlignment, s_Setting.pivot, (SpriteFrameModule.AutoSlicingMethod)s_Setting.autoSlicingMethod);
        }

        private void DoGridSlicing()
        {
            if (s_Setting.slicingType == SpriteEditorMenuSetting.SlicingType.GridByCellCount)
                DetemineGridCellSizeWithCellCount();

            m_SpriteFrameModule.DoGridSlicing(s_Setting.gridSpriteSize, s_Setting.gridSpriteOffset, s_Setting.gridSpritePadding, s_Setting.spriteAlignment, s_Setting.pivot);
        }

        private void DetemineGridCellSizeWithCellCount()
        {
            int width, height;
            m_TextureDataProvider.GetTextureActualWidthAndHeight(out width, out height);
            var texture = m_TextureDataProvider.GetReadableTexture2D();
            int maxWidth = texture != null ? width : 4096;
            int maxHeight = texture != null ? height : 4096;

            s_Setting.gridSpriteSize.x = (maxWidth - s_Setting.gridSpriteOffset.x - (s_Setting.gridSpritePadding.x * s_Setting.gridCellCount.x)) / s_Setting.gridCellCount.x;
            s_Setting.gridSpriteSize.y = (maxHeight - s_Setting.gridSpriteOffset.y - (s_Setting.gridSpritePadding.y * s_Setting.gridCellCount.y)) / s_Setting.gridCellCount.y;

            s_Setting.gridSpriteSize.x = Mathf.Clamp(s_Setting.gridSpriteSize.x, 1, maxWidth);
            s_Setting.gridSpriteSize.y = Mathf.Clamp(s_Setting.gridSpriteSize.y, 1, maxHeight);
        }
    }
}
