#include "my_sandbox/include/MySandbox.h"
#include "ogre3d/include/OgreException.h"

#define WIN32_LEAN_AND_MEAN
#include "windows.h"

int main()
{
	MySandbox app;
	try
	{
		app.Run();
	}
	catch (Ogre::Exception& err)
	{
		MessageBox(
			nullptr,
			err.getFullDescription().c_str(),
			"",
			MB_OK | MB_ICONERROR | MB_TASKMODAL
		);
	}
	return 0;
}
