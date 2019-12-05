#include <APISysConstants.au3>
#include <GUIConstantsEx.au3>
;#include <SendMessage.au3>
;#include <StaticConstants.au3>
;#include <WinAPIConv.au3>
;#include <WinAPIGdi.au3>
;#include <WinAPIGdiDC.au3>
;#include <WinAPIHObj.au3>
;#include <WinAPIRes.au3>
#include <WinAPISys.au3>
;#include <WinAPISysWin.au3>
#include <WindowsConstants.au3>

Global $g_isRecording = false
Global $g_isCalibratingCPI = false
Global $g_yawbuffer = 0
Global $g_mousePathBuffer[2] = [0,0]

Global Const $g_hForm = GUICreate("")


Local	 $tRID = DllStructCreate($tagRAWINPUTDEVICE)
DllStructSetData($tRID, 'UsagePage', 0x01) ; Generic Desktop Controls
DllStructSetData($tRID, 'Usage', 0x02) ; Mouse
DllStructSetData($tRID, 'Flags', $RIDEV_INPUTSINK)
DllStructSetData($tRID, 'hTarget', $g_hForm)

; Register HID input to obtain row input from mice
_WinAPI_RegisterRawInputDevices($tRID)

; Register WM_INPUT message
GUIRegisterMsg($WM_INPUT, 'WM_INPUT')

Func WM_INPUT($hWnd, $iMsg, $wParam, $lParam)
    #forceref $iMsg, $wParam
  If $hWnd == $g_hForm Then
      Local $tRIM = DllStructCreate($tagRAWINPUTMOUSE)
      If _WinAPI_GetRawInputData($lParam, $tRIM, DllStructGetSize($tRIM), $RID_INPUT) Then
          Local $mouseDelta[2] = [ DllStructGetData($tRIM, 'LastX') , DllStructGetData($tRIM, 'LastY') ]
          If $g_isRecording Then  
             $g_yawbuffer += $mouseDelta[0]
          EndIf
          If $g_isCalibratingCPI Then
             $g_mousePathBuffer[0] += $mouseDelta[0]
             $g_mousePathBuffer[1] += $mouseDelta[1]
          EndIf
      EndIf
  EndIf
  Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_INPUT
