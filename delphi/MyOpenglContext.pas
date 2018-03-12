unit MyOpenGLContext;
interface

uses
  Windows, opengl;

type
//Guarda as informações do contexto do opengl.
TMyOpenGLContext = record
  wnd : HWND;
  dc  : HDC;
  glrc: HGLRC;
end;

//Cria um contexto pro hwnd dado.
function myCreateContextForWindow(wnd:HWND):TMyOpenGLContext;
//Destroi o contexto criado com CreateContextForWindow
procedure myDestroyContext(ctx:TMyOpenGLContext);
//Inicialização do opengl.
procedure myGLInit();
//Setagem do pixel format do DeviceContext, parte do ritual do CreateContextForWindow.
procedure mySetupPixelFormat(DC:HDC);

implementation

//------------------------------------------------------------------------------
function myCreateContextForWindow(wnd:HWND):TMyOpenGLContext;
var
  ctx:TMyOpenGLContext;
begin
  ctx.wnd := wnd;
  ctx.dc := GetDC(ctx.wnd);
  mySetupPixelFormat(ctx.dc);
  ctx.glrc := wglCreateContext(ctx.dc);
  wglMakeCurrent(ctx.dc,ctx.glrc);
  Result := ctx;
end;
//------------------------------------------------------------------------------
procedure myDestroyContext(ctx:TMyOpenGLContext);
begin
  wglMakeCurrent(ctx.dc, ctx.glrc);
  wglDeleteContext(ctx.glrc);
end;
//------------------------------------------------------------------------------
procedure myGLInit;
begin
   // set viewing projection
   glMatrixMode(GL_PROJECTION);
   glFrustum(-0.1, 0.1, -0.1, 0.1, 0.3, 25.0);
   // position viewer
   glMatrixMode(GL_MODELVIEW);
   glEnable(GL_DEPTH_TEST);
end;
//------------------------------------------------------------------------------
procedure mySetupPixelFormat(DC:HDC);
const
   pfd:TPIXELFORMATDESCRIPTOR = (
        nSize:sizeof(TPIXELFORMATDESCRIPTOR);	// size
        nVersion:1;			// version
        dwFlags:PFD_SUPPORT_OPENGL or PFD_DRAW_TO_WINDOW or
                PFD_DOUBLEBUFFER;	// support double-buffering
        iPixelType:PFD_TYPE_RGBA;	// color type
        cColorBits:24;			// preferred color depth
        cRedBits:0; cRedShift:0;	// color bits (ignored)
        cGreenBits:0;  cGreenShift:0;
        cBlueBits:0; cBlueShift:0;
        cAlphaBits:0;  cAlphaShift:0;   // no alpha buffer
        cAccumBits: 0;
        cAccumRedBits: 0;  		// no accumulation buffer,
        cAccumGreenBits: 0;     	// accum bits (ignored)
        cAccumBlueBits: 0;
        cAccumAlphaBits: 0;
        cDepthBits:16;			// depth buffer
        cStencilBits:0;			// no stencil buffer
        cAuxBuffers:0;			// no auxiliary buffers
        iLayerType:PFD_MAIN_PLANE;  	// main layer
   bReserved: 0;
   dwLayerMask: 0;
   dwVisibleMask: 0;
   dwDamageMask: 0;                    // no layer, visible, damage masks
   );
var pixelFormat:integer;
begin
   pixelFormat := ChoosePixelFormat(DC, @pfd);
   if (pixelFormat = 0) then
        exit;
   if (SetPixelFormat(DC, pixelFormat, @pfd) <> TRUE) then
        exit;
end;

end.
