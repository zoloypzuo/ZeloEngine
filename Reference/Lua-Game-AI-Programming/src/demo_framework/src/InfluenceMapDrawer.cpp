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

#include "demo_framework/include/InfluenceMap.h"
#include "demo_framework/include/InfluenceMapDrawer.h"

inline static float interpolate(
    const float to, const float from, const float percent)
{
    return to * percent + from * (1.0f - percent);
}

static void BuildCellLines(
    Ogre::ManualObject& manualObject,
    const float cellWidth,
    const float cellHeight,
    const Ogre::Vector3& minBoundary,
    const Ogre::ColourValue& color,
    const size_t xOffset,
    const size_t yOffset,
    const size_t zOffset)
{
    const unsigned int vertexCount =
        static_cast<unsigned int>(manualObject.getCurrentVertexCount());

    const Ogre::Vector3 offset = minBoundary +
        Ogre::Vector3(
        xOffset * cellWidth, yOffset * cellHeight, zOffset * cellWidth);

    manualObject.position(offset);
    manualObject.colour(color);

    manualObject.position(offset + Ogre::Vector3(cellWidth, 0, 0));
    manualObject.colour(color);

    manualObject.position(offset + Ogre::Vector3(0, 0, cellWidth));
    manualObject.colour(color);

    manualObject.position(offset + Ogre::Vector3(cellWidth, 0, cellWidth));
    manualObject.colour(color);

    manualObject.index(vertexCount);
    manualObject.index(vertexCount + 1);

    manualObject.index(vertexCount);
    manualObject.index(vertexCount + 2);

    manualObject.index(vertexCount + 2);
    manualObject.index(vertexCount + 3);

    manualObject.index(vertexCount + 1);
    manualObject.index(vertexCount + 3);
}

static void BuildCellTriangles(
    Ogre::ManualObject& manualObject,
    const float cellWidth,
    const float cellHeight,
    const Ogre::Vector3& minBoundary,
    const Ogre::ColourValue& color,
    const size_t xOffset,
    const size_t yOffset,
    const size_t zOffset)
{
    const unsigned int vertexCount =
        static_cast<unsigned int>(manualObject.getCurrentVertexCount());

    const Ogre::Vector3 offset = minBoundary +
        Ogre::Vector3(
            xOffset * cellWidth, yOffset * cellHeight, zOffset * cellWidth);

    manualObject.position(offset);
    manualObject.colour(color);

    manualObject.position(offset + Ogre::Vector3(cellWidth, 0, 0));
    manualObject.colour(color);

    manualObject.position(offset + Ogre::Vector3(0, 0, cellWidth));
    manualObject.colour(color);

    manualObject.position(offset + Ogre::Vector3(cellWidth, 0, cellWidth));
    manualObject.colour(color);

    manualObject.index(vertexCount);
    manualObject.index(vertexCount + 2);
    manualObject.index(vertexCount + 1);

    manualObject.index(vertexCount + 1);
    manualObject.index(vertexCount + 2);
    manualObject.index(vertexCount + 3);
}

InfluenceMapDrawer::InfluenceMapDrawer(Ogre::SceneManager& sceneManager)
{
    manualObject_ = sceneManager.createManualObject();
    manualObjectNode =
        sceneManager.getRootSceneNode()->createChildSceneNode();
    manualObjectNode->attachObject(manualObject_);
    manualObject_->setDynamic(true);

    manualObject_->begin("debug_draw", Ogre::RenderOperation::OT_LINE_LIST);
    manualObject_->position(Ogre::Vector3::ZERO);
    manualObject_->colour(Ogre::ColourValue::ZERO);
    manualObject_->index(0);
    manualObject_->end();
    manualObject_->begin("debug_draw", Ogre::RenderOperation::OT_TRIANGLE_LIST);
    manualObject_->position(Ogre::Vector3::ZERO);
    manualObject_->colour(Ogre::ColourValue::ZERO);
    manualObject_->index(0);
    manualObject_->end();

    manualObject_->setBoundingBox(Ogre::AxisAlignedBox::BOX_INFINITE);
    manualObjectNode->_updateBounds();
}

InfluenceMapDrawer::~InfluenceMapDrawer()
{
    Ogre::SceneManager* const sceneManager = manualObjectNode->getCreator();

    sceneManager->destroyManualObject(manualObject_);
    sceneManager->destroySceneNode(manualObjectNode);
}

void InfluenceMapDrawer::DrawInfluenceMap(
    const InfluenceMap& map,
    const size_t layer,
    const Ogre::ColourValue& positiveValue,
    const Ogre::ColourValue& zeroValue,
    const Ogre::ColourValue& negativeValue)
{
    const size_t cellCount = map.GetCellCount();

    size_t xCell = 0;
    size_t yCell = 0;
    size_t zCell = 0;

    const size_t xCellCount = map.GetXCellCount();
    const size_t yCellCount = map.GetYCellCount();

    if (layer >= map.GetInfluenceLayers())
    {
        return;
    }

    manualObject_->beginUpdate(0);

    const InfluenceMapCell* cell;

    Ogre::ColourValue color;

    for (size_t index = 0; index < cellCount; ++index)
    {
        cell = map.GetCellAt(index);

        if (cell->used)
        {
            /*
            if (cell->values[layer] > 0)
            {
                color.r = interpolate(
                    positiveValue.r, zeroValue.r, cell->values[layer]) * 0.5f;
                color.g = interpolate(
                    positiveValue.g, zeroValue.g, cell->values[layer]) * 0.5f;
                color.b = interpolate(
                    positiveValue.b, zeroValue.b, cell->values[layer]) * 0.5f;
                color.a = interpolate(
                    positiveValue.a, zeroValue.a, cell->values[layer]) * 0.5f;
            }
            else
            {
                color.r = interpolate(
                    negativeValue.r, zeroValue.r, abs(cell->values[layer])) * 0.5f;
                color.g = interpolate(
                    negativeValue.g, zeroValue.g, abs(cell->values[layer])) * 0.5f;
                color.b = interpolate(
                    negativeValue.b, zeroValue.b, abs(cell->values[layer])) * 0.5f;
                color.a = interpolate(
                    negativeValue.a, zeroValue.a, abs(cell->values[layer])) * 0.5f;
            }
            */

            color = Ogre::ColourValue(0, 0, 0, 0.5f);

            BuildCellLines(
                *manualObject_,
                map.GetCellWidth(),
                map.GetCellHeight(),
                map.GetMinimumBoundary(),
                color,
                xCell,
                yCell,
                zCell);
        }

        xCell += 1;
        yCell += (xCell >= xCellCount) ? 1 : 0;
        zCell += (yCell >= yCellCount) ? 1 : 0;

        xCell %= xCellCount;
        yCell %= yCellCount;
    }

    manualObject_->end();

    xCell = 0;
    yCell = 0;
    zCell = 0;

    manualObject_->beginUpdate(1);

    for (size_t index = 0; index < cellCount; ++index)
    {
        cell = map.GetCellAt(index);

        if (cell->used)
        {
            if (cell->values[layer] > 0)
            {
                color.r = interpolate(
                    positiveValue.r, zeroValue.r, cell->values[layer]);
                color.g = interpolate(
                    positiveValue.g, zeroValue.g, cell->values[layer]);
                color.b = interpolate(
                    positiveValue.b, zeroValue.b, cell->values[layer]);
                color.a = interpolate(
                    positiveValue.a, zeroValue.a, cell->values[layer]);
            }
            else
            {
                color.r = interpolate(
                    negativeValue.r, zeroValue.r, abs(cell->values[layer]));
                color.g = interpolate(
                    negativeValue.g, zeroValue.g, abs(cell->values[layer]));
                color.b = interpolate(
                    negativeValue.b, zeroValue.b, abs(cell->values[layer]));
                color.a = interpolate(
                    negativeValue.a, zeroValue.a, abs(cell->values[layer]));
            }

            BuildCellTriangles(
                *manualObject_,
                map.GetCellWidth(),
                map.GetCellHeight(),
                map.GetMinimumBoundary(),
                color,
                xCell,
                yCell,
                zCell);
        }

        xCell += 1;
        yCell += (xCell >= xCellCount) ? 1 : 0;
        zCell += (yCell >= yCellCount) ? 1 : 0;

        xCell %= xCellCount;
        yCell %= yCellCount;
    }

    manualObject_->end();
    manualObjectNode->_updateBounds();
}

void InfluenceMapDrawer::SetVisible(const bool visible)
{
    manualObjectNode->setVisible(visible);
}