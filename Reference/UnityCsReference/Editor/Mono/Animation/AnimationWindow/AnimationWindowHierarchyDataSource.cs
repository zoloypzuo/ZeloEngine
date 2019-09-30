// Unity C# reference source
// Copyright (c) Unity Technologies. For terms of use, see
// https://unity3d.com/legal/licenses/Unity_Reference_Only_License

using UnityEditor;
using System.Collections.Generic;
using UnityEditor.IMGUI.Controls;
using UnityEngine;
using Object = UnityEngine.Object;

namespace UnityEditorInternal
{
    internal class AnimationWindowHierarchyDataSource : TreeViewDataSource
    {
        // Animation window shared state
        private AnimationWindowState state { get; set; }
        public bool showAll { get; set; }

        public AnimationWindowHierarchyDataSource(TreeViewController treeView, AnimationWindowState animationWindowState)
            : base(treeView)
        {
            state = animationWindowState;
        }

        private void SetupRootNodeSettings()
        {
            showRootItem = false;
            rootIsCollapsable = false;
            SetExpanded(m_RootItem, true);
        }

        private AnimationWindowHierarchyNode GetEmptyRootNode()
        {
            return new AnimationWindowHierarchyNode(0, -1, null, null, "", "", "root");
        }

        public override void FetchData()
        {
            m_RootItem = GetEmptyRootNode();
            SetupRootNodeSettings();
            m_NeedRefreshRows = true;

            if (state.selection.disabled)
            {
                root.children = null;
                return;
            }

            List<AnimationWindowHierarchyNode> childNodes = new List<AnimationWindowHierarchyNode>();

            if (state.allCurves.Count > 0)
            {
                AnimationWindowHierarchyMasterNode masterNode = new AnimationWindowHierarchyMasterNode();
                masterNode.curves = state.allCurves.ToArray();

                childNodes.Add(masterNode);
            }

            childNodes.AddRange(CreateTreeFromCurves());
            childNodes.Add(new AnimationWindowHierarchyAddButtonNode());

            TreeViewUtility.SetChildParentReferences(new List<TreeViewItem>(childNodes.ToArray()), root);
        }

        public override bool IsRenamingItemAllowed(TreeViewItem item)
        {
            if (item is AnimationWindowHierarchyAddButtonNode || item is AnimationWindowHierarchyMasterNode || item is AnimationWindowHierarchyClipNode)
                return false;

            if ((item as AnimationWindowHierarchyNode).path.Length == 0)
                return false;

            return true;
        }

        public List<AnimationWindowHierarchyNode> CreateTreeFromCurves()
        {
            List<AnimationWindowHierarchyNode> nodes = new List<AnimationWindowHierarchyNode>();
            List<AnimationWindowCurve> singlePropertyCurves = new List<AnimationWindowCurve>();

            AnimationWindowCurve[] curves = state.allCurves.ToArray();
            AnimationWindowHierarchyNode parentNode = (AnimationWindowHierarchyNode)m_RootItem;

            for (int i = 0; i < curves.Length; i++)
            {
                AnimationWindowCurve curve = curves[i];
                AnimationWindowCurve nextCurve = i < curves.Length - 1 ? curves[i + 1] : null;

                singlePropertyCurves.Add(curve);

                bool areSameGroup = nextCurve != null && AnimationWindowUtility.GetPropertyGroupName(nextCurve.propertyName) == AnimationWindowUtility.GetPropertyGroupName(curve.propertyName);
                bool areSamePathAndType = nextCurve != null && curve.path.Equals(nextCurve.path) && curve.type == nextCurve.type;

                // We expect curveBindings to come sorted by propertyname
                // So we compare curve vs nextCurve. If its different path or different group (think "scale.xyz" as group), then we know this is the last element of such group.
                if (i == curves.Length - 1 || !areSameGroup || !areSamePathAndType)
                {
                    if (singlePropertyCurves.Count > 1)
                        nodes.Add(AddPropertyGroupToHierarchy(singlePropertyCurves.ToArray(), parentNode));
                    else
                        nodes.Add(AddPropertyToHierarchy(singlePropertyCurves[0], parentNode));
                    singlePropertyCurves.Clear();
                }
            }

            return nodes;
        }

        private AnimationWindowHierarchyPropertyGroupNode AddPropertyGroupToHierarchy(AnimationWindowCurve[] curves, AnimationWindowHierarchyNode parentNode)
        {
            List<AnimationWindowHierarchyNode> childNodes = new List<AnimationWindowHierarchyNode>();

            System.Type animatableObjectType = curves[0].type;
            AnimationWindowHierarchyPropertyGroupNode node = new AnimationWindowHierarchyPropertyGroupNode(animatableObjectType, 0, AnimationWindowUtility.GetPropertyGroupName(curves[0].propertyName), curves[0].path, parentNode);

            node.icon = GetIcon(curves[0].binding);

            node.indent = curves[0].depth;
            node.curves = curves;

            foreach (AnimationWindowCurve curve in curves)
            {
                AnimationWindowHierarchyPropertyNode childNode = AddPropertyToHierarchy(curve, node);
                // For child nodes we do not want to display the type in front (It is already shown by the group node)
                childNode.displayName = AnimationWindowUtility.GetPropertyDisplayName(childNode.propertyName);
                childNodes.Add(childNode);
            }

            TreeViewUtility.SetChildParentReferences(new List<TreeViewItem>(childNodes.ToArray()), node);
            return node;
        }

        private AnimationWindowHierarchyPropertyNode AddPropertyToHierarchy(AnimationWindowCurve curve, AnimationWindowHierarchyNode parentNode)
        {
            AnimationWindowHierarchyPropertyNode node = new AnimationWindowHierarchyPropertyNode(curve.type, 0, curve.propertyName, curve.path, parentNode, curve.binding, curve.isPPtrCurve);

            if (parentNode.icon != null)
                node.icon = parentNode.icon;
            else
                node.icon = GetIcon(curve.binding);

            node.indent = curve.depth;
            node.curves = new[] { curve };
            return node;
        }

        public Texture2D GetIcon(EditorCurveBinding curveBinding)
        {
            if (state.activeRootGameObject != null)
            {
                Object animatedObject = AnimationUtility.GetAnimatedObject(state.activeRootGameObject, curveBinding);
                if (animatedObject != null)
                    return AssetPreview.GetMiniThumbnail(animatedObject);
            }
            return AssetPreview.GetMiniTypeThumbnail(curveBinding.type);
        }

        public void UpdateData()
        {
            m_TreeView.ReloadData();
        }
    }
}
