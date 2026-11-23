# Emulation test for CCLibVLC native thunks (unicorn). Exit code != 0 on failure.
import struct, sys
from unicorn import *
from unicorn.x86_const import *

def run(arch, post_ok):
    x64 = arch == 'x64'
    code = open('thunks_%s.bin' % arch, 'rb').read()
    mu = Uc(UC_ARCH_X86, UC_MODE_64 if x64 else UC_MODE_32)
    CODE, STUB, DATA, STACK = 0x100000, 0x200000, 0x300000, 0x400000
    for a in (CODE, STUB, DATA, STACK): mu.mem_map(a, 0x10000)
    mu.mem_write(CODE, code)
    ps = 8 if x64 else 4
    SP, BP, IP = (UC_X86_REG_RSP, UC_X86_REG_RBP, UC_X86_REG_RIP) if x64 else (UC_X86_REG_ESP, UC_X86_REG_EBP, UC_X86_REG_EIP)
    stubs = {'HeapAlloc': STUB+0x10, 'HeapFree': STUB+0x20, 'PostMessageW': STUB+0x30, 'Func': STUB+0x40, 'RET': STUB+0x80}
    for a in stubs.values(): mu.mem_write(a, b'\x90')  # nop, intercepted by hook
    log = []
    HEAPBLK = DATA + 0x8000
    def rd(addr, n): return bytes(mu.mem_read(addr, n))
    def rdp(addr): return struct.unpack('<Q' if x64 else '<I', rd(addr, ps))[0]
    def args(n):
        if x64:
            regs = [mu.reg_read(r) for r in (UC_X86_REG_RCX, UC_X86_REG_RDX, UC_X86_REG_R8, UC_X86_REG_R9)]
            return regs[:n]
        sp = mu.reg_read(SP)
        return [rdp(sp + 4 + 4*i) for i in range(n)]
    def ret(val, nargs_stdcall):
        sp = mu.reg_read(SP)
        ra = rdp(sp)
        mu.reg_write(UC_X86_REG_RAX if x64 else UC_X86_REG_EAX, val)
        mu.reg_write(SP, sp + ps + (0 if x64 else 4*nargs_stdcall))
        mu.reg_write(IP, ra)
    def hook(uc, addr, size, _):
        if addr == stubs['RET']:
            uc.emu_stop(); return
        name = {v: k for k, v in stubs.items()}.get(addr)
        if not name: return
        sp = mu.reg_read(SP)
        if x64:
            assert sp % 16 == 8, '%s: stack misaligned at call (rsp=%x)' % (name, sp)
            # clobber volatile regs like a real callee would
            for r in (UC_X86_REG_RCX, UC_X86_REG_RDX, UC_X86_REG_R8, UC_X86_REG_R9, UC_X86_REG_R10, UC_X86_REG_R11):
                mu.reg_write(r, 0xDEADBEEFDEADBEEF)
        if name == 'HeapAlloc':
            a = args(3) if not x64 else log_args[:3]
            log.append(('HeapAlloc',) + tuple(a))
            ret(HEAPBLK, 3)
        elif name == 'PostMessageW':
            a = args(4) if not x64 else log_args[:4]
            log.append(('PostMessageW',) + tuple(a))
            ret(1 if post_ok else 0, 4)
        elif name == 'HeapFree':
            a = args(3) if not x64 else log_args[:3]
            log.append(('HeapFree',) + tuple(a))
            ret(1, 3)
        elif name == 'Func':
            a = args(2) if not x64 else log_args
            if not x64:
                sp2 = mu.reg_read(SP)
                a = [rdp(sp2 + 4), rdp(sp2 + 8)]
            log.append(('Func',) + tuple(a[:2]))
            ret(0, 0)  # cdecl
    log_args = []
    def hook_pre(uc, addr, size, _):
        # capture register args before the generic hook clobbers them
        nonlocal log_args
        if x64 and addr in stubs.values():
            log_args = [mu.reg_read(r) for r in (UC_X86_REG_RCX, UC_X86_REG_RDX, UC_X86_REG_R8, UC_X86_REG_R9)]
        hook(uc, addr, size, _)
    mu.hook_add(UC_HOOK_CODE, hook_pre, begin=STUB, end=STUB+0x100)

    # ---- event thunk
    ev = DATA + 0x100
    evsize = 32 if x64 else 16
    evbytes = bytes(range(0x41, 0x41 + evsize))
    mu.mem_write(ev, evbytes + b'\xEE' * 16)
    ctx = DATA + 0x200
    vals = [stubs['HeapAlloc'], stubs['HeapFree'], stubs['PostMessageW'], 0x1234, 0x5678, 0x9A57, 77, evsize]
    mu.mem_write(ctx, b''.join(struct.pack('<Q' if x64 else '<I', v) for v in vals))
    sp0 = STACK + 0x8000 - (8 if x64 else 0)   # x64: rsp = 8 mod 16 at function entry
    canary = {UC_X86_REG_RBX if x64 else UC_X86_REG_EBX: 0x11, UC_X86_REG_RSI if x64 else UC_X86_REG_ESI: 0x22,
              UC_X86_REG_RDI if x64 else UC_X86_REG_EDI: 0x33, BP: 0x44}
    for r, v in canary.items(): mu.reg_write(r, v)
    if x64:
        mu.mem_write(sp0, struct.pack('<Q', stubs['RET']))
        mu.reg_write(UC_X86_REG_RCX, ev); mu.reg_write(UC_X86_REG_RDX, ctx)
    else:
        mu.mem_write(sp0, struct.pack('<III', stubs['RET'], ev, ctx))
    mu.reg_write(SP, sp0)
    mu.emu_start(CODE, STUB + 0x81, count=10000)
    assert mu.reg_read(SP) == sp0 + ps, 'stack not balanced'
    for r, v in canary.items(): assert mu.reg_read(r) == v, 'callee-saved register clobbered'
    assert log[0] == ('HeapAlloc', 0x1234, 0, evsize), log[0]
    assert rd(HEAPBLK, evsize) == evbytes, 'event copy wrong'
    assert rd(HEAPBLK + evsize, 4) == b'\x00' * 4, 'copied too much'
    assert log[1] == ('PostMessageW', 0x5678, 0x9A57, HEAPBLK, 77), log[1]
    if post_ok:
        assert len(log) == 2, log
    else:
        assert log[2] == ('HeapFree', 0x1234, 0, HEAPBLK), log
    # ---- NULL ctx must be a no-op
    log.clear()
    if x64:
        mu.mem_write(sp0, struct.pack('<Q', stubs['RET'])); mu.reg_write(UC_X86_REG_RCX, ev); mu.reg_write(UC_X86_REG_RDX, 0)
    else:
        mu.mem_write(sp0, struct.pack('<III', stubs['RET'], ev, 0))
    mu.reg_write(SP, sp0)
    mu.emu_start(CODE, STUB + 0x81, count=10000)
    assert log == [] and mu.reg_read(SP) == sp0 + ps
    # ---- worker thunk
    log.clear()
    wctx = DATA + 0x400
    mu.mem_write(wctx, struct.pack('<QQQ' if x64 else '<III', stubs['Func'], 0xABCD, 0x1234))
    for r, v in canary.items(): mu.reg_write(r, v)
    if x64:
        mu.mem_write(sp0, struct.pack('<Q', stubs['RET'])); mu.reg_write(UC_X86_REG_RCX, wctx)
    else:
        mu.mem_write(sp0, struct.pack('<II', stubs['RET'], wctx))
    mu.reg_write(SP, sp0)
    mu.emu_start(CODE + 0x80, STUB + 0x81, count=10000)
    assert log == [('Func', 0xABCD, 0x1234)], log
    exp_sp = sp0 + ps + (0 if x64 else 4)       # stdcall thread proc pops its argument
    assert mu.reg_read(SP) == exp_sp, 'worker stack not balanced'
    assert mu.reg_read(UC_X86_REG_RAX if x64 else UC_X86_REG_EAX) == 0
    for r, v in canary.items(): assert mu.reg_read(r) == v
    print('%s post_ok=%s: OK' % (arch, post_ok))

for arch in ('x64', 'x86'):
    for ok in (True, False):
        run(arch, ok)
