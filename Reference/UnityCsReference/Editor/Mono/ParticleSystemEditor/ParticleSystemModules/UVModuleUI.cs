// Unity C# reference source
// Copyright (c) Unity Technologies. For terms of use, see
// https://unity3d.com/legal/licenses/Unity_Reference_Only_License

using UnityEngine;
using UnityEditorInternal;

namespace UnityEditor
{
    class UVModuleUI : ModuleUI
    {
        SerializedProperty m_Mode;
        SerializedProperty m_TimeMode;
        SerializedProperty m_FPS;
        SerializedMinMaxCurve m_FrameOverTime;
        SerializedMinMaxCurve m_StartFrame;
        SerializedProperty m_SpeedRange;
        SerializedProperty m_TilesX;
        SerializedProperty m_TilesY;
        SerializedProperty m_AnimationType;
        SerializedProperty m_RandomRow;
        SerializedProperty m_RowIndex;
        SerializedProperty m_Sprites;
        SerializedProperty m_Cycles;
        SerializedProperty m_UVChannelMask;

        class Texts
        {
            public GUIContent mode = EditorGUIUtility.TrTextContent("Mode", "Animation frames can either be specified on a regular grid texture, or as a list of Sprites.");
            public GUIContent timeMode = EditorGUIUtility.TrTextContent("Time Mode", "Play frames either based on the lifetime of the particle, the speed of the particle, or at a constant FPS, regardless of particle lifetime.");
            public GUIContent fps = EditorGUIUtility.TrTextContent("FPS", "Specify the Frames Per Second of the animation.");
            public GUIContent frameOverTime = EditorGUIUtility.TrTextContent("Frame over Time", "Controls the uv animation frame of each particle over its lifetime. On the horisontal axis you will find the lifetime. On the vertical axis you will find the sheet index.");
            public GUIContent startFrame = EditorGUIUtility.TrTextContent("Start Frame", "Phase the animation, so it starts on a frame other than 0.");
            public GUIContent speedRange = EditorGUIUtility.TrTextContent("Speed Range", "Remaps speed in the defined range to a 0-1 value through the animation.");
            public GUIContent tiles = EditorGUIUtility.TrTextContent("Tiles", "Defines the tiling of the texture.");
            public GUIContent tilesX = EditorGUIUtility.TextContent("X");
            public GUIContent tilesY = EditorGUIUtility.TextContent("Y");
            public GUIContent animation = EditorGUIUtility.TrTextContent("Animation", "Specifies the animation type: Whole Sheet or Single Row. Whole Sheet will animate over the whole texture sheet from left to right, top to bottom. Single Row will animate a single row in the sheet from left to right.");
            public GUIContent randomRow = EditorGUIUtility.TrTextContent("Random Row", "If enabled, the animated row will be chosen randomly.");
            public GUIContent row = EditorGUIUtility.TrTextContent("Row", "The row in the sheet which will be played.");
            public GUIContent sprites = EditorGUIUtility.TrTextContent("Sprites", "The list of Sprites to be played.");
            public GUIContent frame = EditorGUIUtility.TrTextContent("Frame", "The frame in the sheet which will be used.");
            public GUIContent cycles = EditorGUIUtility.TrTextContent("Cycles", "Specifies how many times the animation will loop during the lifetime of the particle.");
            public GUIContent uvChannelMask = EditorGUIUtility.TrTextContent("Affected UV Channels", "Specifies which UV channels will be animated.");

            public GUIContent[] modes = new GUIContent[]
            {
                EditorGUIUtility.TrTextContent("Grid"),
                EditorGUIUtility.TrTextContent("Sprites")
            };

            public GUIContent[] timeModes = new GUIContent[]
            {
                EditorGUIUtility.TrTextContent("Lifetime"),
                EditorGUIUtility.TrTextContent("Speed"),
                EditorGUIUtility.TrTextContent("FPS")
            };

            public GUIContent[] types = new GUIContent[]
            {
                EditorGUIUtility.TrTextContent("Whole Sheet"),
                EditorGUIUtility.TrTextContent("Single Row")
            };
        }
        private static Texts s_Texts;


        public UVModuleUI(ParticleSystemUI owner, SerializedObject o, string displayName)
            : base(owner, o, "UVModule", displayName)
        {
            m_ToolTip = "Particle UV animation. This allows you to specify a texture sheet (a texture with multiple tiles/sub frames) and animate or randomize over it per particle.";
        }

        protected override void Init()
        {
            // Already initialized?
            if (m_TilesX != null)
                return;
            if (s_Texts == null)
                s_Texts = new Texts();

            m_Mode = GetProperty("mode");
            m_TimeMode = GetProperty("timeMode");
            m_FPS = GetProperty("fps");
            m_FrameOverTime = new SerializedMinMaxCurve(this, s_Texts.frameOverTime, "frameOverTime");
            m_StartFrame = new SerializedMinMaxCurve(this, s_Texts.startFrame, "startFrame");
            m_StartFrame.m_AllowCurves = false;
            m_SpeedRange = GetProperty("speedRange");
            m_TilesX = GetProperty("tilesX");
            m_TilesY = GetProperty("tilesY");
            m_AnimationType = GetProperty("animationType");
            m_RandomRow = GetProperty("randomRow");
            m_RowIndex = GetProperty("rowIndex");
            m_Sprites = GetProperty("sprites");
            m_Cycles = GetProperty("cycles");
            m_UVChannelMask = GetProperty("uvChannelMask");
        }

        override public void OnInspectorGUI(InitialModuleUI initial)
        {
            int mode = GUIPopup(s_Texts.mode, m_Mode, s_Texts.modes);
            if (!m_Mode.hasMultipleDifferentValues)
            {
                if (mode == (int)ParticleSystemAnimationMode.Grid)
                {
                    GUIIntDraggableX2(s_Texts.tiles, s_Texts.tilesX, m_TilesX, s_Texts.tilesY, m_TilesY);

                    int type = GUIPopup(s_Texts.animation, m_AnimationType, s_Texts.types);
                    if (type == (int)ParticleSystemAnimationType.SingleRow)
                    {
                        GUIToggle(s_Texts.randomRow, m_RandomRow);
                        if (!m_RandomRow.boolValue)
                            GUIInt(s_Texts.row, m_RowIndex);

                        m_FrameOverTime.m_RemapValue = (float)(m_TilesX.intValue);
                        m_StartFrame.m_RemapValue = (float)(m_TilesX.intValue);
                    }
                    else
                    {
                        m_FrameOverTime.m_RemapValue = (float)(m_TilesX.intValue * m_TilesY.intValue);
                        m_StartFrame.m_RemapValue = (float)(m_TilesX.intValue * m_TilesY.intValue);
                    }
                }
                else
                {
                    DoListOfSpritesGUI();
                    ValidateSpriteList();

                    m_FrameOverTime.m_RemapValue = (float)(m_Sprites.arraySize);
                    m_StartFrame.m_RemapValue = (float)(m_Sprites.arraySize);
                }
            }

            int timeMode = GUIPopup(s_Texts.timeMode, m_TimeMode, s_Texts.timeModes);
            if (!m_TimeMode.hasMultipleDifferentValues)
            {
                if (timeMode == (int)ParticleSystemAnimationTimeMode.FPS)
                    GUIFloat(s_Texts.fps, m_FPS);
                else if (timeMode == (int)ParticleSystemAnimationTimeMode.Speed)
                    GUIMinMaxRange(s_Texts.speedRange, m_SpeedRange);
                else
                    GUIMinMaxCurve(s_Texts.frameOverTime, m_FrameOverTime);
            }
            GUIMinMaxCurve(s_Texts.startFrame, m_StartFrame);

            if (!m_TimeMode.hasMultipleDifferentValues && timeMode != (int)ParticleSystemAnimationTimeMode.FPS)
                GUIFloat(s_Texts.cycles, m_Cycles);
            GUIEnumMaskUVChannelFlags(s_Texts.uvChannelMask, m_UVChannelMask);
        }

        private void DoListOfSpritesGUI()
        {
            for (int i = 0; i < m_Sprites.arraySize; i++)
            {
                GUILayout.BeginHorizontal();

                SerializedProperty spriteData = m_Sprites.GetArrayElementAtIndex(i);
                SerializedProperty sprite = spriteData.FindPropertyRelative("sprite");
                GUIObject(new GUIContent(" "), sprite, typeof(Sprite));

                // add plus button to first element
                if (i == 0)
                {
                    if (GUILayout.Button(GUIContent.none, "OL Plus", GUILayout.Width(16)))
                    {
                        m_Sprites.InsertArrayElementAtIndex(m_Sprites.arraySize);
                        SerializedProperty newSpriteData = m_Sprites.GetArrayElementAtIndex(m_Sprites.arraySize - 1);
                        SerializedProperty newSprite = newSpriteData.FindPropertyRelative("sprite");
                        newSprite.objectReferenceValue = null;
                    }
                }
                // add minus button to all other elements
                else
                {
                    if (GUILayout.Button(GUIContent.none, "OL Minus", GUILayout.Width(16)))
                        m_Sprites.DeleteArrayElementAtIndex(i);
                }

                GUILayout.EndHorizontal();
            }
        }

        private void ValidateSpriteList()
        {
            if (m_Sprites.arraySize <= 1)
                return;

            Texture texture = null;
            for (int i = 0; i < m_Sprites.arraySize; i++)
            {
                SerializedProperty spriteData = m_Sprites.GetArrayElementAtIndex(i);
                SerializedProperty prop = spriteData.FindPropertyRelative("sprite");
                Sprite sprite = prop.objectReferenceValue as Sprite;
                if (sprite != null)
                {
                    if (texture == null)
                    {
                        texture = sprite.GetTextureForPlayMode();
                    }
                    else if (texture != sprite.GetTextureForPlayMode())
                    {
                        EditorGUILayout.HelpBox("All Sprites must share the same texture. Either pack all Sprites into one Texture by setting the Packing Tag, or use a Multiple Mode Sprite.", MessageType.Error, true);
                        break;
                    }
                    else if (sprite.border != Vector4.zero)
                    {
                        EditorGUILayout.HelpBox("Sprite borders are not supported. They will be ignored.", MessageType.Warning, true);
                        break;
                    }
                }
            }
        }
    }
} // namespace UnityEditor
