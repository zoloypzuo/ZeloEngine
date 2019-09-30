/**
 * Ogre Wiki Source Code Public Domain (Un)License
 * The source code on the Ogre Wiki is free and unencumbered
 * software released into the public domain.
 *
 * Anyone is free to copy, modify, publish, use, compile, sell, or
 * distribute this software, either in source code form or as a compiled
 * binary, for any purpose, commercial or non-commercial, and by any
 * means.
 *
 * In jurisdictions that recognize copyright laws, the author or authors
 * of this software dedicate any and all copyright interest in the
 * software to the public domain. We make this dedication for the benefit
 * of the public at large and to the detriment of our heirs and
 * successors. We intend this dedication to be an overt act of
 * relinquishment in perpetuity of all present and future rights to this
 * software under copyright law.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
 * OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 *
 * For more information, please refer to http://unlicense.org/
 */

/**
 * The source code in this file is attributed to the Ogre wiki article at
 * http://www.ogre3d.org/tikiwiki/tiki-index.php?page=Skeleton+Debugger&structure=Cookbook
 *
 * The source code from the wiki has been modified and altered.
 */

#include "PrecompiledHeaders.h"

#include "demo_framework/include/SkeletonDebug.h"

Ogre::String SkeletonDebug::axesName = "SkeletonDebug/AxesMesh";
Ogre::String SkeletonDebug::axesMeshName = "SkeletonDebug/AxesMesh";
Ogre::String SkeletonDebug::boneName = "SkeletonDebug/BoneMesh";
Ogre::String SkeletonDebug::boneMeshName = "SkeletonDebug/BoneMesh";

Ogre::MaterialPtr SkeletonDebug::GetAxesMaterial()
{
    Ogre::String matName = "SkeletonDebug/AxesMat";

    Ogre::MaterialPtr mAxisMatPtr =
        Ogre::MaterialManager::getSingleton().getByName(matName);

    if (mAxisMatPtr.isNull())
    {
        mAxisMatPtr = Ogre::MaterialManager::getSingleton().create(
            matName, Ogre::ResourceGroupManager::INTERNAL_RESOURCE_GROUP_NAME);

        // First pass for axes that are partially within the model (shows transparency)
        Ogre::Pass* p = mAxisMatPtr->getTechnique(0)->getPass(0);
        p->setLightingEnabled(false);
        p->setPolygonModeOverrideable(false);
        p->setVertexColourTracking(Ogre::TVC_AMBIENT);
        p->setSceneBlending(Ogre::SBT_TRANSPARENT_ALPHA);
        p->setCullingMode(Ogre::CULL_NONE);
        p->setDepthWriteEnabled(false);
        p->setDepthCheckEnabled(false);

        // Second pass for the portion of the axis that is outside the model (solid colour)
        Ogre::Pass* p2 = mAxisMatPtr->getTechnique(0)->createPass();
        p2->setLightingEnabled(false);
        p2->setPolygonModeOverrideable(false);
        p2->setVertexColourTracking(Ogre::TVC_AMBIENT);
        p2->setCullingMode(Ogre::CULL_NONE);
        p2->setDepthWriteEnabled(false);
    }

    return mAxisMatPtr;
}

Ogre::ResourcePtr SkeletonDebug::GetAxesMesh()
{
    Ogre::ResourcePtr axesMeshPtr =
        Ogre::MeshManager::getSingleton().getByName(axesMeshName);

    if (axesMeshPtr.isNull())
    {
        Ogre::ManualObject mo("tmp");
        mo.begin(GetAxesMaterial()->getName());
        /* 3 axes, each made up of 2 of these (base plane = XY)
        *   .------------|\
        *   '------------|/
        */
        mo.estimateVertexCount(7 * 2 * 3);
        mo.estimateIndexCount(3 * 2 * 3);
        Ogre::Quaternion quat[6];
        Ogre::ColourValue col[3];

        // x-axis
        quat[0] = Ogre::Quaternion::IDENTITY;
        quat[1].FromAxes(Ogre::Vector3::UNIT_X, Ogre::Vector3::NEGATIVE_UNIT_Z, Ogre::Vector3::UNIT_Y);
        col[0] = Ogre::ColourValue::Red;
        col[0].a = 0.3f;
        // y-axis
        quat[2].FromAxes(Ogre::Vector3::UNIT_Y, Ogre::Vector3::NEGATIVE_UNIT_X, Ogre::Vector3::UNIT_Z);
        quat[3].FromAxes(Ogre::Vector3::UNIT_Y, Ogre::Vector3::UNIT_Z, Ogre::Vector3::UNIT_X);
        col[1] = Ogre::ColourValue::Green;
        col[1].a = 0.3f;
        // z-axis
        quat[4].FromAxes(Ogre::Vector3::UNIT_Z, Ogre::Vector3::UNIT_Y, Ogre::Vector3::NEGATIVE_UNIT_X);
        quat[5].FromAxes(Ogre::Vector3::UNIT_Z, Ogre::Vector3::UNIT_X, Ogre::Vector3::UNIT_Y);
        col[2] = Ogre::ColourValue::Blue;
        col[2].a = 0.3f;

        Ogre::Vector3 basepos[7] =
        {
            // stalk
            Ogre::Vector3(0.0f, 0.05f, 0.0f),
            Ogre::Vector3(0.0f, -0.05f, 0.0f),
            Ogre::Vector3(0.7f, -0.05f, 0.0f),
            Ogre::Vector3(0.7f, 0.05f, 0.0f),
            // head
            Ogre::Vector3(0.7f, -0.15f, 0.0f),
            Ogre::Vector3(1.0f, 0.0f, 0.0f),
            Ogre::Vector3(0.7f, 0.15f, 0.0f)
        };

        // vertices
        // 6 arrows
        for (size_t i = 0; i < 6; ++i)
        {
            // 7 points
            for (size_t p = 0; p < 7; ++p)
            {
                Ogre::Vector3 pos = quat[i] * basepos[p];
                mo.position(pos);
                mo.colour(col[i / 2]);
            }
        }

        // indices
        // 6 arrows
        for (size_t i = 0; i < 6; ++i)
        {
            int base = static_cast<int>(i) * 7;
            mo.triangle(base + 0, base + 1, base + 2);
            mo.triangle(base + 0, base + 2, base + 3);
            mo.triangle(base + 4, base + 5, base + 6);
        }

        mo.end();

        axesMeshPtr = mo.convertToMesh(
            axesMeshName, Ogre::ResourceGroupManager::INTERNAL_RESOURCE_GROUP_NAME);
    }

    return axesMeshPtr;
}

Ogre::MaterialPtr SkeletonDebug::GetBoneMaterial()
{
    Ogre::String matName = "SkeletonDebug/BoneMat";

    Ogre::MaterialPtr mBoneMatPtr =
        Ogre::MaterialManager::getSingleton().getByName(matName);
    if (mBoneMatPtr.isNull())
    {
        mBoneMatPtr = Ogre::MaterialManager::getSingleton().create(
            matName, Ogre::ResourceGroupManager::INTERNAL_RESOURCE_GROUP_NAME);

        Ogre::Pass* p = mBoneMatPtr->getTechnique(0)->getPass(0);
        p->setLightingEnabled(false);
        p->setPolygonModeOverrideable(false);
        p->setVertexColourTracking(Ogre::TVC_AMBIENT);
        p->setSceneBlending(Ogre::SBT_TRANSPARENT_ALPHA);
        p->setCullingMode(Ogre::CULL_ANTICLOCKWISE);
        p->setDepthWriteEnabled(false);
        p->setDepthCheckEnabled(false);
    }

    return mBoneMatPtr;
}

Ogre::MeshPtr SkeletonDebug::GetBoneMesh(const Ogre::Real boneSize)
{
    Ogre::MeshPtr boneMeshPtr =
        Ogre::MeshManager::getSingleton().getByName(boneMeshName);

    if(boneMeshPtr.isNull())
    {
        Ogre::ManualObject mo("tmp");
        mo.begin(GetBoneMaterial()->getName());

        Ogre::Vector3 basepos[6] =
        {
            Ogre::Vector3(0,0,0),
            Ogre::Vector3(boneSize, boneSize*2, boneSize),
            Ogre::Vector3(-boneSize, boneSize*2, boneSize),
            Ogre::Vector3(-boneSize, boneSize*2, -boneSize),
            Ogre::Vector3(boneSize, boneSize*2, -boneSize),
            Ogre::Vector3(0, 1.0f, 0),
        };

        // Two colours so that we can distinguish the sides of the bones
        // (we don't use any lighting on the material)
        Ogre::ColourValue col = Ogre::ColourValue(0.7f, 0.7f, 0.7f, 1.0f);
        Ogre::ColourValue col1 = Ogre::ColourValue(0.8f, 0.8f, 0.8f, 1.0f);

        mo.position(basepos[0]);
        mo.colour(col);
        mo.position(basepos[2]);
        mo.colour(col);
        mo.position(basepos[1]);
        mo.colour(col);

        mo.position(basepos[0]);
        mo.colour(col1);
        mo.position(basepos[3]);
        mo.colour(col1);
        mo.position(basepos[2]);
        mo.colour(col1);

        mo.position(basepos[0]);
        mo.colour(col);
        mo.position(basepos[4]);
        mo.colour(col);
        mo.position(basepos[3]);
        mo.colour(col);

        mo.position(basepos[0]);
        mo.colour(col1);
        mo.position(basepos[1]);
        mo.colour(col1);
        mo.position(basepos[4]);
        mo.colour(col1);

        mo.position(basepos[1]);
        mo.colour(col1);
        mo.position(basepos[2]);
        mo.colour(col1);
        mo.position(basepos[5]);
        mo.colour(col1);

        mo.position(basepos[2]);
        mo.colour(col);
        mo.position(basepos[3]);
        mo.colour(col);
        mo.position(basepos[5]);
        mo.colour(col);

        mo.position(basepos[3]);
        mo.colour(col1);
        mo.position(basepos[4]);
        mo.colour(col1);
        mo.position(basepos[5]);
        mo.colour(col1);

        mo.position(basepos[4]);
        mo.colour(col);
        mo.position(basepos[1]);
        mo.colour(col);
        mo.position(basepos[5]);
        mo.colour(col);

        // indices
        mo.triangle(0, 1, 2);
        mo.triangle(3, 4, 5);
        mo.triangle(6, 7, 8);
        mo.triangle(9, 10, 11);
        mo.triangle(12, 13, 14);
        mo.triangle(15, 16, 17);
        mo.triangle(18, 19, 20);
        mo.triangle(21, 22, 23);

        mo.end();

        boneMeshPtr = mo.convertToMesh(
            boneMeshName, Ogre::ResourceGroupManager::INTERNAL_RESOURCE_GROUP_NAME);
    }

    return boneMeshPtr;
}

bool SkeletonDebug::HasSkeletonDebug(Ogre::Entity *entity)
{
    Ogre::Entity::ChildObjectListIterator it =
        entity->getAttachedObjectIterator();

    while (it.hasMoreElements())
    {
        Ogre::Entity* const entity =
            static_cast<Ogre::Entity*>(it.getNext());

        const Ogre::String meshName = entity->getMesh()->getName();

        if (meshName == axesMeshName)
        {
            return true;
        }
        else if (meshName == boneName)
        {
            return true;
        }
    }

    return false;
}

void SkeletonDebug::HideSkeletonDebug(Ogre::Entity *entity)
{
    Ogre::Entity::ChildObjectListIterator it =
        entity->getAttachedObjectIterator();

    while (it.hasMoreElements())
    {
        Ogre::Entity* const entity =
            static_cast<Ogre::Entity*>(it.getNext());

        const Ogre::String meshName = entity->getMesh()->getName();

        if (meshName == axesMeshName)
        {
            entity->setVisible(false);
        }
        else if (meshName == boneName)
        {
            entity->setVisible(false);
        }
    }
}

void SkeletonDebug::SetSkeletonDebug(
    Ogre::Entity* entity,
    Ogre::SceneManager* sceneManager,
    const bool enable,
    Ogre::Real boneSize,
    Ogre::Real axisSize)
{
    if (!HasSkeletonDebug(entity))
    {
        GetAxesMaterial();
        GetBoneMaterial();
        GetAxesMesh();
        GetBoneMesh(boneSize);

        const int numBones = entity->getSkeleton()->getNumBones();

        for(unsigned short int iBone = 0; iBone < numBones; ++iBone)
        {
            Ogre::Bone* pBone = entity->getSkeleton()->getBone(iBone);
            if ( !pBone )
            {
                assert(false);
                continue;
            }

            Ogre::Entity *ent;
            Ogre::TagPoint *tp;

            // Absolutely HAVE to create bone representations first. Otherwise we
            // would get the wrong child count because an attached object counts as
            // a child would be nice to have a function that only gets the children
            // that are bones...
            unsigned short numChildren = pBone->numChildren();
            if (numChildren == 0)
            {
                // There are no children, but we should still represent the bone
                // Creates a bone of length 1 for leaf bones (bones without children)
                ent = sceneManager->createEntity(boneName);
                ent->setCastShadows(false);
                tp = entity->attachObjectToBone(
                    pBone->getName(),
                    (Ogre::MovableObject*)ent,
                    Ogre::Quaternion(Ogre::Degree(270.0f), Ogre::Vector3::UNIT_Z));

                const Ogre::Real modBoneSize =
                    boneSize + boneSize * boneSize * 15.0f;

                tp->setScale(modBoneSize, boneSize, modBoneSize);
            }
            else
            {
                for(unsigned short i = 0; i < numChildren; ++i)
                {
                    if (dynamic_cast<Ogre::Bone*>(pBone->getChild(i)))
                    {
                        Ogre::Vector3 childPosition = pBone->getChild(i)->getPosition();
                        // If the length is zero, no point in creating the bone representation
                        float length = childPosition.length();
                        if(length < 0.00001f)
                            continue;

                        Ogre::Quaternion rotation = Ogre::Vector3::UNIT_Y.getRotationTo(
                            childPosition);

                        ent = sceneManager->createEntity(boneName);
                        ent->setCastShadows(false);
                        tp = entity->attachObjectToBone(
                            pBone->getName(),
                            (Ogre::MovableObject*)ent,
                            rotation);

                        const Ogre::Real modBoneSize =
                            boneSize + boneSize * length * 15.0f;

                        tp->setScale(modBoneSize, length, modBoneSize);
                    }
                }
            }

            ent = sceneManager->createEntity(axesName);
            ent->setCastShadows(false);
            tp = entity->attachObjectToBone(pBone->getName(), (Ogre::MovableObject*)ent);
            // Make sure we don't wind up with tiny/giant axes and that one axis doesnt get squashed
            tp->setScale(
                (axisSize/entity->getParentSceneNode()->getScale().x),
                (axisSize/entity->getParentSceneNode()->getScale().y),
                (axisSize/entity->getParentSceneNode()->getScale().z));
        }
    }

    if (enable)
    {
        ShowSkeletonDebug(entity);
    }
    else
    {
        HideSkeletonDebug(entity);
    }
}

void SkeletonDebug::ShowSkeletonDebug(Ogre::Entity *entity)
{
    Ogre::Entity::ChildObjectListIterator it =
        entity->getAttachedObjectIterator();

    while (it.hasMoreElements())
    {
        Ogre::Entity* const entity =
            static_cast<Ogre::Entity*>(it.getNext());

        const Ogre::String meshName = entity->getMesh()->getName();

        if (meshName == axesMeshName)
        {
            entity->setVisible(true);
        }
        else if (meshName == boneName)
        {
            entity->setVisible(true);
        }
    }
}