// Resource.cpp
// created on 2021/3/31
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "Resource.h"
#include "Core/Resource/ResourceManager.h"
#include "Core/LuaScript/LuaScriptManager.h"

using namespace Zelo::Core::Resource;
using namespace Zelo::Core::LuaScript;

Zelo::IOStream::IOStream(const std::string &fileName) : m_fileName(fileName) {
    // fallback search
    std::filesystem::path filePath{};
    std::filesystem::path resourceDir{};
    auto resourceConfigLuaPath = ResourceManager::getSingletonPtr()->getConfigDir() / "resource_config.lua";
    sol::table resourceDirList = LuaScriptManager::getSingletonPtr()->require_file(
            resourceConfigLuaPath.string(),
            resourceConfigLuaPath.string());
    for (const auto &pair : resourceDirList) {
        resourceDir = pair.second.as<std::string>();
        auto resourcePath = resourceDir / fileName;
        if (std::filesystem::exists(resourcePath)) {
            filePath = resourcePath;
            break;
        };
    }
    if (filePath.empty()) {
        auto engineAssetPath = ResourceManager::getSingletonPtr()->getAssetDir() / fileName;
        if (std::filesystem::exists(engineAssetPath)) {
            filePath = engineAssetPath;
        } else {
            auto enginePath = ResourceManager::getSingletonPtr()->getEngineDir() / fileName;
            ZELO_ASSERT(std::filesystem::exists(enginePath));
            filePath = enginePath;
        }
    }

    const auto mode = std::ifstream::binary | std::fstream::in | std::fstream::out;
    m_file = new std::fstream(filePath.c_str(), mode);
}

Zelo::IOStream::~IOStream() {
    delete m_file;
}

size_t Zelo::IOStream::read(void *pvBuffer, size_t pSize, size_t pCount) {
    m_file->read((char *) pvBuffer, pSize * pCount);
    return static_cast<size_t>(m_file->gcount());
}

size_t Zelo::IOStream::write(const void *pvBuffer, size_t pSize, size_t pCount) {
    m_file->write((char *) pvBuffer, pSize * pCount);
    return pSize * pCount;
}

bool Zelo::IOStream::seek(size_t pOffset, Zelo::origin pOrigin) {
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

size_t Zelo::IOStream::tell() const {
    return static_cast<size_t >(m_file->tellg());
}

size_t Zelo::IOStream::fileSize() const {
    size_t cur = static_cast<size_t>(m_file->tellg());
    m_file->seekg(0, std::ios::end);

    size_t end = static_cast<size_t>(m_file->tellg());
    m_file->seekg(cur, std::ios::beg);

    return end;
}

void Zelo::IOStream::flush() {
    m_file->flush();
}

std::string Zelo::IOStream::getFileName() {
    return m_fileName;
}

Zelo::Resource::Resource(const std::string &fileName) {
    m_ioStream = new Zelo::IOStream(fileName);
    m_fileSize = m_ioStream->fileSize();
    m_buffer = new char[m_fileSize + 1];
    m_buffer[m_fileSize] = '\0';
}

Zelo::Resource::~Resource() {
    delete[] m_buffer;
    delete m_ioStream;
}

const char *Zelo::Resource::read() const {
    m_ioStream->read(m_buffer, sizeof(char), m_fileSize);

    return m_buffer;
}

Zelo::IOStream *Zelo::Resource::getIOStream() const {
    return m_ioStream;
}

size_t Zelo::Resource::getFileSize() const {
    return m_fileSize;
}

const char *Zelo::Resource::readCopy() const {
    const char *data = read();
    auto size = m_fileSize;
    void *buffer = new char[size];
    memcpy(buffer, data, size);
    return static_cast<const char *>(buffer);
}
