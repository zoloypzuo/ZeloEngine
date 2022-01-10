// LogManager.cpp.cc
// created on 2021/12/23
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "LogManager.h"

#include <spdlog/sinks/stdout_color_sinks.h>
#include <spdlog/sinks/basic_file_sink.h>
#include <spdlog/sinks/rotating_file_sink.h>

template<> Zelo::Core::Log::LogManager *Zelo::Singleton<Zelo::Core::Log::LogManager>::msSingleton = nullptr;

namespace Zelo::Core::Log {

LogManager *LogManager::getSingletonPtr() {
    return msSingleton;
}

LogManager::LogManager() {
    // root
    {
        const std::string pattern = "[%T.%e] [%n] [%^%l%$] %v";  // remove datetime in ts
        auto console_sink = std::make_shared<spdlog::sinks::stdout_color_sink_mt>();
        console_sink->set_level(spdlog::level::info);
        console_sink->set_pattern(pattern);

        auto file_sink = std::make_shared<spdlog::sinks::basic_file_sink_mt>("logs/root.log", true);
        file_sink->set_level(spdlog::level::debug);

        spdlog::sinks_init_list sink_list = {file_sink, console_sink};

        auto logger = std::make_shared<spdlog::logger>("root", sink_list.begin(), sink_list.end());
        logger->set_level(spdlog::level::debug);
        spdlog::set_default_logger(logger);
        spdlog::flush_on(spdlog::level::debug);
    }
    // engine modules
    {
        auto root = spdlog::default_logger();
        spdlog::register_logger(root->clone("window"));
        spdlog::register_logger(root->clone("gl"));
        spdlog::register_logger(root->clone("lua"));
    }
    // gltracer, to single file
    {
        auto file_sink = std::make_shared<spdlog::sinks::basic_file_sink_mt>("logs/gltracer.log", true);
        spdlog::sinks_init_list sink_list = {file_sink};

        auto logger = std::make_shared<spdlog::logger>("gltracer", sink_list.begin(), sink_list.end());
        logger->set_pattern("[%T.%e] %v");
        logger->set_level(spdlog::level::debug);
        logger->flush_on(spdlog::level::debug);
        spdlog::register_logger(logger);
    }
}

LogManager::~LogManager() {
    spdlog::drop_all();
}
}
