; SPDX-License-Identifier: GPL-3.0-or-later
; CCLibVLC example: 2x2 grid of IP camera streams (RTSP) in a resizable window.
; Enter your camera URLs below. Streams that fail are restarted every 10 seconds.
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include "..\CCGUICtrlVLC.au3"

Global $aUrl[4] = ["rtsp://user:password@192.168.1.10:554/stream1", "rtsp://192.168.1.11/live", "", ""]
Global Const $sCamOptions = ":network-caching=300|:rtsp-tcp" ; low latency, RTSP over TCP (more robust)

If Not _VLC_Startup() Then Exit MsgBox(16, "CCLibVLC", _VLC_GetLastError())
Global $hGui = GUICreate("Cameras", 960, 560, -1, -1, BitOR($GUI_SS_DEFAULT_GUI, $WS_SIZEBOX, $WS_MAXIMIZEBOX))
Global $aCam[4], $aRetry[4], $iX, $iY, $iState
For $i = 0 To 3
	$iX = Mod($i, 2) * 480
	$iY = Int($i / 2) * 280
	$aCam[$i] = _GUICtrlVLC_Create($iX, $iY, 480, 280)
	_GUICtrlVLC_SetResizing($aCam[$i], $GUI_DOCKAUTO) ; every tile scales with the window
	_GUICtrlVLC_SetMute($aCam[$i], True)
	$aRetry[$i] = 0
Next
GUISetState()

While 1
	Switch GUIGetMsg()
		Case $GUI_EVENT_CLOSE
			ExitLoop
		Case _GUICtrlVLC_GetCtrlID($aCam[0]), _GUICtrlVLC_GetCtrlID($aCam[1]), _GUICtrlVLC_GetCtrlID($aCam[2]), _GUICtrlVLC_GetCtrlID($aCam[3])
			For $i = 0 To 3
				If @GUI_CtrlId = _GUICtrlVLC_GetCtrlID($aCam[$i]) And _GUICtrlVLC_IsDoubleClick($aCam[$i]) Then _GUICtrlVLC_ToggleFullscreen($aCam[$i])
			Next
	EndSwitch
	; (re)start streams that are not running, at most every 10 s per camera
	For $i = 0 To 3
		If $aUrl[$i] = "" Then ContinueLoop
		$iState = _GUICtrlVLC_GetState($aCam[$i])
		If $iState >= $VLC_STATE_OPENING And $iState <= $VLC_STATE_PAUSED Then ContinueLoop
		If $aRetry[$i] <> 0 And TimerDiff($aRetry[$i]) < 10000 Then ContinueLoop
		$aRetry[$i] = TimerInit()
		_GUICtrlVLC_Open($aCam[$i], $aUrl[$i], $sCamOptions)
	Next
WEnd
