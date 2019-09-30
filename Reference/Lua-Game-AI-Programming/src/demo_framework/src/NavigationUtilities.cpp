/**
* Copyright (c) 2013 David Young dayoung@goliathdesigns.com
*
* This software is provided 'as-is', without any express or implied
* warranty. In no event will the authors be held liable for any damages
* arising from the use of this software.
*
* Permission is granted to anyone to use this software for any purpose,
* including commercial applications, and to alter it and redistribute it
* freely, subject to the following restrictions:
*
*  1. The origin of this software must not be misrepresented; you must not
*  claim that you wrote the original software. If you use this software
*  in a product, an acknowledgment in the product documentation would be
*  appreciated but is not required.
*
*  2. Altered source versions must be plainly marked as such, and must not be
*  misrepresented as being the original software.
*
*  3. This notice may not be removed or altered from any source
*  distribution.
*/

#include "PrecompiledHeaders.h"

#include "demo_framework/include/Agent.h"
#include "demo_framework/include/LuaScriptUtilities.h"
#include "demo_framework/include/MeshUtilities.h"
#include "demo_framework/include/NavigationUtilities.h"
#include "demo_framework/include/SandboxObject.h"

namespace
{
float navRand()
{
    return static_cast<float>(rand())/static_cast<float>(RAND_MAX);
}
}

MeshMetadata::MeshMetadata(
    unsigned char* const dataBuffer,
    const size_t dataBufferSize)
    : dataBuffer(dataBuffer),
    dataBufferSize(dataBufferSize)
{
    memset(dataBuffer, 0, sizeof(dataBuffer[0] * dataBufferSize));
}

namespace
{
void AddQuadIndex(
    Ogre::ManualObject* const manualObject,
    const int index1,
    const int index2,
    const int index3,
    const int index4)
{
    manualObject->quad(index1, index2, index3, index4);
}

void AddFlatBox(
    Ogre::ManualObject* const manualObject,
    float minx,
    float miny,
    float minz,
    float maxx,
    float maxy,
    float maxz,
    const Ogre::ColourValue& color)
{
    static const size_t vertexCount = 8;

    const float vertexes[vertexCount * 3] =
    {
        minx, miny, minz,
        maxx, miny, minz,
        maxx, miny, maxz,
        minx, miny, maxz,
        minx, maxy, minz,
        maxx, maxy, minz,
        maxx, maxy, maxz,
        minx, maxy, maxz,
    };

    static const size_t indices[6 * 4] =
    {
        7, 6, 5, 4,
        0, 1, 2, 3,
        1, 5, 6, 2,
        3, 7, 4, 0,
        2, 6, 7, 3,
        0, 4, 5, 1,
    };

    const size_t index = manualObject->getCurrentVertexCount();

    for (size_t vIndex = 0; vIndex < vertexCount; ++vIndex)
    {
        manualObject->position(Ogre::Vector3(
            vertexes[vIndex * 3],
            vertexes[vIndex * 3 + 1],
            vertexes[vIndex * 3 + 2]));
        manualObject->colour(color);
    }

    for (size_t vIndex = 0; vIndex < 6; ++vIndex)
    {
        AddQuadIndex(
            manualObject,
            static_cast<int>(index + indices[vIndex * 4]),
            static_cast<int>(index + indices[vIndex * 4 + 1]),
            static_cast<int>(index + indices[vIndex * 4 + 2]),
            static_cast<int>(index + indices[vIndex * 4 + 3]));
    }
}

void AddShadedBox(
    Ogre::ManualObject* const manualObject,
    float minx,
    float miny,
    float minz,
    float maxx,
    float maxy,
    float maxz,
    const Ogre::ColourValue& color)
{
    static const size_t vertexCount = 24;

    const float vertexes[vertexCount * 3] =
    {
        minx, miny, maxz,
        maxx, miny, maxz,
        maxx, maxy, maxz,
        minx, maxy, maxz,
        minx, maxy, maxz,
        maxx, maxy, maxz,
        maxx, maxy, minz,
        minx, maxy, minz,
        minx, maxy, minz,
        maxx, maxy, minz,
        maxx, miny, minz,
        minx, miny, minz,
        minx, miny, minz,
        maxx, miny, minz,
        maxx, miny, maxz,
        minx, miny, maxz,
        maxx, miny, maxz,
        maxx, miny, minz,
        maxx, maxy, minz,
        maxx, maxy, maxz,
        minx, miny, minz,
        minx, miny, maxz,
        minx, maxy, maxz,
        minx, maxy, minz,
    };

    static const size_t indices[vertexCount] =
    {
        0, 1, 2, 3,
        4, 5, 6, 7,
        8, 9, 10, 11,
        12, 13, 14, 15,
        16, 17, 18, 19,
        20, 21, 22, 23
    };

    static const float normals[vertexCount * 3] =
    {
        0, 0, 1.0f,
        0, 0, 1.0f,
        0, 0, 1.0f,
        0, 0, 1.0f,
        0, 1.0f, 0,
        0, 1.0f, 0,
        0, 1.0f, 0,
        0, 1.0f, 0,
        0, 0, -1.0f,
        0, 0, -1.0f,
        0, 0, -1.0f,
        0, 0, -1.0f,
        0, -1.0f, 0,
        0, -1.0f, 0,
        0, -1.0f, 0,
        0, -1.0f, 0,
        1.0f, 0, 0,
        1.0f, 0, 0,
        1.0f, 0, 0,
        1.0f, 0, 0,
        -1.0f, 0, 0,
        -1.0f, 0, 0,
        -1.0f, 0, 0,
        -1.0f, 0, 0
    };

    const size_t index = manualObject->getCurrentVertexCount();

    for (size_t vIndex = 0; vIndex < vertexCount; ++vIndex)
    {
        manualObject->position(Ogre::Vector3(
            vertexes[vIndex * 3],
            vertexes[vIndex * 3 + 1],
            vertexes[vIndex * 3 + 2]));
        manualObject->normal(Ogre::Vector3(
            normals[vIndex * 3],
            normals[vIndex * 3 + 1],
            normals[vIndex * 3 + 2]));
        manualObject->colour(color);
    }

    for (size_t vIndex = 0; vIndex < vertexCount / 4; ++vIndex)
    {
        AddQuadIndex(
            manualObject,
            static_cast<int>(index + indices[vIndex * 4]),
            static_cast<int>(index + indices[vIndex * 4 + 1]),
            static_cast<int>(index + indices[vIndex * 4 + 2]),
            static_cast<int>(index + indices[vIndex * 4 + 3]));
    }
}

void DrawMeshOutline(
    Ogre::ManualObject& manualObject,
    const dtNavMesh& navMesh,
    const dtMeshTile& tile)
{
    const Ogre::ColourValue lineColor(
        0.0f / 255.0f,
        128.0f / 255.0f,
        128.0f / 255.0f);

    for (int i = 0; i < tile.header->polyCount; ++i)
    {
        const dtPoly* p = &tile.polys[i];

        if (p->getType() == DT_POLYTYPE_OFFMESH_CONNECTION) continue;

        const dtPolyDetail* pd = &tile.detailMeshes[i];

        for (int j = 0, nj = (int)p->vertCount; j < nj; ++j)
        {
            if (p->neis[j] == 0) continue;

            // Draw detail mesh edges which align with the actual poly edge.
            // This is really slow.
            for (int k = 0; k < pd->triCount; ++k)
            {
                const unsigned char* t = &tile.detailTris[(pd->triBase + k) * 4];
                const float* tv[3];
                for (int m = 0; m < 3; ++m)
                {
                    if (t[m] < p->vertCount)
                        tv[m] = &tile.verts[p->verts[t[m]] * 3];
                    else
                        tv[m] = &tile.detailVerts[(pd->vertBase + (t[m] - p->vertCount)) * 3];
                }
                for (int m = 0, n = 2; m < 3; n = m++)
                {
                    if (((t[3] >> (n * 2)) & 0x3) == 0) continue;	// Skip inner detail edges.

                    manualObject.position(Ogre::Vector3(tv[n][0], tv[n][1], tv[n][2]));
                    manualObject.colour(lineColor);

                    manualObject.position(Ogre::Vector3(tv[m][0], tv[m][1], tv[m][2]));
                    manualObject.colour(lineColor);
                }
            }
        }
    }
}

void DrawMeshTile(
    Ogre::ManualObject& manualObject,
    const dtNavMesh& navMesh,
    const dtMeshTile& tile)
{
    for (int i = 0; i < tile.header->polyCount; ++i)
    {
        const dtPoly* p = &tile.polys[i];
        if (p->getType() == DT_POLYTYPE_OFFMESH_CONNECTION)	// Skip off-mesh links.
            continue;

        const dtPolyDetail* pd = &tile.detailMeshes[i];

        const Ogre::ColourValue color(
            0.0f / 255.0f,
            255.0f / 255.0f,
            255.0f / 255.0f,
            32.0f / 255.0f);

        for (int j = 0; j < pd->triCount; ++j)
        {
            const unsigned int index = static_cast<unsigned int>(
                manualObject.getCurrentVertexCount());

            const unsigned char* t = &tile.detailTris[(pd->triBase + j) * 4];

            for (int k = 0; k < 3; ++k)
            {
                float* vertex = NULL;

                if (t[k] < p->vertCount)
                {
                    vertex = &tile.verts[p->verts[t[k]] * 3];
                }
                else
                {
                    vertex = &tile.detailVerts[(pd->vertBase + t[k] - p->vertCount) * 3];
                }

                manualObject.position(
                    Ogre::Vector3(vertex[0], vertex[1], vertex[2]));

                manualObject.colour(color);
            }

            manualObject.triangle(index, index + 1, index + 2);
            manualObject.triangle(index + 2, index + 1, index);
        }
    }
}
}

void NavigationUtilities::BuildDistanceField(
    rcContext& context,
    const rcConfig& config,
    rcCompactHeightfield& heightfield)
{
    rcBuildDistanceField(&context, heightfield);
}

void NavigationUtilities::BuildRegions(
    rcContext& context,
    const rcConfig& config,
    rcCompactHeightfield& heightfield)
{
    rcBuildRegions(
        &context,
        heightfield,
        0,
        config.minRegionArea,
        config.mergeRegionArea);
}

rcCompactHeightfield* NavigationUtilities::CreateCompactHeightfield(
    rcContext& context, const rcConfig& config, rcHeightfield& heightfield)
{
    rcCompactHeightfield* const compactHeightfield =
        rcAllocCompactHeightfield();

    rcBuildCompactHeightfield(
        &context,
        config.walkableHeight,
        config.walkableClimb,
        heightfield,
        *compactHeightfield);

    return compactHeightfield;
}

rcContourSet* NavigationUtilities::CreateContourSet(
    rcContext& context,
    const rcConfig& config,
    rcCompactHeightfield& heightfield)
{
    rcContourSet* const contourSet = rcAllocContourSet();

    rcBuildContours(
        &context,
        heightfield,
        config.maxSimplificationError,
        config.maxEdgeLen,
        *contourSet);

    return contourSet;
}

rcHeightfield* NavigationUtilities::CreateHeightfield(
    rcContext& context, const rcConfig& config)
{
    rcHeightfield* const heightField = rcAllocHeightfield();

    rcCreateHeightfield(
        &context,
        *heightField,
        config.width,
        config.height,
        config.bmin,
        config.bmax,
        config.cs,
        config.ch);

    return heightField;
}

Ogre::ManualObject* NavigationUtilities::CreateManualObject(
    Ogre::SceneManager& sceneManager, const dtNavMesh& navMesh)
{
    Ogre::ManualObject* const manualObject = sceneManager.createManualObject();
    manualObject->setCastShadows(false);

    manualObject->begin("debug_draw", Ogre::RenderOperation::OT_TRIANGLE_LIST);

    for (int i = 0; i < navMesh.getMaxTiles(); ++i)
    {
        const dtMeshTile* const tile = navMesh.getTile(i);
        if (!tile->header)
        {
            continue;
        }

        DrawMeshTile(*manualObject, navMesh, *tile);
    }

    manualObject->end();

    manualObject->begin("debug_opaque_draw", Ogre::RenderOperation::OT_LINE_LIST);

    for (int i = 0; i < navMesh.getMaxTiles(); ++i)
    {
        const dtMeshTile* const tile = navMesh.getTile(i);
        if (!tile->header)
        {
            continue;
        }

        DrawMeshOutline(*manualObject, navMesh, *tile);
    }

    manualObject->end();

    return manualObject;
}

Ogre::ManualObject* NavigationUtilities::CreateManualObject(
    Ogre::SceneManager& sceneManager, const rcHeightfield& heightfield)
{
    Ogre::ManualObject* const manualObject = sceneManager.createManualObject();
    manualObject->setCastShadows(false);

    const float* const origin = heightfield.bmin;
    const float cellSize = heightfield.cs;
    const float cellHeight = heightfield.ch;

    const int width = heightfield.width;
    const int height = heightfield.height;

    const Ogre::ColourValue color(1.0f, 0.0f, 1.0f, 1.0f);

    manualObject->begin("White", Ogre::RenderOperation::OT_TRIANGLE_LIST);

    for (int y = 0; y < height; ++y)
    {
        for (int x = 0; x < width; ++x)
        {
            const float fx = origin[0] + x * cellSize;
            const float fz = origin[2] + y * cellSize;
            const rcSpan* span = heightfield.spans[x + y * width];

            while (span)
            {
                AddShadedBox(
                    manualObject,
                    fx,
                    origin[1] + span->smin * cellHeight,
                    fz,
                    fx + cellSize,
                    origin[1] + span->smax * cellHeight,
                    fz + cellSize,
                    color);

                span = span->next;
            }
        }
    }

    manualObject->end();

    return manualObject;
}

Ogre::ManualObject* NavigationUtilities::CreateManualObject(
    Ogre::SceneManager& sceneManager, const rcPolyMesh& polyMesh)
{
    Ogre::ManualObject* const manualObject = sceneManager.createManualObject();
    manualObject->setCastShadows(false);

    manualObject->begin("debug_draw", Ogre::RenderOperation::OT_TRIANGLE_LIST);

    const int numVertexPerPoly = polyMesh.nvp;
    const float cellSize = polyMesh.cs;
    const float cellHeight = polyMesh.ch;
    const float* orig = polyMesh.bmin;

    for (int polygonIndex = 0; polygonIndex < polyMesh.npolys; ++polygonIndex)
    {
        const unsigned short* polygon =
            &polyMesh.polys[polygonIndex*numVertexPerPoly * 2];

        Ogre::ColourValue color;

        if (polyMesh.areas[polygonIndex] == RC_WALKABLE_AREA)
        {
            color = Ogre::ColourValue(
                0.0f / 255.0f,
                255.0f / 255.0f,
                255.0f / 255.0f,
                32.0f / 255.0f);
        }
        else if (polyMesh.areas[polygonIndex] == RC_NULL_AREA)
        {
            color = Ogre::ColourValue(0, 0, 0, 0);
        }
        else
        {
            color = Ogre::ColourValue(
                polyMesh.areas[polygonIndex] / 255.0f,
                polyMesh.areas[polygonIndex] / 255.0f,
                polyMesh.areas[polygonIndex] / 255.0f);
        }

        unsigned short vi[3];
        for (int vertexNum = 2; vertexNum < numVertexPerPoly; ++vertexNum)
        {
            if (polygon[vertexNum] == RC_MESH_NULL_IDX) break;
            vi[0] = polygon[0];
            vi[1] = polygon[vertexNum - 1];
            vi[2] = polygon[vertexNum];

            const unsigned int index = static_cast<unsigned int>(
                manualObject->getCurrentVertexCount());

            for (int k = 0; k < 3; ++k)
            {
                const unsigned short* v = &polyMesh.verts[vi[k] * 3];
                const float x = orig[0] + v[0] * cellSize;
                const float y = orig[1] + (v[1] + 1)*cellHeight;
                const float z = orig[2] + v[2] * cellSize;

                manualObject->position(Ogre::Vector3(x, y, z));
                manualObject->colour(color);
            }

            manualObject->triangle(index, index + 1, index + 2);
            manualObject->triangle(index + 2, index + 1, index);
        }
    }

    manualObject->end();

    const Ogre::ColourValue lineColor(
        0.0f / 255.0f,
        128.0f / 255.0f,
        128.0f / 255.0f);

    manualObject->begin("debug_draw", Ogre::RenderOperation::OT_LINE_LIST);

    for (int polygonIndex = 0; polygonIndex < polyMesh.npolys; ++polygonIndex)
    {
        const unsigned short* polygon = &polyMesh.polys[polygonIndex*numVertexPerPoly * 2];
        for (int vertexNum = 0; vertexNum < numVertexPerPoly; ++vertexNum)
        {
            if (polygon[vertexNum] == RC_MESH_NULL_IDX)
            {
                break;
            }

            if (polygon[numVertexPerPoly + vertexNum] & 0x8000)
            {
                continue;
            }

            const int nextVertex = (vertexNum + 1 >= numVertexPerPoly || polygon[vertexNum + 1] == RC_MESH_NULL_IDX) ? 0 : vertexNum + 1;

            const int lineVertices[2] =
                { polygon[vertexNum], polygon[nextVertex] };

            for (int lineVertexIndex = 0; lineVertexIndex < 2; ++lineVertexIndex)
            {
                const unsigned short* vertex = &polyMesh.verts[lineVertices[lineVertexIndex] * 3];
                const float x = orig[0] + vertex[0] * cellSize;
                const float y = orig[1] + (vertex[1] + 1)*cellHeight;
                const float z = orig[2] + vertex[2] * cellSize;

                manualObject->position(Ogre::Vector3(x, y, z));
                manualObject->colour(lineColor);
            }
        }
    }

    for (int polygonIndex = 0; polygonIndex < polyMesh.npolys; ++polygonIndex)
    {
        const unsigned short* polygon =
            &polyMesh.polys[polygonIndex*numVertexPerPoly * 2];

        for (int vertexNum = 0; vertexNum < numVertexPerPoly; ++vertexNum)
        {
            if (polygon[vertexNum] == RC_MESH_NULL_IDX) break;
            if ((polygon[numVertexPerPoly + vertexNum] & 0x8000) == 0) continue;
            const int nextVertex = (vertexNum + 1 >= numVertexPerPoly || polygon[vertexNum + 1] == RC_MESH_NULL_IDX) ? 0 : vertexNum + 1;
            const int lineVertices[2] = { polygon[vertexNum], polygon[nextVertex] };

            for (int lineVertexIndex = 0; lineVertexIndex < 2; ++lineVertexIndex)
            {
                const unsigned short* v = &polyMesh.verts[lineVertices[lineVertexIndex] * 3];
                const float x = orig[0] + v[0] * cellSize;
                const float y = orig[1] + (v[1] + 1)*cellHeight;
                const float z = orig[2] + v[2] * cellSize;

                manualObject->position(Ogre::Vector3(x, y, z));
                manualObject->colour(lineColor);
            }
        }
    }

    manualObject->end();

    return manualObject;
}

Ogre::ManualObject* NavigationUtilities::CreateManualObject(
    Ogre::SceneManager& sceneManager, const rcPolyMeshDetail& polyMesh)
{
    Ogre::ManualObject* const manualObject = sceneManager.createManualObject();
    manualObject->setCastShadows(false);

    manualObject->begin("debug_draw", Ogre::RenderOperation::OT_TRIANGLE_LIST);

    Ogre::ColourValue color(
        0.0f / 255.0f,
        255.0f / 255.0f,
        255.0f / 255.0f,
        32.0f / 255.0f);

    for (int i = 0; i < polyMesh.nmeshes; ++i)
    {
        const unsigned int* m = &polyMesh.meshes[i * 4];
        const unsigned int bverts = m[0];
        const unsigned int btris = m[2];
        const int ntris = (int)m[3];
        const float* verts = &polyMesh.verts[bverts * 3];
        const unsigned char* tris = &polyMesh.tris[btris * 4];

        for (int j = 0; j < ntris; ++j)
        {
            const unsigned int index = static_cast<unsigned int>(
                manualObject->getCurrentVertexCount());

            const float* vert = &verts[tris[j * 4 + 0] * 3];
            manualObject->position(Ogre::Vector3(vert[0], vert[1], vert[2]));
            manualObject->colour(color);

            vert = &verts[tris[j * 4 + 1] * 3];
            manualObject->position(Ogre::Vector3(vert[0], vert[1], vert[2]));
            manualObject->colour(color);

            vert = &verts[tris[j * 4 + 2] * 3];
            manualObject->position(Ogre::Vector3(vert[0], vert[1], vert[2]));
            manualObject->colour(color);

            manualObject->triangle(index, index + 1, index + 2);
            manualObject->triangle(index + 2, index + 1, index);
        }
    }

    manualObject->end();

    const Ogre::ColourValue lineColor(
        0.0f / 255.0f,
        128.0f / 255.0f,
        128.0f / 255.0f);

    manualObject->begin("debug_draw", Ogre::RenderOperation::OT_LINE_LIST);

    for (int i = 0; i < polyMesh.nmeshes; ++i)
    {
        const unsigned int* m = &polyMesh.meshes[i * 4];
        const unsigned int bverts = m[0];
        const unsigned int btris = m[2];
        const int ntris = (int)m[3];
        const float* verts = &polyMesh.verts[bverts * 3];
        const unsigned char* tris = &polyMesh.tris[btris * 4];

        for (int j = 0; j < ntris; ++j)
        {
            const unsigned char* t = &tris[j * 4];
            for (int k = 0, kp = 2; k < 3; kp = k++)
            {
                unsigned char ef = (t[3] >> (kp * 2)) & 0x3;
                if (ef == 0)
                {
                    // Internal edge
                    if (t[kp] < t[k])
                    {
                        const float* vert = &verts[t[kp] * 3];
                        manualObject->position(
                            Ogre::Vector3(vert[0], vert[1], vert[2]));
                        manualObject->colour(lineColor);

                        vert = &verts[t[k]*3];
                        manualObject->position(
                            Ogre::Vector3(vert[0], vert[1], vert[2]));
                        manualObject->colour(lineColor);
                    }
                }
            }
        }
    }

    for (int i = 0; i < polyMesh.nmeshes; ++i)
    {
        const unsigned int* m = &polyMesh.meshes[i * 4];
        const unsigned int bverts = m[0];
        const unsigned int btris = m[2];
        const int ntris = (int)m[3];
        const float* verts = &polyMesh.verts[bverts * 3];
        const unsigned char* tris = &polyMesh.tris[btris * 4];

        for (int j = 0; j < ntris; ++j)
        {
            const unsigned char* t = &tris[j * 4];
            for (int k = 0, kp = 2; k < 3; kp = k++)
            {
                unsigned char ef = (t[3] >> (kp * 2)) & 0x3;
                if (ef != 0)
                {
                    const float* vert = &verts[t[kp] * 3];
                    manualObject->position(
                        Ogre::Vector3(vert[0], vert[1], vert[2]));
                    manualObject->colour(lineColor);

                    vert = &verts[t[k] * 3];
                    manualObject->position(
                        Ogre::Vector3(vert[0], vert[1], vert[2]));
                    manualObject->colour(lineColor);
                }
            }
        }
    }

    manualObject->end();

    return manualObject;
}

dtNavMesh* NavigationUtilities::CreateNavMesh(
    const rcConfig& config,
    rcPolyMesh& polyMesh,
    rcPolyMeshDetail& polyMeshDetail)
{
    dtNavMesh* const navMesh = dtAllocNavMesh();

    dtNavMeshCreateParams params;
    memset(&params, 0, sizeof(params));
    params.verts = polyMesh.verts;
    params.vertCount = polyMesh.nverts;
    params.polys = polyMesh.polys;
    params.polyAreas = polyMesh.areas;
    params.polyFlags = polyMesh.flags;
    params.polyCount = polyMesh.npolys;
    params.nvp = polyMesh.nvp;
    params.detailMeshes = polyMeshDetail.meshes;
    params.detailVerts = polyMeshDetail.verts;
    params.detailVertsCount = polyMeshDetail.nverts;
    params.detailTris = polyMeshDetail.tris;
    params.detailTriCount = polyMeshDetail.ntris;
    params.offMeshConVerts = 0;
    params.offMeshConRad = 0;
    params.offMeshConDir = 0;
    params.offMeshConAreas = 0;
    params.offMeshConFlags = 0;
    params.offMeshConUserID = 0;
    params.offMeshConCount = 0;
    params.walkableHeight = config.walkableHeight * config.ch;
    params.walkableRadius = config.walkableRadius * config.cs;
    params.walkableClimb = config.walkableClimb * config.ch;
    params.bmin[0] = polyMesh.bmin[0];
    params.bmin[1] = polyMesh.bmin[1];
    params.bmin[2] = polyMesh.bmin[2];
    params.bmax[0] = polyMesh.bmax[0];
    params.bmax[1] = polyMesh.bmax[1];
    params.bmax[2] = polyMesh.bmax[2];
    params.cs = config.cs;
    params.ch = config.ch;
    params.buildBvTree = true;

    unsigned char* navData = 0;
    int navDataSize = 0;

    if (!dtCreateNavMeshData(&params, &navData, &navDataSize))
    {
        dtFreeNavMesh(navMesh);
        return NULL;
    }

    dtStatus status;

    status = navMesh->init(navData, navDataSize, DT_TILE_FREE_DATA);

    if (dtStatusFailed(status))
    {
        dtFreeNavMesh(navMesh);
        dtFree(navData);
        return NULL;
    }

    return navMesh;
}

dtNavMeshQuery* NavigationUtilities::CreateNavMeshQuery(
    const dtNavMesh& navMesh)
{
    dtNavMeshQuery* const query = dtAllocNavMeshQuery();

    query->init(&navMesh, 2048);

    return query;
}

rcPolyMesh* NavigationUtilities::CreatePolyMesh(
    rcContext& context,
    const rcConfig& config,
    rcContourSet& contourSet)
{
    rcPolyMesh* const polyMesh = rcAllocPolyMesh();

    rcBuildPolyMesh(&context, contourSet, config.maxVertsPerPoly, *polyMesh);

    for (int index = 0; index < polyMesh->npolys; ++index)
    {
        polyMesh->flags[index] = 1;
    }

    return polyMesh;
}

void NavigationUtilities::CreatePolyMeshes(
    rcConfig& config,
    const std::vector<SandboxObject*>& objects,
    rcPolyMesh*& polyMesh,
    rcPolyMeshDetail*& polyMeshDetail)
{
    rcContext context;

    SetBounds(config, objects);

    rcHeightfield* const heightfield = CreateHeightfield(context, config);

    RasterizeSandboxObjects(context, config, objects, *heightfield);
    FilterWalkableSurfaces(context, config, *heightfield);

    rcCompactHeightfield* const compactHeightfield =
        CreateCompactHeightfield(context, config, *heightfield);

    ErodeWalkableArea(context, config, *compactHeightfield);

    BuildDistanceField(context, config, *compactHeightfield);

    BuildRegions(context, config, *compactHeightfield);

    rcContourSet* const contourSet = CreateContourSet(
        context, config, *compactHeightfield);

    polyMesh = CreatePolyMesh(context, config, *contourSet);

    polyMeshDetail = CreatePolyMeshDetail(
        context, config, *compactHeightfield, *polyMesh);

    DestroyHeightfield(*heightfield);
    DestroyCompactHeightfield(*compactHeightfield);
    DestroyContourSet(*contourSet);
}

rcPolyMeshDetail* NavigationUtilities::CreatePolyMeshDetail(
    rcContext& context,
    const rcConfig& config,
    rcCompactHeightfield& compactHeightfield,
    rcPolyMesh& polyMesh)
{
    rcPolyMeshDetail* const polyMeshDetail = rcAllocPolyMeshDetail();

    rcBuildPolyMeshDetail(
        &context,
        polyMesh,
        compactHeightfield,
        config.detailSampleDist,
        config.detailSampleMaxError,
        *polyMeshDetail);

    return polyMeshDetail;
}

void NavigationUtilities::DefaultConfig(rcConfig& config)
{
    config.cs = 0.1f;
    config.ch = 0.1f;
    config.walkableSlopeAngle = Agent::DEFAULT_AGENT_WALKABLE_SLOPE;
    config.walkableHeight = static_cast<int>(
        ceilf(Agent::DEFAULT_AGENT_HEIGHT / config.ch));
    config.walkableClimb = static_cast<int>(
        floorf(Agent::DEFAULT_AGENT_WALKABLE_CLIMB / config.ch));
    config.walkableRadius = static_cast<int>(
        ceilf(Agent::DEFAULT_AGENT_RADIUS * 1.25f / config.cs));
    config.maxEdgeLen = static_cast<int>(20.0f / config.cs);
    config.maxSimplificationError = 1.0f;
    config.minRegionArea = static_cast<int>(pow(50.0f, 2));
    config.mergeRegionArea = static_cast<int>(pow(100.0f, 2));
    config.maxVertsPerPoly = 3;
    config.detailSampleDist = 5.0f * config.cs;
    config.detailSampleMaxError = 1.0f * config.ch;

    config.bmin[0] = -100.05f;
    config.bmin[1] = -100.05f;
    config.bmin[2] = -100.05f;

    config.bmax[0] = 100.05f;
    config.bmax[1] = 100.05f;
    config.bmax[2] = 100.05f;

    rcCalcGridSize(
        config.bmin, config.bmax, config.cs, &config.width, &config.height);
}

void NavigationUtilities::DestroyCompactHeightfield(
    rcCompactHeightfield& heightfield)
{
    rcFreeCompactHeightfield(&heightfield);
}

void NavigationUtilities::DestroyContourSet(rcContourSet& countourSet)
{
    rcFreeContourSet(&countourSet);
}

void NavigationUtilities::DestroyHeightfield(rcHeightfield& heightfield)
{
    rcFreeHeightField(&heightfield);
}

void NavigationUtilities::DestroyNavMesh(dtNavMesh& navMesh)
{
    dtFreeNavMesh(&navMesh);
}

void NavigationUtilities::DestroyNavMeshQuery(dtNavMeshQuery& navMeshQuery)
{
    dtFreeNavMeshQuery(&navMeshQuery);
}

void NavigationUtilities::DestroyPolyMesh(rcPolyMesh& polyMesh)
{
    rcFreePolyMesh(&polyMesh);
}

void NavigationUtilities::DestroyPolyMeshDetail(
    rcPolyMeshDetail& polyMeshDetail)
{
    rcFreePolyMeshDetail(&polyMeshDetail);
}

void NavigationUtilities::ErodeWalkableArea(
    rcContext& context,
    const rcConfig& config,
    rcCompactHeightfield& heightfield)
{
    rcErodeWalkableArea(&context, config.walkableRadius, heightfield);
}

void NavigationUtilities::FilterWalkableSurfaces(
    rcContext& context,
    const rcConfig& config,
    rcHeightfield& heightfield)
{
    rcFilterLowHangingWalkableObstacles(
        &context, config.walkableClimb, heightfield);
    rcFilterLedgeSpans(
        &context, config.walkableHeight, config.walkableClimb, heightfield);
    rcFilterWalkableLowHeightSpans(
        &context, config.walkableHeight, heightfield);
}

Ogre::Vector3 NavigationUtilities::FindClosestPoint(
    const Ogre::Vector3& point, const dtNavMeshQuery& query)
{
    const float center[3] = { point.x, point.y, point.z };
    const float extents[3] = { 0.5, 2, 0.5 };

    dtQueryFilter filter;

    dtPolyRef poly;
    float nearestPoint[3];

    dtStatus status = query.findNearestPoly(
        center, extents, &filter, &poly, nearestPoint);

    if (dtStatusSucceed(status))
    {
        return Ogre::Vector3(point[0], point[1], point[2]);
    }
    return point;
}

Ogre::Vector3 NavigationUtilities::FindRandomPoint(const dtNavMeshQuery& query)
{
    dtQueryFilter filter;

    dtPolyRef poly;
    float point[3];

    query.findRandomPoint(&filter, navRand, &poly, point);

    return Ogre::Vector3(point[0], point[1], point[2]);
}

void NavigationUtilities::FindStraightPath(
    const Ogre::Vector3& start,
    const Ogre::Vector3& end,
    const dtNavMeshQuery& query,
    std::vector<Ogre::Vector3>& outPath)
{
    dtStatus status;

    const float startPoint[] = { start.x, start.y, start.z };
    const float endPoint[] = { end.x, end.y, end.z };

    dtPolyRef startPoly;
    dtPolyRef endPoly;
    float startPolyPoint[3];
    float endPolyPoint[3];

    const float extents[] = { 2, 5, 2 };

    dtQueryFilter filter;

    outPath.clear();

    status = query.findNearestPoly(
        startPoint, extents, &filter, &startPoly, startPolyPoint);

    if (dtStatusFailed(status))
    {
        return;
    }

    status = query.findNearestPoly(
        endPoint, extents, &filter, &endPoly, endPolyPoint);

    if (dtStatusFailed(status))
    {
        return;
    }

    dtPolyRef path[128];
    int pathCount = 0;

    status = query.findPath(
        startPoly,
        endPoly,
        startPoint,
        endPoint,
        &filter,
        path,
        &pathCount,
        sizeof(path));

    if (dtStatusFailed(status))
    {
        return;
    }

    // No path found.
    if (!pathCount || path[pathCount - 1] != endPoly)
    {
        return;
    }

    const size_t pathLength = 256;
    float straightPath[pathLength * 3];
    int straightPathCount;

    status = query.findStraightPath(
        startPolyPoint,
        endPolyPoint,
        path,
        pathCount,
        straightPath,
        0,
        0,
        &straightPathCount,
        pathLength,
        DT_STRAIGHTPATH_ALL_CROSSINGS);

    if (dtStatusFailed(status))
    {
        return;
    }

    outPath.resize(straightPathCount);

    for (int index = 0; index < straightPathCount; ++index)
    {
        Ogre::Vector3& point = outPath[index];

        point.x = straightPath[index * 3];
        point.y = straightPath[index * 3 + 1];
        point.z = straightPath[index * 3 + 2];
    }
}

rcConfig NavigationUtilities::GetNavigationMeshConfig(
    lua_State* luaVM, int stackIndex)
{
    static const Ogre::String merRegionArea = "MergeRegionArea";
    static const Ogre::String mRegionArea = "MinimumRegionArea";
    static const Ogre::String walkClimb = "WalkableClimbHeight";
    static const Ogre::String walkHeight = "WalkableHeight";
    static const Ogre::String walkRadius = "WalkableRadius";
    static const Ogre::String walkSlope = "WalkableSlopeAngle";

    rcConfig config;

    NavigationUtilities::DefaultConfig(config);

    if (lua_istable(luaVM, stackIndex))
    {
        if (LuaScriptUtilities::HasAttribute(luaVM, stackIndex, walkHeight))
        {
            const Ogre::Real height = LuaScriptUtilities::GetRealAttribute(
                luaVM, walkHeight, stackIndex);

            if (height > 0)
            {
                config.walkableHeight = static_cast<int>(
                    ceilf(height / config.ch));
            }
        }

        if (LuaScriptUtilities::HasAttribute(luaVM, stackIndex, walkRadius))
        {
            const Ogre::Real radius = LuaScriptUtilities::GetRealAttribute(
                luaVM, walkRadius, stackIndex);

            if (radius >= 0)
            {
                config.walkableRadius = static_cast<int>(
                    ceilf(radius / config.cs));
            }
        }

        if (LuaScriptUtilities::HasAttribute(luaVM, stackIndex, walkSlope))
        {
            const Ogre::Real angle = LuaScriptUtilities::GetRealAttribute(
                luaVM, walkSlope, stackIndex);

            if (angle >= 0)
            {
                config.walkableSlopeAngle = angle;
            }
        }

        if (LuaScriptUtilities::HasAttribute(luaVM, stackIndex, walkClimb))
        {
            const Ogre::Real climb = LuaScriptUtilities::GetRealAttribute(
                luaVM, walkClimb, stackIndex);

            if (climb >= 0)
            {
                config.walkableClimb = static_cast<int>(floorf(climb / config.ch));
            }
        }

        if (LuaScriptUtilities::HasAttribute(luaVM, stackIndex, mRegionArea))
        {
            const Ogre::Real minRegionArea = LuaScriptUtilities::GetRealAttribute(
                luaVM, mRegionArea, stackIndex);

            if (minRegionArea >= 0)
            {
                config.minRegionArea = static_cast<int>(pow(minRegionArea, 2));
            }
        }

        if (LuaScriptUtilities::HasAttribute(luaVM, stackIndex, merRegionArea))
        {
            const Ogre::Real mergeRegionArea = LuaScriptUtilities::GetRealAttribute(
                luaVM, merRegionArea, stackIndex);

            if (mergeRegionArea >= 0)
            {
                config.mergeRegionArea = static_cast<int>(pow(mergeRegionArea, 2));
            }
        }
    }

    return config;
}

void NavigationUtilities::RasterizeMesh(
    rcContext& context,
    const rcConfig& config,
    const RawMesh& mesh,
    const MeshMetadata& metadata,
    rcHeightfield& heightfield)
{
    memset(
        metadata.dataBuffer,
        0,
        metadata.dataBufferSize * sizeof(metadata.dataBuffer[0]));

    assert(mesh.indexBufferSize / 3 >= metadata.dataBufferSize);

    rcMarkWalkableTriangles(
        &context,
        config.walkableSlopeAngle,
        mesh.vertexBuffer,
        static_cast<int>(mesh.vertexBufferSize),
        mesh.indexBuffer,
        static_cast<int>(mesh.indexBufferSize / 3),
        metadata.dataBuffer);

    rcRasterizeTriangles(
        &context,
        mesh.vertexBuffer,
        static_cast<int>(mesh.vertexBufferSize),
        mesh.indexBuffer,
        metadata.dataBuffer,
        static_cast<int>(mesh.indexBufferSize / 3),
        heightfield,
        config.walkableClimb);
}

void NavigationUtilities::RasterizeSandboxObjects(
    rcContext& context,
    const rcConfig& config,
    const std::vector<SandboxObject*>& objects,
    rcHeightfield& heightfield)
{
    size_t maxVertexCount = 0;
    size_t maxIndexCount = 0;

    for (std::vector<SandboxObject*>::const_iterator it = objects.begin();
        it != objects.end(); ++it)
    {
        const SandboxObject* const object = *it;

        const Ogre::SceneNode* const node = object->GetSceneNode();

        if (node)
        {
            // Currently only process the first attached mesh.
            const Ogre::Mesh* const mesh = MeshUtilities::GetMesh(*node);

            if (mesh)
            {
                size_t vertexCount;
                size_t indexCount;

                MeshUtilities::GetMeshInformation(
                    *mesh, vertexCount, indexCount);

                if (vertexCount > maxVertexCount)
                {
                    maxVertexCount = vertexCount;
                    maxIndexCount = indexCount;
                }
            }
        }
    }

    if (maxVertexCount == 0 || maxIndexCount == 0)
    {
        return;
    }

    float* const vertexBuffer = new float[maxVertexCount * 3];
    int* const indexBuffer = new int[maxIndexCount];
    assert(!(maxIndexCount % 3));
    unsigned char* const dataBuffer = new unsigned char[maxIndexCount / 3];

    for (std::vector<SandboxObject*>::const_iterator it = objects.begin();
        it != objects.end(); ++it)
    {
        const SandboxObject* const object = *it;

        const Ogre::SceneNode* const node = object->GetSceneNode();

        if (node)
        {
            // Currently only process the first attached mesh.
            const Ogre::Mesh* const mesh = MeshUtilities::GetMesh(*node);

            if (mesh)
            {
                RawMesh rawMesh(
                    vertexBuffer,
                    maxVertexCount * 3,
                    indexBuffer,
                    maxIndexCount,
                    object->GetPosition(),
                    object->GetOrientation());

                MeshUtilities::ConvertToRawMesh(*mesh, rawMesh);

                MeshMetadata metadata(dataBuffer, maxIndexCount / 3);

                RasterizeMesh(context, config, rawMesh, metadata, heightfield);
            }
        }
    }

    delete vertexBuffer;
    delete indexBuffer;
    delete dataBuffer;
}

void NavigationUtilities::SetBounds(
    rcConfig& config,
    const std::vector<SandboxObject*>& objects)
{
    Ogre::Vector3 minimum;
    Ogre::Vector3 maximum;

    for (std::vector<SandboxObject*>::const_iterator it = objects.begin();
        it != objects.end(); ++it)
    {
        Ogre::AxisAlignedBox box = (*it)->GetSceneNode()->_getWorldAABB();

        const Ogre::Vector3& currentMin = box.getMinimum();

        if (currentMin.x < minimum.x)
            minimum.x = currentMin.x;

        if (currentMin.y < minimum.y)
            minimum.y = currentMin.y;

        if (currentMin.z < minimum.z)
            minimum.z = currentMin.z;

        const Ogre::Vector3& currentMax = box.getMaximum();

        if (currentMax.x > maximum.x)
            maximum.x = currentMax.x;

        if (currentMax.y > maximum.y)
            maximum.y = currentMax.y;

        if (currentMax.z > maximum.z)
            maximum.z = currentMax.z;
    }
}