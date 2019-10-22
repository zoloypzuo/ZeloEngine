#ifndef DEMO_FRAMEWORK_LUA_FILE_H
#define DEMO_FRAMEWORK_LUA_FILE_H

#include "ogre3d/include/OgreResource.h"

class LuaFile : public Ogre::Resource
{
public:
	LuaFile(
		Ogre::ResourceManager* creator,
		const Ogre::String& resourceName,
		Ogre::ResourceHandle handle,
		const Ogre::String& group,
		bool isManual = false,
		Ogre::ManualResourceLoader* loader = nullptr);

	virtual ~LuaFile();

	const char* GetData() const;

	size_t GetDataLength() const;

	void SetData(const char* data, size_t dataLength);

protected:
	size_t calculateSize() const override;

	void loadImpl() override;

	void unloadImpl() override;

private:
	const char* binaryData_;
	size_t dataLength_;

	/**
	 * Unimplemented copy constructor.
	 */
	LuaFile(const LuaFile&);

	/**
	 * Unimplemented assignment operator.
	 */
	LuaFile& operator=(const LuaFile&);
}; // class LuaFile

#endif  // DEMO_FRAMEWORK_LUA_FILE_H
