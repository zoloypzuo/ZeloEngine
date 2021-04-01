// Asset.h
// created on 2021/3/31
// author @zoloypzuo

#ifndef ZELOENGINE_ASSET_H
#define ZELOENGINE_ASSET_H

#include "ZeloPrerequisites.h"

#include <fstream>

#ifdef ANDROID
#include "AndroidAssetManager.h"
#endif

enum origin {
    Origin_SET,
    Origin_CUR,
    Origin_END
};

class EngineIOStream {
public:
    explicit EngineIOStream(const std::string &fileName);

    ~EngineIOStream();

    size_t read(void *pvBuffer, size_t pSize, size_t pCount);

    size_t write(const void *pvBuffer, size_t pSize, size_t pCount);

    bool seek(size_t pOffset, origin pOrigin);

    size_t tell() const;

    size_t fileSize() const;

    void flush();

    std::string getFileName();

private:
    std::string m_fileName;

#ifndef ANDROID
    std::fstream *m_file;
#else
    AAsset *m_file;
#endif
};

class Asset {
public:
    explicit Asset(const std::string &fileName);

    ~Asset();

    const char *read() const;

    EngineIOStream *getIOStream() const;

private:
    char *m_buffer;
    EngineIOStream *m_ioStream;
    size_t m_fileSize;
};


#endif //ZELOENGINE_ASSET_H