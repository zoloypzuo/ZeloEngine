// Unity C# reference source
// Copyright (c) Unity Technologies. For terms of use, see
// https://unity3d.com/legal/licenses/Unity_Reference_Only_License

using UnityEngine;

namespace UnityEditor.Experimental.AssetImporters
{
    public abstract class AssetImporterEditor : Editor
    {
        ulong m_AssetTimeStamp = 0;
        bool m_MightHaveModified = false;

        private Editor m_AssetEditor;
        // Called from ActiveEditorTracker.cpp to setup the target editor once created before Awake and OnEnable of the Editor.
        internal void InternalSetAssetImporterTargetEditor(Object editor)
        {
            m_AssetEditor = editor as Editor;
        }

        protected internal Object[] assetTargets { get { return m_AssetEditor != null ? m_AssetEditor.targets : null; } }
        protected internal Object assetTarget { get { return m_AssetEditor != null ? m_AssetEditor.target : null; } }
        protected internal SerializedObject assetSerializedObject { get { return m_AssetEditor != null ? m_AssetEditor.serializedObject : null; } }

        static string s_LocalizedTitleString = L10n.Tr("{0} Import Settings");

        internal override string targetTitle
        {
            get
            {
                return string.Format(s_LocalizedTitleString, m_AssetEditor == null ? string.Empty : m_AssetEditor.targetTitle);
            }
        }

        internal override int referenceTargetIndex
        {
            get { return base.referenceTargetIndex; }
            set
            {
                base.referenceTargetIndex = value;
                if (m_AssetEditor != null)
                    m_AssetEditor.referenceTargetIndex = value;
            }
        }

        internal override IPreviewable preview
        {
            get
            {
                if (useAssetDrawPreview && m_AssetEditor != null)
                    return m_AssetEditor;
                // Sometimes assetEditor has gone away because of "magical" workarounds and we need to fall back to base.Preview.
                // See cases 597496 and 601174 for context.
                return base.preview;
            }
        }

        //We usually want to redirect the DrawPreview to the assetEditor, but there are few cases we don't want that.
        //If you want to use the Importer DrawPreview, then override useAssetDrawPreview to false.
        protected virtual bool useAssetDrawPreview { get { return true; } }

        // Make the Importer use the icon of the asset
        internal override void OnHeaderIconGUI(Rect iconRect)
        {
            if (m_AssetEditor != null)
                m_AssetEditor.OnHeaderIconGUI(iconRect);
        }

        // Let asset importers decide if the imported object should be shown as a separate editor or not
        public virtual bool showImportedObject { get { return true; } }

        internal override SerializedObject GetSerializedObjectInternal()
        {
            if (m_SerializedObject == null)
                m_SerializedObject = SerializedObject.LoadFromCache(GetInstanceID());
            if (m_SerializedObject == null)
                m_SerializedObject = new SerializedObject(targets);
            return m_SerializedObject;
        }

        public virtual void OnEnable()
        {
            // warning: if you add anything here make sure every descent of this class calls this properly...
        }

        public virtual void OnDisable()
        {
            ////FIXME: The code below wreaks havoc with tabbed editors.  Triggering a re-import will
            ////    cause all active editors to be destroyed which, if we're part of a tabbed editor,
            ////    will take down our parent while it is trying to switch editors.  Also, we'll be
            ////    doing all this while InspectorWindow.OnGUI() is still going through the active
            ////    editors to draw them so we're killing them right under its nose.

            // When destroying the inspector check if we have any unapplied modifications
            // and apply them.
            AssetImporter importer = target as AssetImporter;
            if (Unsupported.IsDestroyScriptableObject(this) && m_MightHaveModified && importer != null && HasModified() && !AssetWasUpdated())
            {
                string dialogText = string.Format(L10n.Tr("Unapplied import settings for \'{0}\'"), importer.assetPath);

                if (targets.Length > 1)
                    dialogText = string.Format(L10n.Tr("Unapplied import settings for \'{0}\' files"), targets.Length);

                if (EditorUtility.DisplayDialog(L10n.Tr("Unapplied import settings"), dialogText, L10n.Tr("Apply"), L10n.Tr("Revert")))
                {
                    Apply();
                    m_MightHaveModified = false;
                    ImportAssets(GetAssetPaths());
                }
            }

            // Only cache SerializedObject if it has modified properties.
            // If we have multiple editors (e.g. a tabbed editor and its editor for the active tab) we don't
            // want the one that doesn't do anything with the SerializedObject to overwrite the cache.
            if (m_SerializedObject != null && m_SerializedObject.hasModifiedProperties)
            {
                m_SerializedObject.Cache(GetInstanceID());
                m_SerializedObject = null;
            }
        }

        protected virtual void Awake()
        {
            ResetTimeStamp();
            ResetValues();
        }

        private string[] GetAssetPaths()
        {
            Object[] allTargets = targets;
            string[] paths = new string[allTargets.Length];
            for (int i = 0; i < allTargets.Length; i++)
            {
                AssetImporter importer = allTargets[i] as AssetImporter;
                paths[i] = importer.assetPath;
            }
            return paths;
        }

        protected virtual void ResetValues()
        {
            serializedObject.SetIsDifferentCacheDirty();
            serializedObject.Update();
        }

        public virtual bool HasModified()
        {
            return serializedObject.hasModifiedProperties;
        }

        protected virtual void Apply()
        {
            serializedObject.ApplyModifiedPropertiesWithoutUndo();
        }

        internal bool AssetWasUpdated()
        {
            AssetImporter importer = target as AssetImporter;
            if (m_AssetTimeStamp == 0)
                ResetTimeStamp();
            return importer != null && m_AssetTimeStamp != importer.assetTimeStamp;
        }

        internal void ResetTimeStamp()
        {
            AssetImporter importer = target as AssetImporter;
            if (importer != null)
                m_AssetTimeStamp = importer.assetTimeStamp;
        }

        protected internal void ApplyAndImport()
        {
            Apply();
            m_MightHaveModified = false;
            ImportAssets(GetAssetPaths());
            ResetValues();
        }

        private void ImportAssets(string[] paths)
        {
            // When using the cache server we have to write all import settings to disk first.
            // Then perform the import (Otherwise the cache server will not be used for the import)
            foreach (string path in paths)
                AssetDatabase.WriteImportSettingsIfDirty(path);

            try
            {
                AssetDatabase.StartAssetEditing();
                foreach (string path in paths)
                    AssetDatabase.ImportAsset(path);
            }
            finally
            {
                AssetDatabase.StopAssetEditing();
            }

            OnAssetImportDone();
        }

        internal virtual void OnAssetImportDone()
        {
            // Default, do nothing.
        }

        protected void RevertButton()
        {
            RevertButton(L10n.Tr("Revert"));
        }

        protected void RevertButton(string buttonText)
        {
            if (GUILayout.Button(buttonText))
            {
                m_MightHaveModified = false;
                ResetTimeStamp();
                ResetValues();
                if (HasModified())
                    Debug.LogError("Importer reports modified values after reset.");
            }
        }

        protected bool ApplyButton()
        {
            return ApplyButton(L10n.Tr("Apply"));
        }

        protected bool ApplyButton(string buttonText)
        {
            if (GUILayout.Button(buttonText))
            {
                ApplyAndImport();
                return true;
            }
            return false;
        }

        protected virtual bool OnApplyRevertGUI()
        {
            using (new EditorGUI.DisabledScope(!HasModified()))
            {
                RevertButton();
                return ApplyButton();
            }
        }

        protected void ApplyRevertGUI()
        {
            if (m_AssetEditor == null || m_AssetEditor.target == null)
            {
                // always apply changes when buttons are hidden
                Apply();
                return;
            }

            m_MightHaveModified = true;
            EditorGUILayout.Space();

            GUILayout.BeginHorizontal();
            GUILayout.FlexibleSpace();

            var applied = false;
            applied = OnApplyRevertGUI();

            // If the .meta file was modified on disk, reload UI
            if (AssetWasUpdated() && Event.current.type != EventType.Layout)
            {
                IPreviewable previewable = preview;
                if (previewable != null)
                    previewable.ReloadPreviewInstances();

                ResetTimeStamp();
                ResetValues();
                Repaint();
            }

            GUILayout.EndHorizontal();

            // asset has changed...
            // need to start rendering again.
            if (applied)
                GUIUtility.ExitGUI();
        }
    }
}
