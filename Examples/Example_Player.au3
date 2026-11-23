; SPDX-License-Identifier: GPL-3.0-or-later
; CCLibVLC example: complete video player in a resizable window.
;  - open file / URL, play, pause, stop, seek slider, volume slider, mute
;  - double click on the video or the "Fullscreen" button toggles fullscreen (Esc leaves it)
;  - the video follows the window size
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <SliderConstants.au3>
#include <EditConstants.au3>
#include "..\CCGUICtrlVLC.au3"

Opt("GUIOnEventMode", 0)

; libVLC: VLC 3.0 must be installed (same bitness as AutoIt) or copied to @ScriptDir\vlc. You can also pass the
; directory: _VLC_Startup("C:\Tools\vlc-3.0.24")
If Not _VLC_Startup() Then Exit MsgBox(16, "CCLibVLC", "libVLC could not be started:" & @CRLF & _VLC_GetLastError())

Global $hGui = GUICreate("CCLibVLC Player - " & _VLC_GetVersion(), 900, 600, -1, -1, BitOR($GUI_SS_DEFAULT_GUI, $WS_SIZEBOX, $WS_MAXIMIZEBOX))
Global $idUrl = GUICtrlCreateInput("", 10, 10, 610, 24)
GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKTOP + $GUI_DOCKHEIGHT)
Global $idOpenUrl = GUICtrlCreateButton("Open URL", 630, 10, 120, 24)
GUICtrlSetResizing(-1, $GUI_DOCKRIGHT + $GUI_DOCKTOP + $GUI_DOCKSIZE)
Global $idOpenFile = GUICtrlCreateButton("Open file...", 760, 10, 130, 24)
GUICtrlSetResizing(-1, $GUI_DOCKRIGHT + $GUI_DOCKTOP + $GUI_DOCKSIZE)

; the video area
Global $iVlc = _GUICtrlVLC_Create(10, 44, 880, 470)
If Not $iVlc Then Exit MsgBox(16, "CCLibVLC", "Player could not be created:" & @CRLF & _VLC_GetLastError())
_GUICtrlVLC_SetResizing($iVlc, $GUI_DOCKBORDERS)
_GUICtrlVLC_SetEventCallback($iVlc, "OnVlcEvent")

Global $idPos = GUICtrlCreateSlider(10, 520, 880, 26, BitOR($TBS_NOTICKS, $TBS_BOTH))
GUICtrlSetLimit(-1, 1000, 0)
GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKHEIGHT)
Global $idPlay = GUICtrlCreateButton("Play", 10, 556, 70, 30)
GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKSIZE)
Global $idPause = GUICtrlCreateButton("Pause", 85, 556, 70, 30)
GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKSIZE)
Global $idStop = GUICtrlCreateButton("Stop", 160, 556, 70, 30)
GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKSIZE)
Global $idFull = GUICtrlCreateButton("Fullscreen", 235, 556, 90, 30)
GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKSIZE)
Global $idTime = GUICtrlCreateLabel("0:00 / 0:00", 340, 563, 220, 20)
GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKSIZE)
Global $idMute = GUICtrlCreateCheckbox("Mute", 650, 560, 60, 22)
GUICtrlSetResizing(-1, $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKSIZE)
Global $idVol = GUICtrlCreateSlider(715, 556, 175, 30, $TBS_NOTICKS)
GUICtrlSetLimit(-1, 200, 0)
GUICtrlSetData(-1, 100)
GUICtrlSetResizing(-1, $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKSIZE)
GUISetState(@SW_SHOW, $hGui)

Global $hUpdate = TimerInit(), $sFile = ""
While 1
	Switch GUIGetMsg()
		Case $GUI_EVENT_CLOSE
			ExitLoop
		Case $idOpenUrl
			If GUICtrlRead($idUrl) <> "" Then OpenMedia(GUICtrlRead($idUrl))
		Case $idOpenFile
			$sFile = FileOpenDialog("Open media", @MyDocumentsDir, "Media (*.mp4;*.mkv;*.avi;*.mov;*.ts;*.mp3;*.flac;*.wav)|All (*.*)", 1, "", $hGui)
			If Not @error Then OpenMedia($sFile)
		Case $idPlay
			_GUICtrlVLC_Play($iVlc)
		Case $idPause
			_GUICtrlVLC_Pause($iVlc)
		Case $idStop
			_GUICtrlVLC_Stop($iVlc)
		Case $idFull
			_GUICtrlVLC_ToggleFullscreen($iVlc)
		Case _GUICtrlVLC_GetCtrlID($iVlc)
			If _GUICtrlVLC_IsDoubleClick($iVlc) Then _GUICtrlVLC_ToggleFullscreen($iVlc)
		Case $idMute
			_GUICtrlVLC_SetMute($iVlc, GUICtrlRead($idMute) = $GUI_CHECKED)
		Case $idVol
			_GUICtrlVLC_SetVolume($iVlc, GUICtrlRead($idVol))
		Case $idPos
			_GUICtrlVLC_SetPosition($iVlc, GUICtrlRead($idPos) / 1000)
	EndSwitch
	If TimerDiff($hUpdate) > 250 Then
		$hUpdate = TimerInit()
		UpdateTime()
	EndIf
WEnd
_VLC_Shutdown() ; optional, done automatically on exit
Exit

Func OpenMedia($sMRL)
	If Not _GUICtrlVLC_Open($iVlc, $sMRL) Then MsgBox(48, "CCLibVLC", "Cannot open:" & @CRLF & $sMRL & @CRLF & @CRLF & _VLC_GetLastError(), 0, $hGui)
EndFunc   ;==>OpenMedia

Func UpdateTime()
	Local $iLen = _GUICtrlVLC_GetLength($iVlc), $iTime = _GUICtrlVLC_GetTime($iVlc)
	Local $sText = _VLC_FormatTime($iTime) & " / " & _VLC_FormatTime($iLen) & "  " & _GUICtrlVLC_GetStateText($iVlc)
	If GUICtrlRead($idTime) <> $sText Then GUICtrlSetData($idTime, $sText)
	; do not move the slider while the user drags it
	Local $aCursor = GUIGetCursorInfo($hGui)
	If IsArray($aCursor) And $aCursor[2] = 1 And $aCursor[4] = $idPos Then Return
	If $iLen > 0 Then GUICtrlSetData($idPos, Int(_GUICtrlVLC_GetPosition($iVlc) * 1000))
EndFunc   ;==>UpdateTime

Func OnVlcEvent($iPlayer, $iEvent, $vValue1, $vValue2)
	#forceref $iPlayer, $vValue2
	Switch $iEvent
		Case $libvlc_MediaPlayerEncounteredError
			ConsoleWrite("! playback error" & @CRLF)
		Case $libvlc_MediaPlayerLengthChanged
			ConsoleWrite("length: " & _VLC_FormatTime($vValue1) & @CRLF)
		Case $libvlc_MediaPlayerEndReached
			ConsoleWrite("end reached" & @CRLF)
	EndSwitch
EndFunc   ;==>OnVlcEvent
