#include "stdafx.h"
#include "interfaceDll.h"

class VRSystem{
private:
	std::string idExame, idSerie;
	vtkRenderer* renderer;
	vtkWin32OpenGLRenderWindow* renderWindow;
	vtkWin32RenderWindowInteractor* renderWindowInteractor;
	vtkSmartPointer<vtkImageAlgorithm> image;
	vtkGPUVolumeRayCastMapper *mapper;
	vtkColorTransferFunction *ctf;
	vtkPiecewiseFunction *sof;
	vtkVolume* volume;
	vtkVolumeProperty* prop;
public:
	//Construtor. Cria a tela a partir do contexto de opengl atual.
	VRSystem(std::string idExame, std::string idSerie){
		image = nullptr;
		this->idExame = idExame;
		this->idSerie = idSerie;
		renderer = vtkRenderer::New();
		//renderer->DebugOn();
		renderer->SetBackground(0, 1, 0);
		renderWindow = vtkWin32OpenGLRenderWindow::New();
		//renderWindow->DebugOn();
		renderWindow->InitializeFromCurrentContext();
		renderWindow->AddRenderer(renderer);
		renderWindowInteractor = vtkWin32RenderWindowInteractor::New();
		//renderWindowInteractor->DebugOn();
		renderWindowInteractor->InstallMessageProcOn();
		renderWindow->SetInteractor(renderWindowInteractor);
		renderWindow->Render();
	}
	~VRSystem(){
		renderer->Delete();
		renderWindow->Delete();
		renderWindowInteractor->Delete();
		mapper->Delete();
		ctf->Delete();
		sof->Delete();
		volume->Delete();
		prop->Delete();
	}
	//Bota a imagem dada na tela.
	void SetImage(vtkSmartPointer<vtkImageAlgorithm> img){
		image = img;
		image->Update();
		mapper = vtkGPUVolumeRayCastMapper::New();
		mapper->SetInputConnection(img->GetOutputPort());
		prop = vtkVolumeProperty::New();
		ctf = vtkColorTransferFunction::New();
		ctf->AddRGBSegment(500, 0, 0, 0, 800, 0, 0, 0);
		ctf->AddRGBSegment(801, 1, 0, 0, 1100, 1, 0, 0);
		ctf->AddRGBSegment(1101, 1, 1, 0, 1400, 1, 1, 0);
		ctf->AddRGBSegment(1401, 1, 1, 0, 3000, 1, 1, 1);
		ctf->ClampingOn();
		sof = vtkPiecewiseFunction::New();
		sof->ClampingOn();
		sof->AddSegment(500, 0, 800, 0);
		sof->AddSegment(801, 0, 1100, 0.2);
		sof->AddSegment(1101, 0.2, 1400, 0.7);
		sof->AddSegment(1401, 0.7, 3000, 1.0);
		prop->SetColor(ctf);
		prop->SetScalarOpacity(sof);
		prop->ShadeOn();
		volume = vtkVolume::New();
		volume->SetMapper(mapper);
		volume->SetProperty(prop);

		renderer->AddVolume(volume);
		renderer->ResetCamera();
		renderWindow->Render();
	}

	void SetColorFunction(ColorTransferFunctionStruct *data){
		ctf->Delete();
		sof->Delete();
		ctf = vtkColorTransferFunction::New();
		sof = vtkPiecewiseFunction::New();
		for (int i = 0; i < data->numColorPoints-2; i++){
			//float _x, _v0, _v1, _v2, _v3, _midpoint, _sharpness;
			ColorPointStruct currPt = data->points[i];
			ColorPointStruct nextPt = data->points[i+1];
			ctf->AddRGBSegment(currPt._x, currPt._v0, currPt._v1, currPt._v2,
				currPt._x, currPt._v0, currPt._v1, currPt._v2);
			sof->AddSegment(currPt._x, currPt._v3, nextPt._x, nextPt._v3);
		}
		prop->SetColor(ctf);
		prop->SetScalarOpacity(sof);
	}
	//Renderiza
	void Render(){
		renderWindow->Render();
	}
};

std::shared_ptr<VRSystem> sys = nullptr;;

void _stdcall SetFuncaoDeCor(ColorTransferFunctionStruct* data){
	sys->SetColorFunction(data);
	sys->Render();
}

void _stdcall CreateScreenFromContext(){
	//Criação da janela.
	if (!sys)
		sys = std::make_shared<VRSystem>("foo", "bar");
	//Adiciona à tela
	// Read all the DICOM files in the specified directory.
	vtkSmartPointer<vtkDICOMImageReader> reader = vtkSmartPointer<vtkDICOMImageReader>::New();
	reader->SetDirectoryName("C:\\meus dicoms\\Marching Man");
	reader->Update();
	sys->SetImage(reader);
}

void _stdcall Render(){
	if (sys)
		sys->Render();
}