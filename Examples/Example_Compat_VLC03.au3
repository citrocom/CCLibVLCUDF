; SPDX-License-Identifier: GPL-3.0-or-later
; CCLibVLC example: a script written for seangriffin's VLC.au3 v0.3 runs unchanged except for the #include line.
; Original: #include <VLC.au3>   ->   now: #include "CCGUICtrlVLC.au3"
#include <GUIConstantsEx.au3>
#include "..\CCGUICtrlVLC.au3"

_VLCErrorHandlerRegister() ; not needed any more, kept for compatibility

Global $main_gui = GUICreate("VLC.au3 v0.3 compatible", 800, 520)
Global $vlc1 = _GUICtrlVLC_Create(0, 0, 800, 450)
If $vlc1 = False Then Exit MsgBox(16, "VLC", "_GUICtrlVLC_Create failed." & @CRLF & _VLC_GetLastError())
Global $idPlay = GUICtrlCreateButton("Play", 10, 470, 80, 30)
Global $idPause = GUICtrlCreateButton("Pause", 100, 470, 80, 30)
Global $idStop = GUICtrlCreateButton("Stop", 190, 470, 80, 30)
Global $idBack = GUICtrlCreateButton("<< 10 s", 280, 470, 80, 30)
Global $idFwd = GUICtrlCreateButton("10 s >>", 370, 470, 80, 30)
GUISetState()

Global $sFile = FileOpenDialog("Select video", @MyDocumentsDir, "Video (*.*)", 1, "", $main_gui)
If Not @error Then _GUICtrlVLC_Play($vlc1, _GUICtrlVLC_Add($vlc1, $sFile))

While 1
	Switch GUIGetMsg()
		Case $GUI_EVENT_CLOSE
			ExitLoop
		Case $idPlay
			If _GUICtrlVLC_GetState($vlc1) <> 3 Then _GUICtrlVLC_Play($vlc1, 0)
		Case $idPause
			_GUICtrlVLC_Pause($vlc1)
		Case $idStop
			_GUICtrlVLC_Stop($vlc1)
		Case $idBack
			_GUICtrlVLC_SeekRelative($vlc1, -10000)
		Case $idFwd
			_GUICtrlVLC_SeekRelative($vlc1, 10000)
	EndSwitch
WEnd
