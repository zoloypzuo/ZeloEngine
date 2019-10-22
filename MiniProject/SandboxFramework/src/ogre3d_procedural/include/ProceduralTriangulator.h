/*
-----------------------------------------------------------------------------
This source file is part of ogre-procedural

For the latest info, see http://code.google.com/p/ogre-procedural/

Copyright (c) 2010 Michael Broutin

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
-----------------------------------------------------------------------------
*/
#ifndef PROCEDURAL_TRIANGULATOR_INCLUDED
#define PROCEDURAL_TRIANGULATOR_INCLUDED

#include "ProceduralTriangleBuffer.h"
#include "ProceduralShape.h"
#include "OgreVector3.h"
#include "OgreMatrix4.h"
#include "ProceduralUtils.h"
#include "ProceduralMultiShape.h"
#include "ProceduralMeshGenerator.h"

namespace Procedural
{
typedef std::vector<Ogre::Vector2> PointList;

/** Implements a Delaunay Triangulation algorithm.
 * It works on Shapes to build Triangle Buffers
 */
class _ProceduralExport Triangulator : public MeshGenerator<Triangulator>
{	
	struct Triangle;
	struct DelaunaySegment;
	typedef std::list<Triangle> DelaunayTriangleBuffer;	
	
//-----------------------------------------------------------------------
struct DelaunaySegment
{
	int i1, i2;
	DelaunaySegment(int _i1, int _i2) : i1(_i1), i2(_i2) {}
	bool operator<(const DelaunaySegment& other) const
	{
		if (i1!=other.i1)
			return i1<other.i1;
		else
			return i2<other.i2;
	}
	DelaunaySegment inverse()
	{
		return DelaunaySegment(i2, i1);
	}
};	

	//-----------------------------------------------------------------------
struct Triangle
{
	const PointList* pl;
	int i[3];
	Triangle(const PointList* pl)
	{	this->pl = pl;
	}

	inline Ogre::Vector2 p(int k) const
	{
		return (*pl)[i[k]];
	}

	bool operator==(const Triangle& other) const
	{
		return i[0]==other.i[0] && i[1]==other.i[1] && i[2]==other.i[2];
	}

	inline Ogre::Vector2 getMidPoint() const
	{
		return 1.f/3.f * (p(0)+p(1)+p(2));
	}
	
	void setVertices(int i0, int i1, int i2);

	int findSegNumber(int i0, int i1) const;

	bool isPointInside(const Ogre::Vector2& point);
	
	bool containsSegment(int i0, int i1) const
	{		
		return ((i0==i[0] || i0==i[1] || i0==i[2])&&(i1==i[0] || i1==i[1] || i1==i[2]));
	}

	enum InsideType
	{
		IT_INSIDE, IT_OUTSIDE, IT_BORDERLINEOUTSIDE
	};

	InsideType isPointInsideCircumcircle(const Ogre::Vector2& point);

	void makeDirectIfNeeded()
	{
		if ((p(1)-p(0)).crossProduct(p(2)-p(0))<0)
		{
			std::swap(i[0], i[1]);
		}
	}
};
//-----------------------------------------------------------------------
struct TouchSuperTriangle
{
	int i0,i1,i2;
	TouchSuperTriangle(int i, int j, int k) : i0(i), i1(j), i2(k) {}
	bool operator()(const Triangulator::Triangle& tri)
	{
		for (int k=0;k<3;k++) if (tri.i[k]==i0 || tri.i[k]==i1 ||tri.i[k]==i2) return true;
		return false;
	}
};

	Shape* mShapeToTriangulate;
	MultiShape* mMultiShapeToTriangulate;

	void delaunay(PointList& pointList, DelaunayTriangleBuffer& tbuffer) const;
	void addConstraints(const MultiShape& multiShape, DelaunayTriangleBuffer& tbuffer, const PointList& pl) const;
	void _recursiveTriangulatePolygon(const DelaunaySegment& cuttingSeg, std::vector<int> inputPoints, DelaunayTriangleBuffer& tbuffer, const PointList&  pl) const;

public:	

	/// Default ctor
	Triangulator() : mShapeToTriangulate(0), mMultiShapeToTriangulate(0) {}

	/// Sets shape to triangulate
	Triangulator& setShapeToTriangulate(Shape* shape)
	{
		mShapeToTriangulate = shape;
		mMultiShapeToTriangulate = 0;
		return *this;
	}

	/// Sets multi shape to triangulate
	Triangulator& setMultiShapeToTriangulate(MultiShape* multiShape)
	{
		mMultiShapeToTriangulate = multiShape;
		return *this;
	}
	
	/**
	 * Executes the Constrained Delaunay Triangulation algorithm
	 * @arg ouput A vector of index where is outputed the resulting triangle indexes
	 */
	void triangulate(std::vector<int>& output, PointList& outputVertices) const;
	
	/**
	 * Builds the mesh into the given TriangleBuffer
	 * @param buffer The TriangleBuffer on where to append the mesh.
	 */
	void addToTriangleBuffer(TriangleBuffer& buffer) const;
};

}
#endif
