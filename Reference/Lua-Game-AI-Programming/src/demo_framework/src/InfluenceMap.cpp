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
#include "demo_framework/include/InfluenceMapUtilities.h"

InfluenceMap::InfluenceMap(
    const InfluenceMapConfig& config, const Ogre::SceneNode& mesh) {
    grid_ = InfluenceMapUtilities::BuildInfluenceMapGrid(config, mesh);

    memset(inertia_, 0, sizeof(inertia_[0]) * MAX_INFLUENCE_LAYERS);
    memset(falloff_, 0, sizeof(falloff_[0]) * MAX_INFLUENCE_LAYERS);
}

InfluenceMap::~InfluenceMap() {
    delete grid_->cells;
    delete grid_;
}

void InfluenceMap::ClearInfluence(const size_t layer)
{
    if (layer < GetInfluenceLayers())
    {
        for (size_t index = 0; index < grid_->cellCount; ++index)
        {
            grid_->cells[index].values[layer] = 0.0f;
        }
    }
}

const InfluenceMapCell* InfluenceMap::GetCellAt(const size_t index) const
{
    if (index < grid_->cellCount)
    {
        return &grid_->cells[index];
    }

    return NULL;
}

const InfluenceMapCell* InfluenceMap::GetCellAt(
    const Ogre::Vector3& position) const
{
    return InfluenceMapUtilities::GetCell(*grid_, position);
}

size_t InfluenceMap::GetCellCount() const
{
    return grid_->cellCount;
}

float InfluenceMap::GetCellHeight() const
{
    return grid_->cellHeight;
}

float InfluenceMap::GetCellWidth() const
{
    return grid_->cellWidth;
}

float InfluenceMap::GetInfluenceAt(
    const Ogre::Vector3& position, const size_t layer) const
{
    const InfluenceMapCell* const cell = GetCellAt(position);

    if (cell && layer < GetInfluenceLayers())
    {
        return cell->values[layer];
    }

    return 0;
}

size_t InfluenceMap::GetInfluenceLayers() const
{
    return MAX_INFLUENCE_LAYERS;
}

Ogre::Vector3 InfluenceMap::GetMaximumBoundary() const
{
    return Ogre::Vector3(
        grid_->boundaryMax[0],
        grid_->boundaryMax[1],
        grid_->boundaryMax[2]);
}

Ogre::Vector3 InfluenceMap::GetMinimumBoundary() const
{
    return Ogre::Vector3(
        grid_->boundaryMin[0],
        grid_->boundaryMin[1],
        grid_->boundaryMin[2]);
}

size_t InfluenceMap::GetXCellCount() const
{
    return grid_->xCellCount;
}

size_t InfluenceMap::GetYCellCount() const
{
    return grid_->yCellCount;
}

size_t InfluenceMap::GetZCellCount() const
{
    return grid_->zCellCount;
}

void InfluenceMap::SetInfluence(
    const Ogre::Vector3& position,
    const size_t layer,
    const float value)
{
    InfluenceMapCell* const cell =
        InfluenceMapUtilities::GetCell(*grid_, position);

    if (cell && cell->used && layer < GetInfluenceLayers())
    {
       cell->values[layer] = std::max(std::min(value, 1.0f), -1.0f);
    }
}

void InfluenceMap::SpreadInfluence(const size_t layer)
{
    const size_t maxIterations = 20;
    const float minPropagation = 0.01f;

    float currentPropagation = (1.0f - falloff_[layer]);

    for (size_t index = 0; index < maxIterations; ++index)
    {
        InfluenceMapUtilities::UpdateInfluenceGrid(
            *grid_, layer, inertia_[layer], falloff_[layer]);

        currentPropagation *= (1.0f - falloff_[layer]);

        if (currentPropagation <= minPropagation)
        {
            break;
        }
    }
}

void InfluenceMap::SetFalloff(const size_t layer, const float falloff)
{
    falloff_[layer] = InfluenceMapUtilities::ClampFalloff(falloff);
}

void InfluenceMap::SetInertia(const size_t layer, const float inertia)
{
    inertia_[layer] = InfluenceMapUtilities::ClampInertia(inertia);
}