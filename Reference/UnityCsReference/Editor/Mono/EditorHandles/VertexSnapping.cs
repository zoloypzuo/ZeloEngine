// Unity C# reference source
// Copyright (c) Unity Technologies. For terms of use, see
// https://unity3d.com/legal/licenses/Unity_Reference_Only_License

using UnityEngine;
using UnityEditor.ShortcutManagement;

namespace UnityEditor
{
    internal class VertexSnapping
    {
        private static Vector3 s_VertexSnappingOffset = Vector3.zero;

        [Shortcut("Scene View/Toggle Vertex Snapping", typeof(SceneView), "#v")]
        private static void ToggleVertexSnappingViaShortcut()
        {
            int id = GUIUtility.hotControl;
            if (Tools.vertexDragging)
                DisableVertexSnapping(id);
            else
                EnableVertexSnapping(id);
        }

        [ClutchShortcut("Scene View/Vertex Snapping", typeof(SceneView), "v")]
        private static void ToggleVertexSnappingViaClutchShortcut(ShortcutArguments arguments)
        {
            int id = GUIUtility.hotControl;
            if (arguments.state == ShortcutState.Begin)
                EnableVertexSnapping(id);
            else
                DisableVertexSnapping(id);
        }

        // This method handles MouseMove for doing vertex snapping.
        // To ensure correct behaviour the caller must do on it's own:
        // - On MouseDown and MouseUp (if event is ours to use):
        //      HandleUtility.ignoreRaySnapObjects = null;
        // - On MouseDrag (if event is ours to use):
        //      if (Tools.vertexDragging)
        //      {
        //          if (HandleUtility.ignoreRaySnapObjects == null)
        //              Handles.SetupIgnoreRaySnapObjects ();
        //          Vector3 near;
        //          if (HandleUtility.FindNearestVertex (evt.mousePosition, null, out near))
        //          {
        //              // Snap position based on found near vertex
        //          }
        //      }
        //
        // This is not the most elegant code-reuse solution,
        // but still a step up from the copy-pasted code that was used before.
        public static void HandleMouseMove(int id)
        {
            var evt = Event.current;
            if (evt.GetTypeForControl(id) == EventType.MouseMove && Tools.vertexDragging)
            {
                EnableVertexSnapping(id);
                evt.Use();
            }
        }

        private static void EnableVertexSnapping(int id)
        {
            Tools.vertexDragging = true;
            if (GUIUtility.hotControl == id)
            {
                Tools.handleOffset = s_VertexSnappingOffset;
            }
            else
            {
                UpdateVertexSnappingOffset();
                s_VertexSnappingOffset = Tools.handleOffset;
            }
        }

        private static void DisableVertexSnapping(int id)
        {
            Tools.vertexDragging = false;
            Tools.handleOffset = Vector3.zero;
            if (GUIUtility.hotControl != id)
                s_VertexSnappingOffset = Vector3.zero;
        }

        // Iterates over selected objects, finds nearest vertex or pivot and sets Tools.handleOffset accordingly
        private static void UpdateVertexSnappingOffset()
        {
            Event evt = Event.current;
            Tools.vertexDragging = true;
            Vector3 nearestVertex;
            Transform[] selection = Selection.GetTransforms(SelectionMode.Deep | SelectionMode.ExcludePrefab | SelectionMode.Editable);

            // Make sure we're not ignoring any objects, that other handles may have set to ignore and forgot to reset.
            HandleUtility.ignoreRaySnapObjects = null;

            Vector3 nearestPivot = FindNearestPivot(selection, evt.mousePosition);
            bool foundVertex = HandleUtility.FindNearestVertex(evt.mousePosition, selection, out nearestVertex);

            Vector3 near;

            // Is nearest vertex closer than nearest pivot?
            float distanceToNearestVertex = (HandleUtility.WorldToGUIPoint(nearestVertex) - evt.mousePosition).magnitude;
            float distanceToNearestPivot = (HandleUtility.WorldToGUIPoint(nearestPivot) - evt.mousePosition).magnitude;

            if (foundVertex && (distanceToNearestVertex < distanceToNearestPivot))
                near = nearestVertex;
            else
                near = nearestPivot;

            // Important to reset handleOffset before querying handlePosition,
            // since handlePosition depends on handleOffset.
            Tools.handleOffset = Vector3.zero;
            Tools.handleOffset = near - Tools.handlePosition;
        }

        private static Vector3 FindNearestPivot(Transform[] transforms, Vector2 screenPosition)
        {
            bool foundPivot = false;
            Vector3 pivot = Vector3.zero;

            foreach (Transform transform in transforms)
            {
                Vector3 worldPosition = ScreenToWorld(screenPosition, transform);
                if (!foundPivot || (pivot - worldPosition).magnitude > (transform.position - worldPosition).magnitude)
                {
                    pivot = transform.position;
                    foundPivot = true;
                }
            }
            return pivot;
        }

        private static Vector3 ScreenToWorld(Vector2 screen, Transform target)
        {
            Ray mouseRay = HandleUtility.GUIPointToWorldRay(screen);
            float dist = 0.0f;
            new Plane(target.forward, target.position).Raycast(mouseRay, out dist);
            return mouseRay.GetPoint(dist);
        }
    }
}
