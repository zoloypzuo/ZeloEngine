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
#include "ProceduralGeometryHelpers.h"
#include "ProceduralUtils.h"

using namespace Ogre;

namespace Procedural
{
//-----------------------------------------------------------------------
Circle::Circle(Vector2 p1, Vector2 p2, Vector2 p3)
{
	Vector2 c1 = .5*(p1+p2);
	Vector2 d1 = (p2-p1).perpendicular();
	float a1 = d1.y;
	float b1 = -d1.x;
	float g1 = d1.x*c1.y-d1.y*c1.x;

	Vector2 c3 = .5*(p2+p3);
	Vector2 d3 = (p3-p2).perpendicular();
	float a2 = d3.y;
	float b2 = -d3.x;
	float g2 = d3.x*c3.y-d3.y*c3.x;
	
	Vector2 intersect;
	float intersectx = (b2*g1-b1*g2)/(b1*a2-b2*a1);
	float intersecty = (a2*g1-a1*g2)/(a1*b2-a2*b1);		

	intersect = Vector2(intersectx, intersecty);

	mCenter = intersect;
	mRadius = (intersect-p1).length();
}
//-----------------------------------------------------------------------
bool Segment2D::findIntersect(const Segment2D& other, Vector2& intersection) const
	{		
		const Vector2& p1 = mA;
		const Vector2& p2 = mB;
		const Vector2& p3 = other.mA;
		const Vector2& p4 = other.mB;


		Vector2 d1 = p2-p1;
		float a1 = d1.y;
		float b1 = -d1.x;
		float g1 = d1.x*p1.y-d1.y*p1.x;
				
		Vector2 d3 = p4-p3;
		float a2 = d3.y;
		float b2 = -d3.x;
		float g2 = d3.x*p3.y-d3.y*p3.x;

		// if both segments are parallel, early out
		if (d1.crossProduct(d3) == 0.)
			return false;
	
		Vector2 intersect;
		float intersectx = (b2*g1-b1*g2)/(b1*a2-b2*a1);
		float intersecty = (a2*g1-a1*g2)/(a1*b2-a2*b1);		
	
		intersect = Vector2(intersectx, intersecty);

		if ((intersect-p1).dotProduct(intersect-p2)<0 && (intersect-p3).dotProduct(intersect-p4)<0)
		{
			intersection = intersect;
			return true;
		}
		return false;
	}
//-----------------------------------------------------------------------
bool Segment2D::intersects(const Segment2D& other) const
{
	// Early out if segments have nothing in common
	Vector2 min1 = Utils::min(mA, mB);
	Vector2 max1 = Utils::max(mA, mB);
	Vector2 min2 = Utils::min(other.mA, other.mB);
	Vector2 max2 = Utils::max(other.mA, other.mB);
	if (max1.x<min2.x || max1.y<min2.y || max2.x<min1.x || max2.y<min2.y)
		return false;
	Vector2 t;
	return findIntersect(other, t);
}
//-----------------------------------------------------------------------
bool Plane::intersect(const Plane& other, Line& outputLine) const
	{		
		//TODO : handle the case where the plane is perpendicular to T
		Vector3 point1(Ogre::Vector3::ZERO);
		Vector3 direction = normal.crossProduct(other.normal);
		if (direction.squaredLength() < 1e-08)
			return false;
		
		Real cp = normal.x*other.normal.y-other.normal.x*normal.y;
		if (cp!=0)
		{
			Real denom = 1.f/cp;
			point1.x = (normal.y*other.d-other.normal.y*d)*denom;
			point1.y = (other.normal.x*d-normal.x*other.d)*denom;
			point1.z = 0;
		} else if ((cp= normal.y*other.normal.z-other.normal.y*normal.z)!=0)
		{ //special case #1
			Real denom = 1.f/cp;
			point1.x = 0;
			point1.y = (normal.z*other.d-other.normal.z*d)*denom;
			point1.z = (other.normal.y*d-normal.y*other.d)*denom;			
		} else if ((cp= normal.x*other.normal.z-other.normal.x*normal.z)!=0)
		{ //special case #2			
			Real denom = 1.f/cp;			
			point1.x = (normal.z*other.d-other.normal.z*d)*denom;
			point1.y = 0;
			point1.z = (other.normal.x*d-normal.x*other.d)*denom;			
		}
		
		outputLine = Line(point1, direction);

		return true;
	}
//-----------------------------------------------------------------------
Vector3 Line::shortestPathToPoint(const Vector3& point) const
{
	Vector3 projection = (point-mPoint).dotProduct(mDirection) * mDirection;
	Vector3 vec = -projection+point-mPoint;
	return vec;
}
//-----------------------------------------------------------------------
bool Line2D::findIntersect(const Line2D& other, Ogre::Vector2& intersection) const
{
	const Vector2& p1 = mPoint;
	//const Vector2& p2 = mPoint+mDirection;
	const Vector2& p3 = other.mPoint;
	//const Vector2& p4 = other.mPoint+other.mDirection;

	Vector2 d1 = mDirection;
	float a1 = d1.y;
	float b1 = -d1.x;
	float g1 = d1.x*p1.y-d1.y*p1.x;
			
	Vector2 d3 = other.mDirection;
	float a2 = d3.y;
	float b2 = -d3.x;
	float g2 = d3.x*p3.y-d3.y*p3.x;

	// if both segments are parallel, early out
	if (d1.crossProduct(d3) == 0.)
		return false;
	float intersectx = (b2*g1-b1*g2)/(b1*a2-b2*a1);
	float intersecty = (a2*g1-a1*g2)/(a1*b2-a2*b1);		
	
	intersection = Vector2(intersectx, intersecty);
	return true;
}

}
