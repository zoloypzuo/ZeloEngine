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

#ifndef DEMO_FRAMEWORK_INFLUENCE_MAP_UTILITIES_H
#define DEMO_FRAMEWORK_INFLUENCE_MAP_UTILITIES_H

struct InfluenceMapConfig;
struct InfluenceMapGrid;

class InfluenceMap;

namespace Ogre
{
    class Mesh;
}

class InfluenceMapUtilities
{
public:
    static InfluenceMapGrid* BuildInfluenceMapGrid(
        const InfluenceMapConfig& config, const Ogre::SceneNode& sceneNode);

    static float ClampFalloff(const float falloff);

    static float ClampInertia(const float inertia);

    static void ClearInfluences(InfluenceMap& influenceMap);

    static InfluenceMapCell* GetCell(
        const InfluenceMapGrid& grid, const Ogre::Vector3& position);

    static bool GetCellIndex(
        const InfluenceMapGrid& grid,
        const Ogre::Vector3& position,
        size_t* const cellIndex);

    static bool GetCellIndexes(
        const InfluenceMapGrid& grid,
        const Ogre::Vector3& position,
        size_t* const xCellIndex,
        size_t* const yCellIndex,
        size_t* const zCellIndex);

    static InfluenceMapConfig GetInfluenceMapConfig(
        lua_State* luaVM, int stackIndex);

    static bool InGridBounds(
        const InfluenceMapGrid& grid, const Ogre::Vector3& position);

    static void SpreadInfluences(InfluenceMap& influenceMap);

    static void UpdateInfluenceGrid(
        InfluenceMapGrid& grid,
        const size_t layer,
        const float inertia,
        const float falloff);

private:
    InfluenceMapUtilities();
    ~InfluenceMapUtilities();
    InfluenceMapUtilities(const InfluenceMapUtilities&);
    InfluenceMapUtilities& operator=(const InfluenceMapUtilities&);
};

#endif  // DEMO_FRAMEWORK_INFLUENCE_MAP_UTILITIES_H
