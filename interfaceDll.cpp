#include "stdafx.h"
#include "interfaceDll.h"
vtkSmartPointer<vtkRenderer> renderer = nullptr;
vtkSmartPointer<vtkWin32OpenGLRenderWindow> renderWindow = nullptr;
vtkSmartPointer<vtkWin32RenderWindowInteractor> renderWindowInteractor = nullptr;

vtkSmartPointer<vtkVolume> CreateVolume(){
	// Read all the DICOM files in the specified directory.
	vtkSmartPointer<vtkDICOMImageReader> reader = vtkSmartPointer<vtkDICOMImageReader>::New();
	reader->SetDirectoryName("C:\\meus dicoms\\Marching Man");
	reader->Update();
	auto mapper = vtkSmartPointer<vtkGPUVolumeRayCastMapper>::New();
	mapper->SetInputData(reader->GetOutput());
	auto prop = vtkSmartPointer<vtkVolumeProperty>::New();
	auto ctf = vtkSmartPointer<vtkColorTransferFunction>::New();
	ctf->AddRGBSegment(500, 0, 0, 0, 800, 0, 0, 0);
	ctf->AddRGBSegment(801, 1, 0, 0, 1100, 1, 0, 0);
	ctf->AddRGBSegment(1101, 1, 1, 0, 1400, 1, 1, 0);
	ctf->AddRGBSegment(1401, 1, 1, 0, 3000, 1, 1, 1);
	ctf->ClampingOn();
	auto sof = vtkSmartPointer<vtkPiecewiseFunction>::New();
	sof->ClampingOn();
	sof->AddSegment(500, 0, 800, 0);
	sof->AddSegment(801, 0, 1100, 0.2);
	sof->AddSegment(1101, 0.2, 1400, 0.7);
	sof->AddSegment(1401, 0.7, 3000, 1.0);
	prop->SetColor(ctf);
	prop->SetScalarOpacity(sof);
	prop->ShadeOn();
	auto volume = vtkSmartPointer<vtkVolume>::New();
	volume->SetMapper(mapper);
	volume->SetProperty(prop);
	return volume;
}

void _stdcall CreateScreenFromContext(){
	//Criação da janela.
	renderer = vtkSmartPointer<vtkRenderer>::New();
	renderer->SetBackground(0, 1, 0);
	renderWindow = vtkSmartPointer<vtkWin32OpenGLRenderWindow>::New();
	renderWindow->InitializeFromCurrentContext();
	renderWindow->AddRenderer(renderer);
	renderWindowInteractor = vtkSmartPointer<vtkWin32RenderWindowInteractor>::New();
	renderWindowInteractor->InstallMessageProcOn();
	renderWindow->SetInteractor(renderWindowInteractor);
	renderWindow->Render();
	//Adiciona à tela
	auto volume = CreateVolume();
	renderer->AddVolume(volume);
	renderer->ResetCamera();
	renderWindow->Render();

}

void _stdcall CreateScreen(HWND handle){
	//Criação da janela.
	renderer = vtkSmartPointer<vtkRenderer>::New();
	renderer->SetBackground(1, 0, 0);
	renderWindow = vtkSmartPointer<vtkWin32OpenGLRenderWindow>::New();
	renderWindow->SetWindowId(handle);
	renderWindow->AddRenderer(renderer);
	renderWindowInteractor = vtkSmartPointer<vtkWin32RenderWindowInteractor>::New();
	renderWindowInteractor->InstallMessageProcOn();
	renderWindow->SetInteractor(renderWindowInteractor);
	renderWindow->Render();
	//Adiciona à tela
	auto volume = CreateVolume();
	renderer->AddVolume(volume);
	renderer->ResetCamera();
	renderWindow->Render();
}

void _stdcall Render(){
	if (renderWindow)
		renderWindow->Render();
}