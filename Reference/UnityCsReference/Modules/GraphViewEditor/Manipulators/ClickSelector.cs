// Unity C# reference source
// Copyright (c) Unity Technologies. For terms of use, see
// https://unity3d.com/legal/licenses/Unity_Reference_Only_License

using UnityEngine;
using UnityEngine.Experimental.UIElements;

namespace UnityEditor.Experimental.UIElements.GraphView
{
    public class ClickSelector : MouseManipulator
    {
        static bool WasSelectableDescendantHitByMouse(GraphElement currentTarget, MouseDownEvent evt)
        {
            VisualElement targetElement = evt.target as VisualElement;

            if (targetElement == null || currentTarget == targetElement)
                return false;

            VisualElement descendant = targetElement;

            while (descendant != null && currentTarget != descendant)
            {
                GraphElement selectableDescendant = descendant as GraphElement;

                if (selectableDescendant != null && selectableDescendant.enabledInHierarchy && selectableDescendant.pickingMode != PickingMode.Ignore && selectableDescendant.IsSelectable())
                {
                    Vector2 localMousePosition = currentTarget.ChangeCoordinatesTo(descendant, evt.localMousePosition);

                    if (selectableDescendant.HitTest(localMousePosition))
                    {
                        return true;
                    }
                }
                descendant = descendant.parent;
            }
            return false;
        }

        public ClickSelector()
        {
            activators.Add(new ManipulatorActivationFilter {button = MouseButton.LeftMouse});
            activators.Add(new ManipulatorActivationFilter {button = MouseButton.RightMouse});
            if (Application.platform == RuntimePlatform.OSXEditor || Application.platform == RuntimePlatform.OSXPlayer)
            {
                activators.Add(new ManipulatorActivationFilter { button = MouseButton.LeftMouse, modifiers = EventModifiers.Command });
            }
            else
            {
                activators.Add(new ManipulatorActivationFilter { button = MouseButton.LeftMouse, modifiers = EventModifiers.Control });
            }
        }

        protected override void RegisterCallbacksOnTarget()
        {
            target.RegisterCallback<MouseDownEvent>(OnMouseDown);
        }

        protected override void UnregisterCallbacksFromTarget()
        {
            target.UnregisterCallback<MouseDownEvent>(OnMouseDown);
        }

        protected void OnMouseDown(MouseDownEvent e)
        {
            var graphElement = e.currentTarget as GraphElement;

            if (graphElement == null)
            {
                return;
            }

            if (CanStartManipulation(e) && graphElement.IsSelectable() && graphElement.HitTest(e.localMousePosition) && !WasSelectableDescendantHitByMouse(graphElement, e))
            {
                var gv = graphElement.GetFirstAncestorOfType<GraphView>();

                if (graphElement.IsSelected(gv))
                {
                    if (e.actionKey)
                    {
                        graphElement.Unselect(gv);
                    }
                }
                else
                {
                    graphElement.Select(gv, e.actionKey);
                }
                // Do not stop the propagation as it is common case for a parent start to move the selection on a mouse down.
            }
        }
    }
}
