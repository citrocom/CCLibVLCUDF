# Changelog

## 1.0.2 – 2026-11-26

- Robustness: window procedures (event window, video host controls) and the worker wait loop now call Windows functions through DLL handles opened once. Before, every call loaded and freed the DLL by name, which takes the process-wide loader lock; while libVLC loads plugins, for example from a slow network share, this could stall the GUI thread.

## 1.0.1 – 2026-11-23

- Fix: events could get lost or be delivered twice. The window procedure that receives events from the native thunk can interrupt running script code between two statements, also while the event pump was removing an event from the shared queue. Events now pass through a lock-free inbox (ring buffer with a single writer and a single reader) before they enter the queue, and script code that changes the queue keeps the Adlib pump out. Seen as a missing `MediaPlayerPlaying` event with RTSP streams.
- Time/position/buffering events are coalesced only with the newest queued event of the same type, so the order of events is kept.
- Fix: `_GUICtrlVLC_IsDoubleClick()` never returned True with real mouse double clicks. The static control behind the video reports the second click as `STN_DBLCLK`, which AutoIt does not pass on, so `GUIGetMsg()` saw only one click. The host control is now subclassed and the second click is passed on as a normal click.

## 1.0.0 – 2026-11-22

First release. Complete rewrite as a replacement for VLC.au3 v0.3 (seangriffin, ActiveX) and LibVLC.au3 (genius257).

- Raw layer: 266 of the 316 exported libVLC 3.0 functions, generated from the VLC 3.0.x headers (`tools/generate_raw.py`), with UTF-8, ByRef outputs, NULL protection and freeing of libVLC strings
- 219 libVLC constants (log levels as `$LIBVLC_LOG_*`, because AutoIt variable names are case-insensitive)
- Core: loading with bitness check and search order, thread-safe event bridge (native thunk + PostMessage), stop/release/media switching in a worker thread with busy protection on timeout, list helpers (tracks, titles, chapters, audio devices, filters, equalizer, discoverers)
- GUI control `_GUICtrlVLC_*`: 87 functions, compatible with VLC.au3 v0.3, playlist with auto-advance and loop, fullscreen for embedded video, double-click detection, resizing via GUICtrlSetResizing
- Examples and self-tests (core, GUI, stress)
- Documentation: VLC 4 compatibility situation (README)
