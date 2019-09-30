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
#include "ProceduralShapeGenerators.h"
#include "ProceduralGeometryHelpers.h"

using namespace Ogre;

namespace Procedural
{	
//-----------------------------------------------------------------------
Shape CubicHermiteSpline2::realizeShape()
	{
	Shape shape;

		unsigned int numPoints = mClosed ? mPoints.size() : (mPoints.size() - 1);
		//Precompute tangents
		for (unsigned int i = 0; i < mPoints.size(); ++i)
			computeTangents<Vector2>(mPoints[i], safeGetPoint(i-1).position, safeGetPoint(i+1).position);

		for (unsigned int i = 0; i < numPoints; ++i)
		{
			const ControlPoint& pointBefore = mPoints[i];
			const ControlPoint& pointAfter = safeGetPoint(i+1);

			computeCubicHermitePoints(pointBefore, pointAfter, mNumSeg, shape.getPointsReference());

			if (i == mPoints.size() - 2 && !mClosed)
			{
				shape.addPoint(pointAfter.position);
			}
		}
		if (mClosed)
			shape.close();
		shape.setOutSide(mOutSide);

		return shape;
	}
//-----------------------------------------------------------------------
Shape CatmullRomSpline2::realizeShape()
	{
		Shape shape;

		unsigned int numPoints = mClosed ? mPoints.size() : (mPoints.size() - 1);
		for (unsigned int i = 0; i < numPoints; ++i)
		{			
			const Vector2& P1 = safeGetPoint(i-1);
			const Vector2& P2 = safeGetPoint(i);
			const Vector2& P3 = safeGetPoint(i+1);
			const Vector2& P4 = safeGetPoint(i+2);

			computeCatmullRomPoints(P1, P2, P3, P4, mNumSeg, shape.getPointsReference());

			if (i == mPoints.size() - 2 && !mClosed)
			{
				shape.addPoint(P3);
			}

		}
		if (mClosed)
			shape.close();
		shape.setOutSide(mOutSide);

		return shape;
	}
//-----------------------------------------------------------------------
	Shape KochanekBartelsSpline2::realizeShape()	
	{
		Shape shape;
		
		unsigned int numPoints = mClosed ? mPoints.size() : (mPoints.size() - 1);
		for (unsigned int i = 0; i < numPoints; ++i)
		{
			const ControlPoint& P1 = safeGetPoint(i-1);
			const ControlPoint& P2 = safeGetPoint(i);
			const ControlPoint& P3 = safeGetPoint(i+1);
			const ControlPoint& P4 = safeGetPoint(i+2);
			
			computeKochanekBartelsPoints(P1, P2, P3, P4, mNumSeg, shape.getPointsReference());

			if (i == mPoints.size() - 2 && !mClosed)
			{
				shape.addPoint(P3.position);
			}
		}
		if (mClosed)
			shape.close();
		shape.setOutSide(mOutSide);
		return shape;
	}
//-----------------------------------------------------------------------
Shape RoundedCornerSpline2::realizeShape()
{
	assert(!mPoints.empty());

	Shape shape;
	unsigned int numPoints = mClosed ? mPoints.size() : (mPoints.size() - 2);
	if (!mClosed)
			shape.addPoint(mPoints[0]);
		
	for (unsigned int i = 0; i < numPoints; ++i)
	{
		const Vector2& p0 = safeGetPoint(i);
		const Vector2& p1 = safeGetPoint(i+1);
		const Vector2& p2 = safeGetPoint(i+2);

		Vector2 vBegin = p1-p0;
		Vector2 vEnd = p2-p1;
		
		// We're capping the radius if it's too big compared to segment length
		Real radius = mRadius;
		Real smallestSegLength = std::min(vBegin.length(), vEnd.length());
		if (smallestSegLength < 2 * mRadius)
			radius = smallestSegLength / 2.0f;
		
		Vector2 pBegin = p1 - vBegin.normalisedCopy() * radius;
		Vector2 pEnd = p1 + vEnd.normalisedCopy() * radius;
		Line2D line1(pBegin, vBegin.perpendicular());
		Line2D line2(pEnd, vEnd.perpendicular());
		Vector2 center;
		line1.findIntersect(line2, center);
		Vector2 vradBegin = pBegin - center;
		Vector2 vradEnd = pEnd - center;		
		Radian angleTotal = Utils::angleBetween(vradBegin, vradEnd);
		if (vradBegin.crossProduct(vradEnd)<0)
			angleTotal = -angleTotal;
				
		for (unsigned int j=0;j<=mNumSeg;j++)
		{
			Vector2 deltaVector = Utils::rotateVector2(vradBegin, (Real)j * angleTotal / (Real)mNumSeg);
			shape.addPoint(center + deltaVector);
		}
	}

	if (!mClosed)
		shape.addPoint(mPoints[mPoints.size()-1]);

	if (mClosed)
			shape.close();
		shape.setOutSide(mOutSide);

	return shape;
}
}
