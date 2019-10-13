# install_vcpkg.ps1
# created on 2019/10/12
# author @zoloypzuo

cd D:\vcpkg
.\bootstrap-vcpkg.bat
.\vcpkg integrate install  # need admin
.\vcpkg integrate powershell  # need restart console