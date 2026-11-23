#include-once
; SPDX-License-Identifier: GPL-3.0-or-later
; =============================================================================================================
; Title .........: CCLibVLC_Raw
; AutoIt Version : 3.3.14.5+
; Language ......: English
; Description ...: Raw 1:1 wrappers for every exported libVLC 3.0.24 function (cdecl, UTF-8, x86/x64).
;                  GENERATED FILE - do not edit. Regenerate with tools/generate_raw.py.
; Author(s) .....: Markus Debus, CITRO Computer
; Generated .....: 2026-11-22 from VLC 3.0.24 headers, 266 functions
; Remarks .......: Include CCLibVLC.au3 instead of this file. All wrappers need _VLC_Startup() first.
;                  Naming: C function libvlc_xxx  ->  AutoIt function _libvlc_xxx
;                  - pointer parameters accept Ptr, Hwnd, numbers or DllStructs
;                  - string parameters take AutoIt strings (converted to UTF-8), Null/Default = NULL
;                  - string results are converted from UTF-8; "char *" results are freed with libvlc_free
;                  - C out parameters (int *, unsigned *, T ***) are ByRef parameters
;                  - void functions return True on success
;                  - DllCall failures: @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
; =============================================================================================================

; Functions intentionally not wrapped:
;   libvlc_vprinterr                              va_list, not callable from AutoIt
;   libvlc_printerr                               printf-style varargs, not callable from AutoIt
;   libvlc_new                                    handwritten in CCLibVLC.au3 (argv array): _libvlc_new()
;   libvlc_log_get_context                        only valid inside a libvlc_log_set callback
;   libvlc_log_get_object                         only valid inside a libvlc_log_set callback
;   libvlc_log_set                                callback receives a va_list and runs on VLC threads; use libvlc_new options --file-logging --logfile=<path>
;   libvlc_log_set_file                           needs a C runtime FILE* of the CRT VLC was built with; use --file-logging --logfile=<path>
;   libvlc_media_player_set_nsobject              macOS only
;   libvlc_media_player_get_nsobject              macOS only
;   libvlc_media_player_set_xwindow               X11 only
;   libvlc_media_player_get_xwindow               X11 only
;   libvlc_media_player_set_android_context       Android only
;   libvlc_media_player_set_evas_object           Tizen only, not exported on Windows
;   libvlc_vlm_get_media_instance_title           not exported by libvlc.dll (static inline or internal)
;   libvlc_vlm_get_media_instance_chapter         not exported by libvlc.dll (static inline or internal)
;   libvlc_vlm_get_media_instance_seekable        not exported by libvlc.dll (static inline or internal)

#Region libvlc.h

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_errmsg
; Description ...: A human-readable error message for the last LibVLC error in the calling thread.
; Syntax ........: _libvlc_errmsg()
; Parameters ....: None
; Return values .: Success - string
;                            A NULL result is returned as "" with @extended = 1.
;                  Failure - "", sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: const char * libvlc_errmsg(void)
;                  Warning: This will be NULL if there was no error.
; Related .......:
; Link ..........: include/vlc/libvlc.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_errmsg()
	If $__g_pVLC_Instance = 0 Then Return "" ; no instance: libVLC TLS not initialised
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_errmsg")
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, "")
	Local $__sRet = __VLC_StrFromPtr($__aCall[0], False)
	Return SetExtended(@extended, $__sRet)
EndFunc   ;==>_libvlc_errmsg

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_clearerr
; Description ...: Clears the LibVLC error status for the current thread.
; Syntax ........: _libvlc_clearerr()
; Parameters ....: None
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_clearerr(void)
; Related .......:
; Link ..........: include/vlc/libvlc.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_clearerr()
	If $__g_pVLC_Instance = 0 Then Return True ; no instance: libVLC TLS not initialised
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_clearerr")
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_clearerr

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_release
; Description ...: Decrement the reference count of a libvlc instance, and destroy it if it reaches zero.
; Syntax ........: _libvlc_release($p_instance)
; Parameters ....: $p_instance          - libvlc_instance_t * : the instance to destroy
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_instance is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_release(libvlc_instance_t * p_instance)
; Related .......:
; Link ..........: include/vlc/libvlc.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_release($p_instance)
	If __VLC_Ptr($p_instance) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_release", "ptr", __VLC_Ptr($p_instance))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_release

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_retain
; Description ...: Increments the reference count of a libvlc instance.
; Syntax ........: _libvlc_retain($p_instance)
; Parameters ....: $p_instance          - libvlc_instance_t * : the instance to reference
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_instance is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_retain(libvlc_instance_t * p_instance)
; Related .......:
; Link ..........: include/vlc/libvlc.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_retain($p_instance)
	If __VLC_Ptr($p_instance) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_retain", "ptr", __VLC_Ptr($p_instance))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_retain

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_add_intf
; Description ...: Try to start a user interface for the libvlc instance.
; Syntax ........: _libvlc_add_intf($p_instance, $name)
; Parameters ....: $p_instance          - libvlc_instance_t * : the instance
;                  $name                - const char * : interface name, or NULL for default (string (UTF-8 converted automatically,
;                                       - Null/Default = NULL))
; Return values .: Success - int: 0 on success, -1 on error.
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_instance is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_add_intf(libvlc_instance_t * p_instance, const char * name)
; Related .......:
; Link ..........: include/vlc/libvlc.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_add_intf($p_instance, $name)
	If __VLC_Ptr($p_instance) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__tStr2 = __VLC_Utf8Struct($name)
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_add_intf", "ptr", __VLC_Ptr($p_instance), "ptr", __VLC_Ptr($__tStr2))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_add_intf

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_set_exit_handler
; Description ...: Registers a callback for the LibVLC exit event.
; Syntax ........: _libvlc_set_exit_handler($p_instance, $cb, $opaque)
; Parameters ....: $p_instance          - libvlc_instance_t * : LibVLC instance
;                  $cb                  - fnptr : callback to invoke when LibVLC wants to exit, or NULL to disable the exit handler
;                                       - (as by default)
;                  $opaque              - void * : data pointer for the callback
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_instance is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_set_exit_handler(libvlc_instance_t * p_instance, void (*cb)(void *), void *
;                  opaque)
;                  Note: This function should be called before the playlist or interface are started. Otherwise,
;                  there is a small race condition: the exit event could be raised before the handler is
;                  registered.
;                  Warning: This function and libvlc_wait() cannot be used at the same time.
; Related .......:
; Link ..........: include/vlc/libvlc.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_set_exit_handler($p_instance, $cb, $opaque)
	If __VLC_Ptr($p_instance) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_set_exit_handler", "ptr", __VLC_Ptr($p_instance), "ptr", __VLC_Ptr($cb), "ptr", __VLC_Ptr($opaque))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_set_exit_handler

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_set_user_agent
; Description ...: Sets the application name.
; Syntax ........: _libvlc_set_user_agent($p_instance, $name, $http)
; Parameters ....: $p_instance          - libvlc_instance_t * : LibVLC instance
;                  $name                - const char * : human-readable application name, e.g. "FooBar player 1.2.3" (string (UTF-8
;                                       - converted automatically, Null/Default = NULL))
;                  $http                - const char * : HTTP User Agent, e.g. "FooBar/1.2.3 Python/2.6.0" (string (UTF-8 converted
;                                       - automatically, Null/Default = NULL))
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_instance is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_set_user_agent(libvlc_instance_t * p_instance, const char * name, const char *
;                  http)
;                  Version: LibVLC 1.1.1 or later
; Related .......:
; Link ..........: include/vlc/libvlc.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_set_user_agent($p_instance, $name, $http)
	If __VLC_Ptr($p_instance) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	Local $__tStr2 = __VLC_Utf8Struct($name)
	Local $__tStr3 = __VLC_Utf8Struct($http)
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_set_user_agent", "ptr", __VLC_Ptr($p_instance), "ptr", __VLC_Ptr($__tStr2), "ptr", __VLC_Ptr($__tStr3))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_set_user_agent

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_set_app_id
; Description ...: Sets some meta-information about the application.
; Syntax ........: _libvlc_set_app_id($p_instance, $id, $version, $icon)
; Parameters ....: $p_instance          - libvlc_instance_t * : LibVLC instance
;                  $id                  - const char * : Java-style application identifier, e.g. "com.acme.foobar" (string (UTF-8
;                                       - converted automatically, Null/Default = NULL))
;                  $version             - const char * : application version numbers, e.g. "1.2.3" (string (UTF-8 converted
;                                       - automatically, Null/Default = NULL))
;                  $icon                - const char * : application icon name, e.g. "foobar" (string (UTF-8 converted
;                                       - automatically, Null/Default = NULL))
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_instance is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_set_app_id(libvlc_instance_t * p_instance, const char * id, const char *
;                  version, const char * icon)
;                  Version: LibVLC 2.1.0 or later.
; Related .......:
; Link ..........: include/vlc/libvlc.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_set_app_id($p_instance, $id, $version, $icon)
	If __VLC_Ptr($p_instance) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	Local $__tStr2 = __VLC_Utf8Struct($id)
	Local $__tStr3 = __VLC_Utf8Struct($version)
	Local $__tStr4 = __VLC_Utf8Struct($icon)
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_set_app_id", "ptr", __VLC_Ptr($p_instance), "ptr", __VLC_Ptr($__tStr2), "ptr", __VLC_Ptr($__tStr3), "ptr", __VLC_Ptr($__tStr4))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_set_app_id

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_get_version
; Description ...: Retrieve libvlc version.
; Syntax ........: _libvlc_get_version()
; Parameters ....: None
; Return values .: Success - string: a string containing the libvlc version
;                            A NULL result is returned as "" with @extended = 1.
;                  Failure - "", sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: const char * libvlc_get_version(void)
; Related .......:
; Link ..........: include/vlc/libvlc.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_get_version()
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_get_version")
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, "")
	Local $__sRet = __VLC_StrFromPtr($__aCall[0], False)
	Return SetExtended(@extended, $__sRet)
EndFunc   ;==>_libvlc_get_version

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_get_compiler
; Description ...: Retrieve libvlc compiler version.
; Syntax ........: _libvlc_get_compiler()
; Parameters ....: None
; Return values .: Success - string: a string containing the libvlc compiler version
;                            A NULL result is returned as "" with @extended = 1.
;                  Failure - "", sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: const char * libvlc_get_compiler(void)
; Related .......:
; Link ..........: include/vlc/libvlc.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_get_compiler()
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_get_compiler")
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, "")
	Local $__sRet = __VLC_StrFromPtr($__aCall[0], False)
	Return SetExtended(@extended, $__sRet)
EndFunc   ;==>_libvlc_get_compiler

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_get_changeset
; Description ...: Retrieve libvlc changeset.
; Syntax ........: _libvlc_get_changeset()
; Parameters ....: None
; Return values .: Success - string: a string containing the libvlc changeset
;                            A NULL result is returned as "" with @extended = 1.
;                  Failure - "", sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: const char * libvlc_get_changeset(void)
; Related .......:
; Link ..........: include/vlc/libvlc.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_get_changeset()
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_get_changeset")
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, "")
	Local $__sRet = __VLC_StrFromPtr($__aCall[0], False)
	Return SetExtended(@extended, $__sRet)
EndFunc   ;==>_libvlc_get_changeset

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_free
; Description ...: Frees an heap allocation returned by a LibVLC function.
; Syntax ........: _libvlc_free($ptr)
; Parameters ....: $ptr                 - void * : the pointer
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_free(void * ptr)
; Related .......:
; Link ..........: include/vlc/libvlc.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_free($ptr)
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_free", "ptr", __VLC_Ptr($ptr))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_free

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_event_attach
; Description ...: Register for an event notification.
; Syntax ........: _libvlc_event_attach($p_event_manager, $i_event_type, $f_callback, $user_data)
; Parameters ....: $p_event_manager     - libvlc_event_manager_t * : the event manager to which you want to attach to. Generally it
;                                       - is obtained by vlc_my_object_event_manager() where my_object is the object you want to
;                                       - listen to.
;                  $i_event_type        - libvlc_event_type_t : the desired event to which we want to listen
;                  $f_callback          - libvlc_callback_t : the function to call when i_event_type occurs
;                  $user_data           - void * : user provided data to carry with the event
; Return values .: Success - int: 0 on success, ENOMEM on error
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_event_manager is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_event_attach(libvlc_event_manager_t * p_event_manager, libvlc_event_type_t
;                  i_event_type, libvlc_callback_t f_callback, void * user_data)
; Related .......:
; Link ..........: include/vlc/libvlc.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_event_attach($p_event_manager, $i_event_type, $f_callback, $user_data)
	If __VLC_Ptr($p_event_manager) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_event_attach", "ptr", __VLC_Ptr($p_event_manager), "int", $i_event_type, "ptr", __VLC_Ptr($f_callback), "ptr", __VLC_Ptr($user_data))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_event_attach

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_event_detach
; Description ...: Unregister an event notification.
; Syntax ........: _libvlc_event_detach($p_event_manager, $i_event_type, $f_callback, $p_user_data)
; Parameters ....: $p_event_manager     - libvlc_event_manager_t * : the event manager
;                  $i_event_type        - libvlc_event_type_t : the desired event to which we want to unregister
;                  $f_callback          - libvlc_callback_t : the function to call when i_event_type occurs
;                  $p_user_data         - void * : user provided data to carry with the event
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_event_manager is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_event_detach(libvlc_event_manager_t * p_event_manager, libvlc_event_type_t
;                  i_event_type, libvlc_callback_t f_callback, void * p_user_data)
; Related .......:
; Link ..........: include/vlc/libvlc.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_event_detach($p_event_manager, $i_event_type, $f_callback, $p_user_data)
	If __VLC_Ptr($p_event_manager) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_event_detach", "ptr", __VLC_Ptr($p_event_manager), "int", $i_event_type, "ptr", __VLC_Ptr($f_callback), "ptr", __VLC_Ptr($p_user_data))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_event_detach

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_event_type_name
; Description ...: Get an event's type name.
; Syntax ........: _libvlc_event_type_name($event_type)
; Parameters ....: $event_type          - libvlc_event_type_t : the desired event
; Return values .: Success - string
;                            A NULL result is returned as "" with @extended = 1.
;                  Failure - "", sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: const char * libvlc_event_type_name(libvlc_event_type_t event_type)
; Related .......:
; Link ..........: include/vlc/libvlc.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_event_type_name($event_type)
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_event_type_name", "int", $event_type)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, "")
	Local $__sRet = __VLC_StrFromPtr($__aCall[0], False)
	Return SetExtended(@extended, $__sRet)
EndFunc   ;==>_libvlc_event_type_name

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_log_unset
; Description ...: Unsets the logging callback.
; Syntax ........: _libvlc_log_unset($p_instance)
; Parameters ....: $p_instance          - libvlc_instance_t * : libvlc instance
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_instance is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_log_unset(libvlc_instance_t * p_instance)
;                  Version: LibVLC 2.1.0 or later
;                  Note: This function will wait for any pending callbacks invocation to complete (causing a
;                  deadlock if called from within the callback).
; Related .......:
; Link ..........: include/vlc/libvlc.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_log_unset($p_instance)
	If __VLC_Ptr($p_instance) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_log_unset", "ptr", __VLC_Ptr($p_instance))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_log_unset

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_module_description_list_release
; Description ...: Release a list of module descriptions.
; Syntax ........: _libvlc_module_description_list_release($p_list)
; Parameters ....: $p_list              - libvlc_module_description_t * : the list to be released
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_module_description_list_release(libvlc_module_description_t * p_list)
; Related .......:
; Link ..........: include/vlc/libvlc.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_module_description_list_release($p_list)
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_module_description_list_release", "ptr", __VLC_Ptr($p_list))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_module_description_list_release

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_audio_filter_list_get
; Description ...: Returns a list of audio filters that are available.
; Syntax ........: _libvlc_audio_filter_list_get($p_instance)
; Parameters ....: $p_instance          - libvlc_instance_t * : libvlc instance
; Return values .: Success - pointer: a list of module descriptions. It should be freed with
;                  libvlc_module_description_list_release(). In case of an error, NULL is returned.
;                  Failure - Ptr(0), sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_instance is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: libvlc_module_description_t * libvlc_audio_filter_list_get(libvlc_instance_t * p_instance)
; Related .......:
; Link ..........: include/vlc/libvlc.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_audio_filter_list_get($p_instance)
	If __VLC_Ptr($p_instance) = 0 Then Return SetError($VLC_ERR_PARAM, 0, Ptr(0)) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_audio_filter_list_get", "ptr", __VLC_Ptr($p_instance))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, Ptr(0))
	Return $__aCall[0]
EndFunc   ;==>_libvlc_audio_filter_list_get

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_video_filter_list_get
; Description ...: Returns a list of video filters that are available.
; Syntax ........: _libvlc_video_filter_list_get($p_instance)
; Parameters ....: $p_instance          - libvlc_instance_t * : libvlc instance
; Return values .: Success - pointer: a list of module descriptions. It should be freed with
;                  libvlc_module_description_list_release(). In case of an error, NULL is returned.
;                  Failure - Ptr(0), sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_instance is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: libvlc_module_description_t * libvlc_video_filter_list_get(libvlc_instance_t * p_instance)
; Related .......:
; Link ..........: include/vlc/libvlc.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_video_filter_list_get($p_instance)
	If __VLC_Ptr($p_instance) = 0 Then Return SetError($VLC_ERR_PARAM, 0, Ptr(0)) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_video_filter_list_get", "ptr", __VLC_Ptr($p_instance))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, Ptr(0))
	Return $__aCall[0]
EndFunc   ;==>_libvlc_video_filter_list_get

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_clock
; Description ...: Return the current time as defined by LibVLC.
; Syntax ........: _libvlc_clock()
; Parameters ....: None
; Return values .: Success - int64
;                  Failure - 0, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int64_t libvlc_clock(void)
;                  Note: On systems that support it, the POSIX monotonic clock is used.
; Related .......:
; Link ..........: include/vlc/libvlc.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_clock()
	Local $__aCall = DllCall($__g_hVLC_Dll, "int64:cdecl", "libvlc_clock")
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, 0)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_clock

#EndRegion libvlc.h

#Region libvlc_renderer_discoverer.h

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_renderer_item_hold
; Description ...: Hold a renderer item, i.e.
; Syntax ........: _libvlc_renderer_item_hold($p_item)
; Parameters ....: $p_item              - libvlc_renderer_item_t *
; Return values .: Success - pointer: the current item
;                  Failure - Ptr(0), sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_item is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: libvlc_renderer_item_t * libvlc_renderer_item_hold(libvlc_renderer_item_t * p_item)
;                  Version: LibVLC 3.0.0 or later
; Related .......:
; Link ..........: include/vlc/libvlc_renderer_discoverer.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_renderer_item_hold($p_item)
	If __VLC_Ptr($p_item) = 0 Then Return SetError($VLC_ERR_PARAM, 0, Ptr(0)) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_renderer_item_hold", "ptr", __VLC_Ptr($p_item))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, Ptr(0))
	Return $__aCall[0]
EndFunc   ;==>_libvlc_renderer_item_hold

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_renderer_item_release
; Description ...: Releases a renderer item, i.e.
; Syntax ........: _libvlc_renderer_item_release($p_item)
; Parameters ....: $p_item              - libvlc_renderer_item_t *
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_item is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_renderer_item_release(libvlc_renderer_item_t * p_item)
;                  Version: LibVLC 3.0.0 or later
; Related .......:
; Link ..........: include/vlc/libvlc_renderer_discoverer.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_renderer_item_release($p_item)
	If __VLC_Ptr($p_item) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_renderer_item_release", "ptr", __VLC_Ptr($p_item))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_renderer_item_release

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_renderer_item_name
; Description ...: Get the human readable name of a renderer item
; Syntax ........: _libvlc_renderer_item_name($p_item)
; Parameters ....: $p_item              - const libvlc_renderer_item_t *
; Return values .: Success - string: the name of the item (can't be NULL, must *not* be freed)
;                            A NULL result is returned as "" with @extended = 1.
;                  Failure - "", sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_item is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: const char * libvlc_renderer_item_name(const libvlc_renderer_item_t * p_item)
;                  Version: LibVLC 3.0.0 or later
; Related .......:
; Link ..........: include/vlc/libvlc_renderer_discoverer.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_renderer_item_name($p_item)
	If __VLC_Ptr($p_item) = 0 Then Return SetError($VLC_ERR_PARAM, 0, "") ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_renderer_item_name", "ptr", __VLC_Ptr($p_item))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, "")
	Local $__sRet = __VLC_StrFromPtr($__aCall[0], False)
	Return SetExtended(@extended, $__sRet)
EndFunc   ;==>_libvlc_renderer_item_name

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_renderer_item_type
; Description ...: Get the type (not translated) of a renderer item.
; Syntax ........: _libvlc_renderer_item_type($p_item)
; Parameters ....: $p_item              - const libvlc_renderer_item_t *
; Return values .: Success - string: the type of the item (can't be NULL, must *not* be freed)
;                            A NULL result is returned as "" with @extended = 1.
;                  Failure - "", sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_item is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: const char * libvlc_renderer_item_type(const libvlc_renderer_item_t * p_item)
;                  Version: LibVLC 3.0.0 or later
; Related .......:
; Link ..........: include/vlc/libvlc_renderer_discoverer.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_renderer_item_type($p_item)
	If __VLC_Ptr($p_item) = 0 Then Return SetError($VLC_ERR_PARAM, 0, "") ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_renderer_item_type", "ptr", __VLC_Ptr($p_item))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, "")
	Local $__sRet = __VLC_StrFromPtr($__aCall[0], False)
	Return SetExtended(@extended, $__sRet)
EndFunc   ;==>_libvlc_renderer_item_type

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_renderer_item_icon_uri
; Description ...: Get the icon uri of a renderer item
; Syntax ........: _libvlc_renderer_item_icon_uri($p_item)
; Parameters ....: $p_item              - const libvlc_renderer_item_t *
; Return values .: Success - string: the uri of the item's icon (can be NULL, must *not* be freed)
;                            A NULL result is returned as "" with @extended = 1.
;                  Failure - "", sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_item is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: const char * libvlc_renderer_item_icon_uri(const libvlc_renderer_item_t * p_item)
;                  Version: LibVLC 3.0.0 or later
; Related .......:
; Link ..........: include/vlc/libvlc_renderer_discoverer.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_renderer_item_icon_uri($p_item)
	If __VLC_Ptr($p_item) = 0 Then Return SetError($VLC_ERR_PARAM, 0, "") ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_renderer_item_icon_uri", "ptr", __VLC_Ptr($p_item))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, "")
	Local $__sRet = __VLC_StrFromPtr($__aCall[0], False)
	Return SetExtended(@extended, $__sRet)
EndFunc   ;==>_libvlc_renderer_item_icon_uri

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_renderer_item_flags
; Description ...: Get the flags of a renderer item
; Syntax ........: _libvlc_renderer_item_flags($p_item)
; Parameters ....: $p_item              - const libvlc_renderer_item_t *
; Return values .: Success - int: bitwise flag: capabilities of the renderer, see
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_item is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_renderer_item_flags(const libvlc_renderer_item_t * p_item)
;                  Version: LibVLC 3.0.0 or later
; Related .......:
; Link ..........: include/vlc/libvlc_renderer_discoverer.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_renderer_item_flags($p_item)
	If __VLC_Ptr($p_item) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_renderer_item_flags", "ptr", __VLC_Ptr($p_item))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_renderer_item_flags

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_renderer_discoverer_new
; Description ...: Create a renderer discoverer object by name After this object is created, you should attach to events in order to be notified of the discoverer events.
; Syntax ........: _libvlc_renderer_discoverer_new($p_inst, $psz_name)
; Parameters ....: $p_inst              - libvlc_instance_t * : libvlc instance
;                  $psz_name            - const char * : service name; use libvlc_renderer_discoverer_list_get() to get a list of
;                                       - the discoverer names available in this libVLC instance (string (UTF-8 converted
;                                       - automatically, Null/Default = NULL))
; Return values .: Success - pointer: media discover object or NULL in case of error
;                  Failure - Ptr(0), sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_inst is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: libvlc_renderer_discoverer_t * libvlc_renderer_discoverer_new(libvlc_instance_t * p_inst,
;                  const char * psz_name)
;                  Version: LibVLC 3.0.0 or later
; Related .......:
; Link ..........: include/vlc/libvlc_renderer_discoverer.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_renderer_discoverer_new($p_inst, $psz_name)
	If __VLC_Ptr($p_inst) = 0 Then Return SetError($VLC_ERR_PARAM, 0, Ptr(0)) ; NULL would crash libVLC
	Local $__tStr2 = __VLC_Utf8Struct($psz_name)
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_renderer_discoverer_new", "ptr", __VLC_Ptr($p_inst), "ptr", __VLC_Ptr($__tStr2))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, Ptr(0))
	Return $__aCall[0]
EndFunc   ;==>_libvlc_renderer_discoverer_new

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_renderer_discoverer_release
; Description ...: Release a renderer discoverer object
; Syntax ........: _libvlc_renderer_discoverer_release($p_rd)
; Parameters ....: $p_rd                - libvlc_renderer_discoverer_t * : renderer discoverer object
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_rd is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_renderer_discoverer_release(libvlc_renderer_discoverer_t * p_rd)
;                  Version: LibVLC 3.0.0 or later
; Related .......:
; Link ..........: include/vlc/libvlc_renderer_discoverer.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_renderer_discoverer_release($p_rd)
	If __VLC_Ptr($p_rd) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_renderer_discoverer_release", "ptr", __VLC_Ptr($p_rd))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_renderer_discoverer_release

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_renderer_discoverer_start
; Description ...: Start renderer discovery To stop it, call libvlc_renderer_discoverer_stop() or libvlc_renderer_discoverer_release() directly.
; Syntax ........: _libvlc_renderer_discoverer_start($p_rd)
; Parameters ....: $p_rd                - libvlc_renderer_discoverer_t * : renderer discoverer object
; Return values .: Success - int: -1 in case of error, 0 otherwise
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_rd is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_renderer_discoverer_start(libvlc_renderer_discoverer_t * p_rd)
;                  Version: LibVLC 3.0.0 or later
; Related .......:
; Link ..........: include/vlc/libvlc_renderer_discoverer.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_renderer_discoverer_start($p_rd)
	If __VLC_Ptr($p_rd) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_renderer_discoverer_start", "ptr", __VLC_Ptr($p_rd))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_renderer_discoverer_start

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_renderer_discoverer_stop
; Description ...: Stop renderer discovery.
; Syntax ........: _libvlc_renderer_discoverer_stop($p_rd)
; Parameters ....: $p_rd                - libvlc_renderer_discoverer_t * : renderer discoverer object
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_rd is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_renderer_discoverer_stop(libvlc_renderer_discoverer_t * p_rd)
;                  Version: LibVLC 3.0.0 or later
; Related .......:
; Link ..........: include/vlc/libvlc_renderer_discoverer.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_renderer_discoverer_stop($p_rd)
	If __VLC_Ptr($p_rd) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_renderer_discoverer_stop", "ptr", __VLC_Ptr($p_rd))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_renderer_discoverer_stop

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_renderer_discoverer_event_manager
; Description ...: Get the event manager of the renderer discoverer The possible events to attach are @ref libvlc_RendererDiscovererItemAdded and @ref libvlc_RendererDiscovererItemDeleted.
; Syntax ........: _libvlc_renderer_discoverer_event_manager($p_rd)
; Parameters ....: $p_rd                - libvlc_renderer_discoverer_t *
; Return values .: Success - pointer: a valid event manager (can't fail)
;                  Failure - Ptr(0), sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_rd is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: libvlc_event_manager_t *
;                  libvlc_renderer_discoverer_event_manager(libvlc_renderer_discoverer_t * p_rd)
;                  Version: LibVLC 3.0.0 or later
; Related .......:
; Link ..........: include/vlc/libvlc_renderer_discoverer.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_renderer_discoverer_event_manager($p_rd)
	If __VLC_Ptr($p_rd) = 0 Then Return SetError($VLC_ERR_PARAM, 0, Ptr(0)) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_renderer_discoverer_event_manager", "ptr", __VLC_Ptr($p_rd))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, Ptr(0))
	Return $__aCall[0]
EndFunc   ;==>_libvlc_renderer_discoverer_event_manager

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_renderer_discoverer_list_get
; Description ...: Get media discoverer services
; Syntax ........: _libvlc_renderer_discoverer_list_get($p_inst, $ppp_services)
; Parameters ....: $p_inst              - libvlc_instance_t * : libvlc instance
;                  $ppp_services        - [out, ByRef] libvlc_rd_description_t *** : address to store an allocated array of renderer
;                                       - discoverer services (must be freed with libvlc_renderer_list_release() by the caller)
;                                       - [OUT]
; Return values .: Success - ulong_ptr: the number of media discoverer services (0 on error)
;                  Failure - 0, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_inst is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: size_t libvlc_renderer_discoverer_list_get(libvlc_instance_t * p_inst,
;                  libvlc_rd_description_t *** ppp_services)
;                  Version: LibVLC 3.0.0 and later
; Related .......:
; Link ..........: include/vlc/libvlc_renderer_discoverer.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_renderer_discoverer_list_get($p_inst, ByRef $ppp_services)
	If __VLC_Ptr($p_inst) = 0 Then Return SetError($VLC_ERR_PARAM, 0, 0) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "ulong_ptr:cdecl", "libvlc_renderer_discoverer_list_get", "ptr", __VLC_Ptr($p_inst), "ptr*", Ptr(0))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, 0)
	$ppp_services = $__aCall[2]
	Return $__aCall[0]
EndFunc   ;==>_libvlc_renderer_discoverer_list_get

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_renderer_discoverer_list_release
; Description ...: Release an array of media discoverer services
; Syntax ........: _libvlc_renderer_discoverer_list_release($pp_services, $i_count)
; Parameters ....: $pp_services         - libvlc_rd_description_t ** : array to release
;                  $i_count             - size_t : number of elements in the array
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_renderer_discoverer_list_release(libvlc_rd_description_t ** pp_services, size_t
;                  i_count)
;                  Version: LibVLC 3.0.0 and later
; Related .......:
; Link ..........: include/vlc/libvlc_renderer_discoverer.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_renderer_discoverer_list_release($pp_services, $i_count)
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_renderer_discoverer_list_release", "ptr", __VLC_Ptr($pp_services), "ulong_ptr", $i_count)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_renderer_discoverer_list_release

#EndRegion libvlc_renderer_discoverer.h

#Region libvlc_media.h

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_new_location
; Description ...: Create a media with a certain given media resource location, for instance a valid URL.
; Syntax ........: _libvlc_media_new_location($p_instance, $psz_mrl)
; Parameters ....: $p_instance          - libvlc_instance_t * : the instance
;                  $psz_mrl             - const char * : the media location (string (UTF-8 converted automatically, Null/Default =
;                                       - NULL))
; Return values .: Success - pointer: the newly created media or NULL on error
;                  Failure - Ptr(0), sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_instance is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: libvlc_media_t * libvlc_media_new_location(libvlc_instance_t * p_instance, const char *
;                  psz_mrl)
;                  Note: To refer to a local file with this function, the file://... URI syntax must be used (see
;                  IETF RFC3986). We recommend using libvlc_media_new_path() instead when dealing with local
;                  files.
; Related .......:
; Link ..........: include/vlc/libvlc_media.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_new_location($p_instance, $psz_mrl)
	If __VLC_Ptr($p_instance) = 0 Then Return SetError($VLC_ERR_PARAM, 0, Ptr(0)) ; NULL would crash libVLC
	Local $__tStr2 = __VLC_Utf8Struct($psz_mrl)
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_media_new_location", "ptr", __VLC_Ptr($p_instance), "ptr", __VLC_Ptr($__tStr2))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, Ptr(0))
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_new_location

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_new_path
; Description ...: Create a media for a certain file path.
; Syntax ........: _libvlc_media_new_path($p_instance, $path)
; Parameters ....: $p_instance          - libvlc_instance_t * : the instance
;                  $path                - const char * : local filesystem path (string (UTF-8 converted automatically, Null/Default
;                                       - = NULL))
; Return values .: Success - pointer: the newly created media or NULL on error
;                  Failure - Ptr(0), sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_instance is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: libvlc_media_t * libvlc_media_new_path(libvlc_instance_t * p_instance, const char * path)
; Related .......:
; Link ..........: include/vlc/libvlc_media.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_new_path($p_instance, $path)
	If __VLC_Ptr($p_instance) = 0 Then Return SetError($VLC_ERR_PARAM, 0, Ptr(0)) ; NULL would crash libVLC
	Local $__tStr2 = __VLC_Utf8Struct($path)
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_media_new_path", "ptr", __VLC_Ptr($p_instance), "ptr", __VLC_Ptr($__tStr2))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, Ptr(0))
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_new_path

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_new_fd
; Description ...: Create a media for an already open file descriptor.
; Syntax ........: _libvlc_media_new_fd($p_instance, $fd)
; Parameters ....: $p_instance          - libvlc_instance_t * : the instance
;                  $fd                  - int : open file descriptor
; Return values .: Success - pointer: the newly created media or NULL on error
;                  Failure - Ptr(0), sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_instance is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: libvlc_media_t * libvlc_media_new_fd(libvlc_instance_t * p_instance, int fd)
;                  Version: LibVLC 1.1.5 and later.
;                  Note: This library will not automatically close the file descriptor under any circumstance.
;                  Nevertheless, a file descriptor can usually only be rendered once in a media player. To render
;                  it a second time, the file descriptor should probably be rewound to the beginning with lseek().
; Related .......:
; Link ..........: include/vlc/libvlc_media.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_new_fd($p_instance, $fd)
	If __VLC_Ptr($p_instance) = 0 Then Return SetError($VLC_ERR_PARAM, 0, Ptr(0)) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_media_new_fd", "ptr", __VLC_Ptr($p_instance), "int", $fd)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, Ptr(0))
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_new_fd

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_new_callbacks
; Description ...: Create a media with custom callbacks to read the data from.
; Syntax ........: _libvlc_media_new_callbacks($instance, $open_cb, $read_cb, $seek_cb, $close_cb, $opaque)
; Parameters ....: $instance            - libvlc_instance_t * : LibVLC instance
;                  $open_cb             - libvlc_media_open_cb : callback to open the custom bitstream input media
;                  $read_cb             - libvlc_media_read_cb : callback to read data (must not be NULL)
;                  $seek_cb             - libvlc_media_seek_cb : callback to seek, or NULL if seeking is not supported
;                  $close_cb            - libvlc_media_close_cb : callback to close the media, or NULL if unnecessary
;                  $opaque              - void * : data pointer for the open callback
; Return values .: Success - pointer: the newly created media or NULL on error
;                  Failure - Ptr(0), sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $instance is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: libvlc_media_t * libvlc_media_new_callbacks(libvlc_instance_t * instance,
;                  libvlc_media_open_cb open_cb, libvlc_media_read_cb read_cb, libvlc_media_seek_cb seek_cb,
;                  libvlc_media_close_cb close_cb, void * opaque)
;                  Version: LibVLC 3.0.0 and later.
;                  Note: If open_cb is NULL, the opaque pointer will be passed to read_cb, seek_cb and close_cb,
;                  and the stream size will be treated as unknown.
;                  Note: The callbacks may be called asynchronously (from another thread). A single stream
;                  instance need not be reentrant. However the open_cb needs to be reentrant if the media is used
;                  by multiple player instances.
;                  Warning: The callbacks may be used until all or any player instances that were supplied the
;                  media item are stopped.
; Related .......:
; Link ..........: include/vlc/libvlc_media.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_new_callbacks($instance, $open_cb, $read_cb, $seek_cb, $close_cb, $opaque)
	If __VLC_Ptr($instance) = 0 Then Return SetError($VLC_ERR_PARAM, 0, Ptr(0)) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_media_new_callbacks", "ptr", __VLC_Ptr($instance), "ptr", __VLC_Ptr($open_cb), "ptr", __VLC_Ptr($read_cb), "ptr", __VLC_Ptr($seek_cb), "ptr", __VLC_Ptr($close_cb), "ptr", __VLC_Ptr($opaque))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, Ptr(0))
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_new_callbacks

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_new_as_node
; Description ...: Create a media as an empty node with a given name.
; Syntax ........: _libvlc_media_new_as_node($p_instance, $psz_name)
; Parameters ....: $p_instance          - libvlc_instance_t * : the instance
;                  $psz_name            - const char * : the name of the node (string (UTF-8 converted automatically, Null/Default =
;                                       - NULL))
; Return values .: Success - pointer: the new empty media or NULL on error
;                  Failure - Ptr(0), sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_instance is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: libvlc_media_t * libvlc_media_new_as_node(libvlc_instance_t * p_instance, const char *
;                  psz_name)
; Related .......:
; Link ..........: include/vlc/libvlc_media.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_new_as_node($p_instance, $psz_name)
	If __VLC_Ptr($p_instance) = 0 Then Return SetError($VLC_ERR_PARAM, 0, Ptr(0)) ; NULL would crash libVLC
	Local $__tStr2 = __VLC_Utf8Struct($psz_name)
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_media_new_as_node", "ptr", __VLC_Ptr($p_instance), "ptr", __VLC_Ptr($__tStr2))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, Ptr(0))
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_new_as_node

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_add_option
; Description ...: Add an option to the media.
; Syntax ........: _libvlc_media_add_option($p_md, $psz_options)
; Parameters ....: $p_md                - libvlc_media_t * : the media descriptor
;                  $psz_options         - const char * : the options (as a string) (string (UTF-8 converted automatically,
;                                       - Null/Default = NULL))
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_md is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_media_add_option(libvlc_media_t * p_md, const char * psz_options)
;                  Note: The options are listed in 'vlc --long-help' from the command line, e.g. "-sout-all". Keep
;                  in mind that available options and their semantics vary across LibVLC versions and builds.
;                  Warning: Not all options affects libvlc_media_t objects: Specifically, due to architectural
;                  issues most audio and video options, such as text renderer options, have no effects on an
;                  individual media. These options must be set through libvlc_new() instead.
; Related .......:
; Link ..........: include/vlc/libvlc_media.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_add_option($p_md, $psz_options)
	If __VLC_Ptr($p_md) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	Local $__tStr2 = __VLC_Utf8Struct($psz_options)
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_media_add_option", "ptr", __VLC_Ptr($p_md), "ptr", __VLC_Ptr($__tStr2))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_media_add_option

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_add_option_flag
; Description ...: Add an option to the media with configurable flags.
; Syntax ........: _libvlc_media_add_option_flag($p_md, $psz_options, $i_flags)
; Parameters ....: $p_md                - libvlc_media_t * : the media descriptor
;                  $psz_options         - const char * : the options (as a string) (string (UTF-8 converted automatically,
;                                       - Null/Default = NULL))
;                  $i_flags             - unsigned : the flags for this option
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_md is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_media_add_option_flag(libvlc_media_t * p_md, const char * psz_options, unsigned
;                  i_flags)
; Related .......:
; Link ..........: include/vlc/libvlc_media.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_add_option_flag($p_md, $psz_options, $i_flags)
	If __VLC_Ptr($p_md) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	Local $__tStr2 = __VLC_Utf8Struct($psz_options)
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_media_add_option_flag", "ptr", __VLC_Ptr($p_md), "ptr", __VLC_Ptr($__tStr2), "uint", $i_flags)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_media_add_option_flag

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_retain
; Description ...: Retain a reference to a media descriptor object (libvlc_media_t).
; Syntax ........: _libvlc_media_retain($p_md)
; Parameters ....: $p_md                - libvlc_media_t * : the media descriptor
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_md is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_media_retain(libvlc_media_t * p_md)
; Related .......:
; Link ..........: include/vlc/libvlc_media.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_retain($p_md)
	If __VLC_Ptr($p_md) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_media_retain", "ptr", __VLC_Ptr($p_md))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_media_retain

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_release
; Description ...: Decrement the reference count of a media descriptor object.
; Syntax ........: _libvlc_media_release($p_md)
; Parameters ....: $p_md                - libvlc_media_t * : the media descriptor
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_md is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_media_release(libvlc_media_t * p_md)
; Related .......:
; Link ..........: include/vlc/libvlc_media.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_release($p_md)
	If __VLC_Ptr($p_md) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_media_release", "ptr", __VLC_Ptr($p_md))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_media_release

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_get_mrl
; Description ...: Get the media resource locator (mrl) from a media descriptor object
; Syntax ........: _libvlc_media_get_mrl($p_md)
; Parameters ....: $p_md                - libvlc_media_t * : a media descriptor object
; Return values .: Success - string (C memory is released automatically): string with mrl of media descriptor
;                  object
;                            A NULL result is returned as "" with @extended = 1.
;                  Failure - "", sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_md is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: char * libvlc_media_get_mrl(libvlc_media_t * p_md)
; Related .......:
; Link ..........: include/vlc/libvlc_media.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_get_mrl($p_md)
	If __VLC_Ptr($p_md) = 0 Then Return SetError($VLC_ERR_PARAM, 0, "") ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_media_get_mrl", "ptr", __VLC_Ptr($p_md))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, "")
	Local $__sRet = __VLC_StrFromPtr($__aCall[0], True)
	Return SetExtended(@extended, $__sRet)
EndFunc   ;==>_libvlc_media_get_mrl

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_duplicate
; Description ...: Duplicate a media descriptor object.
; Syntax ........: _libvlc_media_duplicate($p_md)
; Parameters ....: $p_md                - libvlc_media_t * : a media descriptor object.
; Return values .: Success - pointer
;                  Failure - Ptr(0), sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_md is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: libvlc_media_t * libvlc_media_duplicate(libvlc_media_t * p_md)
; Related .......:
; Link ..........: include/vlc/libvlc_media.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_duplicate($p_md)
	If __VLC_Ptr($p_md) = 0 Then Return SetError($VLC_ERR_PARAM, 0, Ptr(0)) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_media_duplicate", "ptr", __VLC_Ptr($p_md))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, Ptr(0))
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_duplicate

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_get_meta
; Description ...: Read the meta of the media.
; Syntax ........: _libvlc_media_get_meta($p_md, $e_meta)
; Parameters ....: $p_md                - libvlc_media_t * : the media descriptor
;                  $e_meta              - libvlc_meta_t : the meta to read
; Return values .: Success - string (C memory is released automatically): the media's meta
;                            A NULL result is returned as "" with @extended = 1.
;                  Failure - "", sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_md is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: char * libvlc_media_get_meta(libvlc_media_t * p_md, libvlc_meta_t e_meta)
; Related .......:
; Link ..........: include/vlc/libvlc_media.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_get_meta($p_md, $e_meta)
	If __VLC_Ptr($p_md) = 0 Then Return SetError($VLC_ERR_PARAM, 0, "") ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_media_get_meta", "ptr", __VLC_Ptr($p_md), "int", $e_meta)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, "")
	Local $__sRet = __VLC_StrFromPtr($__aCall[0], True)
	Return SetExtended(@extended, $__sRet)
EndFunc   ;==>_libvlc_media_get_meta

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_set_meta
; Description ...: Set the meta of the media (this function will not save the meta, call libvlc_media_save_meta in order to save the meta)
; Syntax ........: _libvlc_media_set_meta($p_md, $e_meta, $psz_value)
; Parameters ....: $p_md                - libvlc_media_t * : the media descriptor
;                  $e_meta              - libvlc_meta_t : the meta to write
;                  $psz_value           - const char * : the media's meta (string (UTF-8 converted automatically, Null/Default =
;                                       - NULL))
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_md is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_media_set_meta(libvlc_media_t * p_md, libvlc_meta_t e_meta, const char *
;                  psz_value)
; Related .......:
; Link ..........: include/vlc/libvlc_media.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_set_meta($p_md, $e_meta, $psz_value)
	If __VLC_Ptr($p_md) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	Local $__tStr3 = __VLC_Utf8Struct($psz_value)
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_media_set_meta", "ptr", __VLC_Ptr($p_md), "int", $e_meta, "ptr", __VLC_Ptr($__tStr3))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_media_set_meta

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_save_meta
; Description ...: Save the meta previously set
; Syntax ........: _libvlc_media_save_meta($p_md)
; Parameters ....: $p_md                - libvlc_media_t * : the media desriptor
; Return values .: Success - int: true if the write operation was successful
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_md is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_media_save_meta(libvlc_media_t * p_md)
; Related .......:
; Link ..........: include/vlc/libvlc_media.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_save_meta($p_md)
	If __VLC_Ptr($p_md) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_media_save_meta", "ptr", __VLC_Ptr($p_md))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_save_meta

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_get_state
; Description ...: Get current state of media descriptor object.
; Syntax ........: _libvlc_media_get_state($p_md)
; Parameters ....: $p_md                - libvlc_media_t * : a media descriptor object
; Return values .: Success - int: state of media descriptor object
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_md is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: libvlc_state_t libvlc_media_get_state(libvlc_media_t * p_md)
; Related .......:
; Link ..........: include/vlc/libvlc_media.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_get_state($p_md)
	If __VLC_Ptr($p_md) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_media_get_state", "ptr", __VLC_Ptr($p_md))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_get_state

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_get_stats
; Description ...: Get the current statistics about the media
; Syntax ........: _libvlc_media_get_stats($p_md, $p_stats)
; Parameters ....: $p_md                - libvlc_media_t * : : media descriptor object
;                  $p_stats             - libvlc_media_stats_t * : : structure that contain the statistics about the media (this
;                                       - structure must be allocated by the caller)
; Return values .: Success - int: 0 on success, -1 on error
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_md is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_media_get_stats(libvlc_media_t * p_md, libvlc_media_stats_t * p_stats)
; Related .......:
; Link ..........: include/vlc/libvlc_media.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_get_stats($p_md, $p_stats)
	If __VLC_Ptr($p_md) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_media_get_stats", "ptr", __VLC_Ptr($p_md), "ptr", __VLC_Ptr($p_stats))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_get_stats

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_subitems
; Description ...: Get subitems of media descriptor object.
; Syntax ........: _libvlc_media_subitems($p_md)
; Parameters ....: $p_md                - libvlc_media_t * : media descriptor object
; Return values .: Success - pointer: list of media descriptor subitems or NULL
;                  Failure - Ptr(0), sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_md is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: libvlc_media_list_t * libvlc_media_subitems(libvlc_media_t * p_md)
; Related .......:
; Link ..........: include/vlc/libvlc_media.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_subitems($p_md)
	If __VLC_Ptr($p_md) = 0 Then Return SetError($VLC_ERR_PARAM, 0, Ptr(0)) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_media_subitems", "ptr", __VLC_Ptr($p_md))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, Ptr(0))
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_subitems

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_event_manager
; Description ...: Get event manager from media descriptor object.
; Syntax ........: _libvlc_media_event_manager($p_md)
; Parameters ....: $p_md                - libvlc_media_t * : a media descriptor object
; Return values .: Success - pointer: event manager object
;                  Failure - Ptr(0), sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_md is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: libvlc_event_manager_t * libvlc_media_event_manager(libvlc_media_t * p_md)
; Related .......:
; Link ..........: include/vlc/libvlc_media.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_event_manager($p_md)
	If __VLC_Ptr($p_md) = 0 Then Return SetError($VLC_ERR_PARAM, 0, Ptr(0)) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_media_event_manager", "ptr", __VLC_Ptr($p_md))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, Ptr(0))
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_event_manager

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_get_duration
; Description ...: Get duration (in ms) of media descriptor object item.
; Syntax ........: _libvlc_media_get_duration($p_md)
; Parameters ....: $p_md                - libvlc_media_t * : media descriptor object
; Return values .: Success - int64: duration of media item or -1 on error
;                  Failure - 0, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_md is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: libvlc_time_t libvlc_media_get_duration(libvlc_media_t * p_md)
; Related .......:
; Link ..........: include/vlc/libvlc_media.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_get_duration($p_md)
	If __VLC_Ptr($p_md) = 0 Then Return SetError($VLC_ERR_PARAM, 0, 0) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int64:cdecl", "libvlc_media_get_duration", "ptr", __VLC_Ptr($p_md))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, 0)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_get_duration

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_parse_with_options
; Description ...: Parse the media asynchronously with options.
; Syntax ........: _libvlc_media_parse_with_options($p_md, $parse_flag, $timeout)
; Parameters ....: $p_md                - libvlc_media_t * : media descriptor object
;                  $parse_flag          - libvlc_media_parse_flag_t : parse options:
;                  $timeout             - int : maximum time allowed to preparse the media. If -1, the default "preparse-timeout"
;                                       - option will be used as a timeout. If 0, it will wait indefinitely. If > 0, the timeout
;                                       - will be used (in milliseconds).
; Return values .: Success - int: -1 in case of error, 0 otherwise
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_md is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_media_parse_with_options(libvlc_media_t * p_md, libvlc_media_parse_flag_t
;                  parse_flag, int timeout)
;                  Version: LibVLC 3.0.0 or later
;                  Note: Parsing can be aborted with libvlc_media_parse_stop().
; Related .......:
; Link ..........: include/vlc/libvlc_media.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_parse_with_options($p_md, $parse_flag, $timeout)
	If __VLC_Ptr($p_md) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_media_parse_with_options", "ptr", __VLC_Ptr($p_md), "int", $parse_flag, "int", $timeout)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_parse_with_options

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_parse_stop
; Description ...: Stop the parsing of the media When the media parsing is stopped, the libvlc_MediaParsedChanged event will be sent with the libvlc_media_parsed_status_timeout status.
; Syntax ........: _libvlc_media_parse_stop($p_md)
; Parameters ....: $p_md                - libvlc_media_t * : media descriptor object
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_md is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_media_parse_stop(libvlc_media_t * p_md)
;                  Version: LibVLC 3.0.0 or later
; Related .......:
; Link ..........: include/vlc/libvlc_media.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_parse_stop($p_md)
	If __VLC_Ptr($p_md) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_media_parse_stop", "ptr", __VLC_Ptr($p_md))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_media_parse_stop

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_get_parsed_status
; Description ...: Get Parsed status for media descriptor object.
; Syntax ........: _libvlc_media_get_parsed_status($p_md)
; Parameters ....: $p_md                - libvlc_media_t * : media descriptor object
; Return values .: Success - int: a value of the libvlc_media_parsed_status_t enum
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_md is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: libvlc_media_parsed_status_t libvlc_media_get_parsed_status(libvlc_media_t * p_md)
;                  Version: LibVLC 3.0.0 or later
; Related .......:
; Link ..........: include/vlc/libvlc_media.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_get_parsed_status($p_md)
	If __VLC_Ptr($p_md) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_media_get_parsed_status", "ptr", __VLC_Ptr($p_md))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_get_parsed_status

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_set_user_data
; Description ...: Sets media descriptor's user_data.
; Syntax ........: _libvlc_media_set_user_data($p_md, $p_new_user_data)
; Parameters ....: $p_md                - libvlc_media_t * : media descriptor object
;                  $p_new_user_data     - void * : pointer to user data
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_md is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_media_set_user_data(libvlc_media_t * p_md, void * p_new_user_data)
; Related .......:
; Link ..........: include/vlc/libvlc_media.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_set_user_data($p_md, $p_new_user_data)
	If __VLC_Ptr($p_md) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_media_set_user_data", "ptr", __VLC_Ptr($p_md), "ptr", __VLC_Ptr($p_new_user_data))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_media_set_user_data

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_get_user_data
; Description ...: Get media descriptor's user_data.
; Syntax ........: _libvlc_media_get_user_data($p_md)
; Parameters ....: $p_md                - libvlc_media_t * : media descriptor object
; Return values .: Success - pointer
;                  Failure - Ptr(0), sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_md is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void * libvlc_media_get_user_data(libvlc_media_t * p_md)
; Related .......:
; Link ..........: include/vlc/libvlc_media.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_get_user_data($p_md)
	If __VLC_Ptr($p_md) = 0 Then Return SetError($VLC_ERR_PARAM, 0, Ptr(0)) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_media_get_user_data", "ptr", __VLC_Ptr($p_md))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, Ptr(0))
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_get_user_data

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_tracks_get
; Description ...: Get media descriptor's elementary streams description Note, you need to call libvlc_media_parse() or play the media at least once before calling this function.
; Syntax ........: _libvlc_media_tracks_get($p_md, $tracks)
; Parameters ....: $p_md                - libvlc_media_t * : media descriptor object
;                  $tracks              - [out, ByRef] libvlc_media_track_t *** : address to store an allocated array of Elementary
;                                       - Streams descriptions (must be freed with libvlc_media_tracks_release by the caller) [OUT]
; Return values .: Success - uint: the number of Elementary Streams (zero on error)
;                  Failure - 0, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_md is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: unsigned libvlc_media_tracks_get(libvlc_media_t * p_md, libvlc_media_track_t *** tracks)
;                  Version: LibVLC 2.1.0 and later.
; Related .......:
; Link ..........: include/vlc/libvlc_media.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_tracks_get($p_md, ByRef $tracks)
	If __VLC_Ptr($p_md) = 0 Then Return SetError($VLC_ERR_PARAM, 0, 0) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "uint:cdecl", "libvlc_media_tracks_get", "ptr", __VLC_Ptr($p_md), "ptr*", Ptr(0))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, 0)
	$tracks = $__aCall[2]
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_tracks_get

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_get_codec_description
; Description ...: Get codec description from media elementary stream
; Syntax ........: _libvlc_media_get_codec_description($i_type, $i_codec)
; Parameters ....: $i_type              - libvlc_track_type_t : i_type from libvlc_media_track_t
;                  $i_codec             - uint32_t : i_codec or i_original_fourcc from libvlc_media_track_t
; Return values .: Success - string: codec description
;                            A NULL result is returned as "" with @extended = 1.
;                  Failure - "", sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: const char * libvlc_media_get_codec_description(libvlc_track_type_t i_type, uint32_t
;                  i_codec)
;                  Version: LibVLC 3.0.0 and later.
; Related .......:
; Link ..........: include/vlc/libvlc_media.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_get_codec_description($i_type, $i_codec)
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_media_get_codec_description", "int", $i_type, "uint", $i_codec)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, "")
	Local $__sRet = __VLC_StrFromPtr($__aCall[0], False)
	Return SetExtended(@extended, $__sRet)
EndFunc   ;==>_libvlc_media_get_codec_description

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_tracks_release
; Description ...: Release media descriptor's elementary streams description array
; Syntax ........: _libvlc_media_tracks_release($p_tracks, $i_count)
; Parameters ....: $p_tracks            - libvlc_media_track_t ** : tracks info array to release
;                  $i_count             - unsigned : number of elements in the array
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_media_tracks_release(libvlc_media_track_t ** p_tracks, unsigned i_count)
;                  Version: LibVLC 2.1.0 and later.
; Related .......:
; Link ..........: include/vlc/libvlc_media.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_tracks_release($p_tracks, $i_count)
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_media_tracks_release", "ptr", __VLC_Ptr($p_tracks), "uint", $i_count)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_media_tracks_release

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_get_type
; Description ...: Get the media type of the media descriptor object
; Syntax ........: _libvlc_media_get_type($p_md)
; Parameters ....: $p_md                - libvlc_media_t * : media descriptor object
; Return values .: Success - int: media type
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_md is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: libvlc_media_type_t libvlc_media_get_type(libvlc_media_t * p_md)
;                  Version: LibVLC 3.0.0 and later.
; Related .......:
; Link ..........: include/vlc/libvlc_media.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_get_type($p_md)
	If __VLC_Ptr($p_md) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_media_get_type", "ptr", __VLC_Ptr($p_md))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_get_type

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_slaves_add
; Description ...: Add a slave to the current media.
; Syntax ........: _libvlc_media_slaves_add($p_md, $i_type, $i_priority, $psz_uri)
; Parameters ....: $p_md                - libvlc_media_t * : media descriptor object
;                  $i_type              - libvlc_media_slave_type_t : subtitle or audio
;                  $i_priority          - unsigned int : from 0 (low priority) to 4 (high priority)
;                  $psz_uri             - const char * : Uri of the slave (should contain a valid scheme). (string (UTF-8 converted
;                                       - automatically, Null/Default = NULL))
; Return values .: Success - int: 0 on success, -1 on error.
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_md is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_media_slaves_add(libvlc_media_t * p_md, libvlc_media_slave_type_t i_type,
;                  unsigned int i_priority, const char * psz_uri)
;                  Version: LibVLC 3.0.0 and later.
;                  Note: This function must be called before the media is parsed (via
;                  libvlc_media_parse_with_options()) or before the media is played (via
;                  libvlc_media_player_play())
; Related .......:
; Link ..........: include/vlc/libvlc_media.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_slaves_add($p_md, $i_type, $i_priority, $psz_uri)
	If __VLC_Ptr($p_md) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__tStr4 = __VLC_Utf8Struct($psz_uri)
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_media_slaves_add", "ptr", __VLC_Ptr($p_md), "int", $i_type, "uint", $i_priority, "ptr", __VLC_Ptr($__tStr4))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_slaves_add

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_slaves_clear
; Description ...: Clear all slaves previously added by libvlc_media_slaves_add() or internally.
; Syntax ........: _libvlc_media_slaves_clear($p_md)
; Parameters ....: $p_md                - libvlc_media_t * : media descriptor object
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_md is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_media_slaves_clear(libvlc_media_t * p_md)
;                  Version: LibVLC 3.0.0 and later.
; Related .......:
; Link ..........: include/vlc/libvlc_media.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_slaves_clear($p_md)
	If __VLC_Ptr($p_md) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_media_slaves_clear", "ptr", __VLC_Ptr($p_md))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_media_slaves_clear

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_slaves_get
; Description ...: Get a media descriptor's slave list The list will contain slaves parsed by VLC or previously added by libvlc_media_slaves_add().
; Syntax ........: _libvlc_media_slaves_get($p_md, $ppp_slaves)
; Parameters ....: $p_md                - libvlc_media_t * : media descriptor object
;                  $ppp_slaves          - [out, ByRef] libvlc_media_slave_t *** : address to store an allocated array of slaves
;                                       - (must be freed with libvlc_media_slaves_release()) [OUT]
; Return values .: Success - uint: the number of slaves (zero on error)
;                  Failure - 0, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_md is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: unsigned int libvlc_media_slaves_get(libvlc_media_t * p_md, libvlc_media_slave_t ***
;                  ppp_slaves)
;                  Version: LibVLC 3.0.0 and later.
; Related .......:
; Link ..........: include/vlc/libvlc_media.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_slaves_get($p_md, ByRef $ppp_slaves)
	If __VLC_Ptr($p_md) = 0 Then Return SetError($VLC_ERR_PARAM, 0, 0) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "uint:cdecl", "libvlc_media_slaves_get", "ptr", __VLC_Ptr($p_md), "ptr*", Ptr(0))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, 0)
	$ppp_slaves = $__aCall[2]
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_slaves_get

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_slaves_release
; Description ...: Release a media descriptor's slave list
; Syntax ........: _libvlc_media_slaves_release($pp_slaves, $i_count)
; Parameters ....: $pp_slaves           - libvlc_media_slave_t ** : slave array to release
;                  $i_count             - unsigned int : number of elements in the array
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_media_slaves_release(libvlc_media_slave_t ** pp_slaves, unsigned int i_count)
;                  Version: LibVLC 3.0.0 and later.
; Related .......:
; Link ..........: include/vlc/libvlc_media.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_slaves_release($pp_slaves, $i_count)
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_media_slaves_release", "ptr", __VLC_Ptr($pp_slaves), "uint", $i_count)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_media_slaves_release

#EndRegion libvlc_media.h

#Region libvlc_media_player.h

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_player_new
; Description ...: Create an empty Media Player object
; Syntax ........: _libvlc_media_player_new($p_libvlc_instance)
; Parameters ....: $p_libvlc_instance   - libvlc_instance_t * : the libvlc instance in which the Media Player should be created.
; Return values .: Success - pointer: a new media player object, or NULL on error.
;                  Failure - Ptr(0), sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_libvlc_instance is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: libvlc_media_player_t * libvlc_media_player_new(libvlc_instance_t * p_libvlc_instance)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_player_new($p_libvlc_instance)
	If __VLC_Ptr($p_libvlc_instance) = 0 Then Return SetError($VLC_ERR_PARAM, 0, Ptr(0)) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_media_player_new", "ptr", __VLC_Ptr($p_libvlc_instance))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, Ptr(0))
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_player_new

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_player_new_from_media
; Description ...: Create a Media Player object from a Media
; Syntax ........: _libvlc_media_player_new_from_media($p_md)
; Parameters ....: $p_md                - libvlc_media_t * : the media. Afterwards the p_md can be safely destroyed.
; Return values .: Success - pointer: a new media player object, or NULL on error.
;                  Failure - Ptr(0), sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_md is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: libvlc_media_player_t * libvlc_media_player_new_from_media(libvlc_media_t * p_md)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_player_new_from_media($p_md)
	If __VLC_Ptr($p_md) = 0 Then Return SetError($VLC_ERR_PARAM, 0, Ptr(0)) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_media_player_new_from_media", "ptr", __VLC_Ptr($p_md))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, Ptr(0))
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_player_new_from_media

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_player_release
; Description ...: Release a media_player after use Decrement the reference count of a media player object.
; Syntax ........: _libvlc_media_player_release($p_mi)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the Media Player to free
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_media_player_release(libvlc_media_player_t * p_mi)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_player_release($p_mi)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_media_player_release", "ptr", __VLC_Ptr($p_mi))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_media_player_release

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_player_retain
; Description ...: Retain a reference to a media player object.
; Syntax ........: _libvlc_media_player_retain($p_mi)
; Parameters ....: $p_mi                - libvlc_media_player_t * : media player object
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_media_player_retain(libvlc_media_player_t * p_mi)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_player_retain($p_mi)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_media_player_retain", "ptr", __VLC_Ptr($p_mi))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_media_player_retain

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_player_set_media
; Description ...: Set the media that will be used by the media_player.
; Syntax ........: _libvlc_media_player_set_media($p_mi, $p_md)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the Media Player
;                  $p_md                - libvlc_media_t * : the Media. Afterwards the p_md can be safely destroyed.
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_media_player_set_media(libvlc_media_player_t * p_mi, libvlc_media_t * p_md)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_player_set_media($p_mi, $p_md)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_media_player_set_media", "ptr", __VLC_Ptr($p_mi), "ptr", __VLC_Ptr($p_md))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_media_player_set_media

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_player_get_media
; Description ...: Get the media used by the media_player.
; Syntax ........: _libvlc_media_player_get_media($p_mi)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the Media Player
; Return values .: Success - pointer: the media associated with p_mi, or NULL if no media is associated
;                  Failure - Ptr(0), sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: libvlc_media_t * libvlc_media_player_get_media(libvlc_media_player_t * p_mi)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_player_get_media($p_mi)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, Ptr(0)) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_media_player_get_media", "ptr", __VLC_Ptr($p_mi))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, Ptr(0))
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_player_get_media

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_player_event_manager
; Description ...: Get the Event Manager from which the media player send event.
; Syntax ........: _libvlc_media_player_event_manager($p_mi)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the Media Player
; Return values .: Success - pointer: the event manager associated with p_mi
;                  Failure - Ptr(0), sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: libvlc_event_manager_t * libvlc_media_player_event_manager(libvlc_media_player_t * p_mi)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_player_event_manager($p_mi)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, Ptr(0)) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_media_player_event_manager", "ptr", __VLC_Ptr($p_mi))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, Ptr(0))
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_player_event_manager

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_player_is_playing
; Description ...: is_playing
; Syntax ........: _libvlc_media_player_is_playing($p_mi)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the Media Player
; Return values .: Success - int: 0 on success, -1 on error
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_media_player_is_playing(libvlc_media_player_t * p_mi)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_player_is_playing($p_mi)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_media_player_is_playing", "ptr", __VLC_Ptr($p_mi))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_player_is_playing

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_player_play
; Description ...: Play
; Syntax ........: _libvlc_media_player_play($p_mi)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the Media Player
; Return values .: Success - int: 0 if playback started (and was already started), or -1 on error.
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_media_player_play(libvlc_media_player_t * p_mi)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_player_play($p_mi)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_media_player_play", "ptr", __VLC_Ptr($p_mi))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_player_play

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_player_set_pause
; Description ...: Pause or resume (no effect if there is no media)
; Syntax ........: _libvlc_media_player_set_pause($mp, $do_pause)
; Parameters ....: $mp                  - libvlc_media_player_t * : the Media Player
;                  $do_pause            - int : play/resume if zero, pause if non-zero
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $mp is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_media_player_set_pause(libvlc_media_player_t * mp, int do_pause)
;                  Version: LibVLC 1.1.1 or later
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_player_set_pause($mp, $do_pause)
	If __VLC_Ptr($mp) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_media_player_set_pause", "ptr", __VLC_Ptr($mp), "int", $do_pause)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_media_player_set_pause

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_player_pause
; Description ...: Toggle pause (no effect if there is no media)
; Syntax ........: _libvlc_media_player_pause($p_mi)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the Media Player
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_media_player_pause(libvlc_media_player_t * p_mi)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_player_pause($p_mi)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_media_player_pause", "ptr", __VLC_Ptr($p_mi))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_media_player_pause

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_player_stop
; Description ...: Stop (no effect if there is no media)
; Syntax ........: _libvlc_media_player_stop($p_mi)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the Media Player
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_media_player_stop(libvlc_media_player_t * p_mi)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_player_stop($p_mi)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_media_player_stop", "ptr", __VLC_Ptr($p_mi))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_media_player_stop

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_player_set_renderer
; Description ...: Set a renderer to the media player
; Syntax ........: _libvlc_media_player_set_renderer($p_mi, $p_item)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the Media Player
;                  $p_item              - libvlc_renderer_item_t * : an item discovered by libvlc_renderer_discoverer_start()
; Return values .: Success - int: 0 on success, -1 on error.
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_media_player_set_renderer(libvlc_media_player_t * p_mi, libvlc_renderer_item_t *
;                  p_item)
;                  Version: LibVLC 3.0.0 or later
;                  Note: must be called before the first call of libvlc_media_player_play() to take effect.
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_player_set_renderer($p_mi, $p_item)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_media_player_set_renderer", "ptr", __VLC_Ptr($p_mi), "ptr", __VLC_Ptr($p_item))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_player_set_renderer

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_video_set_callbacks
; Description ...: Set callbacks and private data to render decoded video to a custom area in memory.
; Syntax ........: _libvlc_video_set_callbacks($mp, $lock, $unlock, $display, $opaque)
; Parameters ....: $mp                  - libvlc_media_player_t * : the media player
;                  $lock                - libvlc_video_lock_cb : callback to lock video memory (must not be NULL)
;                  $unlock              - libvlc_video_unlock_cb : callback to unlock video memory (or NULL if not needed)
;                  $display             - libvlc_video_display_cb : callback to display video (or NULL if not needed)
;                  $opaque              - void * : private pointer for the three callbacks (as first parameter)
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $mp is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_video_set_callbacks(libvlc_media_player_t * mp, libvlc_video_lock_cb lock,
;                  libvlc_video_unlock_cb unlock, libvlc_video_display_cb display, void * opaque)
;                  Version: LibVLC 1.1.1 or later
;                  Warning: Rendering video into custom memory buffers is considerably less efficient than
;                  rendering in a custom window as normal. For optimal perfomances, VLC media player renders into
;                  a custom window, and does not use this function and associated callbacks. It is highly
;                  recommended that other LibVLC-based application do likewise. To embed video in a window, use
;                  libvlc_media_player_set_xid() or equivalent depending on the operating system. If window
;                  embedding does not fit the application use case, then a custom LibVLC video output display
;                  plugin is required to maintain optimal video rendering performances. The following limitations
;                  affect performance: - Hardware video decoding acceleration will either be disabled completely,
;                  or require (relatively slow) copy from video/DSP memory to main memory. - Sub-pictures
;                  (subtitles, on-screen display, etc.) must be blent into the main picture by the CPU instead of
;                  the GPU. - Depending on the video format, pixel format conversion, picture scaling, cropping
;                  and/or picture re-orientation, must be performed by the CPU instead of the GPU. - Memory
;                  copying is required between LibVLC reference picture buffers and application buffers (between
;                  lock and unlock callbacks).
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_video_set_callbacks($mp, $lock, $unlock, $display, $opaque)
	If __VLC_Ptr($mp) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_video_set_callbacks", "ptr", __VLC_Ptr($mp), "ptr", __VLC_Ptr($lock), "ptr", __VLC_Ptr($unlock), "ptr", __VLC_Ptr($display), "ptr", __VLC_Ptr($opaque))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_video_set_callbacks

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_video_set_format
; Description ...: Set decoded video chroma and dimensions.
; Syntax ........: _libvlc_video_set_format($mp, $chroma, $width, $height, $pitch)
; Parameters ....: $mp                  - libvlc_media_player_t * : the media player
;                  $chroma              - const char * : a four-characters string identifying the chroma (e.g. "RV32" or "YUYV")
;                                       - (string (UTF-8 converted automatically, Null/Default = NULL))
;                  $width               - unsigned : pixel width
;                  $height              - unsigned : pixel height
;                  $pitch               - unsigned : line pitch (in bytes)
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $mp is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_video_set_format(libvlc_media_player_t * mp, const char * chroma, unsigned
;                  width, unsigned height, unsigned pitch)
;                  Version: LibVLC 1.1.1 or later
;                  Bug: All pixel planes are expected to have the same pitch. To use the YCbCr color space with
;                  chrominance subsampling, consider using libvlc_video_set_format_callbacks() instead.
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_video_set_format($mp, $chroma, $width, $height, $pitch)
	If __VLC_Ptr($mp) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	Local $__tStr2 = __VLC_Utf8Struct($chroma)
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_video_set_format", "ptr", __VLC_Ptr($mp), "ptr", __VLC_Ptr($__tStr2), "uint", $width, "uint", $height, "uint", $pitch)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_video_set_format

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_video_set_format_callbacks
; Description ...: Set decoded video chroma and dimensions.
; Syntax ........: _libvlc_video_set_format_callbacks($mp, $setup, $cleanup)
; Parameters ....: $mp                  - libvlc_media_player_t * : the media player
;                  $setup               - libvlc_video_format_cb : callback to select the video format (cannot be NULL)
;                  $cleanup             - libvlc_video_cleanup_cb : callback to release any allocated resources (or NULL)
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $mp is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_video_set_format_callbacks(libvlc_media_player_t * mp, libvlc_video_format_cb
;                  setup, libvlc_video_cleanup_cb cleanup)
;                  Version: LibVLC 2.0.0 or later
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_video_set_format_callbacks($mp, $setup, $cleanup)
	If __VLC_Ptr($mp) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_video_set_format_callbacks", "ptr", __VLC_Ptr($mp), "ptr", __VLC_Ptr($setup), "ptr", __VLC_Ptr($cleanup))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_video_set_format_callbacks

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_player_set_hwnd
; Description ...: Set a Win32/Win64 API window handle (HWND) where the media player should render its video output.
; Syntax ........: _libvlc_media_player_set_hwnd($p_mi, $drawable)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the Media Player
;                  $drawable            - void * : windows handle of the drawable
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_media_player_set_hwnd(libvlc_media_player_t * p_mi, void * drawable)
;                  Warning: the HWND must have the WS_CLIPCHILDREN set in its style.
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_player_set_hwnd($p_mi, $drawable)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_media_player_set_hwnd", "ptr", __VLC_Ptr($p_mi), "ptr", __VLC_Ptr($drawable))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_media_player_set_hwnd

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_player_get_hwnd
; Description ...: Get the Windows API window handle (HWND) previously set with libvlc_media_player_set_hwnd().
; Syntax ........: _libvlc_media_player_get_hwnd($p_mi)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the Media Player
; Return values .: Success - pointer: a window handle or NULL if there are none.
;                  Failure - Ptr(0), sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void * libvlc_media_player_get_hwnd(libvlc_media_player_t * p_mi)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_player_get_hwnd($p_mi)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, Ptr(0)) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_media_player_get_hwnd", "ptr", __VLC_Ptr($p_mi))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, Ptr(0))
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_player_get_hwnd

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_audio_set_callbacks
; Description ...: Sets callbacks and private data for decoded audio.
; Syntax ........: _libvlc_audio_set_callbacks($mp, $play, $pause, $resume, $flush, $drain, $opaque)
; Parameters ....: $mp                  - libvlc_media_player_t * : the media player
;                  $play                - libvlc_audio_play_cb : callback to play audio samples (must not be NULL)
;                  $pause               - libvlc_audio_pause_cb : callback to pause playback (or NULL to ignore)
;                  $resume              - libvlc_audio_resume_cb : callback to resume playback (or NULL to ignore)
;                  $flush               - libvlc_audio_flush_cb : callback to flush audio buffers (or NULL to ignore)
;                  $drain               - libvlc_audio_drain_cb : callback to drain audio buffers (or NULL to ignore)
;                  $opaque              - void * : private pointer for the audio callbacks (as first parameter)
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $mp is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_audio_set_callbacks(libvlc_media_player_t * mp, libvlc_audio_play_cb play,
;                  libvlc_audio_pause_cb pause, libvlc_audio_resume_cb resume, libvlc_audio_flush_cb flush,
;                  libvlc_audio_drain_cb drain, void * opaque)
;                  Version: LibVLC 2.0.0 or later
;                  Note: The audio callbacks override any other audio output mechanism. If the callbacks are set,
;                  LibVLC will not output audio in any way.
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_audio_set_callbacks($mp, $play, $pause, $resume, $flush, $drain, $opaque)
	If __VLC_Ptr($mp) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_audio_set_callbacks", "ptr", __VLC_Ptr($mp), "ptr", __VLC_Ptr($play), "ptr", __VLC_Ptr($pause), "ptr", __VLC_Ptr($resume), "ptr", __VLC_Ptr($flush), "ptr", __VLC_Ptr($drain), "ptr", __VLC_Ptr($opaque))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_audio_set_callbacks

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_audio_set_volume_callback
; Description ...: Set callbacks and private data for decoded audio.
; Syntax ........: _libvlc_audio_set_volume_callback($mp, $set_volume)
; Parameters ....: $mp                  - libvlc_media_player_t * : the media player
;                  $set_volume          - libvlc_audio_set_volume_cb : callback to apply audio volume, or NULL to apply volume in
;                                       - software
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $mp is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_audio_set_volume_callback(libvlc_media_player_t * mp, libvlc_audio_set_volume_cb
;                  set_volume)
;                  Version: LibVLC 2.0.0 or later
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_audio_set_volume_callback($mp, $set_volume)
	If __VLC_Ptr($mp) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_audio_set_volume_callback", "ptr", __VLC_Ptr($mp), "ptr", __VLC_Ptr($set_volume))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_audio_set_volume_callback

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_audio_set_format_callbacks
; Description ...: Sets decoded audio format via callbacks.
; Syntax ........: _libvlc_audio_set_format_callbacks($mp, $setup, $cleanup)
; Parameters ....: $mp                  - libvlc_media_player_t * : the media player
;                  $setup               - libvlc_audio_setup_cb : callback to select the audio format (cannot be NULL)
;                  $cleanup             - libvlc_audio_cleanup_cb : callback to release any allocated resources (or NULL)
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $mp is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_audio_set_format_callbacks(libvlc_media_player_t * mp, libvlc_audio_setup_cb
;                  setup, libvlc_audio_cleanup_cb cleanup)
;                  Version: LibVLC 2.0.0 or later
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_audio_set_format_callbacks($mp, $setup, $cleanup)
	If __VLC_Ptr($mp) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_audio_set_format_callbacks", "ptr", __VLC_Ptr($mp), "ptr", __VLC_Ptr($setup), "ptr", __VLC_Ptr($cleanup))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_audio_set_format_callbacks

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_audio_set_format
; Description ...: Sets a fixed decoded audio format.
; Syntax ........: _libvlc_audio_set_format($mp, $format, $rate, $channels)
; Parameters ....: $mp                  - libvlc_media_player_t * : the media player
;                  $format              - const char * : a four-characters string identifying the sample format (e.g. "S16N" or
;                                       - "f32l") (string (UTF-8 converted automatically, Null/Default = NULL))
;                  $rate                - unsigned : sample rate (expressed in Hz)
;                  $channels            - unsigned : channels count
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $mp is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_audio_set_format(libvlc_media_player_t * mp, const char * format, unsigned rate,
;                  unsigned channels)
;                  Version: LibVLC 2.0.0 or later
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_audio_set_format($mp, $format, $rate, $channels)
	If __VLC_Ptr($mp) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	Local $__tStr2 = __VLC_Utf8Struct($format)
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_audio_set_format", "ptr", __VLC_Ptr($mp), "ptr", __VLC_Ptr($__tStr2), "uint", $rate, "uint", $channels)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_audio_set_format

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_player_get_length
; Description ...: Get the current movie length (in ms).
; Syntax ........: _libvlc_media_player_get_length($p_mi)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the Media Player
; Return values .: Success - int64: the movie length (in ms), or -1 if there is no media.
;                  Failure - 0, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: libvlc_time_t libvlc_media_player_get_length(libvlc_media_player_t * p_mi)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_player_get_length($p_mi)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, 0) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int64:cdecl", "libvlc_media_player_get_length", "ptr", __VLC_Ptr($p_mi))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, 0)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_player_get_length

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_player_get_time
; Description ...: Get the current movie time (in ms).
; Syntax ........: _libvlc_media_player_get_time($p_mi)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the Media Player
; Return values .: Success - int64: the movie time (in ms), or -1 if there is no media.
;                  Failure - 0, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: libvlc_time_t libvlc_media_player_get_time(libvlc_media_player_t * p_mi)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_player_get_time($p_mi)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, 0) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int64:cdecl", "libvlc_media_player_get_time", "ptr", __VLC_Ptr($p_mi))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, 0)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_player_get_time

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_player_set_time
; Description ...: Set the movie time (in ms).
; Syntax ........: _libvlc_media_player_set_time($p_mi, $i_time)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the Media Player
;                  $i_time              - libvlc_time_t : the movie time (in ms).
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_media_player_set_time(libvlc_media_player_t * p_mi, libvlc_time_t i_time)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_player_set_time($p_mi, $i_time)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_media_player_set_time", "ptr", __VLC_Ptr($p_mi), "int64", $i_time)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_media_player_set_time

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_player_get_position
; Description ...: Get movie position as percentage between 0.0 and 1.0.
; Syntax ........: _libvlc_media_player_get_position($p_mi)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the Media Player
; Return values .: Success - float: movie position, or -1. in case of error
;                  Failure - 0, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: float libvlc_media_player_get_position(libvlc_media_player_t * p_mi)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_player_get_position($p_mi)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, 0) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "float:cdecl", "libvlc_media_player_get_position", "ptr", __VLC_Ptr($p_mi))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, 0)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_player_get_position

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_player_set_position
; Description ...: Set movie position as percentage between 0.0 and 1.0.
; Syntax ........: _libvlc_media_player_set_position($p_mi, $f_pos)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the Media Player
;                  $f_pos               - float : the position
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_media_player_set_position(libvlc_media_player_t * p_mi, float f_pos)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_player_set_position($p_mi, $f_pos)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_media_player_set_position", "ptr", __VLC_Ptr($p_mi), "float", $f_pos)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_media_player_set_position

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_player_set_chapter
; Description ...: Set movie chapter (if applicable).
; Syntax ........: _libvlc_media_player_set_chapter($p_mi, $i_chapter)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the Media Player
;                  $i_chapter           - int : chapter number to play
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_media_player_set_chapter(libvlc_media_player_t * p_mi, int i_chapter)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_player_set_chapter($p_mi, $i_chapter)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_media_player_set_chapter", "ptr", __VLC_Ptr($p_mi), "int", $i_chapter)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_media_player_set_chapter

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_player_get_chapter
; Description ...: Get movie chapter.
; Syntax ........: _libvlc_media_player_get_chapter($p_mi)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the Media Player
; Return values .: Success - int: chapter number currently playing, or -1 if there is no media.
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_media_player_get_chapter(libvlc_media_player_t * p_mi)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_player_get_chapter($p_mi)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_media_player_get_chapter", "ptr", __VLC_Ptr($p_mi))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_player_get_chapter

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_player_get_chapter_count
; Description ...: Get movie chapter count
; Syntax ........: _libvlc_media_player_get_chapter_count($p_mi)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the Media Player
; Return values .: Success - int: number of chapters in movie, or -1.
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_media_player_get_chapter_count(libvlc_media_player_t * p_mi)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_player_get_chapter_count($p_mi)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_media_player_get_chapter_count", "ptr", __VLC_Ptr($p_mi))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_player_get_chapter_count

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_player_will_play
; Description ...: Is the player able to play
; Syntax ........: _libvlc_media_player_will_play($p_mi)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the Media Player
; Return values .: Success - int: 0 on success, -1 on error
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_media_player_will_play(libvlc_media_player_t * p_mi)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_player_will_play($p_mi)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_media_player_will_play", "ptr", __VLC_Ptr($p_mi))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_player_will_play

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_player_get_chapter_count_for_title
; Description ...: Get title chapter count
; Syntax ........: _libvlc_media_player_get_chapter_count_for_title($p_mi, $i_title)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the Media Player
;                  $i_title             - int : title
; Return values .: Success - int: number of chapters in title, or -1
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_media_player_get_chapter_count_for_title(libvlc_media_player_t * p_mi, int
;                  i_title)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_player_get_chapter_count_for_title($p_mi, $i_title)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_media_player_get_chapter_count_for_title", "ptr", __VLC_Ptr($p_mi), "int", $i_title)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_player_get_chapter_count_for_title

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_player_set_title
; Description ...: Set movie title
; Syntax ........: _libvlc_media_player_set_title($p_mi, $i_title)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the Media Player
;                  $i_title             - int : title number to play
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_media_player_set_title(libvlc_media_player_t * p_mi, int i_title)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_player_set_title($p_mi, $i_title)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_media_player_set_title", "ptr", __VLC_Ptr($p_mi), "int", $i_title)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_media_player_set_title

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_player_get_title
; Description ...: Get movie title
; Syntax ........: _libvlc_media_player_get_title($p_mi)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the Media Player
; Return values .: Success - int: title number currently playing, or -1
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_media_player_get_title(libvlc_media_player_t * p_mi)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_player_get_title($p_mi)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_media_player_get_title", "ptr", __VLC_Ptr($p_mi))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_player_get_title

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_player_get_title_count
; Description ...: Get movie title count
; Syntax ........: _libvlc_media_player_get_title_count($p_mi)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the Media Player
; Return values .: Success - int: title number count, or -1
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_media_player_get_title_count(libvlc_media_player_t * p_mi)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_player_get_title_count($p_mi)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_media_player_get_title_count", "ptr", __VLC_Ptr($p_mi))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_player_get_title_count

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_player_previous_chapter
; Description ...: Set previous chapter (if applicable)
; Syntax ........: _libvlc_media_player_previous_chapter($p_mi)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the Media Player
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_media_player_previous_chapter(libvlc_media_player_t * p_mi)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_player_previous_chapter($p_mi)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_media_player_previous_chapter", "ptr", __VLC_Ptr($p_mi))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_media_player_previous_chapter

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_player_next_chapter
; Description ...: Set next chapter (if applicable)
; Syntax ........: _libvlc_media_player_next_chapter($p_mi)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the Media Player
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_media_player_next_chapter(libvlc_media_player_t * p_mi)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_player_next_chapter($p_mi)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_media_player_next_chapter", "ptr", __VLC_Ptr($p_mi))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_media_player_next_chapter

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_player_get_rate
; Description ...: Get the requested movie play rate.
; Syntax ........: _libvlc_media_player_get_rate($p_mi)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the Media Player
; Return values .: Success - float: movie play rate
;                  Failure - 0, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: float libvlc_media_player_get_rate(libvlc_media_player_t * p_mi)
;                  Warning: Depending on the underlying media, the requested rate may be different from the real
;                  playback rate.
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_player_get_rate($p_mi)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, 0) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "float:cdecl", "libvlc_media_player_get_rate", "ptr", __VLC_Ptr($p_mi))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, 0)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_player_get_rate

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_player_set_rate
; Description ...: Set movie play rate
; Syntax ........: _libvlc_media_player_set_rate($p_mi, $rate)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the Media Player
;                  $rate                - float : movie play rate to set
; Return values .: Success - int: -1 if an error was detected, 0 otherwise (but even then, it might not actually
;                  work depending on the underlying media protocol)
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_media_player_set_rate(libvlc_media_player_t * p_mi, float rate)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_player_set_rate($p_mi, $rate)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_media_player_set_rate", "ptr", __VLC_Ptr($p_mi), "float", $rate)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_player_set_rate

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_player_get_state
; Description ...: Get current movie state
; Syntax ........: _libvlc_media_player_get_state($p_mi)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the Media Player
; Return values .: Success - int: the current state of the media player (playing, paused, ...)
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: libvlc_state_t libvlc_media_player_get_state(libvlc_media_player_t * p_mi)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_player_get_state($p_mi)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_media_player_get_state", "ptr", __VLC_Ptr($p_mi))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_player_get_state

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_player_has_vout
; Description ...: How many video outputs does this media player have?
; Syntax ........: _libvlc_media_player_has_vout($p_mi)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the media player
; Return values .: Success - uint: the number of video outputs
;                  Failure - 0, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: unsigned libvlc_media_player_has_vout(libvlc_media_player_t * p_mi)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_player_has_vout($p_mi)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, 0) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "uint:cdecl", "libvlc_media_player_has_vout", "ptr", __VLC_Ptr($p_mi))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, 0)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_player_has_vout

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_player_is_seekable
; Description ...: Is this media player seekable?
; Syntax ........: _libvlc_media_player_is_seekable($p_mi)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the media player
; Return values .: Success - int: 0 on success, -1 on error
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_media_player_is_seekable(libvlc_media_player_t * p_mi)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_player_is_seekable($p_mi)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_media_player_is_seekable", "ptr", __VLC_Ptr($p_mi))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_player_is_seekable

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_player_can_pause
; Description ...: Can this media player be paused?
; Syntax ........: _libvlc_media_player_can_pause($p_mi)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the media player
; Return values .: Success - int: 0 on success, -1 on error
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_media_player_can_pause(libvlc_media_player_t * p_mi)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_player_can_pause($p_mi)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_media_player_can_pause", "ptr", __VLC_Ptr($p_mi))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_player_can_pause

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_player_program_scrambled
; Description ...: Check if the current program is scrambled
; Syntax ........: _libvlc_media_player_program_scrambled($p_mi)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the media player
; Return values .: Success - int: 0 on success, -1 on error
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_media_player_program_scrambled(libvlc_media_player_t * p_mi)
;                  Version: LibVLC 2.2.0 or later
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_player_program_scrambled($p_mi)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_media_player_program_scrambled", "ptr", __VLC_Ptr($p_mi))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_player_program_scrambled

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_player_next_frame
; Description ...: Display the next frame (if supported)
; Syntax ........: _libvlc_media_player_next_frame($p_mi)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the media player
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_media_player_next_frame(libvlc_media_player_t * p_mi)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_player_next_frame($p_mi)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_media_player_next_frame", "ptr", __VLC_Ptr($p_mi))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_media_player_next_frame

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_player_navigate
; Description ...: Navigate through DVD Menu
; Syntax ........: _libvlc_media_player_navigate($p_mi, $navigate)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the Media Player
;                  $navigate            - unsigned : the Navigation mode
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_media_player_navigate(libvlc_media_player_t * p_mi, unsigned navigate)
;                  Version: libVLC 2.0.0 or later
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_player_navigate($p_mi, $navigate)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_media_player_navigate", "ptr", __VLC_Ptr($p_mi), "uint", $navigate)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_media_player_navigate

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_player_set_video_title_display
; Description ...: Set if, and how, the video title will be shown when media is played.
; Syntax ........: _libvlc_media_player_set_video_title_display($p_mi, $position, $timeout)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the media player
;                  $position            - libvlc_position_t : position at which to display the title, or libvlc_position_disable to
;                                       - prevent the title from being displayed
;                  $timeout             - unsigned int : title display timeout in milliseconds (ignored if libvlc_position_disable)
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_media_player_set_video_title_display(libvlc_media_player_t * p_mi,
;                  libvlc_position_t position, unsigned int timeout)
;                  Version: libVLC 2.1.0 or later
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_player_set_video_title_display($p_mi, $position, $timeout)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_media_player_set_video_title_display", "ptr", __VLC_Ptr($p_mi), "int", $position, "uint", $timeout)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_media_player_set_video_title_display

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_player_add_slave
; Description ...: Add a slave to the current media player.
; Syntax ........: _libvlc_media_player_add_slave($p_mi, $i_type, $psz_uri, $b_select)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the media player
;                  $i_type              - libvlc_media_slave_type_t : subtitle or audio
;                  $psz_uri             - const char * : Uri of the slave (should contain a valid scheme). (string (UTF-8 converted
;                                       - automatically, Null/Default = NULL))
;                  $b_select            - bool : True if this slave should be selected when it's loaded
; Return values .: Success - int: 0 on success, -1 on error.
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_media_player_add_slave(libvlc_media_player_t * p_mi, libvlc_media_slave_type_t
;                  i_type, const char * psz_uri, bool b_select)
;                  Version: LibVLC 3.0.0 and later.
;                  Note: If the player is playing, the slave will be added directly. This call will also update
;                  the slave list of the attached libvlc_media_t.
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_player_add_slave($p_mi, $i_type, $psz_uri, $b_select)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__tStr3 = __VLC_Utf8Struct($psz_uri)
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_media_player_add_slave", "ptr", __VLC_Ptr($p_mi), "int", $i_type, "ptr", __VLC_Ptr($__tStr3), "boolean", $b_select)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_player_add_slave

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_track_description_list_release
; Description ...: Release (free) libvlc_track_description_t
; Syntax ........: _libvlc_track_description_list_release($p_track_description)
; Parameters ....: $p_track_description - libvlc_track_description_t * : the structure to release
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_track_description_list_release(libvlc_track_description_t * p_track_description)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_track_description_list_release($p_track_description)
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_track_description_list_release", "ptr", __VLC_Ptr($p_track_description))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_track_description_list_release

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_toggle_fullscreen
; Description ...: Toggle fullscreen status on non-embedded video outputs.
; Syntax ........: _libvlc_toggle_fullscreen($p_mi)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the media player
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_toggle_fullscreen(libvlc_media_player_t * p_mi)
;                  Warning: The same limitations applies to this function as to libvlc_set_fullscreen().
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_toggle_fullscreen($p_mi)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_toggle_fullscreen", "ptr", __VLC_Ptr($p_mi))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_toggle_fullscreen

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_set_fullscreen
; Description ...: Enable or disable fullscreen.
; Syntax ........: _libvlc_set_fullscreen($p_mi, $b_fullscreen)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the media player
;                  $b_fullscreen        - int : boolean for fullscreen status
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_set_fullscreen(libvlc_media_player_t * p_mi, int b_fullscreen)
;                  Warning: With most window managers, only a top-level windows can be in full-screen mode. Hence,
;                  this function will not operate properly if libvlc_media_player_set_xwindow() was used to embed
;                  the video in a non-top-level window. In that case, the embedding window must be reparented to
;                  the root window before fullscreen mode is enabled. You will want to reparent it back to its
;                  normal parent when disabling fullscreen.
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_set_fullscreen($p_mi, $b_fullscreen)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_set_fullscreen", "ptr", __VLC_Ptr($p_mi), "int", $b_fullscreen)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_set_fullscreen

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_get_fullscreen
; Description ...: Get current fullscreen status.
; Syntax ........: _libvlc_get_fullscreen($p_mi)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the media player
; Return values .: Success - int: 0 on success, -1 on error
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_get_fullscreen(libvlc_media_player_t * p_mi)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_get_fullscreen($p_mi)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_get_fullscreen", "ptr", __VLC_Ptr($p_mi))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_get_fullscreen

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_video_set_key_input
; Description ...: Enable or disable key press events handling, according to the LibVLC hotkeys configuration.
; Syntax ........: _libvlc_video_set_key_input($p_mi, $on)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the media player
;                  $on                  - unsigned : true to handle key press events, false to ignore them.
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_video_set_key_input(libvlc_media_player_t * p_mi, unsigned on)
;                  Note: On X11, there can be only one subscriber for key press and mouse click events per window.
;                  If your application has subscribed to those events for the X window ID of the video widget,
;                  then LibVLC will not be able to handle key presses and mouse clicks in any case.
;                  Warning: This function is only implemented for X11 and Win32 at the moment.
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_video_set_key_input($p_mi, $on)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_video_set_key_input", "ptr", __VLC_Ptr($p_mi), "uint", $on)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_video_set_key_input

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_video_set_mouse_input
; Description ...: Enable or disable mouse click events handling.
; Syntax ........: _libvlc_video_set_mouse_input($p_mi, $on)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the media player
;                  $on                  - unsigned : true to handle mouse click events, false to ignore them.
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_video_set_mouse_input(libvlc_media_player_t * p_mi, unsigned on)
;                  Warning: This function is only implemented for X11 and Win32 at the moment.
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_video_set_mouse_input($p_mi, $on)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_video_set_mouse_input", "ptr", __VLC_Ptr($p_mi), "uint", $on)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_video_set_mouse_input

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_video_get_size
; Description ...: Get the pixel dimensions of a video.
; Syntax ........: _libvlc_video_get_size($p_mi, $num, $px, $py)
; Parameters ....: $p_mi                - libvlc_media_player_t * : media player
;                  $num                 - unsigned : number of the video (starting from, and most commonly 0)
;                  $px                  - [out, ByRef] unsigned * : pointer to get the pixel width [OUT]
;                  $py                  - [out, ByRef] unsigned * : pointer to get the pixel height [OUT]
; Return values .: Success - int: 0 on success, -1 if the specified video does not exist
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_video_get_size(libvlc_media_player_t * p_mi, unsigned num, unsigned * px,
;                  unsigned * py)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_video_get_size($p_mi, $num, ByRef $px, ByRef $py)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_video_get_size", "ptr", __VLC_Ptr($p_mi), "uint", $num, "uint*", 0, "uint*", 0)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	$px = $__aCall[3]
	$py = $__aCall[4]
	Return $__aCall[0]
EndFunc   ;==>_libvlc_video_get_size

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_video_get_cursor
; Description ...: Get the mouse pointer coordinates over a video.
; Syntax ........: _libvlc_video_get_cursor($p_mi, $num, $px, $py)
; Parameters ....: $p_mi                - libvlc_media_player_t * : media player
;                  $num                 - unsigned : number of the video (starting from, and most commonly 0)
;                  $px                  - [out, ByRef] int * : pointer to get the abscissa [OUT]
;                  $py                  - [out, ByRef] int * : pointer to get the ordinate [OUT]
; Return values .: Success - int: 0 on success, -1 if the specified video does not exist
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_video_get_cursor(libvlc_media_player_t * p_mi, unsigned num, int * px, int * py)
;                  Warning: The coordinates may be out-of-date if the pointer is not located on the video
;                  rendering area. LibVLC does not track the pointer if it is outside of the video widget.
;                  Note: LibVLC does not support multiple pointers (it does of course support multiple input
;                  devices sharing the same pointer) at the moment.
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_video_get_cursor($p_mi, $num, ByRef $px, ByRef $py)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_video_get_cursor", "ptr", __VLC_Ptr($p_mi), "uint", $num, "int*", 0, "int*", 0)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	$px = $__aCall[3]
	$py = $__aCall[4]
	Return $__aCall[0]
EndFunc   ;==>_libvlc_video_get_cursor

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_video_get_scale
; Description ...: Get the current video scaling factor.
; Syntax ........: _libvlc_video_get_scale($p_mi)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the media player
; Return values .: Success - float: the currently configured zoom factor, or 0. if the video is set to fit to the
;                  output window/drawable automatically.
;                  Failure - 0, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: float libvlc_video_get_scale(libvlc_media_player_t * p_mi)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_video_get_scale($p_mi)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, 0) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "float:cdecl", "libvlc_video_get_scale", "ptr", __VLC_Ptr($p_mi))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, 0)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_video_get_scale

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_video_set_scale
; Description ...: Set the video scaling factor.
; Syntax ........: _libvlc_video_set_scale($p_mi, $f_factor)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the media player
;                  $f_factor            - float : the scaling factor, or zero
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_video_set_scale(libvlc_media_player_t * p_mi, float f_factor)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_video_set_scale($p_mi, $f_factor)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_video_set_scale", "ptr", __VLC_Ptr($p_mi), "float", $f_factor)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_video_set_scale

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_video_get_aspect_ratio
; Description ...: Get current video aspect ratio.
; Syntax ........: _libvlc_video_get_aspect_ratio($p_mi)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the media player
; Return values .: Success - string (C memory is released automatically): the video aspect ratio or NULL if
;                  unspecified (the result must be released with free() or libvlc_free()).
;                            A NULL result is returned as "" with @extended = 1.
;                  Failure - "", sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: char * libvlc_video_get_aspect_ratio(libvlc_media_player_t * p_mi)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_video_get_aspect_ratio($p_mi)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, "") ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_video_get_aspect_ratio", "ptr", __VLC_Ptr($p_mi))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, "")
	Local $__sRet = __VLC_StrFromPtr($__aCall[0], True)
	Return SetExtended(@extended, $__sRet)
EndFunc   ;==>_libvlc_video_get_aspect_ratio

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_video_set_aspect_ratio
; Description ...: Set new video aspect ratio.
; Syntax ........: _libvlc_video_set_aspect_ratio($p_mi, $psz_aspect)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the media player
;                  $psz_aspect          - const char * : new video aspect-ratio or NULL to reset to default (string (UTF-8 converted
;                                       - automatically, Null/Default = NULL))
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_video_set_aspect_ratio(libvlc_media_player_t * p_mi, const char * psz_aspect)
;                  Note: Invalid aspect ratios are ignored.
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_video_set_aspect_ratio($p_mi, $psz_aspect)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	Local $__tStr2 = __VLC_Utf8Struct($psz_aspect)
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_video_set_aspect_ratio", "ptr", __VLC_Ptr($p_mi), "ptr", __VLC_Ptr($__tStr2))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_video_set_aspect_ratio

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_video_new_viewpoint
; Description ...: Create a video viewpoint structure.
; Syntax ........: _libvlc_video_new_viewpoint()
; Parameters ....: None
; Return values .: Success - pointer: video viewpoint or NULL (the result must be released with free() or
;                  libvlc_free()).
;                  Failure - Ptr(0), sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: libvlc_video_viewpoint_t * libvlc_video_new_viewpoint(void)
;                  Version: LibVLC 3.0.0 and later
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_video_new_viewpoint()
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_video_new_viewpoint")
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, Ptr(0))
	Return $__aCall[0]
EndFunc   ;==>_libvlc_video_new_viewpoint

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_video_update_viewpoint
; Description ...: Update the video viewpoint information.
; Syntax ........: _libvlc_video_update_viewpoint($p_mi, $p_viewpoint, $b_absolute)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the media player
;                  $p_viewpoint         - const libvlc_video_viewpoint_t * : video viewpoint allocated via
;                                       - libvlc_video_new_viewpoint()
;                  $b_absolute          - bool : if true replace the old viewpoint with the new one. If false, increase/decrease it.
; Return values .: Success - int: -1 in case of error, 0 otherwise
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_video_update_viewpoint(libvlc_media_player_t * p_mi, const
;                  libvlc_video_viewpoint_t * p_viewpoint, bool b_absolute)
;                  Version: LibVLC 3.0.0 and later
;                  Note: It is safe to call this function before the media player is started.
;                  Note: the values are set asynchronously, it will be used by the next frame displayed.
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_video_update_viewpoint($p_mi, $p_viewpoint, $b_absolute)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_video_update_viewpoint", "ptr", __VLC_Ptr($p_mi), "ptr", __VLC_Ptr($p_viewpoint), "boolean", $b_absolute)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_video_update_viewpoint

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_video_get_spu
; Description ...: Get current video subtitle.
; Syntax ........: _libvlc_video_get_spu($p_mi)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the media player
; Return values .: Success - int: the video subtitle selected, or -1 if none
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_video_get_spu(libvlc_media_player_t * p_mi)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_video_get_spu($p_mi)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_video_get_spu", "ptr", __VLC_Ptr($p_mi))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_video_get_spu

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_video_get_spu_count
; Description ...: Get the number of available video subtitles.
; Syntax ........: _libvlc_video_get_spu_count($p_mi)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the media player
; Return values .: Success - int: the number of available video subtitles
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_video_get_spu_count(libvlc_media_player_t * p_mi)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_video_get_spu_count($p_mi)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_video_get_spu_count", "ptr", __VLC_Ptr($p_mi))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_video_get_spu_count

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_video_get_spu_description
; Description ...: Get the description of available video subtitles.
; Syntax ........: _libvlc_video_get_spu_description($p_mi)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the media player
; Return values .: Success - pointer: list containing description of available video subtitles. It must be freed
;                  with libvlc_track_description_list_release()
;                  Failure - Ptr(0), sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: libvlc_track_description_t * libvlc_video_get_spu_description(libvlc_media_player_t * p_mi)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_video_get_spu_description($p_mi)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, Ptr(0)) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_video_get_spu_description", "ptr", __VLC_Ptr($p_mi))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, Ptr(0))
	Return $__aCall[0]
EndFunc   ;==>_libvlc_video_get_spu_description

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_video_set_spu
; Description ...: Set new video subtitle.
; Syntax ........: _libvlc_video_set_spu($p_mi, $i_spu)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the media player
;                  $i_spu               - int : video subtitle track to select (i_id from track description)
; Return values .: Success - int: 0 on success, -1 if out of range
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_video_set_spu(libvlc_media_player_t * p_mi, int i_spu)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_video_set_spu($p_mi, $i_spu)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_video_set_spu", "ptr", __VLC_Ptr($p_mi), "int", $i_spu)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_video_set_spu

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_video_get_spu_delay
; Description ...: Get the current subtitle delay.
; Syntax ........: _libvlc_video_get_spu_delay($p_mi)
; Parameters ....: $p_mi                - libvlc_media_player_t * : media player
; Return values .: Success - int64: time (in microseconds) the display of subtitles is being delayed
;                  Failure - 0, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int64_t libvlc_video_get_spu_delay(libvlc_media_player_t * p_mi)
;                  Version: LibVLC 2.0.0 or later
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_video_get_spu_delay($p_mi)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, 0) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int64:cdecl", "libvlc_video_get_spu_delay", "ptr", __VLC_Ptr($p_mi))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, 0)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_video_get_spu_delay

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_video_set_spu_delay
; Description ...: Set the subtitle delay.
; Syntax ........: _libvlc_video_set_spu_delay($p_mi, $i_delay)
; Parameters ....: $p_mi                - libvlc_media_player_t * : media player
;                  $i_delay             - int64_t : time (in microseconds) the display of subtitles should be delayed
; Return values .: Success - int: 0 on success, -1 on error
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_video_set_spu_delay(libvlc_media_player_t * p_mi, int64_t i_delay)
;                  Version: LibVLC 2.0.0 or later
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_video_set_spu_delay($p_mi, $i_delay)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_video_set_spu_delay", "ptr", __VLC_Ptr($p_mi), "int64", $i_delay)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_video_set_spu_delay

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_player_get_full_title_descriptions
; Description ...: Get the full description of available titles
; Syntax ........: _libvlc_media_player_get_full_title_descriptions($p_mi, $titles)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the media player
;                  $titles              - [out, ByRef] libvlc_title_description_t *** : address to store an allocated array of title
;                                       - descriptions descriptions (must be freed with libvlc_title_descriptions_release() by the
;                                       - caller) [OUT]
; Return values .: Success - int: the number of titles (-1 on error)
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_media_player_get_full_title_descriptions(libvlc_media_player_t * p_mi,
;                  libvlc_title_description_t *** titles)
;                  Version: LibVLC 3.0.0 and later.
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_player_get_full_title_descriptions($p_mi, ByRef $titles)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_media_player_get_full_title_descriptions", "ptr", __VLC_Ptr($p_mi), "ptr*", Ptr(0))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	$titles = $__aCall[2]
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_player_get_full_title_descriptions

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_title_descriptions_release
; Description ...: Release a title description
; Syntax ........: _libvlc_title_descriptions_release($p_titles, $i_count)
; Parameters ....: $p_titles            - libvlc_title_description_t ** : title description array to release
;                  $i_count             - unsigned : number of title descriptions to release
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_title_descriptions_release(libvlc_title_description_t ** p_titles, unsigned
;                  i_count)
;                  Version: LibVLC 3.0.0 and later
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_title_descriptions_release($p_titles, $i_count)
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_title_descriptions_release", "ptr", __VLC_Ptr($p_titles), "uint", $i_count)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_title_descriptions_release

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_player_get_full_chapter_descriptions
; Description ...: Get the full description of available chapters
; Syntax ........: _libvlc_media_player_get_full_chapter_descriptions($p_mi, $i_chapters_of_title, $pp_chapters)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the media player
;                  $i_chapters_of_title - int : index of the title to query for chapters (uses current title if set to -1)
;                  $pp_chapters         - [out, ByRef] libvlc_chapter_description_t *** : address to store an allocated array of
;                                       - chapter descriptions descriptions (must be freed with
;                                       - libvlc_chapter_descriptions_release() by the caller) [OUT]
; Return values .: Success - int: the number of chapters (-1 on error)
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_media_player_get_full_chapter_descriptions(libvlc_media_player_t * p_mi, int
;                  i_chapters_of_title, libvlc_chapter_description_t *** pp_chapters)
;                  Version: LibVLC 3.0.0 and later.
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_player_get_full_chapter_descriptions($p_mi, $i_chapters_of_title, ByRef $pp_chapters)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_media_player_get_full_chapter_descriptions", "ptr", __VLC_Ptr($p_mi), "int", $i_chapters_of_title, "ptr*", Ptr(0))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	$pp_chapters = $__aCall[3]
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_player_get_full_chapter_descriptions

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_chapter_descriptions_release
; Description ...: Release a chapter description
; Syntax ........: _libvlc_chapter_descriptions_release($p_chapters, $i_count)
; Parameters ....: $p_chapters          - libvlc_chapter_description_t ** : chapter description array to release
;                  $i_count             - unsigned : number of chapter descriptions to release
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_chapter_descriptions_release(libvlc_chapter_description_t ** p_chapters,
;                  unsigned i_count)
;                  Version: LibVLC 3.0.0 and later
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_chapter_descriptions_release($p_chapters, $i_count)
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_chapter_descriptions_release", "ptr", __VLC_Ptr($p_chapters), "uint", $i_count)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_chapter_descriptions_release

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_video_get_crop_geometry
; Description ...: Get current crop filter geometry.
; Syntax ........: _libvlc_video_get_crop_geometry($p_mi)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the media player
; Return values .: Success - string (C memory is released automatically): the crop filter geometry or NULL if
;                  unset
;                            A NULL result is returned as "" with @extended = 1.
;                  Failure - "", sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: char * libvlc_video_get_crop_geometry(libvlc_media_player_t * p_mi)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_video_get_crop_geometry($p_mi)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, "") ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_video_get_crop_geometry", "ptr", __VLC_Ptr($p_mi))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, "")
	Local $__sRet = __VLC_StrFromPtr($__aCall[0], True)
	Return SetExtended(@extended, $__sRet)
EndFunc   ;==>_libvlc_video_get_crop_geometry

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_video_set_crop_geometry
; Description ...: Set new crop filter geometry.
; Syntax ........: _libvlc_video_set_crop_geometry($p_mi, $psz_geometry)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the media player
;                  $psz_geometry        - const char * : new crop filter geometry (NULL to unset) (string (UTF-8 converted
;                                       - automatically, Null/Default = NULL))
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_video_set_crop_geometry(libvlc_media_player_t * p_mi, const char * psz_geometry)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_video_set_crop_geometry($p_mi, $psz_geometry)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	Local $__tStr2 = __VLC_Utf8Struct($psz_geometry)
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_video_set_crop_geometry", "ptr", __VLC_Ptr($p_mi), "ptr", __VLC_Ptr($__tStr2))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_video_set_crop_geometry

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_video_get_teletext
; Description ...: Get current teletext page requested or 0 if it's disabled.
; Syntax ........: _libvlc_video_get_teletext($p_mi)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the media player
; Return values .: Success - int: the current teletext page requested.
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_video_get_teletext(libvlc_media_player_t * p_mi)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_video_get_teletext($p_mi)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_video_get_teletext", "ptr", __VLC_Ptr($p_mi))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_video_get_teletext

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_video_set_teletext
; Description ...: Set new teletext page to retrieve.
; Syntax ........: _libvlc_video_set_teletext($p_mi, $i_page)
; Parameters ....: $p_mi                - libvlc_media_player_t * : the media player
;                  $i_page              - int : teletex page number requested. This value can be 0 to disable teletext, a number in
;                                       - the range ]0;1000[ to show the requested page, or a libvlc_teletext_key_t. 100 is the
;                                       - default teletext page.
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_video_set_teletext(libvlc_media_player_t * p_mi, int i_page)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_video_set_teletext($p_mi, $i_page)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_video_set_teletext", "ptr", __VLC_Ptr($p_mi), "int", $i_page)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_video_set_teletext

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_video_get_track_count
; Description ...: Get number of available video tracks.
; Syntax ........: _libvlc_video_get_track_count($p_mi)
; Parameters ....: $p_mi                - libvlc_media_player_t * : media player
; Return values .: Success - int: the number of available video tracks (int)
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_video_get_track_count(libvlc_media_player_t * p_mi)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_video_get_track_count($p_mi)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_video_get_track_count", "ptr", __VLC_Ptr($p_mi))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_video_get_track_count

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_video_get_track_description
; Description ...: Get the description of available video tracks.
; Syntax ........: _libvlc_video_get_track_description($p_mi)
; Parameters ....: $p_mi                - libvlc_media_player_t * : media player
; Return values .: Success - pointer: list with description of available video tracks, or NULL on error. It must
;                  be freed with libvlc_track_description_list_release()
;                  Failure - Ptr(0), sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: libvlc_track_description_t * libvlc_video_get_track_description(libvlc_media_player_t *
;                  p_mi)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_video_get_track_description($p_mi)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, Ptr(0)) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_video_get_track_description", "ptr", __VLC_Ptr($p_mi))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, Ptr(0))
	Return $__aCall[0]
EndFunc   ;==>_libvlc_video_get_track_description

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_video_get_track
; Description ...: Get current video track.
; Syntax ........: _libvlc_video_get_track($p_mi)
; Parameters ....: $p_mi                - libvlc_media_player_t * : media player
; Return values .: Success - int: the video track ID (int) or -1 if no active input
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_video_get_track(libvlc_media_player_t * p_mi)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_video_get_track($p_mi)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_video_get_track", "ptr", __VLC_Ptr($p_mi))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_video_get_track

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_video_set_track
; Description ...: Set video track.
; Syntax ........: _libvlc_video_set_track($p_mi, $i_track)
; Parameters ....: $p_mi                - libvlc_media_player_t * : media player
;                  $i_track             - int : the track ID (i_id field from track description)
; Return values .: Success - int: 0 on success, -1 if out of range
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_video_set_track(libvlc_media_player_t * p_mi, int i_track)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_video_set_track($p_mi, $i_track)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_video_set_track", "ptr", __VLC_Ptr($p_mi), "int", $i_track)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_video_set_track

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_video_take_snapshot
; Description ...: Take a snapshot of the current video window.
; Syntax ........: _libvlc_video_take_snapshot($p_mi, $num, $psz_filepath, $i_width, $i_height)
; Parameters ....: $p_mi                - libvlc_media_player_t * : media player instance
;                  $num                 - unsigned : number of video output (typically 0 for the first/only one)
;                  $psz_filepath        - const char * : the path of a file or a folder to save the screenshot into (string (UTF-8
;                                       - converted automatically, Null/Default = NULL))
;                  $i_width             - unsigned int : the snapshot's width
;                  $i_height            - unsigned int : the snapshot's height
; Return values .: Success - int: 0 on success, -1 if the video was not found
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_video_take_snapshot(libvlc_media_player_t * p_mi, unsigned num, const char *
;                  psz_filepath, unsigned int i_width, unsigned int i_height)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_video_take_snapshot($p_mi, $num, $psz_filepath, $i_width, $i_height)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__tStr3 = __VLC_Utf8Struct($psz_filepath)
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_video_take_snapshot", "ptr", __VLC_Ptr($p_mi), "uint", $num, "ptr", __VLC_Ptr($__tStr3), "uint", $i_width, "uint", $i_height)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_video_take_snapshot

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_video_set_deinterlace
; Description ...: Enable or disable deinterlace filter
; Syntax ........: _libvlc_video_set_deinterlace($p_mi, $psz_mode)
; Parameters ....: $p_mi                - libvlc_media_player_t * : libvlc media player
;                  $psz_mode            - const char * : type of deinterlace filter, NULL to disable (string (UTF-8 converted
;                                       - automatically, Null/Default = NULL))
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_video_set_deinterlace(libvlc_media_player_t * p_mi, const char * psz_mode)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_video_set_deinterlace($p_mi, $psz_mode)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	Local $__tStr2 = __VLC_Utf8Struct($psz_mode)
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_video_set_deinterlace", "ptr", __VLC_Ptr($p_mi), "ptr", __VLC_Ptr($__tStr2))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_video_set_deinterlace

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_video_get_marquee_int
; Description ...: Get an integer marquee option value
; Syntax ........: _libvlc_video_get_marquee_int($p_mi, $option)
; Parameters ....: $p_mi                - libvlc_media_player_t * : libvlc media player
;                  $option              - unsigned : marq option to get
; Return values .: Success - int
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_video_get_marquee_int(libvlc_media_player_t * p_mi, unsigned option)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_video_get_marquee_int($p_mi, $option)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_video_get_marquee_int", "ptr", __VLC_Ptr($p_mi), "uint", $option)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_video_get_marquee_int

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_video_get_marquee_string
; Description ...: Get a string marquee option value
; Syntax ........: _libvlc_video_get_marquee_string($p_mi, $option)
; Parameters ....: $p_mi                - libvlc_media_player_t * : libvlc media player
;                  $option              - unsigned : marq option to get
; Return values .: Success - string (C memory is released automatically)
;                            A NULL result is returned as "" with @extended = 1.
;                  Failure - "", sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: char * libvlc_video_get_marquee_string(libvlc_media_player_t * p_mi, unsigned option)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_video_get_marquee_string($p_mi, $option)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, "") ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_video_get_marquee_string", "ptr", __VLC_Ptr($p_mi), "uint", $option)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, "")
	Local $__sRet = __VLC_StrFromPtr($__aCall[0], True)
	Return SetExtended(@extended, $__sRet)
EndFunc   ;==>_libvlc_video_get_marquee_string

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_video_set_marquee_int
; Description ...: Enable, disable or set an integer marquee option Setting libvlc_marquee_Enable has the side effect of enabling (arg !0) or disabling (arg 0) the marq filter.
; Syntax ........: _libvlc_video_set_marquee_int($p_mi, $option, $i_val)
; Parameters ....: $p_mi                - libvlc_media_player_t * : libvlc media player
;                  $option              - unsigned : marq option to set
;                  $i_val               - int : marq option value
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_video_set_marquee_int(libvlc_media_player_t * p_mi, unsigned option, int i_val)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_video_set_marquee_int($p_mi, $option, $i_val)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_video_set_marquee_int", "ptr", __VLC_Ptr($p_mi), "uint", $option, "int", $i_val)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_video_set_marquee_int

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_video_set_marquee_string
; Description ...: Set a marquee string option
; Syntax ........: _libvlc_video_set_marquee_string($p_mi, $option, $psz_text)
; Parameters ....: $p_mi                - libvlc_media_player_t * : libvlc media player
;                  $option              - unsigned : marq option to set
;                  $psz_text            - const char * : marq option value (string (UTF-8 converted automatically, Null/Default =
;                                       - NULL))
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_video_set_marquee_string(libvlc_media_player_t * p_mi, unsigned option, const
;                  char * psz_text)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_video_set_marquee_string($p_mi, $option, $psz_text)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	Local $__tStr3 = __VLC_Utf8Struct($psz_text)
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_video_set_marquee_string", "ptr", __VLC_Ptr($p_mi), "uint", $option, "ptr", __VLC_Ptr($__tStr3))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_video_set_marquee_string

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_video_get_logo_int
; Description ...: Get integer logo option.
; Syntax ........: _libvlc_video_get_logo_int($p_mi, $option)
; Parameters ....: $p_mi                - libvlc_media_player_t * : libvlc media player instance
;                  $option              - unsigned : logo option to get, values of libvlc_video_logo_option_t
; Return values .: Success - int
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_video_get_logo_int(libvlc_media_player_t * p_mi, unsigned option)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_video_get_logo_int($p_mi, $option)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_video_get_logo_int", "ptr", __VLC_Ptr($p_mi), "uint", $option)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_video_get_logo_int

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_video_set_logo_int
; Description ...: Set logo option as integer.
; Syntax ........: _libvlc_video_set_logo_int($p_mi, $option, $value)
; Parameters ....: $p_mi                - libvlc_media_player_t * : libvlc media player instance
;                  $option              - unsigned : logo option to set, values of libvlc_video_logo_option_t
;                  $value               - int : logo option value
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_video_set_logo_int(libvlc_media_player_t * p_mi, unsigned option, int value)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_video_set_logo_int($p_mi, $option, $value)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_video_set_logo_int", "ptr", __VLC_Ptr($p_mi), "uint", $option, "int", $value)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_video_set_logo_int

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_video_set_logo_string
; Description ...: Set logo option as string.
; Syntax ........: _libvlc_video_set_logo_string($p_mi, $option, $psz_value)
; Parameters ....: $p_mi                - libvlc_media_player_t * : libvlc media player instance
;                  $option              - unsigned : logo option to set, values of libvlc_video_logo_option_t
;                  $psz_value           - const char * : logo option value (string (UTF-8 converted automatically, Null/Default =
;                                       - NULL))
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_video_set_logo_string(libvlc_media_player_t * p_mi, unsigned option, const char
;                  * psz_value)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_video_set_logo_string($p_mi, $option, $psz_value)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	Local $__tStr3 = __VLC_Utf8Struct($psz_value)
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_video_set_logo_string", "ptr", __VLC_Ptr($p_mi), "uint", $option, "ptr", __VLC_Ptr($__tStr3))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_video_set_logo_string

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_video_get_adjust_int
; Description ...: Get integer adjust option.
; Syntax ........: _libvlc_video_get_adjust_int($p_mi, $option)
; Parameters ....: $p_mi                - libvlc_media_player_t * : libvlc media player instance
;                  $option              - unsigned : adjust option to get, values of libvlc_video_adjust_option_t
; Return values .: Success - int
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_video_get_adjust_int(libvlc_media_player_t * p_mi, unsigned option)
;                  Version: LibVLC 1.1.1 and later.
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_video_get_adjust_int($p_mi, $option)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_video_get_adjust_int", "ptr", __VLC_Ptr($p_mi), "uint", $option)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_video_get_adjust_int

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_video_set_adjust_int
; Description ...: Set adjust option as integer.
; Syntax ........: _libvlc_video_set_adjust_int($p_mi, $option, $value)
; Parameters ....: $p_mi                - libvlc_media_player_t * : libvlc media player instance
;                  $option              - unsigned : adust option to set, values of libvlc_video_adjust_option_t
;                  $value               - int : adjust option value
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_video_set_adjust_int(libvlc_media_player_t * p_mi, unsigned option, int value)
;                  Version: LibVLC 1.1.1 and later.
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_video_set_adjust_int($p_mi, $option, $value)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_video_set_adjust_int", "ptr", __VLC_Ptr($p_mi), "uint", $option, "int", $value)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_video_set_adjust_int

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_video_get_adjust_float
; Description ...: Get float adjust option.
; Syntax ........: _libvlc_video_get_adjust_float($p_mi, $option)
; Parameters ....: $p_mi                - libvlc_media_player_t * : libvlc media player instance
;                  $option              - unsigned : adjust option to get, values of libvlc_video_adjust_option_t
; Return values .: Success - float
;                  Failure - 0, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: float libvlc_video_get_adjust_float(libvlc_media_player_t * p_mi, unsigned option)
;                  Version: LibVLC 1.1.1 and later.
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_video_get_adjust_float($p_mi, $option)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, 0) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "float:cdecl", "libvlc_video_get_adjust_float", "ptr", __VLC_Ptr($p_mi), "uint", $option)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, 0)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_video_get_adjust_float

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_video_set_adjust_float
; Description ...: Set adjust option as float.
; Syntax ........: _libvlc_video_set_adjust_float($p_mi, $option, $value)
; Parameters ....: $p_mi                - libvlc_media_player_t * : libvlc media player instance
;                  $option              - unsigned : adust option to set, values of libvlc_video_adjust_option_t
;                  $value               - float : adjust option value
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_video_set_adjust_float(libvlc_media_player_t * p_mi, unsigned option, float
;                  value)
;                  Version: LibVLC 1.1.1 and later.
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_video_set_adjust_float($p_mi, $option, $value)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_video_set_adjust_float", "ptr", __VLC_Ptr($p_mi), "uint", $option, "float", $value)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_video_set_adjust_float

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_audio_output_list_get
; Description ...: Gets the list of available audio output modules.
; Syntax ........: _libvlc_audio_output_list_get($p_instance)
; Parameters ....: $p_instance          - libvlc_instance_t * : libvlc instance
; Return values .: Success - pointer: list of available audio outputs. It must be freed with
;                  Failure - Ptr(0), sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_instance is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: libvlc_audio_output_t * libvlc_audio_output_list_get(libvlc_instance_t * p_instance)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_audio_output_list_get($p_instance)
	If __VLC_Ptr($p_instance) = 0 Then Return SetError($VLC_ERR_PARAM, 0, Ptr(0)) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_audio_output_list_get", "ptr", __VLC_Ptr($p_instance))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, Ptr(0))
	Return $__aCall[0]
EndFunc   ;==>_libvlc_audio_output_list_get

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_audio_output_list_release
; Description ...: Frees the list of available audio output modules.
; Syntax ........: _libvlc_audio_output_list_release($p_list)
; Parameters ....: $p_list              - libvlc_audio_output_t * : list with audio outputs for release
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_audio_output_list_release(libvlc_audio_output_t * p_list)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_audio_output_list_release($p_list)
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_audio_output_list_release", "ptr", __VLC_Ptr($p_list))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_audio_output_list_release

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_audio_output_set
; Description ...: Selects an audio output module.
; Syntax ........: _libvlc_audio_output_set($p_mi, $psz_name)
; Parameters ....: $p_mi                - libvlc_media_player_t * : media player
;                  $psz_name            - const char * : name of audio output, use psz_name of (string (UTF-8 converted
;                                       - automatically, Null/Default = NULL))
; Return values .: Success - int: 0 if function succeeded, -1 on error
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_audio_output_set(libvlc_media_player_t * p_mi, const char * psz_name)
;                  Note: Any change will take be effect only after playback is stopped and restarted. Audio output
;                  cannot be changed while playing.
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_audio_output_set($p_mi, $psz_name)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__tStr2 = __VLC_Utf8Struct($psz_name)
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_audio_output_set", "ptr", __VLC_Ptr($p_mi), "ptr", __VLC_Ptr($__tStr2))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_audio_output_set

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_audio_output_device_enum
; Description ...: Gets a list of potential audio output devices,
; Syntax ........: _libvlc_audio_output_device_enum($mp)
; Parameters ....: $mp                  - libvlc_media_player_t * : media player
; Return values .: Success - pointer: A NULL-terminated linked list of potential audio output devices. It must be
;                  freed with libvlc_audio_output_device_list_release()
;                  Failure - Ptr(0), sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $mp is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: libvlc_audio_output_device_t * libvlc_audio_output_device_enum(libvlc_media_player_t * mp)
;                  Version: LibVLC 2.2.0 or later.
;                  Note: Not all audio outputs support enumerating devices. The audio output may be functional
;                  even if the list is empty (NULL).
;                  Note: The list may not be exhaustive.
;                  Warning: Some audio output devices in the list might not actually work in some circumstances.
;                  By default, it is recommended to not specify any explicit audio device.
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_audio_output_device_enum($mp)
	If __VLC_Ptr($mp) = 0 Then Return SetError($VLC_ERR_PARAM, 0, Ptr(0)) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_audio_output_device_enum", "ptr", __VLC_Ptr($mp))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, Ptr(0))
	Return $__aCall[0]
EndFunc   ;==>_libvlc_audio_output_device_enum

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_audio_output_device_list_get
; Description ...: Gets a list of audio output devices for a given audio output module,
; Syntax ........: _libvlc_audio_output_device_list_get($p_instance, $aout)
; Parameters ....: $p_instance          - libvlc_instance_t * : libvlc instance
;                  $aout                - const char * : audio output name (as returned by libvlc_audio_output_list_get()) (string
;                                       - (UTF-8 converted automatically, Null/Default = NULL))
; Return values .: Success - pointer: A NULL-terminated linked list of potential audio output devices. It must be
;                  freed with libvlc_audio_output_device_list_release()
;                  Failure - Ptr(0), sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_instance is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: libvlc_audio_output_device_t * libvlc_audio_output_device_list_get(libvlc_instance_t *
;                  p_instance, const char * aout)
;                  Version: LibVLC 2.1.0 or later.
;                  Note: Not all audio outputs support this. In particular, an empty (NULL) list of devices does
;                  not imply that the specified audio output does not work.
;                  Note: The list might not be exhaustive.
;                  Warning: Some audio output devices in the list might not actually work in some circumstances.
;                  By default, it is recommended to not specify any explicit audio device.
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_audio_output_device_list_get($p_instance, $aout)
	If __VLC_Ptr($p_instance) = 0 Then Return SetError($VLC_ERR_PARAM, 0, Ptr(0)) ; NULL would crash libVLC
	Local $__tStr2 = __VLC_Utf8Struct($aout)
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_audio_output_device_list_get", "ptr", __VLC_Ptr($p_instance), "ptr", __VLC_Ptr($__tStr2))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, Ptr(0))
	Return $__aCall[0]
EndFunc   ;==>_libvlc_audio_output_device_list_get

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_audio_output_device_list_release
; Description ...: Frees a list of available audio output devices.
; Syntax ........: _libvlc_audio_output_device_list_release($p_list)
; Parameters ....: $p_list              - libvlc_audio_output_device_t * : list with audio outputs for release
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_audio_output_device_list_release(libvlc_audio_output_device_t * p_list)
;                  Version: LibVLC 2.1.0 or later.
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_audio_output_device_list_release($p_list)
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_audio_output_device_list_release", "ptr", __VLC_Ptr($p_list))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_audio_output_device_list_release

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_audio_output_device_set
; Description ...: Configures an explicit audio output device.
; Syntax ........: _libvlc_audio_output_device_set($mp, $module, $device_id)
; Parameters ....: $mp                  - libvlc_media_player_t * : media player
;                  $module              - const char * : If NULL, current audio output module. if non-NULL, name of audio output
;                                       - module ( (string (UTF-8 converted automatically, Null/Default = NULL))
;                  $device_id           - const char * : device identifier string (string (UTF-8 converted automatically,
;                                       - Null/Default = NULL))
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $mp is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_audio_output_device_set(libvlc_media_player_t * mp, const char * module, const
;                  char * device_id)
;                  Note: This function does not select the specified audio output plugin.
;                  libvlc_audio_output_set() is used for that purpose.
;                  Warning: The syntax for the device parameter depends on the audio output. Some audio output
;                  modules require further parameters (e.g. a channels map in the case of ALSA).
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_audio_output_device_set($mp, $module, $device_id)
	If __VLC_Ptr($mp) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	Local $__tStr2 = __VLC_Utf8Struct($module)
	Local $__tStr3 = __VLC_Utf8Struct($device_id)
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_audio_output_device_set", "ptr", __VLC_Ptr($mp), "ptr", __VLC_Ptr($__tStr2), "ptr", __VLC_Ptr($__tStr3))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_audio_output_device_set

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_audio_output_device_get
; Description ...: Get the current audio output device identifier.
; Syntax ........: _libvlc_audio_output_device_get($mp)
; Parameters ....: $mp                  - libvlc_media_player_t * : media player
; Return values .: Success - string (C memory is released automatically): the current audio output device
;                  identifier NULL if no device is selected or in case of error (the result must be released with
;                  free() or libvlc_free()).
;                            A NULL result is returned as "" with @extended = 1.
;                  Failure - "", sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $mp is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: char * libvlc_audio_output_device_get(libvlc_media_player_t * mp)
;                  Version: LibVLC 3.0.0 or later.
;                  Warning: The initial value for the current audio output device identifier may not be set or may
;                  be some unknown value. A LibVLC application should compare this value against the known device
;                  identifiers (e.g. those that were previously retrieved by a call to
;                  libvlc_audio_output_device_enum or libvlc_audio_output_device_list_get) to find the current
;                  audio output device. It is possible that the selected audio output device changes (an external
;                  change) without a call to libvlc_audio_output_device_set. That may make this method unsuitable
;                  to use if a LibVLC application is attempting to track dynamic audio device changes as they
;                  happen.
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_audio_output_device_get($mp)
	If __VLC_Ptr($mp) = 0 Then Return SetError($VLC_ERR_PARAM, 0, "") ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_audio_output_device_get", "ptr", __VLC_Ptr($mp))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, "")
	Local $__sRet = __VLC_StrFromPtr($__aCall[0], True)
	Return SetExtended(@extended, $__sRet)
EndFunc   ;==>_libvlc_audio_output_device_get

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_audio_toggle_mute
; Description ...: Toggle mute status.
; Syntax ........: _libvlc_audio_toggle_mute($p_mi)
; Parameters ....: $p_mi                - libvlc_media_player_t * : media player
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_audio_toggle_mute(libvlc_media_player_t * p_mi)
;                  Warning: Toggling mute atomically is not always possible: On some platforms, other processes
;                  can mute the VLC audio playback stream asynchronously. Thus, there is a small race condition
;                  where toggling will not work. See also the limitations of libvlc_audio_set_mute().
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_audio_toggle_mute($p_mi)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_audio_toggle_mute", "ptr", __VLC_Ptr($p_mi))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_audio_toggle_mute

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_audio_get_mute
; Description ...: Get current mute status.
; Syntax ........: _libvlc_audio_get_mute($p_mi)
; Parameters ....: $p_mi                - libvlc_media_player_t * : media player
; Return values .: Success - int: the mute status (boolean) if defined, -1 if undefined/unapplicable
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_audio_get_mute(libvlc_media_player_t * p_mi)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_audio_get_mute($p_mi)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_audio_get_mute", "ptr", __VLC_Ptr($p_mi))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_audio_get_mute

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_audio_set_mute
; Description ...: Set mute status.
; Syntax ........: _libvlc_audio_set_mute($p_mi, $status)
; Parameters ....: $p_mi                - libvlc_media_player_t * : media player
;                  $status              - int : If status is true then mute, otherwise unmute
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_audio_set_mute(libvlc_media_player_t * p_mi, int status)
;                  Warning: This function does not always work. If there are no active audio playback stream, the
;                  mute status might not be available. If digital pass-through (S/PDIF, HDMI...) is in use, muting
;                  may be unapplicable. Also some audio output plugins do not support muting at all.
;                  Note: To force silent playback, disable all audio tracks. This is more efficient and reliable
;                  than mute.
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_audio_set_mute($p_mi, $status)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_audio_set_mute", "ptr", __VLC_Ptr($p_mi), "int", $status)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_audio_set_mute

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_audio_get_volume
; Description ...: Get current software audio volume.
; Syntax ........: _libvlc_audio_get_volume($p_mi)
; Parameters ....: $p_mi                - libvlc_media_player_t * : media player
; Return values .: Success - int: the software volume in percents (0 = mute, 100 = nominal / 0dB)
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_audio_get_volume(libvlc_media_player_t * p_mi)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_audio_get_volume($p_mi)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_audio_get_volume", "ptr", __VLC_Ptr($p_mi))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_audio_get_volume

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_audio_set_volume
; Description ...: Set current software audio volume.
; Syntax ........: _libvlc_audio_set_volume($p_mi, $i_volume)
; Parameters ....: $p_mi                - libvlc_media_player_t * : media player
;                  $i_volume            - int : the volume in percents (0 = mute, 100 = 0dB)
; Return values .: Success - int: 0 if the volume was set, -1 if it was out of range
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_audio_set_volume(libvlc_media_player_t * p_mi, int i_volume)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_audio_set_volume($p_mi, $i_volume)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_audio_set_volume", "ptr", __VLC_Ptr($p_mi), "int", $i_volume)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_audio_set_volume

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_audio_get_track_count
; Description ...: Get number of available audio tracks.
; Syntax ........: _libvlc_audio_get_track_count($p_mi)
; Parameters ....: $p_mi                - libvlc_media_player_t * : media player
; Return values .: Success - int: the number of available audio tracks (int), or -1 if unavailable
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_audio_get_track_count(libvlc_media_player_t * p_mi)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_audio_get_track_count($p_mi)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_audio_get_track_count", "ptr", __VLC_Ptr($p_mi))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_audio_get_track_count

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_audio_get_track_description
; Description ...: Get the description of available audio tracks.
; Syntax ........: _libvlc_audio_get_track_description($p_mi)
; Parameters ....: $p_mi                - libvlc_media_player_t * : media player
; Return values .: Success - pointer: list with description of available audio tracks, or NULL. It must be freed
;                  with libvlc_track_description_list_release()
;                  Failure - Ptr(0), sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: libvlc_track_description_t * libvlc_audio_get_track_description(libvlc_media_player_t *
;                  p_mi)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_audio_get_track_description($p_mi)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, Ptr(0)) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_audio_get_track_description", "ptr", __VLC_Ptr($p_mi))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, Ptr(0))
	Return $__aCall[0]
EndFunc   ;==>_libvlc_audio_get_track_description

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_audio_get_track
; Description ...: Get current audio track.
; Syntax ........: _libvlc_audio_get_track($p_mi)
; Parameters ....: $p_mi                - libvlc_media_player_t * : media player
; Return values .: Success - int: the audio track ID or -1 if no active input.
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_audio_get_track(libvlc_media_player_t * p_mi)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_audio_get_track($p_mi)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_audio_get_track", "ptr", __VLC_Ptr($p_mi))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_audio_get_track

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_audio_set_track
; Description ...: Set current audio track.
; Syntax ........: _libvlc_audio_set_track($p_mi, $i_track)
; Parameters ....: $p_mi                - libvlc_media_player_t * : media player
;                  $i_track             - int : the track ID (i_id field from track description)
; Return values .: Success - int: 0 on success, -1 on error
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_audio_set_track(libvlc_media_player_t * p_mi, int i_track)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_audio_set_track($p_mi, $i_track)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_audio_set_track", "ptr", __VLC_Ptr($p_mi), "int", $i_track)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_audio_set_track

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_audio_get_channel
; Description ...: Get current audio channel.
; Syntax ........: _libvlc_audio_get_channel($p_mi)
; Parameters ....: $p_mi                - libvlc_media_player_t * : media player
; Return values .: Success - int: the audio channel
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_audio_get_channel(libvlc_media_player_t * p_mi)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_audio_get_channel($p_mi)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_audio_get_channel", "ptr", __VLC_Ptr($p_mi))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_audio_get_channel

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_audio_set_channel
; Description ...: Set current audio channel.
; Syntax ........: _libvlc_audio_set_channel($p_mi, $channel)
; Parameters ....: $p_mi                - libvlc_media_player_t * : media player
;                  $channel             - int : the audio channel,
; Return values .: Success - int: 0 on success, -1 on error
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_audio_set_channel(libvlc_media_player_t * p_mi, int channel)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_audio_set_channel($p_mi, $channel)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_audio_set_channel", "ptr", __VLC_Ptr($p_mi), "int", $channel)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_audio_set_channel

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_audio_get_delay
; Description ...: Get current audio delay.
; Syntax ........: _libvlc_audio_get_delay($p_mi)
; Parameters ....: $p_mi                - libvlc_media_player_t * : media player
; Return values .: Success - int64: the audio delay (microseconds)
;                  Failure - 0, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int64_t libvlc_audio_get_delay(libvlc_media_player_t * p_mi)
;                  Version: LibVLC 1.1.1 or later
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_audio_get_delay($p_mi)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, 0) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int64:cdecl", "libvlc_audio_get_delay", "ptr", __VLC_Ptr($p_mi))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, 0)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_audio_get_delay

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_audio_set_delay
; Description ...: Set current audio delay.
; Syntax ........: _libvlc_audio_set_delay($p_mi, $i_delay)
; Parameters ....: $p_mi                - libvlc_media_player_t * : media player
;                  $i_delay             - int64_t : the audio delay (microseconds)
; Return values .: Success - int: 0 on success, -1 on error
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_audio_set_delay(libvlc_media_player_t * p_mi, int64_t i_delay)
;                  Version: LibVLC 1.1.1 or later
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_audio_set_delay($p_mi, $i_delay)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_audio_set_delay", "ptr", __VLC_Ptr($p_mi), "int64", $i_delay)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_audio_set_delay

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_audio_equalizer_get_preset_count
; Description ...: Get the number of equalizer presets.
; Syntax ........: _libvlc_audio_equalizer_get_preset_count()
; Parameters ....: None
; Return values .: Success - uint: number of presets
;                  Failure - 0, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: unsigned libvlc_audio_equalizer_get_preset_count(void)
;                  Version: LibVLC 2.2.0 or later
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_audio_equalizer_get_preset_count()
	Local $__aCall = DllCall($__g_hVLC_Dll, "uint:cdecl", "libvlc_audio_equalizer_get_preset_count")
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, 0)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_audio_equalizer_get_preset_count

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_audio_equalizer_get_preset_name
; Description ...: Get the name of a particular equalizer preset.
; Syntax ........: _libvlc_audio_equalizer_get_preset_name($u_index)
; Parameters ....: $u_index             - unsigned : index of the preset, counting from zero
; Return values .: Success - string: preset name, or NULL if there is no such preset
;                            A NULL result is returned as "" with @extended = 1.
;                  Failure - "", sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: const char * libvlc_audio_equalizer_get_preset_name(unsigned u_index)
;                  Version: LibVLC 2.2.0 or later
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_audio_equalizer_get_preset_name($u_index)
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_audio_equalizer_get_preset_name", "uint", $u_index)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, "")
	Local $__sRet = __VLC_StrFromPtr($__aCall[0], False)
	Return SetExtended(@extended, $__sRet)
EndFunc   ;==>_libvlc_audio_equalizer_get_preset_name

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_audio_equalizer_get_band_count
; Description ...: Get the number of distinct frequency bands for an equalizer.
; Syntax ........: _libvlc_audio_equalizer_get_band_count()
; Parameters ....: None
; Return values .: Success - uint: number of frequency bands
;                  Failure - 0, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: unsigned libvlc_audio_equalizer_get_band_count(void)
;                  Version: LibVLC 2.2.0 or later
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_audio_equalizer_get_band_count()
	Local $__aCall = DllCall($__g_hVLC_Dll, "uint:cdecl", "libvlc_audio_equalizer_get_band_count")
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, 0)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_audio_equalizer_get_band_count

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_audio_equalizer_get_band_frequency
; Description ...: Get a particular equalizer band frequency.
; Syntax ........: _libvlc_audio_equalizer_get_band_frequency($u_index)
; Parameters ....: $u_index             - unsigned : index of the band, counting from zero
; Return values .: Success - float: equalizer band frequency (Hz), or -1 if there is no such band
;                  Failure - 0, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: float libvlc_audio_equalizer_get_band_frequency(unsigned u_index)
;                  Version: LibVLC 2.2.0 or later
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_audio_equalizer_get_band_frequency($u_index)
	Local $__aCall = DllCall($__g_hVLC_Dll, "float:cdecl", "libvlc_audio_equalizer_get_band_frequency", "uint", $u_index)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, 0)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_audio_equalizer_get_band_frequency

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_audio_equalizer_new
; Description ...: Create a new default equalizer, with all frequency values zeroed.
; Syntax ........: _libvlc_audio_equalizer_new()
; Parameters ....: None
; Return values .: Success - pointer: opaque equalizer handle, or NULL on error
;                  Failure - Ptr(0), sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: libvlc_equalizer_t * libvlc_audio_equalizer_new(void)
;                  Version: LibVLC 2.2.0 or later
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_audio_equalizer_new()
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_audio_equalizer_new")
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, Ptr(0))
	Return $__aCall[0]
EndFunc   ;==>_libvlc_audio_equalizer_new

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_audio_equalizer_new_from_preset
; Description ...: Create a new equalizer, with initial frequency values copied from an existing preset.
; Syntax ........: _libvlc_audio_equalizer_new_from_preset($u_index)
; Parameters ....: $u_index             - unsigned : index of the preset, counting from zero
; Return values .: Success - pointer: opaque equalizer handle, or NULL on error
;                  Failure - Ptr(0), sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: libvlc_equalizer_t * libvlc_audio_equalizer_new_from_preset(unsigned u_index)
;                  Version: LibVLC 2.2.0 or later
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_audio_equalizer_new_from_preset($u_index)
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_audio_equalizer_new_from_preset", "uint", $u_index)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, Ptr(0))
	Return $__aCall[0]
EndFunc   ;==>_libvlc_audio_equalizer_new_from_preset

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_audio_equalizer_release
; Description ...: Release a previously created equalizer instance.
; Syntax ........: _libvlc_audio_equalizer_release($p_equalizer)
; Parameters ....: $p_equalizer         - libvlc_equalizer_t * : opaque equalizer handle, or NULL
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_equalizer is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_audio_equalizer_release(libvlc_equalizer_t * p_equalizer)
;                  Version: LibVLC 2.2.0 or later
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_audio_equalizer_release($p_equalizer)
	If __VLC_Ptr($p_equalizer) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_audio_equalizer_release", "ptr", __VLC_Ptr($p_equalizer))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_audio_equalizer_release

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_audio_equalizer_set_preamp
; Description ...: Set a new pre-amplification value for an equalizer.
; Syntax ........: _libvlc_audio_equalizer_set_preamp($p_equalizer, $f_preamp)
; Parameters ....: $p_equalizer         - libvlc_equalizer_t * : valid equalizer handle, must not be NULL
;                  $f_preamp            - float : preamp value (-20.0 to 20.0 Hz)
; Return values .: Success - int: zero on success, -1 on error
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_equalizer is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_audio_equalizer_set_preamp(libvlc_equalizer_t * p_equalizer, float f_preamp)
;                  Version: LibVLC 2.2.0 or later
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_audio_equalizer_set_preamp($p_equalizer, $f_preamp)
	If __VLC_Ptr($p_equalizer) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_audio_equalizer_set_preamp", "ptr", __VLC_Ptr($p_equalizer), "float", $f_preamp)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_audio_equalizer_set_preamp

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_audio_equalizer_get_preamp
; Description ...: Get the current pre-amplification value from an equalizer.
; Syntax ........: _libvlc_audio_equalizer_get_preamp($p_equalizer)
; Parameters ....: $p_equalizer         - libvlc_equalizer_t * : valid equalizer handle, must not be NULL
; Return values .: Success - float: preamp value (Hz)
;                  Failure - 0, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_equalizer is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: float libvlc_audio_equalizer_get_preamp(libvlc_equalizer_t * p_equalizer)
;                  Version: LibVLC 2.2.0 or later
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_audio_equalizer_get_preamp($p_equalizer)
	If __VLC_Ptr($p_equalizer) = 0 Then Return SetError($VLC_ERR_PARAM, 0, 0) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "float:cdecl", "libvlc_audio_equalizer_get_preamp", "ptr", __VLC_Ptr($p_equalizer))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, 0)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_audio_equalizer_get_preamp

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_audio_equalizer_set_amp_at_index
; Description ...: Set a new amplification value for a particular equalizer frequency band.
; Syntax ........: _libvlc_audio_equalizer_set_amp_at_index($p_equalizer, $f_amp, $u_band)
; Parameters ....: $p_equalizer         - libvlc_equalizer_t * : valid equalizer handle, must not be NULL
;                  $f_amp               - float : amplification value (-20.0 to 20.0 Hz)
;                  $u_band              - unsigned : index, counting from zero, of the frequency band to set
; Return values .: Success - int: zero on success, -1 on error
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_equalizer is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_audio_equalizer_set_amp_at_index(libvlc_equalizer_t * p_equalizer, float f_amp,
;                  unsigned u_band)
;                  Version: LibVLC 2.2.0 or later
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_audio_equalizer_set_amp_at_index($p_equalizer, $f_amp, $u_band)
	If __VLC_Ptr($p_equalizer) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_audio_equalizer_set_amp_at_index", "ptr", __VLC_Ptr($p_equalizer), "float", $f_amp, "uint", $u_band)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_audio_equalizer_set_amp_at_index

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_audio_equalizer_get_amp_at_index
; Description ...: Get the amplification value for a particular equalizer frequency band.
; Syntax ........: _libvlc_audio_equalizer_get_amp_at_index($p_equalizer, $u_band)
; Parameters ....: $p_equalizer         - libvlc_equalizer_t * : valid equalizer handle, must not be NULL
;                  $u_band              - unsigned : index, counting from zero, of the frequency band to get
; Return values .: Success - float: amplification value (Hz); NaN if there is no such frequency band
;                  Failure - 0, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_equalizer is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: float libvlc_audio_equalizer_get_amp_at_index(libvlc_equalizer_t * p_equalizer, unsigned
;                  u_band)
;                  Version: LibVLC 2.2.0 or later
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_audio_equalizer_get_amp_at_index($p_equalizer, $u_band)
	If __VLC_Ptr($p_equalizer) = 0 Then Return SetError($VLC_ERR_PARAM, 0, 0) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "float:cdecl", "libvlc_audio_equalizer_get_amp_at_index", "ptr", __VLC_Ptr($p_equalizer), "uint", $u_band)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, 0)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_audio_equalizer_get_amp_at_index

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_player_set_equalizer
; Description ...: Apply new equalizer settings to a media player.
; Syntax ........: _libvlc_media_player_set_equalizer($p_mi, $p_equalizer)
; Parameters ....: $p_mi                - libvlc_media_player_t * : opaque media player handle
;                  $p_equalizer         - libvlc_equalizer_t * : opaque equalizer handle, or NULL to disable the equalizer for this
;                                       - media player
; Return values .: Success - int: zero on success, -1 on error
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_media_player_set_equalizer(libvlc_media_player_t * p_mi, libvlc_equalizer_t *
;                  p_equalizer)
;                  Version: LibVLC 2.2.0 or later
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_player_set_equalizer($p_mi, $p_equalizer)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_media_player_set_equalizer", "ptr", __VLC_Ptr($p_mi), "ptr", __VLC_Ptr($p_equalizer))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_player_set_equalizer

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_player_get_role
; Description ...: Gets the media role.
; Syntax ........: _libvlc_media_player_get_role($p_mi)
; Parameters ....: $p_mi                - libvlc_media_player_t * : media player
; Return values .: Success - int: the media player role (libvlc_media_player_role_t)
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_media_player_get_role(libvlc_media_player_t * p_mi)
;                  Version: LibVLC 3.0.0 and later.
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_player_get_role($p_mi)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_media_player_get_role", "ptr", __VLC_Ptr($p_mi))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_player_get_role

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_player_set_role
; Description ...: Sets the media role.
; Syntax ........: _libvlc_media_player_set_role($p_mi, $role)
; Parameters ....: $p_mi                - libvlc_media_player_t * : media player
;                  $role                - unsigned : the media player role (libvlc_media_player_role_t)
; Return values .: Success - int: 0 on success, -1 on error
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mi is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_media_player_set_role(libvlc_media_player_t * p_mi, unsigned role)
; Related .......:
; Link ..........: include/vlc/libvlc_media_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_player_set_role($p_mi, $role)
	If __VLC_Ptr($p_mi) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_media_player_set_role", "ptr", __VLC_Ptr($p_mi), "uint", $role)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_player_set_role

#EndRegion libvlc_media_player.h

#Region libvlc_media_list.h

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_list_new
; Description ...: Create an empty media list.
; Syntax ........: _libvlc_media_list_new($p_instance)
; Parameters ....: $p_instance          - libvlc_instance_t * : libvlc instance
; Return values .: Success - pointer: empty media list, or NULL on error
;                  Failure - Ptr(0), sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_instance is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: libvlc_media_list_t * libvlc_media_list_new(libvlc_instance_t * p_instance)
; Related .......:
; Link ..........: include/vlc/libvlc_media_list.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_list_new($p_instance)
	If __VLC_Ptr($p_instance) = 0 Then Return SetError($VLC_ERR_PARAM, 0, Ptr(0)) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_media_list_new", "ptr", __VLC_Ptr($p_instance))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, Ptr(0))
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_list_new

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_list_release
; Description ...: Release media list created with libvlc_media_list_new().
; Syntax ........: _libvlc_media_list_release($p_ml)
; Parameters ....: $p_ml                - libvlc_media_list_t * : a media list created with libvlc_media_list_new()
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_ml is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_media_list_release(libvlc_media_list_t * p_ml)
; Related .......:
; Link ..........: include/vlc/libvlc_media_list.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_list_release($p_ml)
	If __VLC_Ptr($p_ml) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_media_list_release", "ptr", __VLC_Ptr($p_ml))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_media_list_release

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_list_retain
; Description ...: Retain reference to a media list
; Syntax ........: _libvlc_media_list_retain($p_ml)
; Parameters ....: $p_ml                - libvlc_media_list_t * : a media list created with libvlc_media_list_new()
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_ml is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_media_list_retain(libvlc_media_list_t * p_ml)
; Related .......:
; Link ..........: include/vlc/libvlc_media_list.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_list_retain($p_ml)
	If __VLC_Ptr($p_ml) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_media_list_retain", "ptr", __VLC_Ptr($p_ml))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_media_list_retain

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_list_set_media
; Description ...: Associate media instance with this media list instance.
; Syntax ........: _libvlc_media_list_set_media($p_ml, $p_md)
; Parameters ....: $p_ml                - libvlc_media_list_t * : a media list instance
;                  $p_md                - libvlc_media_t * : media instance to add
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_ml is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_media_list_set_media(libvlc_media_list_t * p_ml, libvlc_media_t * p_md)
; Related .......:
; Link ..........: include/vlc/libvlc_media_list.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_list_set_media($p_ml, $p_md)
	If __VLC_Ptr($p_ml) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_media_list_set_media", "ptr", __VLC_Ptr($p_ml), "ptr", __VLC_Ptr($p_md))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_media_list_set_media

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_list_media
; Description ...: Get media instance from this media list instance.
; Syntax ........: _libvlc_media_list_media($p_ml)
; Parameters ....: $p_ml                - libvlc_media_list_t * : a media list instance
; Return values .: Success - pointer: media instance
;                  Failure - Ptr(0), sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_ml is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: libvlc_media_t * libvlc_media_list_media(libvlc_media_list_t * p_ml)
; Related .......:
; Link ..........: include/vlc/libvlc_media_list.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_list_media($p_ml)
	If __VLC_Ptr($p_ml) = 0 Then Return SetError($VLC_ERR_PARAM, 0, Ptr(0)) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_media_list_media", "ptr", __VLC_Ptr($p_ml))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, Ptr(0))
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_list_media

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_list_add_media
; Description ...: Add media instance to media list The libvlc_media_list_lock should be held upon entering this function.
; Syntax ........: _libvlc_media_list_add_media($p_ml, $p_md)
; Parameters ....: $p_ml                - libvlc_media_list_t * : a media list instance
;                  $p_md                - libvlc_media_t * : a media instance
; Return values .: Success - int: 0 on success, -1 if the media list is read-only
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_ml is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_media_list_add_media(libvlc_media_list_t * p_ml, libvlc_media_t * p_md)
; Related .......:
; Link ..........: include/vlc/libvlc_media_list.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_list_add_media($p_ml, $p_md)
	If __VLC_Ptr($p_ml) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_media_list_add_media", "ptr", __VLC_Ptr($p_ml), "ptr", __VLC_Ptr($p_md))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_list_add_media

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_list_insert_media
; Description ...: Insert media instance in media list on a position The libvlc_media_list_lock should be held upon entering this function.
; Syntax ........: _libvlc_media_list_insert_media($p_ml, $p_md, $i_pos)
; Parameters ....: $p_ml                - libvlc_media_list_t * : a media list instance
;                  $p_md                - libvlc_media_t * : a media instance
;                  $i_pos               - int : position in array where to insert
; Return values .: Success - int: 0 on success, -1 if the media list is read-only
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_ml is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_media_list_insert_media(libvlc_media_list_t * p_ml, libvlc_media_t * p_md, int
;                  i_pos)
; Related .......:
; Link ..........: include/vlc/libvlc_media_list.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_list_insert_media($p_ml, $p_md, $i_pos)
	If __VLC_Ptr($p_ml) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_media_list_insert_media", "ptr", __VLC_Ptr($p_ml), "ptr", __VLC_Ptr($p_md), "int", $i_pos)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_list_insert_media

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_list_remove_index
; Description ...: Remove media instance from media list on a position The libvlc_media_list_lock should be held upon entering this function.
; Syntax ........: _libvlc_media_list_remove_index($p_ml, $i_pos)
; Parameters ....: $p_ml                - libvlc_media_list_t * : a media list instance
;                  $i_pos               - int : position in array where to insert
; Return values .: Success - int: 0 on success, -1 if the list is read-only or the item was not found
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_ml is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_media_list_remove_index(libvlc_media_list_t * p_ml, int i_pos)
; Related .......:
; Link ..........: include/vlc/libvlc_media_list.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_list_remove_index($p_ml, $i_pos)
	If __VLC_Ptr($p_ml) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_media_list_remove_index", "ptr", __VLC_Ptr($p_ml), "int", $i_pos)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_list_remove_index

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_list_count
; Description ...: Get count on media list items The libvlc_media_list_lock should be held upon entering this function.
; Syntax ........: _libvlc_media_list_count($p_ml)
; Parameters ....: $p_ml                - libvlc_media_list_t * : a media list instance
; Return values .: Success - int: number of items in media list
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_ml is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_media_list_count(libvlc_media_list_t * p_ml)
; Related .......:
; Link ..........: include/vlc/libvlc_media_list.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_list_count($p_ml)
	If __VLC_Ptr($p_ml) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_media_list_count", "ptr", __VLC_Ptr($p_ml))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_list_count

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_list_item_at_index
; Description ...: List media instance in media list at a position The libvlc_media_list_lock should be held upon entering this function.
; Syntax ........: _libvlc_media_list_item_at_index($p_ml, $i_pos)
; Parameters ....: $p_ml                - libvlc_media_list_t * : a media list instance
;                  $i_pos               - int : position in array where to insert
; Return values .: Success - pointer: media instance at position i_pos, or NULL if not found. In case of success,
;                  libvlc_media_retain() is called to increase the refcount on the media.
;                  Failure - Ptr(0), sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_ml is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: libvlc_media_t * libvlc_media_list_item_at_index(libvlc_media_list_t * p_ml, int i_pos)
; Related .......:
; Link ..........: include/vlc/libvlc_media_list.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_list_item_at_index($p_ml, $i_pos)
	If __VLC_Ptr($p_ml) = 0 Then Return SetError($VLC_ERR_PARAM, 0, Ptr(0)) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_media_list_item_at_index", "ptr", __VLC_Ptr($p_ml), "int", $i_pos)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, Ptr(0))
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_list_item_at_index

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_list_index_of_item
; Description ...: Find index position of List media instance in media list.
; Syntax ........: _libvlc_media_list_index_of_item($p_ml, $p_md)
; Parameters ....: $p_ml                - libvlc_media_list_t * : a media list instance
;                  $p_md                - libvlc_media_t * : media instance
; Return values .: Success - int: position of media instance or -1 if media not found
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_ml is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_media_list_index_of_item(libvlc_media_list_t * p_ml, libvlc_media_t * p_md)
; Related .......:
; Link ..........: include/vlc/libvlc_media_list.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_list_index_of_item($p_ml, $p_md)
	If __VLC_Ptr($p_ml) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_media_list_index_of_item", "ptr", __VLC_Ptr($p_ml), "ptr", __VLC_Ptr($p_md))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_list_index_of_item

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_list_is_readonly
; Description ...: This indicates if this media list is read-only from a user point of view
; Syntax ........: _libvlc_media_list_is_readonly($p_ml)
; Parameters ....: $p_ml                - libvlc_media_list_t * : media list instance
; Return values .: Success - int: 0 on success, -1 on error
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_ml is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_media_list_is_readonly(libvlc_media_list_t * p_ml)
; Related .......:
; Link ..........: include/vlc/libvlc_media_list.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_list_is_readonly($p_ml)
	If __VLC_Ptr($p_ml) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_media_list_is_readonly", "ptr", __VLC_Ptr($p_ml))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_list_is_readonly

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_list_lock
; Description ...: Get lock on media list items
; Syntax ........: _libvlc_media_list_lock($p_ml)
; Parameters ....: $p_ml                - libvlc_media_list_t * : a media list instance
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_ml is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_media_list_lock(libvlc_media_list_t * p_ml)
; Related .......:
; Link ..........: include/vlc/libvlc_media_list.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_list_lock($p_ml)
	If __VLC_Ptr($p_ml) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_media_list_lock", "ptr", __VLC_Ptr($p_ml))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_media_list_lock

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_list_unlock
; Description ...: Release lock on media list items The libvlc_media_list_lock should be held upon entering this function.
; Syntax ........: _libvlc_media_list_unlock($p_ml)
; Parameters ....: $p_ml                - libvlc_media_list_t * : a media list instance
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_ml is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_media_list_unlock(libvlc_media_list_t * p_ml)
; Related .......:
; Link ..........: include/vlc/libvlc_media_list.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_list_unlock($p_ml)
	If __VLC_Ptr($p_ml) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_media_list_unlock", "ptr", __VLC_Ptr($p_ml))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_media_list_unlock

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_list_event_manager
; Description ...: Get libvlc_event_manager from this media list instance.
; Syntax ........: _libvlc_media_list_event_manager($p_ml)
; Parameters ....: $p_ml                - libvlc_media_list_t * : a media list instance
; Return values .: Success - pointer: libvlc_event_manager
;                  Failure - Ptr(0), sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_ml is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: libvlc_event_manager_t * libvlc_media_list_event_manager(libvlc_media_list_t * p_ml)
; Related .......:
; Link ..........: include/vlc/libvlc_media_list.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_list_event_manager($p_ml)
	If __VLC_Ptr($p_ml) = 0 Then Return SetError($VLC_ERR_PARAM, 0, Ptr(0)) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_media_list_event_manager", "ptr", __VLC_Ptr($p_ml))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, Ptr(0))
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_list_event_manager

#EndRegion libvlc_media_list.h

#Region libvlc_media_list_player.h

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_list_player_new
; Description ...: Create new media_list_player.
; Syntax ........: _libvlc_media_list_player_new($p_instance)
; Parameters ....: $p_instance          - libvlc_instance_t * : libvlc instance
; Return values .: Success - pointer: media list player instance or NULL on error
;                  Failure - Ptr(0), sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_instance is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: libvlc_media_list_player_t * libvlc_media_list_player_new(libvlc_instance_t * p_instance)
; Related .......:
; Link ..........: include/vlc/libvlc_media_list_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_list_player_new($p_instance)
	If __VLC_Ptr($p_instance) = 0 Then Return SetError($VLC_ERR_PARAM, 0, Ptr(0)) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_media_list_player_new", "ptr", __VLC_Ptr($p_instance))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, Ptr(0))
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_list_player_new

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_list_player_release
; Description ...: Release a media_list_player after use Decrement the reference count of a media player object.
; Syntax ........: _libvlc_media_list_player_release($p_mlp)
; Parameters ....: $p_mlp               - libvlc_media_list_player_t * : media list player instance
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mlp is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_media_list_player_release(libvlc_media_list_player_t * p_mlp)
; Related .......:
; Link ..........: include/vlc/libvlc_media_list_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_list_player_release($p_mlp)
	If __VLC_Ptr($p_mlp) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_media_list_player_release", "ptr", __VLC_Ptr($p_mlp))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_media_list_player_release

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_list_player_retain
; Description ...: Retain a reference to a media player list object.
; Syntax ........: _libvlc_media_list_player_retain($p_mlp)
; Parameters ....: $p_mlp               - libvlc_media_list_player_t * : media player list object
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mlp is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_media_list_player_retain(libvlc_media_list_player_t * p_mlp)
; Related .......:
; Link ..........: include/vlc/libvlc_media_list_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_list_player_retain($p_mlp)
	If __VLC_Ptr($p_mlp) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_media_list_player_retain", "ptr", __VLC_Ptr($p_mlp))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_media_list_player_retain

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_list_player_event_manager
; Description ...: Return the event manager of this media_list_player.
; Syntax ........: _libvlc_media_list_player_event_manager($p_mlp)
; Parameters ....: $p_mlp               - libvlc_media_list_player_t * : media list player instance
; Return values .: Success - pointer: the event manager
;                  Failure - Ptr(0), sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mlp is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: libvlc_event_manager_t * libvlc_media_list_player_event_manager(libvlc_media_list_player_t *
;                  p_mlp)
; Related .......:
; Link ..........: include/vlc/libvlc_media_list_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_list_player_event_manager($p_mlp)
	If __VLC_Ptr($p_mlp) = 0 Then Return SetError($VLC_ERR_PARAM, 0, Ptr(0)) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_media_list_player_event_manager", "ptr", __VLC_Ptr($p_mlp))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, Ptr(0))
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_list_player_event_manager

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_list_player_set_media_player
; Description ...: Replace media player in media_list_player with this instance.
; Syntax ........: _libvlc_media_list_player_set_media_player($p_mlp, $p_mi)
; Parameters ....: $p_mlp               - libvlc_media_list_player_t * : media list player instance
;                  $p_mi                - libvlc_media_player_t * : media player instance
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mlp is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_media_list_player_set_media_player(libvlc_media_list_player_t * p_mlp,
;                  libvlc_media_player_t * p_mi)
; Related .......:
; Link ..........: include/vlc/libvlc_media_list_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_list_player_set_media_player($p_mlp, $p_mi)
	If __VLC_Ptr($p_mlp) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_media_list_player_set_media_player", "ptr", __VLC_Ptr($p_mlp), "ptr", __VLC_Ptr($p_mi))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_media_list_player_set_media_player

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_list_player_get_media_player
; Description ...: Get media player of the media_list_player instance.
; Syntax ........: _libvlc_media_list_player_get_media_player($p_mlp)
; Parameters ....: $p_mlp               - libvlc_media_list_player_t * : media list player instance
; Return values .: Success - pointer: media player instance
;                  Failure - Ptr(0), sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mlp is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: libvlc_media_player_t * libvlc_media_list_player_get_media_player(libvlc_media_list_player_t
;                  * p_mlp)
;                  Note: the caller is responsible for releasing the returned instance
; Related .......:
; Link ..........: include/vlc/libvlc_media_list_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_list_player_get_media_player($p_mlp)
	If __VLC_Ptr($p_mlp) = 0 Then Return SetError($VLC_ERR_PARAM, 0, Ptr(0)) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_media_list_player_get_media_player", "ptr", __VLC_Ptr($p_mlp))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, Ptr(0))
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_list_player_get_media_player

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_list_player_set_media_list
; Description ...: Set the media list associated with the player
; Syntax ........: _libvlc_media_list_player_set_media_list($p_mlp, $p_mlist)
; Parameters ....: $p_mlp               - libvlc_media_list_player_t * : media list player instance
;                  $p_mlist             - libvlc_media_list_t * : list of media
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mlp is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_media_list_player_set_media_list(libvlc_media_list_player_t * p_mlp,
;                  libvlc_media_list_t * p_mlist)
; Related .......:
; Link ..........: include/vlc/libvlc_media_list_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_list_player_set_media_list($p_mlp, $p_mlist)
	If __VLC_Ptr($p_mlp) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_media_list_player_set_media_list", "ptr", __VLC_Ptr($p_mlp), "ptr", __VLC_Ptr($p_mlist))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_media_list_player_set_media_list

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_list_player_play
; Description ...: Play media list
; Syntax ........: _libvlc_media_list_player_play($p_mlp)
; Parameters ....: $p_mlp               - libvlc_media_list_player_t * : media list player instance
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mlp is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_media_list_player_play(libvlc_media_list_player_t * p_mlp)
; Related .......:
; Link ..........: include/vlc/libvlc_media_list_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_list_player_play($p_mlp)
	If __VLC_Ptr($p_mlp) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_media_list_player_play", "ptr", __VLC_Ptr($p_mlp))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_media_list_player_play

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_list_player_pause
; Description ...: Toggle pause (or resume) media list
; Syntax ........: _libvlc_media_list_player_pause($p_mlp)
; Parameters ....: $p_mlp               - libvlc_media_list_player_t * : media list player instance
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mlp is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_media_list_player_pause(libvlc_media_list_player_t * p_mlp)
; Related .......:
; Link ..........: include/vlc/libvlc_media_list_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_list_player_pause($p_mlp)
	If __VLC_Ptr($p_mlp) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_media_list_player_pause", "ptr", __VLC_Ptr($p_mlp))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_media_list_player_pause

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_list_player_set_pause
; Description ...: Pause or resume media list
; Syntax ........: _libvlc_media_list_player_set_pause($p_mlp, $do_pause)
; Parameters ....: $p_mlp               - libvlc_media_list_player_t * : media list player instance
;                  $do_pause            - int : play/resume if zero, pause if non-zero
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mlp is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_media_list_player_set_pause(libvlc_media_list_player_t * p_mlp, int do_pause)
;                  Version: LibVLC 3.0.0 or later
; Related .......:
; Link ..........: include/vlc/libvlc_media_list_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_list_player_set_pause($p_mlp, $do_pause)
	If __VLC_Ptr($p_mlp) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_media_list_player_set_pause", "ptr", __VLC_Ptr($p_mlp), "int", $do_pause)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_media_list_player_set_pause

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_list_player_is_playing
; Description ...: Is media list playing?
; Syntax ........: _libvlc_media_list_player_is_playing($p_mlp)
; Parameters ....: $p_mlp               - libvlc_media_list_player_t * : media list player instance
; Return values .: Success - int: 0 on success, -1 on error
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mlp is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_media_list_player_is_playing(libvlc_media_list_player_t * p_mlp)
; Related .......:
; Link ..........: include/vlc/libvlc_media_list_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_list_player_is_playing($p_mlp)
	If __VLC_Ptr($p_mlp) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_media_list_player_is_playing", "ptr", __VLC_Ptr($p_mlp))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_list_player_is_playing

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_list_player_get_state
; Description ...: Get current libvlc_state of media list player
; Syntax ........: _libvlc_media_list_player_get_state($p_mlp)
; Parameters ....: $p_mlp               - libvlc_media_list_player_t * : media list player instance
; Return values .: Success - int: libvlc_state_t for media list player
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mlp is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: libvlc_state_t libvlc_media_list_player_get_state(libvlc_media_list_player_t * p_mlp)
; Related .......:
; Link ..........: include/vlc/libvlc_media_list_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_list_player_get_state($p_mlp)
	If __VLC_Ptr($p_mlp) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_media_list_player_get_state", "ptr", __VLC_Ptr($p_mlp))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_list_player_get_state

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_list_player_play_item_at_index
; Description ...: Play media list item at position index
; Syntax ........: _libvlc_media_list_player_play_item_at_index($p_mlp, $i_index)
; Parameters ....: $p_mlp               - libvlc_media_list_player_t * : media list player instance
;                  $i_index             - int : index in media list to play
; Return values .: Success - int: 0 upon success -1 if the item wasn't found
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mlp is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_media_list_player_play_item_at_index(libvlc_media_list_player_t * p_mlp, int
;                  i_index)
; Related .......:
; Link ..........: include/vlc/libvlc_media_list_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_list_player_play_item_at_index($p_mlp, $i_index)
	If __VLC_Ptr($p_mlp) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_media_list_player_play_item_at_index", "ptr", __VLC_Ptr($p_mlp), "int", $i_index)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_list_player_play_item_at_index

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_list_player_play_item
; Description ...: Play the given media item
; Syntax ........: _libvlc_media_list_player_play_item($p_mlp, $p_md)
; Parameters ....: $p_mlp               - libvlc_media_list_player_t * : media list player instance
;                  $p_md                - libvlc_media_t * : the media instance
; Return values .: Success - int: 0 upon success, -1 if the media is not part of the media list
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mlp is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_media_list_player_play_item(libvlc_media_list_player_t * p_mlp, libvlc_media_t *
;                  p_md)
; Related .......:
; Link ..........: include/vlc/libvlc_media_list_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_list_player_play_item($p_mlp, $p_md)
	If __VLC_Ptr($p_mlp) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_media_list_player_play_item", "ptr", __VLC_Ptr($p_mlp), "ptr", __VLC_Ptr($p_md))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_list_player_play_item

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_list_player_stop
; Description ...: Stop playing media list
; Syntax ........: _libvlc_media_list_player_stop($p_mlp)
; Parameters ....: $p_mlp               - libvlc_media_list_player_t * : media list player instance
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mlp is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_media_list_player_stop(libvlc_media_list_player_t * p_mlp)
; Related .......:
; Link ..........: include/vlc/libvlc_media_list_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_list_player_stop($p_mlp)
	If __VLC_Ptr($p_mlp) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_media_list_player_stop", "ptr", __VLC_Ptr($p_mlp))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_media_list_player_stop

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_list_player_next
; Description ...: Play next item from media list
; Syntax ........: _libvlc_media_list_player_next($p_mlp)
; Parameters ....: $p_mlp               - libvlc_media_list_player_t * : media list player instance
; Return values .: Success - int: 0 upon success -1 if there is no next item
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mlp is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_media_list_player_next(libvlc_media_list_player_t * p_mlp)
; Related .......:
; Link ..........: include/vlc/libvlc_media_list_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_list_player_next($p_mlp)
	If __VLC_Ptr($p_mlp) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_media_list_player_next", "ptr", __VLC_Ptr($p_mlp))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_list_player_next

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_list_player_previous
; Description ...: Play previous item from media list
; Syntax ........: _libvlc_media_list_player_previous($p_mlp)
; Parameters ....: $p_mlp               - libvlc_media_list_player_t * : media list player instance
; Return values .: Success - int: 0 upon success -1 if there is no previous item
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mlp is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_media_list_player_previous(libvlc_media_list_player_t * p_mlp)
; Related .......:
; Link ..........: include/vlc/libvlc_media_list_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_list_player_previous($p_mlp)
	If __VLC_Ptr($p_mlp) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_media_list_player_previous", "ptr", __VLC_Ptr($p_mlp))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_list_player_previous

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_list_player_set_playback_mode
; Description ...: Sets the playback mode for the playlist
; Syntax ........: _libvlc_media_list_player_set_playback_mode($p_mlp, $e_mode)
; Parameters ....: $p_mlp               - libvlc_media_list_player_t * : media list player instance
;                  $e_mode              - libvlc_playback_mode_t : playback mode specification
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mlp is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_media_list_player_set_playback_mode(libvlc_media_list_player_t * p_mlp,
;                  libvlc_playback_mode_t e_mode)
; Related .......:
; Link ..........: include/vlc/libvlc_media_list_player.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_list_player_set_playback_mode($p_mlp, $e_mode)
	If __VLC_Ptr($p_mlp) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_media_list_player_set_playback_mode", "ptr", __VLC_Ptr($p_mlp), "int", $e_mode)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_media_list_player_set_playback_mode

#EndRegion libvlc_media_list_player.h

#Region libvlc_media_discoverer.h

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_discoverer_new
; Description ...: Create a media discoverer object by name.
; Syntax ........: _libvlc_media_discoverer_new($p_inst, $psz_name)
; Parameters ....: $p_inst              - libvlc_instance_t * : libvlc instance
;                  $psz_name            - const char * : service name; use libvlc_media_discoverer_list_get() to get a list of the
;                                       - discoverer names available in this libVLC instance (string (UTF-8 converted automatically,
;                                       - Null/Default = NULL))
; Return values .: Success - pointer: media discover object or NULL in case of error
;                  Failure - Ptr(0), sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_inst is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: libvlc_media_discoverer_t * libvlc_media_discoverer_new(libvlc_instance_t * p_inst, const
;                  char * psz_name)
;                  Version: LibVLC 3.0.0 or later
; Related .......:
; Link ..........: include/vlc/libvlc_media_discoverer.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_discoverer_new($p_inst, $psz_name)
	If __VLC_Ptr($p_inst) = 0 Then Return SetError($VLC_ERR_PARAM, 0, Ptr(0)) ; NULL would crash libVLC
	Local $__tStr2 = __VLC_Utf8Struct($psz_name)
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_media_discoverer_new", "ptr", __VLC_Ptr($p_inst), "ptr", __VLC_Ptr($__tStr2))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, Ptr(0))
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_discoverer_new

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_discoverer_start
; Description ...: Start media discovery.
; Syntax ........: _libvlc_media_discoverer_start($p_mdis)
; Parameters ....: $p_mdis              - libvlc_media_discoverer_t * : media discover object
; Return values .: Success - int: -1 in case of error, 0 otherwise
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mdis is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_media_discoverer_start(libvlc_media_discoverer_t * p_mdis)
;                  Version: LibVLC 3.0.0 or later
; Related .......:
; Link ..........: include/vlc/libvlc_media_discoverer.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_discoverer_start($p_mdis)
	If __VLC_Ptr($p_mdis) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_media_discoverer_start", "ptr", __VLC_Ptr($p_mdis))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_discoverer_start

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_discoverer_stop
; Description ...: Stop media discovery.
; Syntax ........: _libvlc_media_discoverer_stop($p_mdis)
; Parameters ....: $p_mdis              - libvlc_media_discoverer_t * : media discover object
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mdis is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_media_discoverer_stop(libvlc_media_discoverer_t * p_mdis)
;                  Version: LibVLC 3.0.0 or later
; Related .......:
; Link ..........: include/vlc/libvlc_media_discoverer.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_discoverer_stop($p_mdis)
	If __VLC_Ptr($p_mdis) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_media_discoverer_stop", "ptr", __VLC_Ptr($p_mdis))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_media_discoverer_stop

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_discoverer_release
; Description ...: Release media discover object.
; Syntax ........: _libvlc_media_discoverer_release($p_mdis)
; Parameters ....: $p_mdis              - libvlc_media_discoverer_t * : media service discover object
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mdis is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_media_discoverer_release(libvlc_media_discoverer_t * p_mdis)
; Related .......:
; Link ..........: include/vlc/libvlc_media_discoverer.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_discoverer_release($p_mdis)
	If __VLC_Ptr($p_mdis) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_media_discoverer_release", "ptr", __VLC_Ptr($p_mdis))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_media_discoverer_release

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_discoverer_media_list
; Description ...: Get media service discover media list.
; Syntax ........: _libvlc_media_discoverer_media_list($p_mdis)
; Parameters ....: $p_mdis              - libvlc_media_discoverer_t * : media service discover object
; Return values .: Success - pointer: list of media items
;                  Failure - Ptr(0), sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mdis is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: libvlc_media_list_t * libvlc_media_discoverer_media_list(libvlc_media_discoverer_t * p_mdis)
; Related .......:
; Link ..........: include/vlc/libvlc_media_discoverer.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_discoverer_media_list($p_mdis)
	If __VLC_Ptr($p_mdis) = 0 Then Return SetError($VLC_ERR_PARAM, 0, Ptr(0)) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_media_discoverer_media_list", "ptr", __VLC_Ptr($p_mdis))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, Ptr(0))
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_discoverer_media_list

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_discoverer_is_running
; Description ...: Query if media service discover object is running.
; Syntax ........: _libvlc_media_discoverer_is_running($p_mdis)
; Parameters ....: $p_mdis              - libvlc_media_discoverer_t * : media service discover object
; Return values .: Success - int: 0 on success, -1 on error
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mdis is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_media_discoverer_is_running(libvlc_media_discoverer_t * p_mdis)
; Related .......:
; Link ..........: include/vlc/libvlc_media_discoverer.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_discoverer_is_running($p_mdis)
	If __VLC_Ptr($p_mdis) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_media_discoverer_is_running", "ptr", __VLC_Ptr($p_mdis))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_discoverer_is_running

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_discoverer_list_get
; Description ...: Get media discoverer services by category
; Syntax ........: _libvlc_media_discoverer_list_get($p_inst, $i_cat, $ppp_services)
; Parameters ....: $p_inst              - libvlc_instance_t * : libvlc instance
;                  $i_cat               - libvlc_media_discoverer_category_t : category of services to fetch
;                  $ppp_services        - [out, ByRef] libvlc_media_discoverer_description_t *** : address to store an allocated
;                                       - array of media discoverer services (must be freed with
;                                       - libvlc_media_discoverer_list_release() by the caller) [OUT]
; Return values .: Success - ulong_ptr: the number of media discoverer services (0 on error)
;                  Failure - 0, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_inst is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: size_t libvlc_media_discoverer_list_get(libvlc_instance_t * p_inst,
;                  libvlc_media_discoverer_category_t i_cat, libvlc_media_discoverer_description_t ***
;                  ppp_services)
;                  Version: LibVLC 3.0.0 and later.
; Related .......:
; Link ..........: include/vlc/libvlc_media_discoverer.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_discoverer_list_get($p_inst, $i_cat, ByRef $ppp_services)
	If __VLC_Ptr($p_inst) = 0 Then Return SetError($VLC_ERR_PARAM, 0, 0) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "ulong_ptr:cdecl", "libvlc_media_discoverer_list_get", "ptr", __VLC_Ptr($p_inst), "int", $i_cat, "ptr*", Ptr(0))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, 0)
	$ppp_services = $__aCall[3]
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_discoverer_list_get

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_discoverer_list_release
; Description ...: Release an array of media discoverer services
; Syntax ........: _libvlc_media_discoverer_list_release($pp_services, $i_count)
; Parameters ....: $pp_services         - libvlc_media_discoverer_description_t ** : array to release
;                  $i_count             - size_t : number of elements in the array
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_media_discoverer_list_release(libvlc_media_discoverer_description_t **
;                  pp_services, size_t i_count)
;                  Version: LibVLC 3.0.0 and later.
; Related .......:
; Link ..........: include/vlc/libvlc_media_discoverer.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_discoverer_list_release($pp_services, $i_count)
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_media_discoverer_list_release", "ptr", __VLC_Ptr($pp_services), "ulong_ptr", $i_count)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_media_discoverer_list_release

#EndRegion libvlc_media_discoverer.h

#Region libvlc_dialog.h

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_dialog_set_callbacks
; Description ...: Register callbacks in order to handle VLC dialogs
; Syntax ........: _libvlc_dialog_set_callbacks($p_instance, $p_cbs, $p_data)
; Parameters ....: $p_instance          - libvlc_instance_t *
;                  $p_cbs               - const libvlc_dialog_cbs * : a pointer to callbacks, or NULL to unregister callbacks.
;                  $p_data              - void * : opaque pointer for the callback
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_instance is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_dialog_set_callbacks(libvlc_instance_t * p_instance, const libvlc_dialog_cbs *
;                  p_cbs, void * p_data)
;                  Version: LibVLC 3.0.0 and later.
; Related .......:
; Link ..........: include/vlc/libvlc_dialog.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_dialog_set_callbacks($p_instance, $p_cbs, $p_data)
	If __VLC_Ptr($p_instance) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_dialog_set_callbacks", "ptr", __VLC_Ptr($p_instance), "ptr", __VLC_Ptr($p_cbs), "ptr", __VLC_Ptr($p_data))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_dialog_set_callbacks

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_dialog_set_context
; Description ...: Associate an opaque pointer with the dialog id
; Syntax ........: _libvlc_dialog_set_context($p_id, $p_context)
; Parameters ....: $p_id                - libvlc_dialog_id *
;                  $p_context           - void *
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_id is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_dialog_set_context(libvlc_dialog_id * p_id, void * p_context)
;                  Version: LibVLC 3.0.0 and later.
; Related .......:
; Link ..........: include/vlc/libvlc_dialog.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_dialog_set_context($p_id, $p_context)
	If __VLC_Ptr($p_id) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_dialog_set_context", "ptr", __VLC_Ptr($p_id), "ptr", __VLC_Ptr($p_context))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_dialog_set_context

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_dialog_get_context
; Description ...: Return the opaque pointer associated with the dialog id
; Syntax ........: _libvlc_dialog_get_context($p_id)
; Parameters ....: $p_id                - libvlc_dialog_id *
; Return values .: Success - pointer
;                  Failure - Ptr(0), sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_id is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void * libvlc_dialog_get_context(libvlc_dialog_id * p_id)
;                  Version: LibVLC 3.0.0 and later.
; Related .......:
; Link ..........: include/vlc/libvlc_dialog.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_dialog_get_context($p_id)
	If __VLC_Ptr($p_id) = 0 Then Return SetError($VLC_ERR_PARAM, 0, Ptr(0)) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_dialog_get_context", "ptr", __VLC_Ptr($p_id))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, Ptr(0))
	Return $__aCall[0]
EndFunc   ;==>_libvlc_dialog_get_context

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_dialog_post_login
; Description ...: Post a login answer After this call, p_id won't be valid anymore
; Syntax ........: _libvlc_dialog_post_login($p_id, $psz_username, $psz_password, $b_store)
; Parameters ....: $p_id                - libvlc_dialog_id * : id of the dialog
;                  $psz_username        - const char * : valid and non empty string (string (UTF-8 converted automatically,
;                                       - Null/Default = NULL))
;                  $psz_password        - const char * : valid string (can be empty) (string (UTF-8 converted automatically,
;                                       - Null/Default = NULL))
;                  $b_store             - bool : if true, store the credentials
; Return values .: Success - int: 0 on success, or -1 on error
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_id is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_dialog_post_login(libvlc_dialog_id * p_id, const char * psz_username, const char
;                  * psz_password, bool b_store)
;                  Version: LibVLC 3.0.0 and later.
; Related .......:
; Link ..........: include/vlc/libvlc_dialog.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_dialog_post_login($p_id, $psz_username, $psz_password, $b_store)
	If __VLC_Ptr($p_id) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__tStr2 = __VLC_Utf8Struct($psz_username)
	Local $__tStr3 = __VLC_Utf8Struct($psz_password)
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_dialog_post_login", "ptr", __VLC_Ptr($p_id), "ptr", __VLC_Ptr($__tStr2), "ptr", __VLC_Ptr($__tStr3), "boolean", $b_store)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_dialog_post_login

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_dialog_post_action
; Description ...: Post a question answer After this call, p_id won't be valid anymore
; Syntax ........: _libvlc_dialog_post_action($p_id, $i_action)
; Parameters ....: $p_id                - libvlc_dialog_id * : id of the dialog
;                  $i_action            - int : 1 for action1, 2 for action2
; Return values .: Success - int: 0 on success, or -1 on error
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_id is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_dialog_post_action(libvlc_dialog_id * p_id, int i_action)
;                  Version: LibVLC 3.0.0 and later.
; Related .......:
; Link ..........: include/vlc/libvlc_dialog.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_dialog_post_action($p_id, $i_action)
	If __VLC_Ptr($p_id) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_dialog_post_action", "ptr", __VLC_Ptr($p_id), "int", $i_action)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_dialog_post_action

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_dialog_dismiss
; Description ...: Dismiss a dialog After this call, p_id won't be valid anymore
; Syntax ........: _libvlc_dialog_dismiss($p_id)
; Parameters ....: $p_id                - libvlc_dialog_id * : id of the dialog
; Return values .: Success - int: 0 on success, or -1 on error
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_id is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_dialog_dismiss(libvlc_dialog_id * p_id)
;                  Version: LibVLC 3.0.0 and later.
; Related .......:
; Link ..........: include/vlc/libvlc_dialog.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_dialog_dismiss($p_id)
	If __VLC_Ptr($p_id) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_dialog_dismiss", "ptr", __VLC_Ptr($p_id))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_dialog_dismiss

#EndRegion libvlc_dialog.h

#Region libvlc_vlm.h

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_vlm_release
; Description ...: Release the vlm instance related to the given libvlc_instance_t
; Syntax ........: _libvlc_vlm_release($p_instance)
; Parameters ....: $p_instance          - libvlc_instance_t * : the instance
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_instance is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_vlm_release(libvlc_instance_t * p_instance)
; Related .......:
; Link ..........: include/vlc/libvlc_vlm.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_vlm_release($p_instance)
	If __VLC_Ptr($p_instance) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_vlm_release", "ptr", __VLC_Ptr($p_instance))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_vlm_release

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_vlm_add_broadcast
; Description ...: Add a broadcast, with one input.
; Syntax ........: _libvlc_vlm_add_broadcast($p_instance, $psz_name, $psz_input, $psz_output, $i_options, $ppsz_options, $b_enabled, $b_loop)
; Parameters ....: $p_instance          - libvlc_instance_t * : the instance
;                  $psz_name            - const char * : the name of the new broadcast (string (UTF-8 converted automatically,
;                                       - Null/Default = NULL))
;                  $psz_input           - const char * : the input MRL (string (UTF-8 converted automatically, Null/Default = NULL))
;                  $psz_output          - const char * : the output MRL (the parameter to the "sout" variable) (string (UTF-8
;                                       - converted automatically, Null/Default = NULL))
;                  $i_options           - int : number of additional options
;                  $ppsz_options        - const char * const * : additional options (array of strings (AutoIt array, converted
;                                       - automatically))
;                  $b_enabled           - int : boolean for enabling the new broadcast
;                  $b_loop              - int : Should this broadcast be played in loop ?
; Return values .: Success - int: 0 on success, -1 on error
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_instance is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_vlm_add_broadcast(libvlc_instance_t * p_instance, const char * psz_name, const
;                  char * psz_input, const char * psz_output, int i_options, const char * const * ppsz_options,
;                  int b_enabled, int b_loop)
; Related .......:
; Link ..........: include/vlc/libvlc_vlm.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_vlm_add_broadcast($p_instance, $psz_name, $psz_input, $psz_output, $i_options, $ppsz_options, $b_enabled, $b_loop)
	If __VLC_Ptr($p_instance) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__tStr2 = __VLC_Utf8Struct($psz_name)
	Local $__tStr3 = __VLC_Utf8Struct($psz_input)
	Local $__tStr4 = __VLC_Utf8Struct($psz_output)
	Local $__aStr6 = __VLC_Utf8Array($ppsz_options)
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_vlm_add_broadcast", "ptr", __VLC_Ptr($p_instance), "ptr", __VLC_Ptr($__tStr2), "ptr", __VLC_Ptr($__tStr3), "ptr", __VLC_Ptr($__tStr4), "int", $i_options, "ptr", __VLC_Utf8ArrayPtr($__aStr6), "int", $b_enabled, "int", $b_loop)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_vlm_add_broadcast

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_vlm_add_vod
; Description ...: Add a vod, with one input.
; Syntax ........: _libvlc_vlm_add_vod($p_instance, $psz_name, $psz_input, $i_options, $ppsz_options, $b_enabled, $psz_mux)
; Parameters ....: $p_instance          - libvlc_instance_t * : the instance
;                  $psz_name            - const char * : the name of the new vod media (string (UTF-8 converted automatically,
;                                       - Null/Default = NULL))
;                  $psz_input           - const char * : the input MRL (string (UTF-8 converted automatically, Null/Default = NULL))
;                  $i_options           - int : number of additional options
;                  $ppsz_options        - const char * const * : additional options (array of strings (AutoIt array, converted
;                                       - automatically))
;                  $b_enabled           - int : boolean for enabling the new vod
;                  $psz_mux             - const char * : the muxer of the vod media (string (UTF-8 converted automatically,
;                                       - Null/Default = NULL))
; Return values .: Success - int: 0 on success, -1 on error
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_instance is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_vlm_add_vod(libvlc_instance_t * p_instance, const char * psz_name, const char *
;                  psz_input, int i_options, const char * const * ppsz_options, int b_enabled, const char *
;                  psz_mux)
; Related .......:
; Link ..........: include/vlc/libvlc_vlm.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_vlm_add_vod($p_instance, $psz_name, $psz_input, $i_options, $ppsz_options, $b_enabled, $psz_mux)
	If __VLC_Ptr($p_instance) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__tStr2 = __VLC_Utf8Struct($psz_name)
	Local $__tStr3 = __VLC_Utf8Struct($psz_input)
	Local $__aStr5 = __VLC_Utf8Array($ppsz_options)
	Local $__tStr7 = __VLC_Utf8Struct($psz_mux)
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_vlm_add_vod", "ptr", __VLC_Ptr($p_instance), "ptr", __VLC_Ptr($__tStr2), "ptr", __VLC_Ptr($__tStr3), "int", $i_options, "ptr", __VLC_Utf8ArrayPtr($__aStr5), "int", $b_enabled, "ptr", __VLC_Ptr($__tStr7))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_vlm_add_vod

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_vlm_del_media
; Description ...: Delete a media (VOD or broadcast).
; Syntax ........: _libvlc_vlm_del_media($p_instance, $psz_name)
; Parameters ....: $p_instance          - libvlc_instance_t * : the instance
;                  $psz_name            - const char * : the media to delete (string (UTF-8 converted automatically, Null/Default =
;                                       - NULL))
; Return values .: Success - int: 0 on success, -1 on error
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_instance is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_vlm_del_media(libvlc_instance_t * p_instance, const char * psz_name)
; Related .......:
; Link ..........: include/vlc/libvlc_vlm.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_vlm_del_media($p_instance, $psz_name)
	If __VLC_Ptr($p_instance) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__tStr2 = __VLC_Utf8Struct($psz_name)
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_vlm_del_media", "ptr", __VLC_Ptr($p_instance), "ptr", __VLC_Ptr($__tStr2))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_vlm_del_media

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_vlm_set_enabled
; Description ...: Enable or disable a media (VOD or broadcast).
; Syntax ........: _libvlc_vlm_set_enabled($p_instance, $psz_name, $b_enabled)
; Parameters ....: $p_instance          - libvlc_instance_t * : the instance
;                  $psz_name            - const char * : the media to work on (string (UTF-8 converted automatically, Null/Default =
;                                       - NULL))
;                  $b_enabled           - int : the new status
; Return values .: Success - int: 0 on success, -1 on error
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_instance is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_vlm_set_enabled(libvlc_instance_t * p_instance, const char * psz_name, int
;                  b_enabled)
; Related .......:
; Link ..........: include/vlc/libvlc_vlm.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_vlm_set_enabled($p_instance, $psz_name, $b_enabled)
	If __VLC_Ptr($p_instance) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__tStr2 = __VLC_Utf8Struct($psz_name)
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_vlm_set_enabled", "ptr", __VLC_Ptr($p_instance), "ptr", __VLC_Ptr($__tStr2), "int", $b_enabled)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_vlm_set_enabled

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_vlm_set_output
; Description ...: Set the output for a media.
; Syntax ........: _libvlc_vlm_set_output($p_instance, $psz_name, $psz_output)
; Parameters ....: $p_instance          - libvlc_instance_t * : the instance
;                  $psz_name            - const char * : the media to work on (string (UTF-8 converted automatically, Null/Default =
;                                       - NULL))
;                  $psz_output          - const char * : the output MRL (the parameter to the "sout" variable) (string (UTF-8
;                                       - converted automatically, Null/Default = NULL))
; Return values .: Success - int: 0 on success, -1 on error
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_instance is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_vlm_set_output(libvlc_instance_t * p_instance, const char * psz_name, const char
;                  * psz_output)
; Related .......:
; Link ..........: include/vlc/libvlc_vlm.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_vlm_set_output($p_instance, $psz_name, $psz_output)
	If __VLC_Ptr($p_instance) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__tStr2 = __VLC_Utf8Struct($psz_name)
	Local $__tStr3 = __VLC_Utf8Struct($psz_output)
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_vlm_set_output", "ptr", __VLC_Ptr($p_instance), "ptr", __VLC_Ptr($__tStr2), "ptr", __VLC_Ptr($__tStr3))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_vlm_set_output

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_vlm_set_input
; Description ...: Set a media's input MRL.
; Syntax ........: _libvlc_vlm_set_input($p_instance, $psz_name, $psz_input)
; Parameters ....: $p_instance          - libvlc_instance_t * : the instance
;                  $psz_name            - const char * : the media to work on (string (UTF-8 converted automatically, Null/Default =
;                                       - NULL))
;                  $psz_input           - const char * : the input MRL (string (UTF-8 converted automatically, Null/Default = NULL))
; Return values .: Success - int: 0 on success, -1 on error
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_instance is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_vlm_set_input(libvlc_instance_t * p_instance, const char * psz_name, const char *
;                  psz_input)
; Related .......:
; Link ..........: include/vlc/libvlc_vlm.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_vlm_set_input($p_instance, $psz_name, $psz_input)
	If __VLC_Ptr($p_instance) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__tStr2 = __VLC_Utf8Struct($psz_name)
	Local $__tStr3 = __VLC_Utf8Struct($psz_input)
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_vlm_set_input", "ptr", __VLC_Ptr($p_instance), "ptr", __VLC_Ptr($__tStr2), "ptr", __VLC_Ptr($__tStr3))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_vlm_set_input

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_vlm_add_input
; Description ...: Add a media's input MRL.
; Syntax ........: _libvlc_vlm_add_input($p_instance, $psz_name, $psz_input)
; Parameters ....: $p_instance          - libvlc_instance_t * : the instance
;                  $psz_name            - const char * : the media to work on (string (UTF-8 converted automatically, Null/Default =
;                                       - NULL))
;                  $psz_input           - const char * : the input MRL (string (UTF-8 converted automatically, Null/Default = NULL))
; Return values .: Success - int: 0 on success, -1 on error
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_instance is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_vlm_add_input(libvlc_instance_t * p_instance, const char * psz_name, const char *
;                  psz_input)
; Related .......:
; Link ..........: include/vlc/libvlc_vlm.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_vlm_add_input($p_instance, $psz_name, $psz_input)
	If __VLC_Ptr($p_instance) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__tStr2 = __VLC_Utf8Struct($psz_name)
	Local $__tStr3 = __VLC_Utf8Struct($psz_input)
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_vlm_add_input", "ptr", __VLC_Ptr($p_instance), "ptr", __VLC_Ptr($__tStr2), "ptr", __VLC_Ptr($__tStr3))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_vlm_add_input

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_vlm_set_loop
; Description ...: Set a media's loop status.
; Syntax ........: _libvlc_vlm_set_loop($p_instance, $psz_name, $b_loop)
; Parameters ....: $p_instance          - libvlc_instance_t * : the instance
;                  $psz_name            - const char * : the media to work on (string (UTF-8 converted automatically, Null/Default =
;                                       - NULL))
;                  $b_loop              - int : the new status
; Return values .: Success - int: 0 on success, -1 on error
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_instance is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_vlm_set_loop(libvlc_instance_t * p_instance, const char * psz_name, int b_loop)
; Related .......:
; Link ..........: include/vlc/libvlc_vlm.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_vlm_set_loop($p_instance, $psz_name, $b_loop)
	If __VLC_Ptr($p_instance) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__tStr2 = __VLC_Utf8Struct($psz_name)
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_vlm_set_loop", "ptr", __VLC_Ptr($p_instance), "ptr", __VLC_Ptr($__tStr2), "int", $b_loop)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_vlm_set_loop

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_vlm_set_mux
; Description ...: Set a media's vod muxer.
; Syntax ........: _libvlc_vlm_set_mux($p_instance, $psz_name, $psz_mux)
; Parameters ....: $p_instance          - libvlc_instance_t * : the instance
;                  $psz_name            - const char * : the media to work on (string (UTF-8 converted automatically, Null/Default =
;                                       - NULL))
;                  $psz_mux             - const char * : the new muxer (string (UTF-8 converted automatically, Null/Default = NULL))
; Return values .: Success - int: 0 on success, -1 on error
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_instance is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_vlm_set_mux(libvlc_instance_t * p_instance, const char * psz_name, const char *
;                  psz_mux)
; Related .......:
; Link ..........: include/vlc/libvlc_vlm.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_vlm_set_mux($p_instance, $psz_name, $psz_mux)
	If __VLC_Ptr($p_instance) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__tStr2 = __VLC_Utf8Struct($psz_name)
	Local $__tStr3 = __VLC_Utf8Struct($psz_mux)
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_vlm_set_mux", "ptr", __VLC_Ptr($p_instance), "ptr", __VLC_Ptr($__tStr2), "ptr", __VLC_Ptr($__tStr3))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_vlm_set_mux

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_vlm_change_media
; Description ...: Edit the parameters of a media.
; Syntax ........: _libvlc_vlm_change_media($p_instance, $psz_name, $psz_input, $psz_output, $i_options, $ppsz_options, $b_enabled, $b_loop)
; Parameters ....: $p_instance          - libvlc_instance_t * : the instance
;                  $psz_name            - const char * : the name of the new broadcast (string (UTF-8 converted automatically,
;                                       - Null/Default = NULL))
;                  $psz_input           - const char * : the input MRL (string (UTF-8 converted automatically, Null/Default = NULL))
;                  $psz_output          - const char * : the output MRL (the parameter to the "sout" variable) (string (UTF-8
;                                       - converted automatically, Null/Default = NULL))
;                  $i_options           - int : number of additional options
;                  $ppsz_options        - const char * const * : additional options (array of strings (AutoIt array, converted
;                                       - automatically))
;                  $b_enabled           - int : boolean for enabling the new broadcast
;                  $b_loop              - int : Should this broadcast be played in loop ?
; Return values .: Success - int: 0 on success, -1 on error
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_instance is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_vlm_change_media(libvlc_instance_t * p_instance, const char * psz_name, const
;                  char * psz_input, const char * psz_output, int i_options, const char * const * ppsz_options,
;                  int b_enabled, int b_loop)
; Related .......:
; Link ..........: include/vlc/libvlc_vlm.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_vlm_change_media($p_instance, $psz_name, $psz_input, $psz_output, $i_options, $ppsz_options, $b_enabled, $b_loop)
	If __VLC_Ptr($p_instance) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__tStr2 = __VLC_Utf8Struct($psz_name)
	Local $__tStr3 = __VLC_Utf8Struct($psz_input)
	Local $__tStr4 = __VLC_Utf8Struct($psz_output)
	Local $__aStr6 = __VLC_Utf8Array($ppsz_options)
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_vlm_change_media", "ptr", __VLC_Ptr($p_instance), "ptr", __VLC_Ptr($__tStr2), "ptr", __VLC_Ptr($__tStr3), "ptr", __VLC_Ptr($__tStr4), "int", $i_options, "ptr", __VLC_Utf8ArrayPtr($__aStr6), "int", $b_enabled, "int", $b_loop)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_vlm_change_media

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_vlm_play_media
; Description ...: Play the named broadcast.
; Syntax ........: _libvlc_vlm_play_media($p_instance, $psz_name)
; Parameters ....: $p_instance          - libvlc_instance_t * : the instance
;                  $psz_name            - const char * : the name of the broadcast (string (UTF-8 converted automatically,
;                                       - Null/Default = NULL))
; Return values .: Success - int: 0 on success, -1 on error
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_instance is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_vlm_play_media(libvlc_instance_t * p_instance, const char * psz_name)
; Related .......:
; Link ..........: include/vlc/libvlc_vlm.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_vlm_play_media($p_instance, $psz_name)
	If __VLC_Ptr($p_instance) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__tStr2 = __VLC_Utf8Struct($psz_name)
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_vlm_play_media", "ptr", __VLC_Ptr($p_instance), "ptr", __VLC_Ptr($__tStr2))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_vlm_play_media

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_vlm_stop_media
; Description ...: Stop the named broadcast.
; Syntax ........: _libvlc_vlm_stop_media($p_instance, $psz_name)
; Parameters ....: $p_instance          - libvlc_instance_t * : the instance
;                  $psz_name            - const char * : the name of the broadcast (string (UTF-8 converted automatically,
;                                       - Null/Default = NULL))
; Return values .: Success - int: 0 on success, -1 on error
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_instance is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_vlm_stop_media(libvlc_instance_t * p_instance, const char * psz_name)
; Related .......:
; Link ..........: include/vlc/libvlc_vlm.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_vlm_stop_media($p_instance, $psz_name)
	If __VLC_Ptr($p_instance) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__tStr2 = __VLC_Utf8Struct($psz_name)
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_vlm_stop_media", "ptr", __VLC_Ptr($p_instance), "ptr", __VLC_Ptr($__tStr2))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_vlm_stop_media

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_vlm_pause_media
; Description ...: Pause the named broadcast.
; Syntax ........: _libvlc_vlm_pause_media($p_instance, $psz_name)
; Parameters ....: $p_instance          - libvlc_instance_t * : the instance
;                  $psz_name            - const char * : the name of the broadcast (string (UTF-8 converted automatically,
;                                       - Null/Default = NULL))
; Return values .: Success - int: 0 on success, -1 on error
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_instance is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_vlm_pause_media(libvlc_instance_t * p_instance, const char * psz_name)
; Related .......:
; Link ..........: include/vlc/libvlc_vlm.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_vlm_pause_media($p_instance, $psz_name)
	If __VLC_Ptr($p_instance) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__tStr2 = __VLC_Utf8Struct($psz_name)
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_vlm_pause_media", "ptr", __VLC_Ptr($p_instance), "ptr", __VLC_Ptr($__tStr2))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_vlm_pause_media

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_vlm_seek_media
; Description ...: Seek in the named broadcast.
; Syntax ........: _libvlc_vlm_seek_media($p_instance, $psz_name, $f_percentage)
; Parameters ....: $p_instance          - libvlc_instance_t * : the instance
;                  $psz_name            - const char * : the name of the broadcast (string (UTF-8 converted automatically,
;                                       - Null/Default = NULL))
;                  $f_percentage        - float : the percentage to seek to
; Return values .: Success - int: 0 on success, -1 on error
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_instance is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_vlm_seek_media(libvlc_instance_t * p_instance, const char * psz_name, float
;                  f_percentage)
; Related .......:
; Link ..........: include/vlc/libvlc_vlm.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_vlm_seek_media($p_instance, $psz_name, $f_percentage)
	If __VLC_Ptr($p_instance) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__tStr2 = __VLC_Utf8Struct($psz_name)
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_vlm_seek_media", "ptr", __VLC_Ptr($p_instance), "ptr", __VLC_Ptr($__tStr2), "float", $f_percentage)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_vlm_seek_media

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_vlm_show_media
; Description ...: Return information about the named media as a JSON string representation.
; Syntax ........: _libvlc_vlm_show_media($p_instance, $psz_name)
; Parameters ....: $p_instance          - libvlc_instance_t * : the instance
;                  $psz_name            - const char * : the name of the media, if the name is an empty string, all media is
;                                       - described (string (UTF-8 converted automatically, Null/Default = NULL))
; Return values .: Success - string: string with information about named media, or NULL on error
;                            A NULL result is returned as "" with @extended = 1.
;                  Failure - "", sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_instance is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: const char * libvlc_vlm_show_media(libvlc_instance_t * p_instance, const char * psz_name)
; Related .......:
; Link ..........: include/vlc/libvlc_vlm.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_vlm_show_media($p_instance, $psz_name)
	If __VLC_Ptr($p_instance) = 0 Then Return SetError($VLC_ERR_PARAM, 0, "") ; NULL would crash libVLC
	Local $__tStr2 = __VLC_Utf8Struct($psz_name)
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_vlm_show_media", "ptr", __VLC_Ptr($p_instance), "ptr", __VLC_Ptr($__tStr2))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, "")
	Local $__sRet = __VLC_StrFromPtr($__aCall[0], False)
	Return SetExtended(@extended, $__sRet)
EndFunc   ;==>_libvlc_vlm_show_media

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_vlm_get_media_instance_position
; Description ...: Get vlm_media instance position by name or instance id
; Syntax ........: _libvlc_vlm_get_media_instance_position($p_instance, $psz_name, $i_instance)
; Parameters ....: $p_instance          - libvlc_instance_t * : a libvlc instance
;                  $psz_name            - const char * : name of vlm media instance (string (UTF-8 converted automatically,
;                                       - Null/Default = NULL))
;                  $i_instance          - int : instance id
; Return values .: Success - float: position as float or -1. on error
;                  Failure - 0, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_instance is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: float libvlc_vlm_get_media_instance_position(libvlc_instance_t * p_instance, const char *
;                  psz_name, int i_instance)
; Related .......:
; Link ..........: include/vlc/libvlc_vlm.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_vlm_get_media_instance_position($p_instance, $psz_name, $i_instance)
	If __VLC_Ptr($p_instance) = 0 Then Return SetError($VLC_ERR_PARAM, 0, 0) ; NULL would crash libVLC
	Local $__tStr2 = __VLC_Utf8Struct($psz_name)
	Local $__aCall = DllCall($__g_hVLC_Dll, "float:cdecl", "libvlc_vlm_get_media_instance_position", "ptr", __VLC_Ptr($p_instance), "ptr", __VLC_Ptr($__tStr2), "int", $i_instance)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, 0)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_vlm_get_media_instance_position

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_vlm_get_media_instance_time
; Description ...: Get vlm_media instance time by name or instance id
; Syntax ........: _libvlc_vlm_get_media_instance_time($p_instance, $psz_name, $i_instance)
; Parameters ....: $p_instance          - libvlc_instance_t * : a libvlc instance
;                  $psz_name            - const char * : name of vlm media instance (string (UTF-8 converted automatically,
;                                       - Null/Default = NULL))
;                  $i_instance          - int : instance id
; Return values .: Success - int: time as integer or -1 on error
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_instance is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_vlm_get_media_instance_time(libvlc_instance_t * p_instance, const char *
;                  psz_name, int i_instance)
; Related .......:
; Link ..........: include/vlc/libvlc_vlm.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_vlm_get_media_instance_time($p_instance, $psz_name, $i_instance)
	If __VLC_Ptr($p_instance) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__tStr2 = __VLC_Utf8Struct($psz_name)
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_vlm_get_media_instance_time", "ptr", __VLC_Ptr($p_instance), "ptr", __VLC_Ptr($__tStr2), "int", $i_instance)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_vlm_get_media_instance_time

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_vlm_get_media_instance_length
; Description ...: Get vlm_media instance length by name or instance id
; Syntax ........: _libvlc_vlm_get_media_instance_length($p_instance, $psz_name, $i_instance)
; Parameters ....: $p_instance          - libvlc_instance_t * : a libvlc instance
;                  $psz_name            - const char * : name of vlm media instance (string (UTF-8 converted automatically,
;                                       - Null/Default = NULL))
;                  $i_instance          - int : instance id
; Return values .: Success - int: length of media item or -1 on error
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_instance is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_vlm_get_media_instance_length(libvlc_instance_t * p_instance, const char *
;                  psz_name, int i_instance)
; Related .......:
; Link ..........: include/vlc/libvlc_vlm.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_vlm_get_media_instance_length($p_instance, $psz_name, $i_instance)
	If __VLC_Ptr($p_instance) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__tStr2 = __VLC_Utf8Struct($psz_name)
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_vlm_get_media_instance_length", "ptr", __VLC_Ptr($p_instance), "ptr", __VLC_Ptr($__tStr2), "int", $i_instance)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_vlm_get_media_instance_length

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_vlm_get_media_instance_rate
; Description ...: Get vlm_media instance playback rate by name or instance id
; Syntax ........: _libvlc_vlm_get_media_instance_rate($p_instance, $psz_name, $i_instance)
; Parameters ....: $p_instance          - libvlc_instance_t * : a libvlc instance
;                  $psz_name            - const char * : name of vlm media instance (string (UTF-8 converted automatically,
;                                       - Null/Default = NULL))
;                  $i_instance          - int : instance id
; Return values .: Success - int: playback rate or -1 on error
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_instance is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_vlm_get_media_instance_rate(libvlc_instance_t * p_instance, const char *
;                  psz_name, int i_instance)
; Related .......:
; Link ..........: include/vlc/libvlc_vlm.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_vlm_get_media_instance_rate($p_instance, $psz_name, $i_instance)
	If __VLC_Ptr($p_instance) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__tStr2 = __VLC_Utf8Struct($psz_name)
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_vlm_get_media_instance_rate", "ptr", __VLC_Ptr($p_instance), "ptr", __VLC_Ptr($__tStr2), "int", $i_instance)
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_vlm_get_media_instance_rate

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_vlm_get_event_manager
; Description ...: Get libvlc_event_manager from a vlm media.
; Syntax ........: _libvlc_vlm_get_event_manager($p_instance)
; Parameters ....: $p_instance          - libvlc_instance_t * : a libvlc instance
; Return values .: Success - pointer: libvlc_event_manager
;                  Failure - Ptr(0), sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_instance is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: libvlc_event_manager_t * libvlc_vlm_get_event_manager(libvlc_instance_t * p_instance)
; Related .......:
; Link ..........: include/vlc/libvlc_vlm.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_vlm_get_event_manager($p_instance)
	If __VLC_Ptr($p_instance) = 0 Then Return SetError($VLC_ERR_PARAM, 0, Ptr(0)) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_vlm_get_event_manager", "ptr", __VLC_Ptr($p_instance))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, Ptr(0))
	Return $__aCall[0]
EndFunc   ;==>_libvlc_vlm_get_event_manager

#EndRegion libvlc_vlm.h

#Region libvlc_media_library.h

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_library_new
; Description ...: Create an new Media Library object
; Syntax ........: _libvlc_media_library_new($p_instance)
; Parameters ....: $p_instance          - libvlc_instance_t * : the libvlc instance
; Return values .: Success - pointer: a new object or NULL on error
;                  Failure - Ptr(0), sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_instance is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: libvlc_media_library_t * libvlc_media_library_new(libvlc_instance_t * p_instance)
; Related .......:
; Link ..........: include/vlc/libvlc_media_library.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_library_new($p_instance)
	If __VLC_Ptr($p_instance) = 0 Then Return SetError($VLC_ERR_PARAM, 0, Ptr(0)) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_media_library_new", "ptr", __VLC_Ptr($p_instance))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, Ptr(0))
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_library_new

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_library_release
; Description ...: Release media library object.
; Syntax ........: _libvlc_media_library_release($p_mlib)
; Parameters ....: $p_mlib              - libvlc_media_library_t * : media library object
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mlib is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_media_library_release(libvlc_media_library_t * p_mlib)
; Related .......:
; Link ..........: include/vlc/libvlc_media_library.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_library_release($p_mlib)
	If __VLC_Ptr($p_mlib) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_media_library_release", "ptr", __VLC_Ptr($p_mlib))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_media_library_release

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_library_retain
; Description ...: Retain a reference to a media library object.
; Syntax ........: _libvlc_media_library_retain($p_mlib)
; Parameters ....: $p_mlib              - libvlc_media_library_t * : media library object
; Return values .: Success - True
;                  Failure - False, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mlib is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: void libvlc_media_library_retain(libvlc_media_library_t * p_mlib)
; Related .......:
; Link ..........: include/vlc/libvlc_media_library.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_library_retain($p_mlib)
	If __VLC_Ptr($p_mlib) = 0 Then Return SetError($VLC_ERR_PARAM, 0, False) ; NULL would crash libVLC
	DllCall($__g_hVLC_Dll, "none:cdecl", "libvlc_media_library_retain", "ptr", __VLC_Ptr($p_mlib))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, False)
	Return True
EndFunc   ;==>_libvlc_media_library_retain

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_library_load
; Description ...: Load media library.
; Syntax ........: _libvlc_media_library_load($p_mlib)
; Parameters ....: $p_mlib              - libvlc_media_library_t * : media library object
; Return values .: Success - int: 0 on success, -1 on error
;                  Failure - -1, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mlib is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: int libvlc_media_library_load(libvlc_media_library_t * p_mlib)
; Related .......:
; Link ..........: include/vlc/libvlc_media_library.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_library_load($p_mlib)
	If __VLC_Ptr($p_mlib) = 0 Then Return SetError($VLC_ERR_PARAM, 0, -1) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "int:cdecl", "libvlc_media_library_load", "ptr", __VLC_Ptr($p_mlib))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, -1)
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_library_load

; #FUNCTION# ============================================================================================================
; Name ..........: _libvlc_media_library_media_list
; Description ...: Get media library subitems.
; Syntax ........: _libvlc_media_library_media_list($p_mlib)
; Parameters ....: $p_mlib              - libvlc_media_library_t * : media library object
; Return values .: Success - pointer: media list subitems
;                  Failure - Ptr(0), sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error
;                            or @error = $VLC_ERR_PARAM if $p_mlib is NULL (would crash libVLC)
; Author ........: CCLibVLC generator (from VLC 3.0 headers)
; Modified ......:
; Remarks .......: C: libvlc_media_list_t * libvlc_media_library_media_list(libvlc_media_library_t * p_mlib)
; Related .......:
; Link ..........: include/vlc/libvlc_media_library.h
; Example .......: No
; =======================================================================================================================
Func _libvlc_media_library_media_list($p_mlib)
	If __VLC_Ptr($p_mlib) = 0 Then Return SetError($VLC_ERR_PARAM, 0, Ptr(0)) ; NULL would crash libVLC
	Local $__aCall = DllCall($__g_hVLC_Dll, "ptr:cdecl", "libvlc_media_library_media_list", "ptr", __VLC_Ptr($p_mlib))
	If @error Then Return SetError($VLC_ERR_DLLCALL, @error, Ptr(0))
	Return $__aCall[0]
EndFunc   ;==>_libvlc_media_library_media_list

#EndRegion libvlc_media_library.h
