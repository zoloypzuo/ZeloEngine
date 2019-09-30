// Unity C# reference source
// Copyright (c) Unity Technologies. For terms of use, see
// https://unity3d.com/legal/licenses/Unity_Reference_Only_License

using UnityEngine;
using System.Collections.Generic;
using UnityEngine.Rendering;
using UnityEngine.Experimental.Rendering;
using UnityEditor.AnimatedValues;
using System.Linq;

namespace UnityEditor
{
    internal enum DefaultReflectionMode
    {
        FromSkybox = 0,
        Custom
    }

    [CustomEditor(typeof(RenderSettings))]
    internal class LightingEditor : Editor
    {
        internal static class Styles
        {
            static Styles() {}

            public static readonly GUIContent env_top = EditorGUIUtility.TrTextContent("Environment");
            public static readonly GUIContent env_skybox_mat = EditorGUIUtility.TrTextContent("Skybox Material", "Specifies the material that is used to simulate the sky or other distant background in the Scene.");
            public static readonly GUIContent env_skybox_sun = EditorGUIUtility.TrTextContent("Sun Source", "Specifies the directional light that is used to indicate the direction of the sun when a procedural skybox is used. If set to None, the brightest directional light in the Scene is used to represent the sun.");
            public static readonly GUIContent env_amb_top = EditorGUIUtility.TrTextContent("Environment Lighting");
            public static readonly GUIContent env_amb_src = EditorGUIUtility.TrTextContent("Source", "Specifies whether to use a skybox, gradient, or color for ambient light contributed to the Scene.");
            public static readonly GUIContent env_amb_int = EditorGUIUtility.TrTextContent("Intensity Multiplier", "Controls the brightness of the skybox lighting in the Scene.");
            public static readonly GUIContent env_refl_top = EditorGUIUtility.TrTextContent("Environment Reflections");
            public static readonly GUIContent env_refl_src = EditorGUIUtility.TrTextContent("Source", "Specifies whether to use the skybox or a custom cube map for reflection effects in the Scene.");
            public static readonly GUIContent env_refl_res = EditorGUIUtility.TrTextContent("Resolution", "Controls the resolution for the cube map assigned to the skybox material for reflection effects in the Scene.");
            public static readonly GUIContent env_refl_cmp = EditorGUIUtility.TrTextContent("Compression", "Controls how Unity compresses the reflection cube maps. Options are Auto, Compressed, and Uncompressed. Auto compresses the cube maps if the compression format is suitable.");
            public static readonly GUIContent env_refl_int = EditorGUIUtility.TrTextContent("Intensity Multiplier", "Controls how much the skybox or custom cubemap affects reflections in the Scene. A value of 1 produces physically correct results.");
            public static readonly GUIContent env_refl_bnc = EditorGUIUtility.TrTextContent("Bounces", "Controls how many times a reflection includes other reflections. A value of 1 results in the Scene being rendered once so mirrored reflections will be black. A value of 2 results in mirrored reflections being visible in the Scene.");
            public static readonly GUIContent skyboxWarning = EditorGUIUtility.TrTextContent("Shader of this material does not support skybox rendering.");
            public static readonly GUIContent createLight = EditorGUIUtility.TrTextContent("Create Light");
            public static readonly GUIContent ambientUp = EditorGUIUtility.TrTextContent("Sky Color", "Controls the color of light emitted from the sky in the Scene.");
            public static readonly GUIContent ambientMid = EditorGUIUtility.TrTextContent("Equator Color", "Controls the color of light emitted from the sides of the Scene.");
            public static readonly GUIContent ambientDown = EditorGUIUtility.TrTextContent("Ground Color", "Controls the color of light emitted from the ground of the Scene.");
            public static readonly GUIContent ambient = EditorGUIUtility.TrTextContent("Ambient Color", "Controls the color of the ambient light contributed to the Scene.");
            public static readonly GUIContent customReflection = EditorGUIUtility.TrTextContent("Cubemap", "Specifies the custom cube map used for reflection effects in the Scene.");
            public static readonly GUIContent AmbientLightingMode = EditorGUIUtility.TrTextContent("Ambient Mode", "Specifies the Global Illumination mode that should be used for handling ambient light in the Scene. Options are Realtime or Baked. This property is not editable unless both Realtime Global Illumination and Baked Global Illumination are enabled for the scene.");

            public static readonly GUIContent[] kFullAmbientSource =
            {
                EditorGUIUtility.TrTextContent("Skybox"),
                EditorGUIUtility.TrTextContent("Gradient"),
                EditorGUIUtility.TrTextContent("Color"),
            };

            public static readonly GUIContent[] AmbientLightingModes =
            {
                EditorGUIUtility.TrTextContent("Realtime"),
                EditorGUIUtility.TrTextContent("Baked")
            };

            public static readonly int[] kFullAmbientSourceValues = { (int)AmbientMode.Skybox, (int)AmbientMode.Trilight, (int)AmbientMode.Flat };
        }

        protected SerializedProperty m_EnabledBakedGI;
        protected SerializedProperty m_EnabledRealtimeGI;

        protected SerializedProperty m_Sun;
        protected SerializedProperty m_AmbientSource;
        protected SerializedProperty m_AmbientSkyColor;
        protected SerializedProperty m_AmbientEquatorColor;
        protected SerializedProperty m_AmbientGroundColor;
        protected SerializedProperty m_AmbientIntensity;
        protected SerializedProperty m_AmbientLightingMode;

        protected SerializedProperty m_ReflectionIntensity;
        protected SerializedProperty m_ReflectionBounces;

        protected SerializedProperty m_SkyboxMaterial;
        protected SerializedProperty m_DefaultReflectionMode;
        protected SerializedProperty m_DefaultReflectionResolution;
        protected SerializedProperty m_CustomReflection;
        protected SerializedProperty m_ReflectionCompression;

        protected SerializedObject m_RenderSettings;
        protected SerializedObject m_LightmapSettings;

        private bool m_bShowEnvironment;
        private const string kShowEnvironment = "ShowEnvironment";

        private void InitSettings()
        {
            m_RenderSettings = new SerializedObject(RenderSettings.GetRenderSettings());
            m_Sun = m_RenderSettings.FindProperty("m_Sun");
            m_AmbientSource = m_RenderSettings.FindProperty("m_AmbientMode");
            m_AmbientSkyColor = m_RenderSettings.FindProperty("m_AmbientSkyColor");
            m_AmbientEquatorColor = m_RenderSettings.FindProperty("m_AmbientEquatorColor");
            m_AmbientGroundColor = m_RenderSettings.FindProperty("m_AmbientGroundColor");
            m_AmbientIntensity = m_RenderSettings.FindProperty("m_AmbientIntensity");
            m_ReflectionIntensity = m_RenderSettings.FindProperty("m_ReflectionIntensity");
            m_ReflectionBounces = m_RenderSettings.FindProperty("m_ReflectionBounces");
            m_SkyboxMaterial = m_RenderSettings.FindProperty("m_SkyboxMaterial");
            m_DefaultReflectionMode = m_RenderSettings.FindProperty("m_DefaultReflectionMode");
            m_DefaultReflectionResolution = m_RenderSettings.FindProperty("m_DefaultReflectionResolution");
            m_CustomReflection = m_RenderSettings.FindProperty("m_CustomReflection");

            m_LightmapSettings = new SerializedObject(LightmapEditorSettings.GetLightmapSettings());
            m_ReflectionCompression = m_LightmapSettings.FindProperty("m_LightmapEditorSettings.m_ReflectionCompression");
            m_AmbientLightingMode = m_LightmapSettings.FindProperty("m_GISettings.m_EnvironmentLightingMode");
            m_EnabledBakedGI = m_LightmapSettings.FindProperty("m_GISettings.m_EnableBakedLightmaps");
            m_EnabledRealtimeGI = m_LightmapSettings.FindProperty("m_GISettings.m_EnableRealtimeLightmaps");

            m_bShowEnvironment = SessionState.GetBool(kShowEnvironment, true);
        }

        public virtual void OnEnable()
        {
            InitSettings();
        }

        public virtual void OnDisable()
        {
            SessionState.SetBool(kShowEnvironment, m_bShowEnvironment);
        }

        private void DrawGUI()
        {
            Material skyboxMaterial = m_SkyboxMaterial.objectReferenceValue as Material;

            m_bShowEnvironment = EditorGUILayout.FoldoutTitlebar(m_bShowEnvironment, Styles.env_top, true);

            if (m_bShowEnvironment)
            {
                EditorGUI.indentLevel++;

                EditorGUILayout.PropertyField(m_SkyboxMaterial, Styles.env_skybox_mat);
                if (skyboxMaterial && !EditorMaterialUtility.IsBackgroundMaterial(skyboxMaterial))
                {
                    EditorGUILayout.HelpBox(Styles.skyboxWarning.text, MessageType.Warning);
                }

                EditorGUILayout.PropertyField(m_Sun, Styles.env_skybox_sun);
                EditorGUILayout.Space();

                EditorGUILayout.LabelField(Styles.env_amb_top);
                EditorGUI.indentLevel++;

                EditorGUILayout.IntPopup(m_AmbientSource, Styles.kFullAmbientSource, Styles.kFullAmbientSourceValues, Styles.env_amb_src);
                switch ((AmbientMode)m_AmbientSource.intValue)
                {
                    case AmbientMode.Trilight:
                    {
                        EditorGUI.BeginChangeCheck();
                        Color newValueUp = EditorGUILayout.ColorField(Styles.ambientUp, m_AmbientSkyColor.colorValue, true, false, true);
                        Color newValueMid = EditorGUILayout.ColorField(Styles.ambientMid, m_AmbientEquatorColor.colorValue, true, false, true);
                        Color newValueDown = EditorGUILayout.ColorField(Styles.ambientDown, m_AmbientGroundColor.colorValue, true, false, true);
                        if (EditorGUI.EndChangeCheck())
                        {
                            m_AmbientSkyColor.colorValue = newValueUp;
                            m_AmbientEquatorColor.colorValue = newValueMid;
                            m_AmbientGroundColor.colorValue = newValueDown;
                        }
                    }
                    break;

                    case AmbientMode.Flat:
                    {
                        EditorGUI.BeginChangeCheck();
                        Color newValue = EditorGUILayout.ColorField(Styles.ambient, m_AmbientSkyColor.colorValue, true, false, true);
                        if (EditorGUI.EndChangeCheck())
                            m_AmbientSkyColor.colorValue = newValue;
                    }
                    break;

                    case AmbientMode.Skybox:
                        if (skyboxMaterial == null)
                        {
                            EditorGUI.BeginChangeCheck();
                            Color newValue = EditorGUILayout.ColorField(Styles.ambient, m_AmbientSkyColor.colorValue, true, false, true);
                            if (EditorGUI.EndChangeCheck())
                                m_AmbientSkyColor.colorValue = newValue;
                        }
                        else
                        {
                            // Ambient intensity - maximum is kEmissiveRGBMMax
                            EditorGUILayout.Slider(m_AmbientIntensity, 0.0F, 8.0F, Styles.env_amb_int);
                        }
                        break;
                }

                // ambient GI - realtime / baked
                bool realtimeGISupported = SupportedRenderingFeatures.IsLightmapBakeTypeSupported(LightmapBakeType.Realtime);
                bool bakedGISupported = SupportedRenderingFeatures.IsLightmapBakeTypeSupported(LightmapBakeType.Baked);

                if ((m_EnabledBakedGI.boolValue || m_EnabledRealtimeGI.boolValue) && (bakedGISupported || realtimeGISupported))
                {
                    int[] modeVals = { 0, 1 };

                    if (m_EnabledBakedGI.boolValue && m_EnabledRealtimeGI.boolValue)
                    {
                        // if the user has selected the only state that is supported, then gray it out
                        using (new EditorGUI.DisabledScope(((m_AmbientLightingMode.intValue == 0) && realtimeGISupported && !bakedGISupported) || ((m_AmbientLightingMode.intValue == 1) && bakedGISupported && !realtimeGISupported)))
                        {
                            EditorGUILayout.IntPopup(m_AmbientLightingMode, Styles.AmbientLightingModes, modeVals, Styles.AmbientLightingMode);
                        }

                        // if they have selected a state that isnt supported, show dialog, and still make the box editable
                        if (((m_AmbientLightingMode.intValue == 0) && !realtimeGISupported) ||
                            ((m_AmbientLightingMode.intValue == 1) && !bakedGISupported))
                        {
                            EditorGUILayout.HelpBox("The following mode is not supported and will fallback on " + (((m_AmbientLightingMode.intValue == 0) && !realtimeGISupported) ? "Baked" : "Realtime"), MessageType.Warning);
                        }
                    }
                    // Show "Baked" if precomputed GI is disabled and "Realtime" if baked GI is disabled (but we don't wanna show the box if the whole mode is not supported.)
                    else if ((m_EnabledBakedGI.boolValue && bakedGISupported) || (m_EnabledRealtimeGI.boolValue && realtimeGISupported))
                    {
                        using (new EditorGUI.DisabledScope(true))
                        {
                            EditorGUILayout.IntPopup(Styles.AmbientLightingMode, m_EnabledBakedGI.boolValue ? 1 : 0, Styles.AmbientLightingModes, modeVals);
                        }
                    }
                }

                EditorGUI.indentLevel--;
                EditorGUILayout.Space();

                EditorGUILayout.LabelField(Styles.env_refl_top);
                EditorGUI.indentLevel++;

                EditorGUILayout.PropertyField(m_DefaultReflectionMode, Styles.env_refl_src);

                DefaultReflectionMode defReflectionMode = (DefaultReflectionMode)m_DefaultReflectionMode.intValue;
                switch (defReflectionMode)
                {
                    case DefaultReflectionMode.FromSkybox:
                    {
                        int[] reflectionResolutionValuesArray = null;
                        GUIContent[] reflectionResolutionTextArray = null;
                        ReflectionProbeEditor.GetResolutionArray(ref reflectionResolutionValuesArray, ref reflectionResolutionTextArray);
                        EditorGUILayout.IntPopup(m_DefaultReflectionResolution, reflectionResolutionTextArray, reflectionResolutionValuesArray, Styles.env_refl_res, GUILayout.MinWidth(40));
                    }
                    break;
                    case DefaultReflectionMode.Custom:
                        EditorGUILayout.PropertyField(m_CustomReflection, Styles.customReflection);
                        break;
                }

                EditorGUILayout.PropertyField(m_ReflectionCompression, Styles.env_refl_cmp);
                EditorGUILayout.Slider(m_ReflectionIntensity, 0.0F, 1.0F, Styles.env_refl_int);
                EditorGUILayout.IntSlider(m_ReflectionBounces, 1, 5, Styles.env_refl_bnc);

                EditorGUI.indentLevel--;

                EditorGUI.indentLevel--;
                EditorGUILayout.Space();
            }
        }

        public override void OnInspectorGUI()
        {
            if (m_RenderSettings == null || m_RenderSettings.targetObject != RenderSettings.GetRenderSettings() || m_LightmapSettings == null || m_LightmapSettings.targetObject != LightmapEditorSettings.GetLightmapSettings())
            {
                InitSettings();
            }

            m_RenderSettings.Update();
            m_LightmapSettings.Update();

            DrawGUI();

            m_RenderSettings.ApplyModifiedProperties();
            m_LightmapSettings.ApplyModifiedProperties();
        }
    }
}
