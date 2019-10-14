#include "PrecompiledHeaders.h"

#include "demo_framework/include/LuaFile.h"
#include "demo_framework/include/LuaFileSerializer.h"

LuaFile::LuaFile(
	Ogre::ResourceManager* const creator,
	const Ogre::String& resourceName,
	Ogre::ResourceHandle handle,
	const Ogre::String& group,
	const bool isManual,
	Ogre::ManualResourceLoader* const loader)
	: Ogre::Resource(creator, resourceName, handle, group, isManual, loader),
	  binaryData_(nullptr),
	  dataLength_(0)
{
	createParamDictionary("LuaFile");
}

LuaFile::~LuaFile()
{
	unload();
}

size_t LuaFile::calculateSize() const
{
	return dataLength_;
}

const char* LuaFile::GetData() const
{
	return binaryData_;
}

size_t LuaFile::GetDataLength() const
{
	return dataLength_;
}

void LuaFile::loadImpl()
{
	LuaFileSerializer serializer;

	Ogre::DataStreamPtr stream =
		Ogre::ResourceGroupManager::getSingleton().openResource(
			mName, mGroup, true, this);

	serializer.ImportLuaFile(stream, this);
}

void LuaFile::SetData(const char* const data, const size_t dataLength)
{
	binaryData_ = data;
	dataLength_ = dataLength;
}

void LuaFile::unloadImpl()
{
	if (binaryData_)
	{
		delete binaryData_;
		binaryData_ = nullptr;
		dataLength_ = 0;
	}
}
