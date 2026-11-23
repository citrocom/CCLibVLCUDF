# Changelog

## 1.0.0 – 2026-11-22

First release. Complete rewrite as a replacement for VLC.au3 v0.3 (seangriffin, ActiveX) and LibVLC.au3 (genius257).

- Raw layer: 266 of the 316 exported libVLC 3.0 functions, generated from the VLC 3.0.x headers (`tools/generate_raw.py`), with UTF-8, ByRef outputs, NULL protection and freeing of libVLC strings
- 219 libVLC constants (log levels as `$LIBVLC_LOG_*`, because AutoIt variable names are case-insensitive)
- Core: loading with bitness check and search order, thread-safe event bridge (native thunk + PostMessage), stop/release/media switching in a worker thread with busy protection on timeout, list helpers (tracks, titles, chapters, audio devices, filters, equalizer, discoverers)
- GUI control `_GUICtrlVLC_*`: 87 functions, compatible with VLC.au3 v0.3, playlist with auto-advance and loop, fullscreen for embedded video, double-click detection, resizing via GUICtrlSetResizing
- Examples and self-tests (core, GUI, stress)
- Documentation: VLC 4 compatibility situation (README)
