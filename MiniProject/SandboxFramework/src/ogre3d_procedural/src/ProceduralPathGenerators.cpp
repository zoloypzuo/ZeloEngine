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
#include "ProceduralPathGenerators.h"
#include "ProceduralSplines.h"
#include "ProceduralGeometryHelpers.h"

using namespace Ogre;

namespace Procedural 
{
//-----------------------------------------------------------------------
Path CatmullRomSpline3::realizePath()
{
	Path path;

	unsigned int numPoints = mClosed?mPoints.size():mPoints.size()-1;		
	for (unsigned int i=0; i < numPoints; ++i)
	{			
		const Vector3& P1 = safeGetPoint(i-1);
		const Vector3& P2 = safeGetPoint(i);
		const Vector3& P3 = safeGetPoint(i+1);
		const Vector3& P4 = safeGetPoint(i+2);

		computeCatmullRomPoints(P1, P2, P3, P4, mNumSeg, path.getPointsReference());

		if (i == mPoints.size() - 2 && !mClosed)
			path.addPoint(P3);
	}
	if (mClosed)
		path.close();

	return path;
}
//-----------------------------------------------------------------------
Path CubicHermiteSpline3::realizePath()
{
	Path path;
	
	//Precompute tangents
	for (unsigned int i = 0; i < mPoints.size(); ++i)
		computeTangents<Vector3>(mPoints[i], safeGetPoint(i-1).position, safeGetPoint(i+1).position);

	unsigned int numPoints = mClosed ? mPoints.size() : (mPoints.size() - 1);
	for (unsigned int i = 0; i < numPoints; ++i)
	{
		const ControlPoint& pointBefore = mPoints[i];
		const ControlPoint& pointAfter = safeGetPoint(i+1);

		computeCubicHermitePoints(pointBefore, pointAfter, mNumSeg, path.getPointsReference());

		if (i == mPoints.size() - 2 && !mClosed)		
			path.addPoint(pointAfter.position);
		
	}
	if (mClosed)
		path.close();

	return path;
}

//-----------------------------------------------------------------------
Path RoundedCornerSpline3::realizePath()
{
	assert(!mPoints.empty());

	Path path;
	unsigned int numPoints = mClosed ? mPoints.size() : (mPoints.size() - 2);
	if (!mClosed)
			path.addPoint(mPoints[0]);
		
	for (unsigned int i = 0; i < numPoints; ++i)
	{
		const Vector3& p0 = safeGetPoint(i);
		const Vector3& p1 = safeGetPoint(i+1);
		const Vector3& p2 = safeGetPoint(i+2);

		Vector3 vBegin = p1-p0;
		Vector3 vEnd = p2-p1;
		
		// We're capping the radius if it's too big compared to segment length
		Real radius = mRadius;
		Real smallestSegLength = std::min(vBegin.length(), vEnd.length());
		if (smallestSegLength < 2 * mRadius)
			radius = smallestSegLength / 2.0f;
		
		Vector3 pBegin = p1 - vBegin.normalisedCopy() * radius;
		Vector3 pEnd = p1 + vEnd.normalisedCopy() * radius;
		Procedural::Plane plane1(vBegin, pBegin);
		Procedural::Plane plane2(vEnd, pEnd);
		Line axis;
		plane1.intersect(plane2, axis);	

		Vector3 vradBegin = axis.shortestPathToPoint(pBegin);
		Vector3 vradEnd = axis.shortestPathToPoint(pEnd);
		Quaternion q = vradBegin.getRotationTo(vradEnd);
		Vector3 center = pBegin - vradBegin;
		Radian angleTotal;
		Vector3 vAxis;
		q.ToAngleAxis(angleTotal, vAxis);
						
		for (unsigned int j=0;j<=mNumSeg;j++)
		{
			q.FromAngleAxis(angleTotal * (Real)j / (Real)mNumSeg, vAxis);
			path.addPoint(center + q*vradBegin);
		}
	}

	if (!mClosed)
		path.addPoint(mPoints[mPoints.size()-1]);

	if (mClosed)
			path.close();

	return path;
}

}
