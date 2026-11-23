#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Markus Debus, CITRO Computer
#
# CCLibVLC - generator for the raw libVLC binding layer.
#
# Reads the public libVLC 3.0 headers (include/vlc/*.h) and the export list
# (lib/libvlc.sym) of a VLC 3.0.x source tree and writes
#   CCLibVLC_Raw.au3        - one AutoIt wrapper per exported libVLC function
#   CCLibVLC_Constants.au3  - all libVLC enums as AutoIt constants
#
# Usage: python3 generate_raw.py <vlc-source-dir> <output-dir> [vlc-version]
#
# The generator is deliberately strict: every C type must be known, otherwise
# it aborts. That way a new libVLC release cannot silently produce a wrapper
# with a wrong calling signature.

import os
import re
import sys
import datetime

HEADERS = [
    'libvlc.h', 'libvlc_renderer_discoverer.h', 'libvlc_media.h',
    'libvlc_media_player.h', 'libvlc_media_list.h', 'libvlc_media_list_player.h',
    'libvlc_media_discoverer.h', 'libvlc_events.h', 'libvlc_dialog.h',
    'libvlc_vlm.h', 'libvlc_media_library.h',
]

# Functions that are not generated:
#   handwritten in CCLibVLC.au3 (need special treatment), or useless/unsafe
#   from AutoIt (varargs, C runtime FILE*, logging callbacks with va_list,
#   non-Windows platforms).
SKIP = {
    'libvlc_new': 'handwritten in CCLibVLC.au3 (argv array): _libvlc_new()',
    'libvlc_printerr': 'printf-style varargs, not callable from AutoIt',
    'libvlc_vprinterr': 'va_list, not callable from AutoIt',
    'libvlc_log_set': 'callback receives a va_list and runs on VLC threads; use libvlc_new options --file-logging --logfile=<path>',
    'libvlc_log_set_file': 'needs a C runtime FILE* of the CRT VLC was built with; use --file-logging --logfile=<path>',
    'libvlc_log_get_context': 'only valid inside a libvlc_log_set callback',
    'libvlc_log_get_object': 'only valid inside a libvlc_log_set callback',
    'libvlc_media_player_set_nsobject': 'macOS only',
    'libvlc_media_player_get_nsobject': 'macOS only',
    'libvlc_media_player_set_xwindow': 'X11 only',
    'libvlc_media_player_get_xwindow': 'X11 only',
    'libvlc_media_player_set_android_context': 'Android only',
    'libvlc_media_player_set_evas_object': 'Tizen only, not exported on Windows',
}

# AutoIt DllCall type for scalar C types
SCALAR = {
    'int': 'int', 'unsigned': 'uint', 'unsigned int': 'uint', 'uint32_t': 'uint',
    'int64_t': 'int64', 'libvlc_time_t': 'int64', 'float': 'float',
    'size_t': 'ulong_ptr', 'bool': 'boolean',
    'libvlc_event_type_t': 'int',
}
# enums are 32 bit int
ENUM_TYPES = {
    'libvlc_media_discoverer_category_t', 'libvlc_media_parse_flag_t',
    'libvlc_media_slave_type_t', 'libvlc_meta_t', 'libvlc_playback_mode_t',
    'libvlc_position_t', 'libvlc_track_type_t', 'libvlc_state_t',
    'libvlc_media_type_t', 'libvlc_media_parsed_status_t',
}
CALLBACK_TYPES = {
    'libvlc_audio_cleanup_cb', 'libvlc_audio_drain_cb', 'libvlc_audio_flush_cb',
    'libvlc_audio_pause_cb', 'libvlc_audio_play_cb', 'libvlc_audio_resume_cb',
    'libvlc_audio_set_volume_cb', 'libvlc_audio_setup_cb', 'libvlc_callback_t',
    'libvlc_media_close_cb', 'libvlc_media_open_cb', 'libvlc_media_read_cb',
    'libvlc_media_seek_cb', 'libvlc_video_cleanup_cb', 'libvlc_video_display_cb',
    'libvlc_video_format_cb', 'libvlc_video_lock_cb', 'libvlc_video_unlock_cb',
}


def norm(t):
    t = ' '.join(t.replace('*', ' * ').split())
    t = t.replace('* *', '**').replace('** *', '***')
    return t


def strip_comments_keep_docs(src):
    """Return list of (doc, declaration) for every LIBVLC_API declaration."""
    out = []
    # remove preprocessor lines (multi-line with backslash too)
    src = re.sub(r'^\s*#(?:[^\n]*\\\n)*[^\n]*', '', src, flags=re.M)
    src = src.replace('VLC_FORWARD_DECLARE_OBJECT(libvlc_media_list_t *)', 'libvlc_media_list_t *')
    tokens = re.split(r'(/\*.*?\*/)', src, flags=re.S)
    last_doc = ''
    for tok in tokens:
        if tok.startswith('/*'):
            if tok.startswith('/**') or tok.startswith('/*!'):
                last_doc = tok
            continue
        code = re.sub(r'//[^\n]*', '', tok)
        pos = 0
        for m in re.finditer(r'\bLIBVLC_API\b(.*?);', code, flags=re.S):
            between = code[pos:m.start()]
            # doc belongs to this declaration only if nothing but whitespace
            # stands between the comment and the declaration
            doc = last_doc if between.strip() == '' else ''
            out.append((doc, ' '.join(m.group(1).split())))
            last_doc = ''
            pos = m.end()
        if code.strip():
            # code after a comment that is not a declaration voids the doc
            if not re.search(r'\bLIBVLC_API\b', code):
                last_doc = ''
    return out


def parse_doc(doc):
    if not doc:
        return {'brief': '', 'params': {}, 'ret': '', 'notes': [], 'version': ''}
    d = doc.strip()
    d = re.sub(r'^/\*\*!?|^/\*!|\*/$', '', d)
    lines = []
    for ln in d.split('\n'):
        ln = re.sub(r'^\s*\*\s?', '', ln.rstrip())
        lines.append(ln)
    text = '\n'.join(lines)
    # split into sections at \cmd
    parts = re.split(r'\n?\s*[\\@](param(?:\[\w+\])?|return|note|warning|version|deprecated|see|libvlc_return_bool|bug)\b', text)
    brief = parts[0].strip()
    info = {'brief': brief, 'params': {}, 'ret': '', 'notes': [], 'version': ''}
    for i in range(1, len(parts), 2):
        cmd, body = parts[i], parts[i + 1].strip()
        body = ' '.join(body.split())
        if cmd.startswith('param'):
            m = re.match(r'(\w+)\s*(.*)', body)
            if m:
                info['params'][m.group(1)] = m.group(2)
        elif cmd == 'return':
            info['ret'] = body
        elif cmd == 'libvlc_return_bool':
            info['ret'] = '0 on success, -1 on error'
        elif cmd == 'version':
            info['version'] = body
        elif cmd in ('note', 'warning', 'bug'):
            info['notes'].append(cmd.capitalize() + ': ' + body)
    return info


def clean(s):
    s = s.replace('\\ref ', '').replace('\\c ', '').replace('\\b ', '')
    s = re.sub(r'\\p\s+', '', s)
    s = re.sub(r'<[^>]+>', '', s)
    return ' '.join(s.split())


def first_sentence(s):
    s = clean(s)
    m = re.match(r'(.+?[.!?])(\s|$)', s)
    return m.group(1) if m else s


def split_params(p):
    p = p.strip()
    if p in ('', 'void'):
        return []
    parts, depth, cur = [], 0, ''
    for ch in p:
        if ch == '(':
            depth += 1
        elif ch == ')':
            depth -= 1
        if ch == ',' and depth == 0:
            parts.append(cur)
            cur = ''
        else:
            cur += ch
    parts.append(cur)
    return [x.strip() for x in parts]


def parse_param(p, idx):
    p = ' '.join(p.split())
    m = re.match(r'^void\s*\(\s*\*\s*(\w+)\s*\)\s*\(.*\)$', p)
    if m:
        return ('fnptr', m.group(1))
    n = norm(p)
    # unnamed parameter (type only)
    if n in SCALAR or n in ENUM_TYPES or n in CALLBACK_TYPES or n.endswith('*') or n in ('...', 'va_list'):
        return (n, 'p%d' % idx)
    m = re.match(r'^(.*?[\s\*])(\w+)$', p)
    if not m:
        raise ValueError('cannot parse parameter %r' % p)
    return (norm(m.group(1)), m.group(2))


RESERVED_NAMES = {'default', 'null', 'true', 'false'}

# opaque libVLC objects: passing NULL as first argument crashes libVLC, the wrapper refuses it
OBJECT_TYPES = {
    'libvlc_instance_t *', 'const libvlc_instance_t *', 'libvlc_media_t *', 'libvlc_media_player_t *',
    'libvlc_media_list_t *', 'libvlc_media_list_player_t *', 'libvlc_event_manager_t *',
    'libvlc_media_discoverer_t *', 'libvlc_renderer_discoverer_t *', 'libvlc_renderer_item_t *',
    'const libvlc_renderer_item_t *', 'libvlc_equalizer_t *', 'libvlc_media_library_t *', 'libvlc_dialog_id *',
}
# functions that are only safe while a libVLC instance exists (thread-local error storage)
NEEDS_INSTANCE = {'libvlc_errmsg', 'libvlc_clearerr'}


def classify_param(ctype, fname):
    """Return (kind, autoit_type, description)."""
    t = ctype
    if t == 'fnptr':
        return ('ptr', 'ptr', 'function pointer')
    if t in ('...', 'va_list', 'FILE *'):
        raise ValueError('unsupported param %s in %s' % (t, fname))
    if t in SCALAR:
        return ('scalar', SCALAR[t], t)
    if t in ENUM_TYPES:
        return ('scalar', 'int', t)
    if t in CALLBACK_TYPES:
        return ('ptr', 'ptr', t + ' (native callback pointer)')
    if t in ('const char *',):
        return ('str', 'ptr', 'string (UTF-8 converted automatically, Null/Default = NULL)')
    if t in ('const char * const *', 'const char *const *'):
        return ('strarr', 'ptr', 'array of strings (AutoIt array, converted automatically)')
    if t == 'int *':
        return ('out', 'int*', 'out int')
    if t == 'unsigned *':
        return ('out', 'uint*', 'out unsigned')
    if t.endswith('***'):
        return ('out', 'ptr*', 'out pointer (' + t + ')')
    if t.endswith('*'):
        return ('ptr', 'ptr', t)
    raise ValueError('unknown param type %r in %s' % (t, fname))


def classify_ret(rtype, fname):
    t = norm(rtype)
    if t == 'void':
        return ('void', 'none')
    if t in SCALAR:
        return ('scalar', SCALAR[t])
    if t in ENUM_TYPES:
        return ('scalar', 'int')
    if t in ('const char *',):
        return ('cstr', 'ptr')
    if t == 'char *':
        return ('heapstr', 'ptr')
    if t.endswith('*'):
        return ('ptr', 'ptr')
    raise ValueError('unknown return type %r in %s' % (t, fname))


def fail_value(rkind, atype):
    if rkind == 'void':
        return 'False'
    if rkind in ('cstr', 'heapstr'):
        return '""'
    if rkind == 'ptr':
        return 'Ptr(0)'
    if atype == 'int':
        return '-1'
    return '0'


def header_block(name, brief, syntax, params_doc, ret_doc, remarks, header):
    L = []
    L.append('; #FUNCTION# ' + '=' * 108)
    L.append('; Name ..........: ' + name)
    L.append('; Description ...: ' + (brief or name))
    L.append('; Syntax ........: ' + syntax)
    first = True
    if not params_doc:
        L.append('; Parameters ....: None')
    for pn, pd in params_doc:
        prefix = '; Parameters ....: ' if first else ';                  '
        L.append(prefix + '%-20s - %s' % (pn, pd))
        first = False
    first = True
    for rd in ret_doc:
        prefix = '; Return values .: ' if first else ';                  '
        L.append(prefix + rd)
        first = False
    L.append('; Author ........: CCLibVLC generator (from VLC 3.0 headers)')
    L.append('; Modified ......:')
    first = True
    if not remarks:
        L.append('; Remarks .......:')
    for r in remarks:
        prefix = '; Remarks .......: ' if first else ';                  '
        L.append(prefix + r)
        first = False
    L.append('; Related .......:')
    L.append('; Link ..........: include/vlc/' + header)
    L.append('; Example .......: No')
    L.append('; ' + '=' * 119)
    return L


def wrap(text, width=100):
    words = text.split()
    lines, cur = [], ''
    for w in words:
        if len(cur) + len(w) + 1 > width and cur:
            lines.append(cur)
            cur = w
        else:
            cur = (cur + ' ' + w).strip()
    if cur:
        lines.append(cur)
    return lines


def gen_function(fname, rtype, params, doc, header):
    rkind, ratype = classify_ret(rtype, fname)
    info = parse_doc(doc)
    au_name = '_' + fname
    pinfo = []
    used = set()
    for idx, p in enumerate(split_params(params)):
        ctype, pname = parse_param(p, idx + 1)
        if pname.lower() in RESERVED_NAMES or pname.lower() in used:
            pname = pname + '_'
        used.add(pname.lower())
        kind, atype, desc = classify_param(ctype, fname)
        pinfo.append({'c': ctype, 'name': pname, 'kind': kind, 'atype': atype, 'desc': desc})

    sig_parts = []
    for p in pinfo:
        sig_parts.append(('ByRef $' if p['kind'] == 'out' else '$') + p['name'])
    syntax = '%s(%s)' % (au_name, ', '.join('$' + p['name'] for p in pinfo))

    body = []
    call_args = []
    fv0 = fail_value(rkind, ratype)
    if fname in NEEDS_INSTANCE:
        body.append('\tIf $__g_pVLC_Instance = 0 Then Return %s ; no instance: libVLC TLS not initialised' % ('True' if rkind == 'void' else '""'))
    guarded = False
    if pinfo and pinfo[0]['kind'] == 'ptr' and norm(pinfo[0]['c']) in OBJECT_TYPES:
        body.append('\tIf __VLC_Ptr($%s) = 0 Then Return SetError($VLC_ERR_PARAM, 0, %s) ; NULL would crash libVLC' % (pinfo[0]['name'], fv0))
        guarded = True
    for i, p in enumerate(pinfo, start=1):
        v = '$' + p['name']
        if p['kind'] == 'scalar':
            call_args.append('"%s", %s' % (p['atype'], v))
        elif p['kind'] == 'ptr':
            call_args.append('"ptr", __VLC_Ptr(%s)' % v)
        elif p['kind'] == 'str':
            body.append('\tLocal $__tStr%d = __VLC_Utf8Struct(%s)' % (i, v))
            call_args.append('"ptr", __VLC_Ptr($__tStr%d)' % i)
        elif p['kind'] == 'strarr':
            body.append('\tLocal $__aStr%d = __VLC_Utf8Array(%s)' % (i, v))
            call_args.append('"ptr", __VLC_Utf8ArrayPtr($__aStr%d)' % i)
        elif p['kind'] == 'out':
            init = 'Ptr(0)' if p['atype'] == 'ptr*' else '0'
            call_args.append('"%s", %s' % (p['atype'], init))
    ret_t = ratype + ':cdecl'
    has_out = any(p['kind'] == 'out' for p in pinfo)
    lhs = '\tLocal $__aCall = ' if (rkind != 'void' or has_out) else '\t'
    call = lhs + 'DllCall($__g_hVLC_Dll, "%s", "%s"%s)' % (
        ret_t, fname, ''.join(', ' + a for a in call_args))
    body.append(call)
    fv = fail_value(rkind, ratype)
    body.append('\tIf @error Then Return SetError($VLC_ERR_DLLCALL, @error, %s)' % fv)
    for i, p in enumerate(pinfo, start=1):
        if p['kind'] == 'out':
            body.append('\t$%s = $__aCall[%d]' % (p['name'], i))
    if rkind == 'void':
        body.append('\tReturn True')
    elif rkind in ('cstr', 'heapstr'):
        # @extended of a helper does not survive its Return: re-set it here
        body.append('\tLocal $__sRet = __VLC_StrFromPtr($__aCall[0], %s)' % ('True' if rkind == 'heapstr' else 'False'))
        body.append('\tReturn SetExtended(@extended, $__sRet)')
    else:
        body.append('\tReturn $__aCall[0]')

    # --- documentation
    params_doc = []
    for p in pinfo:
        d = clean(info['params'].get(p['name'].rstrip('_'), ''))
        inout = '[out, ByRef] ' if p['kind'] == 'out' else ''
        txt = inout + p['c'] + (' : ' + d if d else '')
        if p['kind'] in ('str', 'strarr'):
            txt += ' (' + p['desc'] + ')'
        wl = wrap(txt, 90)
        params_doc.append(('$' + p['name'], wl[0]))
        for extra in wl[1:]:
            params_doc.append(('', extra))
    ret_doc = []
    rd = clean(info['ret'])
    if rkind == 'void':
        ret_doc.append('Success - True')
    else:
        what = {'cstr': 'string', 'heapstr': 'string (C memory is released automatically)',
                'ptr': 'pointer', 'scalar': ratype}[rkind]
        wl = wrap('Success - ' + what + (': ' + rd if rd else ''), 95)
        ret_doc.extend(wl)
        if rkind in ('cstr', 'heapstr'):
            ret_doc.append('          A NULL result is returned as "" with @extended = 1.')
    ret_doc.append('Failure - %s, sets @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error' % fv)
    if guarded:
        ret_doc.append('          or @error = $VLC_ERR_PARAM if $%s is NULL (would crash libVLC)' % pinfo[0]['name'])
    remarks = []
    cproto = '%s %s(%s)' % (norm(rtype), fname, ', '.join(
        (p['c'] + ' ' + p['name'].rstrip('_')) if p['c'] != 'fnptr' else ('void (*%s)(void *)' % p['name']) for p in pinfo) or 'void')
    remarks.extend(wrap('C: ' + cproto, 95))
    if info['version']:
        remarks.append('Version: ' + clean(info['version']))
    for n in info['notes']:
        remarks.extend(wrap(clean(n), 95))
    brief = first_sentence(info['brief'])
    lines = header_block(au_name, brief, syntax, params_doc, ret_doc, remarks, header)
    lines.append('Func %s(%s)' % (au_name, ', '.join(sig_parts)))
    lines.extend(body)
    lines.append('EndFunc   ;==>%s' % au_name)
    lines.append('')
    return lines, {'name': fname, 'au': au_name, 'header': header, 'brief': brief, 'syntax': syntax}


def parse_enums(src_text, header):
    src = re.sub(r'/\*.*?\*/', '', src_text, flags=re.S)
    src = re.sub(r'//[^\n]*', '', src)
    src = re.sub(r'^\s*#[^\n]*', '', src, flags=re.M)
    out = []
    for m in re.finditer(r'(?:typedef\s+)?enum\s+(\w*)\s*\{(.*?)\}\s*(\w*)\s*;', src, flags=re.S):
        ename = m.group(1) or m.group(3)
        items = []
        val = -1
        for raw in m.group(2).split(','):
            raw = raw.strip()
            if not raw:
                continue
            mm = re.match(r'^(\w+)\s*(?:=\s*(.+))?$', raw, flags=re.S)
            if not mm:
                raise ValueError('bad enum item %r' % raw)
            n, expr = mm.group(1), mm.group(2)
            if expr is not None:
                e = expr.strip()
                # C character literals like 'r'
                e = re.sub(r"'(.)'", lambda mo: str(ord(mo.group(1))), e)
                env = {k: v for k, v in out_env.items()}
                val = int(eval(e, {'__builtins__': {}}, env))
            else:
                val += 1
            out_env[n] = val
            items.append((n, val))
        out.append((ename, items, header))
    return out


out_env = {}


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        sys.exit(1)
    vlc_src, out_dir = sys.argv[1], sys.argv[2]
    vlc_ver = sys.argv[3] if len(sys.argv) > 3 else '3.0.x'
    inc = os.path.join(vlc_src, 'include', 'vlc')
    exported = set(x.strip() for x in open(os.path.join(vlc_src, 'lib', 'libvlc.sym')) if x.strip())

    funcs, index, seen = [], [], set()
    skipped = []
    enums = []
    for h in HEADERS:
        text = open(os.path.join(inc, h), encoding='utf-8').read()
        enums.extend(parse_enums(text, h))
        for doc, decl in strip_comments_keep_docs(text):
            m = re.match(r'^(.*?)\b(libvlc_\w+)\s*\((.*)\)\s*$', decl, flags=re.S)
            if not m:
                raise ValueError('cannot parse declaration: ' + decl)
            rtype, fname, params = m.group(1), m.group(2), m.group(3)
            if fname in seen:
                continue
            seen.add(fname)
            if fname in SKIP:
                skipped.append((fname, SKIP[fname]))
                continue
            if fname not in exported:
                skipped.append((fname, 'not exported by libvlc.dll (static inline or internal)'))
                continue
            lines, meta = gen_function(fname, rtype, params, doc, h)
            funcs.append((h, lines))
            index.append(meta)

    now = datetime.date.today().isoformat()
    bom = '\ufeff'
    # ---------------------------------------------------------------- Raw
    R = []
    R.append('#include-once')
    R.append('; SPDX-License-Identifier: GPL-3.0-or-later')
    R.append('; =============================================================================================================')
    R.append('; Title .........: CCLibVLC_Raw')
    R.append('; AutoIt Version : 3.3.14.5+')
    R.append('; Language ......: English')
    R.append('; Description ...: Raw 1:1 wrappers for every exported libVLC %s function (cdecl, UTF-8, x86/x64).' % vlc_ver)
    R.append(';                  GENERATED FILE - do not edit. Regenerate with tools/generate_raw.py.')
    R.append('; Author(s) .....: Markus Debus, CITRO Computer')
    R.append('; Generated .....: %s from VLC %s headers, %d functions' % (now, vlc_ver, len(index)))
    R.append('; Remarks .......: Include CCLibVLC.au3 instead of this file. All wrappers need _VLC_Startup() first.')
    R.append(';                  Naming: C function libvlc_xxx  ->  AutoIt function _libvlc_xxx')
    R.append(';                  - pointer parameters accept Ptr, Hwnd, numbers or DllStructs')
    R.append(';                  - string parameters take AutoIt strings (converted to UTF-8), Null/Default = NULL')
    R.append(';                  - string results are converted from UTF-8; "char *" results are freed with libvlc_free')
    R.append(';                  - C out parameters (int *, unsigned *, T ***) are ByRef parameters')
    R.append(';                  - void functions return True on success')
    R.append(';                  - DllCall failures: @error = $VLC_ERR_DLLCALL, @extended = DllCall() @error')
    R.append('; =============================================================================================================')
    R.append('')
    R.append('; Functions intentionally not wrapped:')
    for n, why in skipped:
        R.append(';   %-45s %s' % (n, why))
    R.append('')
    cur_h = None
    for h, lines in funcs:
        if h != cur_h:
            if cur_h is not None:
                R.append('#EndRegion ' + cur_h)
                R.append('')
            R.append('#Region ' + h)
            R.append('')
            cur_h = h
        R.extend(lines)
    R.append('#EndRegion ' + cur_h)
    R.append('')
    with open(os.path.join(out_dir, 'CCLibVLC_Raw.au3'), 'w', encoding='utf-8', newline='\r\n') as f:
        f.write(bom + '\n'.join(R))

    # ---------------------------------------------------------- Constants
    C = []
    C.append('#include-once')
    C.append('; SPDX-License-Identifier: GPL-3.0-or-later')
    C.append('; =============================================================================================================')
    C.append('; Title .........: CCLibVLC_Constants')
    C.append('; Description ...: libVLC %s enumerations as AutoIt constants (names identical to C).' % vlc_ver)
    C.append(';                  GENERATED FILE - do not edit. Regenerate with tools/generate_raw.py.')
    C.append('; Author(s) .....: Markus Debus, CITRO Computer')
    C.append('; Generated .....: %s' % now)
    C.append('; =============================================================================================================')
    C.append('')
    names_ci = {}
    for ename, items, h in enums:
        C.append('; enum %s (%s)' % (ename, h))
        for n, v in items:
            # AutoIt variables are case-insensitive: LIBVLC_ERROR (log level)
            # would collide with libvlc_Error (player state)
            if ename == 'libvlc_log_level':
                n = n.replace('LIBVLC_', 'LIBVLC_LOG_')
            key = n.lower()
            if key in names_ci:
                if names_ci[key] != v:
                    raise ValueError('case-insensitive constant clash %s' % n)
                continue
            names_ci[key] = v
            C.append('Global Const $%s = %s' % (n, ('0x%X' % v) if v >= 256 and (v & 0xFF) == 0 else v))
        C.append('')
    # derived constant
    C.append('Global Const $libvlc_role_Last = $libvlc_role_Test')
    C.append('')
    with open(os.path.join(out_dir, 'CCLibVLC_Constants.au3'), 'w', encoding='utf-8', newline='\r\n') as f:
        f.write(bom + '\n'.join(C))

    # ------------------------------------------------------------- index
    with open(os.path.join(out_dir, 'tools', 'raw_index.tsv'), 'w', encoding='utf-8') as f:
        for m in index:
            f.write('%s\t%s\t%s\t%s\n' % (m['au'], m['header'], m['syntax'], m['brief']))
    print('functions: %d, skipped: %d, enums: %d, constants: %d' % (len(index), len(skipped), len(enums), len(names_ci)))
    missing = exported - seen
    print('exported but not declared in public headers:', ' '.join(sorted(missing)))


if __name__ == '__main__':
    main()
