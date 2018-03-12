#pragma once
#include <Windows.h>
#define DLL_INTERFACE __declspec(dllexport)
extern "C"
{
	DLL_INTERFACE void _stdcall CreateScreen(HWND handle);
	DLL_INTERFACE void _stdcall CreateScreenFromContext();
	DLL_INTERFACE void _stdcall Render();
}