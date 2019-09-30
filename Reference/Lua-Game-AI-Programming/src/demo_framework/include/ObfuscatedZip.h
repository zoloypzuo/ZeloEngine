/**
 * Ogre Wiki Source Code Public Domain (Un)License
 * The source code on the Ogre Wiki is free and unencumbered
 * software released into the public domain.
 *
 * Anyone is free to copy, modify, publish, use, compile, sell, or
 * distribute this software, either in source code form or as a compiled
 * binary, for any purpose, commercial or non-commercial, and by any
 * means.
 *
 * In jurisdictions that recognize copyright laws, the author or authors
 * of this software dedicate any and all copyright interest in the
 * software to the public domain. We make this dedication for the benefit
 * of the public at large and to the detriment of our heirs and
 * successors. We intend this dedication to be an overt act of
 * relinquishment in perpetuity of all present and future rights to this
 * software under copyright law.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
 * OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 *
 * For more information, please refer to http://unlicense.org/
 */

/**
 * The source code in this file is attributed to the Ogre wiki article at
 * http://www.ogre3d.org/tikiwiki/Obfuscated+Zip
 */
#ifndef DEMO_FRAMEWORK_OBFUSCATED_ZIP_H
#define DEMO_FRAMEWORK_OBFUSCATED_ZIP_H

#include "ogre3d/include/OgreArchive.h"
#include "ogre3d/include/OgreArchiveFactory.h"

// Forward declaration for zziplib to avoid header file dependency.
typedef struct zzip_dir ZZIP_DIR;
typedef struct zzip_file ZZIP_FILE;

/** Specialization of the Archive class to allow reading of files from an
    obfuscated zip format source archive.
@remarks
    This archive format supports obfuscated zip archives.
*/
class ObfuscatedZip : public Ogre::Archive
{
protected:
    /// Handle to root zip file
    ZZIP_DIR* mZzipDir;
    /// Handle any errors from zzip
    void checkZzipError(int zzipError, const Ogre::String& operation) const;
    /// File list (since zziplib seems to only allow scanning of dir tree once)
    Ogre::FileInfoList mFileList;

public:
    ObfuscatedZip(const Ogre::String& name, const Ogre::String& archType );
    ~ObfuscatedZip();
    /// @copydoc Archive::isCaseSensitive
    bool isCaseSensitive(void) const { return false; }

    /// @copydoc Archive::load
    void load();
    /// @copydoc Archive::unload
    void unload();

    /// @copydoc Archive::open
    Ogre::DataStreamPtr open(const Ogre::String& filename, bool readOnly = true) const;

    /// @copydoc Archive::list
    Ogre::StringVectorPtr list(bool recursive = true, bool dirs = false);

    /// @copydoc Archive::listFileInfo
    Ogre::FileInfoListPtr listFileInfo(bool recursive = true, bool dirs = false);

    /// @copydoc Archive::find
    Ogre::StringVectorPtr find(const Ogre::String& pattern, bool recursive = true,
        bool dirs = false);

    /// @copydoc Archive::findFileInfo
    Ogre::FileInfoListPtr findFileInfo(const Ogre::String& pattern, bool recursive = true,
        bool dirs = false) const;

    /// @copydoc Archive::exists
    bool exists(const Ogre::String& filename);

    /// @copydoc Archive::getModifiedTime
    time_t getModifiedTime(const Ogre::String& filename);
};

/** Specialization of ArchiveFactory for Obfuscated Zip files. */
class ObfuscatedZipFactory : public Ogre::ArchiveFactory
{
public:
    virtual ~ObfuscatedZipFactory() {}
    /// @copydoc FactoryObj::getType
    const Ogre::String& getType(void) const;
    /// @copydoc FactoryObj::createInstance
    Ogre::Archive *createInstance( const Ogre::String& name, bool readOnly )
    {
        return new ObfuscatedZip(name, "Obf");
    }
    /// @copydoc FactoryObj::destroyInstance
    void destroyInstance( Ogre::Archive* arch) { OGRE_DELETE arch; }
};

/** Specialization of DataStream to handle streaming data from zip archives. */
class ObfuscatedZipDataStream : public Ogre::DataStream
{
protected:
    ZZIP_FILE* mZzipFile;
public:
    /// Unnamed constructor
    ObfuscatedZipDataStream(ZZIP_FILE* zzipFile, size_t uncompressedSize);
    /// Constructor for creating named streams
    ObfuscatedZipDataStream(const Ogre::String& name, ZZIP_FILE* zzipFile, size_t uncompressedSize);
    ~ObfuscatedZipDataStream();
    /// @copydoc DataStream::read
    size_t read(void* buf, size_t count);
    /// @copydoc DataStream::skip
    void skip(long count);
    /// @copydoc DataStream::seek
    void seek( size_t pos );
    /// @copydoc DataStream::seek
    size_t tell(void) const;
    /// @copydoc DataStream::eof
    bool eof(void) const;
    /// @copydoc DataStream::close
    void close(void);
};

#endif  // DEMO_FRAMEWORK_OBFUSCATED_ZIP_H
