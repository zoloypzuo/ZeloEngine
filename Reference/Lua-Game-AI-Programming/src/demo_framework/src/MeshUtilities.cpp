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

#include "demo_framework/include/MeshUtilities.h"

RawMesh::RawMesh(
    float* const vertexBuffer,
    const size_t vertexBufferSize,
    int* const indexBuffer,
    const size_t indexBufferSize,
    const Ogre::Vector3& position,
    const Ogre::Quaternion& orientation,
    const Ogre::Vector3& scale)
    : vertexBuffer(vertexBuffer),
    vertexBufferSize(vertexBufferSize),
    vertexCount(0),
    indexBuffer(indexBuffer),
    indexBufferSize(indexBufferSize),
    indexCount(0),
    position(position),
    orientation(orientation),
    scale(scale)
{
    assert(vertexBuffer);
    assert(indexBuffer);
    assert(vertexBufferSize);
    assert(indexBufferSize);
}

RawMesh::RawMesh(const RawMesh& mesh)
    : vertexBuffer(mesh.vertexBuffer),
    vertexBufferSize(mesh.vertexBufferSize),
    vertexCount(mesh.vertexCount),
    indexBuffer(mesh.indexBuffer),
    indexBufferSize(mesh.indexBufferSize),
    indexCount(mesh.indexCount),
    position(mesh.position),
    orientation(mesh.orientation),
    scale(mesh.scale)
{
}

bool MeshUtilities::ConvertToRawMesh(const Ogre::Mesh& mesh, RawMesh& rawMesh)
{
    bool addedShared = false;
    size_t currentOffset = 0;
    size_t sharedOffset = 0;
    size_t nextOffset = 0;
    size_t index_offset = 0;

    size_t vertexCount = 0;
    size_t indexCount = 0;

    GetMeshInformation(mesh, vertexCount, indexCount);

    assert(rawMesh.vertexBufferSize >= (vertexCount * 3));
    assert(rawMesh.indexBufferSize >= indexCount);

    if (rawMesh.vertexBufferSize < vertexCount * 3 ||
        rawMesh.indexBufferSize < indexCount)
    {
        return false;
    }

    for (unsigned short sIndex = 0; sIndex < mesh.getNumSubMeshes(); ++sIndex)
    {
        Ogre::SubMesh* const subMesh = mesh.getSubMesh(sIndex);

        Ogre::RenderOperation renderOperation;
        subMesh->_getRenderOperation(renderOperation);

        // Currently only handle triangle based meshes.
        if (renderOperation.operationType != Ogre::RenderOperation::OT_TRIANGLE_LIST &&
            renderOperation.operationType != Ogre::RenderOperation::OT_TRIANGLE_FAN &&
            renderOperation.operationType != Ogre::RenderOperation::OT_TRIANGLE_STRIP)
        {
            continue;
        }

        Ogre::VertexData* const vertexData = subMesh->useSharedVertices ?
            mesh.sharedVertexData : subMesh->vertexData;

        if ((!subMesh->useSharedVertices) ||
            (subMesh->useSharedVertices && !addedShared))
        {
            if (subMesh->useSharedVertices)
            {
                addedShared = true;
                sharedOffset = currentOffset;
            }

            const Ogre::VertexElement* const positionElement =
                vertexData->vertexDeclaration->findElementBySemantic(
                Ogre::VES_POSITION);

            Ogre::HardwareVertexBufferSharedPtr vertexBuffer =
                vertexData->vertexBufferBinding->getBuffer(
                positionElement->getSource());

            unsigned char* vertex =
                static_cast<unsigned char*>(vertexBuffer->lock(
                    Ogre::HardwareBuffer::HBL_READ_ONLY));

            float* pReal;

            for (size_t vIndex = 0; vIndex < vertexData->vertexCount; ++vIndex)
            {
                positionElement->baseVertexPointerToElement(vertex, &pReal);

                const Ogre::Vector3 point(pReal[0], pReal[1], pReal[2]);
                const Ogre::Vector3 modelPoint =
                    (rawMesh.orientation * (point * rawMesh.scale)) +
                    rawMesh.position;

                const size_t bufferOffset = currentOffset + vIndex * 3;

                rawMesh.vertexBuffer[bufferOffset] = modelPoint.x;
                rawMesh.vertexBuffer[bufferOffset + 1] = modelPoint.y;
                rawMesh.vertexBuffer[bufferOffset + 2] = modelPoint.z;

                vertex += vertexBuffer->getVertexSize();
            }

            vertexBuffer->unlock();
            nextOffset += vertexData->vertexCount;
        }

        Ogre::IndexData* const indexData = subMesh->indexData;
        const size_t numTris = indexData->indexCount / 3;
        Ogre::HardwareIndexBufferSharedPtr ibuf = indexData->indexBuffer;

        const bool use32bitindexes =
            ibuf->getType() == Ogre::HardwareIndexBuffer::IT_32BIT;

        unsigned int* pLong = static_cast<unsigned int*>(
            ibuf->lock(Ogre::HardwareBuffer::HBL_READ_ONLY));
        unsigned short* pShort = reinterpret_cast<unsigned short*>(pLong);

        size_t offset = (subMesh->useSharedVertices) ?
        sharedOffset : currentOffset;

        if (use32bitindexes)
        {
            for (size_t k = 0; k < numTris * 3; ++k)
            {
                rawMesh.indexBuffer[index_offset++] =
                    pLong[k] + static_cast<unsigned int>(offset);
            }
        }
        else
        {
            for (size_t k = 0; k < numTris * 3; ++k)
            {
                rawMesh.indexBuffer[index_offset++] =
                    static_cast<unsigned int>(pShort[k]) +
                    static_cast<unsigned int>(offset);
            }
        }

        ibuf->unlock();
        currentOffset = nextOffset;
    }

    return true;
}

const Ogre::Mesh* MeshUtilities::GetMesh(
    const Ogre::SceneNode& node, const size_t meshIndex)
{
    Ogre::SceneNode::ConstObjectIterator objectIt =
        node.getAttachedObjectIterator();

    size_t index = 0;

    for (; objectIt.hasMoreElements(); objectIt.moveNext())
    {
        const Ogre::MovableObject* const object = objectIt.peekNextValue();

        if (object->getMovableType() == Ogre::EntityFactory::FACTORY_TYPE_NAME)
        {
            if (index == meshIndex)
            {
                return static_cast<const Ogre::Entity*>(
                    object)->getMesh().getPointer();
            }

            ++index;
        }
    }

    return NULL;
}

void MeshUtilities::GetMeshInformation(
    const Ogre::Mesh& mesh, size_t& vertexCount, size_t& indexCount)
{
    vertexCount = 0;
    indexCount = 0;

    bool added_shared = false;

    for (unsigned short index = 0; index < mesh.getNumSubMeshes(); ++index)
    {
        Ogre::SubMesh* const submesh = mesh.getSubMesh(index);

        // We only need to add the shared vertices once
        if (submesh->useSharedVertices && !added_shared)
        {
            vertexCount += mesh.sharedVertexData->vertexCount;
            added_shared = true;
        }
        else
        {
            vertexCount += submesh->vertexData->vertexCount;
        }

        indexCount += submesh->indexData->indexCount;
    }
}
