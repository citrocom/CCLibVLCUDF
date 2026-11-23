#include-once
; SPDX-License-Identifier: GPL-3.0-or-later
; #INDEX# =======================================================================================================================
; Title .........: CCGUICtrlVLC
; AutoIt Version : 3.3.14.5+ (tested with 3.3.18.0, x86 and x64)
; Language ......: English
; Description ...: Embedded VLC video player control for AutoIt GUIs, based on libVLC 3.0 (CCLibVLC).
;                  Drop-in compatible with the function names of seangriffin's VLC.au3 v0.3 (_GUICtrlVLC_Create, _Add,
;                  _Play, _Pause, _Stop, _Clear, _SeekRelative, _SeekAbsolute, _GetState, _GetLength, _GetTime,
;                  _GetVolume, _SetVolume, _GetMute, _SetMute, _VLCErrorHandlerRegister), but without ActiveX and IE.
; Author(s) .....: Markus Debus, CITRO Computer
; Copyright .....: Copyright (C) 2026 Markus Debus, CITRO Computer. GPL-3.0-or-later with an additional attribution term
;                  according to GPLv3 section 7(b), see LICENSE and NOTICE.
; Remarks .......: - A player is identified by an integer id (>= 1) returned by _GUICtrlVLC_Create().
;                  - The video is drawn into a label control (black background). It behaves like every other control:
;                    GUICtrlSetResizing(_GUICtrlVLC_GetCtrlID($id), $GUI_DOCKBORDERS) makes the video follow the window
;                    size, GUIGetMsg() returns the control id when the video is clicked.
;                  - Playlist item numbers are 0-based (like VLC.au3 v0.3).
;                  - Stop, item changes and deleting never block the GUI (worker thread, see CCLibVLC.au3).
;                  - Volume and mute set before playback starts are remembered and applied as soon as audio is available.
; ===============================================================================================================================

#include "CCLibVLC.au3"

#Region Constants and globals
; #CONSTANTS# ===================================================================================================================
; flags for _GUICtrlVLC_Create()
Global Const $VLC_CTRL_DEFAULT = 0
Global Const $VLC_CTRL_VLC_MOUSE = 1           ; let VLC handle mouse input (no click events for the control)
Global Const $VLC_CTRL_VLC_KEYS = 2            ; let VLC handle its hotkeys
Global Const $VLC_CTRL_KEEP_PARENT_STYLE = 4   ; do not add WS_CLIPCHILDREN to the parent window
Global Const $VLC_CTRL_NO_ESC_FULLSCREEN = 8   ; Esc does not leave fullscreen
Global Const $VLC_CTRL_TIME_EVENTS = 16        ; also deliver TimeChanged/PositionChanged events to the callback

; loop modes for _GUICtrlVLC_SetLoop()
Global Const $VLC_LOOP_NONE = 0, $VLC_LOOP_ALL = 1, $VLC_LOOP_ONE = 2

; player states (identical to libvlc_state_t and to the values of VLC.au3 v0.3)
Global Const $VLC_STATE_IDLE = 0, $VLC_STATE_OPENING = 1, $VLC_STATE_BUFFERING = 2, $VLC_STATE_PLAYING = 3, _
		$VLC_STATE_PAUSED = 4, $VLC_STATE_STOPPED = 5, $VLC_STATE_ENDED = 6, $VLC_STATE_ERROR = 7
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
; player table, [0][0] = number of slots
Global Const $__VLCC_USED = 0, $__VLCC_PLAYER = 1, $__VLCC_MEDIA = 2, $__VLCC_HOST = 3, $__VLCC_CTRLID = 4, $__VLCC_PARENT = 5, _
		$__VLCC_SUB = 6, $__VLCC_CALLBACK = 7, $__VLCC_LIST = 8, $__VLCC_LISTOPT = 9, $__VLCC_CURRENT = 10, $__VLCC_LOOP = 11, _
		$__VLCC_FS = 12, $__VLCC_FSGUI = 13, $__VLCC_FSRECT = 14, $__VLCC_VOLUME = 15, $__VLCC_MUTE = 16, $__VLCC_FLAGS = 17, _
		$__VLCC_LASTCLICK = 18, $__VLCC_COLS = 19
Global $__g_aVLCC[1][$__VLCC_COLS] = [[0]]
Global $__g_bVLCC_FSWatch = False

; compatibility with VLC.au3 v0.3 (seangriffin)
Global $oVLCErrorHandler = 0, $sVLCUserErrorHandler = ""

; let _VLC_Shutdown() delete all players first
$__g_sVLC_ShutdownHook = "__GUICtrlVLC_DeleteAll"
; ===============================================================================================================================
#EndRegion Constants and globals

; #CURRENT# =====================================================================================================================
; Control:    _GUICtrlVLC_Create, _GUICtrlVLC_Delete, _GUICtrlVLC_GetPlayer, _GUICtrlVLC_GetHandle, _GUICtrlVLC_GetCtrlID,
;             _GUICtrlVLC_SetPos, _GUICtrlVLC_SetResizing, _GUICtrlVLC_SetEventCallback, _GUICtrlVLC_IsDoubleClick
; Playlist:   _GUICtrlVLC_Add, _GUICtrlVLC_Clear, _GUICtrlVLC_GetCount, _GUICtrlVLC_GetItem, _GUICtrlVLC_GetCurrentItem,
;             _GUICtrlVLC_Open, _GUICtrlVLC_Play, _GUICtrlVLC_Next, _GUICtrlVLC_Previous, _GUICtrlVLC_SetLoop,
;             _GUICtrlVLC_GetLoop
; Transport:  _GUICtrlVLC_Pause, _GUICtrlVLC_SetPause, _GUICtrlVLC_Stop, _GUICtrlVLC_GetState, _GUICtrlVLC_GetStateText,
;             _GUICtrlVLC_IsPlaying, _GUICtrlVLC_IsSeekable, _GUICtrlVLC_CanPause, _GUICtrlVLC_NextFrame
; Time:       _GUICtrlVLC_GetTime, _GUICtrlVLC_SetTime, _GUICtrlVLC_SeekAbsolute, _GUICtrlVLC_SeekRelative,
;             _GUICtrlVLC_GetLength, _GUICtrlVLC_GetPosition, _GUICtrlVLC_SetPosition, _GUICtrlVLC_GetRate,
;             _GUICtrlVLC_SetRate
; Audio:      _GUICtrlVLC_GetVolume, _GUICtrlVLC_SetVolume, _GUICtrlVLC_GetMute, _GUICtrlVLC_SetMute,
;             _GUICtrlVLC_ToggleMute, _GUICtrlVLC_GetAudioTracks, _GUICtrlVLC_GetAudioTrack, _GUICtrlVLC_SetAudioTrack,
;             _GUICtrlVLC_GetAudioDelay, _GUICtrlVLC_SetAudioDelay, _GUICtrlVLC_GetAudioDevices,
;             _GUICtrlVLC_SetAudioDevice, _GUICtrlVLC_SetEqualizer
; Video:      _GUICtrlVLC_HasVideo, _GUICtrlVLC_GetVideoSize, _GUICtrlVLC_TakeSnapshot, _GUICtrlVLC_GetAspectRatio,
;             _GUICtrlVLC_SetAspectRatio, _GUICtrlVLC_GetScale, _GUICtrlVLC_SetScale, _GUICtrlVLC_SetCrop,
;             _GUICtrlVLC_SetDeinterlace, _GUICtrlVLC_SetAdjust, _GUICtrlVLC_SetMarquee, _GUICtrlVLC_ClearMarquee,
;             _GUICtrlVLC_GetVideoTracks, _GUICtrlVLC_SetVideoTrack
; Subtitles:  _GUICtrlVLC_GetSubtitleTracks, _GUICtrlVLC_GetSubtitleTrack, _GUICtrlVLC_SetSubtitleTrack,
;             _GUICtrlVLC_AddSubtitleFile, _GUICtrlVLC_GetSubtitleDelay, _GUICtrlVLC_SetSubtitleDelay
; Chapters:   _GUICtrlVLC_GetChapters, _GUICtrlVLC_GetChapter, _GUICtrlVLC_SetChapter, _GUICtrlVLC_NextChapter,
;             _GUICtrlVLC_PreviousChapter, _GUICtrlVLC_GetTitles, _GUICtrlVLC_GetTitle, _GUICtrlVLC_SetTitle
; Media:      _GUICtrlVLC_GetMeta, _GUICtrlVLC_GetMRL, _GUICtrlVLC_GetMediaTracks
; Fullscreen: _GUICtrlVLC_SetFullscreen, _GUICtrlVLC_GetFullscreen, _GUICtrlVLC_ToggleFullscreen
; VLC.au3 v0.3 compatibility: _VLCErrorHandlerRegister, __VLCInternalErrorHandler
; ===============================================================================================================================

#Region Control

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_Create
; Description ...: Creates an embedded VLC video player control in the current GUI.
; Syntax ........: _GUICtrlVLC_Create($iLeft, $iTop, $iWidth, $iHeight[, $iFlags = $VLC_CTRL_DEFAULT])
; Parameters ....: $iLeft, $iTop, $iWidth, $iHeight - position and size of the video area
;                  $iFlags              - [optional] combination of $VLC_CTRL_* flags
; Return values .: Success - player id (>= 1)
;                  Failure - 0 (= False, like VLC.au3 v0.3), @error:
;                  |$VLC_ERR_NOT_STARTED and others - libVLC could not be started (see _VLC_Startup)
;                  |$VLC_ERR_STATE  - no GUI has been created yet
;                  |$VLC_ERR_LIBVLC - the media player could not be created
; Author ........: Markus Debus, CITRO Computer
; Remarks .......: Calls _VLC_Startup() with default settings if libVLC is not started yet. Call _VLC_Startup() yourself
;                  first to use another VLC directory or libVLC options.
;                  The parent window gets the style WS_CLIPCHILDREN (required by libVLC, prevents flicker) unless
;                  $VLC_CTRL_KEEP_PARENT_STYLE is given.
; Related .......: _GUICtrlVLC_Delete, _GUICtrlVLC_Open, _GUICtrlVLC_Add
; ===============================================================================================================================
Func _GUICtrlVLC_Create($iLeft, $iTop, $iWidth, $iHeight, $iFlags = $VLC_CTRL_DEFAULT)
	If IsKeyword($iFlags) Then $iFlags = $VLC_CTRL_DEFAULT
	If Not _VLC_IsStarted() Then
		If Not _VLC_Startup() Then Return SetError(@error, 0, 0)
	EndIf
	; SS_NOTIFY (click events) | WS_CLIPSIBLINGS | WS_CLIPCHILDREN
	Local $idCtrl = GUICtrlCreateLabel("", $iLeft, $iTop, $iWidth, $iHeight, BitOR(0x0100, 0x04000000, 0x02000000))
	If $idCtrl = 0 Then Return SetError($VLC_ERR_STATE, 0, __VLC_ErrRet(0, "_GUICtrlVLC_Create: no GUI (call GUICreate first)"))
	GUICtrlSetBkColor($idCtrl, 0x000000)
	Local $hHost = GUICtrlGetHandle($idCtrl)
	Local $aParent = DllCall("user32.dll", "hwnd", "GetParent", "hwnd", $hHost)
	Local $hParent = @error ? 0 : $aParent[0]
	If Not BitAND($iFlags, $VLC_CTRL_KEEP_PARENT_STYLE) And $hParent <> 0 Then __GUICtrlVLC_AddStyle($hParent, 0x02000000)

	Local $pPlayer = _libvlc_media_player_new(_VLC_GetInstance())
	If @error Or $pPlayer = 0 Then
		GUICtrlDelete($idCtrl)
		Return SetError($VLC_ERR_LIBVLC, 0, __VLC_LibErrRet(0, "libvlc_media_player_new() failed"))
	EndIf
	_libvlc_media_player_set_hwnd($pPlayer, $hHost)
	_libvlc_video_set_mouse_input($pPlayer, BitAND($iFlags, $VLC_CTRL_VLC_MOUSE) ? 1 : 0)
	_libvlc_video_set_key_input($pPlayer, BitAND($iFlags, $VLC_CTRL_VLC_KEYS) ? 1 : 0)
	_libvlc_media_player_set_role($pPlayer, $libvlc_role_Video)

	; find a free slot
	Local $iId = 0
	For $i = 1 To $__g_aVLCC[0][0]
		If Not $__g_aVLCC[$i][$__VLCC_USED] Then
			$iId = $i
			ExitLoop
		EndIf
	Next
	If $iId = 0 Then
		$iId = $__g_aVLCC[0][0] + 1
		ReDim $__g_aVLCC[$iId + 1][$__VLCC_COLS]
		$__g_aVLCC[0][0] = $iId
	EndIf
	Local $aList[1] = [0], $aRect[4] = [$iLeft, $iTop, $iWidth, $iHeight]
	$__g_aVLCC[$iId][$__VLCC_USED] = True
	$__g_aVLCC[$iId][$__VLCC_PLAYER] = $pPlayer
	$__g_aVLCC[$iId][$__VLCC_MEDIA] = Ptr(0)
	$__g_aVLCC[$iId][$__VLCC_HOST] = $hHost
	$__g_aVLCC[$iId][$__VLCC_CTRLID] = $idCtrl
	$__g_aVLCC[$iId][$__VLCC_PARENT] = $hParent
	$__g_aVLCC[$iId][$__VLCC_SUB] = 0
	$__g_aVLCC[$iId][$__VLCC_CALLBACK] = ""
	$__g_aVLCC[$iId][$__VLCC_LIST] = $aList
	$__g_aVLCC[$iId][$__VLCC_LISTOPT] = $aList
	$__g_aVLCC[$iId][$__VLCC_CURRENT] = -1
	$__g_aVLCC[$iId][$__VLCC_LOOP] = $VLC_LOOP_NONE
	$__g_aVLCC[$iId][$__VLCC_FS] = False
	$__g_aVLCC[$iId][$__VLCC_FSGUI] = 0
	$__g_aVLCC[$iId][$__VLCC_FSRECT] = $aRect
	$__g_aVLCC[$iId][$__VLCC_VOLUME] = -1
	$__g_aVLCC[$iId][$__VLCC_MUTE] = -1
	$__g_aVLCC[$iId][$__VLCC_FLAGS] = $iFlags
	$__g_aVLCC[$iId][$__VLCC_LASTCLICK] = 0
	If Not __GUICtrlVLC_Subscribe($iId) Then
		Local $iErr = @error
		_VLC_PlayerRelease($pPlayer)
		GUICtrlDelete($idCtrl)
		$__g_aVLCC[$iId][$__VLCC_USED] = False
		Return SetError($iErr, 0, 0)
	EndIf
	Return $iId
EndFunc   ;==>_GUICtrlVLC_Create

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_Delete
; Description ...: Stops playback, releases the player and deletes the control.
; Syntax ........: _GUICtrlVLC_Delete($iPlayer)
; Return values .: Success - True
;                  Failure - False, @error = $VLC_ERR_PARAM (unknown player) or $VLC_ERR_TIMEOUT
; ===============================================================================================================================
Func _GUICtrlVLC_Delete($iPlayer)
	If Not __GUICtrlVLC_Valid($iPlayer) Then Return SetError($VLC_ERR_PARAM, 0, False)
	If $__g_aVLCC[$iPlayer][$__VLCC_FS] Then _GUICtrlVLC_SetFullscreen($iPlayer, False)
	If $__g_aVLCC[$iPlayer][$__VLCC_SUB] Then _VLC_EventDetach($__g_aVLCC[$iPlayer][$__VLCC_SUB])
	Local $bOk = _VLC_PlayerRelease($__g_aVLCC[$iPlayer][$__VLCC_PLAYER])
	Local $iErr = @error
	If $bOk Then
		If $__g_aVLCC[$iPlayer][$__VLCC_MEDIA] <> 0 Then _libvlc_media_release($__g_aVLCC[$iPlayer][$__VLCC_MEDIA])
		GUICtrlDelete($__g_aVLCC[$iPlayer][$__VLCC_CTRLID])
	Else
		; libVLC did not finish in time: its video window still lives inside the control. Destroying the control
		; could crash libVLC later, so it is only hidden; player and media are abandoned.
		GUICtrlSetState($__g_aVLCC[$iPlayer][$__VLCC_CTRLID], 32) ; $GUI_HIDE
	EndIf
	For $c = 0 To $__VLCC_COLS - 1
		$__g_aVLCC[$iPlayer][$c] = 0
	Next
	$__g_aVLCC[$iPlayer][$__VLCC_USED] = False
	Return SetError($iErr, 0, $bOk)
EndFunc   ;==>_GUICtrlVLC_Delete

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_GetPlayer
; Description ...: Returns the libvlc_media_player_t pointer of a player (for the raw _libvlc_* functions).
; Syntax ........: _GUICtrlVLC_GetPlayer($iPlayer)
; Return values .: Success - pointer; Failure - Ptr(0), @error = $VLC_ERR_PARAM
; ===============================================================================================================================
Func _GUICtrlVLC_GetPlayer($iPlayer)
	If Not __GUICtrlVLC_Valid($iPlayer) Then Return SetError($VLC_ERR_PARAM, 0, Ptr(0))
	Return $__g_aVLCC[$iPlayer][$__VLCC_PLAYER]
EndFunc   ;==>_GUICtrlVLC_GetPlayer

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_GetHandle
; Description ...: Returns the window handle of the video area.
; Syntax ........: _GUICtrlVLC_GetHandle($iPlayer)
; ===============================================================================================================================
Func _GUICtrlVLC_GetHandle($iPlayer)
	If Not __GUICtrlVLC_Valid($iPlayer) Then Return SetError($VLC_ERR_PARAM, 0, 0)
	Return $__g_aVLCC[$iPlayer][$__VLCC_HOST]
EndFunc   ;==>_GUICtrlVLC_GetHandle

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_GetCtrlID
; Description ...: Returns the AutoIt control id of the video area (GUIGetMsg returns it when the video is clicked).
; Syntax ........: _GUICtrlVLC_GetCtrlID($iPlayer)
; ===============================================================================================================================
Func _GUICtrlVLC_GetCtrlID($iPlayer)
	If Not __GUICtrlVLC_Valid($iPlayer) Then Return SetError($VLC_ERR_PARAM, 0, 0)
	Return $__g_aVLCC[$iPlayer][$__VLCC_CTRLID]
EndFunc   ;==>_GUICtrlVLC_GetCtrlID

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_SetPos
; Description ...: Moves/resizes the video area (the video follows automatically).
; Syntax ........: _GUICtrlVLC_SetPos($iPlayer, $iLeft, $iTop[, $iWidth = Default[, $iHeight = Default]])
; Remarks .......: In fullscreen mode the new position is used when fullscreen ends.
; ===============================================================================================================================
Func _GUICtrlVLC_SetPos($iPlayer, $iLeft, $iTop, $iWidth = Default, $iHeight = Default)
	If Not __GUICtrlVLC_Valid($iPlayer) Then Return SetError($VLC_ERR_PARAM, 0, False)
	If $__g_aVLCC[$iPlayer][$__VLCC_FS] Then
		Local $aR = $__g_aVLCC[$iPlayer][$__VLCC_FSRECT]
		$aR[0] = $iLeft
		$aR[1] = $iTop
		If Not IsKeyword($iWidth) Then $aR[2] = $iWidth
		If Not IsKeyword($iHeight) Then $aR[3] = $iHeight
		$__g_aVLCC[$iPlayer][$__VLCC_FSRECT] = $aR
		Return True
	EndIf
	Return GUICtrlSetPos($__g_aVLCC[$iPlayer][$__VLCC_CTRLID], $iLeft, $iTop, $iWidth, $iHeight) = 1
EndFunc   ;==>_GUICtrlVLC_SetPos

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_SetResizing
; Description ...: Sets the resizing behaviour of the video area (see GUICtrlSetResizing, e.g. $GUI_DOCKBORDERS = 102).
; Syntax ........: _GUICtrlVLC_SetResizing($iPlayer, $iResizing)
; Remarks .......: The parent GUI must have $WS_SIZEBOX / $WS_MAXIMIZEBOX to be resizable by the user.
; ===============================================================================================================================
Func _GUICtrlVLC_SetResizing($iPlayer, $iResizing)
	If Not __GUICtrlVLC_Valid($iPlayer) Then Return SetError($VLC_ERR_PARAM, 0, False)
	Return GUICtrlSetResizing($__g_aVLCC[$iPlayer][$__VLCC_CTRLID], $iResizing) = 1
EndFunc   ;==>_GUICtrlVLC_SetResizing

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_SetEventCallback
; Description ...: Sets the function that receives the events of a player.
; Syntax ........: _GUICtrlVLC_SetEventCallback($iPlayer, $sFunction[, $bTimeEvents = Default])
; Parameters ....: $sFunction           - "" = no callback, otherwise:
;                                         Func MyVlcEvent($iPlayer, $iEvent, $vValue1, $vValue2)
;                                         $iEvent = $libvlc_MediaPlayer* constant, values see _VLC_EventsProcess()
;                  $bTimeEvents         - [optional] True also delivers TimeChanged/PositionChanged (several per second).
;                                         Default keeps the current setting ($VLC_CTRL_TIME_EVENTS of _GUICtrlVLC_Create).
; Return values .: Success - True; Failure - False, @error set
; Remarks .......: The callback runs on the AutoIt thread (Adlib, every 20 ms). It may call every UDF function.
; ===============================================================================================================================
Func _GUICtrlVLC_SetEventCallback($iPlayer, $sFunction, $bTimeEvents = Default)
	If Not __GUICtrlVLC_Valid($iPlayer) Then Return SetError($VLC_ERR_PARAM, 0, False)
	$__g_aVLCC[$iPlayer][$__VLCC_CALLBACK] = $sFunction
	If Not IsKeyword($bTimeEvents) Then
		Local $iFlags = $__g_aVLCC[$iPlayer][$__VLCC_FLAGS]
		Local $bOld = BitAND($iFlags, $VLC_CTRL_TIME_EVENTS) <> 0
		If $bOld <> ($bTimeEvents = True) Then
			$__g_aVLCC[$iPlayer][$__VLCC_FLAGS] = $bTimeEvents ? BitOR($iFlags, $VLC_CTRL_TIME_EVENTS) : BitAND($iFlags, BitNOT($VLC_CTRL_TIME_EVENTS))
			If $__g_aVLCC[$iPlayer][$__VLCC_SUB] Then _VLC_EventDetach($__g_aVLCC[$iPlayer][$__VLCC_SUB])
			$__g_aVLCC[$iPlayer][$__VLCC_SUB] = 0
			If Not __GUICtrlVLC_Subscribe($iPlayer) Then Return SetError(@error, 0, False)
		EndIf
	EndIf
	Return True
EndFunc   ;==>_GUICtrlVLC_SetEventCallback

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_IsDoubleClick
; Description ...: Call it when GUIGetMsg()/OnEvent reports a click on the video; returns True for the second click of a
;                  double click (system double click time).
; Syntax ........: _GUICtrlVLC_IsDoubleClick($iPlayer)
; Example .......: Case _GUICtrlVLC_GetCtrlID($iVlc)
;                      If _GUICtrlVLC_IsDoubleClick($iVlc) Then _GUICtrlVLC_ToggleFullscreen($iVlc)
; ===============================================================================================================================
Func _GUICtrlVLC_IsDoubleClick($iPlayer)
	If Not __GUICtrlVLC_Valid($iPlayer) Then Return SetError($VLC_ERR_PARAM, 0, False)
	Local $aDbl = DllCall("user32.dll", "uint", "GetDoubleClickTime")
	Local $iDbl = @error ? 500 : $aDbl[0]
	Local $hLast = $__g_aVLCC[$iPlayer][$__VLCC_LASTCLICK]
	If $hLast <> 0 And TimerDiff($hLast) <= $iDbl Then
		$__g_aVLCC[$iPlayer][$__VLCC_LASTCLICK] = 0
		Return True
	EndIf
	$__g_aVLCC[$iPlayer][$__VLCC_LASTCLICK] = TimerInit()
	Return False
EndFunc   ;==>_GUICtrlVLC_IsDoubleClick
#EndRegion Control

#Region Playlist

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_Add
; Description ...: Adds a file or URL (rtsp://, http(s)://, dshow:// ...) to the playlist of a player.
; Syntax ........: _GUICtrlVLC_Add($iPlayer, $sMRL[, $vOptions = Default])
; Parameters ....: $sMRL                - local path (absolute or relative) or URL
;                  $vOptions            - [optional] media options for this item, array or "|" separated,
;                                         e.g. ":network-caching=300|:rtsp-tcp"
; Return values .: Success - 0-based item number (use it with _GUICtrlVLC_Play)
;                  Failure - -1, @error = $VLC_ERR_PARAM or $VLC_ERR_NOTFOUND (local file does not exist)
; Remarks .......: Unlike VLC.au3 v0.3, every URL scheme is supported (v0.3 only knew rtsp://).
; ===============================================================================================================================
Func _GUICtrlVLC_Add($iPlayer, $sMRL, $vOptions = Default)
	If Not __GUICtrlVLC_Valid($iPlayer) Then Return SetError($VLC_ERR_PARAM, 0, -1)
	$sMRL = String($sMRL)
	If $sMRL = "" Then Return SetError($VLC_ERR_PARAM, 0, -1)
	If Not _VLC_IsUrl($sMRL) Then
		$sMRL = __VLC_FullPath($sMRL)
		If Not FileExists($sMRL) Then Return SetError($VLC_ERR_NOTFOUND, 0, __VLC_ErrRet(-1, "file not found: " & $sMRL))
	EndIf
	Local $aOpt = __VLC_OptionsToArray($vOptions), $sOpt = ""
	For $i = 0 To UBound($aOpt) - 1
		$sOpt &= ($i ? "|" : "") & $aOpt[$i]
	Next
	Local $aList = $__g_aVLCC[$iPlayer][$__VLCC_LIST], $aListOpt = $__g_aVLCC[$iPlayer][$__VLCC_LISTOPT]
	Local $n = $aList[0] + 1
	ReDim $aList[$n + 1]
	ReDim $aListOpt[$n + 1]
	$aList[$n] = $sMRL
	$aListOpt[$n] = $sOpt
	$aList[0] = $n
	$aListOpt[0] = $n
	$__g_aVLCC[$iPlayer][$__VLCC_LIST] = $aList
	$__g_aVLCC[$iPlayer][$__VLCC_LISTOPT] = $aListOpt
	Return $n - 1
EndFunc   ;==>_GUICtrlVLC_Add

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_Clear
; Description ...: Stops playback and removes all items from the playlist.
; Syntax ........: _GUICtrlVLC_Clear($iPlayer)
; Return values .: Success - True; Failure - False, @error set
; ===============================================================================================================================
Func _GUICtrlVLC_Clear($iPlayer)
	If Not __GUICtrlVLC_Valid($iPlayer) Then Return SetError($VLC_ERR_PARAM, 0, False)
	Local $pPlayer = $__g_aVLCC[$iPlayer][$__VLCC_PLAYER]
	If Not _VLC_PlayerStop($pPlayer) Then Return SetError(@error, 0, False) ; never touch a player whose stop hangs
	_libvlc_media_player_set_media($pPlayer, Null)
	If $__g_aVLCC[$iPlayer][$__VLCC_MEDIA] <> 0 Then _libvlc_media_release($__g_aVLCC[$iPlayer][$__VLCC_MEDIA])
	$__g_aVLCC[$iPlayer][$__VLCC_MEDIA] = Ptr(0)
	Local $aList[1] = [0]
	$__g_aVLCC[$iPlayer][$__VLCC_LIST] = $aList
	$__g_aVLCC[$iPlayer][$__VLCC_LISTOPT] = $aList
	$__g_aVLCC[$iPlayer][$__VLCC_CURRENT] = -1
	Return True
EndFunc   ;==>_GUICtrlVLC_Clear

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_GetCount
; Description ...: Returns the number of playlist items.
; Syntax ........: _GUICtrlVLC_GetCount($iPlayer)
; ===============================================================================================================================
Func _GUICtrlVLC_GetCount($iPlayer)
	If Not __GUICtrlVLC_Valid($iPlayer) Then Return SetError($VLC_ERR_PARAM, 0, 0)
	Local $aList = $__g_aVLCC[$iPlayer][$__VLCC_LIST]
	Return $aList[0]
EndFunc   ;==>_GUICtrlVLC_GetCount

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_GetItem
; Description ...: Returns the path/URL of a playlist item ("" and @error = $VLC_ERR_PARAM if it does not exist).
; Syntax ........: _GUICtrlVLC_GetItem($iPlayer, $iItem)
; ===============================================================================================================================
Func _GUICtrlVLC_GetItem($iPlayer, $iItem)
	If Not __GUICtrlVLC_Valid($iPlayer) Then Return SetError($VLC_ERR_PARAM, 0, "")
	Local $aList = $__g_aVLCC[$iPlayer][$__VLCC_LIST]
	If $iItem < 0 Or $iItem >= $aList[0] Then Return SetError($VLC_ERR_PARAM, 0, "")
	Return $aList[$iItem + 1]
EndFunc   ;==>_GUICtrlVLC_GetItem

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_GetCurrentItem
; Description ...: Returns the 0-based number of the current playlist item, -1 if none.
; Syntax ........: _GUICtrlVLC_GetCurrentItem($iPlayer)
; ===============================================================================================================================
Func _GUICtrlVLC_GetCurrentItem($iPlayer)
	If Not __GUICtrlVLC_Valid($iPlayer) Then Return SetError($VLC_ERR_PARAM, 0, -1)
	Return $__g_aVLCC[$iPlayer][$__VLCC_CURRENT]
EndFunc   ;==>_GUICtrlVLC_GetCurrentItem

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_Open
; Description ...: Replaces the playlist by one file/URL and (optionally) starts playing it.
; Syntax ........: _GUICtrlVLC_Open($iPlayer, $sMRL[, $vOptions = Default[, $bPlay = True]])
; Return values .: Success - True; Failure - False, @error set (_VLC_GetLastError() has details)
; Remarks .......: Recommended way to (re)start a single stream, e.g. an IP camera:
;                  _GUICtrlVLC_Open($iVlc, "rtsp://user:pass@192.168.1.10/stream1", ":network-caching=300")
; ===============================================================================================================================
Func _GUICtrlVLC_Open($iPlayer, $sMRL, $vOptions = Default, $bPlay = True)
	If Not __GUICtrlVLC_Valid($iPlayer) Then Return SetError($VLC_ERR_PARAM, 0, False)
	_GUICtrlVLC_Clear($iPlayer)
	Local $iItem = _GUICtrlVLC_Add($iPlayer, $sMRL, $vOptions)
	If $iItem < 0 Then Return SetError(@error, 0, False)
	$__g_aVLCC[$iPlayer][$__VLCC_CURRENT] = 0
	If Not $bPlay Then Return True
	Local $bOk = __GUICtrlVLC_PlayIndex($iPlayer, 0)
	Return SetError(@error, 0, $bOk)
EndFunc   ;==>_GUICtrlVLC_Open

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_Play
; Description ...: Plays a playlist item, or resumes/restarts the current one.
; Syntax ........: _GUICtrlVLC_Play($iPlayer[, $iItem = Default])
; Parameters ....: $iItem               - [optional] 0-based item number (as returned by _GUICtrlVLC_Add).
;                                         Default: resume if paused, otherwise (re)start the current item.
; Return values .: Success - True; Failure - False, @error set
; ===============================================================================================================================
Func _GUICtrlVLC_Play($iPlayer, $iItem = Default)
	If Not __GUICtrlVLC_Valid($iPlayer) Then Return SetError($VLC_ERR_PARAM, 0, False)
	Local $bOk
	If Not IsKeyword($iItem) And $iItem >= 0 Then
		$bOk = __GUICtrlVLC_PlayIndex($iPlayer, Int($iItem))
		Return SetError(@error, 0, $bOk)
	EndIf
	Local $pPlayer = $__g_aVLCC[$iPlayer][$__VLCC_PLAYER]
	Local $iState = _libvlc_media_player_get_state($pPlayer)
	If $iState = $libvlc_Paused Then
		_libvlc_media_player_set_pause($pPlayer, 0)
		Return True
	EndIf
	If $iState = $libvlc_Playing Or $iState = $libvlc_Opening Or $iState = $libvlc_Buffering Then Return True
	Local $iCur = $__g_aVLCC[$iPlayer][$__VLCC_CURRENT]
	If $iCur < 0 Then $iCur = 0
	If $iCur >= _GUICtrlVLC_GetCount($iPlayer) Then Return SetError($VLC_ERR_STATE, 0, __VLC_ErrRet(False, "playlist is empty"))
	$bOk = __GUICtrlVLC_PlayIndex($iPlayer, $iCur)
	Return SetError(@error, 0, $bOk)
EndFunc   ;==>_GUICtrlVLC_Play

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_Next
; Description ...: Plays the next playlist item (wraps around with $VLC_LOOP_ALL).
; Syntax ........: _GUICtrlVLC_Next($iPlayer)
; Return values .: Success - True; Failure - False, @error = $VLC_ERR_STATE (no next item) or other
; ===============================================================================================================================
Func _GUICtrlVLC_Next($iPlayer)
	If Not __GUICtrlVLC_Valid($iPlayer) Then Return SetError($VLC_ERR_PARAM, 0, False)
	Local $n = _GUICtrlVLC_GetCount($iPlayer), $i = $__g_aVLCC[$iPlayer][$__VLCC_CURRENT] + 1
	If $i >= $n Then
		If $__g_aVLCC[$iPlayer][$__VLCC_LOOP] <> $VLC_LOOP_ALL Or $n = 0 Then Return SetError($VLC_ERR_STATE, 0, False)
		$i = 0
	EndIf
	Local $bOk = __GUICtrlVLC_PlayIndex($iPlayer, $i)
	Return SetError(@error, 0, $bOk)
EndFunc   ;==>_GUICtrlVLC_Next

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_Previous
; Description ...: Plays the previous playlist item (wraps around with $VLC_LOOP_ALL).
; Syntax ........: _GUICtrlVLC_Previous($iPlayer)
; ===============================================================================================================================
Func _GUICtrlVLC_Previous($iPlayer)
	If Not __GUICtrlVLC_Valid($iPlayer) Then Return SetError($VLC_ERR_PARAM, 0, False)
	Local $n = _GUICtrlVLC_GetCount($iPlayer), $i = $__g_aVLCC[$iPlayer][$__VLCC_CURRENT] - 1
	If $i < 0 Then
		If $__g_aVLCC[$iPlayer][$__VLCC_LOOP] <> $VLC_LOOP_ALL Or $n = 0 Then Return SetError($VLC_ERR_STATE, 0, False)
		$i = $n - 1
	EndIf
	Local $bOk = __GUICtrlVLC_PlayIndex($iPlayer, $i)
	Return SetError(@error, 0, $bOk)
EndFunc   ;==>_GUICtrlVLC_Previous

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_SetLoop / _GUICtrlVLC_GetLoop
; Description ...: Playlist loop mode: $VLC_LOOP_NONE (stop at the end), $VLC_LOOP_ALL, $VLC_LOOP_ONE (repeat item).
; Syntax ........: _GUICtrlVLC_SetLoop($iPlayer, $iMode) / _GUICtrlVLC_GetLoop($iPlayer)
; Remarks .......: Without a loop the next playlist item starts automatically when an item has ended.
; ===============================================================================================================================
Func _GUICtrlVLC_SetLoop($iPlayer, $iMode)
	If Not __GUICtrlVLC_Valid($iPlayer) Or $iMode < 0 Or $iMode > 2 Then Return SetError($VLC_ERR_PARAM, 0, False)
	$__g_aVLCC[$iPlayer][$__VLCC_LOOP] = Int($iMode)
	Return True
EndFunc   ;==>_GUICtrlVLC_SetLoop

Func _GUICtrlVLC_GetLoop($iPlayer)
	If Not __GUICtrlVLC_Valid($iPlayer) Then Return SetError($VLC_ERR_PARAM, 0, -1)
	Return $__g_aVLCC[$iPlayer][$__VLCC_LOOP]
EndFunc   ;==>_GUICtrlVLC_GetLoop
#EndRegion Playlist

#Region Transport

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_Pause
; Description ...: Toggles pause (like VLC.au3 v0.3).
; Syntax ........: _GUICtrlVLC_Pause($iPlayer)
; Return values .: Success - True; Failure - False (also if nothing is loaded, v0.3 returned 0 then)
; ===============================================================================================================================
Func _GUICtrlVLC_Pause($iPlayer)
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Or $__g_aVLCC[$iPlayer][$__VLCC_MEDIA] = 0 Then Return SetError($VLC_ERR_STATE, 0, False)
	Return _libvlc_media_player_pause($p)
EndFunc   ;==>_GUICtrlVLC_Pause

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_SetPause
; Description ...: Pauses (True) or resumes (False).
; Syntax ........: _GUICtrlVLC_SetPause($iPlayer, $bPause)
; ===============================================================================================================================
Func _GUICtrlVLC_SetPause($iPlayer, $bPause)
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Then Return SetError($VLC_ERR_PARAM, 0, False)
	Return _libvlc_media_player_set_pause($p, $bPause ? 1 : 0)
EndFunc   ;==>_GUICtrlVLC_SetPause

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_Stop
; Description ...: Stops playback (without blocking the GUI).
; Syntax ........: _GUICtrlVLC_Stop($iPlayer)
; Return values .: Success - True; Failure - False, @error = $VLC_ERR_PARAM or $VLC_ERR_TIMEOUT
; ===============================================================================================================================
Func _GUICtrlVLC_Stop($iPlayer)
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Then Return SetError($VLC_ERR_PARAM, 0, False)
	Local $bOk = _VLC_PlayerStop($p)
	Return SetError(@error, 0, $bOk)
EndFunc   ;==>_GUICtrlVLC_Stop

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_GetState
; Description ...: Returns the player state: $VLC_STATE_IDLE (0), _OPENING (1), _BUFFERING (2), _PLAYING (3),
;                  _PAUSED (4), _STOPPED (5), _ENDED (6), _ERROR (7). Same values as VLC.au3 v0.3.
; Syntax ........: _GUICtrlVLC_GetState($iPlayer)
; Return values .: State, or 0 with @error = $VLC_ERR_PARAM for an unknown player
; ===============================================================================================================================
Func _GUICtrlVLC_GetState($iPlayer)
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Then Return SetError($VLC_ERR_PARAM, 0, 0)
	Local $iState = _libvlc_media_player_get_state($p)
	If @error Or $iState < 0 Then Return 0
	Return $iState
EndFunc   ;==>_GUICtrlVLC_GetState

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_GetStateText
; Description ...: Returns the state as text ("Idle", "Opening", "Buffering", "Playing", "Paused", "Stopped", "Ended",
;                  "Error").
; Syntax ........: _GUICtrlVLC_GetStateText($iPlayer[, $iState = Default])
; ===============================================================================================================================
Func _GUICtrlVLC_GetStateText($iPlayer, $iState = Default)
	If IsKeyword($iState) Then $iState = _GUICtrlVLC_GetState($iPlayer)
	Local $aText[8] = ["Idle", "Opening", "Buffering", "Playing", "Paused", "Stopped", "Ended", "Error"]
	If $iState < 0 Or $iState > 7 Then Return "Unknown"
	Return $aText[$iState]
EndFunc   ;==>_GUICtrlVLC_GetStateText

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_IsPlaying / _IsSeekable / _CanPause
; Description ...: State queries, return True/False.
; ===============================================================================================================================
Func _GUICtrlVLC_IsPlaying($iPlayer)
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Then Return SetError($VLC_ERR_PARAM, 0, False)
	Return _libvlc_media_player_is_playing($p) = 1
EndFunc   ;==>_GUICtrlVLC_IsPlaying

Func _GUICtrlVLC_IsSeekable($iPlayer)
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Then Return SetError($VLC_ERR_PARAM, 0, False)
	Return _libvlc_media_player_is_seekable($p) = 1
EndFunc   ;==>_GUICtrlVLC_IsSeekable

Func _GUICtrlVLC_CanPause($iPlayer)
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Then Return SetError($VLC_ERR_PARAM, 0, False)
	Return _libvlc_media_player_can_pause($p) = 1
EndFunc   ;==>_GUICtrlVLC_CanPause

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_NextFrame
; Description ...: Shows the next video frame (and pauses).
; Syntax ........: _GUICtrlVLC_NextFrame($iPlayer)
; ===============================================================================================================================
Func _GUICtrlVLC_NextFrame($iPlayer)
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Then Return SetError($VLC_ERR_PARAM, 0, False)
	Return _libvlc_media_player_next_frame($p)
EndFunc   ;==>_GUICtrlVLC_NextFrame
#EndRegion Transport

#Region Time

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_GetTime / _GUICtrlVLC_GetLength
; Description ...: Current position / length of the media in ms (-1 if unknown).
; ===============================================================================================================================
Func _GUICtrlVLC_GetTime($iPlayer)
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1)
	Return _libvlc_media_player_get_time($p)
EndFunc   ;==>_GUICtrlVLC_GetTime

Func _GUICtrlVLC_GetLength($iPlayer)
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1)
	Return _libvlc_media_player_get_length($p)
EndFunc   ;==>_GUICtrlVLC_GetLength

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_SetTime / _GUICtrlVLC_SeekAbsolute
; Description ...: Jumps to an absolute position in ms (SeekAbsolute = name of VLC.au3 v0.3).
; Syntax ........: _GUICtrlVLC_SetTime($iPlayer, $iMs)
; Return values .: Success - True; Failure - False ($VLC_ERR_STATE if nothing is loaded or the media is not seekable)
; ===============================================================================================================================
Func _GUICtrlVLC_SetTime($iPlayer, $iMs)
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Then Return SetError($VLC_ERR_PARAM, 0, False)
	If $__g_aVLCC[$iPlayer][$__VLCC_MEDIA] = 0 Or _libvlc_media_player_is_seekable($p) <> 1 Then Return SetError($VLC_ERR_STATE, 0, False)
	If $iMs < 0 Then $iMs = 0
	Return _libvlc_media_player_set_time($p, Int($iMs))
EndFunc   ;==>_GUICtrlVLC_SetTime

Func _GUICtrlVLC_SeekAbsolute($iPlayer, $iMs)
	Local $bOk = _GUICtrlVLC_SetTime($iPlayer, $iMs)
	Return SetError(@error, 0, $bOk)
EndFunc   ;==>_GUICtrlVLC_SeekAbsolute

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_SeekRelative
; Description ...: Jumps forward (positive) or backward (negative) by $iMs milliseconds.
; Syntax ........: _GUICtrlVLC_SeekRelative($iPlayer, $iMs)
; ===============================================================================================================================
Func _GUICtrlVLC_SeekRelative($iPlayer, $iMs)
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Then Return SetError($VLC_ERR_PARAM, 0, False)
	Local $iNew = _libvlc_media_player_get_time($p) + $iMs
	Local $iLen = _libvlc_media_player_get_length($p)
	If $iLen > 0 And $iNew > $iLen - 500 Then $iNew = $iLen - 500
	Local $bOk = _GUICtrlVLC_SetTime($iPlayer, $iNew)
	Return SetError(@error, 0, $bOk)
EndFunc   ;==>_GUICtrlVLC_SeekRelative

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_GetPosition / _GUICtrlVLC_SetPosition
; Description ...: Position as fraction 0.0 - 1.0 (useful for sliders).
; ===============================================================================================================================
Func _GUICtrlVLC_GetPosition($iPlayer)
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1)
	Return _libvlc_media_player_get_position($p)
EndFunc   ;==>_GUICtrlVLC_GetPosition

Func _GUICtrlVLC_SetPosition($iPlayer, $fPosition)
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Then Return SetError($VLC_ERR_PARAM, 0, False)
	If $fPosition < 0 Then $fPosition = 0
	If $fPosition > 1 Then $fPosition = 1
	Return _libvlc_media_player_set_position($p, $fPosition)
EndFunc   ;==>_GUICtrlVLC_SetPosition

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_GetRate / _GUICtrlVLC_SetRate
; Description ...: Playback speed (1.0 = normal, 2.0 = double, 0.5 = half).
; ===============================================================================================================================
Func _GUICtrlVLC_GetRate($iPlayer)
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Then Return SetError($VLC_ERR_PARAM, 0, 0)
	Return _libvlc_media_player_get_rate($p)
EndFunc   ;==>_GUICtrlVLC_GetRate

Func _GUICtrlVLC_SetRate($iPlayer, $fRate)
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Or $fRate <= 0 Then Return SetError($VLC_ERR_PARAM, 0, False)
	Return _libvlc_media_player_set_rate($p, $fRate) = 0
EndFunc   ;==>_GUICtrlVLC_SetRate
#EndRegion Time

#Region Audio

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_GetVolume
; Description ...: Returns the volume in percent (0 - 200, 100 = normal).
; Syntax ........: _GUICtrlVLC_GetVolume($iPlayer)
; Remarks .......: Returns the value set with _GUICtrlVLC_SetVolume() even if no audio output exists yet.
; ===============================================================================================================================
Func _GUICtrlVLC_GetVolume($iPlayer)
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1)
	If $__g_aVLCC[$iPlayer][$__VLCC_VOLUME] >= 0 Then Return $__g_aVLCC[$iPlayer][$__VLCC_VOLUME]
	Local $iVol = _libvlc_audio_get_volume($p)
	If $iVol < 0 Then Return 100
	Return $iVol
EndFunc   ;==>_GUICtrlVLC_GetVolume

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_SetVolume
; Description ...: Sets the volume in percent (0 - 200).
; Syntax ........: _GUICtrlVLC_SetVolume($iPlayer, $iLevel)
; Return values .: Success - True (@extended = 1: no audio output yet, the value is applied when playback starts)
;                  Failure - False, @error = $VLC_ERR_PARAM
; ===============================================================================================================================
Func _GUICtrlVLC_SetVolume($iPlayer, $iLevel)
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Then Return SetError($VLC_ERR_PARAM, 0, False)
	$iLevel = Int($iLevel)
	If $iLevel < 0 Then $iLevel = 0
	If $iLevel > 200 Then $iLevel = 200
	$__g_aVLCC[$iPlayer][$__VLCC_VOLUME] = $iLevel
	If _libvlc_audio_set_volume($p, $iLevel) <> 0 Then Return SetExtended(1, True)
	Return True
EndFunc   ;==>_GUICtrlVLC_SetVolume

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_GetMute / _GUICtrlVLC_SetMute / _GUICtrlVLC_ToggleMute
; Description ...: Mute state (True = muted). Like the volume, the state is remembered until audio is available.
; ===============================================================================================================================
Func _GUICtrlVLC_GetMute($iPlayer)
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Then Return SetError($VLC_ERR_PARAM, 0, False)
	If $__g_aVLCC[$iPlayer][$__VLCC_MUTE] >= 0 Then Return $__g_aVLCC[$iPlayer][$__VLCC_MUTE] = 1
	Return _libvlc_audio_get_mute($p) = 1
EndFunc   ;==>_GUICtrlVLC_GetMute

Func _GUICtrlVLC_SetMute($iPlayer, $bMute)
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Then Return SetError($VLC_ERR_PARAM, 0, False)
	$__g_aVLCC[$iPlayer][$__VLCC_MUTE] = $bMute ? 1 : 0
	_libvlc_audio_set_mute($p, $bMute ? 1 : 0)
	Return True
EndFunc   ;==>_GUICtrlVLC_SetMute

Func _GUICtrlVLC_ToggleMute($iPlayer)
	If Not __GUICtrlVLC_Valid($iPlayer) Then Return SetError($VLC_ERR_PARAM, 0, False)
	Return _GUICtrlVLC_SetMute($iPlayer, Not _GUICtrlVLC_GetMute($iPlayer))
EndFunc   ;==>_GUICtrlVLC_ToggleMute

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_GetAudioTracks / _GetAudioTrack / _SetAudioTrack
; Description ...: Audio tracks of the playing media: 2D array [0][0] = count, [n][0] = id, [n][1] = name.
;                  Id -1 is "Disable". _SetAudioTrack takes the id.
; ===============================================================================================================================
Func _GUICtrlVLC_GetAudioTracks($iPlayer)
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Then
		Local $aErr[1][2] = [[0, ""]]
		Return SetError($VLC_ERR_PARAM, 0, $aErr)
	EndIf
	Return _VLC_PlayerGetAudioTracks($p)
EndFunc   ;==>_GUICtrlVLC_GetAudioTracks

Func _GUICtrlVLC_GetAudioTrack($iPlayer)
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1)
	Return _libvlc_audio_get_track($p)
EndFunc   ;==>_GUICtrlVLC_GetAudioTrack

Func _GUICtrlVLC_SetAudioTrack($iPlayer, $iTrackId)
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Then Return SetError($VLC_ERR_PARAM, 0, False)
	Return _libvlc_audio_set_track($p, $iTrackId) = 0
EndFunc   ;==>_GUICtrlVLC_SetAudioTrack

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_GetAudioDelay / _GUICtrlVLC_SetAudioDelay
; Description ...: Audio delay in milliseconds (positive = audio later).
; ===============================================================================================================================
Func _GUICtrlVLC_GetAudioDelay($iPlayer)
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Then Return SetError($VLC_ERR_PARAM, 0, 0)
	Return Round(_libvlc_audio_get_delay($p) / 1000)
EndFunc   ;==>_GUICtrlVLC_GetAudioDelay

Func _GUICtrlVLC_SetAudioDelay($iPlayer, $iMs)
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Then Return SetError($VLC_ERR_PARAM, 0, False)
	Return _libvlc_audio_set_delay($p, Int($iMs) * 1000) = 0
EndFunc   ;==>_GUICtrlVLC_SetAudioDelay

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_GetAudioDevices / _GUICtrlVLC_SetAudioDevice
; Description ...: Audio devices of the current output: 2D array [0][0] = count, [n][0] = device id, [n][1] = name.
;                  _SetAudioDevice takes the device id ("" = system default).
; ===============================================================================================================================
Func _GUICtrlVLC_GetAudioDevices($iPlayer)
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Then
		Local $aErr[1][2] = [[0, ""]]
		Return SetError($VLC_ERR_PARAM, 0, $aErr)
	EndIf
	Return _VLC_AudioOutputDeviceList($p)
EndFunc   ;==>_GUICtrlVLC_GetAudioDevices

Func _GUICtrlVLC_SetAudioDevice($iPlayer, $sDeviceId)
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Then Return SetError($VLC_ERR_PARAM, 0, False)
	Return _libvlc_audio_output_device_set($p, Null, $sDeviceId)
EndFunc   ;==>_GUICtrlVLC_SetAudioDevice

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_SetEqualizer
; Description ...: Enables the equalizer with a preset or own band values, or disables it.
; Syntax ........: _GUICtrlVLC_SetEqualizer($iPlayer, $vPreset[, $fPreamp = Default])
; Parameters ....: $vPreset             - -1 / Default = equalizer off
;                                         preset index (0-based, see _VLC_EqualizerGetPresets)
;                                         0-based array with up to 10 band amplifications in dB (-20 .. 20)
;                  $fPreamp             - [optional] pre-amplification in dB (-20 .. 20)
; ===============================================================================================================================
Func _GUICtrlVLC_SetEqualizer($iPlayer, $vPreset, $fPreamp = Default)
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Then Return SetError($VLC_ERR_PARAM, 0, False)
	If IsKeyword($vPreset) Or (Not IsArray($vPreset) And $vPreset < 0) Then Return _libvlc_media_player_set_equalizer($p, Null) = 0
	Local $pEq
	If IsArray($vPreset) Then
		$pEq = _libvlc_audio_equalizer_new()
		If $pEq = 0 Then Return SetError($VLC_ERR_LIBVLC, 0, False)
		For $i = 0 To UBound($vPreset) - 1
			_libvlc_audio_equalizer_set_amp_at_index($pEq, $vPreset[$i], $i)
		Next
	Else
		$pEq = _libvlc_audio_equalizer_new_from_preset(Int($vPreset))
		If $pEq = 0 Then Return SetError($VLC_ERR_PARAM, 0, False)
	EndIf
	If Not IsKeyword($fPreamp) Then _libvlc_audio_equalizer_set_preamp($pEq, $fPreamp)
	Local $bOk = _libvlc_media_player_set_equalizer($p, $pEq) = 0
	_libvlc_audio_equalizer_release($pEq) ; the player keeps its own copy
	Return $bOk
EndFunc   ;==>_GUICtrlVLC_SetEqualizer
#EndRegion Audio

#Region Video

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_HasVideo
; Description ...: True if a video output is active.
; ===============================================================================================================================
Func _GUICtrlVLC_HasVideo($iPlayer)
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Then Return SetError($VLC_ERR_PARAM, 0, False)
	Return _libvlc_media_player_has_vout($p) > 0
EndFunc   ;==>_GUICtrlVLC_HasVideo

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_GetVideoSize
; Description ...: Returns the native size of the video: array [0] = width, [1] = height ([0, 0] if unknown).
; ===============================================================================================================================
Func _GUICtrlVLC_GetVideoSize($iPlayer)
	Local $aSize[2] = [0, 0]
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Then Return SetError($VLC_ERR_PARAM, 0, $aSize)
	Local $iW = 0, $iH = 0
	If _libvlc_video_get_size($p, 0, $iW, $iH) = 0 Then
		$aSize[0] = $iW
		$aSize[1] = $iH
	EndIf
	Return $aSize
EndFunc   ;==>_GUICtrlVLC_GetVideoSize

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_TakeSnapshot
; Description ...: Saves the current video frame as PNG/JPG.
; Syntax ........: _GUICtrlVLC_TakeSnapshot($iPlayer, $sFile[, $iWidth = 0[, $iHeight = 0[, $iWait = 3000]]])
; Parameters ....: $sFile               - target file (.png or .jpg), an existing file is replaced
;                  $iWidth, $iHeight    - [optional] size, 0 = original / keep aspect ratio
;                  $iWait               - [optional] ms to wait until the file exists (0 = do not wait)
; Return values .: Success - True; Failure - False, @error = $VLC_ERR_STATE (no video), $VLC_ERR_LIBVLC or
;                  $VLC_ERR_TIMEOUT (file was not written within $iWait)
; ===============================================================================================================================
Func _GUICtrlVLC_TakeSnapshot($iPlayer, $sFile, $iWidth = 0, $iHeight = 0, $iWait = 3000)
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Then Return SetError($VLC_ERR_PARAM, 0, False)
	If _libvlc_media_player_has_vout($p) < 1 Then Return SetError($VLC_ERR_STATE, 0, __VLC_ErrRet(False, "no video output"))
	$sFile = __VLC_FullPath($sFile)
	If FileExists($sFile) Then FileDelete($sFile)
	If _libvlc_video_take_snapshot($p, 0, $sFile, $iWidth, $iHeight) <> 0 Then Return SetError($VLC_ERR_LIBVLC, 0, __VLC_LibErrRet(False, "snapshot failed"))
	If $iWait <= 0 Then Return True
	Local $hTimer = TimerInit()
	While TimerDiff($hTimer) < $iWait
		If FileExists($sFile) And FileGetSize($sFile) > 0 Then Return True
		Sleep(20)
	WEnd
	Return SetError($VLC_ERR_TIMEOUT, 0, False)
EndFunc   ;==>_GUICtrlVLC_TakeSnapshot

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_GetAspectRatio / _GUICtrlVLC_SetAspectRatio
; Description ...: Forced aspect ratio, e.g. "16:9", "4:3"; "" = automatic (from the video).
; ===============================================================================================================================
Func _GUICtrlVLC_GetAspectRatio($iPlayer)
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Then Return SetError($VLC_ERR_PARAM, 0, "")
	Return _libvlc_video_get_aspect_ratio($p)
EndFunc   ;==>_GUICtrlVLC_GetAspectRatio

Func _GUICtrlVLC_SetAspectRatio($iPlayer, $sRatio)
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Then Return SetError($VLC_ERR_PARAM, 0, False)
	Return _libvlc_video_set_aspect_ratio($p, (IsKeyword($sRatio) Or $sRatio = "") ? Null : $sRatio)
EndFunc   ;==>_GUICtrlVLC_SetAspectRatio

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_GetScale / _GUICtrlVLC_SetScale
; Description ...: Zoom factor: 0 = fit into the control (default), 1.0 = original size, 2.0 = double.
; ===============================================================================================================================
Func _GUICtrlVLC_GetScale($iPlayer)
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Then Return SetError($VLC_ERR_PARAM, 0, 0)
	Return _libvlc_video_get_scale($p)
EndFunc   ;==>_GUICtrlVLC_GetScale

Func _GUICtrlVLC_SetScale($iPlayer, $fScale)
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Or $fScale < 0 Then Return SetError($VLC_ERR_PARAM, 0, False)
	Return _libvlc_video_set_scale($p, $fScale)
EndFunc   ;==>_GUICtrlVLC_SetScale

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_SetCrop
; Description ...: Crops the video: "16:9" (ratio), "640x360+0+60" (WxH+X+Y), "10+20+10+20" (borders), "" = off.
; ===============================================================================================================================
Func _GUICtrlVLC_SetCrop($iPlayer, $sGeometry)
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Then Return SetError($VLC_ERR_PARAM, 0, False)
	Return _libvlc_video_set_crop_geometry($p, (IsKeyword($sGeometry) Or $sGeometry = "") ? Null : $sGeometry)
EndFunc   ;==>_GUICtrlVLC_SetCrop

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_SetDeinterlace
; Description ...: Deinterlacing: "" = off, or a mode: "blend", "bob", "discard", "linear", "mean", "x", "yadif",
;                  "yadif2x", "phosphor", "ivtc".
; ===============================================================================================================================
Func _GUICtrlVLC_SetDeinterlace($iPlayer, $sMode)
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Then Return SetError($VLC_ERR_PARAM, 0, False)
	Return _libvlc_video_set_deinterlace($p, (IsKeyword($sMode) Or $sMode = "") ? Null : $sMode)
EndFunc   ;==>_GUICtrlVLC_SetDeinterlace

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_SetAdjust
; Description ...: Picture adjustment. Parameters left at Default keep their value.
; Syntax ........: _GUICtrlVLC_SetAdjust($iPlayer, $bEnable[, $fContrast = Default[, $fBrightness = Default[, $fHue = Default
;                  [, $fSaturation = Default[, $fGamma = Default]]]]])
; Parameters ....: $fContrast 0..2 (1), $fBrightness 0..2 (1), $fHue -180..180 (0), $fSaturation 0..3 (1), $fGamma 0.01..10 (1)
; ===============================================================================================================================
Func _GUICtrlVLC_SetAdjust($iPlayer, $bEnable, $fContrast = Default, $fBrightness = Default, $fHue = Default, $fSaturation = Default, $fGamma = Default)
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Then Return SetError($VLC_ERR_PARAM, 0, False)
	If Not IsKeyword($fContrast) Then _libvlc_video_set_adjust_float($p, $libvlc_adjust_Contrast, $fContrast)
	If Not IsKeyword($fBrightness) Then _libvlc_video_set_adjust_float($p, $libvlc_adjust_Brightness, $fBrightness)
	If Not IsKeyword($fHue) Then _libvlc_video_set_adjust_float($p, $libvlc_adjust_Hue, $fHue)
	If Not IsKeyword($fSaturation) Then _libvlc_video_set_adjust_float($p, $libvlc_adjust_Saturation, $fSaturation)
	If Not IsKeyword($fGamma) Then _libvlc_video_set_adjust_float($p, $libvlc_adjust_Gamma, $fGamma)
	Return _libvlc_video_set_adjust_int($p, $libvlc_adjust_Enable, $bEnable ? 1 : 0)
EndFunc   ;==>_GUICtrlVLC_SetAdjust

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_SetMarquee
; Description ...: Shows a text over the video (e.g. camera name or time).
; Syntax ........: _GUICtrlVLC_SetMarquee($iPlayer, $sText[, $iPosition = Default[, $iSize = Default[, $iColor = Default
;                  [, $iOpacity = Default[, $iTimeout = Default[, $iX = Default[, $iY = Default]]]]]]])
; Parameters ....: $sText               - text; VLC time format codes are allowed, e.g. "%H:%M:%S"
;                  $iPosition           - 0 center, 1 left, 2 right, 4 top, 8 bottom, combinable (5 = top left)
;                  $iSize               - font size in pixels (0 = automatic)
;                  $iColor              - 0xRRGGBB
;                  $iOpacity            - 0..255
;                  $iTimeout            - ms (0 = forever)
;                  $iX, $iY             - offset from the position in pixels
; Remarks .......: Only works while a video is shown; call it again after a new item was started.
; ===============================================================================================================================
Func _GUICtrlVLC_SetMarquee($iPlayer, $sText, $iPosition = Default, $iSize = Default, $iColor = Default, $iOpacity = Default, $iTimeout = Default, $iX = Default, $iY = Default)
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Then Return SetError($VLC_ERR_PARAM, 0, False)
	_libvlc_video_set_marquee_int($p, $libvlc_marquee_Enable, 1)
	_libvlc_video_set_marquee_string($p, $libvlc_marquee_Text, $sText)
	If Not IsKeyword($iPosition) Then _libvlc_video_set_marquee_int($p, $libvlc_marquee_Position, $iPosition)
	If Not IsKeyword($iSize) Then _libvlc_video_set_marquee_int($p, $libvlc_marquee_Size, $iSize)
	If Not IsKeyword($iColor) Then _libvlc_video_set_marquee_int($p, $libvlc_marquee_Color, $iColor)
	If Not IsKeyword($iOpacity) Then _libvlc_video_set_marquee_int($p, $libvlc_marquee_Opacity, $iOpacity)
	If Not IsKeyword($iTimeout) Then _libvlc_video_set_marquee_int($p, $libvlc_marquee_Timeout, $iTimeout)
	If Not IsKeyword($iX) Then _libvlc_video_set_marquee_int($p, $libvlc_marquee_X, $iX)
	If Not IsKeyword($iY) Then _libvlc_video_set_marquee_int($p, $libvlc_marquee_Y, $iY)
	Return True
EndFunc   ;==>_GUICtrlVLC_SetMarquee

Func _GUICtrlVLC_ClearMarquee($iPlayer)
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Then Return SetError($VLC_ERR_PARAM, 0, False)
	Return _libvlc_video_set_marquee_int($p, $libvlc_marquee_Enable, 0)
EndFunc   ;==>_GUICtrlVLC_ClearMarquee

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_GetVideoTracks / _GUICtrlVLC_SetVideoTrack
; Description ...: Video tracks: 2D array [0][0] = count, [n][0] = id, [n][1] = name. _SetVideoTrack takes the id.
; ===============================================================================================================================
Func _GUICtrlVLC_GetVideoTracks($iPlayer)
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Then
		Local $aErr[1][2] = [[0, ""]]
		Return SetError($VLC_ERR_PARAM, 0, $aErr)
	EndIf
	Return _VLC_PlayerGetVideoTracks($p)
EndFunc   ;==>_GUICtrlVLC_GetVideoTracks

Func _GUICtrlVLC_SetVideoTrack($iPlayer, $iTrackId)
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Then Return SetError($VLC_ERR_PARAM, 0, False)
	Return _libvlc_video_set_track($p, $iTrackId) = 0
EndFunc   ;==>_GUICtrlVLC_SetVideoTrack
#EndRegion Video

#Region Subtitles

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_GetSubtitleTracks / _GetSubtitleTrack / _SetSubtitleTrack
; Description ...: Subtitle tracks: 2D array [0][0] = count, [n][0] = id, [n][1] = name. Id -1 = off.
; ===============================================================================================================================
Func _GUICtrlVLC_GetSubtitleTracks($iPlayer)
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Then
		Local $aErr[1][2] = [[0, ""]]
		Return SetError($VLC_ERR_PARAM, 0, $aErr)
	EndIf
	Return _VLC_PlayerGetSubtitleTracks($p)
EndFunc   ;==>_GUICtrlVLC_GetSubtitleTracks

Func _GUICtrlVLC_GetSubtitleTrack($iPlayer)
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1)
	Return _libvlc_video_get_spu($p)
EndFunc   ;==>_GUICtrlVLC_GetSubtitleTrack

Func _GUICtrlVLC_SetSubtitleTrack($iPlayer, $iTrackId)
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Then Return SetError($VLC_ERR_PARAM, 0, False)
	Return _libvlc_video_set_spu($p, $iTrackId) = 0
EndFunc   ;==>_GUICtrlVLC_SetSubtitleTrack

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_AddSubtitleFile
; Description ...: Loads an external subtitle file (.srt, .ass, .sub ...) for the playing media.
; Syntax ........: _GUICtrlVLC_AddSubtitleFile($iPlayer, $sFile[, $bSelect = True])
; ===============================================================================================================================
Func _GUICtrlVLC_AddSubtitleFile($iPlayer, $sFile, $bSelect = True)
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Then Return SetError($VLC_ERR_PARAM, 0, False)
	If Not _VLC_IsUrl($sFile) And Not FileExists($sFile) Then Return SetError($VLC_ERR_NOTFOUND, 0, False)
	Return _libvlc_media_player_add_slave($p, $libvlc_media_slave_type_subtitle, _VLC_PathToUri($sFile), $bSelect ? True : False) = 0
EndFunc   ;==>_GUICtrlVLC_AddSubtitleFile

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_GetSubtitleDelay / _GUICtrlVLC_SetSubtitleDelay
; Description ...: Subtitle delay in milliseconds.
; ===============================================================================================================================
Func _GUICtrlVLC_GetSubtitleDelay($iPlayer)
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Then Return SetError($VLC_ERR_PARAM, 0, 0)
	Return Round(_libvlc_video_get_spu_delay($p) / 1000)
EndFunc   ;==>_GUICtrlVLC_GetSubtitleDelay

Func _GUICtrlVLC_SetSubtitleDelay($iPlayer, $iMs)
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Then Return SetError($VLC_ERR_PARAM, 0, False)
	Return _libvlc_video_set_spu_delay($p, Int($iMs) * 1000) = 0
EndFunc   ;==>_GUICtrlVLC_SetSubtitleDelay
#EndRegion Subtitles

#Region Chapters and titles

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_GetChapters / _GetChapter / _SetChapter / _NextChapter / _PreviousChapter
; Description ...: Chapters of the current title. GetChapters: 2D array [0][0] = count, [n][0] = start ms,
;                  [n][1] = duration ms, [n][2] = name. Chapter numbers are 0-based.
; ===============================================================================================================================
Func _GUICtrlVLC_GetChapters($iPlayer)
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Then
		Local $aErr[1][3] = [[0, "", ""]]
		Return SetError($VLC_ERR_PARAM, 0, $aErr)
	EndIf
	Return _VLC_PlayerGetChapters($p)
EndFunc   ;==>_GUICtrlVLC_GetChapters

Func _GUICtrlVLC_GetChapter($iPlayer)
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1)
	Return _libvlc_media_player_get_chapter($p)
EndFunc   ;==>_GUICtrlVLC_GetChapter

Func _GUICtrlVLC_SetChapter($iPlayer, $iChapter)
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Then Return SetError($VLC_ERR_PARAM, 0, False)
	Return _libvlc_media_player_set_chapter($p, $iChapter)
EndFunc   ;==>_GUICtrlVLC_SetChapter

Func _GUICtrlVLC_NextChapter($iPlayer)
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Then Return SetError($VLC_ERR_PARAM, 0, False)
	Return _libvlc_media_player_next_chapter($p)
EndFunc   ;==>_GUICtrlVLC_NextChapter

Func _GUICtrlVLC_PreviousChapter($iPlayer)
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Then Return SetError($VLC_ERR_PARAM, 0, False)
	Return _libvlc_media_player_previous_chapter($p)
EndFunc   ;==>_GUICtrlVLC_PreviousChapter

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_GetTitles / _GetTitle / _SetTitle
; Description ...: Titles (DVD, Blu-ray ...). GetTitles: 2D array [0][0] = count, [n][0] = duration ms, [n][1] = name,
;                  [n][2] = flags (1 = menu). Title numbers are 0-based.
; ===============================================================================================================================
Func _GUICtrlVLC_GetTitles($iPlayer)
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Then
		Local $aErr[1][3] = [[0, "", ""]]
		Return SetError($VLC_ERR_PARAM, 0, $aErr)
	EndIf
	Return _VLC_PlayerGetTitles($p)
EndFunc   ;==>_GUICtrlVLC_GetTitles

Func _GUICtrlVLC_GetTitle($iPlayer)
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1)
	Return _libvlc_media_player_get_title($p)
EndFunc   ;==>_GUICtrlVLC_GetTitle

Func _GUICtrlVLC_SetTitle($iPlayer, $iTitle)
	Local $p = __GUICtrlVLC_P($iPlayer)
	If $p = 0 Then Return SetError($VLC_ERR_PARAM, 0, False)
	Return _libvlc_media_player_set_title($p, $iTitle)
EndFunc   ;==>_GUICtrlVLC_SetTitle
#EndRegion Chapters and titles

#Region Media

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_GetMeta
; Description ...: Returns a meta data field of the current media, e.g. $libvlc_meta_Title, $libvlc_meta_NowPlaying
;                  (current song of a web radio).
; Syntax ........: _GUICtrlVLC_GetMeta($iPlayer, $iMeta)
; ===============================================================================================================================
Func _GUICtrlVLC_GetMeta($iPlayer, $iMeta)
	If Not __GUICtrlVLC_Valid($iPlayer) Then Return SetError($VLC_ERR_PARAM, 0, "")
	Local $pMedia = $__g_aVLCC[$iPlayer][$__VLCC_MEDIA]
	If $pMedia = 0 Then Return SetError($VLC_ERR_STATE, 0, "")
	Return _libvlc_media_get_meta($pMedia, $iMeta)
EndFunc   ;==>_GUICtrlVLC_GetMeta

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_GetMRL
; Description ...: Returns the MRL (URI) of the current media.
; ===============================================================================================================================
Func _GUICtrlVLC_GetMRL($iPlayer)
	If Not __GUICtrlVLC_Valid($iPlayer) Then Return SetError($VLC_ERR_PARAM, 0, "")
	Local $pMedia = $__g_aVLCC[$iPlayer][$__VLCC_MEDIA]
	If $pMedia = 0 Then Return SetError($VLC_ERR_STATE, 0, "")
	Return _libvlc_media_get_mrl($pMedia)
EndFunc   ;==>_GUICtrlVLC_GetMRL

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_GetMediaTracks
; Description ...: Returns the elementary streams of the current media (see _VLC_MediaGetTracks).
; ===============================================================================================================================
Func _GUICtrlVLC_GetMediaTracks($iPlayer)
	Local $aErr[1][$VLC_TRACK_COLUMNS]
	$aErr[0][0] = 0
	If Not __GUICtrlVLC_Valid($iPlayer) Then Return SetError($VLC_ERR_PARAM, 0, $aErr)
	Local $pMedia = $__g_aVLCC[$iPlayer][$__VLCC_MEDIA]
	If $pMedia = 0 Then Return SetError($VLC_ERR_STATE, 0, $aErr)
	Return _VLC_MediaGetTracks($pMedia)
EndFunc   ;==>_GUICtrlVLC_GetMediaTracks
#EndRegion Media

#Region Fullscreen

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_SetFullscreen
; Description ...: Shows the video area fullscreen on the monitor it is on, or returns to the normal position.
; Syntax ........: _GUICtrlVLC_SetFullscreen($iPlayer[, $bFullscreen = True])
; Return values .: Success - True; Failure - False, @error set
; Remarks .......: libVLC's own fullscreen does not work with embedded windows, so the control is moved into a
;                  borderless topmost window. Esc leaves fullscreen (unless $VLC_CTRL_NO_ESC_FULLSCREEN).
;                  _GUICtrlVLC_GetFullscreenGUI() returns the window (e.g. to detect its $GUI_EVENT_CLOSE).
; ===============================================================================================================================
Func _GUICtrlVLC_SetFullscreen($iPlayer, $bFullscreen = True)
	If Not __GUICtrlVLC_Valid($iPlayer) Then Return SetError($VLC_ERR_PARAM, 0, False)
	Local $hHost = $__g_aVLCC[$iPlayer][$__VLCC_HOST]
	If $bFullscreen Then
		If $__g_aVLCC[$iPlayer][$__VLCC_FS] Then Return True
		Local $hParent = $__g_aVLCC[$iPlayer][$__VLCC_PARENT]
		; current position of the control inside its parent
		Local $tRect = DllStructCreate("long Left;long Top;long Right;long Bottom")
		DllCall("user32.dll", "bool", "GetWindowRect", "hwnd", $hHost, "struct*", $tRect)
		DllCall("user32.dll", "int", "MapWindowPoints", "hwnd", 0, "hwnd", $hParent, "struct*", $tRect, "uint", 2)
		Local $aRect[4] = [DllStructGetData($tRect, "Left"), DllStructGetData($tRect, "Top"), _
				DllStructGetData($tRect, "Right") - DllStructGetData($tRect, "Left"), _
				DllStructGetData($tRect, "Bottom") - DllStructGetData($tRect, "Top")]
		; monitor of the control
		Local $aMon = DllCall("user32.dll", "handle", "MonitorFromWindow", "hwnd", $hHost, "dword", 2) ; MONITOR_DEFAULTTONEAREST
		Local $tMI = DllStructCreate("dword cbSize;long mLeft;long mTop;long mRight;long mBottom;long wLeft;long wTop;long wRight;long wBottom;dword dwFlags")
		DllStructSetData($tMI, "cbSize", DllStructGetSize($tMI))
		DllCall("user32.dll", "bool", "GetMonitorInfoW", "handle", $aMon[0], "struct*", $tMI)
		Local $iX = DllStructGetData($tMI, "mLeft"), $iY = DllStructGetData($tMI, "mTop")
		Local $iW = DllStructGetData($tMI, "mRight") - $iX, $iH = DllStructGetData($tMI, "mBottom") - $iY
		If $iW <= 0 Or $iH <= 0 Then Return SetError($VLC_ERR_STATE, 0, False)
		Local $aRoot = DllCall("user32.dll", "hwnd", "GetAncestor", "hwnd", $hParent, "uint", 2) ; GA_ROOT
		Local $hCurrent = __VLC_GetCurrentGUI()
		; WS_POPUP | WS_CLIPCHILDREN, WS_EX_TOPMOST, owned by the main window (no taskbar button)
		Local $hFS = GUICreate("", $iW, $iH, $iX, $iY, BitOR(0x80000000, 0x02000000), 0x00000008, $aRoot[0])
		If $hCurrent <> 0 Then GUISwitch($hCurrent)
		If $hFS = 0 Then Return SetError($VLC_ERR_STATE, 0, False)
		GUISetBkColor(0x000000, $hFS)
		DllCall("user32.dll", "hwnd", "SetParent", "hwnd", $hHost, "hwnd", $hFS)
		DllCall("user32.dll", "bool", "MoveWindow", "hwnd", $hHost, "int", 0, "int", 0, "int", $iW, "int", $iH, "bool", True)
		GUISetState(@SW_SHOW, $hFS)
		WinActivate($hFS)
		$__g_aVLCC[$iPlayer][$__VLCC_FS] = True
		$__g_aVLCC[$iPlayer][$__VLCC_FSGUI] = $hFS
		$__g_aVLCC[$iPlayer][$__VLCC_FSRECT] = $aRect
		If Not $__g_bVLCC_FSWatch Then
			AdlibRegister("__GUICtrlVLC_FSWatch", 50)
			$__g_bVLCC_FSWatch = True
		EndIf
		Return True
	EndIf
	If Not $__g_aVLCC[$iPlayer][$__VLCC_FS] Then Return True
	Local $aR = $__g_aVLCC[$iPlayer][$__VLCC_FSRECT]
	DllCall("user32.dll", "hwnd", "SetParent", "hwnd", $hHost, "hwnd", $__g_aVLCC[$iPlayer][$__VLCC_PARENT])
	DllCall("user32.dll", "bool", "MoveWindow", "hwnd", $hHost, "int", $aR[0], "int", $aR[1], "int", $aR[2], "int", $aR[3], "bool", True)
	GUIDelete($__g_aVLCC[$iPlayer][$__VLCC_FSGUI])
	$__g_aVLCC[$iPlayer][$__VLCC_FS] = False
	$__g_aVLCC[$iPlayer][$__VLCC_FSGUI] = 0
	Local $aRoot2 = DllCall("user32.dll", "hwnd", "GetAncestor", "hwnd", $__g_aVLCC[$iPlayer][$__VLCC_PARENT], "uint", 2)
	If Not @error Then WinActivate($aRoot2[0])
	Return True
EndFunc   ;==>_GUICtrlVLC_SetFullscreen

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlVLC_GetFullscreen / _GUICtrlVLC_ToggleFullscreen / _GUICtrlVLC_GetFullscreenGUI
; Description ...: Fullscreen state / toggle / handle of the fullscreen window (0 if not fullscreen).
; ===============================================================================================================================
Func _GUICtrlVLC_GetFullscreen($iPlayer)
	If Not __GUICtrlVLC_Valid($iPlayer) Then Return SetError($VLC_ERR_PARAM, 0, False)
	Return $__g_aVLCC[$iPlayer][$__VLCC_FS]
EndFunc   ;==>_GUICtrlVLC_GetFullscreen

Func _GUICtrlVLC_ToggleFullscreen($iPlayer)
	If Not __GUICtrlVLC_Valid($iPlayer) Then Return SetError($VLC_ERR_PARAM, 0, False)
	Local $bOk = _GUICtrlVLC_SetFullscreen($iPlayer, Not $__g_aVLCC[$iPlayer][$__VLCC_FS])
	Return SetError(@error, 0, $bOk)
EndFunc   ;==>_GUICtrlVLC_ToggleFullscreen

Func _GUICtrlVLC_GetFullscreenGUI($iPlayer)
	If Not __GUICtrlVLC_Valid($iPlayer) Then Return SetError($VLC_ERR_PARAM, 0, 0)
	Return $__g_aVLCC[$iPlayer][$__VLCC_FSGUI]
EndFunc   ;==>_GUICtrlVLC_GetFullscreenGUI
#EndRegion Fullscreen

#Region VLC.au3 v0.3 compatibility

; #FUNCTION# ====================================================================================================================
; Name ..........: _VLCErrorHandlerRegister
; Description ...: Compatibility stub for VLC.au3 v0.3. Not needed any more (no COM/ActiveX); returns 1.
; Syntax ........: _VLCErrorHandlerRegister([$s_functionName = "__VLCInternalErrorHandler"])
; ===============================================================================================================================
Func _VLCErrorHandlerRegister($s_functionName = "__VLCInternalErrorHandler")
	$sVLCUserErrorHandler = $s_functionName
	Return 1
EndFunc   ;==>_VLCErrorHandlerRegister

Func __VLCInternalErrorHandler()
	Return
EndFunc   ;==>__VLCInternalErrorHandler
#EndRegion VLC.au3 v0.3 compatibility

#Region Internal

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __GUICtrlVLC_Valid / __GUICtrlVLC_P
; Description ...: Player id check / player pointer of a valid id (Ptr(0) otherwise).
; ===============================================================================================================================
Func __GUICtrlVLC_Valid($iPlayer)
	If Not IsNumber($iPlayer) Or $iPlayer < 1 Or $iPlayer > $__g_aVLCC[0][0] Then Return False
	Return $__g_aVLCC[$iPlayer][$__VLCC_USED] = True
EndFunc   ;==>__GUICtrlVLC_Valid

Func __GUICtrlVLC_P($iPlayer)
	If Not __GUICtrlVLC_Valid($iPlayer) Then Return Ptr(0)
	; while a timed-out stop is still running, libVLC holds the input lock: calls would freeze the GUI
	If _VLC_PlayerIsBusy($__g_aVLCC[$iPlayer][$__VLCC_PLAYER]) Then Return __VLC_ErrRet(Ptr(0), "player is busy (a stop did not finish yet)")
	Return $__g_aVLCC[$iPlayer][$__VLCC_PLAYER]
EndFunc   ;==>__GUICtrlVLC_P

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __GUICtrlVLC_PlayIndex
; Description ...: Stops the player (worker thread), loads playlist item $iIndex and starts it.
; ===============================================================================================================================
Func __GUICtrlVLC_PlayIndex($iPlayer, $iIndex)
	Local $aList = $__g_aVLCC[$iPlayer][$__VLCC_LIST], $aListOpt = $__g_aVLCC[$iPlayer][$__VLCC_LISTOPT]
	If $iIndex < 0 Or $iIndex >= $aList[0] Then Return SetError($VLC_ERR_PARAM, 0, __VLC_ErrRet(False, "playlist item " & $iIndex & " does not exist"))
	Local $pPlayer = $__g_aVLCC[$iPlayer][$__VLCC_PLAYER]
	If _VLC_PlayerIsBusy($pPlayer) Then Return SetError($VLC_ERR_STATE, 0, __VLC_ErrRet(False, "player is busy (a stop did not finish yet)"))
	Local $pMedia = _VLC_MediaNew($aList[$iIndex + 1], $aListOpt[$iIndex + 1])
	If @error Or $pMedia = 0 Then Return SetError(@error ? @error : $VLC_ERR_LIBVLC, 0, False)
	Local $iState = _libvlc_media_player_get_state($pPlayer)
	If $iState <> $libvlc_NothingSpecial And $iState <> $libvlc_Stopped Then
		; playing, paused, ended or error: change the media on the worker thread. Unlike a full stop this keeps the
		; video output (window, Direct3D device) for the next item - faster, no flicker, nothing to tear down.
		If Not _VLC_PlayerSetMedia($pPlayer, $pMedia) Then
			Local $iErr = @error
			; after a timeout set_media is still running on the worker and takes its reference only after the
			; blocking part: releasing the media now would let libVLC use freed memory, so it is kept (leaked)
			If $iErr <> $VLC_ERR_TIMEOUT Then _libvlc_media_release($pMedia)
			Return SetError($iErr, 0, False)
		EndIf
	Else
		_libvlc_media_player_set_media($pPlayer, $pMedia) ; no input thread: returns at once
	EndIf
	; the player holds its own reference
	If $__g_aVLCC[$iPlayer][$__VLCC_MEDIA] <> 0 Then _libvlc_media_release($__g_aVLCC[$iPlayer][$__VLCC_MEDIA])
	$__g_aVLCC[$iPlayer][$__VLCC_MEDIA] = $pMedia
	$__g_aVLCC[$iPlayer][$__VLCC_CURRENT] = $iIndex
	If _libvlc_media_player_play($pPlayer) <> 0 Then Return SetError($VLC_ERR_LIBVLC, 0, __VLC_LibErrRet(False, "libvlc_media_player_play() failed"))
	Return True
EndFunc   ;==>__GUICtrlVLC_PlayIndex

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __GUICtrlVLC_Subscribe
; Description ...: Attaches the player events used by the control (and by the user callback).
; ===============================================================================================================================
Func __GUICtrlVLC_Subscribe($iPlayer)
	Local $pPlayer = $__g_aVLCC[$iPlayer][$__VLCC_PLAYER]
	Local $pEM = _libvlc_media_player_event_manager($pPlayer)
	If $pEM = 0 Then Return SetError($VLC_ERR_LIBVLC, 0, False)
	Local $aTypes[21] = [$libvlc_MediaPlayerMediaChanged, $libvlc_MediaPlayerOpening, $libvlc_MediaPlayerBuffering, _
			$libvlc_MediaPlayerPlaying, $libvlc_MediaPlayerPaused, $libvlc_MediaPlayerStopped, $libvlc_MediaPlayerEndReached, _
			$libvlc_MediaPlayerEncounteredError, $libvlc_MediaPlayerLengthChanged, $libvlc_MediaPlayerSeekableChanged, _
			$libvlc_MediaPlayerPausableChanged, $libvlc_MediaPlayerVout, $libvlc_MediaPlayerESAdded, $libvlc_MediaPlayerESDeleted, _
			$libvlc_MediaPlayerESSelected, $libvlc_MediaPlayerMuted, $libvlc_MediaPlayerUnmuted, $libvlc_MediaPlayerAudioVolume, _
			$libvlc_MediaPlayerChapterChanged, $libvlc_MediaPlayerTitleChanged, $libvlc_MediaPlayerSnapshotTaken]
	If BitAND($__g_aVLCC[$iPlayer][$__VLCC_FLAGS], $VLC_CTRL_TIME_EVENTS) Then
		ReDim $aTypes[23]
		$aTypes[21] = $libvlc_MediaPlayerTimeChanged
		$aTypes[22] = $libvlc_MediaPlayerPositionChanged
	EndIf
	Local $iSub = _VLC_EventAttach($pEM, $aTypes, "__GUICtrlVLC_OnEvent", $iPlayer, "GUICtrlVLC")
	If $iSub = 0 Then Return SetError(@error, 0, False)
	$__g_aVLCC[$iPlayer][$__VLCC_SUB] = $iSub
	Return True
EndFunc   ;==>__GUICtrlVLC_Subscribe

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __GUICtrlVLC_OnEvent
; Description ...: Internal event handler (AutoIt thread): volume/mute re-apply, playlist advance, user callback.
;                  Volume/mute are applied on Playing and on a new audio track only. They are deliberately NOT
;                  re-applied on AudioVolume/Muted events: audio outputs that cannot report their volume would cause
;                  an endless set/notify loop.
; ===============================================================================================================================
Func __GUICtrlVLC_OnEvent($iSub, $iType, $v1, $v2, $pObj, $iPlayer)
	#forceref $pObj
	If Not __GUICtrlVLC_Valid($iPlayer) Then Return
	If $__g_aVLCC[$iPlayer][$__VLCC_SUB] <> $iSub Then Return
	Local $pPlayer = $__g_aVLCC[$iPlayer][$__VLCC_PLAYER]
	Switch $iType
		Case $libvlc_MediaPlayerPlaying
			__GUICtrlVLC_ApplyAudio($iPlayer)
		Case $libvlc_MediaPlayerESAdded
			If $v1 = $libvlc_track_audio Then __GUICtrlVLC_ApplyAudio($iPlayer)
	EndSwitch
	Local $sFunc = $__g_aVLCC[$iPlayer][$__VLCC_CALLBACK]
	If $sFunc <> "" Then
		Call($sFunc, $iPlayer, $iType, $v1, $v2)
		If @error = 0xDEAD And @extended = 0xBEEF Then $__g_sVLC_LastError = "event callback '" & $sFunc & "' not found or wrong number of parameters (4 required)"
	EndIf
	; playlist advance after the user saw EndReached (the player may have been deleted in the callback)
	If $iType = $libvlc_MediaPlayerEndReached And __GUICtrlVLC_Valid($iPlayer) Then
		If $__g_aVLCC[$iPlayer][$__VLCC_SUB] <> $iSub Then Return
		If _libvlc_media_player_get_state($pPlayer) <> $libvlc_Ended Then Return ; something else was started meanwhile
		Local $iCur = $__g_aVLCC[$iPlayer][$__VLCC_CURRENT], $n = _GUICtrlVLC_GetCount($iPlayer)
		Switch $__g_aVLCC[$iPlayer][$__VLCC_LOOP]
			Case $VLC_LOOP_ONE
				__GUICtrlVLC_PlayIndex($iPlayer, $iCur)
			Case $VLC_LOOP_ALL
				If $n > 0 Then __GUICtrlVLC_PlayIndex($iPlayer, Mod($iCur + 1, $n))
			Case Else
				If $iCur + 1 < $n Then __GUICtrlVLC_PlayIndex($iPlayer, $iCur + 1)
		EndSwitch
	EndIf
EndFunc   ;==>__GUICtrlVLC_OnEvent

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __GUICtrlVLC_ApplyAudio
; Description ...: Applies remembered volume/mute to the (new) audio output.
; ===============================================================================================================================
Func __GUICtrlVLC_ApplyAudio($iPlayer)
	Local $pPlayer = $__g_aVLCC[$iPlayer][$__VLCC_PLAYER]
	If $__g_aVLCC[$iPlayer][$__VLCC_VOLUME] >= 0 Then _libvlc_audio_set_volume($pPlayer, $__g_aVLCC[$iPlayer][$__VLCC_VOLUME])
	If $__g_aVLCC[$iPlayer][$__VLCC_MUTE] >= 0 Then _libvlc_audio_set_mute($pPlayer, $__g_aVLCC[$iPlayer][$__VLCC_MUTE])
EndFunc   ;==>__GUICtrlVLC_ApplyAudio

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __GUICtrlVLC_AddStyle
; Description ...: Adds window style bits.
; ===============================================================================================================================
Func __GUICtrlVLC_AddStyle($hWnd, $iStyle)
	Local $aStyle = DllCall("user32.dll", "long", "GetWindowLongW", "hwnd", $hWnd, "int", -16)
	If @error Then Return
	If BitAND($aStyle[0], $iStyle) = $iStyle Then Return
	DllCall("user32.dll", "long", "SetWindowLongW", "hwnd", $hWnd, "int", -16, "long", BitOR($aStyle[0], $iStyle))
EndFunc   ;==>__GUICtrlVLC_AddStyle

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __GUICtrlVLC_FSWatch
; Description ...: Adlib: Esc leaves fullscreen; unregisters itself when no player is fullscreen.
; ===============================================================================================================================
Func __GUICtrlVLC_FSWatch()
	Local $bAny = False
	For $i = 1 To $__g_aVLCC[0][0]
		If Not $__g_aVLCC[$i][$__VLCC_USED] Or Not $__g_aVLCC[$i][$__VLCC_FS] Then ContinueLoop
		$bAny = True
		If BitAND($__g_aVLCC[$i][$__VLCC_FLAGS], $VLC_CTRL_NO_ESC_FULLSCREEN) Then ContinueLoop
		If Not WinActive($__g_aVLCC[$i][$__VLCC_FSGUI]) Then ContinueLoop
		Local $aKey = DllCall("user32.dll", "short", "GetAsyncKeyState", "int", 0x1B)
		If Not @error And BitAND($aKey[0], 0x8000) Then _GUICtrlVLC_SetFullscreen($i, False)
	Next
	If Not $bAny Then
		AdlibUnRegister("__GUICtrlVLC_FSWatch")
		$__g_bVLCC_FSWatch = False
	EndIf
EndFunc   ;==>__GUICtrlVLC_FSWatch

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __GUICtrlVLC_DeleteAll
; Description ...: Shutdown hook of CCLibVLC: deletes all players.
; ===============================================================================================================================
Func __GUICtrlVLC_DeleteAll()
	For $i = 1 To $__g_aVLCC[0][0]
		If $__g_aVLCC[$i][$__VLCC_USED] Then _GUICtrlVLC_Delete($i)
	Next
EndFunc   ;==>__GUICtrlVLC_DeleteAll
#EndRegion Internal
