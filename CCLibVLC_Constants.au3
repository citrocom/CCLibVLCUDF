#include-once
; SPDX-License-Identifier: GPL-3.0-or-later
; =============================================================================================================
; Title .........: CCLibVLC_Constants
; Description ...: libVLC 3.0.24 enumerations as AutoIt constants (names identical to C).
;                  GENERATED FILE - do not edit. Regenerate with tools/generate_raw.py.
; Author(s) .....: Markus Debus, CITRO Computer
; Generated .....: 2026-11-22
; =============================================================================================================

; enum libvlc_log_level (libvlc.h)
Global Const $LIBVLC_LOG_DEBUG = 0
Global Const $LIBVLC_LOG_NOTICE = 2
Global Const $LIBVLC_LOG_WARNING = 3
Global Const $LIBVLC_LOG_ERROR = 4

; enum libvlc_meta_t (libvlc_media.h)
Global Const $libvlc_meta_Title = 0
Global Const $libvlc_meta_Artist = 1
Global Const $libvlc_meta_Genre = 2
Global Const $libvlc_meta_Copyright = 3
Global Const $libvlc_meta_Album = 4
Global Const $libvlc_meta_TrackNumber = 5
Global Const $libvlc_meta_Description = 6
Global Const $libvlc_meta_Rating = 7
Global Const $libvlc_meta_Date = 8
Global Const $libvlc_meta_Setting = 9
Global Const $libvlc_meta_URL = 10
Global Const $libvlc_meta_Language = 11
Global Const $libvlc_meta_NowPlaying = 12
Global Const $libvlc_meta_Publisher = 13
Global Const $libvlc_meta_EncodedBy = 14
Global Const $libvlc_meta_ArtworkURL = 15
Global Const $libvlc_meta_TrackID = 16
Global Const $libvlc_meta_TrackTotal = 17
Global Const $libvlc_meta_Director = 18
Global Const $libvlc_meta_Season = 19
Global Const $libvlc_meta_Episode = 20
Global Const $libvlc_meta_ShowName = 21
Global Const $libvlc_meta_Actors = 22
Global Const $libvlc_meta_AlbumArtist = 23
Global Const $libvlc_meta_DiscNumber = 24
Global Const $libvlc_meta_DiscTotal = 25

; enum libvlc_state_t (libvlc_media.h)
Global Const $libvlc_NothingSpecial = 0
Global Const $libvlc_Opening = 1
Global Const $libvlc_Buffering = 2
Global Const $libvlc_Playing = 3
Global Const $libvlc_Paused = 4
Global Const $libvlc_Stopped = 5
Global Const $libvlc_Ended = 6
Global Const $libvlc_Error = 7

; enum  (libvlc_media.h)
Global Const $libvlc_media_option_trusted = 2
Global Const $libvlc_media_option_unique = 0x100

; enum libvlc_track_type_t (libvlc_media.h)
Global Const $libvlc_track_unknown = -1
Global Const $libvlc_track_audio = 0
Global Const $libvlc_track_video = 1
Global Const $libvlc_track_text = 2

; enum libvlc_video_orient_t (libvlc_media.h)
Global Const $libvlc_video_orient_top_left = 0
Global Const $libvlc_video_orient_top_right = 1
Global Const $libvlc_video_orient_bottom_left = 2
Global Const $libvlc_video_orient_bottom_right = 3
Global Const $libvlc_video_orient_left_top = 4
Global Const $libvlc_video_orient_left_bottom = 5
Global Const $libvlc_video_orient_right_top = 6
Global Const $libvlc_video_orient_right_bottom = 7

; enum libvlc_video_projection_t (libvlc_media.h)
Global Const $libvlc_video_projection_rectangular = 0
Global Const $libvlc_video_projection_equirectangular = 1
Global Const $libvlc_video_projection_cubemap_layout_standard = 0x100

; enum libvlc_media_type_t (libvlc_media.h)
Global Const $libvlc_media_type_unknown = 0
Global Const $libvlc_media_type_file = 1
Global Const $libvlc_media_type_directory = 2
Global Const $libvlc_media_type_disc = 3
Global Const $libvlc_media_type_stream = 4
Global Const $libvlc_media_type_playlist = 5

; enum libvlc_media_parse_flag_t (libvlc_media.h)
Global Const $libvlc_media_parse_local = 0
Global Const $libvlc_media_parse_network = 1
Global Const $libvlc_media_fetch_local = 2
Global Const $libvlc_media_fetch_network = 4
Global Const $libvlc_media_do_interact = 8

; enum libvlc_media_parsed_status_t (libvlc_media.h)
Global Const $libvlc_media_parsed_status_skipped = 1
Global Const $libvlc_media_parsed_status_failed = 2
Global Const $libvlc_media_parsed_status_timeout = 3
Global Const $libvlc_media_parsed_status_done = 4

; enum libvlc_media_slave_type_t (libvlc_media.h)
Global Const $libvlc_media_slave_type_subtitle = 0
Global Const $libvlc_media_slave_type_audio = 1

; enum  (libvlc_media_player.h)
Global Const $libvlc_title_menu = 1
Global Const $libvlc_title_interactive = 2

; enum libvlc_video_marquee_option_t (libvlc_media_player.h)
Global Const $libvlc_marquee_Enable = 0
Global Const $libvlc_marquee_Text = 1
Global Const $libvlc_marquee_Color = 2
Global Const $libvlc_marquee_Opacity = 3
Global Const $libvlc_marquee_Position = 4
Global Const $libvlc_marquee_Refresh = 5
Global Const $libvlc_marquee_Size = 6
Global Const $libvlc_marquee_Timeout = 7
Global Const $libvlc_marquee_X = 8
Global Const $libvlc_marquee_Y = 9

; enum libvlc_navigate_mode_t (libvlc_media_player.h)
Global Const $libvlc_navigate_activate = 0
Global Const $libvlc_navigate_up = 1
Global Const $libvlc_navigate_down = 2
Global Const $libvlc_navigate_left = 3
Global Const $libvlc_navigate_right = 4
Global Const $libvlc_navigate_popup = 5

; enum libvlc_position_t (libvlc_media_player.h)
Global Const $libvlc_position_disable = -1
Global Const $libvlc_position_center = 0
Global Const $libvlc_position_left = 1
Global Const $libvlc_position_right = 2
Global Const $libvlc_position_top = 3
Global Const $libvlc_position_top_left = 4
Global Const $libvlc_position_top_right = 5
Global Const $libvlc_position_bottom = 6
Global Const $libvlc_position_bottom_left = 7
Global Const $libvlc_position_bottom_right = 8

; enum libvlc_teletext_key_t (libvlc_media_player.h)
Global Const $libvlc_teletext_key_red = 0x720000
Global Const $libvlc_teletext_key_green = 0x670000
Global Const $libvlc_teletext_key_yellow = 0x790000
Global Const $libvlc_teletext_key_blue = 0x620000
Global Const $libvlc_teletext_key_index = 0x690000

; enum libvlc_video_logo_option_t (libvlc_media_player.h)
Global Const $libvlc_logo_enable = 0
Global Const $libvlc_logo_file = 1
Global Const $libvlc_logo_x = 2
Global Const $libvlc_logo_y = 3
Global Const $libvlc_logo_delay = 4
Global Const $libvlc_logo_repeat = 5
Global Const $libvlc_logo_opacity = 6
Global Const $libvlc_logo_position = 7

; enum libvlc_video_adjust_option_t (libvlc_media_player.h)
Global Const $libvlc_adjust_Enable = 0
Global Const $libvlc_adjust_Contrast = 1
Global Const $libvlc_adjust_Brightness = 2
Global Const $libvlc_adjust_Hue = 3
Global Const $libvlc_adjust_Saturation = 4
Global Const $libvlc_adjust_Gamma = 5

; enum libvlc_audio_output_device_types_t (libvlc_media_player.h)
Global Const $libvlc_AudioOutputDevice_Error = -1
Global Const $libvlc_AudioOutputDevice_Mono = 1
Global Const $libvlc_AudioOutputDevice_Stereo = 2
Global Const $libvlc_AudioOutputDevice_2F2R = 4
Global Const $libvlc_AudioOutputDevice_3F2R = 5
Global Const $libvlc_AudioOutputDevice_5_1 = 6
Global Const $libvlc_AudioOutputDevice_6_1 = 7
Global Const $libvlc_AudioOutputDevice_7_1 = 8
Global Const $libvlc_AudioOutputDevice_SPDIF = 10

; enum libvlc_audio_output_channel_t (libvlc_media_player.h)
Global Const $libvlc_AudioChannel_Error = -1
Global Const $libvlc_AudioChannel_Stereo = 1
Global Const $libvlc_AudioChannel_RStereo = 2
Global Const $libvlc_AudioChannel_Left = 3
Global Const $libvlc_AudioChannel_Right = 4
Global Const $libvlc_AudioChannel_Dolbys = 5

; enum libvlc_media_player_role (libvlc_media_player.h)
Global Const $libvlc_role_None = 0
Global Const $libvlc_role_Music = 1
Global Const $libvlc_role_Video = 2
Global Const $libvlc_role_Communication = 3
Global Const $libvlc_role_Game = 4
Global Const $libvlc_role_Notification = 5
Global Const $libvlc_role_Animation = 6
Global Const $libvlc_role_Production = 7
Global Const $libvlc_role_Accessibility = 8
Global Const $libvlc_role_Test = 9

; enum libvlc_playback_mode_t (libvlc_media_list_player.h)
Global Const $libvlc_playback_mode_default = 0
Global Const $libvlc_playback_mode_loop = 1
Global Const $libvlc_playback_mode_repeat = 2

; enum libvlc_media_discoverer_category_t (libvlc_media_discoverer.h)
Global Const $libvlc_media_discoverer_devices = 0
Global Const $libvlc_media_discoverer_lan = 1
Global Const $libvlc_media_discoverer_podcasts = 2
Global Const $libvlc_media_discoverer_localdirs = 3

; enum libvlc_event_e (libvlc_events.h)
Global Const $libvlc_MediaMetaChanged = 0
Global Const $libvlc_MediaSubItemAdded = 1
Global Const $libvlc_MediaDurationChanged = 2
Global Const $libvlc_MediaParsedChanged = 3
Global Const $libvlc_MediaFreed = 4
Global Const $libvlc_MediaStateChanged = 5
Global Const $libvlc_MediaSubItemTreeAdded = 6
Global Const $libvlc_MediaPlayerMediaChanged = 0x100
Global Const $libvlc_MediaPlayerNothingSpecial = 257
Global Const $libvlc_MediaPlayerOpening = 258
Global Const $libvlc_MediaPlayerBuffering = 259
Global Const $libvlc_MediaPlayerPlaying = 260
Global Const $libvlc_MediaPlayerPaused = 261
Global Const $libvlc_MediaPlayerStopped = 262
Global Const $libvlc_MediaPlayerForward = 263
Global Const $libvlc_MediaPlayerBackward = 264
Global Const $libvlc_MediaPlayerEndReached = 265
Global Const $libvlc_MediaPlayerEncounteredError = 266
Global Const $libvlc_MediaPlayerTimeChanged = 267
Global Const $libvlc_MediaPlayerPositionChanged = 268
Global Const $libvlc_MediaPlayerSeekableChanged = 269
Global Const $libvlc_MediaPlayerPausableChanged = 270
Global Const $libvlc_MediaPlayerTitleChanged = 271
Global Const $libvlc_MediaPlayerSnapshotTaken = 272
Global Const $libvlc_MediaPlayerLengthChanged = 273
Global Const $libvlc_MediaPlayerVout = 274
Global Const $libvlc_MediaPlayerScrambledChanged = 275
Global Const $libvlc_MediaPlayerESAdded = 276
Global Const $libvlc_MediaPlayerESDeleted = 277
Global Const $libvlc_MediaPlayerESSelected = 278
Global Const $libvlc_MediaPlayerCorked = 279
Global Const $libvlc_MediaPlayerUncorked = 280
Global Const $libvlc_MediaPlayerMuted = 281
Global Const $libvlc_MediaPlayerUnmuted = 282
Global Const $libvlc_MediaPlayerAudioVolume = 283
Global Const $libvlc_MediaPlayerAudioDevice = 284
Global Const $libvlc_MediaPlayerChapterChanged = 285
Global Const $libvlc_MediaListItemAdded = 0x200
Global Const $libvlc_MediaListWillAddItem = 513
Global Const $libvlc_MediaListItemDeleted = 514
Global Const $libvlc_MediaListWillDeleteItem = 515
Global Const $libvlc_MediaListEndReached = 516
Global Const $libvlc_MediaListViewItemAdded = 0x300
Global Const $libvlc_MediaListViewWillAddItem = 769
Global Const $libvlc_MediaListViewItemDeleted = 770
Global Const $libvlc_MediaListViewWillDeleteItem = 771
Global Const $libvlc_MediaListPlayerPlayed = 0x400
Global Const $libvlc_MediaListPlayerNextItemSet = 1025
Global Const $libvlc_MediaListPlayerStopped = 1026
Global Const $libvlc_MediaDiscovererStarted = 0x500
Global Const $libvlc_MediaDiscovererEnded = 1281
Global Const $libvlc_RendererDiscovererItemAdded = 1282
Global Const $libvlc_RendererDiscovererItemDeleted = 1283
Global Const $libvlc_VlmMediaAdded = 0x600
Global Const $libvlc_VlmMediaRemoved = 1537
Global Const $libvlc_VlmMediaChanged = 1538
Global Const $libvlc_VlmMediaInstanceStarted = 1539
Global Const $libvlc_VlmMediaInstanceStopped = 1540
Global Const $libvlc_VlmMediaInstanceStatusInit = 1541
Global Const $libvlc_VlmMediaInstanceStatusOpening = 1542
Global Const $libvlc_VlmMediaInstanceStatusPlaying = 1543
Global Const $libvlc_VlmMediaInstanceStatusPause = 1544
Global Const $libvlc_VlmMediaInstanceStatusEnd = 1545
Global Const $libvlc_VlmMediaInstanceStatusError = 1546

; enum libvlc_dialog_question_type (libvlc_dialog.h)
Global Const $LIBVLC_DIALOG_QUESTION_NORMAL = 0
Global Const $LIBVLC_DIALOG_QUESTION_WARNING = 1
Global Const $LIBVLC_DIALOG_QUESTION_CRITICAL = 2

Global Const $libvlc_role_Last = $libvlc_role_Test
