// Unity C# reference source
// Copyright (c) Unity Technologies. For terms of use, see
// https://unity3d.com/legal/licenses/Unity_Reference_Only_License

using System;
using System.Collections.Generic;
using System.Linq;
using UnityEditor.IMGUI.Controls;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEditor.SceneManagement;
using UnityEditorInternal;
using UnityEngine.Assertions;
using Object = UnityEngine.Object;

namespace UnityEditor
{
    // Implements dragging behavior for HierarchyProperty based data: Assets or GameObjects

    internal class AssetsTreeViewDragging : TreeViewDragging
    {
        public AssetsTreeViewDragging(TreeViewController treeView)
            : base(treeView)
        {
        }

        public override bool CanStartDrag(TreeViewItem targetItem, List<int> draggedItemIDs, Vector2 mouseDownPosition)
        {
            // Prevent dragging of immutable root folder
            foreach (var draggedItemID in draggedItemIDs)
            {
                var path = AssetDatabase.GetAssetPath(draggedItemID);
                bool rootFolder, readOnly;
                bool validPath = AssetDatabase.GetAssetFolderInfo(path, out rootFolder, out readOnly);
                if (validPath && rootFolder && readOnly)
                    return false;
            }
            return true;
        }

        public override void StartDrag(TreeViewItem draggedItem, List<int> draggedItemIDs)
        {
            DragAndDrop.PrepareStartDrag();

            DragAndDrop.objectReferences = ProjectWindowUtil.GetDragAndDropObjects(draggedItem.id, draggedItemIDs);

            DragAndDrop.paths = ProjectWindowUtil.GetDragAndDropPaths(draggedItem.id, draggedItemIDs);
            if (DragAndDrop.objectReferences.Length > 1)
                DragAndDrop.StartDrag("<Multiple>");
            else
            {
                string title = ObjectNames.GetDragAndDropTitle(InternalEditorUtility.GetObjectFromInstanceID(draggedItem.id));
                DragAndDrop.StartDrag(title);
            }
        }

        public override DragAndDropVisualMode DoDrag(TreeViewItem parentItem, TreeViewItem targetItem, bool perform, DropPosition dropPos)
        {
            if (parentItem != null)
            {
                var hierarchyProperty = new HierarchyProperty(HierarchyType.Assets);
                if (hierarchyProperty.Find(parentItem.id, null))
                    return InternalEditorUtility.ProjectWindowDrag(hierarchyProperty, perform);

                var path = AssetDatabase.GetAssetPath(parentItem.id);
                if (string.IsNullOrEmpty(path))
                    return DragAndDropVisualMode.Rejected;

                var packageInfo = PackageManager.Packages.GetForAssetPath(path);
                if (packageInfo != null)
                {
                    hierarchyProperty = new HierarchyProperty(packageInfo.assetPath);
                    if (hierarchyProperty.Find(parentItem.id, null))
                        return InternalEditorUtility.ProjectWindowDrag(hierarchyProperty, perform);
                }

                return DragAndDropVisualMode.Rejected;
            }

            // Perform drag as on the Assets folder
            return InternalEditorUtility.ProjectWindowDrag(null, perform);
        }
    }


    internal class GameObjectsTreeViewDragging : TreeViewDragging
    {
        public delegate DragAndDropVisualMode CustomDraggingDelegate(GameObjectTreeViewItem parentItem, GameObjectTreeViewItem targetItem, DropPosition dropPos, bool perform);
        CustomDraggingDelegate m_CustomDragHandling;

        const string kSceneHeaderDragString = "SceneHeaderList";

        public Transform parentForDraggedObjectsOutsideItems { get; set; }

        public GameObjectsTreeViewDragging(TreeViewController treeView) : base(treeView) {}

        public void SetCustomDragHandler(CustomDraggingDelegate handler)
        {
            m_CustomDragHandling = handler;
        }

        public override void StartDrag(TreeViewItem draggedItem, List<int> draggedItemIDs)
        {
            DragAndDrop.PrepareStartDrag();

            if (Event.current.control || Event.current.command)
            {
                draggedItemIDs.Add(draggedItem.id);
            }

            // Ensure correct order for hierarchy items (to preserve visible order when dropping at new location)
            draggedItemIDs = m_TreeView.SortIDsInVisiblityOrder(draggedItemIDs);

            if (!draggedItemIDs.Contains(draggedItem.id))
                draggedItemIDs = new List<int> {draggedItem.id};

            Object[] draggedObjReferences = ProjectWindowUtil.GetDragAndDropObjects(draggedItem.id, draggedItemIDs);
            DragAndDrop.objectReferences = draggedObjReferences;

            // After introducing multi-scene, UnityEngine.Scene can be selected in HierarchyWindow.
            // UnityEngine.Scene is not a UnityEngine.Object.
            // So DragAndDrop.objectReferences can't cover this case.
            List<Scene> draggedScenes = GetDraggedScenes(draggedItemIDs);
            if (draggedScenes != null)
            {
                DragAndDrop.SetGenericData(kSceneHeaderDragString, draggedScenes);

                List<string> paths = new List<string>();
                foreach (Scene scene in draggedScenes)
                {
                    if (scene.path.Length > 0)
                        paths.Add(scene.path);
                }
                DragAndDrop.paths = paths.ToArray();
            }
            else
                DragAndDrop.paths = new string[0];

            string title;
            if (draggedItemIDs.Count > 1)
                title = "<Multiple>";
            else
            {
                if (draggedObjReferences.Length == 1)
                    title = ObjectNames.GetDragAndDropTitle(draggedObjReferences[0]);
                else if (draggedScenes != null && draggedScenes.Count == 1)
                    title = draggedScenes[0].path;
                else
                {
                    title = "Unhandled dragged item";
                    Debug.LogError("Unhandled dragged item");
                }
            }
            DragAndDrop.StartDrag(title);

            dataSource.SetupChildParentReferencesIfNeeded();
        }

        GameObjectTreeViewDataSource dataSource { get { return (GameObjectTreeViewDataSource)m_TreeView.data; } }

        public override DragAndDropVisualMode DoDrag(TreeViewItem parentItem, TreeViewItem targetItem, bool perform, DropPosition dropPos)
        {
            // Allow client to handle drag
            if (m_CustomDragHandling != null)
            {
                DragAndDropVisualMode dragResult = m_CustomDragHandling(parentItem as GameObjectTreeViewItem, targetItem as GameObjectTreeViewItem, dropPos, perform);
                if (dragResult != DragAndDropVisualMode.None)
                    return dragResult;
            }

            // Scene dragging logic
            DragAndDropVisualMode dragSceneResult = DoDragScenes(parentItem as GameObjectTreeViewItem, targetItem as GameObjectTreeViewItem, perform, dropPos);
            if (dragSceneResult != DragAndDropVisualMode.None)
                return dragSceneResult;

            if (targetItem != null && !IsDropTargetUserModifiable(targetItem as GameObjectTreeViewItem, dropPos))
                return DragAndDropVisualMode.Rejected;

            var option = InternalEditorUtility.HierarchyDropMode.kHierarchyDragNormal;
            var searchActive = !string.IsNullOrEmpty(dataSource.searchString);
            if (searchActive)
                option |= InternalEditorUtility.HierarchyDropMode.kHierarchySearchActive;
            if (parentItem == null || targetItem == null)
            {
                // Here we are dragging outside any treeview items:

                if (parentForDraggedObjectsOutsideItems != null)
                {
                    // Use specific parent for DragAndDropForwarding
                    return InternalEditorUtility.HierarchyWindowDrag(null, option, parentForDraggedObjectsOutsideItems, perform);
                }
                else
                {
                    // Simulate drag upon the last loaded scene in the hierarchy (adds as last root sibling of the last scene)
                    Scene lastScene = dataSource.GetLastScene();
                    option |= InternalEditorUtility.HierarchyDropMode.kHierarchyDropUpon;

                    var prop = dataSource.CreateHierarchyProperty();
                    if (prop.Find(lastScene.handle, null))
                    {
                        return InternalEditorUtility.HierarchyWindowDrag(prop, option, null, perform);
                    }

                    Assert.IsFalse(true, "Could not find scene with handle: " + lastScene.handle);
                }
            }

            // Here we are hovering over items
            var hierarchyProperty = dataSource.CreateHierarchyProperty();
            if (!hierarchyProperty.Find(targetItem.id, null))
            {
                hierarchyProperty = null;
            }

            var draggingUpon = dropPos == TreeViewDragging.DropPosition.Upon;

            if (searchActive && !draggingUpon)
            {
                return DragAndDropVisualMode.None;
            }

            option |= (draggingUpon ? InternalEditorUtility.HierarchyDropMode.kHierarchyDropUpon : InternalEditorUtility.HierarchyDropMode.kHierarchyDropBetween);

            bool isDroppingBetweenParentAndFirstChild = parentItem != null && targetItem != parentItem && dropPos == DropPosition.Above && parentItem.children[0] == targetItem;
            if (isDroppingBetweenParentAndFirstChild)
            {
                option |= InternalEditorUtility.HierarchyDropMode.kHierarchyDropAfterParent;
            }

            return InternalEditorUtility.HierarchyWindowDrag(hierarchyProperty, option, null, perform);
        }

        static bool IsDropTargetUserModifiable(GameObjectTreeViewItem targetItem, DropPosition dropPos)
        {
            switch (dropPos)
            {
                case DropPosition.Upon:
                    if (targetItem.objectPPTR != null)
                        return IsUserModifiable(targetItem.objectPPTR);
                    break;
                case DropPosition.Below:
                case DropPosition.Above:
                    var targetParent = targetItem.parent as GameObjectTreeViewItem;
                    if (targetParent != null && targetParent.objectPPTR != null)
                        return IsUserModifiable(targetParent.objectPPTR);
                    break;
                default:
                    throw new ArgumentOutOfRangeException(nameof(dropPos), dropPos, null);
            }

            return true;
        }

        static bool IsUserModifiable(Object obj)
        {
            return (obj.hideFlags & HideFlags.NotEditable) == 0;
        }

        public override void DragCleanup(bool revertExpanded)
        {
            DragAndDrop.SetGenericData(kSceneHeaderDragString, null);

            base.DragCleanup(revertExpanded);
        }

        private List<Scene> GetDraggedScenes(List<int> draggedItemIDs)
        {
            List<Scene> scenes = new List<Scene>();
            foreach (int id in draggedItemIDs)
            {
                Scene scene = EditorSceneManager.GetSceneByHandle(id);
                if (!SceneHierarchy.IsSceneHeaderInHierarchyWindow(scene))
                    return null;
                scenes.Add(scene);
            }

            return scenes;
        }

        private DragAndDropVisualMode DoDragScenes(GameObjectTreeViewItem parentItem, GameObjectTreeViewItem targetItem, bool perform, DropPosition dropPos)
        {
            // We allow dragging SceneAssets on any game object in the Hierarchy to make it easy to drag in a Scene from
            // the project browser. If dragging on a game object (not a sceneheader) we place the dropped scene
            // below the game object's scene

            // Case: 1
            List<Scene> scenes = DragAndDrop.GetGenericData(kSceneHeaderDragString) as List<Scene>;
            bool reorderExistingScenes = (scenes != null);

            // Case: 2
            bool insertNewScenes = false;
            if (!reorderExistingScenes && DragAndDrop.objectReferences.Length > 0)
            {
                int sceneAssetCount = 0;
                foreach (var dragged in DragAndDrop.objectReferences)
                {
                    if (dragged is SceneAsset)
                        sceneAssetCount++;
                }
                insertNewScenes = (sceneAssetCount == DragAndDrop.objectReferences.Length);
            }

            // Early out if not case 1 or 2
            if (!reorderExistingScenes && !insertNewScenes)
                return DragAndDropVisualMode.None;

            if (perform)
            {
                List<Scene> scenesToBeMoved = null;
                if (insertNewScenes)
                {
                    List<Scene> insertedScenes = new List<Scene>();
                    foreach (var sceneAsset in DragAndDrop.objectReferences)
                    {
                        string scenePath = AssetDatabase.GetAssetPath(sceneAsset);
                        Scene scene = SceneManager.GetSceneByPath(scenePath);
                        if (SceneHierarchy.IsSceneHeaderInHierarchyWindow(scene))
                            m_TreeView.Frame(scene.handle, true, true);
                        else
                        {
                            bool unloaded = Event.current.alt;
                            if (unloaded)
                                scene = EditorSceneManager.OpenScene(scenePath, OpenSceneMode.AdditiveWithoutLoading);
                            else
                                scene = EditorSceneManager.OpenScene(scenePath, OpenSceneMode.Additive);

                            if (SceneHierarchy.IsSceneHeaderInHierarchyWindow(scene))
                                insertedScenes.Add(scene);
                        }
                    }
                    if (targetItem != null)
                        scenesToBeMoved = insertedScenes;

                    // Select added scenes and frame last scene
                    if (insertedScenes.Count > 0)
                    {
                        Selection.instanceIDs = insertedScenes.Select(x => x.handle).ToArray();
                        m_TreeView.Frame(insertedScenes.Last().handle, true, false);
                    }
                }
                else // reorderExistingScenes
                    scenesToBeMoved = scenes;

                if (scenesToBeMoved != null)
                {
                    if (targetItem != null)
                    {
                        Scene dstScene = targetItem.scene;
                        if (SceneHierarchy.IsSceneHeaderInHierarchyWindow(dstScene))
                        {
                            if (!targetItem.isSceneHeader || dropPos == DropPosition.Upon)
                                dropPos = DropPosition.Below;

                            if (dropPos == DropPosition.Above)
                            {
                                for (int i = 0; i < scenesToBeMoved.Count; i++)
                                    EditorSceneManager.MoveSceneBefore(scenesToBeMoved[i], dstScene);
                            }
                            else if (dropPos == DropPosition.Below)
                            {
                                for (int i = scenesToBeMoved.Count - 1; i >= 0; i--)
                                    EditorSceneManager.MoveSceneAfter(scenesToBeMoved[i], dstScene);
                            }
                        }
                    }
                    else
                    {
                        Scene dstScene = SceneManager.GetSceneAt(SceneManager.sceneCount - 1);
                        for (int i = scenesToBeMoved.Count - 1; i >= 0; i--)
                            EditorSceneManager.MoveSceneAfter(scenesToBeMoved[i], dstScene);
                    }
                }
            }

            return DragAndDropVisualMode.Move;
        }
    }
} // namespace UnityEditor
