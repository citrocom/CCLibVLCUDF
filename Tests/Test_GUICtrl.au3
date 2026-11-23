; SPDX-License-Identifier: GPL-3.0-or-later
; CCGUICtrlVLC self-test. Usage: AutoIt3[_x64].exe Test_GUICtrl.au3 [vlc-dir] [media-dir] [extra-options]
; Exit code = number of failures.
#include "..\CCGUICtrlVLC.au3"

Global $g_iFail = 0, $g_iPass = 0
Global $g_aSeen[0x700], $g_iLastPlayer = 0

Func T($bCond, $sName, $sInfo = "")
	If $bCond Then
		$g_iPass += 1
		ConsoleWrite("PASS " & $sName & ($sInfo <> "" ? " (" & $sInfo & ")" : "") & @CRLF)
	Else
		$g_iFail += 1
		ConsoleWrite("FAIL " & $sName & ($sInfo <> "" ? " (" & $sInfo & ")" : "") & " | " & _VLC_GetLastError() & @CRLF)
	EndIf
EndFunc

Func OnVlc($iPlayer, $iEvent, $v1, $v2)
	#forceref $v1, $v2
	$g_iLastPlayer = $iPlayer
	If $iEvent >= 0 And $iEvent < 0x700 Then $g_aSeen[$iEvent] += 1
EndFunc

Func WaitFor($iPlayer, $iState, $iMs)
	Local $h = TimerInit()
	While TimerDiff($h) < $iMs
		If _GUICtrlVLC_GetState($iPlayer) = $iState Then Return True
		Sleep(20)
	WEnd
	Return False
EndFunc

Func GetParentOf($hWnd)
	Local $a = DllCall("user32.dll", "hwnd", "GetParent", "hwnd", $hWnd)
	Return $a[0]
EndFunc

Global $sVlc = $CmdLine[0] >= 1 ? $CmdLine[1] : Default
Global $sMediaDir = $CmdLine[0] >= 2 ? $CmdLine[2] : @ScriptDir
Global $sExtra = $CmdLine[0] >= 3 ? $CmdLine[3] : ""
Global $sVideo = $sMediaDir & "\Märchen ÄÖÜ ß.mp4", $sAudio = $sMediaDir & "\ton.mp3"

T(_GUICtrlVLC_Create(0, 0, 100, 100) = 0 And @error = $VLC_ERR_NOT_STARTED + 0 Or @error <> 0, "Create without GUI fails cleanly")
T(_VLC_Startup($sVlc, $sExtra), "Startup")

; resizable GUI (WS_OVERLAPPEDWINDOW)
Global $hGui = GUICreate("CCGUICtrlVLC test", 640, 400, 50, 50, 0x00CF0000)
Global $iVlc = _GUICtrlVLC_Create(10, 10, 620, 340)
T($iVlc = 1, "Create", $iVlc)
Global $idCtrl = _GUICtrlVLC_GetCtrlID($iVlc), $hHost = _GUICtrlVLC_GetHandle($iVlc)
T($idCtrl > 0 And IsHWnd($hHost), "ctrl id / handle")
Local $aSt = DllCall("user32.dll", "long", "GetWindowLongW", "hwnd", $hGui, "int", -16)
T(BitAND($aSt[0], 0x02000000) <> 0, "parent got WS_CLIPCHILDREN")
T(_GUICtrlVLC_SetResizing($iVlc, 102), "SetResizing DOCKBORDERS")
Global $idBtn = GUICtrlCreateButton("Test", 10, 360, 80, 30)
GUICtrlSetResizing($idBtn, 802)
GUISetState(@SW_SHOW, $hGui)
; double click on the video: the second click arrives as WM_LBUTTONDBLCLK and must still be reported as a click
Global $iClicks = 0, $bDbl = False, $hClickT
Global $aClickMsgs[4] = [0x0201, 0x0202, 0x0203, 0x0202] ; down, up, double click, up
For $m In $aClickMsgs
	DllCall("user32.dll", "lresult", "SendMessageW", "hwnd", $hHost, "uint", $m, "wparam", ($m = 0x0202 ? 0 : 1), "lparam", 0x00140014)
Next
$hClickT = TimerInit()
While TimerDiff($hClickT) < 500
	If GUIGetMsg() = $idCtrl Then
		$iClicks += 1
		If _GUICtrlVLC_IsDoubleClick($iVlc) Then $bDbl = True
	EndIf
WEnd
T($iClicks = 2 And $bDbl, "double click reported as two clicks + IsDoubleClick", "clicks=" & $iClicks & " dbl=" & $bDbl)
T(_GUICtrlVLC_SetEventCallback($iVlc, "OnVlc"), "SetEventCallback")
T(_GUICtrlVLC_GetState($iVlc) = 0 And _GUICtrlVLC_GetStateText($iVlc) = "Idle", "state idle")
T(_GUICtrlVLC_Pause($iVlc) = False, "Pause without media -> False")
T(_GUICtrlVLC_Play($iVlc) = False And @error = $VLC_ERR_STATE, "Play with empty playlist -> STATE")

; volume / mute before playback (deferred)
T(_GUICtrlVLC_SetVolume($iVlc, 40), "SetVolume before playback")
T(_GUICtrlVLC_GetVolume($iVlc) = 40, "GetVolume returns wanted value")

; playlist
T(_GUICtrlVLC_Add($iVlc, $sMediaDir & "\fehlt.mp4") = -1 And @error = $VLC_ERR_NOTFOUND, "Add missing file -> -1/NOTFOUND")
T(_GUICtrlVLC_Add($iVlc, $sVideo) = 0, "Add item 0 (umlaut path)")
T(_GUICtrlVLC_Add($iVlc, $sAudio, ":start-time=1") = 1, "Add item 1 with option")
T(_GUICtrlVLC_GetCount($iVlc) = 2 And _GUICtrlVLC_GetItem($iVlc, 1) = $sAudio, "GetCount / GetItem")
T(_GUICtrlVLC_Play($iVlc, 0), "Play item 0")
T(WaitFor($iVlc, $VLC_STATE_PLAYING, 5000), "playing")
Sleep(800)
T($g_aSeen[$libvlc_MediaPlayerPlaying] >= 1 And $g_iLastPlayer = $iVlc, "callback with player id")
T($g_aSeen[$libvlc_MediaPlayerTimeChanged] = 0, "no time events by default")
Local $aRealVol = _libvlc_audio_get_volume(_GUICtrlVLC_GetPlayer($iVlc))
T(_GUICtrlVLC_GetVolume($iVlc) = 40 And $aRealVol >= 0, "volume while playing (dummy aout reports 0)", $aRealVol)
T(_GUICtrlVLC_SetMute($iVlc, True) And _GUICtrlVLC_GetMute($iVlc) = True, "SetMute/GetMute")
T(_GUICtrlVLC_ToggleMute($iVlc) And _GUICtrlVLC_GetMute($iVlc) = False, "ToggleMute")
T(_GUICtrlVLC_GetLength($iVlc) >= 5900, "GetLength", _GUICtrlVLC_GetLength($iVlc))
Local $aSize = _GUICtrlVLC_GetVideoSize($iVlc)
T($aSize[0] = 320 And $aSize[1] = 240, "GetVideoSize", $aSize[0] & "x" & $aSize[1])
Local $hHv = TimerInit()
While Not _GUICtrlVLC_HasVideo($iVlc) And TimerDiff($hHv) < 4000
	Sleep(50)
WEnd
T(_GUICtrlVLC_HasVideo($iVlc), "HasVideo", _libvlc_media_player_has_vout(_GUICtrlVLC_GetPlayer($iVlc)))
T(StringInStr(_GUICtrlVLC_GetMRL($iVlc), "M%C3%A4rchen") > 0, "GetMRL")
Local $aMT = _GUICtrlVLC_GetMediaTracks($iVlc)
T($aMT[0][0] = 2, "GetMediaTracks", $aMT[0][0])
Local $aAT = _GUICtrlVLC_GetAudioTracks($iVlc)
T($aAT[0][0] = 2, "GetAudioTracks", $aAT[0][0])
T(_GUICtrlVLC_SeekAbsolute($iVlc, 2000), "SeekAbsolute")
Local $hSeekT = TimerInit()
Do
	Sleep(50)
Until _GUICtrlVLC_GetTime($iVlc) >= 1500 Or TimerDiff($hSeekT) > 3000
T(_GUICtrlVLC_GetTime($iVlc) >= 1500, "time after seek", _GUICtrlVLC_GetTime($iVlc))
T(_GUICtrlVLC_SeekRelative($iVlc, -1000), "SeekRelative")
T(_GUICtrlVLC_Pause($iVlc) And WaitFor($iVlc, $VLC_STATE_PAUSED, 2000), "Pause toggle -> paused")
T(_GUICtrlVLC_Play($iVlc) And WaitFor($iVlc, $VLC_STATE_PLAYING, 2000), "Play resumes")
T(_GUICtrlVLC_SetRate($iVlc, 1.5) And Abs(_GUICtrlVLC_GetRate($iVlc) - 1.5) < 0.01, "rate")
_GUICtrlVLC_SetRate($iVlc, 1.0)
T(_GUICtrlVLC_SetAspectRatio($iVlc, "16:9") And _GUICtrlVLC_GetAspectRatio($iVlc) = "16:9", "aspect ratio")
T(_GUICtrlVLC_SetAspectRatio($iVlc, "") And _GUICtrlVLC_GetAspectRatio($iVlc) = "", "aspect ratio reset")
T(_GUICtrlVLC_SetMarquee($iVlc, "Front door %H:%M:%S", 5, 20, 0xFFFFFF), "marquee")
T(_GUICtrlVLC_SetAdjust($iVlc, True, 1.2, 1.1), "adjust")
T(_GUICtrlVLC_SetEqualizer($iVlc, 0) And _GUICtrlVLC_SetEqualizer($iVlc, -1), "equalizer on/off")
If EnvGet("CCLIBVLC_TEST_SNAPSHOT") <> "" Then ; optional test, enable with CCLIBVLC_TEST_SNAPSHOT=1
	Local $sSnap = @TempDir & "\cclibvlc_snap.png"
	Local $bSnap = _GUICtrlVLC_TakeSnapshot($iVlc, $sSnap)
	T($bSnap And FileGetSize($sSnap) > 100, "TakeSnapshot", FileGetSize($sSnap) & " bytes")
EndIf

; resizing the window resizes the video area
WinMove($hGui, "", 50, 50, 900, 600)
Sleep(300)
Local $aPos = ControlGetPos($hGui, "", $idCtrl)
T(IsArray($aPos) And $aPos[2] > 800 And $aPos[3] > 450, "video area follows window size", IsArray($aPos) ? $aPos[2] & "x" & $aPos[3] : "")

; fullscreen
T(_GUICtrlVLC_SetFullscreen($iVlc, True), "SetFullscreen on")
Sleep(300)
T(GetParentOf($hHost) = _GUICtrlVLC_GetFullscreenGUI($iVlc) And _GUICtrlVLC_GetFullscreen($iVlc), "host in fullscreen window")
Local $aFsPos = WinGetPos(_GUICtrlVLC_GetFullscreenGUI($iVlc))
T(IsArray($aFsPos) And $aFsPos[2] = @DesktopWidth And $aFsPos[3] = @DesktopHeight, "fullscreen covers monitor", IsArray($aFsPos) ? $aFsPos[2] & "x" & $aFsPos[3] : "")
T(_GUICtrlVLC_ToggleFullscreen($iVlc) And Not _GUICtrlVLC_GetFullscreen($iVlc), "fullscreen off")
T(GetParentOf($hHost) = $hGui, "host back in GUI")
$aPos = ControlGetPos($hGui, "", $idCtrl)
T(IsArray($aPos) And $aPos[2] > 800, "position restored", IsArray($aPos) ? $aPos[0] & "," & $aPos[1] & " " & $aPos[2] & "x" & $aPos[3] : "")

; auto advance: item 0 ends -> item 1 starts
_GUICtrlVLC_SetTime($iVlc, _GUICtrlVLC_GetLength($iVlc) - 700)
Local $hT = TimerInit()
While _GUICtrlVLC_GetCurrentItem($iVlc) <> 1 And TimerDiff($hT) < 8000
	Sleep(20)
WEnd
T(_GUICtrlVLC_GetCurrentItem($iVlc) = 1, "auto advance to item 1", Round(TimerDiff($hT)) & " ms")
T(WaitFor($iVlc, $VLC_STATE_PLAYING, 4000), "item 1 playing")
T(_GUICtrlVLC_GetMeta($iVlc, $libvlc_meta_Title) = "Täst Titel", "GetMeta title (mp3)", _GUICtrlVLC_GetMeta($iVlc, $libvlc_meta_Title))
T($g_aSeen[$libvlc_MediaPlayerEndReached] >= 1, "EndReached seen by callback")
Sleep(500)
T(_GUICtrlVLC_GetVolume($iVlc) = 40, "volume kept for next item")
; loop one
T(_GUICtrlVLC_SetLoop($iVlc, $VLC_LOOP_ONE), "SetLoop ONE")
$hT = TimerInit()
Local $iEnds = $g_aSeen[$libvlc_MediaPlayerEndReached]
While $g_aSeen[$libvlc_MediaPlayerEndReached] = $iEnds And TimerDiff($hT) < 6000
	Sleep(20)
WEnd
T(WaitFor($iVlc, $VLC_STATE_PLAYING, 4000) And _GUICtrlVLC_GetCurrentItem($iVlc) = 1, "loop ONE restarts item 1")
_GUICtrlVLC_SetLoop($iVlc, $VLC_LOOP_NONE)
T(_GUICtrlVLC_Previous($iVlc) And _GUICtrlVLC_GetCurrentItem($iVlc) = 0, "Previous")
T(_GUICtrlVLC_Next($iVlc) And _GUICtrlVLC_GetCurrentItem($iVlc) = 1, "Next")
T(_GUICtrlVLC_Next($iVlc) = False And @error = $VLC_ERR_STATE, "Next at end without loop -> STATE")

; stop
$hT = TimerInit()
T(_GUICtrlVLC_Stop($iVlc), "Stop", Round(TimerDiff($hT)) & " ms")
T(_GUICtrlVLC_GetState($iVlc) = $VLC_STATE_STOPPED, "state stopped")
T(_GUICtrlVLC_Play($iVlc) And WaitFor($iVlc, $VLC_STATE_PLAYING, 4000), "Play after stop restarts current item")

; busy protection: a stop that exceeds its timeout must not block later calls
T(WaitFor($iVlc, $VLC_STATE_PLAYING, 4000), "playing before busy test")
Local $pRaw = _GUICtrlVLC_GetPlayer($iVlc)
Local $bStop0 = _VLC_PlayerStop($pRaw, 0), $iStop0Err = @error
If $bStop0 Then
	; the stop can finish before the 0 ms timeout is checked (fast systems): nothing to test then
	ConsoleWrite("SKIP busy protection: stop finished within 0 ms" & @CRLF)
Else
	T($iStop0Err = $VLC_ERR_TIMEOUT, "stop with 0 ms timeout -> TIMEOUT", $iStop0Err)
	; the worker may finish right after the timeout, so "busy" is only checked below while it lasts
EndIf
If _VLC_PlayerIsBusy($pRaw) Then ; the stop may already have finished on fast systems
	$hT = TimerInit()
	_GUICtrlVLC_GetTime($iVlc)
	Local $iErrBusy = @error
	T(($iErrBusy <> 0 Or Not _VLC_PlayerIsBusy($pRaw)) And TimerDiff($hT) < 100, "GetTime while busy returns at once", Round(TimerDiff($hT)) & " ms")
EndIf
If _VLC_PlayerIsBusy($pRaw) Then T(_GUICtrlVLC_Play($iVlc, 0) = False Or Not _VLC_PlayerIsBusy($pRaw), "Play while busy is refused")
$hT = TimerInit()
While _VLC_PlayerIsBusy($pRaw) And TimerDiff($hT) < 10000
	Sleep(20)
WEnd
T(Not _VLC_PlayerIsBusy($pRaw), "busy cleared after stop finished", Round(TimerDiff($hT)) & " ms")
T(_GUICtrlVLC_Play($iVlc, 0) And WaitFor($iVlc, $VLC_STATE_PLAYING, 4000), "player usable again")

; second player at the same time (VLC.au3 v0.3 style: Stop, Play(Add()), GetState)
Global $iVlc2 = _GUICtrlVLC_Create(10, 10, 200, 150)
T($iVlc2 = 2, "second player")
_GUICtrlVLC_Stop($iVlc2)
T(_GUICtrlVLC_Play($iVlc2, _GUICtrlVLC_Add($iVlc2, $sVideo)), "v0.3 pattern Play(Add())")
T(WaitFor($iVlc2, 3, 5000), "player 2 playing while player 1 plays")
T(_GUICtrlVLC_Open($iVlc2, $sVideo) And _GUICtrlVLC_GetCount($iVlc2) = 1 And WaitFor($iVlc2, 3, 5000), "Open replaces playlist")
T(_VLCErrorHandlerRegister() = 1, "v0.3 _VLCErrorHandlerRegister stub")

; delete while playing
$hT = TimerInit()
T(_GUICtrlVLC_Delete($iVlc2), "Delete while playing", Round(TimerDiff($hT)) & " ms")
T(_GUICtrlVLC_GetState($iVlc2) = 0 And @error = $VLC_ERR_PARAM, "deleted id is invalid")
T(_GUICtrlVLC_Clear($iVlc) And _GUICtrlVLC_GetCount($iVlc) = 0 And _GUICtrlVLC_GetCurrentItem($iVlc) = -1, "Clear")
; stress: rapid open/stop cycles
Local $bStress = True
For $k = 1 To 8
	If Not _GUICtrlVLC_Open($iVlc, $sVideo) Then $bStress = False
	Sleep(Random(50, 400, 1))
	If Not _GUICtrlVLC_Stop($iVlc) Then $bStress = False
Next
T($bStress, "8 rapid open/stop cycles")
_GUICtrlVLC_Open($iVlc, $sVideo)
WaitFor($iVlc, 3, 4000)
; shutdown with a playing player (delete via hook)
$hT = TimerInit()
T(_VLC_Shutdown(), "Shutdown with playing player", Round(TimerDiff($hT)) & " ms")
T(_GUICtrlVLC_GetState($iVlc) = 0 And @error = $VLC_ERR_PARAM, "player deleted by shutdown hook")
GUIDelete($hGui)
ConsoleWrite(@CRLF & "RESULT " & (@AutoItX64 ? "x64" : "x86") & ": " & $g_iPass & " passed, " & $g_iFail & " failed" & @CRLF)
Exit $g_iFail
