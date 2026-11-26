#include-once
; SPDX-License-Identifier: GPL-3.0-or-later
; #INDEX# =======================================================================================================================
; Title .........: CCLibVLC
; AutoIt Version : 3.3.14.5+ (tested with 3.3.18.0, x86 and x64)
; Language ......: English
; Description ...: Core of the CCLibVLC UDF: loading libVLC 3.0, string/struct helpers, thread-safe libVLC events and
;                  deadlock-free stop/release on a worker thread. Includes the generated raw layer (_libvlc_*) and all
;                  libVLC constants. For an embedded video player control see CCGUICtrlVLC.au3.
; Author(s) .....: Markus Debus, CITRO Computer
; Copyright .....: Copyright (C) 2026 Markus Debus, CITRO Computer. GPL-3.0-or-later with an additional attribution term
;                  according to GPLv3 section 7(b), see LICENSE and NOTICE.
; Requirements ..: libVLC 3.0.x (libvlc.dll, libvlccore.dll, plugins\) with the same bitness as AutoIt.
;                  Recommended: VLC 3.0.24 or newer (security fixes).
; Remarks .......: Conventions used throughout the UDF:
;                  - Error codes: see $VLC_ERR_* below. libVLC's own error text: _VLC_GetLastError().
;                  - Arrays returned by helper functions hold the number of rows in [0] / [0][0].
;                  - Times are milliseconds unless stated otherwise.
;                  Threading: libVLC calls event callbacks on its own threads. AutoIt code must never run there.
;                  CCLibVLC therefore attaches a small native thunk which only copies the event and posts it to a
;                  hidden AutoIt window. Events are delivered to your AutoIt callback on the AutoIt thread.
; ===============================================================================================================================

#Region Constants and globals
; #CONSTANTS# ===================================================================================================================
Global Const $CCLIBVLC_VERSION = "1.0.2"

; error codes (@error)
Global Const $VLC_ERR_OK = 0
Global Const $VLC_ERR_NOT_STARTED = 1 ; _VLC_Startup() has not been called or failed
Global Const $VLC_ERR_DLLCALL = 2     ; DllCall() failed, @extended = DllCall() @error
Global Const $VLC_ERR_LIBVLC = 3      ; libVLC reported an error, see _VLC_GetLastError()
Global Const $VLC_ERR_PARAM = 4       ; invalid parameter
Global Const $VLC_ERR_NOTFOUND = 5    ; file, directory or object not found
Global Const $VLC_ERR_VERSION = 6     ; unsupported libVLC version (only 3.x is supported)
Global Const $VLC_ERR_ARCH = 7        ; libvlc.dll bitness does not match AutoIt (x86/x64)
Global Const $VLC_ERR_MEMORY = 8      ; memory allocation failed
Global Const $VLC_ERR_TIMEOUT = 9     ; operation timed out
Global Const $VLC_ERR_NATIVE = 10     ; native helper (thunk/thread/window) could not be created
Global Const $VLC_ERR_STATE = 11      ; operation not possible in the current state

; window message used by the event bridge (WM_APP range), sent to CCLibVLC's own message-only window
Global Const $VLC_WM_EVENT = 0x8000 + 0x1A57

; default timeout for stop/release on the worker thread (ms)
Global Const $VLC_DEFAULT_TIMEOUT = 10000

; struct tags of libVLC 3.0 structures
Global Const $tagLIBVLC_TRACK_DESCRIPTION = "int i_id;ptr psz_name;ptr p_next"
Global Const $tagLIBVLC_TITLE_DESCRIPTION = "int64 i_duration;ptr psz_name;uint i_flags"
Global Const $tagLIBVLC_CHAPTER_DESCRIPTION = "int64 i_time_offset;int64 i_duration;ptr psz_name"
Global Const $tagLIBVLC_AUDIO_OUTPUT = "ptr psz_name;ptr psz_description;ptr p_next"
Global Const $tagLIBVLC_AUDIO_OUTPUT_DEVICE = "ptr p_next;ptr psz_device;ptr psz_description"
Global Const $tagLIBVLC_MODULE_DESCRIPTION = "ptr psz_name;ptr psz_shortname;ptr psz_longname;ptr psz_help;ptr p_next"
Global Const $tagLIBVLC_MEDIA_STATS = "int i_read_bytes;float f_input_bitrate;int i_demux_read_bytes;float f_demux_bitrate;" & _
		"int i_demux_corrupted;int i_demux_discontinuity;int i_decoded_video;int i_decoded_audio;int i_displayed_pictures;" & _
		"int i_lost_pictures;int i_played_abuffers;int i_lost_abuffers;int i_sent_packets;int i_sent_bytes;float f_send_bitrate"
Global Const $tagLIBVLC_MEDIA_TRACK = "uint i_codec;uint i_original_fourcc;int i_id;int i_type;int i_profile;int i_level;" & _
		"ptr p_track;uint i_bitrate;ptr psz_language;ptr psz_description"
Global Const $tagLIBVLC_AUDIO_TRACK = "uint i_channels;uint i_rate"
Global Const $tagLIBVLC_VIDEO_TRACK = "uint i_height;uint i_width;uint i_sar_num;uint i_sar_den;uint i_frame_rate_num;" & _
		"uint i_frame_rate_den;int i_orientation;int i_projection;float f_yaw;float f_pitch;float f_roll;float f_field_of_view"
Global Const $tagLIBVLC_SUBTITLE_TRACK = "ptr psz_encoding"
Global Const $tagLIBVLC_MEDIA_SLAVE = "ptr psz_uri;int i_type;uint i_priority"
Global Const $tagLIBVLC_MEDIA_DISCOVERER_DESCRIPTION = "ptr psz_name;ptr psz_longname;int i_cat"
Global Const $tagLIBVLC_RD_DESCRIPTION = "ptr psz_name;ptr psz_longname"
Global Const $tagLIBVLC_VIDEO_VIEWPOINT = "float f_yaw;float f_pitch;float f_roll;float f_field_of_view"

; column indices of _VLC_MediaGetTracks()
Global Const $VLC_TRACK_TYPE = 0, $VLC_TRACK_ID = 1, $VLC_TRACK_CODEC = 2, $VLC_TRACK_FOURCC = 3, $VLC_TRACK_PROFILE = 4, _
		$VLC_TRACK_LEVEL = 5, $VLC_TRACK_BITRATE = 6, $VLC_TRACK_LANGUAGE = 7, $VLC_TRACK_DESCRIPTION = 8, _
		$VLC_TRACK_CHANNELS = 9, $VLC_TRACK_RATE = 10, $VLC_TRACK_WIDTH = 11, $VLC_TRACK_HEIGHT = 12, $VLC_TRACK_SAR_NUM = 13, _
		$VLC_TRACK_SAR_DEN = 14, $VLC_TRACK_FPS_NUM = 15, $VLC_TRACK_FPS_DEN = 16, $VLC_TRACK_ORIENTATION = 17, _
		$VLC_TRACK_PROJECTION = 18, $VLC_TRACK_ENCODING = 19, $VLC_TRACK_COLUMNS = 20

; indices of _VLC_MediaGetStats()
Global Const $VLC_STAT_READ_BYTES = 1, $VLC_STAT_INPUT_BITRATE = 2, $VLC_STAT_DEMUX_READ_BYTES = 3, $VLC_STAT_DEMUX_BITRATE = 4, _
		$VLC_STAT_DEMUX_CORRUPTED = 5, $VLC_STAT_DEMUX_DISCONTINUITY = 6, $VLC_STAT_DECODED_VIDEO = 7, $VLC_STAT_DECODED_AUDIO = 8, _
		$VLC_STAT_DISPLAYED_PICTURES = 9, $VLC_STAT_LOST_PICTURES = 10, $VLC_STAT_PLAYED_ABUFFERS = 11, $VLC_STAT_LOST_ABUFFERS = 12, _
		$VLC_STAT_SENT_PACKETS = 13, $VLC_STAT_SENT_BYTES = 14, $VLC_STAT_SEND_BITRATE = 15
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
Global $__g_hVLC_Dll = -1                 ; DllOpen() handle of libvlc.dll
Global $__g_hVLC_Module = 0               ; HMODULE of libvlc.dll (GetProcAddress)
Global $__g_pVLC_Instance = Ptr(0)        ; libvlc_instance_t *
Global $__g_sVLC_Dir = ""                 ; directory of libvlc.dll
Global $__g_sVLC_Version = ""             ; libvlc_get_version()
Global $__g_sVLC_LastError = ""           ; last error text
Global $__g_bVLC_ExitRegistered = False
Global $__g_aVLC_Options[1] = [0]         ; options used for libvlc_new

; native helpers
Global $__g_pVLC_Code = 0                 ; executable page with the thunks
Global $__g_pVLC_HeapAlloc = 0, $__g_pVLC_HeapFree = 0, $__g_pVLC_PostMessage = 0, $__g_hVLC_Heap = 0
Global $__g_hVLC_EventWnd = 0             ; message-only window receiving $VLC_WM_EVENT
Global $__g_hVLC_WndProc = 0              ; DllCallbackRegister handle of its window procedure (never freed)
Global $__g_pVLC_OldWndProc = 0
Global $__g_aVLC_KeepAlive[1] = [0]       ; structs that must never be freed (worker contexts after a timeout)
Global $__g_aVLC_Busy[1][2] = [[0]]       ; worker threads that exceeded their timeout: [n][0] = object, [n][1] = thread handle

; event subscriptions: [0][0] = number of slots
; columns: 0 active, 1 pEventManager, 2 types (0-based array), 3 ctx struct, 4 callback, 5 user data, 6 owner tag,
;          7 subscription id (unique, never reused, also the cookie posted by the thunk)
Global $__g_aVLC_Subs[1][8] = [[0]]
Global $__g_iVLC_NextSubId = 0
; Event delivery runs in two stages, because the window procedure that receives the events from the native thunk can
; interrupt running script code between any two statements (verified): a shared array changed by both sides would lose
; or duplicate events.
;   1. Inbox (ring buffer): written only by __VLC_WM_EVENT (window procedure), read only by __VLC_InboxDrain (script
;      code). The writer publishes an entry by advancing $__g_iVLC_InboxTail as its last statement, the reader frees it
;      by advancing $__g_iVLC_InboxHead. Each index has exactly one writer, so no lock is needed. The window procedure
;      is never re-entered (verified), so there is only one writer at a time.
;   2. Queue: used only by script code (drain, pump, polling, detach). Script code that changes it sets
;      $__g_bVLC_InPump, so the Adlib pump cannot interrupt it in the middle of a change.
; inbox: columns 0 subscription id, 1 type, 2 value1, 3 value2, 4 pObj
Global Const $__VLC_INBOX_SIZE = 4096
Global $__g_aVLC_Inbox[$__VLC_INBOX_SIZE][5]
Global $__g_iVLC_InboxTail = 0            ; number of entries ever written (window procedure only)
Global $__g_iVLC_InboxHead = 0            ; number of entries ever taken (script code only)
Global $__g_iVLC_InboxDropped = 0         ; events dropped because the inbox was full (window procedure only)
; event queue: [0][0] = count; columns: 0 subscription id, 1 type, 2 value1, 3 value2, 4 pObj
Global $__g_aVLC_Queue[1][5] = [[0]]
Global Const $__VLC_QUEUE_MAX = 5000
Global $__g_bVLC_InPump = False           ; queue is being changed by script code / pump is running
; DLL handles for calls in frequently used paths (window procedures, wait loops). DllCall with a file name loads and
; frees the DLL on every call, which takes the process-wide loader lock each time; while libVLC loads plugins (possibly
; from a slow network share) that can stall the GUI thread.
Global $__g_hVLC_K32 = DllOpen("kernel32.dll")
Global $__g_hVLC_U32 = DllOpen("user32.dll")
Global $__g_bVLC_PumpRegistered = False
Global $__g_sVLC_ShutdownHook = ""        ; called by _VLC_Shutdown() before the instance is released (GUI layer)

; native code (see tools/thunks_*.asm, verified by tools/emu_test.py)
Global Const $__g_bVLC_ThunkX64 = Binary("0x5356574883EC204889CE4889D34885DB74584885F67453488B4B1831D24C8B4338FF134885C074424889C7488B0E48890F488B4E0848894F08488B4E1048894F10488B4E1848894F18488B4B208B53284989F84C8B4B30FF531085C0750C488B4B1831D24989F8FF53084883C4205F5E5BC3CCCCCCCCCCCCCCCCCCCCCCCCCCCC4883EC284889C8488B4808488B5010FF1031C04883C428C3CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC")
Global Const $__g_bVLC_ThunkX86 = Binary("0x5356578B7424108B5C241485DB744485F67440FF731C6A00FF730CFF1385C0743289C78B0E890F8B4E04894F048B4E08894F088B4E0C894F0CFF731857FF7314FF7310FF530885C07509576A00FF730CFF53045F5E5BC3CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC8B442404FF7008FF7004FF1083C40831C0C20400CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC")
Global Const $__VLC_THUNK_EVENT = 0x00, $__VLC_THUNK_WORKER = 0x80
; ===============================================================================================================================
#EndRegion Constants and globals

#include "CCLibVLC_Constants.au3"
#include "CCLibVLC_Raw.au3"

; #CURRENT# =====================================================================================================================
; _VLC_Startup
; _VLC_Shutdown
; _VLC_IsStarted
; _VLC_GetInstance
; _VLC_GetDir
; _VLC_GetVersion
; _VLC_GetLastError
; _VLC_GetDefaultOptions
; _libvlc_new
; _VLC_MediaNew
; _VLC_MediaParse
; _VLC_MediaGetMetaAll
; _VLC_MediaGetTracks
; _VLC_MediaGetStats
; _VLC_MediaGetSlaves
; _VLC_TrackDescriptionToArray
; _VLC_PlayerGetAudioTracks
; _VLC_PlayerGetVideoTracks
; _VLC_PlayerGetSubtitleTracks
; _VLC_PlayerGetTitles
; _VLC_PlayerGetChapters
; _VLC_PlayerStop
; _VLC_PlayerSetMedia
; _VLC_PlayerRelease
; _VLC_PlayerIsBusy
; _VLC_AudioOutputList
; _VLC_AudioOutputDeviceList
; _VLC_FilterList
; _VLC_EqualizerGetPresets
; _VLC_EqualizerGetBands
; _VLC_MediaDiscovererList
; _VLC_RendererDiscovererList
; _VLC_EventAttach
; _VLC_EventDetach
; _VLC_EventDetachAll
; _VLC_EventGetNext
; _VLC_EventsProcess
; _VLC_EventTypeName
; _VLC_IsUrl
; _VLC_PathToUri
; _VLC_FormatTime
; _VLC_FourCCToString
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
; __VLC_Ptr, __VLC_Utf8Struct, __VLC_Utf8Array, __VLC_Utf8ArrayPtr, __VLC_StrFromPtr, __VLC_ErrRet, __VLC_LibErrRet,
; __VLC_FindDir, __VLC_CheckDir, __VLC_GetPEMachine, __VLC_OptionsToArray, __VLC_NativeInit, __VLC_GetCurrentGUI, __VLC_WndProc,
; __VLC_RunOnWorker, __VLC_WM_EVENT, __VLC_InboxAdd, __VLC_InboxDrain, __VLC_EventPump, __VLC_EventDecode, __VLC_QueueAdd,
; __VLC_OnExit, __VLC_FullPath
; ===============================================================================================================================

#Region Startup / shutdown

; #FUNCTION# ====================================================================================================================
; Name ..........: _VLC_Startup
; Description ...: Loads libVLC 3.0 and creates the libVLC instance used by all other functions.
; Syntax ........: _VLC_Startup([$sVlcDir = Default[, $vOptions = Default[, $bDefaultOptions = True]]])
; Parameters ....: $sVlcDir             - [optional] directory containing libvlc.dll, libvlccore.dll and plugins\.
;                                         Default searches (first match with the right bitness wins):
;                                         @ScriptDir\vlc_x64 or \vlc_x86, @ScriptDir\vlc, @ScriptDir, the installed
;                                         VLC (registry HKLM\SOFTWARE\VideoLAN\VLC), @ProgramFilesDir\VideoLAN\VLC.
;                  $vOptions            - [optional] additional libVLC options: 0-based array of strings or a string
;                                         with options separated by "|", e.g. "--network-caching=1000|--no-audio".
;                  $bDefaultOptions     - [optional] True (default) prepends _VLC_GetDefaultOptions().
; Return values .: Success - True (@extended = 1 if libVLC was already started)
;                  Failure - False, @error:
;                  |$VLC_ERR_NOTFOUND - no libvlc.dll found
;                  |$VLC_ERR_ARCH     - only a libvlc.dll with the wrong bitness was found
;                  |$VLC_ERR_DLLCALL  - libvlc.dll could not be loaded (missing libvlccore.dll?)
;                  |$VLC_ERR_VERSION  - libVLC is not version 3.x
;                  |$VLC_ERR_LIBVLC   - libvlc_new() failed (invalid option?)
;                  |$VLC_ERR_NATIVE   - native event helper could not be created
;                  Details: _VLC_GetLastError()
; Author ........: Markus Debus, CITRO Computer
; Remarks .......: libvlc.dll stays loaded until the script ends, even after _VLC_Shutdown(). This is intentional:
;                  unloading libVLC while plugins are still mapped is unsafe. _VLC_Shutdown() is called automatically
;                  when the script exits.
;                  Logging: add "--file-logging|--logfile=C:\path\vlc.log|--log-verbose=2" to $vOptions.
; Related .......: _VLC_Shutdown, _VLC_GetDefaultOptions
; ===============================================================================================================================
Func _VLC_Startup($sVlcDir = Default, $vOptions = Default, $bDefaultOptions = True)
	If $__g_pVLC_Instance <> 0 Then Return SetExtended(1, True)
	$__g_sVLC_LastError = ""

	If $__g_hVLC_Dll = -1 Then
		Local $sDir = __VLC_FindDir($sVlcDir)
		If @error Then Return SetError(@error, 0, False)

		; libvlc.dll links libvlccore.dll: let the loader search the VLC directory while loading.
		Local $aOld = DllCall("kernel32.dll", "dword", "GetDllDirectoryW", "dword", 32767, "wstr", "")
		Local $sOldDllDir = (@error Or $aOld[0] = 0) ? "" : $aOld[2]
		DllCall("kernel32.dll", "bool", "SetDllDirectoryW", "wstr", $sDir)
		; a VLC_PLUGIN_PATH pointing to another VLC version would load incompatible plugins (crash)
		Local $sEnvPlug = EnvGet("VLC_PLUGIN_PATH")
		If $sEnvPlug <> "" And StringRegExpReplace($sEnvPlug, "\\+$", "") <> $sDir & "\plugins" Then EnvSet("VLC_PLUGIN_PATH")
		Local $hDll = DllOpen($sDir & "\libvlc.dll")
		If $sOldDllDir = "" Then
			DllCall("kernel32.dll", "bool", "SetDllDirectoryW", "ptr", 0)
		Else
			DllCall("kernel32.dll", "bool", "SetDllDirectoryW", "wstr", $sOldDllDir)
		EndIf
		If $hDll = -1 Then Return SetError($VLC_ERR_DLLCALL, 0, __VLC_ErrRet(False, _
				"libvlc.dll could not be loaded from '" & $sDir & "' (libvlccore.dll missing or damaged?)"))
		$__g_hVLC_Dll = $hDll
		$__g_sVLC_Dir = $sDir
		Local $aMod = DllCall("kernel32.dll", "handle", "GetModuleHandleW", "wstr", $sDir & "\libvlc.dll")
		If Not @error Then $__g_hVLC_Module = $aMod[0]

		$__g_sVLC_Version = _libvlc_get_version()
		If Not StringRegExp($__g_sVLC_Version, "^3\.") Then
			Local $sVer = $__g_sVLC_Version
			DllClose($__g_hVLC_Dll)
			$__g_hVLC_Dll = -1
			$__g_sVLC_Dir = ""
			$__g_sVLC_Version = ""
			Return SetError($VLC_ERR_VERSION, 0, __VLC_ErrRet(False, "unsupported libVLC version '" & $sVer & "', 3.x required"))
		EndIf
	EndIf

	If Not __VLC_NativeInit() Then Return SetError($VLC_ERR_NATIVE, 0, False)

	Local $aOpt = __VLC_OptionsToArray($vOptions)
	If $bDefaultOptions Then
		Local $aDef = _VLC_GetDefaultOptions()
		Local $iDef = UBound($aDef), $iOpt = UBound($aOpt)
		Local $aAll[$iDef + $iOpt]
		For $i = 0 To $iDef - 1
			$aAll[$i] = $aDef[$i]
		Next
		For $i = 0 To $iOpt - 1
			$aAll[$iDef + $i] = $aOpt[$i]
		Next
		$aOpt = $aAll
	EndIf
	; note: libvlc_errmsg()/libvlc_clearerr() must not be called while no instance exists (uninitialised TLS)
	Local $pInst = _libvlc_new($aOpt)
	If @error Or $pInst = 0 Then Return SetError($VLC_ERR_LIBVLC, 0, __VLC_ErrRet(False, "libvlc_new() failed (invalid option or " & _
			"damaged plugins directory?). Options: " & __VLC_JoinOptions($aOpt)))
	$__g_pVLC_Instance = $pInst
	$__g_aVLC_Options = $aOpt

	If Not $__g_bVLC_ExitRegistered Then
		OnAutoItExitRegister("__VLC_OnExit")
		$__g_bVLC_ExitRegistered = True
	EndIf
	Return True
EndFunc   ;==>_VLC_Startup

; #FUNCTION# ====================================================================================================================
; Name ..........: _VLC_Shutdown
; Description ...: Detaches all events, releases the libVLC instance and stops the event pump.
; Syntax ........: _VLC_Shutdown([$iTimeout = $VLC_DEFAULT_TIMEOUT])
; Parameters ....: $iTimeout            - [optional] max. time in ms to wait for libVLC to terminate.
; Return values .: Success - True
;                  Failure - False, @error = $VLC_ERR_TIMEOUT (libVLC did not terminate in time; the instance is
;                            abandoned and memory is kept so that late libVLC threads cannot crash the process)
; Author ........: Markus Debus, CITRO Computer
; Remarks .......: Release all players and media objects you created with the raw layer before calling this function.
;                  Players created with CCGUICtrlVLC.au3 are deleted automatically.
; ===============================================================================================================================
Func _VLC_Shutdown($iTimeout = $VLC_DEFAULT_TIMEOUT)
	If $__g_pVLC_Instance = 0 Then Return True
	If $__g_sVLC_ShutdownHook <> "" Then Call($__g_sVLC_ShutdownHook)
	_VLC_EventDetachAll()
	Local $pInst = $__g_pVLC_Instance
	$__g_pVLC_Instance = Ptr(0)
	Local $bOk = __VLC_RunOnWorker("libvlc_release", $pInst, $iTimeout)
	Local $iErr = @error
	; deliver/free events that are still queued as window messages
	Sleep(10)
	$__g_iVLC_InboxHead = $__g_iVLC_InboxTail
	$__g_aVLC_Queue[0][0] = 0
	If $__g_bVLC_PumpRegistered Then
		AdlibUnRegister("__VLC_EventPump")
		$__g_bVLC_PumpRegistered = False
	EndIf
	If Not $bOk Then Return SetError($iErr, 0, __VLC_ErrRet(False, "libvlc_release() did not return within " & $iTimeout & " ms"))
	Return True
EndFunc   ;==>_VLC_Shutdown

; #FUNCTION# ====================================================================================================================
; Name ..........: _VLC_IsStarted
; Description ...: Returns True if a libVLC instance exists.
; Syntax ........: _VLC_IsStarted()
; Return values .: True or False
; ===============================================================================================================================
Func _VLC_IsStarted()
	Return $__g_pVLC_Instance <> 0
EndFunc   ;==>_VLC_IsStarted

; #FUNCTION# ====================================================================================================================
; Name ..........: _VLC_GetInstance
; Description ...: Returns the libvlc_instance_t pointer (for the raw layer).
; Syntax ........: _VLC_GetInstance()
; Return values .: Success - pointer
;                  Failure - Ptr(0), @error = $VLC_ERR_NOT_STARTED
; ===============================================================================================================================
Func _VLC_GetInstance()
	If $__g_pVLC_Instance = 0 Then Return SetError($VLC_ERR_NOT_STARTED, 0, Ptr(0))
	Return $__g_pVLC_Instance
EndFunc   ;==>_VLC_GetInstance

; #FUNCTION# ====================================================================================================================
; Name ..........: _VLC_GetDir
; Description ...: Returns the directory libvlc.dll was loaded from ("" if not loaded).
; Syntax ........: _VLC_GetDir()
; ===============================================================================================================================
Func _VLC_GetDir()
	Return $__g_sVLC_Dir
EndFunc   ;==>_VLC_GetDir

; #FUNCTION# ====================================================================================================================
; Name ..........: _VLC_GetVersion
; Description ...: Returns the libVLC version string, e.g. "3.0.24 Vetinari" ("" if not loaded).
; Syntax ........: _VLC_GetVersion()
; ===============================================================================================================================
Func _VLC_GetVersion()
	Return $__g_sVLC_Version
EndFunc   ;==>_VLC_GetVersion

; #FUNCTION# ====================================================================================================================
; Name ..........: _VLC_GetLastError
; Description ...: Returns the last error text of CCLibVLC, or libVLC's own error message (libvlc_errmsg) if newer.
; Syntax ........: _VLC_GetLastError()
; Return values .: String ("" if no error is known)
; ===============================================================================================================================
Func _VLC_GetLastError()
	If $__g_pVLC_Instance <> 0 Then
		Local $sLib = _libvlc_errmsg()
		If $sLib <> "" And $__g_sVLC_LastError = "" Then Return "libVLC: " & $sLib
	EndIf
	Return $__g_sVLC_LastError
EndFunc   ;==>_VLC_GetLastError

; #FUNCTION# ====================================================================================================================
; Name ..........: _VLC_GetDefaultOptions
; Description ...: Returns the libVLC options CCLibVLC uses by default.
; Syntax ........: _VLC_GetDefaultOptions()
; Return values .: 0-based array of strings:
;                  --ignore-config        do not read/write the vlcrc of an installed VLC (reproducible behaviour)
;                  --no-video-title-show  do not overlay the file name when playback starts
;                  --no-snapshot-preview  do not show a thumbnail after a snapshot
;                  --no-stats             no statistics collection overhead (use False for _VLC_MediaGetStats)
;                  --quiet                no console messages
; Remarks .......: Pass $bDefaultOptions = False to _VLC_Startup() to use only your own options.
; ===============================================================================================================================
Func _VLC_GetDefaultOptions()
	Local $aDef[5] = ["--ignore-config", "--no-video-title-show", "--no-snapshot-preview", "--no-stats", "--quiet"]
	Return $aDef
EndFunc   ;==>_VLC_GetDefaultOptions

; #FUNCTION# ====================================================================================================================
; Name ..........: _libvlc_new
; Description ...: Create and initialize a libvlc instance (handwritten wrapper with a real argv array).
; Syntax ........: _libvlc_new([$vArgs = Default])
; Parameters ....: $vArgs               - [optional] 0-based array of option strings or a "|" separated string.
; Return values .: Success - libvlc_instance_t * (release with _libvlc_release)
;                  Failure - Ptr(0), @error = $VLC_ERR_DLLCALL (@extended = DllCall @error) or $VLC_ERR_LIBVLC
; Remarks .......: Normally you call _VLC_Startup() instead. Strings are passed as UTF-8.
; ===============================================================================================================================
Func _libvlc_new($vArgs = Default)
	Local $aArgs = __VLC_OptionsToArray($vArgs)
	Local $aKeep = __VLC_Utf8Array($aArgs)
	Local $iCount = UBound($aArgs)
	Local $aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_new", "int", $iCount, "ptr", __VLC_Utf8ArrayPtr($aKeep))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, Ptr(0))
	If $aCall[0] = 0 Then Return SetError($VLC_ERR_LIBVLC, 0, Ptr(0))
	Return $aCall[0]
EndFunc   ;==>_libvlc_new
#EndRegion Startup / shutdown

#Region Media helpers

; #FUNCTION# ====================================================================================================================
; Name ..........: _VLC_MediaNew
; Description ...: Creates a libvlc_media_t from a local path or an URL/MRL and adds media options.
; Syntax ........: _VLC_MediaNew($sMRL[, $vOptions = Default])
; Parameters ....: $sMRL                - local file (absolute or relative) or URL/MRL such as "rtsp://cam/stream",
;                                         "https://...", "dshow://", "screen://", "file:///C:/video.mp4".
;                  $vOptions            - [optional] media options, array or "|" separated, e.g. ":start-time=10".
;                                         They are added as trusted options (libvlc_media_option_trusted).
; Return values .: Success - libvlc_media_t * (release with _libvlc_media_release)
;                  Failure - Ptr(0), @error = $VLC_ERR_NOT_STARTED, $VLC_ERR_NOTFOUND (local file missing) or
;                            $VLC_ERR_LIBVLC
; Remarks .......: Paths with non-ASCII characters (umlauts etc.) are supported (UTF-8).
; ===============================================================================================================================
Func _VLC_MediaNew($sMRL, $vOptions = Default)
	If $__g_pVLC_Instance = 0 Then Return SetError($VLC_ERR_NOT_STARTED, 0, __VLC_ErrRet(Ptr(0), "libVLC not started"))
	$sMRL = String($sMRL)
	If $sMRL = "" Then Return SetError($VLC_ERR_PARAM, 0, __VLC_ErrRet(Ptr(0), "empty media location"))
	Local $pMedia
	If _VLC_IsUrl($sMRL) Then
		$pMedia = _libvlc_media_new_location($__g_pVLC_Instance, $sMRL)
	Else
		Local $sPath = __VLC_FullPath($sMRL)
		If Not FileExists($sPath) Then Return SetError($VLC_ERR_NOTFOUND, 0, __VLC_ErrRet(Ptr(0), "file not found: " & $sPath))
		$pMedia = _libvlc_media_new_path($__g_pVLC_Instance, $sPath)
	EndIf
	If @error Or $pMedia = 0 Then Return SetError($VLC_ERR_LIBVLC, 0, __VLC_LibErrRet(Ptr(0), "cannot create media for '" & $sMRL & "'"))
	Local $aOpt = __VLC_OptionsToArray($vOptions)
	For $i = 0 To UBound($aOpt) - 1
		; options passed by the script are trusted: without the flag libVLC silently ignores every option that is
		; not marked "safe" (e.g. :vout, :avcodec-hw, :sout)
		If $aOpt[$i] <> "" Then _libvlc_media_add_option_flag($pMedia, $aOpt[$i], $libvlc_media_option_trusted)
	Next
	Return $pMedia
EndFunc   ;==>_VLC_MediaNew

; #FUNCTION# ====================================================================================================================
; Name ..........: _VLC_MediaParse
; Description ...: Parses a media (meta data, tracks, duration) and waits until parsing has finished.
; Syntax ........: _VLC_MediaParse($pMedia[, $iFlags = $libvlc_media_parse_local[, $iTimeout = 5000]])
; Parameters ....: $pMedia              - libvlc_media_t *
;                  $iFlags              - [optional] libvlc_media_parse_flag_t combination
;                  $iTimeout            - [optional] timeout in ms (passed to libVLC and used for waiting)
; Return values .: Success - libvlc_media_parsed_status_t ($libvlc_media_parsed_status_done etc.)
;                  Failure - 0, @error = $VLC_ERR_LIBVLC (could not start) or $VLC_ERR_TIMEOUT
; Remarks .......: Waiting uses Sleep(), the GUI stays responsive.
; ===============================================================================================================================
Func _VLC_MediaParse($pMedia, $iFlags = $libvlc_media_parse_local, $iTimeout = 5000)
	If $pMedia = 0 Then Return SetError($VLC_ERR_PARAM, 0, 0)
	If _libvlc_media_parse_with_options($pMedia, $iFlags, $iTimeout) <> 0 Then Return SetError($VLC_ERR_LIBVLC, 0, __VLC_LibErrRet(0, "libvlc_media_parse_with_options() failed"))
	Local $hTimer = TimerInit(), $iStatus = 0
	While 1
		$iStatus = _libvlc_media_get_parsed_status($pMedia)
		If $iStatus > 0 Then Return $iStatus
		If TimerDiff($hTimer) > $iTimeout + 1000 Then ExitLoop
		Sleep(10)
	WEnd
	_libvlc_media_parse_stop($pMedia)
	Return SetError($VLC_ERR_TIMEOUT, 0, __VLC_ErrRet(0, "media parsing timed out"))
EndFunc   ;==>_VLC_MediaParse

; #FUNCTION# ====================================================================================================================
; Name ..........: _VLC_MediaGetMetaAll
; Description ...: Returns all 26 meta data fields of a media.
; Syntax ........: _VLC_MediaGetMetaAll($pMedia)
; Parameters ....: $pMedia              - libvlc_media_t *
; Return values .: Success - 2D array [0][0] = 26, [n][0] = field name ("Title", "Artist", ...), [n][1] = value,
;                            [n][2] = libvlc_meta_t constant
;                  Failure - empty result with [0][0] = 0, @error = $VLC_ERR_PARAM
; Remarks .......: Call _VLC_MediaParse() first for local files that have not been played yet.
; ===============================================================================================================================
Func _VLC_MediaGetMetaAll($pMedia)
	Local $aNames[26] = ["Title", "Artist", "Genre", "Copyright", "Album", "TrackNumber", "Description", "Rating", "Date", _
			"Setting", "URL", "Language", "NowPlaying", "Publisher", "EncodedBy", "ArtworkURL", "TrackID", "TrackTotal", _
			"Director", "Season", "Episode", "ShowName", "Actors", "AlbumArtist", "DiscNumber", "DiscTotal"]
	Local $aOut[27][3]
	$aOut[0][0] = 0
	If $pMedia = 0 Then Return SetError($VLC_ERR_PARAM, 0, $aOut)
	For $i = 0 To 25
		$aOut[$i + 1][0] = $aNames[$i]
		$aOut[$i + 1][1] = _libvlc_media_get_meta($pMedia, $i)
		$aOut[$i + 1][2] = $i
	Next
	$aOut[0][0] = 26
	Return $aOut
EndFunc   ;==>_VLC_MediaGetMetaAll

; #FUNCTION# ====================================================================================================================
; Name ..........: _VLC_MediaGetTracks
; Description ...: Returns all elementary streams (audio, video, subtitle) of a media.
; Syntax ........: _VLC_MediaGetTracks($pMedia)
; Parameters ....: $pMedia              - libvlc_media_t * (parsed or playing)
; Return values .: Success - 2D array, [0][0] = number of tracks, columns see $VLC_TRACK_* constants:
;                            TYPE ($libvlc_track_audio/video/text), ID, CODEC (FourCC as text), FOURCC (number),
;                            PROFILE, LEVEL, BITRATE, LANGUAGE, DESCRIPTION, CHANNELS, RATE (audio), WIDTH, HEIGHT,
;                            SAR_NUM, SAR_DEN, FPS_NUM, FPS_DEN, ORIENTATION, PROJECTION (video), ENCODING (subtitle)
;                  Failure - array with [0][0] = 0, @error = $VLC_ERR_PARAM
; ===============================================================================================================================
Func _VLC_MediaGetTracks($pMedia)
	Local $aOut[1][$VLC_TRACK_COLUMNS]
	$aOut[0][0] = 0
	If $pMedia = 0 Then Return SetError($VLC_ERR_PARAM, 0, $aOut)
	Local $pTracks = Ptr(0)
	Local $iCount = _libvlc_media_tracks_get($pMedia, $pTracks)
	If @error Or $iCount <= 0 Or $pTracks = 0 Then Return $aOut
	ReDim $aOut[$iCount + 1][$VLC_TRACK_COLUMNS]
	Local $tArr = DllStructCreate("ptr[" & $iCount & "]", $pTracks)
	For $i = 1 To $iCount
		Local $tT = DllStructCreate($tagLIBVLC_MEDIA_TRACK, DllStructGetData($tArr, 1, $i))
		Local $iType = DllStructGetData($tT, "i_type")
		$aOut[$i][$VLC_TRACK_TYPE] = $iType
		$aOut[$i][$VLC_TRACK_ID] = DllStructGetData($tT, "i_id")
		$aOut[$i][$VLC_TRACK_CODEC] = _VLC_FourCCToString(DllStructGetData($tT, "i_codec"))
		$aOut[$i][$VLC_TRACK_FOURCC] = DllStructGetData($tT, "i_original_fourcc")
		$aOut[$i][$VLC_TRACK_PROFILE] = DllStructGetData($tT, "i_profile")
		$aOut[$i][$VLC_TRACK_LEVEL] = DllStructGetData($tT, "i_level")
		$aOut[$i][$VLC_TRACK_BITRATE] = DllStructGetData($tT, "i_bitrate")
		$aOut[$i][$VLC_TRACK_LANGUAGE] = __VLC_StrFromPtr(DllStructGetData($tT, "psz_language"), False)
		$aOut[$i][$VLC_TRACK_DESCRIPTION] = __VLC_StrFromPtr(DllStructGetData($tT, "psz_description"), False)
		Local $pSub = DllStructGetData($tT, "p_track")
		If $pSub <> 0 Then
			Switch $iType
				Case $libvlc_track_audio
					Local $tA = DllStructCreate($tagLIBVLC_AUDIO_TRACK, $pSub)
					$aOut[$i][$VLC_TRACK_CHANNELS] = DllStructGetData($tA, "i_channels")
					$aOut[$i][$VLC_TRACK_RATE] = DllStructGetData($tA, "i_rate")
				Case $libvlc_track_video
					Local $tV = DllStructCreate($tagLIBVLC_VIDEO_TRACK, $pSub)
					$aOut[$i][$VLC_TRACK_WIDTH] = DllStructGetData($tV, "i_width")
					$aOut[$i][$VLC_TRACK_HEIGHT] = DllStructGetData($tV, "i_height")
					$aOut[$i][$VLC_TRACK_SAR_NUM] = DllStructGetData($tV, "i_sar_num")
					$aOut[$i][$VLC_TRACK_SAR_DEN] = DllStructGetData($tV, "i_sar_den")
					$aOut[$i][$VLC_TRACK_FPS_NUM] = DllStructGetData($tV, "i_frame_rate_num")
					$aOut[$i][$VLC_TRACK_FPS_DEN] = DllStructGetData($tV, "i_frame_rate_den")
					$aOut[$i][$VLC_TRACK_ORIENTATION] = DllStructGetData($tV, "i_orientation")
					$aOut[$i][$VLC_TRACK_PROJECTION] = DllStructGetData($tV, "i_projection")
				Case $libvlc_track_text
					Local $tS = DllStructCreate($tagLIBVLC_SUBTITLE_TRACK, $pSub)
					$aOut[$i][$VLC_TRACK_ENCODING] = __VLC_StrFromPtr(DllStructGetData($tS, "psz_encoding"), False)
			EndSwitch
		EndIf
	Next
	$aOut[0][0] = $iCount
	_libvlc_media_tracks_release($pTracks, $iCount)
	Return $aOut
EndFunc   ;==>_VLC_MediaGetTracks

; #FUNCTION# ====================================================================================================================
; Name ..........: _VLC_MediaGetStats
; Description ...: Returns the playback statistics of a media.
; Syntax ........: _VLC_MediaGetStats($pMedia)
; Parameters ....: $pMedia              - libvlc_media_t * (playing)
; Return values .: Success - 1D array, [0] = 15, indices see $VLC_STAT_* constants
;                  Failure - array with [0] = 0, @error = $VLC_ERR_PARAM or $VLC_ERR_LIBVLC
; Remarks .......: The default option --no-stats disables most counters. Start with _VLC_Startup(Default, "--stats")
;                  (later options win) to get real values.
; ===============================================================================================================================
Func _VLC_MediaGetStats($pMedia)
	Local $aOut[16]
	$aOut[0] = 0
	If $pMedia = 0 Then Return SetError($VLC_ERR_PARAM, 0, $aOut)
	Local $tStats = DllStructCreate($tagLIBVLC_MEDIA_STATS)
	If Not _libvlc_media_get_stats($pMedia, $tStats) Then Return SetError($VLC_ERR_LIBVLC, 0, $aOut)
	For $i = 1 To 15
		$aOut[$i] = DllStructGetData($tStats, $i)
	Next
	$aOut[0] = 15
	Return $aOut
EndFunc   ;==>_VLC_MediaGetStats

; #FUNCTION# ====================================================================================================================
; Name ..........: _VLC_MediaGetSlaves
; Description ...: Returns the slaves (external subtitle/audio files) attached to a media.
; Syntax ........: _VLC_MediaGetSlaves($pMedia)
; Return values .: 2D array [0][0] = count, [n][0] = URI, [n][1] = type, [n][2] = priority
; ===============================================================================================================================
Func _VLC_MediaGetSlaves($pMedia)
	Local $aOut[1][3]
	$aOut[0][0] = 0
	If $pMedia = 0 Then Return SetError($VLC_ERR_PARAM, 0, $aOut)
	Local $pArr = Ptr(0)
	Local $iCount = _libvlc_media_slaves_get($pMedia, $pArr)
	If @error Or $iCount <= 0 Or $pArr = 0 Then Return $aOut
	ReDim $aOut[$iCount + 1][3]
	Local $tArr = DllStructCreate("ptr[" & $iCount & "]", $pArr)
	For $i = 1 To $iCount
		Local $t = DllStructCreate($tagLIBVLC_MEDIA_SLAVE, DllStructGetData($tArr, 1, $i))
		$aOut[$i][0] = __VLC_StrFromPtr(DllStructGetData($t, "psz_uri"), False)
		$aOut[$i][1] = DllStructGetData($t, "i_type")
		$aOut[$i][2] = DllStructGetData($t, "i_priority")
	Next
	$aOut[0][0] = $iCount
	_libvlc_media_slaves_release($pArr, $iCount)
	Return $aOut
EndFunc   ;==>_VLC_MediaGetSlaves
#EndRegion Media helpers

#Region Player helpers

; #FUNCTION# ====================================================================================================================
; Name ..........: _VLC_TrackDescriptionToArray
; Description ...: Converts a libvlc_track_description_t list into an array and releases the list.
; Syntax ........: _VLC_TrackDescriptionToArray($pList[, $bRelease = True])
; Return values .: 2D array [0][0] = count, [n][0] = track id, [n][1] = name
; ===============================================================================================================================
Func _VLC_TrackDescriptionToArray($pList, $bRelease = True)
	Local $aOut[1][2]
	$aOut[0][0] = 0
	Local $p = $pList, $n = 0
	While $p <> 0 And $n < 10000
		Local $t = DllStructCreate($tagLIBVLC_TRACK_DESCRIPTION, $p)
		$n += 1
		ReDim $aOut[$n + 1][2]
		$aOut[$n][0] = DllStructGetData($t, "i_id")
		$aOut[$n][1] = __VLC_StrFromPtr(DllStructGetData($t, "psz_name"), False)
		$p = DllStructGetData($t, "p_next")
	WEnd
	$aOut[0][0] = $n
	If $bRelease And $pList <> 0 Then _libvlc_track_description_list_release($pList)
	Return $aOut
EndFunc   ;==>_VLC_TrackDescriptionToArray

; #FUNCTION# ====================================================================================================================
; Name ..........: _VLC_PlayerGetAudioTracks
; Description ...: Returns the audio tracks of the playing media (id -1 = "Disable").
; Syntax ........: _VLC_PlayerGetAudioTracks($pPlayer)
; Return values .: 2D array [0][0] = count, [n][0] = id, [n][1] = name. Select with _libvlc_audio_set_track().
; ===============================================================================================================================
Func _VLC_PlayerGetAudioTracks($pPlayer)
	Return _VLC_TrackDescriptionToArray(_libvlc_audio_get_track_description($pPlayer))
EndFunc   ;==>_VLC_PlayerGetAudioTracks

; #FUNCTION# ====================================================================================================================
; Name ..........: _VLC_PlayerGetVideoTracks
; Description ...: Returns the video tracks of the playing media.
; Syntax ........: _VLC_PlayerGetVideoTracks($pPlayer)
; Return values .: 2D array [0][0] = count, [n][0] = id, [n][1] = name. Select with _libvlc_video_set_track().
; ===============================================================================================================================
Func _VLC_PlayerGetVideoTracks($pPlayer)
	Return _VLC_TrackDescriptionToArray(_libvlc_video_get_track_description($pPlayer))
EndFunc   ;==>_VLC_PlayerGetVideoTracks

; #FUNCTION# ====================================================================================================================
; Name ..........: _VLC_PlayerGetSubtitleTracks
; Description ...: Returns the subtitle (SPU) tracks of the playing media (id -1 = "Disable").
; Syntax ........: _VLC_PlayerGetSubtitleTracks($pPlayer)
; Return values .: 2D array [0][0] = count, [n][0] = id, [n][1] = name. Select with _libvlc_video_set_spu().
; ===============================================================================================================================
Func _VLC_PlayerGetSubtitleTracks($pPlayer)
	Return _VLC_TrackDescriptionToArray(_libvlc_video_get_spu_description($pPlayer))
EndFunc   ;==>_VLC_PlayerGetSubtitleTracks

; #FUNCTION# ====================================================================================================================
; Name ..........: _VLC_PlayerGetTitles
; Description ...: Returns the titles of the playing media (DVD, Blu-ray, Matroska editions ...).
; Syntax ........: _VLC_PlayerGetTitles($pPlayer)
; Return values .: 2D array [0][0] = count, [n][0] = duration (ms), [n][1] = name, [n][2] = flags
;                  (1 = menu, 2 = interactive)
; ===============================================================================================================================
Func _VLC_PlayerGetTitles($pPlayer)
	Local $aOut[1][3]
	$aOut[0][0] = 0
	Local $pArr = Ptr(0)
	Local $iCount = _libvlc_media_player_get_full_title_descriptions($pPlayer, $pArr)
	If @error Or $iCount <= 0 Or $pArr = 0 Then Return $aOut
	ReDim $aOut[$iCount + 1][3]
	Local $tArr = DllStructCreate("ptr[" & $iCount & "]", $pArr)
	For $i = 1 To $iCount
		Local $t = DllStructCreate($tagLIBVLC_TITLE_DESCRIPTION, DllStructGetData($tArr, 1, $i))
		$aOut[$i][0] = DllStructGetData($t, "i_duration")
		$aOut[$i][1] = __VLC_StrFromPtr(DllStructGetData($t, "psz_name"), False)
		$aOut[$i][2] = DllStructGetData($t, "i_flags")
	Next
	$aOut[0][0] = $iCount
	_libvlc_title_descriptions_release($pArr, $iCount)
	Return $aOut
EndFunc   ;==>_VLC_PlayerGetTitles

; #FUNCTION# ====================================================================================================================
; Name ..........: _VLC_PlayerGetChapters
; Description ...: Returns the chapters of a title of the playing media.
; Syntax ........: _VLC_PlayerGetChapters($pPlayer[, $iTitle = -1])
; Parameters ....: $iTitle              - [optional] title index, -1 = current title
; Return values .: 2D array [0][0] = count, [n][0] = start (ms), [n][1] = duration (ms), [n][2] = name
; ===============================================================================================================================
Func _VLC_PlayerGetChapters($pPlayer, $iTitle = -1)
	Local $aOut[1][3]
	$aOut[0][0] = 0
	Local $pArr = Ptr(0)
	Local $iCount = _libvlc_media_player_get_full_chapter_descriptions($pPlayer, $iTitle, $pArr)
	If @error Or $iCount <= 0 Or $pArr = 0 Then Return $aOut
	ReDim $aOut[$iCount + 1][3]
	Local $tArr = DllStructCreate("ptr[" & $iCount & "]", $pArr)
	For $i = 1 To $iCount
		Local $t = DllStructCreate($tagLIBVLC_CHAPTER_DESCRIPTION, DllStructGetData($tArr, 1, $i))
		$aOut[$i][0] = DllStructGetData($t, "i_time_offset")
		$aOut[$i][1] = DllStructGetData($t, "i_duration")
		$aOut[$i][2] = __VLC_StrFromPtr(DllStructGetData($t, "psz_name"), False)
	Next
	$aOut[0][0] = $iCount
	_libvlc_chapter_descriptions_release($pArr, $iCount)
	Return $aOut
EndFunc   ;==>_VLC_PlayerGetChapters

; #FUNCTION# ====================================================================================================================
; Name ..........: _VLC_PlayerStop
; Description ...: Stops a media player without blocking the GUI thread (no deadlock with the embedded video window).
; Syntax ........: _VLC_PlayerStop($pPlayer[, $iTimeout = $VLC_DEFAULT_TIMEOUT])
; Parameters ....: $pPlayer             - libvlc_media_player_t *
;                  $iTimeout            - [optional] max. wait time in ms
; Return values .: Success - True
;                  Failure - False, @error = $VLC_ERR_PARAM or $VLC_ERR_TIMEOUT
; Remarks .......: libvlc_media_player_stop() joins libVLC's input and video threads. The video window thread may
;                  need the GUI thread at that moment, so calling stop directly from the GUI thread can freeze the
;                  script. This function runs stop on a worker thread and keeps the AutoIt message loop running.
; ===============================================================================================================================
Func _VLC_PlayerStop($pPlayer, $iTimeout = $VLC_DEFAULT_TIMEOUT)
	If $pPlayer = 0 Then Return SetError($VLC_ERR_PARAM, 0, False)
	Local $bOk = __VLC_RunOnWorker("libvlc_media_player_stop", $pPlayer, $iTimeout)
	Return SetError(@error, 0, $bOk)
EndFunc   ;==>_VLC_PlayerStop

; #FUNCTION# ====================================================================================================================
; Name ..........: _VLC_PlayerSetMedia
; Description ...: Replaces the media of a (possibly playing or ended) player without blocking the GUI thread.
; Syntax ........: _VLC_PlayerSetMedia($pPlayer, $pMedia[, $iTimeout = $VLC_DEFAULT_TIMEOUT])
; Parameters ....: $pMedia              - libvlc_media_t * or 0 (no media). The player takes its own reference.
; Return values .: Success - True; Failure - False, @error = $VLC_ERR_PARAM, $VLC_ERR_STATE or $VLC_ERR_TIMEOUT
; Remarks .......: Unlike _VLC_PlayerStop() + set_media, the video output (window, Direct3D device) is kept and reused for
;                  the next media: faster item changes without flicker. Call play afterwards.
;                  On $VLC_ERR_TIMEOUT do NOT release $pMedia: set_media is still running and takes its reference late.
; ===============================================================================================================================
Func _VLC_PlayerSetMedia($pPlayer, $pMedia, $iTimeout = $VLC_DEFAULT_TIMEOUT)
	If $pPlayer = 0 Then Return SetError($VLC_ERR_PARAM, 0, False)
	Local $bOk = __VLC_RunOnWorker("libvlc_media_player_set_media", $pPlayer, $iTimeout, __VLC_Ptr($pMedia))
	Return SetError(@error, 0, $bOk)
EndFunc   ;==>_VLC_PlayerSetMedia

; #FUNCTION# ====================================================================================================================
; Name ..........: _VLC_PlayerRelease
; Description ...: Stops and releases a media player without blocking the GUI thread.
; Syntax ........: _VLC_PlayerRelease($pPlayer[, $iTimeout = $VLC_DEFAULT_TIMEOUT])
; Return values .: Success - True
;                  Failure - False, @error = $VLC_ERR_PARAM or $VLC_ERR_TIMEOUT
; Remarks .......: Detach your events (_VLC_EventDetachAll($pEventManager)) before releasing the player.
; ===============================================================================================================================
Func _VLC_PlayerRelease($pPlayer, $iTimeout = $VLC_DEFAULT_TIMEOUT)
	If $pPlayer = 0 Then Return SetError($VLC_ERR_PARAM, 0, False)
	If Not __VLC_RunOnWorker("libvlc_media_player_stop", $pPlayer, $iTimeout) Then Return SetError(@error, 0, False)
	Local $bOk = __VLC_RunOnWorker("libvlc_media_player_release", $pPlayer, $iTimeout)
	Return SetError(@error, 0, $bOk)
EndFunc   ;==>_VLC_PlayerRelease
; #FUNCTION# ====================================================================================================================
; Name ..........: _VLC_PlayerIsBusy
; Description ...: Returns True while a stop/release of this player that exceeded its timeout is still running.
; Syntax ........: _VLC_PlayerIsBusy($pPlayer)
; Remarks .......: While a player is busy, libVLC holds its internal input lock. Functions such as play, set_media,
;                  get_time or set_time would then block the calling (GUI) thread. Check this function before calling
;                  them after a $VLC_ERR_TIMEOUT. The GUI layer (CCGUICtrlVLC) does this automatically.
; ===============================================================================================================================
Func _VLC_PlayerIsBusy($pPlayer)
	Local $bBusy = False
	For $i = $__g_aVLC_Busy[0][0] To 1 Step -1
		Local $aWait = DllCall($__g_hVLC_K32, "dword", "WaitForSingleObject", "handle", $__g_aVLC_Busy[$i][1], "dword", 0)
		If Not @error And $aWait[0] = 0x102 Then ; still running
			If $__g_aVLC_Busy[$i][0] = Ptr($pPlayer) Then $bBusy = True
			ContinueLoop
		EndIf
		; finished: forget it
		DllCall("kernel32.dll", "bool", "CloseHandle", "handle", $__g_aVLC_Busy[$i][1])
		For $j = $i To $__g_aVLC_Busy[0][0] - 1
			$__g_aVLC_Busy[$j][0] = $__g_aVLC_Busy[$j + 1][0]
			$__g_aVLC_Busy[$j][1] = $__g_aVLC_Busy[$j + 1][1]
		Next
		$__g_aVLC_Busy[0][0] -= 1
	Next
	Return $bBusy
EndFunc   ;==>_VLC_PlayerIsBusy
#EndRegion Player helpers

#Region Lists (audio outputs, filters, equalizer, discoverers)

; #FUNCTION# ====================================================================================================================
; Name ..........: _VLC_AudioOutputList
; Description ...: Returns the available audio output modules (e.g. "mmdevice", "directsound", "waveout").
; Syntax ........: _VLC_AudioOutputList()
; Return values .: 2D array [0][0] = count, [n][0] = module name, [n][1] = description
; ===============================================================================================================================
Func _VLC_AudioOutputList()
	Local $aOut[1][2]
	$aOut[0][0] = 0
	If $__g_pVLC_Instance = 0 Then Return SetError($VLC_ERR_NOT_STARTED, 0, $aOut)
	Local $pList = _libvlc_audio_output_list_get($__g_pVLC_Instance)
	Local $p = $pList, $n = 0
	While $p <> 0 And $n < 1000
		Local $t = DllStructCreate($tagLIBVLC_AUDIO_OUTPUT, $p)
		$n += 1
		ReDim $aOut[$n + 1][2]
		$aOut[$n][0] = __VLC_StrFromPtr(DllStructGetData($t, "psz_name"), False)
		$aOut[$n][1] = __VLC_StrFromPtr(DllStructGetData($t, "psz_description"), False)
		$p = DllStructGetData($t, "p_next")
	WEnd
	$aOut[0][0] = $n
	If $pList <> 0 Then _libvlc_audio_output_list_release($pList)
	Return $aOut
EndFunc   ;==>_VLC_AudioOutputList

; #FUNCTION# ====================================================================================================================
; Name ..........: _VLC_AudioOutputDeviceList
; Description ...: Returns the audio devices of the current audio output of a player.
; Syntax ........: _VLC_AudioOutputDeviceList($pPlayer)
; Return values .: 2D array [0][0] = count, [n][0] = device id (for _libvlc_audio_output_device_set), [n][1] = name
; Remarks .......: The list is most reliable while the player is playing.
; ===============================================================================================================================
Func _VLC_AudioOutputDeviceList($pPlayer)
	Local $aOut[1][2]
	$aOut[0][0] = 0
	If $pPlayer = 0 Then Return SetError($VLC_ERR_PARAM, 0, $aOut)
	Local $pList = _libvlc_audio_output_device_enum($pPlayer)
	Local $p = $pList, $n = 0
	While $p <> 0 And $n < 1000
		Local $t = DllStructCreate($tagLIBVLC_AUDIO_OUTPUT_DEVICE, $p)
		$n += 1
		ReDim $aOut[$n + 1][2]
		$aOut[$n][0] = __VLC_StrFromPtr(DllStructGetData($t, "psz_device"), False)
		$aOut[$n][1] = __VLC_StrFromPtr(DllStructGetData($t, "psz_description"), False)
		$p = DllStructGetData($t, "p_next")
	WEnd
	$aOut[0][0] = $n
	If $pList <> 0 Then _libvlc_audio_output_device_list_release($pList)
	Return $aOut
EndFunc   ;==>_VLC_AudioOutputDeviceList

; #FUNCTION# ====================================================================================================================
; Name ..........: _VLC_FilterList
; Description ...: Returns the available audio or video filter modules.
; Syntax ........: _VLC_FilterList([$bVideo = True])
; Return values .: 2D array [0][0] = count, [n][0] = name, [n][1] = short name, [n][2] = long name, [n][3] = help
; ===============================================================================================================================
Func _VLC_FilterList($bVideo = True)
	Local $aOut[1][4]
	$aOut[0][0] = 0
	If $__g_pVLC_Instance = 0 Then Return SetError($VLC_ERR_NOT_STARTED, 0, $aOut)
	Local $pList = $bVideo ? _libvlc_video_filter_list_get($__g_pVLC_Instance) : _libvlc_audio_filter_list_get($__g_pVLC_Instance)
	Local $p = $pList, $n = 0
	While $p <> 0 And $n < 5000
		Local $t = DllStructCreate($tagLIBVLC_MODULE_DESCRIPTION, $p)
		$n += 1
		ReDim $aOut[$n + 1][4]
		$aOut[$n][0] = __VLC_StrFromPtr(DllStructGetData($t, "psz_name"), False)
		$aOut[$n][1] = __VLC_StrFromPtr(DllStructGetData($t, "psz_shortname"), False)
		$aOut[$n][2] = __VLC_StrFromPtr(DllStructGetData($t, "psz_longname"), False)
		$aOut[$n][3] = __VLC_StrFromPtr(DllStructGetData($t, "psz_help"), False)
		$p = DllStructGetData($t, "p_next")
	WEnd
	$aOut[0][0] = $n
	If $pList <> 0 Then _libvlc_module_description_list_release($pList)
	Return $aOut
EndFunc   ;==>_VLC_FilterList

; #FUNCTION# ====================================================================================================================
; Name ..........: _VLC_EqualizerGetPresets
; Description ...: Returns the names of the built-in equalizer presets.
; Syntax ........: _VLC_EqualizerGetPresets()
; Return values .: 1D array [0] = count, [n] = name of preset n-1 (use n-1 as preset index)
; ===============================================================================================================================
Func _VLC_EqualizerGetPresets()
	Local $iCount = _libvlc_audio_equalizer_get_preset_count()
	If @error Then
		Local $aErr[1] = [0]
		Return SetError($VLC_ERR_DLLCALL, 0, $aErr)
	EndIf
	Local $aOut[$iCount + 1]
	$aOut[0] = $iCount
	For $i = 0 To $iCount - 1
		$aOut[$i + 1] = _libvlc_audio_equalizer_get_preset_name($i)
	Next
	Return $aOut
EndFunc   ;==>_VLC_EqualizerGetPresets

; #FUNCTION# ====================================================================================================================
; Name ..........: _VLC_EqualizerGetBands
; Description ...: Returns the center frequencies of the equalizer bands.
; Syntax ........: _VLC_EqualizerGetBands()
; Return values .: 1D array [0] = count, [n] = frequency of band n-1 in Hz
; ===============================================================================================================================
Func _VLC_EqualizerGetBands()
	Local $iCount = _libvlc_audio_equalizer_get_band_count()
	If @error Then
		Local $aErr[1] = [0]
		Return SetError($VLC_ERR_DLLCALL, 0, $aErr)
	EndIf
	Local $aOut[$iCount + 1]
	$aOut[0] = $iCount
	For $i = 0 To $iCount - 1
		$aOut[$i + 1] = _libvlc_audio_equalizer_get_band_frequency($i)
	Next
	Return $aOut
EndFunc   ;==>_VLC_EqualizerGetBands

; #FUNCTION# ====================================================================================================================
; Name ..........: _VLC_MediaDiscovererList
; Description ...: Returns the media discoverers (UPnP, SMB, mDNS ...) of a category.
; Syntax ........: _VLC_MediaDiscovererList([$iCategory = $libvlc_media_discoverer_lan])
; Return values .: 2D array [0][0] = count, [n][0] = name (for _libvlc_media_discoverer_new), [n][1] = long name,
;                  [n][2] = category
; ===============================================================================================================================
Func _VLC_MediaDiscovererList($iCategory = $libvlc_media_discoverer_lan)
	Local $aOut[1][3]
	$aOut[0][0] = 0
	If $__g_pVLC_Instance = 0 Then Return SetError($VLC_ERR_NOT_STARTED, 0, $aOut)
	Local $pArr = Ptr(0)
	Local $iCount = _libvlc_media_discoverer_list_get($__g_pVLC_Instance, $iCategory, $pArr)
	If @error Or $iCount <= 0 Or $pArr = 0 Then Return $aOut
	ReDim $aOut[$iCount + 1][3]
	Local $tArr = DllStructCreate("ptr[" & $iCount & "]", $pArr)
	For $i = 1 To $iCount
		Local $t = DllStructCreate($tagLIBVLC_MEDIA_DISCOVERER_DESCRIPTION, DllStructGetData($tArr, 1, $i))
		$aOut[$i][0] = __VLC_StrFromPtr(DllStructGetData($t, "psz_name"), False)
		$aOut[$i][1] = __VLC_StrFromPtr(DllStructGetData($t, "psz_longname"), False)
		$aOut[$i][2] = DllStructGetData($t, "i_cat")
	Next
	$aOut[0][0] = $iCount
	_libvlc_media_discoverer_list_release($pArr, $iCount)
	Return $aOut
EndFunc   ;==>_VLC_MediaDiscovererList

; #FUNCTION# ====================================================================================================================
; Name ..........: _VLC_RendererDiscovererList
; Description ...: Returns the renderer discoverers (e.g. "microdns" for Chromecast).
; Syntax ........: _VLC_RendererDiscovererList()
; Return values .: 2D array [0][0] = count, [n][0] = name (for _libvlc_renderer_discoverer_new), [n][1] = long name
; ===============================================================================================================================
Func _VLC_RendererDiscovererList()
	Local $aOut[1][2]
	$aOut[0][0] = 0
	If $__g_pVLC_Instance = 0 Then Return SetError($VLC_ERR_NOT_STARTED, 0, $aOut)
	Local $pArr = Ptr(0)
	Local $iCount = _libvlc_renderer_discoverer_list_get($__g_pVLC_Instance, $pArr)
	If @error Or $iCount <= 0 Or $pArr = 0 Then Return $aOut
	ReDim $aOut[$iCount + 1][2]
	Local $tArr = DllStructCreate("ptr[" & $iCount & "]", $pArr)
	For $i = 1 To $iCount
		Local $t = DllStructCreate($tagLIBVLC_RD_DESCRIPTION, DllStructGetData($tArr, 1, $i))
		$aOut[$i][0] = __VLC_StrFromPtr(DllStructGetData($t, "psz_name"), False)
		$aOut[$i][1] = __VLC_StrFromPtr(DllStructGetData($t, "psz_longname"), False)
	Next
	$aOut[0][0] = $iCount
	_libvlc_renderer_discoverer_list_release($pArr, $iCount)
	Return $aOut
EndFunc   ;==>_VLC_RendererDiscovererList
#EndRegion Lists (audio outputs, filters, equalizer, discoverers)

#Region Events

; #FUNCTION# ====================================================================================================================
; Name ..........: _VLC_EventAttach
; Description ...: Subscribes to one or more libVLC events. Events are delivered on the AutoIt thread.
; Syntax ........: _VLC_EventAttach($pEventManager, $vEventTypes[, $sCallback = ""[, $vUserData = Default[, $vOwner = Default]]])
; Parameters ....: $pEventManager       - libvlc_event_manager_t * (e.g. _libvlc_media_player_event_manager($pPlayer))
;                  $vEventTypes         - one event type ($libvlc_MediaPlayerPlaying ...) or a 0-based array of types
;                  $sCallback           - [optional] name of the AutoIt function to call, signature:
;                                         Func MyEvent($iSubscription, $iEventType, $vValue1, $vValue2, $pObj, $vUserData)
;                                         "" = no callback, read events with _VLC_EventGetNext() instead.
;                  $vUserData           - [optional] any value passed to the callback
;                  $vOwner              - [optional] tag for _VLC_EventDetachAll() (internal use by the GUI layer)
; Return values .: Success - subscription id (> 0)
;                  Failure - 0, @error = $VLC_ERR_NOT_STARTED, $VLC_ERR_PARAM or $VLC_ERR_LIBVLC
; Remarks .......: Values per event type: see _VLC_EventsProcess(). Callbacks are called from an Adlib function
;                  (every 20 ms) or when you call _VLC_EventsProcess(). TimeChanged, PositionChanged and Buffering
;                  events are coalesced: only the newest value is kept in the queue.
;                  IMPORTANT: detach before the object owning the event manager is released.
; Related .......: _VLC_EventDetach, _VLC_EventGetNext, _VLC_EventsProcess
; ===============================================================================================================================
Func _VLC_EventAttach($pEventManager, $vEventTypes, $sCallback = "", $vUserData = Default, $vOwner = Default)
	If $__g_pVLC_Code = 0 Or $__g_hVLC_Dll = -1 Then Return SetError($VLC_ERR_NOT_STARTED, 0, 0)
	If $pEventManager = 0 Then Return SetError($VLC_ERR_PARAM, 0, 0)
	Local $aTypes
	If IsArray($vEventTypes) Then
		$aTypes = $vEventTypes
	Else
		Local $aOne[1] = [Int($vEventTypes)]
		$aTypes = $aOne
	EndIf
	If UBound($aTypes) = 0 Then Return SetError($VLC_ERR_PARAM, 0, 0)

	; find a free slot
	Local $iSub = 0
	For $i = 1 To $__g_aVLC_Subs[0][0]
		If Not $__g_aVLC_Subs[$i][0] Then
			$iSub = $i
			ExitLoop
		EndIf
	Next
	If $iSub = 0 Then
		$iSub = $__g_aVLC_Subs[0][0] + 1
		ReDim $__g_aVLC_Subs[$iSub + 1][8]
		$__g_aVLC_Subs[0][0] = $iSub
	EndIf
	$__g_iVLC_NextSubId += 1
	Local $iId = $__g_iVLC_NextSubId

	; context block for the native thunk (8 pointer-sized fields)
	Local $tCtx = DllStructCreate("ptr[8]")
	DllStructSetData($tCtx, 1, $__g_pVLC_HeapAlloc, 1)
	DllStructSetData($tCtx, 1, $__g_pVLC_HeapFree, 2)
	DllStructSetData($tCtx, 1, $__g_pVLC_PostMessage, 3)
	DllStructSetData($tCtx, 1, $__g_hVLC_Heap, 4)
	DllStructSetData($tCtx, 1, $__g_hVLC_EventWnd, 5)
	DllStructSetData($tCtx, 1, $VLC_WM_EVENT, 6)
	DllStructSetData($tCtx, 1, $iId, 7)
	DllStructSetData($tCtx, 1, @AutoItX64 ? 32 : 16, 8) ; sizeof(libvlc_event_t)

	Local $aDone[UBound($aTypes)], $iDone = 0
	For $i = 0 To UBound($aTypes) - 1
		Local $iRet = _libvlc_event_attach($pEventManager, $aTypes[$i], Ptr($__g_pVLC_Code + $__VLC_THUNK_EVENT), DllStructGetPtr($tCtx))
		If @error Or $iRet <> 0 Then
			; roll back what was attached so far
			For $j = 0 To $iDone - 1
				_libvlc_event_detach($pEventManager, $aDone[$j], Ptr($__g_pVLC_Code + $__VLC_THUNK_EVENT), DllStructGetPtr($tCtx))
			Next
			Return SetError($VLC_ERR_LIBVLC, 0, __VLC_ErrRet(0, "libvlc_event_attach() failed for event type " & $aTypes[$i]))
		EndIf
		$aDone[$iDone] = $aTypes[$i]
		$iDone += 1
	Next

	$__g_aVLC_Subs[$iSub][0] = True
	$__g_aVLC_Subs[$iSub][1] = $pEventManager
	$__g_aVLC_Subs[$iSub][2] = $aDone
	$__g_aVLC_Subs[$iSub][3] = $tCtx
	$__g_aVLC_Subs[$iSub][4] = $sCallback
	$__g_aVLC_Subs[$iSub][5] = $vUserData
	$__g_aVLC_Subs[$iSub][6] = $vOwner
	$__g_aVLC_Subs[$iSub][7] = $iId
	If $sCallback <> "" And Not $__g_bVLC_PumpRegistered Then
		AdlibRegister("__VLC_EventPump", 20)
		$__g_bVLC_PumpRegistered = True
	EndIf
	Return $iId
EndFunc   ;==>_VLC_EventAttach

; #FUNCTION# ====================================================================================================================
; Name ..........: _VLC_EventDetach
; Description ...: Removes an event subscription.
; Syntax ........: _VLC_EventDetach($iSubscription[, $bOwnerReleased = False])
; Parameters ....: $iSubscription       - id returned by _VLC_EventAttach()
;                  $bOwnerReleased      - [optional] True if the object owning the event manager has already been
;                                         released (then libVLC has dropped the listeners itself and detaching would
;                                         access freed memory)
; Return values .: Success - True
;                  Failure - False, @error = $VLC_ERR_PARAM (unknown or already detached subscription)
; Remarks .......: After this function returns, the native thunk is no longer called for this subscription.
;                  Already queued events of this subscription are discarded.
; ===============================================================================================================================
Func _VLC_EventDetach($iSubscription, $bOwnerReleased = False)
	$iSubscription = Int($iSubscription)
	Local $iSlot = __VLC_SubSlot($iSubscription)
	If $iSlot = 0 Then Return SetError($VLC_ERR_PARAM, 0, False)
	Local $tCtx = $__g_aVLC_Subs[$iSlot][3]
	If Not $bOwnerReleased Then
		Local $pEM = $__g_aVLC_Subs[$iSlot][1]
		Local $aTypes = $__g_aVLC_Subs[$iSlot][2]
		; libvlc_event_detach() aborts the process for unknown listeners: only detach what was attached
		For $i = 0 To UBound($aTypes) - 1
			_libvlc_event_detach($pEM, $aTypes[$i], Ptr($__g_pVLC_Code + $__VLC_THUNK_EVENT), DllStructGetPtr($tCtx))
		Next
	EndIf
	; libvlc_event_detach() takes the event manager lock that is held while callbacks run, so the thunk is not
	; running for this context any more. The struct is kept anyway (a few bytes) to be on the safe side.
	__VLC_KeepAlive($tCtx)
	$__g_aVLC_Subs[$iSlot][0] = False
	For $c = 1 To 7
		$__g_aVLC_Subs[$iSlot][$c] = 0
	Next
	$__g_aVLC_Subs[$iSlot][4] = ""
	; drop queued events of this subscription (events still in the inbox or on their way are dropped by the pump,
	; because subscription ids are never reused). The flag keeps the Adlib pump out while the queue is compacted.
	Local $bWasInPump = $__g_bVLC_InPump
	$__g_bVLC_InPump = True
	Local $n = $__g_aVLC_Queue[0][0], $k = 0
	For $i = 1 To $n
		If $__g_aVLC_Queue[$i][0] <> $iSubscription Then
			$k += 1
			If $k <> $i Then
				For $c = 0 To 4
					$__g_aVLC_Queue[$k][$c] = $__g_aVLC_Queue[$i][$c]
				Next
			EndIf
		EndIf
	Next
	$__g_aVLC_Queue[0][0] = $k
	$__g_bVLC_InPump = $bWasInPump
	Return True
EndFunc   ;==>_VLC_EventDetach

; #FUNCTION# ====================================================================================================================
; Name ..........: _VLC_EventDetachAll
; Description ...: Removes all subscriptions, or all subscriptions of one event manager / owner tag.
; Syntax ........: _VLC_EventDetachAll([$pEventManager = Default[, $vOwner = Default[, $bOwnerReleased = False]]])
; Return values .: Number of removed subscriptions
; ===============================================================================================================================
Func _VLC_EventDetachAll($pEventManager = Default, $vOwner = Default, $bOwnerReleased = False)
	Local $n = 0
	For $i = 1 To $__g_aVLC_Subs[0][0]
		If Not $__g_aVLC_Subs[$i][0] Then ContinueLoop
		If Not IsKeyword($pEventManager) And $__g_aVLC_Subs[$i][1] <> $pEventManager Then ContinueLoop
		If Not IsKeyword($vOwner) And $__g_aVLC_Subs[$i][6] <> $vOwner Then ContinueLoop
		If _VLC_EventDetach($__g_aVLC_Subs[$i][7], $bOwnerReleased) Then $n += 1
	Next
	Return $n
EndFunc   ;==>_VLC_EventDetachAll

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __VLC_SubSlot
; Description ...: Slot index of an active subscription id, 0 if unknown.
; ===============================================================================================================================
Func __VLC_SubSlot($iId)
	If $iId < 1 Then Return 0
	For $i = 1 To $__g_aVLC_Subs[0][0]
		If $__g_aVLC_Subs[$i][0] And $__g_aVLC_Subs[$i][7] = $iId Then Return $i
	Next
	Return 0
EndFunc   ;==>__VLC_SubSlot

; #FUNCTION# ====================================================================================================================
; Name ..........: _VLC_EventGetNext
; Description ...: Takes the next queued event of subscriptions without callback (polling mode).
; Syntax ........: _VLC_EventGetNext(ByRef $aEvent[, $iSubscription = Default])
; Parameters ....: $aEvent              - [out] 1D array: [0] subscription, [1] event type, [2] value1, [3] value2,
;                                         [4] pObj (object that sent the event)
;                  $iSubscription       - [optional] only take events of this subscription
; Return values .: True if an event was returned, False if the queue is empty
; ===============================================================================================================================
Func _VLC_EventGetNext(ByRef $aEvent, $iSubscription = Default)
	Local $bWasInPump = $__g_bVLC_InPump
	$__g_bVLC_InPump = True ; keep the Adlib pump out while the queue is changed
	__VLC_InboxDrain()
	Local $bFound = False
	For $i = 1 To $__g_aVLC_Queue[0][0]
		Local $iSub = $__g_aVLC_Queue[$i][0]
		If Not IsKeyword($iSubscription) And $iSub <> $iSubscription Then ContinueLoop
		Local $iSlot = __VLC_SubSlot($iSub)
		If $iSlot <> 0 Then
			If $__g_aVLC_Subs[$iSlot][4] <> "" Then ContinueLoop ; belongs to a callback subscription
		EndIf
		Local $aEv[5] = [$iSub, $__g_aVLC_Queue[$i][1], $__g_aVLC_Queue[$i][2], $__g_aVLC_Queue[$i][3], $__g_aVLC_Queue[$i][4]]
		__VLC_QueueRemove($i)
		$aEvent = $aEv
		$bFound = True
		ExitLoop
	Next
	$__g_bVLC_InPump = $bWasInPump
	Return $bFound
EndFunc   ;==>_VLC_EventGetNext

; #FUNCTION# ====================================================================================================================
; Name ..........: _VLC_EventsProcess
; Description ...: Calls the callbacks of all queued events now (normally done automatically every 20 ms).
; Syntax ........: _VLC_EventsProcess()
; Return values .: Number of delivered events
; Remarks .......: Event values ($vValue1 / $vValue2) by type:
;                  MediaPlayerTimeChanged, LengthChanged, MediaDurationChanged : time in ms (Int64)
;                  MediaPlayerPositionChanged : position 0.0 - 1.0 | MediaPlayerBuffering : cache 0 - 100 (%)
;                  MediaPlayerAudioVolume : volume 0.0 - 2.0 (1.0 = 100 %)
;                  MediaPlayerSeekableChanged, PausableChanged, ScrambledChanged : 0/1
;                  MediaPlayerVout : number of video outputs | TitleChanged, ChapterChanged : index
;                  MediaPlayerESAdded/ESDeleted/ESSelected : value1 = track type, value2 = track id
;                  MediaStateChanged : libvlc_state_t | MediaParsedChanged : parsed status | MediaMetaChanged: meta id
;                  MediaListItemAdded/... : value1 = libvlc_media_t *, value2 = index
;                  MediaPlayerMediaChanged, MediaSubItemAdded, MediaFreed, RendererDiscovererItem* : value1 = pointer
;                  Strings of SnapshotTaken, AudioDevice and Vlm* events are not available (freed by libVLC before
;                  the event reaches AutoIt), value1 is "".
; ===============================================================================================================================
Func _VLC_EventsProcess()
	If $__g_bVLC_InPump Then Return 0
	$__g_bVLC_InPump = True
	Local $iDelivered = 0
	While $iDelivered < 10000
		; take over events that arrived meanwhile (also those that arrive while callbacks run)
		__VLC_InboxDrain()
		; first queued event that belongs to a subscription with callback (drop orphaned events on the way)
		Local $iIdx = 0, $iSlot = 0, $i = 1
		While $i <= $__g_aVLC_Queue[0][0]
			$iSlot = __VLC_SubSlot($__g_aVLC_Queue[$i][0])
			If $iSlot = 0 Then
				__VLC_QueueRemove($i)
				ContinueLoop
			EndIf
			If $__g_aVLC_Subs[$iSlot][4] <> "" Then
				$iIdx = $i
				ExitLoop
			EndIf
			$i += 1
		WEnd
		If $iIdx = 0 Then ExitLoop
		Local $iSub = $__g_aVLC_Queue[$iIdx][0], $iType = $__g_aVLC_Queue[$iIdx][1]
		Local $v1 = $__g_aVLC_Queue[$iIdx][2], $v2 = $__g_aVLC_Queue[$iIdx][3], $pObj = $__g_aVLC_Queue[$iIdx][4]
		Local $sFunc = $__g_aVLC_Subs[$iSlot][4], $vUser = $__g_aVLC_Subs[$iSlot][5]
		__VLC_QueueRemove($iIdx)
		Call($sFunc, $iSub, $iType, $v1, $v2, $pObj, $vUser)
		If @error = 0xDEAD And @extended = 0xBEEF Then
			$__g_sVLC_LastError = "event callback '" & $sFunc & "' not found or wrong number of parameters (6 required)"
		EndIf
		$iDelivered += 1
	WEnd
	$__g_bVLC_InPump = False
	Return $iDelivered
EndFunc   ;==>_VLC_EventsProcess

; #FUNCTION# ====================================================================================================================
; Name ..........: _VLC_EventTypeName
; Description ...: Returns the libVLC name of an event type, e.g. "MediaPlayerPlaying".
; Syntax ........: _VLC_EventTypeName($iEventType)
; ===============================================================================================================================
Func _VLC_EventTypeName($iEventType)
	If $__g_hVLC_Dll = -1 Then Return SetError($VLC_ERR_NOT_STARTED, 0, "")
	Return _libvlc_event_type_name($iEventType)
EndFunc   ;==>_VLC_EventTypeName
#EndRegion Events

#Region Utilities

; #FUNCTION# ====================================================================================================================
; Name ..........: _VLC_IsUrl
; Description ...: Returns True if the string is an URL/MRL ("scheme://...") rather than a local path.
; Syntax ........: _VLC_IsUrl($sMRL)
; ===============================================================================================================================
Func _VLC_IsUrl($sMRL)
	Return StringRegExp($sMRL, "^[A-Za-z][A-Za-z0-9+.\-]+://") = 1
EndFunc   ;==>_VLC_IsUrl

; #FUNCTION# ====================================================================================================================
; Name ..........: _VLC_PathToUri
; Description ...: Converts a local path into a file:// URI (RFC 3986, UTF-8 percent encoding).
; Syntax ........: _VLC_PathToUri($sPath)
; Return values .: URI, e.g. "C:\Movies\Märchen 1.srt" -> "file:///C:/Movies/M%C3%A4rchen%201.srt",
;                  "\\server\share\a.srt" -> "file://server/share/a.srt". URLs are returned unchanged.
; ===============================================================================================================================
Func _VLC_PathToUri($sPath)
	If _VLC_IsUrl($sPath) Then Return $sPath
	Local $sFull = __VLC_FullPath($sPath)
	Local $sPrefix = "file:///"
	If StringLeft($sFull, 2) = "\\" Then
		$sPrefix = "file://"
		$sFull = StringTrimLeft($sFull, 2)
	EndIf
	$sFull = StringReplace($sFull, "\", "/")
	Local $bUtf8 = StringToBinary($sFull, 4), $sOut = ""
	For $i = 1 To BinaryLen($bUtf8)
		Local $iB = Int(BinaryMid($bUtf8, $i, 1))
		; unreserved characters, "/" and ":" stay as they are
		If ($iB >= 0x30 And $iB <= 0x39) Or ($iB >= 0x41 And $iB <= 0x5A) Or ($iB >= 0x61 And $iB <= 0x7A) Or _
				$iB = 0x2D Or $iB = 0x2E Or $iB = 0x5F Or $iB = 0x7E Or $iB = 0x2F Or $iB = 0x3A Then
			$sOut &= Chr($iB)
		Else
			$sOut &= "%" & Hex($iB, 2)
		EndIf
	Next
	Return $sPrefix & $sOut
EndFunc   ;==>_VLC_PathToUri

; #FUNCTION# ====================================================================================================================
; Name ..........: _VLC_FormatTime
; Description ...: Formats milliseconds as "m:ss" or "h:mm:ss".
; Syntax ........: _VLC_FormatTime($iMs[, $bForceHours = False])
; ===============================================================================================================================
Func _VLC_FormatTime($iMs, $bForceHours = False)
	If $iMs < 0 Then $iMs = 0
	Local $iSec = Int($iMs / 1000)
	Local $iH = Int($iSec / 3600), $iM = Int(Mod($iSec, 3600) / 60), $iS = Mod($iSec, 60)
	If $iH > 0 Or $bForceHours Then Return StringFormat("%d:%02d:%02d", $iH, $iM, $iS)
	Return StringFormat("%d:%02d", $iM, $iS)
EndFunc   ;==>_VLC_FormatTime

; #FUNCTION# ====================================================================================================================
; Name ..........: _VLC_FourCCToString
; Description ...: Converts a FourCC number (e.g. codec of a track) into its 4 character text, e.g. "h264".
; Syntax ........: _VLC_FourCCToString($iFourCC)
; ===============================================================================================================================
Func _VLC_FourCCToString($iFourCC)
	Local $s = ""
	For $i = 0 To 3
		Local $c = BitAND(BitShift($iFourCC, $i * 8), 0xFF)
		$s &= ($c >= 32 And $c < 127) ? Chr($c) : " "
	Next
	Return StringStripWS($s, 2)
EndFunc   ;==>_VLC_FourCCToString
#EndRegion Utilities

#Region Internal: strings and pointers

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __VLC_Ptr
; Description ...: Converts Ptr, Hwnd, numbers, DllStructs, Null/Default/"" into a pointer value for DllCall.
; ===============================================================================================================================
Func __VLC_Ptr($v)
	If IsDllStruct($v) Then Return DllStructGetPtr($v)
	If IsKeyword($v) Then Return Ptr(0)
	If IsString($v) And $v = "" Then Return Ptr(0)
	Return Ptr($v)
EndFunc   ;==>__VLC_Ptr

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __VLC_Utf8Struct
; Description ...: Returns a DllStruct with the zero-terminated UTF-8 string, or 0 for Null/Default (NULL pointer).
; ===============================================================================================================================
Func __VLC_Utf8Struct($s)
	If IsKeyword($s) Then Return 0
	Local $bData = StringToBinary(String($s), 4)
	Local $iLen = BinaryLen($bData)
	Local $t = DllStructCreate("byte[" & ($iLen + 1) & "]")
	If $iLen > 0 Then DllStructSetData($t, 1, $bData)
	Return $t
EndFunc   ;==>__VLC_Utf8Struct

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __VLC_Utf8Array
; Description ...: Builds a NULL terminated char*[] from a 0-based AutoIt array. Returns an array that keeps all structs
;                  alive ([0] = pointer array), or 0 if $a is not an array.
; ===============================================================================================================================
Func __VLC_Utf8Array($a)
	If Not IsArray($a) Then Return 0
	Local $n = UBound($a)
	Local $aKeep[$n + 1]
	$aKeep[0] = DllStructCreate("ptr[" & ($n + 1) & "]")
	For $i = 0 To $n - 1
		$aKeep[$i + 1] = __VLC_Utf8Struct($a[$i])
		DllStructSetData($aKeep[0], 1, __VLC_Ptr($aKeep[$i + 1]), $i + 1)
	Next
	Return $aKeep
EndFunc   ;==>__VLC_Utf8Array

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __VLC_Utf8ArrayPtr
; Description ...: Pointer of an array built by __VLC_Utf8Array() (NULL if none).
; ===============================================================================================================================
Func __VLC_Utf8ArrayPtr($aKeep)
	If Not IsArray($aKeep) Then Return Ptr(0)
	Return DllStructGetPtr($aKeep[0])
EndFunc   ;==>__VLC_Utf8ArrayPtr

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __VLC_StrFromPtr
; Description ...: Reads a zero-terminated UTF-8 string. NULL -> "" with @extended = 1. $bFree releases it (libvlc_free).
; ===============================================================================================================================
Func __VLC_StrFromPtr($p, $bFree)
	If $p = 0 Then Return SetExtended(1, "")
	Local $s = ""
	Local $aLen = DllCall("kernel32.dll", "int", "lstrlenA", "ptr", $p)
	If Not @error And $aLen[0] > 0 Then
		Local $t = DllStructCreate("byte[" & $aLen[0] & "]", $p)
		$s = BinaryToString(DllStructGetData($t, 1), 4)
	EndIf
	If $bFree Then DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_free", "ptr", $p)
	Return $s
EndFunc   ;==>__VLC_StrFromPtr

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __VLC_OptionsToArray
; Description ...: Default/""/Null -> empty array, "a|b" -> [a, b], array -> copy (as strings).
; ===============================================================================================================================
Func __VLC_OptionsToArray($v)
	If IsArray($v) Then
		Local $aCopy[UBound($v)]
		For $i = 0 To UBound($v) - 1
			$aCopy[$i] = String($v[$i])
		Next
		Return $aCopy
	EndIf
	If IsKeyword($v) Or String($v) = "" Then
		Local $aEmpty[0]
		Return $aEmpty
	EndIf
	Return StringSplit(String($v), "|", 2)
EndFunc   ;==>__VLC_OptionsToArray

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __VLC_ErrRet / __VLC_LibErrRet
; Description ...: Store an error text and return $vReturn. Use as  Return SetError($iErr, 0, __VLC_ErrRet($v, "text")).
;                  (@error set inside a helper does not survive the helper's own Return, so SetError must be called
;                  in the function that returns to the user.)
; ===============================================================================================================================
Func __VLC_ErrRet($vReturn, $sText)
	$__g_sVLC_LastError = $sText
	Return $vReturn
EndFunc   ;==>__VLC_ErrRet

Func __VLC_LibErrRet($vReturn, $sText)
	Local $sLib = ""
	If $__g_pVLC_Instance <> 0 Then $sLib = _libvlc_errmsg() ; only valid while an instance exists
	$__g_sVLC_LastError = $sText & ($sLib <> "" ? " (libVLC: " & $sLib & ")" : "")
	Return $vReturn
EndFunc   ;==>__VLC_LibErrRet

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __VLC_FullPath
; Description ...: Absolute path via GetFullPathNameW (relative paths are resolved against @WorkingDir).
; ===============================================================================================================================
Func __VLC_FullPath($sPath)
	Local $aCall = DllCall("kernel32.dll", "dword", "GetFullPathNameW", "wstr", $sPath, "dword", 32767, "wstr", "", "ptr", 0)
	If @error Or $aCall[0] = 0 Then Return $sPath
	Return $aCall[3]
EndFunc   ;==>__VLC_FullPath

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __VLC_KeepAlive
; Description ...: Keeps a struct referenced until the script ends.
; ===============================================================================================================================
Func __VLC_JoinOptions($a)
	Local $s = ""
	For $i = 0 To UBound($a) - 1
		$s &= ($i ? " " : "") & $a[$i]
	Next
	Return $s
EndFunc   ;==>__VLC_JoinOptions

Func __VLC_KeepAlive($t)
	Local $n = $__g_aVLC_KeepAlive[0] + 1
	ReDim $__g_aVLC_KeepAlive[$n + 1]
	$__g_aVLC_KeepAlive[$n] = $t
	$__g_aVLC_KeepAlive[0] = $n
EndFunc   ;==>__VLC_KeepAlive
#EndRegion Internal: strings and pointers

#Region Internal: loading

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __VLC_FindDir
; Description ...: Finds a libVLC directory with the bitness of the running AutoIt.
; ===============================================================================================================================
Func __VLC_FindDir($sVlcDir)
	Local $bArchMismatch = False, $sMismatch = ""
	If Not IsKeyword($sVlcDir) And String($sVlcDir) <> "" Then
		Local $sDir = StringRegExpReplace(__VLC_FullPath($sVlcDir), "\\+$", "")
		Local $iRes = __VLC_CheckDir($sDir)
		If $iRes = 1 Then Return $sDir
		If $iRes = 2 Then Return SetError($VLC_ERR_ARCH, 0, __VLC_ErrRet("", "libvlc.dll in '" & $sDir & "' is " & _
				(@AutoItX64 ? "32" : "64") & " bit, but AutoIt runs as " & (@AutoItX64 ? "64" : "32") & " bit"))
		Return SetError($VLC_ERR_NOTFOUND, 0, __VLC_ErrRet("", "libvlc.dll not found in '" & $sDir & "'"))
	EndIf
	Local $aCand[6]
	$aCand[0] = @ScriptDir & (@AutoItX64 ? "\vlc_x64" : "\vlc_x86")
	$aCand[1] = @ScriptDir & "\vlc"
	$aCand[2] = @ScriptDir
	$aCand[3] = RegRead((@AutoItX64 ? "HKLM64" : "HKLM") & "\SOFTWARE\VideoLAN\VLC", "InstallDir")
	$aCand[4] = @ProgramFilesDir & "\VideoLAN\VLC"
	$aCand[5] = EnvGet("ProgramW6432") & "\VideoLAN\VLC"
	For $i = 0 To UBound($aCand) - 1
		If $aCand[$i] = "" Or $aCand[$i] = "\VideoLAN\VLC" Then ContinueLoop
		Local $sD = StringRegExpReplace($aCand[$i], "\\+$", "")
		Local $iR = __VLC_CheckDir($sD)
		If $iR = 1 Then Return $sD
		If $iR = 2 Then
			$bArchMismatch = True
			$sMismatch = $sD
		EndIf
	Next
	If $bArchMismatch Then Return SetError($VLC_ERR_ARCH, 0, __VLC_ErrRet("", "only a libvlc.dll with the wrong bitness was found ('" & _
			$sMismatch & "'). Install VLC " & (@AutoItX64 ? "64" : "32") & " bit or run the script with AutoIt" & _
			(@AutoItX64 ? " x86" : "_x64")))
	Return SetError($VLC_ERR_NOTFOUND, 0, __VLC_ErrRet("", "libvlc.dll not found (install VLC 3.0 or copy it to @ScriptDir\vlc)"))
EndFunc   ;==>__VLC_FindDir

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __VLC_CheckDir
; Description ...: 0 = no libvlc.dll, 1 = usable, 2 = wrong bitness
; ===============================================================================================================================
Func __VLC_CheckDir($sDir)
	If Not FileExists($sDir & "\libvlc.dll") Or Not FileExists($sDir & "\libvlccore.dll") Then Return 0
	Local $iMachine = __VLC_GetPEMachine($sDir & "\libvlc.dll")
	If @AutoItX64 Then Return ($iMachine = 0x8664) ? 1 : 2
	Return ($iMachine = 0x014C) ? 1 : 2
EndFunc   ;==>__VLC_CheckDir

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __VLC_GetPEMachine
; Description ...: Reads the machine type of a PE file (0x14C = x86, 0x8664 = x64, 0xAA64 = ARM64), 0 on error.
; ===============================================================================================================================
Func __VLC_GetPEMachine($sFile)
	Local $hFile = FileOpen($sFile, 16)
	If $hFile = -1 Then Return 0
	Local $bHead = FileRead($hFile, 4096)
	FileClose($hFile)
	If BinaryLen($bHead) < 64 Then Return 0
	Local $tHead = DllStructCreate("byte[" & BinaryLen($bHead) & "]")
	DllStructSetData($tHead, 1, $bHead)
	Local $pHead = DllStructGetPtr($tHead)
	If DllStructGetData(DllStructCreate("word", $pHead), 1) <> 0x5A4D Then Return 0 ; "MZ"
	Local $iPE = DllStructGetData(DllStructCreate("dword", Ptr($pHead + 0x3C)), 1)
	If $iPE < 64 Or $iPE + 6 > BinaryLen($bHead) Then Return 0
	If DllStructGetData(DllStructCreate("dword", Ptr($pHead + $iPE)), 1) <> 0x00004550 Then Return 0 ; "PE\0\0"
	Return DllStructGetData(DllStructCreate("word", Ptr($pHead + $iPE + 4)), 1)
EndFunc   ;==>__VLC_GetPEMachine
#EndRegion Internal: loading

#Region Internal: native helpers, event bridge, worker thread

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __VLC_NativeInit
; Description ...: Creates the executable thunk page and the hidden event window (once per process).
; ===============================================================================================================================
Func __VLC_NativeInit()
	If $__g_pVLC_Code <> 0 Then Return True
	Local $bCode = @AutoItX64 ? $__g_bVLC_ThunkX64 : $__g_bVLC_ThunkX86
	Local $aMem = DllCall("kernel32.dll", "ptr", "VirtualAlloc", "ptr", 0, "ulong_ptr", 4096, "dword", 0x3000, "dword", 0x04)
	If @error Or $aMem[0] = 0 Then Return SetError($VLC_ERR_NATIVE, 0, __VLC_ErrRet(False, "VirtualAlloc failed"))
	Local $pMem = $aMem[0]
	DllStructSetData(DllStructCreate("byte[" & BinaryLen($bCode) & "]", $pMem), 1, $bCode)
	Local $aProt = DllCall("kernel32.dll", "bool", "VirtualProtect", "ptr", $pMem, "ulong_ptr", 4096, "dword", 0x20, "dword*", 0)
	If @error Or Not $aProt[0] Then Return SetError($VLC_ERR_NATIVE, 0, __VLC_ErrRet(False, "VirtualProtect failed"))
	DllCall("kernel32.dll", "bool", "FlushInstructionCache", "handle", -1, "ptr", $pMem, "ulong_ptr", 4096)

	Local $aK32 = DllCall("kernel32.dll", "handle", "GetModuleHandleW", "wstr", "kernel32.dll")
	Local $aU32 = DllCall("kernel32.dll", "handle", "LoadLibraryW", "wstr", "user32.dll")
	If @error Or $aK32[0] = 0 Or $aU32[0] = 0 Then Return SetError($VLC_ERR_NATIVE, 0, __VLC_ErrRet(False, "system modules not found"))
	Local $aHA = DllCall("kernel32.dll", "ptr", "GetProcAddress", "handle", $aK32[0], "str", "HeapAlloc")
	Local $aHF = DllCall("kernel32.dll", "ptr", "GetProcAddress", "handle", $aK32[0], "str", "HeapFree")
	Local $aPM = DllCall("kernel32.dll", "ptr", "GetProcAddress", "handle", $aU32[0], "str", "PostMessageW")
	Local $aHeap = DllCall("kernel32.dll", "handle", "GetProcessHeap")
	If $aHA[0] = 0 Or $aHF[0] = 0 Or $aPM[0] = 0 Or $aHeap[0] = 0 Then Return SetError($VLC_ERR_NATIVE, 0, __VLC_ErrRet(False, "GetProcAddress failed"))

	; message-only window (HWND_MESSAGE) owned by the AutoIt thread. Its window procedure is an AutoIt callback,
	; so the events are processed on the AutoIt thread whenever AutoIt pumps messages (Sleep, GUIGetMsg, idle).
	; No AutoIt GUI is created: GUIRegisterMsg() and the "current GUI" of the script are not touched.
	Local $aWnd = DllCall("user32.dll", "hwnd", "CreateWindowExW", "dword", 0, "wstr", "STATIC", "wstr", "CCLibVLC events", _
			"dword", 0, "int", 0, "int", 0, "int", 0, "int", 0, "hwnd", Ptr(-3), "ptr", 0, "ptr", 0, "ptr", 0)
	If @error Or $aWnd[0] = 0 Then Return SetError($VLC_ERR_NATIVE, 0, __VLC_ErrRet(False, "event window could not be created"))
	Local $hWnd = $aWnd[0]
	$__g_hVLC_WndProc = DllCallbackRegister("__VLC_WndProc", "lresult", "hwnd;uint;wparam;lparam")
	Local $aOld = DllCall("user32.dll", "long_ptr", @AutoItX64 ? "SetWindowLongPtrW" : "SetWindowLongW", "hwnd", $hWnd, "int", -4, _
			"long_ptr", DllCallbackGetPtr($__g_hVLC_WndProc))
	If @error Or $aOld[0] = 0 Then Return SetError($VLC_ERR_NATIVE, 0, __VLC_ErrRet(False, "event window could not be subclassed"))
	$__g_pVLC_OldWndProc = $aOld[0]

	$__g_pVLC_HeapAlloc = $aHA[0]
	$__g_pVLC_HeapFree = $aHF[0]
	$__g_pVLC_PostMessage = $aPM[0]
	$__g_hVLC_Heap = $aHeap[0]
	$__g_hVLC_EventWnd = $hWnd
	$__g_pVLC_Code = $pMem
	Return True
EndFunc   ;==>__VLC_NativeInit

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __VLC_GetCurrentGUI
; Description ...: Returns the handle of the current AutoIt GUI (the one GUICtrlCreate* would use), 0 if none.
; ===============================================================================================================================
Func __VLC_GetCurrentGUI()
	Local $idLbl = GUICtrlCreateLabel("", 0, 0, 0, 0)
	If $idLbl = 0 Then Return 0
	Local $aParent = DllCall("user32.dll", "hwnd", "GetParent", "hwnd", GUICtrlGetHandle($idLbl))
	GUICtrlDelete($idLbl)
	If @error Then Return 0
	Return $aParent[0]
EndFunc   ;==>__VLC_GetCurrentGUI

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __VLC_RunOnWorker
; Description ...: Calls the libVLC function void f(void *[, void *]) on a worker thread and waits while pumping messages.
; ===============================================================================================================================
Func __VLC_RunOnWorker($sFunc, $pArg, $iTimeout, $pArg2 = Default)
	If $__g_hVLC_Dll = -1 Then Return SetError($VLC_ERR_NOT_STARTED, 0, False)
	; a previous call for this object is still running (timed out): do not queue more blocking calls
	If _VLC_PlayerIsBusy($pArg) Then Return SetError($VLC_ERR_STATE, 0, __VLC_ErrRet(False, "a previous stop/release of this object is still running"))
	Local $pFunc = 0
	If $__g_hVLC_Module <> 0 Then
		Local $aProc = DllCall("kernel32.dll", "ptr", "GetProcAddress", "handle", $__g_hVLC_Module, "str", $sFunc)
		If Not @error Then $pFunc = $aProc[0]
	EndIf
	Local $hThread = 0, $tCtx = 0
	If $pFunc <> 0 And $__g_pVLC_Code <> 0 Then
		$tCtx = DllStructCreate("ptr pFunc;ptr pArg;ptr pArg2")
		DllStructSetData($tCtx, "pFunc", $pFunc)
		DllStructSetData($tCtx, "pArg", $pArg)
		DllStructSetData($tCtx, "pArg2", IsKeyword($pArg2) ? 0 : $pArg2)
		Local $aTh = DllCall("kernel32.dll", "handle", "CreateThread", "ptr", 0, "ulong_ptr", 0, _
				"ptr", Ptr($__g_pVLC_Code + $__VLC_THUNK_WORKER), "struct*", $tCtx, "dword", 0, "dword*", 0)
		If Not @error Then $hThread = $aTh[0]
	EndIf
	If $hThread = 0 Then
		; fallback: call directly (still correct, only the deadlock protection is missing)
		If IsKeyword($pArg2) Then
			DllCall($__g_hVLC_Dll, "none:cdecl", $sFunc, "ptr", $pArg)
		Else
			DllCall($__g_hVLC_Dll, "none:cdecl", $sFunc, "ptr", $pArg, "ptr", $pArg2)
		EndIf
		If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
		Return True
	EndIf
	Local $hTimer = TimerInit()
	While 1
		Local $aWait = DllCall($__g_hVLC_K32, "dword", "WaitForSingleObject", "handle", $hThread, "dword", 0)
		If @error Or $aWait[0] <> 0x102 Then ExitLoop ; signalled (0) or failed
		If $iTimeout >= 0 And TimerDiff($hTimer) > $iTimeout Then
			__VLC_KeepAlive($tCtx) ; the thread may still read it
			; remember the thread: the object counts as busy until it has finished (see _VLC_PlayerIsBusy)
			Local $n = $__g_aVLC_Busy[0][0] + 1
			ReDim $__g_aVLC_Busy[$n + 1][2]
			$__g_aVLC_Busy[$n][0] = Ptr($pArg)
			$__g_aVLC_Busy[$n][1] = $hThread
			$__g_aVLC_Busy[0][0] = $n
			Return SetError($VLC_ERR_TIMEOUT, 0, __VLC_ErrRet(False, $sFunc & "() did not return within " & $iTimeout & " ms"))
		EndIf
		Sleep(10)
	WEnd
	DllCall("kernel32.dll", "bool", "CloseHandle", "handle", $hThread)
	Return True
EndFunc   ;==>__VLC_RunOnWorker

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __VLC_WndProc
; Description ...: Window procedure of the event window.
; ===============================================================================================================================
Func __VLC_WndProc($hWnd, $iMsg, $wParam, $lParam)
	If $iMsg = $VLC_WM_EVENT Then Return __VLC_WM_EVENT($wParam, $lParam)
	Local $aRet = DllCall($__g_hVLC_U32, "lresult", "CallWindowProcW", "ptr", $__g_pVLC_OldWndProc, "hwnd", $hWnd, "uint", $iMsg, _
			"wparam", $wParam, "lparam", $lParam)
	If @error Then Return 0
	Return $aRet[0]
EndFunc   ;==>__VLC_WndProc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __VLC_WM_EVENT
; Description ...: Receives the events posted by the native thunk: copies them into the queue, frees the heap block.
; ===============================================================================================================================
Func __VLC_WM_EVENT($wParam, $lParam)
	If $wParam = 0 Then Return 0
	Local $pRec = Ptr($wParam)
	Local $iOff = @AutoItX64 ? 16 : 8
	Local $iType = DllStructGetData(DllStructCreate("int", $pRec), 1)
	Local $pObj = DllStructGetData(DllStructCreate("ptr", Ptr($pRec + (@AutoItX64 ? 8 : 4))), 1)
	Local $aVal = __VLC_EventDecode($iType, Ptr($pRec + $iOff))
	DllCall("kernel32.dll", "bool", "HeapFree", "handle", $__g_hVLC_Heap, "dword", 0, "ptr", $pRec)
	__VLC_InboxAdd(Int($lParam), $iType, $aVal[0], $aVal[1], $pObj)
	Return 0
EndFunc   ;==>__VLC_WM_EVENT

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __VLC_InboxAdd
; Description ...: Window procedure side of the inbox (see the globals): appends an event. Frequent events
;                  (time/position/buffering) replace the newest entry if it has the same subscription and type and the
;                  reader has not reached it yet. If the inbox is full (pump stalled for a long time, e.g. by a MsgBox),
;                  the event is dropped and counted.
; ===============================================================================================================================
Func __VLC_InboxAdd($iSub, $iType, $v1, $v2, $pObj)
	Local $iTail = $__g_iVLC_InboxTail
	If $iType = $libvlc_MediaPlayerTimeChanged Or $iType = $libvlc_MediaPlayerPositionChanged Or $iType = $libvlc_MediaPlayerBuffering Then
		; the reader cannot run while this code runs; entries after the head are not being read
		If $iTail - 1 > $__g_iVLC_InboxHead Then
			Local $iLast = Mod($iTail - 1, $__VLC_INBOX_SIZE)
			If $__g_aVLC_Inbox[$iLast][0] = $iSub And $__g_aVLC_Inbox[$iLast][1] = $iType Then
				$__g_aVLC_Inbox[$iLast][2] = $v1
				Return
			EndIf
		EndIf
	EndIf
	If $iTail - $__g_iVLC_InboxHead >= $__VLC_INBOX_SIZE Then
		$__g_iVLC_InboxDropped += 1
		Return
	EndIf
	Local $iSlot = Mod($iTail, $__VLC_INBOX_SIZE)
	$__g_aVLC_Inbox[$iSlot][0] = $iSub
	$__g_aVLC_Inbox[$iSlot][1] = $iType
	$__g_aVLC_Inbox[$iSlot][2] = $v1
	$__g_aVLC_Inbox[$iSlot][3] = $v2
	$__g_aVLC_Inbox[$iSlot][4] = $pObj
	$__g_iVLC_InboxTail = $iTail + 1 ; publish the entry (last statement)
EndFunc   ;==>__VLC_InboxAdd

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __VLC_InboxDrain
; Description ...: Script side of the inbox: moves all published entries into the queue. Call only with
;                  $__g_bVLC_InPump set (pump, polling), never from the window procedure.
; ===============================================================================================================================
Func __VLC_InboxDrain()
	Local $iTail = $__g_iVLC_InboxTail, $iSlot
	While $__g_iVLC_InboxHead < $iTail
		$iSlot = Mod($__g_iVLC_InboxHead, $__VLC_INBOX_SIZE)
		__VLC_QueueAdd($__g_aVLC_Inbox[$iSlot][0], $__g_aVLC_Inbox[$iSlot][1], $__g_aVLC_Inbox[$iSlot][2], _
				$__g_aVLC_Inbox[$iSlot][3], $__g_aVLC_Inbox[$iSlot][4])
		$__g_aVLC_Inbox[$iSlot][2] = "" ; release references (e.g. strings) early
		$__g_aVLC_Inbox[$iSlot][4] = 0
		$__g_iVLC_InboxHead += 1
	WEnd
EndFunc   ;==>__VLC_InboxDrain

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __VLC_EventDecode
; Description ...: Decodes the union of libvlc_event_t. Returns [value1, value2].
; ===============================================================================================================================
Func __VLC_EventDecode($iType, $pU)
	Local $aVal[2] = ["", ""]
	Switch $iType
		Case $libvlc_MediaPlayerTimeChanged, $libvlc_MediaPlayerLengthChanged, $libvlc_MediaDurationChanged
			$aVal[0] = DllStructGetData(DllStructCreate("int64", $pU), 1)
		Case $libvlc_MediaPlayerPositionChanged, $libvlc_MediaPlayerBuffering, $libvlc_MediaPlayerAudioVolume
			$aVal[0] = DllStructGetData(DllStructCreate("float", $pU), 1)
		Case $libvlc_MediaMetaChanged, $libvlc_MediaParsedChanged, $libvlc_MediaStateChanged, _
				$libvlc_MediaPlayerChapterChanged, $libvlc_MediaPlayerTitleChanged, $libvlc_MediaPlayerSeekableChanged, _
				$libvlc_MediaPlayerPausableChanged, $libvlc_MediaPlayerScrambledChanged, $libvlc_MediaPlayerVout
			$aVal[0] = DllStructGetData(DllStructCreate("int", $pU), 1)
		Case $libvlc_MediaPlayerESAdded, $libvlc_MediaPlayerESDeleted, $libvlc_MediaPlayerESSelected
			Local $tEs = DllStructCreate("int;int", $pU)
			$aVal[0] = DllStructGetData($tEs, 1)
			$aVal[1] = DllStructGetData($tEs, 2)
		Case $libvlc_MediaListItemAdded, $libvlc_MediaListWillAddItem, $libvlc_MediaListItemDeleted, _
				$libvlc_MediaListWillDeleteItem, $libvlc_MediaListViewItemAdded, $libvlc_MediaListViewWillAddItem, _
				$libvlc_MediaListViewItemDeleted, $libvlc_MediaListViewWillDeleteItem
			Local $tLi = DllStructCreate("ptr;int", $pU)
			$aVal[0] = DllStructGetData($tLi, 1)
			$aVal[1] = DllStructGetData($tLi, 2)
		Case $libvlc_MediaSubItemAdded, $libvlc_MediaFreed, $libvlc_MediaSubItemTreeAdded, $libvlc_MediaPlayerMediaChanged, _
				$libvlc_MediaListPlayerNextItemSet, $libvlc_RendererDiscovererItemAdded, $libvlc_RendererDiscovererItemDeleted
			$aVal[0] = DllStructGetData(DllStructCreate("ptr", $pU), 1)
	EndSwitch
	Return $aVal
EndFunc   ;==>__VLC_EventDecode

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __VLC_QueueAdd / __VLC_QueueRemove
; Description ...: Event queue handling, script code only. Time/position/buffering events replace the newest queue entry
;                  if it has the same subscription and type (only the newest, so the order of events is kept).
; ===============================================================================================================================
Func __VLC_QueueAdd($iSub, $iType, $v1, $v2, $pObj)
	Local $n = $__g_aVLC_Queue[0][0]
	If $n > 0 And ($iType = $libvlc_MediaPlayerTimeChanged Or $iType = $libvlc_MediaPlayerPositionChanged Or $iType = $libvlc_MediaPlayerBuffering) Then
		If $__g_aVLC_Queue[$n][0] = $iSub And $__g_aVLC_Queue[$n][1] = $iType Then
			$__g_aVLC_Queue[$n][2] = $v1
			Return
		EndIf
	EndIf
	If $n >= $__VLC_QUEUE_MAX Then __VLC_QueueRemove(1) ; never grow without limit
	$n = $__g_aVLC_Queue[0][0] + 1
	If $n >= UBound($__g_aVLC_Queue) Then ReDim $__g_aVLC_Queue[$n + 32][5]
	$__g_aVLC_Queue[$n][0] = $iSub
	$__g_aVLC_Queue[$n][1] = $iType
	$__g_aVLC_Queue[$n][2] = $v1
	$__g_aVLC_Queue[$n][3] = $v2
	$__g_aVLC_Queue[$n][4] = $pObj
	$__g_aVLC_Queue[0][0] = $n
EndFunc   ;==>__VLC_QueueAdd

Func __VLC_QueueRemove($iIndex)
	Local $n = $__g_aVLC_Queue[0][0]
	If $iIndex < 1 Or $iIndex > $n Then Return
	For $i = $iIndex To $n - 1
		For $c = 0 To 4
			$__g_aVLC_Queue[$i][$c] = $__g_aVLC_Queue[$i + 1][$c]
		Next
	Next
	$__g_aVLC_Queue[0][0] = $n - 1
EndFunc   ;==>__VLC_QueueRemove

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __VLC_EventPump
; Description ...: Adlib function delivering queued events to the callbacks.
; ===============================================================================================================================
Func __VLC_EventPump()
	If $__g_iVLC_InboxHead <> $__g_iVLC_InboxTail Or $__g_aVLC_Queue[0][0] > 0 Then _VLC_EventsProcess()
EndFunc   ;==>__VLC_EventPump

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __VLC_OnExit
; Description ...: OnAutoItExit handler: releases libVLC so no VLC thread outlives the AutoIt objects it uses.
; ===============================================================================================================================
Func __VLC_OnExit()
	If $__g_pVLC_Instance <> 0 Then _VLC_Shutdown(3000)
EndFunc   ;==>__VLC_OnExit
#EndRegion Internal: native helpers, event bridge, worker thread
