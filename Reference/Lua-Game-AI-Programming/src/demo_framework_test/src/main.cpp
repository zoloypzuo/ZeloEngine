/**
 * Copyright (c) 2013 David Young dayoung@goliathdesigns.com
 *
 * This software is provided 'as-is', without any express or implied
 * warranty. In no event will the authors be held liable for any damages
 * arising from the use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 *  1. The origin of this software must not be misrepresented; you must not
 *  claim that you wrote the original software. If you use this software
 *  in a product, an acknowledgment in the product documentation would be
 *  appreciated but is not required.
 *
 *  2. Altered source versions must be plainly marked as such, and must not be
 *  misrepresented as being the original software.
 *
 *  3. This notice may not be removed or altered from any source
 *  distribution.
 */

#include "demo_framework_test/include/DemoTest.h"
#include "ogre3d/include/OgreException.h"

#if OGRE_PLATFORM == OGRE_PLATFORM_WIN32
#define WIN32_LEAN_AND_MEAN
#include "windows.h"
#endif

int main(int argc, char* argv[])
{
    (void)argc;
    (void)argv;

    // Create application object
    DemoTest app;

    try
    {
        app.Run();
    }
    catch( Ogre::Exception& error )
    {
#if OGRE_PLATFORM == OGRE_PLATFORM_WIN32
        MessageBox(
            NULL,
            error.getFullDescription().c_str(),
            "An exception has occured!",
            MB_OK | MB_ICONERROR | MB_TASKMODAL);
#else
        std::cerr << "An exception has occured: " <<
            error.getFullDescription().c_str() << std::endl;
#endif
    }

    return 0;
}