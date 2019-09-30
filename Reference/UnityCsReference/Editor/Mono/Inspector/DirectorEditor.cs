// Unity C# reference source
// Copyright (c) Unity Technologies. For terms of use, see
// https://unity3d.com/legal/licenses/Unity_Reference_Only_License

using System;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEditorInternal;
using UnityEngine.Playables;

namespace UnityEditor
{
    [CustomEditor(typeof(PlayableDirector))]
    [CanEditMultipleObjects]
    internal class DirectorEditor : Editor
    {
        private static class Styles
        {
            public static readonly GUIContent PlayableText = EditorGUIUtility.TrTextContent("Playable");
            public static readonly GUIContent InitialTimeContent = EditorGUIUtility.TrTextContent("Initial Time", "The time at which the Playable will begin playing");
            public static readonly GUIContent TimeContent = EditorGUIUtility.TrTextContent("Current Time", "The current Playable time");
            public static readonly GUIContent InitialStateContent = EditorGUIUtility.TrTextContent("Play On Awake", "Whether the Playable should be playing after it loads");
            public static readonly GUIContent UpdateMethod = EditorGUIUtility.TrTextContent("Update Method", "Controls how the Playable updates every frame");
            public static readonly GUIContent WrapModeContent = EditorGUIUtility.TrTextContent("Wrap Mode", "Controls the behaviour of evaluating the Playable outside its duration");
            public static readonly GUIContent NoBindingsContent = EditorGUIUtility.TrTextContent("This channel will not playback because it is not currently assigned");
            public static readonly GUIContent BindingsTitleContent = EditorGUIUtility.TrTextContent("Bindings");

            public static readonly int ObjectFieldControlID = "s_ObjectFieldHash".GetHashCode();
        }

        private SerializedProperty m_PlayableAsset;
        private SerializedProperty m_InitialState;
        private SerializedProperty m_WrapMode;
        private SerializedProperty m_InitialTime;
        private SerializedProperty m_UpdateMethod;
        private SerializedProperty m_SceneBindings;

        private Texture    m_DefaultScriptContentTexture;

        private GUIContent m_BindingContent = new GUIContent();

        private struct BindingPropertyPair
        {
            public PlayableBinding binding;
            public SerializedProperty property;
        }

        private List<BindingPropertyPair> m_BindingPropertiesCache = new List<BindingPropertyPair>();

        private PlayableBinding[] m_SynchedPlayableBindings = null;

        public void OnEnable()
        {
            m_PlayableAsset = serializedObject.FindProperty("m_PlayableAsset");
            m_InitialState = serializedObject.FindProperty("m_InitialState");
            m_WrapMode = serializedObject.FindProperty("m_WrapMode");
            m_UpdateMethod = serializedObject.FindProperty("m_DirectorUpdateMode");
            m_InitialTime = serializedObject.FindProperty("m_InitialTime");
            m_SceneBindings = serializedObject.FindProperty("m_SceneBindings");

            m_DefaultScriptContentTexture = EditorGUIUtility.FindTexture(typeof(ScriptableObject));
        }

        public override void OnInspectorGUI()
        {
            if (PlayableAssetOutputsChanged())
                SynchSceneBindings();

            serializedObject.Update();

            if (PropertyFieldAsObject(m_PlayableAsset, Styles.PlayableText, typeof(PlayableAsset)))
            {
                serializedObject.ApplyModifiedProperties();
                SynchSceneBindings();

                // some editors (like Timeline) needs to repaint when the playable asset changes
                InternalEditorUtility.RepaintAllViews();
            }

            EditorGUILayout.PropertyField(m_UpdateMethod, Styles.UpdateMethod);

            var rect = EditorGUILayout.GetControlRect(true);
            var label = EditorGUI.BeginProperty(rect, Styles.InitialStateContent, m_InitialState);
            bool playOnAwake = m_InitialState.enumValueIndex != (int)PlayState.Paused;
            EditorGUI.BeginChangeCheck();
            playOnAwake = EditorGUI.Toggle(rect, label, playOnAwake);
            if (EditorGUI.EndChangeCheck())
            {
                m_InitialState.enumValueIndex = (int)(playOnAwake ? PlayState.Playing : PlayState.Paused);
            }
            EditorGUI.EndProperty();

            EditorGUILayout.PropertyField(m_WrapMode, Styles.WrapModeContent);

            PropertyFieldAsFloat(m_InitialTime, Styles.InitialTimeContent);

            if (Application.isPlaying)
            {
                // time field isn't functional in Editor, unless the sequencer window is open,
                // at which point it isn't required. In playmode it can provide valuable feedback,
                // and allow the user to scrub and debug without the sequencer window
                CurrentTimeField();
            }

            if (targets.Length == 1)
            {
                var playableAsset = m_PlayableAsset.objectReferenceValue as PlayableAsset;
                if (playableAsset != null)
                    DoDirectorBindingInspector();
            }

            serializedObject.ApplyModifiedProperties();
        }

        private bool PlayableAssetOutputsChanged()
        {
            var playableAsset = m_PlayableAsset.objectReferenceValue as PlayableAsset;

            if (m_SynchedPlayableBindings == null)
                return playableAsset != null;

            if (playableAsset == null)
                return true;

            if (playableAsset.outputs.Count() != m_SynchedPlayableBindings.Length)
                return true;

            return playableAsset.outputs.Where((t, i) => t.sourceObject != m_SynchedPlayableBindings[i].sourceObject).Any();
        }

        private void BindingInspector(SerializedProperty bindingProperty, PlayableBinding binding)
        {
            if (binding.sourceObject == null || binding.outputTargetType == null || !typeof(UnityEngine.Object).IsAssignableFrom(binding.outputTargetType))
                return;

            var source = bindingProperty.objectReferenceValue;
            PropertyFieldAsObject(bindingProperty,
                GetContentForOutput(binding, source),
                binding.outputTargetType
            );
        }

        GUIContent GetContentForOutput(PlayableBinding binding, UnityEngine.Object source)
        {
            m_BindingContent.text = binding.streamName;
            m_BindingContent.tooltip = (source == null) ? Styles.NoBindingsContent.text : string.Empty;
            m_BindingContent.image = AssetPreview.GetMiniTypeThumbnail(binding.outputTargetType) ?? m_DefaultScriptContentTexture;
            return m_BindingContent;
        }

        private void DoDirectorBindingInspector()
        {
            if (!m_BindingPropertiesCache.Any())
                return;

            m_SceneBindings.isExpanded = EditorGUILayout.Foldout(m_SceneBindings.isExpanded, Styles.BindingsTitleContent);
            if (m_SceneBindings.isExpanded)
            {
                EditorGUI.indentLevel++;

                foreach (var bindingPropertyPair in m_BindingPropertiesCache)
                {
                    BindingInspector(bindingPropertyPair.property, bindingPropertyPair.binding);
                }

                EditorGUI.indentLevel--;
            }
        }

        void SynchSceneBindings()
        {
            if (targets.Length > 1)
                return;

            var director = (PlayableDirector)target;
            var playableAsset = m_PlayableAsset.objectReferenceValue as PlayableAsset;

            m_BindingPropertiesCache.Clear();
            m_SynchedPlayableBindings = null;

            if (playableAsset == null)
                return;

            var bindings = playableAsset.outputs;
            m_SynchedPlayableBindings = bindings.ToArray();

            foreach (var binding in m_SynchedPlayableBindings)
            {
                if (!director.HasGenericBinding(binding.sourceObject))
                    director.SetGenericBinding(binding.sourceObject, null);
            }

            serializedObject.Update();

            var serializedProperties = new SerializedProperty[m_SceneBindings.arraySize];
            for (int i = 0; i < m_SceneBindings.arraySize; ++i)
            {
                serializedProperties[i] = m_SceneBindings.GetArrayElementAtIndex(i);
            }

            foreach (var binding in m_SynchedPlayableBindings)
            {
                foreach (var prop in serializedProperties)
                {
                    if (prop.FindPropertyRelative("key").objectReferenceValue == binding.sourceObject)
                    {
                        m_BindingPropertiesCache.Add(new BindingPropertyPair { binding = binding, property = prop.FindPropertyRelative("value")});
                        break;
                    }
                }
            }
        }

        // To show the current time field in play mode
        public override bool RequiresConstantRepaint()
        {
            return Application.isPlaying;
        }

        private static void PropertyFieldAsFloat(SerializedProperty property, GUIContent title)
        {
            Rect rect = EditorGUILayout.GetControlRect();
            title = EditorGUI.BeginProperty(rect, title, property);
            EditorGUI.BeginChangeCheck();
            float newValue = EditorGUI.FloatField(rect, title, (float)property.doubleValue);
            if (EditorGUI.EndChangeCheck())
            {
                property.doubleValue = newValue;
            }
            EditorGUI.EndProperty();
        }

        private static bool PropertyFieldAsObject(SerializedProperty property, GUIContent title, Type objType)
        {
            bool allowSceneObjects = typeof(GameObject).IsAssignableFrom(objType) ||
                typeof(Component).IsAssignableFrom(objType);

            Rect rect = EditorGUILayout.GetControlRect();
            var label = EditorGUI.BeginProperty(rect, title, property);
            EditorGUI.BeginChangeCheck();

            int id = GUIUtility.GetControlID(Styles.ObjectFieldControlID, FocusType.Keyboard, rect);
            rect = EditorGUI.PrefixLabel(rect, id, label);
            var result = EditorGUI.DoObjectField(rect, rect, id, property.objectReferenceValue, objType, null, null, allowSceneObjects, EditorStyles.objectField);
            if (EditorGUI.EndChangeCheck())
            {
                property.objectReferenceValue = result;
                return true;
            }
            return false;
        }

        // Does not use Properties because time is not a serialized property
        private void CurrentTimeField()
        {
            if (targets.Length == 1)
            {
                var director = (PlayableDirector)target;
                EditorGUI.BeginChangeCheck();
                float t = EditorGUILayout.FloatField(Styles.TimeContent, (float)director.time);
                if (EditorGUI.EndChangeCheck())
                {
                    director.time = t;
                }
            }
            else
            {
                EditorGUILayout.TextField(Styles.TimeContent, EditorGUI.mixedValueContent.text);
            }
        }
    }
}
