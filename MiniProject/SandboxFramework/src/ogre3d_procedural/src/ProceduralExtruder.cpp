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
#include "ProceduralExtruder.h"
#include "ProceduralTriangulator.h"
#include "ProceduralGeometryHelpers.h"

using namespace Ogre;

namespace Procedural
{	
	//-----------------------------------------------------------------------
	void Extruder::_extrudeBodyImpl(TriangleBuffer& buffer, const Shape* shapeToExtrude) const
	{
		assert(mExtrusionPath && shapeToExtrude && "Shape and Path must not be null!");
		unsigned int numSegPath = mExtrusionPath->getSegCount();
		unsigned int numSegShape = shapeToExtrude->getSegCount();
		assert(numSegPath>0 && numSegShape>0 && "Shape and path must contain at least two points");
				
		Real totalPathLength = mExtrusionPath->getTotalLength();
		Real totalShapeLength = shapeToExtrude->getTotalLength();
		
		// Merge shape and path with tracks
		Ogre::Real lineicPos=0.;
		Path path = *mExtrusionPath;
		if (mRotationTrack)
			path = path.mergeKeysWithTrack(*mRotationTrack);
		if (mScaleTrack)
			path = path.mergeKeysWithTrack(*mScaleTrack);
		if (mPathTextureTrack)
			path = path.mergeKeysWithTrack(*mPathTextureTrack);
		numSegPath = path.getSegCount();
		Shape shape = *shapeToExtrude;
		if (mShapeTextureTrack)
			shape = shape.mergeKeysWithTrack(*mShapeTextureTrack);
		numSegShape = shape.getSegCount();
		
		// Estimate vertex and index count
		buffer.rebaseOffset();
		buffer.estimateIndexCount(numSegShape*numSegPath*6);
		buffer.estimateVertexCount((numSegShape+1)*(numSegPath+1));
				
		Vector3 oldup;
		for (unsigned int i = 0; i <= numSegPath; ++i)
		{
			Vector3 v0 = path.getPoint(i);
			Vector3 direction = path.getAvgDirection(i);

			Quaternion q = Utils::_computeQuaternion(direction);
						
			Radian angle = (q*Vector3::UNIT_Y).angleBetween(oldup);
			if (i>0 && angle>(Radian)Math::HALF_PI/2.)
			{
				q = Utils::_computeQuaternion(direction, oldup);
			}
			oldup = q * Vector3::UNIT_Y;

			Real scale=1.;
					
			if (i>0) lineicPos += (v0-path.getPoint(i-1)).length();
			
			// Get the values of angle and scale
			if (mRotationTrack)
			{
				Real angle;
				angle = mRotationTrack->getValue(lineicPos, lineicPos / totalPathLength, i);

				q = q*Quaternion((Radian)angle, Vector3::UNIT_Z);
			}
			if (mScaleTrack)
			{
				scale = mScaleTrack->getValue(lineicPos, lineicPos / totalPathLength, i);
			}
			Real uTexCoord;
			if (mPathTextureTrack)
				uTexCoord = mPathTextureTrack->getValue(lineicPos, lineicPos / totalPathLength, i);
			else
				uTexCoord = lineicPos / totalPathLength;
			
			Real lineicShapePos = 0.;
			// Insert new points
			for (unsigned int j =0; j <= numSegShape; ++j)
			{				
				Vector2 vp2 = shapeToExtrude->getPoint(j);
				//Vector2 vp2direction = shapeToExtrude->getAvgDirection(j);
				Vector2 vp2normal = shapeToExtrude->getAvgNormal(j);
				Vector3 vp(vp2.x, vp2.y, 0);
				Vector3 normal(vp2normal.x, vp2normal.y, 0);							
				buffer.rebaseOffset();
				Vector3 newPoint = v0+q*(scale*vp);				
				if (j>0)
					lineicShapePos += (vp2 - shape.getPoint(j-1)).length();
				Real vTexCoord;
				if (mShapeTextureTrack)
					vTexCoord = mShapeTextureTrack->getValue(lineicShapePos, lineicShapePos / totalShapeLength, j);
				else
					vTexCoord = lineicShapePos / totalShapeLength;				

				addPoint(buffer, newPoint,
					q*normal, 
					Vector2(uTexCoord, vTexCoord));

				if (j <numSegShape && i <numSegPath)
				{		
					if (shapeToExtrude->getOutSide() == SIDE_LEFT)
					{
						buffer.triangle(numSegShape + 1, numSegShape + 2, 0);
						buffer.triangle(0, numSegShape + 2, 1);
					}
					else 
					{
						buffer.triangle(numSegShape + 2, numSegShape + 1, 0);
						buffer.triangle(numSegShape + 2, 0, 1);
					}
				}			
			}			
		}			
	}
	//-----------------------------------------------------------------------
	void Extruder::_extrudeCapImpl(TriangleBuffer& buffer) const
	{
		std::vector<int> indexBuffer;
		PointList pointList;

		buffer.rebaseOffset();

		Triangulator t;
		if (mShapeToExtrude)
			t.setShapeToTriangulate(mShapeToExtrude);
		else
			t.setMultiShapeToTriangulate(mMultiShapeToExtrude);
		t.triangulate(indexBuffer, pointList);
		buffer.estimateIndexCount(2*indexBuffer.size());
		buffer.estimateVertexCount(2*pointList.size());


		//begin cap
		buffer.rebaseOffset();
		Quaternion qBegin = Utils::_computeQuaternion(mExtrusionPath->getDirectionAfter(0));
		if (mRotationTrack)
		{
			Real angle = mRotationTrack->getFirstValue();
			qBegin = qBegin*Quaternion((Radian)angle, Vector3::UNIT_Z);
		}	
		Real scaleBegin=1.;
		if (mScaleTrack)
			scaleBegin = mScaleTrack->getFirstValue();
		for (size_t j =0;j<pointList.size();j++)
		{
			Vector2 vp2 = pointList[j];
			Vector3 vp(vp2.x, vp2.y, 0);
			Vector3 normal = -Vector3::UNIT_Z;				

			Vector3 newPoint = mExtrusionPath->getPoint(0)+qBegin*(scaleBegin*vp);
			addPoint(buffer, newPoint,
				qBegin*normal,
				vp2);
		}

		for (size_t i=0;i<indexBuffer.size()/3;i++)
		{				
			buffer.index(indexBuffer[i*3]);
			buffer.index(indexBuffer[i*3+2]);
			buffer.index(indexBuffer[i*3+1]);
		}

		// end cap
		buffer.rebaseOffset();
		Quaternion qEnd = Utils::_computeQuaternion(mExtrusionPath->getDirectionBefore(mExtrusionPath->getSegCount()));
		if (mRotationTrack)
		{
			Real angle = mRotationTrack->getLastValue();
			qEnd = qEnd*Quaternion((Radian)angle, Vector3::UNIT_Z);
		}			
		Real scaleEnd=1.;
		if (mScaleTrack)
			scaleEnd = mScaleTrack->getLastValue();

		for (size_t j =0;j<pointList.size();j++)
		{
			Vector2 vp2 = pointList[j];
			Vector3 vp(vp2.x, vp2.y, 0);
			Vector3 normal = Vector3::UNIT_Z;				

			Vector3 newPoint = mExtrusionPath->getPoint(mExtrusionPath->getSegCount())+qEnd*(scaleEnd*vp);
			addPoint(buffer, newPoint,
				qEnd*normal,
				vp2);
		}

		for (size_t i=0;i<indexBuffer.size()/3;i++)
		{				
			buffer.index(indexBuffer[i*3]);
			buffer.index(indexBuffer[i*3+1]);
			buffer.index(indexBuffer[i*3+2]);
		}

	}
	//-----------------------------------------------------------------------
	void Extruder::addToTriangleBuffer(TriangleBuffer& buffer) const
	{
		assert((mShapeToExtrude || mMultiShapeToExtrude) && "Either shape or multishape must be defined!");

		// Triangulate the begin and end caps
		if (!mExtrusionPath->isClosed() && mCapped)
			_extrudeCapImpl(buffer);

		// Extrudes the body
		if (mShapeToExtrude)
			_extrudeBodyImpl(buffer, mShapeToExtrude);
		else 
		{
			for (size_t i=0; i<mMultiShapeToExtrude->getShapeCount();i++)			
				_extrudeBodyImpl(buffer, &mMultiShapeToExtrude->getShape(i));
		}
	}
}
