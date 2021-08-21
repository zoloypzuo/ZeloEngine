// Resource.h
// created on 2021/3/31
// author @zoloypzuo

#ifndef ZELOENGINE_RESOURCE_H
#define ZELOENGINE_RESOURCE_H

#include "ZeloPrerequisites.h"

namespace Zelo {
enum origin {
    Origin_SET,
    Origin_CUR,
    Origin_END
};

class IOStream {
public:
    explicit IOStream(const std::string &fileName);

    ~IOStream();

    size_t read(void *pvBuffer, size_t pSize, size_t pCount);

    size_t write(const void *pvBuffer, size_t pSize, size_t pCount);

    bool seek(size_t pOffset, origin pOrigin);

    size_t tell() const;

    size_t fileSize() const;

    void flush();

    std::string getFileName();

private:
    std::string m_fileName;

    std::fstream *m_file;
};

class Resource {
public:
    explicit Resource(const std::string &fileName);

    ~Resource();

public:
    IOStream *getIOStream() const;

    size_t getFileSize() const;

public:
    const char *read() const;

    void * readCopy() const;

private:
    char *m_buffer;
    IOStream *m_ioStream;
    size_t m_fileSize;
};
}

#endif //ZELOENGINE_RESOURCE_H