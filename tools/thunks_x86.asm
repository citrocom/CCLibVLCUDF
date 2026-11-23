; SPDX-License-Identifier: GPL-3.0-or-later
; CCLibVLC native thunks, x86 (32 bit)
; Assemble: nasm -f bin -o thunks_x86.bin thunks_x86.asm
;
; Context block used by the event thunk (8 pointer-sized fields):
;   +0  pHeapAlloc   +4  pHeapFree   +8  pPostMessageW  +12 hHeap
;   +16 hWnd         +20 uMsg        +24 cookie         +28 cbRecord (16)
;
; Worker context: +0 pFunc (void __cdecl f(void*[, void*])), +4 pArg1, +8 pArg2

bits 32

; ---------------------------------------------------------------------------
; void __cdecl event_thunk(const libvlc_event_t *p_event, void *ctx)
; Win32 APIs are __stdcall (callee pops arguments).
; ---------------------------------------------------------------------------
event_thunk:
    push    ebx
    push    esi
    push    edi
    mov     esi, [esp+16]               ; p_event (3 pushes + return address)
    mov     ebx, [esp+20]               ; ctx
    test    ebx, ebx
    jz      .done
    test    esi, esi
    jz      .done
    push    dword [ebx+28]              ; dwBytes
    push    0                           ; dwFlags
    push    dword [ebx+12]              ; hHeap
    call    [ebx+0]                     ; HeapAlloc
    test    eax, eax
    jz      .done
    mov     edi, eax
    mov     ecx, [esi]
    mov     [edi], ecx
    mov     ecx, [esi+4]
    mov     [edi+4], ecx
    mov     ecx, [esi+8]
    mov     [edi+8], ecx
    mov     ecx, [esi+12]
    mov     [edi+12], ecx
    push    dword [ebx+24]              ; lParam = cookie
    push    edi                         ; wParam = block
    push    dword [ebx+20]              ; uMsg
    push    dword [ebx+16]              ; hWnd
    call    [ebx+8]                     ; PostMessageW
    test    eax, eax
    jnz     .done
    push    edi                         ; post failed: free block
    push    0
    push    dword [ebx+12]
    call    [ebx+4]                     ; HeapFree
.done:
    pop     edi
    pop     esi
    pop     ebx
    ret                                 ; cdecl: caller cleans up

    times 0x80 - ($ - $$) db 0xCC

; ---------------------------------------------------------------------------
; DWORD __stdcall worker_thunk(void *wctx)
; Calls wctx->pFunc(wctx->pArg1, wctx->pArg2) (cdecl, caller cleans up, so
; functions with one argument ignore the second one).
; ---------------------------------------------------------------------------
worker_thunk:
    mov     eax, [esp+4]
    push    dword [eax+8]               ; pArg2
    push    dword [eax+4]               ; pArg1
    call    [eax]                       ; pFunc (cdecl)
    add     esp, 8
    xor     eax, eax
    ret     4

    times 0xC0 - ($ - $$) db 0xCC
