// ZeloIOStream.cpp.cc
// created on 2021/12/10
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "ZeloIOStream.h"
#include "Core/Resource/ResourceManager.h"

using namespace Zelo::Core::Resource;
namespace Zelo {
IOStream::IOStream(const std::string &fileName) : m_fileName(fileName) {
    const auto &filePath = ResourceManager::getSingletonPtr()->resolvePath(fileName);
    const auto mode = std::ifstream::binary | std::fstream::in | std::fstream::out;
    m_file = std::make_unique<std::fstream>(filePath.c_str(), mode);
}

IOStream::~IOStream() = default;

size_t IOStream::read(void *pvBuffer, size_t pSize, size_t pCount) {
    m_file->read((char *) pvBuffer, pSize * pCount);
    return static_cast<size_t>(m_file->gcount());
}

size_t IOStream::write(const void *pvBuffer, size_t pSize, size_t pCount) {
    m_file->write((char *) pvBuffer, pSize * pCount);
    return pSize * pCount;
}

bool IOStream::seek(size_t pOffset, origin pOrigin) {
    switch (pOrigin) {
        case Origin_SET:
            m_file->seekg(pOffset, std::ios::beg);
            break;

        case Origin_CUR:
            m_file->seekg(pOffset, std::ios::cur);
            break;

        case Origin_END:
            m_file->seekg(pOffset, std::ios::end);
            break;
    }

    if (!m_file->good()) {
        return false;
    }

    return true;
}

size_t IOStream::tell() const {
    return static_cast<size_t >(m_file->tellg());
}

size_t IOStream::fileSize() const {
    size_t cur = static_cast<size_t>(m_file->tellg());
    m_file->seekg(0, std::ios::end);

    size_t end = static_cast<size_t>(m_file->tellg());
    m_file->seekg(cur, std::ios::beg);

    return end;
}

void IOStream::flush() {
    m_file->flush();
}

std::string IOStream::getFileName() {
    return m_fileName;
}
}
