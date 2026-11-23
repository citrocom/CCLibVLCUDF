; SPDX-License-Identifier: GPL-3.0-or-later
; CCLibVLC core self-test. Usage: AutoIt3[_x64].exe Test_Core.au3 [vlc-dir] [media-dir] [extra-options]
; Writes PASS/FAIL lines to the console, exit code = number of failures.
#include "..\CCLibVLC.au3"

Global $g_iFail = 0, $g_iPass = 0
Global $g_aSeen[0x700]
Global $g_iLastTime = -1, $g_iEvents = 0

Func T($bCond, $sName, $sInfo = "")
	If $bCond Then
		$g_iPass += 1
		ConsoleWrite("PASS " & $sName & ($sInfo <> "" ? " (" & $sInfo & ")" : "") & @CRLF)
	Else
		$g_iFail += 1
		ConsoleWrite("FAIL " & $sName & ($sInfo <> "" ? " (" & $sInfo & ")" : "") & " | " & _VLC_GetLastError() & @CRLF)
	EndIf
EndFunc

Func OnEvent($iSub, $iType, $v1, $v2, $pObj, $vUser)
	#forceref $iSub, $v2, $pObj
	$g_iEvents += 1
	If $iType >= 0 And $iType < 0x700 Then $g_aSeen[$iType] += 1
	If $iType = $libvlc_MediaPlayerTimeChanged Then $g_iLastTime = $v1
	If $vUser <> "user" Then ConsoleWrite("FAIL userdata" & @CRLF)
EndFunc

Local $sVlc = $CmdLine[0] >= 1 ? $CmdLine[1] : Default
Local $sMediaDir = $CmdLine[0] >= 2 ? $CmdLine[2] : @ScriptDir
Local $sExtra = $CmdLine[0] >= 3 ? $CmdLine[3] : ""

; --- error paths before startup
T(_VLC_IsStarted() = False, "not started")
Local $pBad = _VLC_MediaNew("x.mp4")
T(@error = $VLC_ERR_NOT_STARTED And $pBad = 0, "MediaNew before startup -> NOT_STARTED")
T(_VLC_Startup("C:\does\not\exist") = False And @error = $VLC_ERR_NOTFOUND, "Startup wrong dir -> NOTFOUND")

; --- startup
T(_VLC_Startup($sVlc, $sExtra), "Startup", _VLC_GetDir())
T(StringLeft(_VLC_GetVersion(), 2) = "3.", "Version", _VLC_GetVersion())
T(_VLC_Startup($sVlc) = True And @extended = 1, "Startup twice -> extended 1")
T(_VLC_GetInstance() <> 0, "Instance")
T(_VLC_EventTypeName($libvlc_MediaPlayerPlaying) = "MediaPlayerPlaying", "EventTypeName", _VLC_EventTypeName($libvlc_MediaPlayerPlaying))

; --- utilities
T(_VLC_IsUrl("rtsp://a:b@1.2.3.4/x") And Not _VLC_IsUrl("C:\a\b.mp4") And Not _VLC_IsUrl("\\srv\x"), "IsUrl")
T(_VLC_PathToUri("C:\Filme\Märchen 1.srt") = "file:///C:/Filme/M%C3%A4rchen%201.srt", "PathToUri umlaut", _VLC_PathToUri("C:\Filme\Märchen 1.srt"))
T(_VLC_PathToUri("\\server\share\a b.srt") = "file://server/share/a%20b.srt", "PathToUri UNC")
T(_VLC_FormatTime(3723000) = "1:02:03" And _VLC_FormatTime(65000) = "1:05", "FormatTime")
T(_VLC_FourCCToString(0x34363268) = "h264", "FourCC", _VLC_FourCCToString(0x34363268))

; --- lists
Local $aAo = _VLC_AudioOutputList()
T($aAo[0][0] > 0, "AudioOutputList", $aAo[0][0] & " outputs, first " & ($aAo[0][0] ? $aAo[1][0] : ""))
Local $aF = _VLC_FilterList(True)
T($aF[0][0] > 5, "VideoFilterList", $aF[0][0])
Local $aEq = _VLC_EqualizerGetPresets()
T($aEq[0] = 18 And $aEq[1] = "Flat", "EqualizerPresets", $aEq[0] & " first=" & $aEq[1])
Local $aBands = _VLC_EqualizerGetBands()
T($aBands[0] = 10 And Round($aBands[1]) = 31, "EqualizerBands", $aBands[0] & " first=" & $aBands[1])
Local $aMd = _VLC_MediaDiscovererList($libvlc_media_discoverer_lan)
T($aMd[0][0] >= 0, "MediaDiscovererList", $aMd[0][0])
Local $aRd = _VLC_RendererDiscovererList()
T($aRd[0][0] >= 0, "RendererDiscovererList", $aRd[0][0])

; --- media with umlaut path
Local $sFile = $sMediaDir & "\Märchen ÄÖÜ ß.mp4"
T(FileExists($sFile), "test file exists", $sFile)
Local $pM = _VLC_MediaNew($sFile)
T($pM <> 0, "MediaNew umlaut path")
Local $sMrl = _libvlc_media_get_mrl($pM)
T(StringInStr($sMrl, "M%C3%A4rchen") > 0, "MRL is UTF-8 encoded", $sMrl)
T(_VLC_MediaNew($sMediaDir & "\gibtsnicht.mp4") = 0 And @error = $VLC_ERR_NOTFOUND, "MediaNew missing file -> NOTFOUND")
Local $iSt = _VLC_MediaParse($pM)
T($iSt = $libvlc_media_parsed_status_done, "MediaParse", $iSt)
T(_libvlc_media_get_duration($pM) >= 5900 And _libvlc_media_get_duration($pM) <= 6200, "Duration", _libvlc_media_get_duration($pM))
Local $aTr = _VLC_MediaGetTracks($pM)
Local $bV = False, $bA = False
For $i = 1 To $aTr[0][0]
	If $aTr[$i][$VLC_TRACK_TYPE] = $libvlc_track_video And $aTr[$i][$VLC_TRACK_WIDTH] = 320 And $aTr[$i][$VLC_TRACK_HEIGHT] = 240 And $aTr[$i][$VLC_TRACK_CODEC] = "h264" Then $bV = True
	If $aTr[$i][$VLC_TRACK_TYPE] = $libvlc_track_audio And $aTr[$i][$VLC_TRACK_RATE] = 44100 And $aTr[$i][$VLC_TRACK_CHANNELS] = 1 Then $bA = True
Next
T($aTr[0][0] = 2 And $bV And $bA, "MediaGetTracks (320x240 h264 + 44.1kHz mono)", $aTr[0][0])
Local $pMp3 = _VLC_MediaNew($sMediaDir & "\ton.mp3")
_VLC_MediaParse($pMp3)
Local $aMeta = _VLC_MediaGetMetaAll($pMp3)
T($aMeta[0][0] = 26 And $aMeta[1][1] = "Täst Titel" And $aMeta[2][1] = "Künstler", "Meta UTF-8 (title/artist)", $aMeta[1][1] & " / " & $aMeta[2][1])
_libvlc_media_release($pMp3)

; --- player in a GUI
Local $hGui = GUICreate("CCLibVLC core test", 400, 300, -1, -1, BitOR(0x00CF0000, 0x02000000)) ; overlapped + WS_CLIPCHILDREN
GUISetState(@SW_SHOW, $hGui)
Local $pP = _libvlc_media_player_new_from_media($pM)
T($pP <> 0, "player new")
_libvlc_media_release($pM)
T(_libvlc_media_player_set_hwnd($pP, $hGui), "set_hwnd")
_libvlc_video_set_mouse_input($pP, 0)
_libvlc_video_set_key_input($pP, 0)
Local $pEM = _libvlc_media_player_event_manager($pP)
Local $aTypes[8] = [$libvlc_MediaPlayerPlaying, $libvlc_MediaPlayerPaused, $libvlc_MediaPlayerStopped, $libvlc_MediaPlayerEndReached, _
		$libvlc_MediaPlayerTimeChanged, $libvlc_MediaPlayerLengthChanged, $libvlc_MediaPlayerESAdded, $libvlc_MediaPlayerVout]
Local $iSub = _VLC_EventAttach($pEM, $aTypes, "OnEvent", "user")
T($iSub > 0, "EventAttach", $iSub)
Local $iSubPoll = _VLC_EventAttach($pEM, $libvlc_MediaPlayerPlaying)
T($iSubPoll > $iSub, "EventAttach polling")
T(_libvlc_media_player_play($pP) = 0, "play")
Local $hT = TimerInit()
While TimerDiff($hT) < 2500
	Sleep(20)
WEnd
T($g_aSeen[$libvlc_MediaPlayerPlaying] = 1, "event Playing via callback", $g_aSeen[$libvlc_MediaPlayerPlaying])
T($g_aSeen[$libvlc_MediaPlayerLengthChanged] >= 1, "event LengthChanged")
T($g_aSeen[$libvlc_MediaPlayerESAdded] >= 2, "event ESAdded", $g_aSeen[$libvlc_MediaPlayerESAdded])
Local $aEv
T(_VLC_EventGetNext($aEv) And $aEv[1] = $libvlc_MediaPlayerPlaying And $aEv[0] = $iSubPoll, "polling event")
T(_VLC_EventGetNext($aEv) = False, "polling queue empty")
T(_libvlc_media_player_get_state($pP) = $libvlc_Playing, "state playing", _libvlc_media_player_get_state($pP))
Local $iW = 0, $iH = 0
T(_libvlc_video_get_size($pP, 0, $iW, $iH) = 0 And $iW = 320 And $iH = 240, "video_get_size ByRef", $iW & "x" & $iH)
Local $aAt = _VLC_PlayerGetAudioTracks($pP)
T($aAt[0][0] = 2 And $aAt[1][0] = -1, "PlayerGetAudioTracks (Disable + 1)", $aAt[0][0])
Local $aTi = _VLC_PlayerGetTitles($pP)
T($aTi[0][0] >= 0, "PlayerGetTitles", $aTi[0][0])
_libvlc_media_player_set_time($pP, 1000)
Sleep(300)
T(_libvlc_media_player_get_time($pP) < 2200, "seek", _libvlc_media_player_get_time($pP))
_libvlc_media_player_set_pause($pP, 1)
Local $hPauseT = TimerInit()
Do
	Sleep(50)
Until ($g_aSeen[$libvlc_MediaPlayerPaused] = 1 And _libvlc_media_player_get_state($pP) = $libvlc_Paused) Or TimerDiff($hPauseT) > 3000
T($g_aSeen[$libvlc_MediaPlayerPaused] = 1 And _libvlc_media_player_get_state($pP) = $libvlc_Paused, "pause + event")
_libvlc_media_player_set_pause($pP, 0)
Sleep(200)
Local $hS = TimerInit()
T(_VLC_PlayerStop($pP), "PlayerStop on worker", Round(TimerDiff($hS)) & " ms")
Sleep(100)
T($g_aSeen[$libvlc_MediaPlayerStopped] = 1, "event Stopped (sent on worker thread)")
T(_libvlc_media_player_get_state($pP) = $libvlc_Stopped, "state stopped")
; play to the end
_libvlc_media_player_play($pP)
$hT = TimerInit()
While $g_aSeen[$libvlc_MediaPlayerEndReached] = 0 And TimerDiff($hT) < 12000
	Sleep(20)
WEnd
T($g_aSeen[$libvlc_MediaPlayerEndReached] = 1, "event EndReached", Round(TimerDiff($hT)) & " ms")
T($g_aSeen[$libvlc_MediaPlayerTimeChanged] > 3 And $g_iLastTime > 4000, "events TimeChanged (count, last value)", $g_aSeen[$libvlc_MediaPlayerTimeChanged] & ", " & $g_iLastTime)
T(_VLC_EventDetach($iSub), "EventDetach")
T(_VLC_EventDetach($iSub) = False And @error = $VLC_ERR_PARAM, "EventDetach twice -> PARAM (no abort)")
T(_VLC_EventDetachAll($pEM) = 1, "EventDetachAll remaining")
T(_VLC_PlayerRelease($pP), "PlayerRelease")
T(_VLC_Shutdown(), "Shutdown")
T(_VLC_IsStarted() = False, "not started after shutdown")
; restart in the same process
T(_VLC_Startup($sVlc, $sExtra), "Restart after shutdown")
T(_VLC_Shutdown(), "Shutdown 2")
ConsoleWrite("events delivered: " & $g_iEvents & " -")
For $i = 0 To 0x6FF
	If $g_aSeen[$i] Then ConsoleWrite(" " & _VLC_EventTypeName($i) & "=" & $g_aSeen[$i])
Next
ConsoleWrite(@CRLF)
ConsoleWrite(@CRLF & "RESULT " & (@AutoItX64 ? "x64" : "x86") & ": " & $g_iPass & " passed, " & $g_iFail & " failed" & @CRLF)
Exit $g_iFail
