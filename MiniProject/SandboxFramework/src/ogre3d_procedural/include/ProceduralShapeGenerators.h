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
#ifndef PROCEDURAL_SHAPE_GENERATORS_INCLUDED
#define PROCEDURAL_SHAPE_GENERATORS_INCLUDED

#include "ProceduralShape.h"
#include "ProceduralSplines.h"

namespace Procedural
{
//-----------------------------------------------------------------------
/// Base class for Shape generators
template<class T>
class BaseSpline2
{
protected:
	/// The number of segments between 2 control points
	unsigned int mNumSeg;
	/// Whether the shape will be closed or not
	bool mClosed;
	/// The "out" side of the shape
	Side mOutSide;
public:
	/// Default constructor
	BaseSpline2() : mNumSeg(4), mClosed(false), mOutSide(SIDE_RIGHT) {}

	/// Sets the out side of the shape
	inline T& setOutSide(Side outSide)
	{
		mOutSide = outSide;
		return (T&)*this;
	}

	/// Gets the out side of the shape
	inline Side getOutSide() const
	{
		return mOutSide;
	}

	/// Sets the number of segments between 2 control points
	inline T& setNumSeg(unsigned int numSeg)
	{
		assert(numSeg>=1);
		mNumSeg = numSeg;
		return (T&)*this;
	}

	/// Closes the spline
	inline T& close()
	{
		mClosed = true;
		return (T&)*this;
	}
};

//-----------------------------------------------------------------------
/**
 * Produces a shape from Cubic Hermite control points
 */
class _ProceduralExport CubicHermiteSpline2 : public BaseSpline2<CubicHermiteSpline2>
{
	typedef CubicHermiteSplineControlPoint<Ogre::Vector2> ControlPoint;

	std::vector<ControlPoint> mPoints;

public:
	/// Adds a control point
	inline CubicHermiteSpline2& addPoint(const Ogre::Vector2& p, const Ogre::Vector2& before, const Ogre::Vector2& after)
	{
		mPoints.push_back(ControlPoint(p, before, after));
		return *this;
	}
	/// Adds a control point
	inline CubicHermiteSpline2& addPoint(const Ogre::Vector2& p, const Ogre::Vector2& tangent)
	{
		mPoints.push_back(ControlPoint(p, tangent, tangent));
		return *this;
	}
	/// Adds a control point
	inline CubicHermiteSpline2& addPoint(const Ogre::Vector2& p, CubicHermiteSplineAutoTangentMode autoTangentMode = AT_CATMULL)
	{
		ControlPoint cp;
		cp.position = p;
		cp.autoTangentBefore = autoTangentMode;
		cp.autoTangentAfter = autoTangentMode;
		mPoints.push_back(cp);
		return *this;
	}

		/// Adds a control point
	inline CubicHermiteSpline2& addPoint(Ogre::Real x, Ogre::Real y, CubicHermiteSplineAutoTangentMode autoTangentMode = AT_CATMULL)
	{
		ControlPoint cp;
		cp.position = Ogre::Vector2(x,y);
		cp.autoTangentBefore = autoTangentMode;
		cp.autoTangentAfter = autoTangentMode;
		mPoints.push_back(cp);
		return *this;
	}

	/// Safely gets a control point
	inline const ControlPoint& safeGetPoint(unsigned int i) const
	{
		if (mClosed)
			return mPoints[Utils::modulo(i,static_cast<int>(mPoints.size()))];
		return mPoints[Utils::cap(i,0,static_cast<int>(mPoints.size()-1))];
	}

	/**
	 * Builds a shape from control points
	 */
	Shape realizeShape();
};

//-----------------------------------------------------------------------
/**
 * Builds a shape from a Catmull-Rom Spline.
 * A catmull-rom smoothly interpolates position between control points
 */
class _ProceduralExport CatmullRomSpline2 : public BaseSpline2<CatmullRomSpline2>
{
	std::vector<Ogre::Vector2> mPoints;
	public:
	/// Adds a control point
	inline CatmullRomSpline2& addPoint(const Ogre::Vector2& pt)
	{
		mPoints.push_back(pt);
		return *this;
	}

	/// Adds a control point
	inline CatmullRomSpline2& addPoint(Ogre::Real x, Ogre::Real y)
	{
		mPoints.push_back(Ogre::Vector2(x,y));
		return *this;
	}

	/// Safely gets a control point
	inline const Ogre::Vector2& safeGetPoint(unsigned int i) const
	{
		if (mClosed)
			return mPoints[Utils::modulo(i,static_cast<int>(mPoints.size()))];
		return mPoints[Utils::cap(i,0,static_cast<int>(mPoints.size()-1))];
	}

	/**
	 * Build a shape from bezier control points
	 */
	Shape realizeShape();
};

//-----------------------------------------------------------------------
/**
 * Builds a shape from a Kochanek Bartels spline.
 *
 * More details here : http://en.wikipedia.org/wiki/Kochanek%E2%80%93Bartels_spline
 */
class _ProceduralExport KochanekBartelsSpline2 : public BaseSpline2<KochanekBartelsSpline2>
{
	typedef KochanekBartelsSplineControlPoint<Ogre::Vector2> ControlPoint;

	std::vector<ControlPoint> mPoints;

public:
	/// Adds a control point
	inline KochanekBartelsSpline2& addPoint(Ogre::Real x, Ogre::Real y)
	{
		mPoints.push_back(ControlPoint(Ogre::Vector2(x,y)));
		return *this;
	}

	/// Adds a control point
	inline KochanekBartelsSpline2& addPoint(Ogre::Vector2 p)
	{
		mPoints.push_back(ControlPoint(p));
		return *this;
	}

	/// Safely gets a control point
	inline const ControlPoint& safeGetPoint(unsigned int i) const
	{
		if (mClosed)
			return mPoints[Utils::modulo(i,static_cast<int>(mPoints.size()))];
		return mPoints[Utils::cap(i,0,static_cast<int>(mPoints.size()-1))];
	}

	/**
	 * Adds a control point to the spline
	 * @arg p Point position
	 * @arg t Tension    +1 = Tight            -1 = Round
	 * @arg b Bias       +1 = Post-shoot       -1 = Pre-shoot
	 * @arg c Continuity +1 = Inverted Corners -1 = Box Corners
	 */
	inline KochanekBartelsSpline2& addPoint(Ogre::Vector2 p, Ogre::Real t, Ogre::Real b, Ogre::Real c)
	{
		mPoints.push_back(ControlPoint(p,t,b,c));
		return *this;
	}

	/**
	 * Builds a shape from control points
	 */
	Shape realizeShape();
};

//-----------------------------------------------------------------------
/**
 * Builds a rectangular shape
 */
class _ProceduralExport RectangleShape
{
	Ogre::Real mWidth,mHeight;

	public:
	/// Default constructor
	RectangleShape() : mWidth(1.0), mHeight(1.0) {}

	/// Sets width
	inline RectangleShape& setWidth(Ogre::Real width)
	{
		mWidth = width;
		return *this;
	}

	/// Sets height
	inline RectangleShape& setHeight(Ogre::Real height)
	{
		mHeight = height;
		return *this;
	}

	/// Builds the shape
	Shape realizeShape()
	{
		Shape s;
		s.addPoint(-.5f*mWidth,-.5f*mHeight)
		 .addPoint(.5f*mWidth,-.5f*mHeight)
		 .addPoint(.5f*mWidth,.5f*mHeight)
		 .addPoint(-.5f*mWidth,.5f*mHeight)
		 .close();
		return s;
	}
};

//-----------------------------------------------------------------------
/**
 * Builds a circular shape
 */
class _ProceduralExport CircleShape
{
	Ogre::Real mRadius;
	unsigned int mNumSeg;

	public:
	/// Default constructor
	CircleShape() : mRadius(1.0), mNumSeg(8) {}

	/// Sets radius
	inline CircleShape& setRadius(Ogre::Real radius)
	{
		mRadius = radius;
		return *this;
	}

	/// Sets number of segments
	inline CircleShape& setNumSeg(unsigned int numSeg)
	{
		mNumSeg = numSeg;
		return *this;
	}

	/// Builds the shape
	Shape realizeShape()
	{
		Shape s;
		Ogre::Real deltaAngle = Ogre::Math::TWO_PI/(Ogre::Real)mNumSeg;
		for (unsigned int i = 0; i < mNumSeg; ++i)
		{
			s.addPoint(mRadius*cosf(i*deltaAngle), mRadius*sinf(i*deltaAngle));
		}
		s.close();
		return s;
	}
};
//-----------------------------------------------------------------------
/**
 * Produces a shape from Cubic Hermite control points
 */
class _ProceduralExport RoundedCornerSpline2 : public BaseSpline2<RoundedCornerSpline2>
{
	Ogre::Real mRadius;

	std::vector<Ogre::Vector2> mPoints;

public:
	RoundedCornerSpline2() : mRadius(.1f) {}

	/// Sets the radius of the corners
	inline RoundedCornerSpline2& setRadius(Ogre::Real radius)
	{
		mRadius = radius;
		return *this;
	}

	/// Adds a control point
	inline RoundedCornerSpline2& addPoint(const Ogre::Vector2& p)
	{
		mPoints.push_back(p);
		return *this;
	}

	/// Adds a control point
	inline RoundedCornerSpline2& addPoint(Ogre::Real x, Ogre::Real y)
	{
		mPoints.push_back(Ogre::Vector2(x,y));
		return *this;
	}

	/// Safely gets a control point
	inline const Ogre::Vector2& safeGetPoint(unsigned int i) const
	{
		if (mClosed)
			return mPoints[Utils::modulo(i,static_cast<int>(mPoints.size()))];
		return mPoints[Utils::cap(i,0,static_cast<int>(mPoints.size()-1))];
	}

	/**
	 * Builds a shape from control points
	 */
	Shape realizeShape();
};
}

#endif
