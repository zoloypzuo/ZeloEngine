// ZeloIOStream.h
// created on 2021/12/10
// author @zoloypzuo
#pragma once

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

    std::unique_ptr<std::fstream> m_file;
};
}
