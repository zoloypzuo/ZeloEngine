// Unity C# reference source
// Copyright (c) Unity Technologies. For terms of use, see
// https://unity3d.com/legal/licenses/Unity_Reference_Only_License

using System;
using UnityEngine;
using System.Collections.Generic;
using System.Linq;
using UnityEditor.IMGUI.Controls;
using UnityEditor.SceneManagement;
using Object = UnityEngine.Object;


namespace UnityEditor
{
    class PrefabOverridesTreeView : TreeView
    {
        PrefabOverrides m_AllModifications;
        bool m_Debug = false;
        string m_PrefabAssetPath { get; set; }
        GameObject m_PrefabInstanceRoot { get; set; }
        GameObject m_PrefabAssetRoot { get; set; }
        int m_LastShownPreviewWindowRowID = -1;

        enum ToggleValue { FALSE, TRUE, MIXED };
        enum ItemType { PREFAB_OBJECT, ADDED_OBJECT, REMOVED_OBJECT };

        class PrefabOverridesTreeViewItem : TreeViewItem
        {
            public PrefabOverridesTreeViewItem(int id, int depth, string displayName) : base(id, depth, displayName)
            {
            }

            public PrefabOverride singleModification;
            public Texture overlayIcon;

            public ToggleValue included { get; set; }
            public ItemType type
            {
                get { return m_Type; }
                set
                {
                    m_Type = value;

                    overlayIcon = null;
                    if (m_Type == ItemType.ADDED_OBJECT)
                        overlayIcon = EditorGUIUtility.IconContent("PrefabOverlayAdded Icon").image;
                    else if (m_Type == ItemType.REMOVED_OBJECT)
                        overlayIcon = EditorGUIUtility.IconContent("PrefabOverlayRemoved Icon").image;
                }
            }
            ItemType m_Type;

            public Object obj
            {
                get { return m_Obj; }
                set
                {
                    m_Obj = value;
                    icon = (m_Obj is GameObject) ? PrefabUtility.GetIconForGameObject((GameObject)m_Obj) : AssetPreview.GetMiniThumbnail(m_Obj);
                }
            }
            Object m_Obj;

            public string propertyPath { get; set; }
        }

        // Represents all possible modifications to a Prefab instance.
        class PrefabOverrides
        {
            List<ObjectOverride> m_ObjectOverrides = new List<ObjectOverride>();
            List<AddedComponent> m_AddedComponents = new List<AddedComponent>();
            List<RemovedComponent> m_RemovedComponents = new List<RemovedComponent>();
            List<AddedGameObject> m_AddedGameObjects = new List<AddedGameObject>();

            public List<ObjectOverride> objectOverrides { get { return m_ObjectOverrides; } set { m_ObjectOverrides = value; } }
            public List<AddedComponent> addedComponents { get { return m_AddedComponents; } set { m_AddedComponents = value; } }
            public List<RemovedComponent> removedComponents { get { return m_RemovedComponents; } set { m_RemovedComponents = value; } }
            public List<AddedGameObject> addedGameObjects { get { return m_AddedGameObjects; } set { m_AddedGameObjects = value; } }
        }

        static PrefabOverrides GetPrefabOverrides(GameObject prefabInstance, bool includeDefaultOverrides = false)
        {
            if (!PrefabUtility.IsPartOfNonAssetPrefabInstance(prefabInstance))
            {
                Debug.LogError("GeneratePrefabOverrides should only be called with GameObjects that are part of a prefab");
                return new PrefabOverrides();
            }

            var mods = new PrefabOverrides();
            mods.objectOverrides = PrefabOverridesUtility.GetObjectOverrides(prefabInstance, includeDefaultOverrides);
            mods.addedComponents = PrefabOverridesUtility.GetAddedComponents(prefabInstance);
            mods.removedComponents = PrefabOverridesUtility.GetRemovedComponents(prefabInstance);
            mods.addedGameObjects = PrefabOverridesUtility.GetAddedGameObjects(prefabInstance);
            return mods;
        }

        public bool hasModifications { get; set; }

        public PrefabOverridesTreeView(GameObject selectedGameObject, TreeViewState state) : base(state)
        {
            m_SelectedGameObject = selectedGameObject;
            rowHeight = 18f;
        }

        public void SetApplyTarget(GameObject prefabInstanceRoot, GameObject prefabAssetRoot, string prefabAssetPath)
        {
            m_PrefabInstanceRoot = prefabInstanceRoot;
            m_PrefabAssetRoot = prefabAssetRoot;
            m_PrefabAssetPath = prefabAssetPath;
            Reload();
            ExpandAll();
            EnableAllItems(true);
        }

        static string NicifyPropertyName(string propertyPath)
        {
            var result = ObjectNames.NicifyVariableName(propertyPath);
            result = result.Replace("Local ", "");
            return result;
        }

        static string GetModificationValueString(PropertyModification mod)
        {
            if (mod.objectReference != null)
                return mod.objectReference.name;
            return mod.value;
        }

        void BuildPrefabOverridesPerObject(GameObject prefabAssetRoot, out Dictionary<int, PrefabOverrides> instanceIDToPrefabOverridesMap)
        {
            instanceIDToPrefabOverridesMap = new Dictionary<int, PrefabOverrides>();

            foreach (var modifiedObject in m_AllModifications.objectOverrides)
            {
                int instanceID = 0;
                if (modifiedObject.instanceObject is GameObject)
                    instanceID = modifiedObject.instanceObject.GetInstanceID();
                else if (modifiedObject.instanceObject is Component)
                    instanceID = ((Component)modifiedObject.instanceObject).gameObject.GetInstanceID();

                if (instanceID != 0)
                {
                    PrefabOverrides modificationsForObject = GetPrefabOverridesForObject(instanceID, instanceIDToPrefabOverridesMap);
                    modificationsForObject.objectOverrides.Add(modifiedObject);
                }
            }

            foreach (var addedGameObject in m_AllModifications.addedGameObjects)
            {
                int instanceID = addedGameObject.instanceGameObject.GetInstanceID();
                PrefabOverrides modificationsForObject = GetPrefabOverridesForObject(instanceID, instanceIDToPrefabOverridesMap);
                modificationsForObject.addedGameObjects.Add(addedGameObject);
            }

            foreach (var addedComponent in m_AllModifications.addedComponents)
            {
                // This is possible if there's a component with a missing script.
                if (addedComponent.instanceComponent == null)
                    continue;
                int instanceID = addedComponent.instanceComponent.gameObject.GetInstanceID();
                PrefabOverrides modificationsForObject = GetPrefabOverridesForObject(instanceID, instanceIDToPrefabOverridesMap);
                modificationsForObject.addedComponents.Add(addedComponent);
            }

            foreach (var removedComponent in m_AllModifications.removedComponents)
            {
                // This is possible if there's a component with a missing script.
                if (removedComponent.assetComponent == null)
                    continue;
                int instanceID = removedComponent.containingInstanceGameObject.gameObject.GetInstanceID();
                PrefabOverrides modificationsForObject = GetPrefabOverridesForObject(instanceID, instanceIDToPrefabOverridesMap);
                modificationsForObject.removedComponents.Add(removedComponent);
            }
        }

        protected override TreeViewItem BuildRoot()
        {
            Debug.Assert(m_PrefabInstanceRoot != null, "We should always have a valid apply target");

            // Inner prefab asset root.
            m_AllModifications = GetPrefabOverrides(m_PrefabInstanceRoot, false);

            Dictionary<int, PrefabOverrides> instanceIDToPrefabOverridesMap;
            BuildPrefabOverridesPerObject(m_PrefabAssetRoot, out instanceIDToPrefabOverridesMap);

            var hiddenRoot = new TreeViewItem { id = 0, depth = -1, displayName = "Hidden Root" };
            var idSequence = new IdSequence();
            hasModifications = AddTreeViewItemRecursive(hiddenRoot, m_PrefabInstanceRoot, instanceIDToPrefabOverridesMap, idSequence);
            if (!hasModifications)
                hiddenRoot.AddChild(new TreeViewItem { id = 1, depth = 0, displayName = "No Overrides" });

            if (m_Debug)
                AddDebugItems(hiddenRoot, idSequence);

            return hiddenRoot;
        }

        void AddDebugItems(TreeViewItem hiddenRoot, IdSequence idSequence)
        {
            var debugItem = new TreeViewItem(idSequence.get(), 0, "<Debug raw list of modifications>");
            foreach (var mod in m_AllModifications.addedGameObjects)
                debugItem.AddChild(new TreeViewItem(idSequence.get(), debugItem.depth + 1, mod.instanceGameObject.name + " (Added GameObject)"));
            foreach (var mod in m_AllModifications.addedComponents)
                debugItem.AddChild(new TreeViewItem(idSequence.get(), debugItem.depth + 1, mod.instanceComponent.GetType() + " (Added Component)"));
            foreach (var mod in m_AllModifications.removedComponents)
                debugItem.AddChild(new TreeViewItem(idSequence.get(), debugItem.depth + 1, mod.assetComponent.GetType() + " (Removed Component)"));

            hiddenRoot.AddChild(new TreeViewItem()); // spacer
            hiddenRoot.AddChild(debugItem);
        }

        // Returns true if input gameobject or any of its descendants have modifications, otherwise returns false.
        bool AddTreeViewItemRecursive(TreeViewItem parentItem, GameObject gameObject, Dictionary<int, PrefabOverrides> prefabOverrideMap, IdSequence idSequence)
        {
            var gameObjectItem = new PrefabOverridesTreeViewItem
                (
                idSequence.get(),
                parentItem.depth + 1,
                gameObject.name
                );
            gameObjectItem.obj = gameObject;
            // We don't know yet if this item should be added to the parent.
            bool shouldAddGameObjectItemToParent = false;

            PrefabOverrides objectModifications;
            prefabOverrideMap.TryGetValue(gameObject.GetInstanceID(), out objectModifications);
            if (objectModifications != null)
            {
                // Added GameObject - note that this earlies out!
                AddedGameObject addedGameObjectData = objectModifications.addedGameObjects.Find(x => x.instanceGameObject == gameObject);
                if (addedGameObjectData != null)
                {
                    gameObjectItem.singleModification = addedGameObjectData;
                    gameObjectItem.type = ItemType.ADDED_OBJECT;

                    parentItem.AddChild(gameObjectItem);
                    return true;
                }
                else
                {
                    // Modified GameObject
                    ObjectOverride modifiedGameObjectData = objectModifications.objectOverrides.Find(x => x.instanceObject == gameObject);
                    if (modifiedGameObjectData != null)
                    {
                        gameObjectItem.singleModification = modifiedGameObjectData;
                        gameObjectItem.type = ItemType.PREFAB_OBJECT;
                        shouldAddGameObjectItemToParent = true;
                    }
                }

                // Added components and component modifications
                foreach (var component in gameObject.GetComponents(typeof(Component)))
                {
                    var componentItem = new PrefabOverridesTreeViewItem
                        (
                        idSequence.get(),
                        gameObjectItem.depth + 1,
                        ObjectNames.GetInspectorTitle(component)
                        );
                    componentItem.obj = component;

                    AddedComponent addedComponentData = objectModifications.addedComponents.Find(x => x.instanceComponent == component);
                    if (addedComponentData != null)
                    {
                        componentItem.singleModification = addedComponentData;
                        componentItem.type = ItemType.ADDED_OBJECT;
                        gameObjectItem.AddChild(componentItem);
                        shouldAddGameObjectItemToParent = true;
                    }
                    else
                    {
                        ObjectOverride modifiedObjectData = objectModifications.objectOverrides.Find(x => x.instanceObject == component);
                        if (modifiedObjectData != null)
                        {
                            componentItem.singleModification = modifiedObjectData;
                            componentItem.type = ItemType.PREFAB_OBJECT;
                            gameObjectItem.AddChild(componentItem);
                            shouldAddGameObjectItemToParent = true;
                        }
                    }
                }

                // Removed components
                foreach (var removedComponent in objectModifications.removedComponents)
                {
                    var removedComponentItem = new PrefabOverridesTreeViewItem
                        (
                        idSequence.get(),
                        gameObjectItem.depth + 1,
                        ObjectNames.GetInspectorTitle(removedComponent.assetComponent)
                        );
                    removedComponentItem.obj = removedComponent.assetComponent;
                    removedComponentItem.singleModification = removedComponent;
                    removedComponentItem.type = ItemType.REMOVED_OBJECT;
                    gameObjectItem.AddChild(removedComponentItem);
                    shouldAddGameObjectItemToParent = true;
                }
            }

            // Recurse into children
            foreach (Transform childTransform in gameObject.transform)
            {
                var childGameObject = childTransform.gameObject;
                shouldAddGameObjectItemToParent |= AddTreeViewItemRecursive(gameObjectItem, childGameObject, prefabOverrideMap, idSequence);
            }

            if (shouldAddGameObjectItemToParent)
            {
                parentItem.AddChild(gameObjectItem);
                return true;
            }

            return false;
        }

        static PrefabOverrides GetPrefabOverridesForObject(int instanceID, Dictionary<int, PrefabOverrides> map)
        {
            PrefabOverrides modificationsForObject;
            if (!map.TryGetValue(instanceID, out modificationsForObject))
            {
                modificationsForObject = new PrefabOverrides();
                map[instanceID] = modificationsForObject;
            }
            return modificationsForObject;
        }

        public void EnableAllItems(bool enable)
        {
            var topItem = rootItem.children[0] as PrefabOverridesTreeViewItem;
            if (topItem != null)
                UpdateChildrenIncludedState(topItem, enable);
        }

        static void UpdateChildrenIncludedState(PrefabOverridesTreeViewItem item, bool v)
        {
            item.included = v ? ToggleValue.TRUE : ToggleValue.FALSE;
            if (item.hasChildren)
            {
                foreach (var child in item.children)
                {
                    UpdateChildrenIncludedState(child as PrefabOverridesTreeViewItem, v);
                }
            }
        }

        static void UpdateParentsIncludedState(PrefabOverridesTreeViewItem item)
        {
            if (item.depth > 0)
            {
                var parent = item.parent as PrefabOverridesTreeViewItem;
                bool hasIncludedChildren = false;
                bool hasExcludedChildren = false;
                foreach (var child in parent.children)
                {
                    var included = (child as PrefabOverridesTreeViewItem).included;
                    hasIncludedChildren |= included != ToggleValue.FALSE;
                    hasExcludedChildren |= included != ToggleValue.TRUE;
                    if (hasIncludedChildren && hasExcludedChildren)
                    {
                        break;
                    }
                }
                if (hasIncludedChildren && hasExcludedChildren)
                {
                    parent.included = ToggleValue.MIXED;
                }
                else if (hasIncludedChildren)
                {
                    parent.included = ToggleValue.TRUE;
                }
                else
                {
                    parent.included = ToggleValue.FALSE;
                }
                UpdateParentsIncludedState(parent);
            }
        }

        protected override void RowGUI(RowGUIArgs args)
        {
            baseIndent = 4f;

            base.RowGUI(args);

            var item = args.item as PrefabOverridesTreeViewItem;

            // Draw overlay icon.
            if (item != null && Event.current.type == EventType.Repaint)
            {
                if (item.overlayIcon != null)
                {
                    Rect rect = GetRowRect(args.row);
                    rect.xMin += GetContentIndent(args.item);
                    rect.width = 16;
                    GUI.DrawTexture(rect, item.overlayIcon, ScaleMode.ScaleToFit);
                }
            }

            if (args.selected && state.selectedIDs.Count == 1 && item.id != m_LastShownPreviewWindowRowID)
            {
                DoPreviewPopup(item, args.rowRect);
            }
            // Ensure preview is shown when clicking on an already selected item (the preview might have been closed)
            if (Event.current.type == EventType.MouseDown && args.rowRect.Contains(Event.current.mousePosition))
            {
                DoPreviewPopup(item, args.rowRect);
            }
        }

        void DoPreviewPopup(PrefabOverridesTreeViewItem item, Rect rowRect)
        {
            if (item == null || item.obj == null)
                return;

            if (PopupWindowWithoutFocus.IsVisible())
            {
                if (item.id == m_LastShownPreviewWindowRowID)
                    return;
            }

            Rect buttonRect = rowRect;
            buttonRect.width = EditorGUIUtility.currentViewWidth;
            Object rowObject = item.obj;

            Object instance, source;
            if (item.type == ItemType.REMOVED_OBJECT)
            {
                instance = null;
                source = rowObject;
            }
            else if (item.type == ItemType.ADDED_OBJECT)
            {
                instance = rowObject;
                source = null;
            }
            else
            {
                instance = rowObject;
                source = PrefabUtility.GetCorrespondingObjectFromSource(rowObject);
            }

            m_LastShownPreviewWindowRowID = item.id;
            PopupWindowWithoutFocus.Show(
                buttonRect,
                new ComparisonViewPopup(source, instance, item.singleModification, this),
                new[] { PopupLocation.Right, PopupLocation.Left, PopupLocation.Below });
        }

        public GameObject selectedGameObject
        {
            get { return m_SelectedGameObject; }
        }

        GameObject m_SelectedGameObject;

        struct ChangedModification
        {
            public Object target { get; set; }
            public string propertyPath { get; set; }
        }

        enum Operation { APPLY, REVERT }

        static void GetSelectedModificationsRecursive(TreeViewItem treeViewItem, List<PrefabOverride> selectedModifications)
        {
            var objectItem = treeViewItem as PrefabOverridesTreeViewItem;
            if (objectItem == null)
                return;

            if (objectItem.included == ToggleValue.FALSE)
                return;

            if (objectItem.singleModification != null)
            {
                selectedModifications.Add(objectItem.singleModification);
            }

            if (objectItem.hasChildren)
            {
                foreach (var child in objectItem.children)
                    GetSelectedModificationsRecursive(child, selectedModifications);
            }
        }

        class IdSequence
        {
            public int get() { return m_NextId++; }
            int m_NextId = 1;
        }

        class ComparisonViewPopup : PopupWindowContent
        {
            readonly PrefabOverridesTreeView m_Owner;
            readonly PrefabOverride m_Modification;
            readonly Object m_Source;
            readonly Object m_Instance;
            readonly Editor m_SourceEditor;
            readonly Editor m_InstanceEditor;
            readonly bool m_Unappliable;

            const float k_HeaderHeight = 20f;
            const float k_ScrollbarWidth = 15;
            Vector2 m_PreviewSize = new Vector2(600f, 0);
            Vector2 m_Scroll;

            static class Styles
            {
                public static GUIStyle borderStyle = new GUIStyle("grey_border");
                public static GUIStyle centeredLabelStyle = new GUIStyle(EditorStyles.label);
                public static GUIStyle headerGroupStyle = new GUIStyle();
                public static GUIStyle headerStyle = new GUIStyle(EditorStyles.boldLabel);
                public static GUIContent sourceContent = EditorGUIUtility.TrTextContent("Prefab Source");
                public static GUIContent instanceContent = EditorGUIUtility.TrTextContent("Override");
                public static GUIContent removedContent = EditorGUIUtility.TrTextContent("Removed");
                public static GUIContent addedContent = EditorGUIUtility.TrTextContent("Added");
                public static GUIContent noModificationsContent = EditorGUIUtility.TrTextContent("No Overrides");
                public static GUIContent applyContent = EditorGUIUtility.TrTextContent("Apply");
                public static GUIContent revertContent = EditorGUIUtility.TrTextContent("Revert");

                static Styles()
                {
                    centeredLabelStyle.alignment = TextAnchor.UpperCenter;
                    centeredLabelStyle.padding = new RectOffset(3, 3, 3, 3);

                    headerGroupStyle.padding = new RectOffset(0, 0, 3, 3);

                    headerStyle.alignment = TextAnchor.MiddleLeft;
                    headerStyle.padding.left = 5;
                    headerStyle.padding.top = 1;
                }
            }

            public ComparisonViewPopup(Object source, Object instance, PrefabOverride modification, PrefabOverridesTreeView owner)
            {
                m_Owner = owner;
                m_Source = source;
                m_Instance = instance;
                m_Modification = modification;
                if (modification != null)
                {
                    m_Unappliable = !PrefabUtility.IsPartOfPrefabThatCanBeAppliedTo(modification.GetAssetObject());
                }
                else
                {
                    m_Unappliable = false;
                }

                if (m_Source != null)
                {
                    m_SourceEditor = Editor.CreateEditor(m_Source);
                }
                if (m_Instance != null)
                {
                    m_InstanceEditor = Editor.CreateEditor(m_Instance);
                }

                if (m_Source == null || m_Instance == null || m_Modification == null)
                    m_PreviewSize.x /= 2;
            }

            void UpdatePreviewHeight(float height)
            {
                if (height > 0)
                    m_PreviewSize.y = height;
            }

            public override void OnGUI(Rect rect)
            {
                bool scroll = (m_PreviewSize.y > rect.height - k_HeaderHeight);
                if (scroll)
                    rect.width -= k_ScrollbarWidth;
                else
                    // We overdraw border by one pixel to the right, so subtract here to account for that.
                    rect.width -= 1;

                EditorGUIUtility.comparisonViewMode = EditorGUIUtility.ComparisonViewMode.Original;
                EditorGUIUtility.wideMode = true;
                EditorGUIUtility.labelWidth = 100;
                int middleCol = Mathf.RoundToInt(rect.width * 0.5f);

                if (m_Modification == null)
                {
                    DrawHeader(
                        new Rect(rect.x, rect.y, rect.width, k_HeaderHeight + 1),
                        Styles.noModificationsContent);
                    m_PreviewSize.y = 0;
                    return;
                }

                Rect scrollRectPosition =
                    new Rect(
                        rect.x,
                        rect.y + k_HeaderHeight,
                        rect.width + (scroll ? k_ScrollbarWidth : 0),
                        rect.height - k_HeaderHeight);
                Rect viewPosition = new Rect(0, 0, rect.width, m_PreviewSize.y);

                if (m_Source != null && m_Instance != null)
                {
                    Rect sourceHeaderRect = new Rect(rect.x, rect.y, middleCol, k_HeaderHeight);
                    Rect instanceHeaderRect = new Rect(rect.x + middleCol, rect.y, rect.xMax - middleCol, k_HeaderHeight);
                    DrawHeader(sourceHeaderRect, Styles.sourceContent);
                    DrawHeader(instanceHeaderRect, Styles.instanceContent);

                    DrawRevertApplyButtons(instanceHeaderRect);

                    m_Scroll = GUI.BeginScrollView(scrollRectPosition, m_Scroll, viewPosition);
                    {
                        var leftColumnHeight = DrawEditor(new Rect(0, 0, middleCol, m_PreviewSize.y), m_SourceEditor, true);

                        EditorGUIUtility.comparisonViewMode = EditorGUIUtility.ComparisonViewMode.Modified;
                        var rightColumnHeight = DrawEditor(new Rect(middleCol, 0, rect.xMax - middleCol, m_PreviewSize.y), m_InstanceEditor, false);

                        UpdatePreviewHeight(Math.Max(leftColumnHeight, rightColumnHeight));
                    }
                    GUI.EndScrollView();
                }
                else
                {
                    GUIContent headerContent;
                    Editor editor;
                    bool disable;
                    if (m_Source != null)
                    {
                        headerContent = Styles.removedContent;
                        editor = m_SourceEditor;
                        disable = true;
                    }
                    else
                    {
                        headerContent = Styles.addedContent;
                        editor = m_InstanceEditor;
                        disable = false;
                    }

                    Rect headerRect = new Rect(rect.x, rect.y, rect.width, k_HeaderHeight);
                    DrawHeader(headerRect, headerContent);

                    DrawRevertApplyButtons(headerRect);

                    m_Scroll = GUI.BeginScrollView(scrollRectPosition, m_Scroll, viewPosition);

                    EditorGUIUtility.comparisonViewMode = EditorGUIUtility.ComparisonViewMode.Modified;
                    float columnHeight = DrawEditor(new Rect(0, 0, rect.width, m_PreviewSize.y), editor, disable);
                    UpdatePreviewHeight(columnHeight);

                    GUI.EndScrollView();
                }
            }

            void DrawHeader(Rect rect, GUIContent label)
            {
                EditorGUI.LabelField(rect, label, Styles.headerStyle);
                // Overdraw border by one pixel to the right and down, so adjacent borders overlap.
                GUI.Label(new Rect(rect.x, rect.y, rect.width + 1, rect.height + 1), GUIContent.none, Styles.borderStyle);
            }

            void DrawRevertApplyButtons(Rect rect)
            {
                GUILayout.BeginArea(rect);
                GUILayout.BeginHorizontal(Styles.headerGroupStyle);
                GUILayout.FlexibleSpace();

                if (GUILayout.Button(Styles.revertContent, EditorStyles.miniButton, GUILayout.Width(50)))
                {
                    m_Modification.Revert();
                    UpdateAndClose();
                    GUIUtility.ExitGUI();
                }

                using (new EditorGUI.DisabledScope(m_Unappliable))
                {
                    Rect applyRect = GUILayoutUtility.GetRect(GUIContent.none, "MiniPulldown", GUILayout.Width(50));
                    if (EditorGUI.DropdownButton(applyRect, Styles.applyContent, FocusType.Passive))
                    {
                        GenericMenu menu = new GenericMenu();
                        m_Modification.HandleApplyMenuItems(menu, Apply);
                        menu.DropDown(applyRect);
                    }
                }

                GUILayout.EndHorizontal();
                GUILayout.EndArea();
            }

            void Apply(object prefabAssetPathObject)
            {
                string prefabAssetPath = (string)prefabAssetPathObject;
                if (!PrefabUtility.PromptAndCheckoutPrefabIfNeeded(prefabAssetPath, PrefabUtility.SaveVerb.Apply))
                    return;
                m_Modification.Apply(prefabAssetPath);
                UpdateAndClose();
            }

            void UpdateAndClose()
            {
                if (editorWindow != null)
                {
                    editorWindow.Close();
                    m_Owner.Reload();
                }
            }

            float DrawEditor(Rect rect, Editor editor, bool disabled)
            {
                GUILayout.BeginArea(rect);
                Rect editorRect = EditorGUILayout.BeginVertical();
                {
                    using (new EditorGUI.DisabledScope(disabled))
                    {
                        if (editor == null)
                        {
                            GUI.enabled = true;
                            GUILayout.Label("None - this should not happen.", Styles.centeredLabelStyle);
                        }
                        else
                        {
                            if (editor.target is GameObject)
                            {
                                editor.DrawHeader();
                            }
                            else
                            {
                                EditorGUIUtility.hierarchyMode = true;
                                EditorGUILayout.InspectorTitlebar(true, editor.target);
                                EditorGUILayout.BeginVertical(EditorStyles.inspectorDefaultMargins);
                                editor.OnInspectorGUI();
                                EditorGUILayout.Space();
                                EditorGUILayout.EndVertical();
                            }
                        }
                    }
                }

                EditorGUILayout.EndVertical();
                GUILayout.EndArea();

                // Overdraw border by one pixel to the right and down, so adjacent borders overlap.
                GUI.Label(new Rect(rect.x, 0, rect.width + 1, m_PreviewSize.y + 1), GUIContent.none, Styles.borderStyle);

                return editorRect.height;
            }

            public override Vector2 GetWindowSize()
            {
                return new Vector2(m_PreviewSize.x, m_PreviewSize.y + k_HeaderHeight);
            }

            public override void OnClose()
            {
                base.OnClose();
                if (m_SourceEditor != null)
                    Object.DestroyImmediate(m_SourceEditor);
                if (m_InstanceEditor != null)
                    Object.DestroyImmediate(m_InstanceEditor);
            }
        }
    }
}
