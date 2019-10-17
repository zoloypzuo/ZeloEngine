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
#ifndef PROCEDURAL_LATHE_INCLUDED
#define PROCEDURAL_LATHE_INCLUDED

#include "ProceduralShape.h"
#include "ProceduralPlatform.h"
#include "ProceduralMeshGenerator.h"

namespace Procedural
{
/** Builds a mesh by rotating a shape 360° around Y-axis.
 * The shape is assumed to be defined in the X>=0 half-plane
 */
class _ProceduralExport Lathe : public MeshGenerator<Lathe>
{
	Shape* mShapeToExtrude;	
	MultiShape* mMultiShapeToExtrude;
	int mNumSeg;
	Ogre::Radian mAngleBegin;
	Ogre::Radian mAngleEnd;	
	bool mClosed;	
	bool mCapped;
	
	void _latheCapImpl(TriangleBuffer& buffer) const;
	void _latheBodyImpl(TriangleBuffer& buffer, const Shape* shapeToExtrude) const;

public:	
	/// Contructor with arguments
	Lathe(Shape* shapeToExtrude = 0, int numSeg = 16) : mShapeToExtrude(shapeToExtrude), mMultiShapeToExtrude(0), 
														mNumSeg(numSeg), mAngleBegin(0), mAngleEnd((Ogre::Radian)Ogre::Math::TWO_PI), mClosed(true), mCapped(true)
	{}

	/** Sets the number of segments when rotating around the axis (default=16)*/
	inline Lathe& setNumSeg(int numSeg)
	{
		mNumSeg = numSeg;
		return *this;
	}
	
	/// Sets the angle to begin lathe with (default=0)
	/// Automatically makes the lathe not closed
	inline Lathe& setAngleBegin(Ogre::Radian angleBegin)
	{
		mAngleBegin = angleBegin;
		mClosed = false;
		return *this;
	}
	
	/// Sets the angle to end lathe with (default=2PI)
	/// Automatically makes the lathe not closed
	inline Lathe& setAngleEnd(Ogre::Radian angleEnd)
	{
		mAngleEnd = angleEnd;
		mClosed = false;
		return *this;
	}
	
	/// Sets whether the lathe is closed or not
	inline Lathe& setClosed(bool closed)
	{
		mClosed = closed;
		return *this;
	}
	
	/// Sets whether the lathe is capped or not (default=true)
	/// Only makes sense if the lathe is not closed.
	inline Lathe& setCapped(bool capped)
	{
		mCapped = capped;
		return *this;
	}
	
	/** Sets the shape to extrude 	
	  * If a multishape is already defined, auto-disables it
	  * The shape is assumed to be defined in the X>=0 half-plane
	  */
	inline Lathe& setShapeToExtrude(Shape* shapeToExtrude)
	{
		mShapeToExtrude = shapeToExtrude;
		mMultiShapeToExtrude = 0;
		return *this;
	}
	
	/** Sets the multiShape to extrude
	  * If a shape is already defined, auto-disables it
	  * The shapes in this multi-shape are assumed to be defined in the X>=0 half-plane
	  */
	inline Lathe& setMultiShapeToExtrude(MultiShape* multiShapeToExtrude)
	{
		mMultiShapeToExtrude = multiShapeToExtrude;
		mShapeToExtrude = 0;
		return *this;
	}

	/**
	 * Builds the mesh into the given TriangleBuffer
	 * @param buffer The TriangleBuffer on where to append the mesh.
	 */
	void addToTriangleBuffer(TriangleBuffer& buffer) const;
};
}

#endif