#include "stdafx.h"
#include "loadVolume.h"
#include "utils.h"


int main(int argc, char** argv) {
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
	sof->AddSegment(500, 0, 800,0);
	sof->AddSegment(801, 0, 1100, 0.2);
	sof->AddSegment(1101, 0.2 , 1400, 0.7);
	sof->AddSegment(1401, 0.7, 3000, 1.0);
	prop->SetColor(ctf);
	prop->SetScalarOpacity(sof);
	prop->ShadeOn();
	auto volume = vtkSmartPointer<vtkVolume>::New();
	volume->SetMapper(mapper);
	volume->SetProperty(prop);


	//A tela  PROS PROBLEMAS DO OPENGL
	vtkSmartPointer<vtkRenderer> renderer = vtkSmartPointer<vtkRenderer>::New();
	renderer->AddActor(volume);
	renderer->ResetCamera();
	vtkSmartPointer<vtkRenderWindow> renderWindow = vtkSmartPointer<vtkRenderWindow>::New();
	renderWindow->AddRenderer(renderer);
	vtkSmartPointer<vtkRenderWindowInteractor> renderWindowInteractor = vtkSmartPointer<vtkRenderWindowInteractor>::New();
	renderWindow->SetInteractor(renderWindowInteractor);
	renderWindow->Render();

	///////////////////////////////////////////////////
	//A tela dummy PROS PROBLEMAS DO OPENGL
	vtkSmartPointer<vtkRenderer> rendererDummy = vtkSmartPointer<vtkRenderer>::New();
	rendererDummy->ResetCamera();
	vtkSmartPointer<vtkRenderWindow> renderWindowDummy = vtkSmartPointer<vtkRenderWindow>::New();
	renderWindowDummy->AddRenderer(rendererDummy);
	vtkSmartPointer<vtkRenderWindowInteractor> renderWindowInteractorDummy = vtkSmartPointer<vtkRenderWindowInteractor>::New();
	renderWindowDummy->SetInteractor(renderWindowInteractorDummy);
	renderWindowInteractorDummy->Initialize();
	renderWindowInteractorDummy->Start();

	return EXIT_SUCCESS;
}