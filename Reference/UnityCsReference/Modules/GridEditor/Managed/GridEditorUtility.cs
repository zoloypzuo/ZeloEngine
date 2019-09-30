// Unity C# reference source
// Copyright (c) Unity Technologies. For terms of use, see
// https://unity3d.com/legal/licenses/Unity_Reference_Only_License

using System;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.Tilemaps;
using Event = UnityEngine.Event;

namespace UnityEditorInternal
{
    internal static class GridEditorUtility
    {
        private const int k_GridGizmoVertexCount = 32000;
        private const float k_GridGizmoDistanceFalloff = 50f;

        public static Vector3Int ClampToGrid(Vector3Int p, Vector2Int origin, Vector2Int gridSize)
        {
            return new Vector3Int(
                Math.Max(Math.Min(p.x, origin.x + gridSize.x - 1), origin.x),
                Math.Max(Math.Min(p.y, origin.y + gridSize.y - 1), origin.y),
                p.z
            );
        }

        public static Vector3 ScreenToLocal(Transform transform, Vector2 screenPosition)
        {
            return ScreenToLocal(transform, screenPosition, new Plane(transform.forward * -1f, transform.position));
        }

        public static Vector3 ScreenToLocal(Transform transform, Vector2 screenPosition, Plane plane)
        {
            Ray ray;
            if (Camera.current.orthographic)
            {
                Vector2 screen = EditorGUIUtility.PointsToPixels(GUIClip.Unclip(screenPosition));
                screen.y = Screen.height - screen.y;
                Vector3 cameraWorldPoint = Camera.current.ScreenToWorldPoint(screen);
                ray = new Ray(cameraWorldPoint, Camera.current.transform.forward);
            }
            else
            {
                ray = HandleUtility.GUIPointToWorldRay(screenPosition);
            }

            float result;
            plane.Raycast(ray, out result);
            Vector3 world = ray.GetPoint(result);
            return transform.InverseTransformPoint(world);
        }

        public static RectInt GetMarqueeRect(Vector2Int p1, Vector2Int p2)
        {
            return new RectInt(
                Math.Min(p1.x, p2.x),
                Math.Min(p1.y, p2.y),
                Math.Abs(p2.x - p1.x) + 1,
                Math.Abs(p2.y - p1.y) + 1
            );
        }

        public static BoundsInt GetMarqueeBounds(Vector3Int p1, Vector3Int p2)
        {
            return new BoundsInt(
                Math.Min(p1.x, p2.x),
                Math.Min(p1.y, p2.y),
                Math.Min(p1.z, p2.z),
                Math.Abs(p2.x - p1.x) + 1,
                Math.Abs(p2.y - p1.y) + 1,
                Math.Abs(p2.z - p1.z) + 1
            );
        }

        // http://ericw.ca/notes/bresenhams-line-algorithm-in-csharp.html
        public static IEnumerable<Vector2Int> GetPointsOnLine(Vector2Int p1, Vector2Int p2)
        {
            int x0 = p1.x;
            int y0 = p1.y;
            int x1 = p2.x;
            int y1 = p2.y;

            bool steep = Math.Abs(y1 - y0) > Math.Abs(x1 - x0);
            if (steep)
            {
                int t;
                t = x0; // swap x0 and y0
                x0 = y0;
                y0 = t;
                t = x1; // swap x1 and y1
                x1 = y1;
                y1 = t;
            }
            if (x0 > x1)
            {
                int t;
                t = x0; // swap x0 and x1
                x0 = x1;
                x1 = t;
                t = y0; // swap y0 and y1
                y0 = y1;
                y1 = t;
            }
            int dx = x1 - x0;
            int dy = Math.Abs(y1 - y0);
            int error = dx / 2;
            int ystep = (y0 < y1) ? 1 : -1;
            int y = y0;
            for (int x = x0; x <= x1; x++)
            {
                yield return new Vector2Int((steep ? y : x), (steep ? x : y));
                error = error - dy;
                if (error < 0)
                {
                    y += ystep;
                    error += dx;
                }
            }
            yield break;
        }

        public static void DrawBatchedHorizontalLine(float x1, float x2, float y)
        {
            GL.Vertex3(x1, y, 0f);
            GL.Vertex3(x2, y, 0f);
            GL.Vertex3(x2, y + 1, 0f);
            GL.Vertex3(x1, y + 1, 0f);
        }

        public static void DrawBatchedVerticalLine(float y1, float y2, float x)
        {
            GL.Vertex3(x, y1, 0f);
            GL.Vertex3(x, y2, 0f);
            GL.Vertex3(x + 1, y2, 0f);
            GL.Vertex3(x + 1, y1, 0f);
        }

        public static void DrawBatchedLine(Vector3 p1, Vector3 p2)
        {
            GL.Vertex3(p1.x, p1.y, p1.z);
            GL.Vertex3(p2.x, p2.y, p2.z);
        }

        public static void DrawLine(Vector2 p1, Vector2 p2, Color color)
        {
            if (Event.current.type != EventType.Repaint)
                return;

            HandleUtility.ApplyWireMaterial();
            GL.PushMatrix();
            GL.MultMatrix(GUI.matrix);
            GL.Begin(GL.LINES);
            GL.Color(color);
            DrawBatchedLine(p1, p2);
            GL.End();
            GL.PopMatrix();
        }

        public static void DrawBox(Rect r, Color color)
        {
            if (Event.current.type != EventType.Repaint)
                return;

            HandleUtility.ApplyWireMaterial();
            GL.PushMatrix();
            GL.MultMatrix(GUI.matrix);
            GL.Begin(GL.LINES);
            GL.Color(color);
            DrawBatchedLine(new Vector3(r.xMin, r.yMin, 0f), new Vector3(r.xMax, r.yMin, 0f));
            DrawBatchedLine(new Vector3(r.xMax, r.yMin, 0f), new Vector3(r.xMax, r.yMax, 0f));
            DrawBatchedLine(new Vector3(r.xMax, r.yMax, 0f), new Vector3(r.xMin, r.yMax, 0f));
            DrawBatchedLine(new Vector3(r.xMin, r.yMax, 0f), new Vector3(r.xMin, r.yMin, 0f));
            GL.End();
            GL.PopMatrix();
        }

        public static void DrawFilledBox(Rect r, Color color)
        {
            if (Event.current.type != EventType.Repaint)
                return;

            HandleUtility.ApplyWireMaterial();
            GL.PushMatrix();
            GL.MultMatrix(GUI.matrix);
            GL.Begin(GL.QUADS);
            GL.Color(color);
            GL.Vertex3(r.xMin, r.yMin, 0f);
            GL.Vertex3(r.xMax, r.yMin, 0f);
            GL.Vertex3(r.xMax, r.yMax, 0f);
            GL.Vertex3(r.xMin, r.yMax, 0f);
            GL.End();
            GL.PopMatrix();
        }

        public static void DrawGridMarquee(GridLayout gridLayout, BoundsInt area, Color color)
        {
            switch (gridLayout.cellLayout)
            {
                case Grid.CellLayout.Hexagon:
                    DrawSelectedHexGridArea(gridLayout, area, color);
                    break;
                case Grid.CellLayout.Isometric:
                case Grid.CellLayout.IsometricZAsY:
                case Grid.CellLayout.Rectangle:
                    Vector3 cellStride = gridLayout.cellSize + gridLayout.cellGap;
                    Vector3 cellGap = Vector3.one;
                    if (!Mathf.Approximately(cellStride.x, 0f))
                    {
                        cellGap.x = gridLayout.cellSize.x / cellStride.x;
                    }
                    if (!Mathf.Approximately(cellStride.y, 0f))
                    {
                        cellGap.y = gridLayout.cellSize.y / cellStride.y;
                    }

                    Vector3[] cellLocals =
                    {
                        gridLayout.CellToLocal(new Vector3Int(area.xMin, area.yMin, area.zMin)),
                        gridLayout.CellToLocalInterpolated(new Vector3(area.xMax - 1 + cellGap.x, area.yMin, area.zMin)),
                        gridLayout.CellToLocalInterpolated(new Vector3(area.xMax - 1 + cellGap.x, area.yMax - 1  + cellGap.y, area.zMin)),
                        gridLayout.CellToLocalInterpolated(new Vector3(area.xMin, area.yMax - 1 + cellGap.y, area.zMin))
                    };

                    HandleUtility.ApplyWireMaterial();
                    GL.PushMatrix();
                    GL.MultMatrix(gridLayout.transform.localToWorldMatrix);
                    GL.Begin(GL.LINES);
                    GL.Color(color);
                    int i = 0;

                    for (int j = cellLocals.Length - 1; i < cellLocals.Length; j = i++)
                        DrawBatchedLine(cellLocals[j], cellLocals[i]);

                    GL.End();
                    GL.PopMatrix();
                    break;
            }
        }

        public static void DrawSelectedHexGridArea(GridLayout gridLayout, BoundsInt area, Color color)
        {
            int requiredVertices = 4 * (area.size.x + area.size.y) - 2;
            if (requiredVertices < 0)
                return;
            Vector3[] cellLocals = new Vector3[requiredVertices];
            int horizontalCount = area.size.x * 2;
            int verticalCount = area.size.y * 2 - 1;
            int bottom = 0;
            int top = horizontalCount + verticalCount + horizontalCount - 1;
            int left = requiredVertices - 1;
            int right = horizontalCount;
            Vector3[] cellOffset =
            {
                Grid.Swizzle(gridLayout.cellSwizzle, new Vector3(0, gridLayout.cellSize.y / 2, area.zMin)),
                Grid.Swizzle(gridLayout.cellSwizzle, new Vector3(gridLayout.cellSize.x / 2, gridLayout.cellSize.y / 4, area.zMin)),
                Grid.Swizzle(gridLayout.cellSwizzle, new Vector3(gridLayout.cellSize.x / 2, -gridLayout.cellSize.y / 4, area.zMin)),
                Grid.Swizzle(gridLayout.cellSwizzle, new Vector3(0, -gridLayout.cellSize.y / 2, area.zMin)),
                Grid.Swizzle(gridLayout.cellSwizzle, new Vector3(-gridLayout.cellSize.x / 2, -gridLayout.cellSize.y / 4, area.zMin)),
                Grid.Swizzle(gridLayout.cellSwizzle, new Vector3(-gridLayout.cellSize.x / 2, gridLayout.cellSize.y / 4, area.zMin))
            };
            // Fill Top and Bottom Vertices
            for (int x = area.min.x; x < area.max.x; x++)
            {
                cellLocals[bottom++] = gridLayout.CellToLocal(new Vector3Int(x, area.min.y, area.zMin)) + cellOffset[4];
                cellLocals[bottom++] = gridLayout.CellToLocal(new Vector3Int(x, area.min.y, area.zMin)) + cellOffset[3];
                cellLocals[top--] = gridLayout.CellToLocal(new Vector3Int(x, area.max.y - 1, area.zMin)) + cellOffset[0];
                cellLocals[top--] = gridLayout.CellToLocal(new Vector3Int(x, area.max.y - 1, area.zMin)) + cellOffset[1];
            }
            // Fill first Left and Right Vertices
            cellLocals[left--] = gridLayout.CellToLocal(new Vector3Int(area.min.x, area.min.y, area.zMin)) + cellOffset[5];
            cellLocals[top--] = gridLayout.CellToLocal(new Vector3Int(area.max.x - 1, area.max.y - 1, area.zMin)) + cellOffset[2];
            // Fill Left and Right Vertices
            for (int y = area.min.y + 1; y < area.max.y; y++)
            {
                cellLocals[left--] = gridLayout.CellToLocal(new Vector3Int(area.min.x, y, area.zMin)) + cellOffset[4];
                cellLocals[left--] = gridLayout.CellToLocal(new Vector3Int(area.min.x, y, area.zMin)) + cellOffset[5];
            }
            for (int y = area.min.y; y < (area.max.y - 1); y++)
            {
                cellLocals[right++] = gridLayout.CellToLocal(new Vector3Int(area.max.x - 1, y, area.zMin)) + cellOffset[2];
                cellLocals[right++] = gridLayout.CellToLocal(new Vector3Int(area.max.x - 1, y, area.zMin)) + cellOffset[1];
            }
            HandleUtility.ApplyWireMaterial();
            GL.PushMatrix();
            GL.MultMatrix(gridLayout.transform.localToWorldMatrix);
            GL.Begin(GL.LINES);
            GL.Color(color);
            int i = 0;
            for (int j = cellLocals.Length - 1; i < cellLocals.Length; j = i++)
            {
                DrawBatchedLine(cellLocals[j], cellLocals[i]);
            }
            GL.End();
            GL.PopMatrix();
        }

        public static void DrawGridGizmo(GridLayout gridLayout, Transform transform, Color color, ref Mesh gridMesh, ref Material gridMaterial)
        {
            // TODO: Hook this up with DrawGrid
            if (Event.current.type != EventType.Repaint)
                return;

            if (gridMesh == null)
                gridMesh = GenerateCachedGridMesh(gridLayout, color);

            if (gridMaterial == null)
            {
                gridMaterial = (Material)EditorGUIUtility.LoadRequired("SceneView/GridGap.mat");
            }

            if (gridLayout.cellLayout == GridLayout.CellLayout.Hexagon)
            {
                gridMaterial.SetVector("_Gap", new Vector4(1f, 1f / 3f, 1f, 1f));
                gridMaterial.SetVector("_Stride", new Vector4(1f, 1f, 1f, 1f));
            }
            else
            {
                gridMaterial.SetVector("_Gap", gridLayout.cellSize);
                gridMaterial.SetVector("_Stride", gridLayout.cellGap + gridLayout.cellSize);
            }

            gridMaterial.SetPass(0);
            GL.PushMatrix();
            if (gridMesh.GetTopology(0) == MeshTopology.Lines)
                GL.Begin(GL.LINES);
            else
                GL.Begin(GL.QUADS);

            Graphics.DrawMeshNow(gridMesh, transform.localToWorldMatrix);
            GL.End();
            GL.PopMatrix();
        }

        public static Vector3 GetSpriteWorldSize(Sprite sprite)
        {
            if (sprite != null && sprite.rect.size.magnitude > 0f)
            {
                return new Vector3(
                    sprite.rect.size.x / sprite.pixelsPerUnit,
                    sprite.rect.size.y / sprite.pixelsPerUnit,
                    1f
                );
            }
            return Vector3.one;
        }

        private static Mesh GenerateCachedGridMesh(GridLayout gridLayout, Color color)
        {
            switch (gridLayout.cellLayout)
            {
                case GridLayout.CellLayout.Hexagon:
                    return GenerateCachedHexagonalGridMesh(gridLayout, color);
                case GridLayout.CellLayout.Isometric:
                case GridLayout.CellLayout.IsometricZAsY:
                case GridLayout.CellLayout.Rectangle:
                    int min = k_GridGizmoVertexCount / -32;
                    int max = min * -1;
                    int numCells = max - min;
                    RectInt bounds = new RectInt(min, min, numCells, numCells);

                    return GenerateCachedGridMesh(gridLayout, color, 0f, bounds, MeshTopology.Lines);
            }
            return null;
        }

        public static Mesh GenerateCachedGridMesh(GridLayout gridLayout, Color color, float screenPixelSize, RectInt bounds, MeshTopology topology)
        {
            Mesh mesh = new Mesh();
            mesh.hideFlags = HideFlags.HideAndDontSave;

            int vertex = 0;

            int totalVertices = topology == MeshTopology.Quads ?
                8 * (bounds.size.x + bounds.size.y) :
                4 * (bounds.size.x + bounds.size.y);

            Vector3 horizontalPixelOffset = new Vector3(screenPixelSize, 0f, 0f);
            Vector3 verticalPixelOffset = new Vector3(0f, screenPixelSize, 0f);

            Vector3[] vertices = new Vector3[totalVertices];
            Vector2[] uvs2 = new Vector2[totalVertices];

            Vector3 cellStride = gridLayout.cellSize + gridLayout.cellGap;
            Vector3Int minPosition = new Vector3Int(0, bounds.min.y, 0);
            Vector3Int maxPosition = new Vector3Int(0, bounds.max.y, 0);

            Vector3 cellGap = Vector3.zero;
            if (!Mathf.Approximately(cellStride.x, 0f))
            {
                cellGap.x = gridLayout.cellSize.x / cellStride.x;
            }

            for (int x = bounds.min.x; x < bounds.max.x; x++)
            {
                minPosition.x = x;
                maxPosition.x = x;

                vertices[vertex + 0] = gridLayout.CellToLocal(minPosition);
                vertices[vertex + 1] = gridLayout.CellToLocal(maxPosition);
                uvs2[vertex + 0] = Vector2.zero;
                uvs2[vertex + 1] = new Vector2(0f, cellStride.y * bounds.size.y);
                if (topology == MeshTopology.Quads)
                {
                    vertices[vertex + 2] = gridLayout.CellToLocal(maxPosition) + horizontalPixelOffset;
                    vertices[vertex + 3] = gridLayout.CellToLocal(minPosition) + horizontalPixelOffset;
                    uvs2[vertex + 2] = new Vector2(0f, cellStride.y * bounds.size.y);
                    uvs2[vertex + 3] = Vector2.zero;
                }
                vertex += topology == MeshTopology.Quads ? 4 : 2;

                vertices[vertex + 0] = gridLayout.CellToLocalInterpolated(minPosition + cellGap);
                vertices[vertex + 1] = gridLayout.CellToLocalInterpolated(maxPosition + cellGap);
                uvs2[vertex + 0] = Vector2.zero;
                uvs2[vertex + 1] = new Vector2(0f, cellStride.y * bounds.size.y);
                if (topology == MeshTopology.Quads)
                {
                    vertices[vertex + 2] = gridLayout.CellToLocalInterpolated(maxPosition + cellGap) + horizontalPixelOffset;
                    vertices[vertex + 3] = gridLayout.CellToLocalInterpolated(minPosition + cellGap) + horizontalPixelOffset;
                    uvs2[vertex + 2] = new Vector2(0f, cellStride.y * bounds.size.y);
                    uvs2[vertex + 3] = Vector2.zero;
                }
                vertex += topology == MeshTopology.Quads ? 4 : 2;
            }

            minPosition = new Vector3Int(bounds.min.x, 0, 0);
            maxPosition = new Vector3Int(bounds.max.x, 0, 0);
            cellGap = Vector3.zero;
            if (!Mathf.Approximately(cellStride.y, 0f))
            {
                cellGap.y = gridLayout.cellSize.y / cellStride.y;
            }

            for (int y = bounds.min.y; y < bounds.max.y; y++)
            {
                minPosition.y = y;
                maxPosition.y = y;

                vertices[vertex + 0] = gridLayout.CellToLocal(minPosition);
                vertices[vertex + 1] = gridLayout.CellToLocal(maxPosition);
                uvs2[vertex + 0] = Vector2.zero;
                uvs2[vertex + 1] = new Vector2(cellStride.x * bounds.size.x, 0f);
                if (topology == MeshTopology.Quads)
                {
                    vertices[vertex + 2] = gridLayout.CellToLocal(maxPosition) + verticalPixelOffset;
                    vertices[vertex + 3] = gridLayout.CellToLocal(minPosition) + verticalPixelOffset;
                    uvs2[vertex + 2] = new Vector2(cellStride.x * bounds.size.x, 0f);
                    uvs2[vertex + 3] = Vector2.zero;
                }
                vertex += topology == MeshTopology.Quads ? 4 : 2;

                vertices[vertex + 0] = gridLayout.CellToLocalInterpolated(minPosition + cellGap);
                vertices[vertex + 1] = gridLayout.CellToLocalInterpolated(maxPosition + cellGap);
                uvs2[vertex + 0] = Vector2.zero;
                uvs2[vertex + 1] = new Vector2(cellStride.x * bounds.size.x, 0f);
                if (topology == MeshTopology.Quads)
                {
                    vertices[vertex + 2] = gridLayout.CellToLocalInterpolated(maxPosition + cellGap) + verticalPixelOffset;
                    vertices[vertex + 3] = gridLayout.CellToLocalInterpolated(minPosition + cellGap) + verticalPixelOffset;
                    uvs2[vertex + 2] = new Vector2(cellStride.x * bounds.size.x, 0f);
                    uvs2[vertex + 3] = Vector2.zero;
                }
                vertex += topology == MeshTopology.Quads ? 4 : 2;
            }

            var uv0 = new Vector2(k_GridGizmoDistanceFalloff, 0f);
            var uvs = new Vector2[vertex];
            var indices = new int[vertex];
            var colors = new Color[vertex];
            var normals = new Vector3[totalVertices];     // Normal channel stores the position of the other end point of the line.
            var uvs3 = new Vector2[totalVertices];        // UV3 channel stores the UV2 value of the other end point of the line.

            for (int i = 0; i < vertex; i++)
            {
                uvs[i] = uv0;
                indices[i] = i;
                colors[i] = color;
                var alternate = i + ((i % 2) == 0 ? 1 : -1);
                normals[i] = vertices[alternate];
                uvs3[i] = uvs2[alternate];
            }

            mesh.vertices = vertices;
            mesh.uv = uvs;
            mesh.uv2 = uvs2;
            mesh.uv3 = uvs3;
            mesh.colors = colors;
            mesh.normals = normals;
            mesh.SetIndices(indices, topology, 0);

            return mesh;
        }

        private static Mesh GenerateCachedHexagonalGridMesh(GridLayout gridLayout, Color color)
        {
            Mesh mesh = new Mesh();
            mesh.hideFlags = HideFlags.HideAndDontSave;
            int vertex = 0;
            int max = k_GridGizmoVertexCount / (2 * (6 * 2));
            max = (max / 4) * 4;
            int min = -max;
            float numVerticalCells = 6 * (max / 4);
            int totalVertices = max * 2 * 6 * 2;
            var cellStrideY = gridLayout.cellGap.y + gridLayout.cellSize.y;
            var cellOffsetY = gridLayout.cellSize.y / 2;
            var hexOffset = (1.0f / 3.0f);
            var drawTotal = numVerticalCells * 2.0f * hexOffset;
            var drawDiagTotal = 2 * drawTotal;
            Vector3[] vertices = new Vector3[totalVertices];
            Vector2[] uvs2 = new Vector2[totalVertices];
            // Draw Vertical Lines
            for (int x = min; x < max; x++)
            {
                vertices[vertex] = gridLayout.CellToLocal(new Vector3Int(x, min, 0));
                vertices[vertex + 1] = gridLayout.CellToLocal(new Vector3Int(x, max, 0));
                uvs2[vertex] = new Vector2(0f, 2 * hexOffset);
                uvs2[vertex + 1] = new Vector2(0f, 2 * hexOffset + drawTotal);
                vertex += 2;
                // Alternate Row Offset
                vertices[vertex] = gridLayout.CellToLocal(new Vector3Int(x, min - 1, 0));
                vertices[vertex + 1] = gridLayout.CellToLocal(new Vector3Int(x, max - 1, 0));
                uvs2[vertex] = new Vector2(0f, 2 * hexOffset);
                uvs2[vertex + 1] = new Vector2(0f, 2 * hexOffset + drawTotal);
                vertex += 2;
            }
            // Draw Diagonals
            for (int y = min; y < max; y++)
            {
                float drawDiagOffset = ((y + 1) % 3) * hexOffset;
                var cellOffSet = Grid.Swizzle(gridLayout.cellSwizzle, new Vector3(0f, y * cellStrideY + cellOffsetY, 0.0f));
                // Slope Up
                vertices[vertex] = gridLayout.CellToLocal(new Vector3Int(Mathf.RoundToInt(1.5f * min), min, 0)) + cellOffSet;
                vertices[vertex + 1] = gridLayout.CellToLocal(new Vector3Int(Mathf.RoundToInt(1.5f * max), max, 0)) + cellOffSet;
                uvs2[vertex] = new Vector2(0f, drawDiagOffset);
                uvs2[vertex + 1] = new Vector2(0f, drawDiagOffset + drawDiagTotal);
                vertex += 2;
                // Slope Down
                vertices[vertex] = gridLayout.CellToLocal(new Vector3Int(Mathf.RoundToInt(1.5f * max), min, 0)) + cellOffSet;
                vertices[vertex + 1] = gridLayout.CellToLocal(new Vector3Int(Mathf.RoundToInt(1.5f * min), max, 0)) + cellOffSet;
                uvs2[vertex] = new Vector2(0f, drawDiagOffset);
                uvs2[vertex + 1] = new Vector2(0f, drawDiagOffset + drawDiagTotal);
                vertex += 2;
                // Alternate Row Offset
                vertices[vertex] = gridLayout.CellToLocal(new Vector3Int(Mathf.RoundToInt(1.5f * min) + 1, min, 0)) + cellOffSet;
                vertices[vertex + 1] = gridLayout.CellToLocal(new Vector3Int(Mathf.RoundToInt(1.5f * max) + 1, max, 0)) + cellOffSet;
                uvs2[vertex] = new Vector2(0f, drawDiagOffset);
                uvs2[vertex + 1] = new Vector2(0f, drawDiagOffset + drawDiagTotal);
                vertex += 2;
                vertices[vertex] = gridLayout.CellToLocal(new Vector3Int(Mathf.RoundToInt(1.5f * max) + 1, min, 0)) + cellOffSet;
                vertices[vertex + 1] = gridLayout.CellToLocal(new Vector3Int(Mathf.RoundToInt(1.5f * min) + 1, max, 0)) + cellOffSet;
                uvs2[vertex] = new Vector2(0f, drawDiagOffset);
                uvs2[vertex + 1] = new Vector2(0f, drawDiagOffset + drawDiagTotal);
                vertex += 2;
            }
            var uv0 = new Vector2(k_GridGizmoDistanceFalloff, 0f);
            var indices = new int[totalVertices];
            var uvs = new Vector2[totalVertices];
            var colors = new Color[totalVertices];
            var normals = new Vector3[totalVertices];     // Normal channel stores the position of the other end point of the line.
            var uvs3 = new Vector2[totalVertices];        // UV3 channel stores the UV2 value of the other end point of the line.

            for (int i = 0; i < totalVertices; i++)
            {
                uvs[i] = uv0;
                indices[i] = i;
                colors[i] = color;
                var alternate = i + ((i % 2) == 0 ? 1 : -1);
                normals[i] = vertices[alternate];
                uvs3[i] = uvs2[alternate];
            }

            mesh.vertices = vertices;
            mesh.uv = uvs;
            mesh.uv2 = uvs2;
            mesh.uv3 = uvs3;
            mesh.colors = colors;
            mesh.normals = normals;
            mesh.SetIndices(indices, MeshTopology.Lines, 0);
            return mesh;
        }
    }
}
