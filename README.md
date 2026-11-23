# CCLibVLC – VLC player UDF for AutoIt (libVLC 3.0)

CCLibVLC embeds VLC video in AutoIt GUIs and gives full control of libVLC 3.0 from AutoIt – without ActiveX or Internet Explorer. It supports x86 and x64. It replaces the old `VLC.au3` v0.3 by seangriffin (whose function names it keeps) and `LibVLC.au3` by genius257.

Version 1.0.1 · tested with VLC 3.0.24 and AutoIt 3.3.18.0 · licensed under GPL-3.0-or-later with an attribution term (see [License](#license))

## Contents

| File | Purpose |
| --- | --- |
| `CCGUICtrlVLC.au3` | **Player control** for GUIs (87 `_GUICtrlVLC_*` functions), compatible with VLC.au3 v0.3 |
| `CCLibVLC.au3` | Core: loading libVLC, UTF-8, structures, thread-safe events, worker thread (42 `_VLC_*` functions) |
| `CCLibVLC_Raw.au3` | Raw layer: 266 of the 316 exported libVLC 3.0 functions as `_libvlc_*`, generated from the headers (exceptions see [Function overview](#function-overview)) |
| `CCLibVLC_Constants.au3` | All 219 libVLC constants (`$libvlc_*`) |
| `Examples\` | Player with seek/volume/fullscreen, v0.3-compatible script, raw layer, 2×2 camera wall |
| `Tests\` | Self-tests (core, GUI, stress) |
| `tools\` | Generator for the raw and constants files, assembler sources and emulation test of the native thunks |

Include `#include "CCGUICtrlVLC.au3"`; it pulls in all other files. If you only need the core and raw layer, include `#include "CCLibVLC.au3"`.

## Requirements

- **libVLC 3.0.x with the same bitness as AutoIt.** 32-bit AutoIt (`AutoIt3.exe`) needs 32-bit VLC, `AutoIt3_x64.exe` needs 64-bit VLC. VLC **3.0.24 or newer** is recommended; older versions have more than 130 known security vulnerabilities.
- **Search order:** `_VLC_Startup()` looks for libVLC in this order:
  1. `@ScriptDir\vlc_x64` or `\vlc_x86`
  2. `@ScriptDir\vlc`
  3. `@ScriptDir`
  4. the installed VLC (registry `HKLM\SOFTWARE\VideoLAN\VLC`)
  5. `@ProgramFilesDir\VideoLAN\VLC`

  A directory can also be passed directly: `_VLC_Startup("D:\Tools\vlc-3.0.24")`.
- **Distribution without a VLC installation:** copy `libvlc.dll`, `libvlccore.dll` and the complete `plugins\` folder from the official ZIP (`vlc-3.0.24-win64.zip` or `-win32.zip`) into a subfolder `vlc` next to the script. That's all.
- VLC 4.x is deliberately rejected (`$VLC_ERR_VERSION`) because its API is not compatible with 3.0. See [libVLC 3 and VLC 4](#libvlc-3-and-vlc-4).

## libVLC 3 and VLC 4

**In short:** CCLibVLC supports libVLC **3.0.x** only. A `libvlc.dll` from VLC 4 is detected at startup and rejected with `$VLC_ERR_VERSION` (`@error` 6), so the script gets a clear error instead of crashing.

**Status (November 2026):** VLC 4.0 has not been released as a stable version yet; only nightly builds of the development branch exist. VLC 3.0.x is still maintained and is the current stable version.

**Why VLC 4 does not simply work:**

- **Same file name, different interface.** The libVLC binary interface (ABI) goes from version 5 (VLC 3.0) to 12 (VLC 4). On Linux the library therefore gets a new file name; on Windows both are simply called `libvlc.dll`. Without a version check the UDF would call the new DLL as if it were VLC 3.
- **Removed functions.** In the VLC 4 development state (master, 2026-11-22), 108 functions from 3.0 are gone, 69 of which CCLibVLC uses – among them `libvlc_media_player_stop`, `libvlc_media_parse_with_options`, `libvlc_media_tracks_get` and the entire track description API (`libvlc_audio_set_track`, `libvlc_video_set_spu` …).
- **New event model.** `libvlc_event_attach`/`libvlc_event_detach` no longer exist. VLC 4 delivers events through a callback structure that is passed when the player is created. CCLibVLC's event bridge is built on the old model.
- **Same name, different parameters.** This is the most dangerous part, because `DllCall` cannot detect a wrong parameter list. The result would be a crash or unpredictable behaviour instead of an error message:

| Function | VLC 3.0 | VLC 4 (development state) |
| --- | --- | --- |
| `libvlc_media_new_path` | `(instance, path)` | `(path)` |
| `libvlc_media_new_location` | `(instance, mrl)` | `(mrl)` |
| `libvlc_media_player_new_from_media` | `(media)` | `(instance, media, cbs, opaque)` |
| `libvlc_media_player_set_time` | `(mi, time)` → void | `(mi, time, fast)` → int |
| `libvlc_media_player_set_position` | `(mi, float)` → void | `(mi, double, fast)` → int |
| `libvlc_audio_output_device_set` | `(mp, module, device)` | `(mp, device)` |

**Recommendation for production use:** ship VLC 3.0.x portably next to the script (`libvlc.dll`, `libvlccore.dll` and `plugins\` in the subfolder `vlc`, see [Requirements](#requirements)). This folder is found before the installed VLC, so a later update of the installed VLC to version 4 does not affect the script. Alternatively, pass the directory directly to `_VLC_Startup()`.

**Outlook:** VLC 4 support only makes sense once 4.0 is released as stable, since the API may still change until then. The plan is a separate raw layer generated from the 4.0 headers (the generator in `tools\` is prepared for this) and a version switch in the core, while the public `_GUICtrlVLC_*` functions stay unchanged. VLC 4 also brings improvements: asynchronous stop (`libvlc_media_player_stop_async`) and gapless media switching (`libvlc_media_player_set_next_media`) would make part of today's worker thread logic unnecessary.

## Quick start

```autoit
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include "CCGUICtrlVLC.au3"

Local $hGui = GUICreate("Camera", 960, 560, -1, -1, BitOR($GUI_SS_DEFAULT_GUI, $WS_SIZEBOX, $WS_MAXIMIZEBOX))
Local $iVlc = _GUICtrlVLC_Create(0, 0, 960, 560)
_GUICtrlVLC_SetResizing($iVlc, $GUI_DOCKBORDERS)          ; video follows the window size
GUISetState()
_GUICtrlVLC_Open($iVlc, "rtsp://user:pass@192.168.1.10/stream1", ":network-caching=300|:rtsp-tcp")

While 1
    Switch GUIGetMsg()
        Case $GUI_EVENT_CLOSE
            ExitLoop
        Case _GUICtrlVLC_GetCtrlID($iVlc)                 ; click on the video
            If _GUICtrlVLC_IsDoubleClick($iVlc) Then _GUICtrlVLC_ToggleFullscreen($iVlc)
    EndSwitch
WEnd
```

`_GUICtrlVLC_Create` starts libVLC itself if necessary. Cleanup happens automatically when the script exits.

Special characters in RTSP user names or passwords (`#`, `&`, `@`, `:` …) must be percent-encoded in the URL, otherwise the login fails.

## Migrating from VLC.au3 v0.3 (seangriffin)

In most cases replacing the include line is enough:

| VLC.au3 v0.3 | CCLibVLC | Note |
| --- | --- | --- |
| `#include <VLC.au3>` | `#include "CCGUICtrlVLC.au3"` | |
| `_VLCErrorHandlerRegister()` | kept as a dummy (returns 1) | COM is no longer needed |
| `_GUICtrlVLC_Create(l, t, w, h)` | same | returns a player ID (≥ 1) instead of an object, 0 (= False) on error |
| `_GUICtrlVLC_Add`, `_Play`, `_Pause`, `_Stop`, `_Clear` | same | `_Add` accepts all URL types (v0.3 only `rtsp://`) |
| `_GUICtrlVLC_SeekRelative`, `_SeekAbsolute`, `_GetTime`, `_GetLength` | same | milliseconds |
| `_GUICtrlVLC_GetState` | same | same values 0–7 (3 = playing) |
| `_GUICtrlVLC_GetVolume`, `_SetVolume`, `_GetMute`, `_SetMute` | same | 0–200 % |
| direct object access such as `$vlc.playlist...` | not possible | use the UDF functions or `_libvlc_*` with `_GUICtrlVLC_GetPlayer()` |

New for restarting a stream is `_GUICtrlVLC_Open($id, $url, $options)`. It replaces `Stop` + `Play(Add())`, and the playlist does not grow with every restart.

## What the UDF does better

- **No freezing on stop.** `libvlc_media_player_stop()` waits for VLC's video thread, which on Windows needs the GUI thread – for COM objects (VLC creates a taskbar object in the main STA on every resize) or for window messages. Stop, release, shutdown and media switching therefore run in a worker thread while the AutoIt message loop keeps running.
- **No hang when VLC hangs.** If a stop exceeds the timeout (default 10 s), the UDF returns `$VLC_ERR_TIMEOUT`. The player is then considered "busy" (`_VLC_PlayerIsBusy`): calls return immediately with an error instead of blocking on VLC's internal lock. Afterwards the player works normally again.
- **Thread-safe events.** libVLC calls callbacks from its own threads, where AutoIt must never run. A small native thunk (assembler, x86/x64, verified by emulation) copies the event and posts it to an invisible window via `PostMessage`. Your callback then runs in the AutoIt thread and may call any UDF function. Frequent events (TimeChanged, PositionChanged, Buffering) are coalesced.
- **Unicode.** Paths, URLs, options and metadata are passed and read as UTF-8, so non-ASCII characters work. Strings returned by libVLC are freed with `libvlc_free`, so there are no memory leaks.
- **Crash protection.** NULL instead of a libVLC object yields `$VLC_ERR_PARAM` instead of a crash. A double event detach (an `abort()` in libVLC) is caught. `libvlc_errmsg()` is only called while an instance exists (otherwise libVLC crashes).
- **Fast switching without flicker.** When switching between playlist items, the video output is kept (`_VLC_PlayerSetMedia`).
- **Volume and mute** are remembered per player and applied each time an item starts.
- **Fullscreen** also works for embedded video, which libVLC itself cannot show in fullscreen. Esc leaves it.
- **Media options are trusted** (`libvlc_media_option_trusted`). Otherwise libVLC silently ignores options such as `:avcodec-hw` or `:sout`.
- **Bitness check:** a `libvlc.dll` with the wrong bitness yields a clear error (`$VLC_ERR_ARCH`) instead of `DllOpen = -1`.

## Events

```autoit
_GUICtrlVLC_SetEventCallback($iVlc, "VlcEvent")           ; True as 3rd parameter: time/position events too

Func VlcEvent($iPlayer, $iEvent, $vValue1, $vValue2)
    Switch $iEvent
        Case $libvlc_MediaPlayerPlaying
            ConsoleWrite("playing" & @CRLF)
        Case $libvlc_MediaPlayerEncounteredError
            ConsoleWrite("error: " & _VLC_GetLastError() & @CRLF)
        Case $libvlc_MediaPlayerLengthChanged
            ConsoleWrite("length: " & _VLC_FormatTime($vValue1) & @CRLF)
    EndSwitch
EndFunc
```

The values per event are documented at `_VLC_EventsProcess()` in `CCLibVLC.au3`. For the raw layer there is `_VLC_EventAttach()`, which also offers a polling mode without a callback (`_VLC_EventGetNext`).

## Error handling

All functions set `@error`. `_VLC_GetLastError()` returns the error text.

| `@error` | Constant | Meaning |
| --- | --- | --- |
| 1 | `$VLC_ERR_NOT_STARTED` | libVLC not started |
| 2 | `$VLC_ERR_DLLCALL` | DllCall failed (`@extended` = DllCall error) |
| 3 | `$VLC_ERR_LIBVLC` | libVLC reports an error |
| 4 | `$VLC_ERR_PARAM` | invalid parameter, unknown player ID or player busy |
| 5 | `$VLC_ERR_NOTFOUND` | file or libVLC not found |
| 6 | `$VLC_ERR_VERSION` | not a libVLC 3.x version (e.g. VLC 4, see [libVLC 3 and VLC 4](#libvlc-3-and-vlc-4)) |
| 7 | `$VLC_ERR_ARCH` | bitness of libvlc.dll does not match AutoIt |
| 9 | `$VLC_ERR_TIMEOUT` | timeout exceeded |
| 10 | `$VLC_ERR_NATIVE` | event bridge could not be created |
| 11 | `$VLC_ERR_STATE` | not possible in the current state (e.g. empty playlist) |

## Function overview

**Control:** Create, Delete, GetPlayer, GetHandle, GetCtrlID, SetPos, SetResizing, SetEventCallback, IsDoubleClick

**Playlist:** Add, Clear, GetCount, GetItem, GetCurrentItem, Open, Play, Next, Previous, SetLoop/GetLoop (`$VLC_LOOP_NONE/ALL/ONE`)

**Playback:** Pause (toggle), SetPause, Stop, GetState, GetStateText, IsPlaying, IsSeekable, CanPause, NextFrame

**Time:** GetTime, SetTime, SeekAbsolute, SeekRelative, GetLength, GetPosition, SetPosition, GetRate, SetRate

**Audio:** Get/SetVolume, Get/SetMute, ToggleMute, GetAudioTracks, Get/SetAudioTrack, Get/SetAudioDelay, GetAudioDevices, SetAudioDevice, SetEqualizer

**Video:** HasVideo, GetVideoSize, TakeSnapshot, Get/SetAspectRatio, Get/SetScale, SetCrop, SetDeinterlace, SetAdjust, SetMarquee, ClearMarquee, GetVideoTracks, SetVideoTrack

**Subtitles:** GetSubtitleTracks, Get/SetSubtitleTrack, AddSubtitleFile, Get/SetSubtitleDelay

**Chapters/titles:** GetChapters, Get/SetChapter, Next/PreviousChapter, GetTitles, Get/SetTitle

**Media:** GetMeta, GetMRL, GetMediaTracks

**Fullscreen:** SetFullscreen, GetFullscreen, ToggleFullscreen, GetFullscreenGUI

**Core (`_VLC_*`):** Startup, Shutdown, IsStarted, GetInstance, GetDir, GetVersion, GetLastError, GetDefaultOptions, MediaNew, MediaParse, MediaGetMetaAll, MediaGetTracks, MediaGetStats, MediaGetSlaves, TrackDescriptionToArray, PlayerGetAudio/Video/SubtitleTracks, PlayerGetTitles, PlayerGetChapters, PlayerStop, PlayerSetMedia, PlayerRelease, PlayerIsBusy, AudioOutputList, AudioOutputDeviceList, FilterList, EqualizerGetPresets, EqualizerGetBands, MediaDiscovererList, RendererDiscovererList, EventAttach, EventDetach, EventDetachAll, EventGetNext, EventsProcess, EventTypeName, IsUrl, PathToUri, FormatTime, FourCCToString

**Raw layer:** every libVLC function `libvlc_xxx` is available as `_libvlc_xxx`. The function headers contain the C prototype and the documentation from the VLC headers. C outputs (`int *`, `unsigned *`, `T ***`) are ByRef parameters; strings are converted to UTF-8 automatically. Not wrapped are functions with varargs or `FILE*` and functions only for macOS, X11 or Android; the list is at the top of `CCLibVLC_Raw.au3`.

## Tests

Results with AutoIt 3.3.18.0 and VLC 3.0.24, for both 32 and 64 bit:

| Test suite | x64 | x86 | Coverage |
| --- | --- | --- | --- |
| `Tests\Test_Core.au3` | 56/56 | 56/56 | loading, error paths, UTF-8, parsing, metadata, tracks, events (callback and polling), seek, pause, stop in worker, restart |
| `Tests\Test_GUICtrl.au3` | 78/78¹ | 78/78¹ | control, playlist, auto-advance, loop, fullscreen, resizing, two players at once, v0.3 patterns, busy protection, delete during playback |
| `Tests\Test_Stress.au3` | 5/5 (2×) | 5/5 (2×) | 40 open/stop cycles with random pauses, auto-advance over 6 items, 10× delete/recreate during playback |

¹ Two busy-protection checks depend on timing: they only run if the stop with 0 ms timeout actually times out and the worker is still busy afterwards. Otherwise 76–77 checks run.

Also checked:

- Au3Check with `-d` and all warning levels: 0 errors, 0 warnings
- emulation of the native thunks with Unicorn (`tools\emu_test.py`): stack balance, preserved registers, 16-byte alignment, error path
- screenshots of embedding, resizing and fullscreen
- end-to-end use in a door camera client against a real password-protected RTSP server

Running the tests: `AutoIt3_x64.exe Tests\Test_Core.au3 "C:\path\to\vlc" "C:\path\to\testmedia"`. The exit code is the number of failed tests. The media folder needs `test.mp4`, a copy of it named `Märchen ÄÖÜ ß.mp4` (to test non-ASCII paths) and `ton.mp3` with the title "Täst Titel" and the artist "Künstler" (to test UTF-8 metadata). The snapshot test is optional; enable it with the environment variable `CCLIBVLC_TEST_SNAPSHOT=1`.

### Known limitations

- **Volume:** libVLC only sets it while an audio output is active. Some outputs (e.g. the dummy output) always report 0. `_GUICtrlVLC_GetVolume` returns the value that was set.
- **Logging:** libVLC's logging callbacks cannot be used safely from AutoIt. Use `_VLC_Startup(Default, "--file-logging|--logfile=C:\Temp\vlc.log|--log-verbose=2")` instead.

## License

Copyright (C) 2026 Markus Debus, CITRO Computer.

CCLibVLC is free software under the **GNU General Public License v3.0 or later** (`LICENSE`), with an additional term according to section 7(b) GPLv3 requiring attribution (`NOTICE`). Anyone who uses or distributes the UDF must name "CCLibVLC – Markus Debus, CITRO Computer". Modified versions may only be distributed under the same license.

libVLC and the VLC plugins are not part of CCLibVLC. They are licensed by the VideoLAN project under the LGPL 2.1 (or GPL for some plugins). If you ship the DLLs, include their license notices (`COPYING.txt` from the VLC ZIP).
