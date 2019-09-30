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
#include "ProceduralMultiShape.h"
#include "ProceduralShape.h"

using namespace Ogre;

namespace Procedural
{
//-----------------------------------------------------------------------
	MeshPtr MultiShape::realizeMesh(const std::string& name)
	{
		Ogre::SceneManager *smgr = Ogre::Root::getSingleton().getSceneManagerIterator().begin()->second;
		ManualObject * manual = smgr->createManualObject(name);

		for (std::vector<Shape>::iterator it = mShapes.begin(); it!=mShapes.end(); it++)
		{
			manual->begin("BaseWhiteNoLighting", RenderOperation::OT_LINE_STRIP);
			it->_appendToManualObject(manual);
			manual->end();
		}

		MeshPtr mesh;
		if (name=="")
			mesh = manual->convertToMesh(Utils::getName());
		else
			mesh = manual->convertToMesh(name);
		smgr->destroyManualObject(manual);
		return mesh;
	}
//-----------------------------------------------------------------------
	MultiShape::MultiShape(int count, ...)
	{
		va_list shapes;
		va_start(shapes, count);
		for (int i = 0; i < count; i++)
		{
			mShapes.push_back(*va_arg(shapes, const Shape*));
		}

		va_end(shapes);
	}
//-----------------------------------------------------------------------
	std::vector<Vector2> MultiShape::getPoints() const
	{
		std::vector<Vector2> result;
		for (size_t i = 0;i<mShapes.size(); i++)
		{
			std::vector<Vector2> points = mShapes[i].getPoints();
			result.insert(result.end(), points.begin(), points.end());
		}
		return result;
	}
//-----------------------------------------------------------------------
	bool MultiShape::isPointInside(const Vector2& point) const
	{
		// Draw a horizontal lines that goes through "point"
		// Using the closest intersection, find whether the point is actually inside
		int closestSegmentIndex=-1;
		Real closestSegmentDistance = std::numeric_limits<Real>::max();
		Vector2 closestSegmentIntersection(Vector2::ZERO);
		const Shape* closestSegmentShape = 0;

		for (size_t k =0;k<mShapes.size();k++)
		{
			const Shape& shape = mShapes[k];
			for (size_t i =0;i<shape.getSegCount();i++)
			{
				Vector2 A = shape.getPoint(i);
				Vector2 B = shape.getPoint(i+1);
				if (A.y!=B.y && (A.y-point.y)*(B.y-point.y)<=0.)
				{
					Vector2 intersect(A.x+(point.y-A.y)*(B.x-A.x)/(B.y-A.y), point.y);
					float dist = Math::Abs(point.x-intersect.x);
					if (dist<closestSegmentDistance)
					{
						closestSegmentIndex = i;
						closestSegmentDistance = dist;
						closestSegmentIntersection = intersect;
						closestSegmentShape = &shape;
					}
				}
			}
		}
		if (closestSegmentIndex!=-1)
		{
			int edgePoint=-1;
			if (closestSegmentIntersection.squaredDistance(closestSegmentShape->getPoint(closestSegmentIndex))<1e-8)
				//return (closestSegmentShape->getAvgNormal(closestSegmentIndex).x * (point.x-closestSegmentIntersection.x)<0);
				edgePoint=closestSegmentIndex;
			else
			if (closestSegmentIntersection.squaredDistance(closestSegmentShape->getPoint(closestSegmentIndex+1))<1e-8)
				//return (closestSegmentShape->getAvgNormal(closestSegmentIndex+1).x * (point.x-closestSegmentIntersection.x)<0);
				edgePoint=closestSegmentIndex+1;
			if (edgePoint>-1)
			{
				Ogre::Radian alpha1 = Utils::angleBetween(point-closestSegmentShape->getPoint(edgePoint), closestSegmentShape->getDirectionAfter(edgePoint));
				Ogre::Radian alpha2 = Utils::angleBetween(point-closestSegmentShape->getPoint(edgePoint), -closestSegmentShape->getDirectionBefore(edgePoint));
				if (alpha1<alpha2)
					closestSegmentIndex=edgePoint;
				else
					closestSegmentIndex=edgePoint-1;
			}
			return (closestSegmentShape->getNormalAfter(closestSegmentIndex).x * (point.x-closestSegmentIntersection.x)<0);
		}
		// We're in the case where the point is on the "real outside" of the multishape
		// So, if the real outside == user defined outside, then the point is "user-defined outside"
		return !isOutsideRealOutside();
	}
//-----------------------------------------------------------------------
	bool MultiShape::isClosed() const
	{
		for (std::vector<Shape>::const_iterator it = mShapes.begin(); it!=mShapes.end(); it++)
		{
			if (!it->isClosed())
				return false;
		}
		return true;
	}
//-----------------------------------------------------------------------
	void MultiShape::close()
	{
		for (std::vector<Shape>::iterator it = mShapes.begin(); it!= mShapes.end(); it++)
		{
			it->close();
		}
	}

//-----------------------------------------------------------------------
bool MultiShape::isOutsideRealOutside() const
{
	Ogre::Real x = std::numeric_limits<Ogre::Real>::min();
	int index=0;
	int shapeIndex = 0;
	for (size_t j = 0; j < mShapes.size(); j++)
	{
		const Shape& s = mShapes[j];
		const std::vector<Ogre::Vector2>& points = s.getPointsReference();
		for (size_t i=0; i < points.size(); i++)
		{
			if (x < points[i].x)
			{
				x = points[i].x;
				index = i;
				shapeIndex = j;
			}
		}
	}
	Radian alpha1 = Utils::angleTo(Vector2::UNIT_Y, mShapes[shapeIndex].getDirectionAfter(index));
	Radian alpha2 = Utils::angleTo(Vector2::UNIT_Y, -mShapes[shapeIndex].getDirectionBefore(index));
	Side shapeSide;
	if (alpha1<alpha2)
		shapeSide = SIDE_RIGHT;
	else
		shapeSide = SIDE_LEFT;
	return shapeSide == mShapes[shapeIndex].getOutSide();
}

}
