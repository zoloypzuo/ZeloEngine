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
#include "ProceduralStableHeaders.h"
#include "ProceduralTriangulator.h"
#include "ProceduralGeometryHelpers.h"

using namespace Ogre;

namespace Procedural
{
//-----------------------------------------------------------------------
void Triangulator::Triangle::setVertices(int i0, int i1, int i2)
{
	i[0] = i0;
	i[1] = i1;
	i[2] = i2;
}
//-----------------------------------------------------------------------
int Triangulator::Triangle::findSegNumber(int i0, int i1) const
	{
		if ((i0==i[0] && i1==i[1])||(i0==i[1] && i1==i[0]))
			return 2;
		if ((i0==i[1] && i1==i[2])||(i0==i[2] && i1==i[1]))
			return 0;
		if ((i0==i[2] && i1==i[0])||(i0==i[0] && i1==i[2]))
			return 1;
		throw std::runtime_error("we should not be here!");
	}
//-----------------------------------------------------------------------
bool Triangulator::Triangle::isPointInside(const Vector2& point)
	{
		// Compute vectors
		Vector2 v0 = p(2) - p(0);
		Vector2 v1 = p(1) - p(0);
		Vector2 v2 = point - p(0);

		// Compute dot products
		Real dot00 = v0.squaredLength();
		Real dot01 = v0.dotProduct(v1);
		Real dot02 = v0.dotProduct(v2);
		Real dot11 = v1.squaredLength();
		Real dot12 = v1.dotProduct(v2);

		// Compute barycentric coordinates
		Real invDenom = 1 / (dot00 * dot11 - dot01 * dot01);
		Real u = (dot11 * dot02 - dot01 * dot12) * invDenom;
		Real v = (dot00 * dot12 - dot01 * dot02) * invDenom;

		// Check if point is in triangle
		return (u >= 0) && (v >= 0) && (u + v - 1 <= 0);
	}
//-----------------------------------------------------------------------
Triangulator::Triangle::InsideType Triangulator::Triangle::isPointInsideCircumcircle(const Vector2& pt)
{
	Vector2 v0=p(0);
	Vector2 v1=p(1);
	Vector2 v2=p(2);
	Matrix4 m (v0.x, v0.y, v0.squaredLength(), 1.,
		       v1.x, v1.y, v1.squaredLength(), 1.,
			   v2.x, v2.y, v2.squaredLength(), 1.,
			   pt.x, pt.y, pt.squaredLength(), 1.);
	Real det = m.determinant();
	if (det>=0)
		return IT_INSIDE;
	if (det>-1e-3)
		return IT_BORDERLINEOUTSIDE;
	return IT_OUTSIDE;
}
//-----------------------------------------------------------------------
// Triangulation by insertion
void Triangulator::delaunay(PointList& pointList, DelaunayTriangleBuffer& tbuffer) const
{
	// Compute super triangle
	float maxTriangleSize = 0.f;
	for (PointList::iterator it = pointList.begin(); it!=pointList.end();it++)
	{
		maxTriangleSize = std::max<float>(maxTriangleSize,Math::Abs(it->x));
		maxTriangleSize = std::max<float>(maxTriangleSize,Math::Abs(it->y));
	}
	int maxTriangleIndex=pointList.size();
	pointList.push_back(Vector2(-3*maxTriangleSize,-3*maxTriangleSize));
	pointList.push_back(Vector2(3*maxTriangleSize,-3*maxTriangleSize));
	pointList.push_back(Vector2(0.,3*maxTriangleSize));
	Triangle superTriangle(&pointList);
	superTriangle.i[0]= maxTriangleIndex;
	superTriangle.i[1]= maxTriangleIndex+1;
	superTriangle.i[2]= maxTriangleIndex+2;
	tbuffer.push_back(superTriangle);

	// Point insertion loop
	for (unsigned short i=0;i<pointList.size()-3;i++)
	{
		std::list<std::list<Triangle>::iterator> borderlineTriangles;
		// Insert 1 point, find all triangles for which the point is in circumcircle
		Vector2& p = pointList[i];
		std::set<DelaunaySegment> segments;
		for (DelaunayTriangleBuffer::iterator it = tbuffer.begin(); it!=tbuffer.end();)
		{
			Triangle::InsideType isInside = it->isPointInsideCircumcircle(p);
			if (isInside == Triangle::IT_INSIDE)
			{
				for (int k=0;k<3;k++)
				{
					DelaunaySegment d1(it->i[k], it->i[(k+1)%3]);
					if (segments.find(d1)!=segments.end())
						segments.erase(d1);
					else if (segments.find(d1.inverse())!=segments.end())
						segments.erase(d1.inverse());
					else
						segments.insert(d1);
				}
				it=tbuffer.erase(it);
			}
			else if (isInside == Triangle::IT_BORDERLINEOUTSIDE)
			{
				borderlineTriangles.push_back(it);
				it++;
			}
			else
			{
				it++;
			}
		}

		// Robustification of the standard algorithm : if one triangle's circumcircle was borderline against the new point,
		// test whether that triangle is intersected by new segments or not (normal situation : it should not)
		// If intersected, the triangle is considered having the new point in its circumc
		std::set<DelaunaySegment> copySegment = segments;
		for (std::list<std::list<Triangle>::iterator>::iterator itpTri = borderlineTriangles.begin(); itpTri!=borderlineTriangles.end();itpTri++ ) {
			DelaunayTriangleBuffer::iterator itTri = *itpTri;
			bool triRemoved = false;
			for (std::set<DelaunaySegment>::iterator it = copySegment.begin(); it!=copySegment.end() && !triRemoved;it++)
			{
			bool isTriangleIntersected = false;
			for (int k=0;k<2;k++)
			{
			int i1 = (k==0)?it->i1:it->i2;
			int i2 = i;
			for (int l=0;l<3;l++)
			{
				//Early out if 2 points are in fact the same
				if (itTri->i[l]==i1 || itTri->i[l]==i2 || itTri->i[(l+1)%3]==i1 || itTri->i[(l+1)%3]==i2)
					continue;
				Segment2D seg2(itTri->p(l), itTri->p((l+1)%3));
				Segment2D seg1(pointList[i1], pointList[i2]);
				if (seg1.intersects(seg2))
				{
					isTriangleIntersected = true;
					break;
				}
			}

				}
			if (isTriangleIntersected) {
				for (int m=0;m<3;m++)
				{
					DelaunaySegment d1(itTri->i[m], itTri->i[(m+1)%3]);
					if (segments.find(d1)!=segments.end())
						segments.erase(d1);
					else if (segments.find(d1.inverse())!=segments.end())
						segments.erase(d1.inverse());
					else
						segments.insert(d1);
				}
				tbuffer.erase(itTri);
				triRemoved=true;
			}
			}
		}

		// Find all the non-interior edges
		for (std::set<DelaunaySegment>::iterator it = segments.begin(); it!=segments.end();it++)
		{
			Triangle dt(&pointList);
			dt.setVertices(it->i1, it->i2, i);
			dt.makeDirectIfNeeded();
			tbuffer.push_back(dt);

		}
	}

	// NB : Don't remove super triangle here, because all outer triangles are already removed in the addconstraints method.
	//      Uncomment that code if delaunay triangulation ever has to be unconstrained...
	/*TouchSuperTriangle touchSuperTriangle(maxTriangleIndex, maxTriangleIndex+1,maxTriangleIndex+2);
	tbuffer.remove_if(touchSuperTriangle);
	pointList.pop_back();
	pointList.pop_back();
	pointList.pop_back();*/
}
//-----------------------------------------------------------------------
void Triangulator::addConstraints(const MultiShape& multiShape, DelaunayTriangleBuffer& tbuffer, const PointList& pl) const
{
	std::vector<DelaunaySegment> segList;
	size_t shapeOffset = 0;
	// First, list all the segments that are not already in one of the delaunay triangles
	for (size_t k=0;k<multiShape.getShapeCount();k++)
	{
		const Shape& shape = multiShape.getShape(k);
		// Determine which segments should be added
		for (size_t i = 0; i<shape.getPoints().size()-1; i++)
		{
			bool isAlreadyIn = false;
			for (DelaunayTriangleBuffer::iterator it = tbuffer.begin(); it!=tbuffer.end();it++)
			{
				if (it->containsSegment(shapeOffset+i,shapeOffset+i+1))
				{
					isAlreadyIn = true;
					break;
				}
			}
			// only do something for segments not already in DT
			if (!isAlreadyIn)
			{
				segList.push_back(DelaunaySegment(shapeOffset+i, shapeOffset+i+1));
			}
		}
		shapeOffset+=shape.getPoints().size();
	}

	// Re-Triangulate according to the new segments
	for (std::vector<DelaunaySegment>::iterator itSeg=segList.begin();itSeg!=segList.end();itSeg++)
	{
		// Remove all triangles intersecting the segment and keep a list of outside edges
		std::set<DelaunaySegment> segments;
		Segment2D seg1(pl[itSeg->i1], pl[itSeg->i2]);
		for (DelaunayTriangleBuffer::iterator itTri = tbuffer.begin(); itTri!=tbuffer.end(); )
		{
			bool isTriangleIntersected = false;
			for (int i=0;i<3;i++)
			{
				//Early out if 2 points are in fact the same
				if (itTri->i[i]==itSeg->i1 || itTri->i[i]==itSeg->i2 || itTri->i[(i+1)%3]==itSeg->i1 || itTri->i[(i+1)%3]==itSeg->i2)
					continue;
				Segment2D seg2(itTri->p(i), itTri->p((i+1)%3));
				if (seg1.intersects(seg2))
				{
					isTriangleIntersected = true;
					break;
				}
			}
			if (isTriangleIntersected)
			{
				for (int k=0;k<3;k++)
				{
					DelaunaySegment d1(itTri->i[k], itTri->i[(k+1)%3]);
					if (segments.find(d1)!=segments.end())
						segments.erase(d1);
					else if (segments.find(d1.inverse())!=segments.end())
						segments.erase(d1.inverse());
					else
						segments.insert(d1);
				}
				itTri=tbuffer.erase(itTri);
			}
			else
				itTri++;
		}

		// Divide the list of points (coming from remaining segments) in 2 groups : "above" and "below"
		std::vector<int> pointsAbove;
		std::vector<int> pointsBelow;
		int pt = itSeg->i1;
		bool isAbove= true;
		while (segments.size()>0)
		{
		//find next point
		for (std::set<DelaunaySegment>::iterator it = segments.begin(); it!=segments.end();it++)
		{
			if (it->i1==pt || it->i2==pt)
			{
				if (it->i1==pt)
					pt = it->i2;
				else
					pt = it->i1;
				segments.erase(it);
				if (pt==itSeg->i2)
					isAbove=false;
				else if (pt!=itSeg->i1)
				{
					if (isAbove)
						pointsAbove.push_back(pt);
					else
						pointsBelow.push_back(pt);
				}
				break;
			}
		}
		}

		// Recursively triangulate both polygons
		_recursiveTriangulatePolygon(*itSeg, pointsAbove, tbuffer, pl);
		_recursiveTriangulatePolygon(itSeg->inverse(), pointsBelow, tbuffer, pl);
	}
	// Clean up segments outside of multishape
	if (multiShape.isClosed())
	{
		for (DelaunayTriangleBuffer::iterator it = tbuffer.begin(); it!=tbuffer.end();)
		{
			bool isTriangleOut = !multiShape.isPointInside(it->getMidPoint());

			if (isTriangleOut)
				it = tbuffer.erase(it);
			 else
				it++;
		}
	}
}
//-----------------------------------------------------------------------
void Triangulator::_recursiveTriangulatePolygon(const DelaunaySegment& cuttingSeg, std::vector<int> inputPoints, DelaunayTriangleBuffer& tbuffer, const PointList&  pointList) const
{
	if (inputPoints.size() == 0)
		return;
	if (inputPoints.size() ==1)
	{
		Triangle t(&pointList);
		t.setVertices(cuttingSeg.i1, cuttingSeg.i2, *inputPoints.begin());
		t.makeDirectIfNeeded();
		tbuffer.push_back(t);
		return;
	}
	// Find a point which, when associated with seg.i1 and seg.i2, builds a Delaunay triangle
	std::vector<int>::iterator currentPoint = inputPoints.begin();
	bool found = false;
	while (!found)
	{
		bool isDelaunay = true;
		Circle c(pointList[*currentPoint], pointList[cuttingSeg.i1], pointList[cuttingSeg.i2]);
		for (std::vector<int>::iterator it = inputPoints.begin();it!=inputPoints.end();it++)
		{
			if (c.isPointInside(pointList[*it]) && (*it != *currentPoint))
			{
				isDelaunay = false;
				currentPoint = it;
				break;
			}
		}
		if (isDelaunay)
			found = true;
	}

	// Insert current triangle
	Triangle t(&pointList);
	t.setVertices(*currentPoint, cuttingSeg.i1, cuttingSeg.i2);
	t.makeDirectIfNeeded();
	tbuffer.push_back(t);

	// Recurse
	DelaunaySegment newCut1(cuttingSeg.i1, *currentPoint);
	DelaunaySegment newCut2(cuttingSeg.i2, *currentPoint);
	std::vector<int> set1(inputPoints.begin(), currentPoint);
	std::vector<int> set2(currentPoint+1, inputPoints.end());

	if (!set1.empty())
	_recursiveTriangulatePolygon(newCut1, set1, tbuffer, pointList);
	if (!set2.empty())
	_recursiveTriangulatePolygon(newCut2, set2, tbuffer, pointList);
}
//-----------------------------------------------------------------------
void Triangulator::triangulate(std::vector<int>& output, PointList& outputVertices) const
{
	assert((mShapeToTriangulate || mMultiShapeToTriangulate) && "Either shape or multishape must be defined");

	// Do the Delaunay triangulation
	if (mShapeToTriangulate)
		outputVertices = mShapeToTriangulate->getPoints();
	else
		outputVertices = mMultiShapeToTriangulate->getPoints();
	DelaunayTriangleBuffer dtb;
	delaunay(outputVertices, dtb);

	// Add contraints
	if (mMultiShapeToTriangulate)
		addConstraints(*mMultiShapeToTriangulate, dtb, outputVertices);
	else
		addConstraints(*mShapeToTriangulate, dtb, outputVertices);

	//Outputs index buffer
	for (DelaunayTriangleBuffer::iterator it = dtb.begin(); it!=dtb.end();it++)
	{
		output.push_back(it->i[0]);
		output.push_back(it->i[1]);
		output.push_back(it->i[2]);
	}

	// Remove super triangle
	outputVertices.pop_back();
	outputVertices.pop_back();
	outputVertices.pop_back();
}
//-----------------------------------------------------------------------
void Triangulator::addToTriangleBuffer(TriangleBuffer& buffer) const
	{
	assert((mShapeToTriangulate || mMultiShapeToTriangulate) && "Either shape or multishape must be defined");
	if (mShapeToTriangulate)
	{
		PointList pointList;
		std::vector<int> indexBuffer;
		triangulate(indexBuffer, pointList);
		for (size_t j =0;j<pointList.size();j++)
			{
				Ogre::Vector2 vp2 = pointList[j];
				Ogre::Vector3 vp(vp2.x, vp2.y, 0);
				Ogre::Vector3 normal = -Ogre::Vector3::UNIT_Z;

				Ogre::Vector3 newPoint = vp;
				buffer.position(newPoint);
				buffer.normal(normal);
				buffer.textureCoord(vp2.x, vp2.y);
			}

			for (size_t i=0;i<indexBuffer.size()/3;i++)
			{
				buffer.index(indexBuffer[i*3]);
				buffer.index(indexBuffer[i*3+2]);
				buffer.index(indexBuffer[i*3+1]);
			}
	}
	else
	{
		PointList pointList;
		std::vector<int> indexBuffer;
		triangulate(indexBuffer, pointList);
		for (size_t j =0;j<pointList.size();j++)
			{
				Ogre::Vector2 vp2 = pointList[j];
				Ogre::Vector3 vp(vp2.x, vp2.y, 0);
				Ogre::Vector3 normal = -Ogre::Vector3::UNIT_Z;

				Ogre::Vector3 newPoint = vp;
				buffer.position(newPoint);
				buffer.normal(normal);
				buffer.textureCoord(vp2.x, vp2.y);
			}

			for (size_t i=0;i<indexBuffer.size()/3;i++)
			{
				buffer.index(indexBuffer[i*3]);
				buffer.index(indexBuffer[i*3+2]);
				buffer.index(indexBuffer[i*3+1]);
			}
	}
}
}
