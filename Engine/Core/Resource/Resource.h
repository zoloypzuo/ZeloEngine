// Resource.h
// created on 2021/3/31
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "Foundation/ZeloIOStream.h"

namespace Zelo {

class Resource {
public:
    explicit Resource(std::string_view fileName);

    ~Resource();

public:
    IOStream *getIOStream() const;

    size_t getFileSize() const;

public:
    const char *read() const;

    void *readCopy() const;

private:
    char *m_buffer;
    IOStream *m_ioStream;
    size_t m_fileSize;
};
}
