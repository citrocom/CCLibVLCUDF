; SPDX-License-Identifier: GPL-3.0-or-later
; CCLibVLC example: using the raw libVLC functions (_libvlc_*) directly, with thread-safe events.
; Shows media information of a file without playing it, then plays it in a window of your own.
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include "..\CCLibVLC.au3"

If Not _VLC_Startup() Then Exit MsgBox(16, "CCLibVLC", _VLC_GetLastError())
Global $sFile = FileOpenDialog("Select a media file", @MyDocumentsDir, "All (*.*)", 1)
If @error Then Exit

; --- media information (parsing without playback)
Global $pMedia = _VLC_MediaNew($sFile)
If Not $pMedia Then Exit MsgBox(16, "CCLibVLC", _VLC_GetLastError())
_VLC_MediaParse($pMedia)
Global $sInfo = "Duration: " & _VLC_FormatTime(_libvlc_media_get_duration($pMedia)) & @CRLF
Global $aMeta = _VLC_MediaGetMetaAll($pMedia)
For $i = 1 To $aMeta[0][0]
	If $aMeta[$i][1] <> "" Then $sInfo &= $aMeta[$i][0] & ": " & $aMeta[$i][1] & @CRLF
Next
Global $aTracks = _VLC_MediaGetTracks($pMedia)
For $i = 1 To $aTracks[0][0]
	Switch $aTracks[$i][$VLC_TRACK_TYPE]
		Case $libvlc_track_video
			$sInfo &= "Video: " & $aTracks[$i][$VLC_TRACK_CODEC] & " " & $aTracks[$i][$VLC_TRACK_WIDTH] & "x" & $aTracks[$i][$VLC_TRACK_HEIGHT] & @CRLF
		Case $libvlc_track_audio
			$sInfo &= "Audio: " & $aTracks[$i][$VLC_TRACK_CODEC] & " " & $aTracks[$i][$VLC_TRACK_RATE] & " Hz, " & $aTracks[$i][$VLC_TRACK_CHANNELS] & " ch" & @CRLF
		Case $libvlc_track_text
			$sInfo &= "Subtitle: " & $aTracks[$i][$VLC_TRACK_LANGUAGE] & @CRLF
	EndSwitch
Next
MsgBox(64, "Media information", $sInfo)

; --- playback in an own window (WS_CLIPCHILDREN is required by libVLC)
Global $hGui = GUICreate("Raw layer example", 640, 400, -1, -1, BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPCHILDREN))
GUISetState()
Global $pPlayer = _libvlc_media_player_new_from_media($pMedia)
_libvlc_media_release($pMedia) ; the player holds its own reference
_libvlc_media_player_set_hwnd($pPlayer, $hGui)
_libvlc_video_set_mouse_input($pPlayer, 0)
_libvlc_video_set_key_input($pPlayer, 0)

; events are delivered on the AutoIt thread
Global $aTypes[3] = [$libvlc_MediaPlayerPlaying, $libvlc_MediaPlayerEndReached, $libvlc_MediaPlayerEncounteredError]
Global $iSub = _VLC_EventAttach(_libvlc_media_player_event_manager($pPlayer), $aTypes, "OnEvent")
Global $bEnd = False
_libvlc_media_player_play($pPlayer)

While Not $bEnd
	If GUIGetMsg() = $GUI_EVENT_CLOSE Then ExitLoop
WEnd

; clean up: detach events BEFORE releasing the player, stop/release on the worker thread (no GUI freeze)
_VLC_EventDetach($iSub)
_VLC_PlayerRelease($pPlayer)
_VLC_Shutdown()

Func OnEvent($iSub, $iType, $v1, $v2, $pObj, $vUser)
	#forceref $iSub, $v1, $v2, $pObj, $vUser
	ConsoleWrite("event: " & _VLC_EventTypeName($iType) & @CRLF)
	If $iType = $libvlc_MediaPlayerEndReached Or $iType = $libvlc_MediaPlayerEncounteredError Then $bEnd = True
EndFunc   ;==>OnEvent
