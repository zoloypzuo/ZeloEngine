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

#ifndef DEMO_FRAMEWORK_INFLUENCE_MAP_H
#define DEMO_FRAMEWORK_INFLUENCE_MAP_H

#define MAX_INFLUENCE_LAYERS 10

struct InfluenceMapValueToCell;

namespace Ogre
{
class Vector3;
}

struct InfluenceMapConfig
{
    float cellHeight;

    float cellWidth;

    float boundaryMin[3];

    float boundaryMax[3];
};

struct InfluenceMapCell
{
    float values[MAX_INFLUENCE_LAYERS];

    float buffer;

    InfluenceMapValueToCell* valueToCells;

    bool used;
};

struct InfluenceMapValueToCell
{
    float value;

    size_t toCellIndex;
};

struct InfluenceMapGrid
{
    // Stores the three dimensional cells that can make up the influence map grid.
    // To find the correct index:
    // xIndex + yIndex * xCellCount + zIndex * xCellCount * yCellCount
    InfluenceMapCell* cells;

    size_t cellCount;

    size_t xCellCount;

    size_t yCellCount;

    size_t zCellCount;

    float cellHeight;

    float cellWidth;

    float boundaryMin[3];

    float boundaryMax[3];
};

class InfluenceMap
{
public:
    InfluenceMap(
        const InfluenceMapConfig& config, const Ogre::SceneNode& mesh);

    ~InfluenceMap();

    void ClearInfluence(const size_t layer);

    const InfluenceMapCell* GetCellAt(const size_t index) const;

    const InfluenceMapCell* GetCellAt(const Ogre::Vector3& position) const;

    size_t GetCellCount() const;

    float GetCellHeight() const;

    float GetCellWidth() const;

    float GetInfluenceAt(
        const Ogre::Vector3& position, const size_t layer) const;

    size_t GetInfluenceLayers() const;

    Ogre::Vector3 GetMaximumBoundary() const;

    Ogre::Vector3 GetMinimumBoundary() const;

    size_t GetXCellCount() const;

    size_t GetYCellCount() const;

    size_t GetZCellCount() const;

    void SetFalloff(const size_t layer, const float falloff);

    void SetInertia(const size_t layer, const float inertia);

    void SetInfluence(
        const Ogre::Vector3& position,
        const size_t layer,
        const float value);

    void SpreadInfluence(const size_t layer);

private:
    InfluenceMapGrid* grid_;

    // Value between 0 and 1.
    float inertia_[MAX_INFLUENCE_LAYERS];

    // Value between 0 and 1.
    float falloff_[MAX_INFLUENCE_LAYERS];

    InfluenceMap(const InfluenceMap&);

    InfluenceMap operator=(const InfluenceMap&);
};

#endif  // DEMO_FRAMEWORK_INFLUENCE_MAP_H
