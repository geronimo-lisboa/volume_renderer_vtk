{
  Um Painel com um contexto opengl, necessário para o funcionamento do VR.
  O contexto é criado quando o painel é exibido com OnShow e destruído no OnDestroy.
}
unit MyOpenGlPanel;

interface

uses
  SysUtils, Classes, Controls, ExtCtrls, OpenGL, Windows, Dialogs, Messages, MyOpenglContext, Graphics;

type
  FOnRenderCallback = procedure() of object;
  FOnMouseWheel = procedure(var Message: TWMMouseWheel)of object;
//  TMyOpenGlPanel = class(TCustomPanel)
  TMyOpenGlPanel = class(TCustomPanel)
  private
    openGLAlredyInitialized:boolean;
    oglCtx : TMyOpenGLContext;
    _onRenderCallback : FOnRenderCallback;
    _onMouseWheelCbk : FOnMouseWheel;
    procedure InitOpenGLContext();
    procedure Render();
  protected
    procedure WndProc(var Message: TMessage); override;
    procedure Paint();override;
    procedure InternalOnMouseWheel(var Message: TWMMouseWheel); message WM_MOUSEWHEEL;

    property OnMouseWheel : FOnMouseWheel read  _onMouseWheelCbk write _onMouseWheelCbk;
  public
    constructor create(owner:TComponent);override;
    destructor destroy();override;
    procedure MakeCurrent();
    procedure UnmakeCurrent();
    function GetCanvas():TCanvas;
  published
    property DragCursor;
    property DragKind;
    property DragMode;
	  property OnDragDrop;
	  property OnDragOver;
  	property OnEndDrag;
    property OnDblClick;
    property OnRenderCallback : FOnRenderCallback read _onRenderCallback write _onRenderCallback;
    property GLRC : cardinal read oglCtx.glrc;
    property DC : HDC read oglCtx.dc;
  end;

procedure Register;

implementation

procedure TMyOpenGlPanel.InternalOnMouseWheel(var Message: TWMMouseWheel);
begin
  if  Assigned(_onMouseWheelCbk) then
  begin
    _onMouseWheelCbk(Message);
  end;
end;

function TMyOpenGlPanel.GetCanvas():TCanvas;
begin
  result := Canvas;
end;

procedure TMyOpenGlPanel.UnmakeCurrent();
begin
  wglMakeCurrent(oglCtx.dc, 0);
end;

procedure TMyOpenGlPanel.MakeCurrent();
begin
  wglMakeCurrent(oglCtx.dc, oglCtx.glrc);
end;

destructor TMyOpenGlPanel.destroy();
begin
//  ShowMessage('TMyOpenGlPanel.destroy');
  myDestroyContext(oglCtx);
  inherited destroy;
//  ShowMessage('TMyOpenGlPanel.destroy fim');
end;

procedure TMyOpenGlPanel.InitOpenGLContext();
begin
  OutputDebugString('myComp : entrou no InitOpenGLContext');
  oglCtx := myCreateContextForWindow(Self.Handle);
end;

procedure TMyOpenGlPanel.Render();
begin
  wglMakeCurrent(oglCtx.dc, oglCtx.glrc);
  if csDesigning in ComponentState then
  begin
    if (Height = 0) then                // prevent divide by zero exception
      Height := 1;
    glViewport(0, 0, Width, Height);    // Set the viewport for the OpenGL window
    glMatrixMode(GL_PROJECTION);        // Change Matrix Mode to Projection
    glLoadIdentity();                   // Reset View
    gluPerspective(45.0, Width/Height, 1.0, 100.0);  // Do the perspective calculations. Last value = max clipping depth
    glMatrixMode(GL_MODELVIEW);         // Return to the modelview matrix
    glLoadIdentity();
    glClearColor(Random ,0, 0, 1);
    glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
    glTranslatef(0.0,0.0,-3.0);       // Move the scene back by 3 units (Will be explained in a later Chapter)
    glColor3f(1.0, 1.0, 1.0);         // Set the colour of the objects that will be dawn later
    glOrtho(-1.0, 1.0, -1.0, 1.0, -1.0, 1.0);
    glBegin(GL_POLYGON);              // begin drawing a polygon (Many pointed/ sided shape)
      glVertex2f(-0.5, -0.5);         // Draw a point (Two Dimentional Vertex)
      glVertex2f(-0.5, 0.5);
      glVertex2f(0.5, 0.5);
      glVertex2f(0.5, -0.5);
    glEnd();                          // End the shape
  end
  else
  begin
    if (Assigned (_onRenderCallback))then
    begin
      _onRenderCallback();
    end;
  end;
  SwapBuffers(oglCtx.dc);
end;

procedure TMyOpenGlPanel.Paint();
begin
  //inherited;
  if openGLAlredyInitialized = False then
  begin
    OutputDebugString('TMyOpenGlPanel : init context');
    InitOpenGLContext();
    openGLAlredyInitialized := true;
  end
  else
  begin
    OutputDebugString('TMyOpenGlPanel : render');
    Render();
  end;
end;

procedure TMyOpenGlPanel.WndProc(var Message:TMessage);
begin
  inherited;
  case Message.msg of
    WM_SHOWWINDOW:
    begin

    end;
  end;
end;

constructor TMyOpenGlPanel.Create(owner:TComponent);
begin
  inherited Create(owner);
  DoubleBuffered := True;
  openGLAlredyInitialized := false;
  _onRenderCallback := nil;
  Self.Color:=clBlack;
end;

procedure Register;
begin
  RegisterComponents('Samples', [TMyOpenGlPanel]);
end;

end.


