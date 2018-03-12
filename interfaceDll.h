#pragma once
#include <Windows.h>
typedef struct ColorPointStruct{
	float _x, _v0, _v1, _v2, _v3, _midpoint, _sharpness;
};

struct ColorTransferFunctionStruct{
	int numColorPoints;
	ColorPointStruct* points;
};

#define DLL_INTERFACE __declspec(dllexport)
extern "C"
{
	DLL_INTERFACE void _stdcall CreateScreenFromContext();
	DLL_INTERFACE void _stdcall Render();
	DLL_INTERFACE void _stdcall SetFuncaoDeCor(ColorTransferFunctionStruct* data);
}