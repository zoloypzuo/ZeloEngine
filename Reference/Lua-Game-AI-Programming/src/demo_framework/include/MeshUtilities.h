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

#ifndef DEMO_FRAMEWORK_MESH_UTILITIES_H
#define DEMO_FRAMEWORK_MESH_UTILITIES_H

#include <stddef.h>

namespace Ogre
{
class Mesh;
class SceneNode;
}

struct RawMesh
{
    float* const vertexBuffer;
    const size_t vertexBufferSize;
    size_t vertexCount;

    int* const indexBuffer;
    const size_t indexBufferSize;
    size_t indexCount;

    const Ogre::Vector3& position;
    const Ogre::Quaternion& orientation;
    const Ogre::Vector3& scale;

    RawMesh(
        float* const vertexBuffer,
        const size_t vertexBufferSize,
        int* const indexBuffer,
        const size_t indexBufferSize,
        const Ogre::Vector3& position = Ogre::Vector3::ZERO,
        const Ogre::Quaternion& orientation = Ogre::Quaternion::IDENTITY,
        const Ogre::Vector3& scale = Ogre::Vector3::UNIT_SCALE);

    RawMesh(const RawMesh& mesh);

private:
    RawMesh& operator=(const RawMesh& mesh);
};

class MeshUtilities
{
public:
    static bool ConvertToRawMesh(
        const Ogre::Mesh& mesh, RawMesh& rawMesh);

    static const Ogre::Mesh* GetMesh(
        const Ogre::SceneNode& node, const size_t meshIndex = 0);

    static void GetMeshInformation(
        const Ogre::Mesh& mesh, size_t& vertexCount, size_t& indexCount);

private:
    MeshUtilities();
    MeshUtilities(const MeshUtilities&);
    ~MeshUtilities();
    MeshUtilities& operator=(const MeshUtilities&);
};

#endif  // DEMO_FRAMEWORK_MESH_UTILITIES_H