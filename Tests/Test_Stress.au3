; SPDX-License-Identifier: GPL-3.0-or-later
; CCLibVLC stress test: many open/stop cycles, auto advance and delete/create while playing.
; Usage: AutoIt3[_x64].exe Test_Stress.au3 [vlc-dir] [media-dir] [extra-options]   Exit code = number of failures.
#include "..\CCGUICtrlVLC.au3"

Global $g_iFail = 0, $g_iPass = 0
Func T($bCond, $sName, $sInfo = "")
	If $bCond Then
		$g_iPass += 1
		ConsoleWrite("PASS " & $sName & ($sInfo <> "" ? " (" & $sInfo & ")" : "") & @CRLF)
	Else
		$g_iFail += 1
		ConsoleWrite("FAIL " & $sName & ($sInfo <> "" ? " (" & $sInfo & ")" : "") & " | " & _VLC_GetLastError() & @CRLF)
	EndIf
EndFunc

Global $sVlc = $CmdLine[0] >= 1 ? $CmdLine[1] : Default
Global $sMediaDir = $CmdLine[0] >= 2 ? $CmdLine[2] : @ScriptDir
Global $sExtra = $CmdLine[0] >= 3 ? $CmdLine[3] : ""
Global $sVideo = $sMediaDir & "\test.mp4"
T(_VLC_Startup($sVlc, $sExtra), "Startup")
Global $hGui = GUICreate("CCLibVLC stress", 640, 400, 50, 50, 0x00CF0000)
Global $iVlc = _GUICtrlVLC_Create(10, 10, 620, 340)
GUISetState()

; 1) rapid open/stop with random delays (also stops while the video output is being created)
Global $iOk = 0, $iMaxStop = 0, $hT
For $k = 1 To 40
	If Not _GUICtrlVLC_Open($iVlc, $sVideo) Then ContinueLoop
	Sleep(Random(0, 400, 1))
	$hT = TimerInit()
	If _GUICtrlVLC_Stop($iVlc) Then $iOk += 1
	If TimerDiff($hT) > $iMaxStop Then $iMaxStop = Round(TimerDiff($hT))
Next
T($iOk = 40, "40 open/stop cycles", $iOk & " ok, slowest stop " & $iMaxStop & " ms")

; 2) playlist of 6 items, skip to the end of each item: auto advance through the whole list
_GUICtrlVLC_Clear($iVlc)
For $k = 1 To 6
	_GUICtrlVLC_Add($iVlc, $sVideo)
Next
_GUICtrlVLC_Play($iVlc, 0)
$hT = TimerInit()
Global $iLast = -1, $iSeen = 0
While TimerDiff($hT) < 60000
	Local $i = _GUICtrlVLC_GetCurrentItem($iVlc)
	If $i <> $iLast Then
		$iLast = $i
		$iSeen += 1
	EndIf
	If _GUICtrlVLC_GetState($iVlc) = $VLC_STATE_PLAYING And _GUICtrlVLC_GetTime($iVlc) > 300 And _GUICtrlVLC_GetTime($iVlc) < 4000 Then _GUICtrlVLC_SetTime($iVlc, 5300)
	If $i = 5 And _GUICtrlVLC_GetState($iVlc) = $VLC_STATE_ENDED Then ExitLoop
	Sleep(30)
WEnd
T($iSeen = 6 And _GUICtrlVLC_GetCurrentItem($iVlc) = 5, "auto advance through 6 items", $iSeen & " items, " & Round(TimerDiff($hT)) & " ms")

; 3) delete and re-create the control while playing
Global $bOk = True
For $k = 1 To 10
	_GUICtrlVLC_Open($iVlc, $sVideo)
	Sleep(Random(100, 600, 1))
	If Not _GUICtrlVLC_Delete($iVlc) Then $bOk = False
	$iVlc = _GUICtrlVLC_Create(10, 10, 620, 340)
	If Not $iVlc Then $bOk = False
Next
T($bOk, "10 delete/create cycles while playing")
T(_VLC_Shutdown(), "Shutdown")
ConsoleWrite(@CRLF & "RESULT " & (@AutoItX64 ? "x64" : "x86") & ": " & $g_iPass & " passed, " & $g_iFail & " failed" & @CRLF)
Exit $g_iFail
