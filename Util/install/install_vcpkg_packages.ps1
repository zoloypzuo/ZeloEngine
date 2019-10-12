# install_vcpkg_packages.ps1
# created on 2019/10/12
# author @zoloypzuo

#find_package(spdlog CONFIG REQUIRED)
#target_link_libraries(main PRIVATE spdlog::spdlog)
vcpkg install spdlog:x86-windows
vcpkg install spdlog:x64-windows


vcpkg install boost:x86-windows
vcpkg install boost:x64-windows