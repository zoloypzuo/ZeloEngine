// Asset.cpp
// created on 2021/3/31
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "Asset.h"
#include "Engine.h"

#ifdef EMSCRIPTEN
#elif ANDROID
#else
#endif

EngineIOStream::EngineIOStream(const std::string &fileName) : m_fileName(fileName) {
#ifdef ANDROID
    m_file = AAssetManager_open(AndroidAssetManager::getAssetManager(), fileName.c_str(), AASSET_MODE_UNKNOWN);
#elif EMSCRIPTEN
    m_file = new std::fstream(ASSET_DIR + fileName, std::ifstream::binary | std::fstream::in | std::fstream::out);
#else
    spdlog::debug("EngineIOStream {}", fileName);
    // fallback search
    std::filesystem::path filePath{};
    std::filesystem::path resourceDir{};
    auto resourceConfigLuaPath = Engine::getSingletonPtr()->getConfigDir() / "resource_config.lua";
    sol::table resourceDirList = LuaScriptManager::getSingletonPtr()->require_file(
            resourceConfigLuaPath.string(),
            resourceConfigLuaPath.string());
    for (const auto& pair : resourceDirList ) {
        resourceDir = pair.second.as<std::string>();
        auto resourcePath = resourceDir / fileName;
        if(std::filesystem::exists(resourcePath)){
            filePath = resourcePath;
            break;
        };
    }
    if(filePath.empty()){
        auto engineAssetPath = Engine::getSingletonPtr()->getAssetDir() / fileName;
        if (std::filesystem::exists(engineAssetPath)) {
            filePath = engineAssetPath;
        } else {
            auto enginePath = Engine::getSingletonPtr()->getEngineDir() / fileName;
            ZELO_ASSERT(std::filesystem::exists(enginePath));
            filePath = enginePath;
        }
    }

    spdlog::debug("EngineIOStream {} => {}", fileName, filePath);
    m_file = new std::fstream(
            filePath.c_str(),
            std::ifstream::binary | std::fstream::in | std::fstream::out);
#endif
}

EngineIOStream::~EngineIOStream() {
#ifndef ANDROID
    delete m_file;
#else
    AAsset_close(m_file);
#endif
}

size_t EngineIOStream::read(void *pvBuffer, size_t pSize, size_t pCount) {
#ifndef ANDROID
    m_file->read((char *) pvBuffer, pSize * pCount);
    return static_cast<size_t>(m_file->gcount());
#else
    return AAsset_read(m_file, (char *)pvBuffer, pSize * pCount);
#endif
}

size_t EngineIOStream::write(const void *pvBuffer, size_t pSize, size_t pCount) {
#ifndef ANDROID
    m_file->write((char *) pvBuffer, pSize * pCount);
    return pSize * pCount;
#else
    return 0;
#endif
}

bool EngineIOStream::seek(size_t pOffset, origin pOrigin) {
    switch (pOrigin) {
        case Origin_SET:
#ifndef ANDROID
            m_file->seekg(pOffset, std::ios::beg);
#else
            AAsset_seek(m_file, pOffset, std::ios::beg);
#endif
            break;

        case Origin_CUR:
#ifndef ANDROID
            m_file->seekg(pOffset, std::ios::cur);
#else
            AAsset_seek(m_file, pOffset, std::ios::cur);
#endif
            break;

        case Origin_END:
#ifndef ANDROID
            m_file->seekg(pOffset, std::ios::end);
#else
            AAsset_seek(m_file, pOffset, std::ios::end);
#endif
            break;
    }

#ifndef ANDROID
    if (!m_file->good()) {
        return false;
    }
#endif

    return true;
}

size_t EngineIOStream::tell() const {
#ifndef ANDROID
    return static_cast<size_t >(m_file->tellg());
#else
    return AAsset_getLength(m_file) - AAsset_getRemainingLength(m_file);
#endif
}

size_t EngineIOStream::fileSize() const {
#ifndef ANDROID
    size_t cur = static_cast<size_t>(m_file->tellg());
    m_file->seekg(0, std::ios::end);

    size_t end = static_cast<size_t>(m_file->tellg());
    m_file->seekg(cur, std::ios::beg);

    return end;
#else
    return AAsset_getLength(m_file);
#endif
}

void EngineIOStream::flush() {
#ifndef ANDROID
    m_file->flush();
#endif
}

std::string EngineIOStream::getFileName() {
    return m_fileName;
}

Asset::Asset(const std::string &fileName) {
    m_ioStream = new EngineIOStream(fileName);
    m_fileSize = m_ioStream->fileSize();
    m_buffer = new char[m_fileSize + 1];
    m_buffer[m_fileSize] = '\0';
}

Asset::~Asset() {
    delete[] m_buffer;
    delete m_ioStream;
}

const char *Asset::read() const {
    m_ioStream->read(m_buffer, sizeof(char), m_fileSize);

    return m_buffer;
}

EngineIOStream *Asset::getIOStream() const {
    return m_ioStream;
}
