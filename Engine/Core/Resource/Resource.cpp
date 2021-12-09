// Resource.cpp
// created on 2021/3/31
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "Resource.h"

namespace Zelo {
Resource::Resource(const std::string &fileName) {
    m_ioStream = new IOStream(fileName);
    m_fileSize = m_ioStream->fileSize();
    m_buffer = new char[m_fileSize + 1];
    m_buffer[m_fileSize] = '\0';
}

Resource::~Resource() {
    delete[] m_buffer;
    delete m_ioStream;
}

const char *Resource::read() const {
    m_ioStream->read(m_buffer, sizeof(char), m_fileSize);

    return m_buffer;
}

IOStream *Resource::getIOStream() const {
    return m_ioStream;
}

size_t Resource::getFileSize() const {
    return m_fileSize;
}

void *Resource::readCopy() const {
    const char *data = read();
    auto size = m_fileSize;
    void *buffer = new char[size];
    memcpy(buffer, data, size);
    return buffer;
}
}