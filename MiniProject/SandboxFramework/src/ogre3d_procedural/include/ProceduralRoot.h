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
#ifndef PROCEDURALROOT_H_INCLUDED
#define PROCEDURALROOT_H_INCLUDED

#include "OgreSceneManager.h"
#include "ProceduralPlatform.h"

/**
 * @mainpage API reference start page
 * 
 * This is the reference doc for OgreProcedural, containing description for all classes and function. <br>
 *
 * If you want to get a more complete overview of functionnality, you can also check out the manual.
 */

namespace Procedural
{
/** Singleton that holds the general parameters of OgreProcedural.
 *  Unused for now.
 */
class _ProceduralExport Root
{
	static Root* instance;
	Root()
	{}
	public:

	/// Return the singleton pointer of this class
	static Root* getInstance()
	{
		if (!instance)
			instance = new Root();
		return instance;
	}

};
}

#endif // PROCEDURALROOT_H_INCLUDED
