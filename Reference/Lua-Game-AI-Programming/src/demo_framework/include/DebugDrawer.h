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
 * http://www.ogre3d.org/tikiwiki/tiki-index.php?page=Debug+Drawing+Utility+Class
 */
#ifndef DEMO_FRAMEWORK_DEBUG_DRAWER_H
#define DEMO_FRAMEWORK_DEBUG_DRAWER_H

#include <map>

#include "ogre3d/include/OgreSingleton.h"

typedef std::pair<Ogre::Vector3, Ogre::ColourValue> VertexPair;

#define DEFAULT_ICOSPHERE_RECURSION_LEVEL	1

class IcoSphere
{
public:
    struct TriangleIndices
    {
        int v1, v2, v3;

        TriangleIndices(int _v1, int _v2, int _v3) : v1(_v1), v2(_v2), v3(_v3) {}

        bool operator < (const TriangleIndices &o) const { return v1 < o.v1 && v2 < o.v2 && v3 < o.v3; }
    };

    struct LineIndices
    {
        int v1, v2;

        LineIndices(int _v1, int _v2) : v1(_v1), v2(_v2) {}

        bool operator == (const LineIndices &o) const
        {
            return (v1 == o.v1 && v2 == o.v2) || (v1 == o.v2 && v2 == o.v1);
        }
    };

    IcoSphere();
    ~IcoSphere();

    void create(int recursionLevel);
    void addToLineIndices(int baseIndex, std::vector<int> *target);
    int addToVertices(std::vector<VertexPair> *target, const Ogre::Vector3 &position, const Ogre::ColourValue &colour, float scale);
    void addToTriangleIndices(int baseIndex, std::vector<int> *target);

private:
    int addVertex(const Ogre::Vector3 &vertex);
    void addLineIndices(int index0, int index1);
    void addTriangleLines(int index0, int index1, int index2);
    int getMiddlePoint(int index0, int index1);
    void addFace(int index0, int index1, int index2);

    void removeLineIndices(int index0, int index1);

    std::vector<Ogre::Vector3> vertices;
    std::vector<LineIndices> lineIndices;
    std::vector<int> triangleIndices;
    std::vector<TriangleIndices> faces;
    std::map<__int64, int> middlePointIndexCache;
    int index;
};

class DebugDrawer : public Ogre::Singleton<DebugDrawer>
{
public:
    DebugDrawer(Ogre::SceneManager *_sceneManager, float _fillAlpha);
    ~DebugDrawer();

    static DebugDrawer& getSingleton(void);
    static DebugDrawer* getSingletonPtr(void);

    void build();

    void setIcoSphereRecursionLevel(int recursionLevel);

    void drawLine(const Ogre::Vector3 &start, const Ogre::Vector3 &end, const Ogre::ColourValue &colour);
    void drawCircle(const Ogre::Vector3 &centre, float radius, int segmentsCount, const Ogre::ColourValue& colour, bool isFilled = false);
    void drawCylinder(const Ogre::Vector3 &centre, float radius, int segmentsCount, float height, const Ogre::ColourValue& colour, bool isFilled = false);
    void drawTriangle(const Ogre::Vector3 *vertices, const Ogre::ColourValue& colour, bool isFilled = false);
    void drawQuad(const Ogre::Vector3 *vertices, const Ogre::ColourValue& colour, bool isFilled = false);
    void drawCuboid(const Ogre::Vector3 *vertices, const Ogre::ColourValue& colour, bool isFilled = false);
    void drawSphere(const Ogre::Vector3 &centre, float radius, const Ogre::ColourValue& colour, bool isFilled = false);
    void drawTetrahedron(const Ogre::Vector3 &centre, float scale, const Ogre::ColourValue& colour, bool isFilled = false);

    bool getEnabled() { return isEnabled; }
    void setEnabled(bool _isEnabled) { isEnabled = _isEnabled; }
    void switchEnabled() { isEnabled = !isEnabled; }

    void clear();

private:

    Ogre::SceneManager *sceneManager;
    Ogre::ManualObject *manualObject_;
    Ogre::SceneNode* manualObjectNode;
    float fillAlpha;
    IcoSphere icoSphere;

    bool isEnabled;

   std::vector<VertexPair> lineVertices;
   std::vector<int> lineIndices;

   std::vector<VertexPair> triangleVertices;
   std::vector<int> triangleIndices;

    int linesIndex, trianglesIndex;

    void initialise();
    void shutdown();

    void buildLine(const Ogre::Vector3& start, const Ogre::Vector3& end, const Ogre::ColourValue& colour, float alpha = 1.0f);
    void buildQuad(const Ogre::Vector3 *vertices, const Ogre::ColourValue& colour, float alpha = 1.0f);
    void buildFilledQuad(const Ogre::Vector3 *vertices, const Ogre::ColourValue& colour, float alpha = 1.0f);
    void buildTriangle(const Ogre::Vector3 *vertices, const Ogre::ColourValue& colour, float alpha = 1.0f);
    void buildFilledTriangle(const Ogre::Vector3 *vertices, const Ogre::ColourValue& colour, float alpha = 1.0f);
    void buildCuboid(const Ogre::Vector3 *vertices, const Ogre::ColourValue& colour, float alpha = 1.0f);
    void buildFilledCuboid(const Ogre::Vector3 *vertices, const Ogre::ColourValue& colour, float alpha = 1.0f);

    void buildCircle(const Ogre::Vector3 &centre, float radius, int segmentsCount, const Ogre::ColourValue& colour, float alpha = 1.0f);
    void buildFilledCircle(const Ogre::Vector3 &centre, float radius, int segmentsCount, const Ogre::ColourValue& colour, float alpha = 1.0f);

    void buildCylinder(const Ogre::Vector3 &centre, float radius, int segmentsCount, float height, const Ogre::ColourValue& colour, float alpha = 1.0f);
    void buildFilledCylinder(const Ogre::Vector3 &centre, float radius, int segmentsCount, float height, const Ogre::ColourValue& colour, float alpha = 1.0f);

    void buildTetrahedron(const Ogre::Vector3 &centre, float scale, const Ogre::ColourValue &colour, float alpha = 1.0f);
    void buildFilledTetrahedron(const Ogre::Vector3 &centre, float scale, const Ogre::ColourValue &colour, float alpha = 1.0f);

    int addLineVertex(const Ogre::Vector3 &vertex, const Ogre::ColourValue &colour);
    void addLineIndices(const int index1, const int index2);

    int addTriangleVertex(const Ogre::Vector3 &vertex, const Ogre::ColourValue &colour);
    void addTriangleIndices(int index1, int index2, int index3);

    void addQuadIndices(int index1, int index2, int index3, int index4);
};

#endif  // DEMO_FRAMEWORK_DEBUG_DRAWER_H
