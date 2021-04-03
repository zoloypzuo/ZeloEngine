// WindowsFileDialogs.cpp
// created on 2021/4/2
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "Framework/FileDialogs.h"

std::wstring FileDialogs::OpenFile(const wchar_t *filter, void *windowHandle) {
    OPENFILENAME ofn;
    WCHAR szFile[260] = {0};
    WCHAR currentDir[256] = {0};
    ZeroMemory(&ofn, sizeof(OPENFILENAME));
    ofn.lStructSize = sizeof(OPENFILENAME);
    ofn.hwndOwner = static_cast<HWND>(windowHandle);
    ofn.lpstrFile = szFile;
    ofn.nMaxFile = sizeof(szFile);
    if (GetCurrentDirectory(256, currentDir))
        ofn.lpstrInitialDir = currentDir;
    ofn.lpstrFilter = filter;
    ofn.nFilterIndex = 1;
    ofn.Flags = OFN_PATHMUSTEXIST | OFN_FILEMUSTEXIST | OFN_NOCHANGEDIR;

    if (GetOpenFileName(&ofn) == TRUE)
        return ofn.lpstrFile;
    return {};
}

std::wstring FileDialogs::SaveFile(const wchar_t *filter, void *windowHandle) {
    OPENFILENAME ofn;
    WCHAR szFile[260] = {0};
    WCHAR currentDir[256] = {0};
    ZeroMemory(&ofn, sizeof(OPENFILENAME));
    ofn.lStructSize = sizeof(OPENFILENAME);
    ofn.hwndOwner = static_cast<HWND>(windowHandle);
    ofn.lpstrFile = szFile;
    ofn.nMaxFile = sizeof(szFile);
    if (GetCurrentDirectory(256, currentDir))
        ofn.lpstrInitialDir = currentDir;
    ofn.lpstrFilter = filter;
    ofn.nFilterIndex = 1;
    ofn.Flags = OFN_PATHMUSTEXIST | OFN_OVERWRITEPROMPT | OFN_NOCHANGEDIR;

    ofn.lpstrDefExt = wcschr(filter, '\0') + 1;

    if (GetSaveFileName(&ofn) == TRUE)
        return ofn.lpstrFile;
    return {};
}
