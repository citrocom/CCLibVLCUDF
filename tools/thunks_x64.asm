; SPDX-License-Identifier: GPL-3.0-or-later
; CCLibVLC native thunks, x64 (Microsoft x64 calling convention)
; Assemble: nasm -f bin -o thunks_x64.bin thunks_x64.asm
;
; Context block used by the event thunk (8 pointer-sized fields):
;   +0  pHeapAlloc   +8  pHeapFree   +16 pPostMessageW  +24 hHeap
;   +32 hWnd         +40 uMsg        +48 cookie         +56 cbRecord (32)
;
; Worker context (3 pointer-sized fields):
;   +0  pFunc (void __cdecl f(void*[, void*]))   +8  pArg1   +16 pArg2

bits 64
default rel

; ---------------------------------------------------------------------------
; void event_thunk(const libvlc_event_t *p_event, void *ctx)
; Runs on a VLC thread. Copies the event (32 bytes) into a heap block and
; posts it to the AutoIt window: PostMessageW(hWnd, uMsg, pBlock, cookie).
; Never calls libVLC, never blocks.
; ---------------------------------------------------------------------------
event_thunk:
    push    rbx
    push    rsi
    push    rdi
    sub     rsp, 0x20                   ; shadow space, keeps rsp 16-aligned
    mov     rsi, rcx                    ; p_event
    mov     rbx, rdx                    ; ctx
    test    rbx, rbx
    jz      .done
    test    rsi, rsi
    jz      .done
    mov     rcx, [rbx+24]               ; hHeap
    xor     edx, edx                    ; dwFlags = 0
    mov     r8,  [rbx+56]               ; size
    call    [rbx+0]                     ; HeapAlloc
    test    rax, rax
    jz      .done
    mov     rdi, rax
    mov     rcx, [rsi]
    mov     [rdi], rcx
    mov     rcx, [rsi+8]
    mov     [rdi+8], rcx
    mov     rcx, [rsi+16]
    mov     [rdi+16], rcx
    mov     rcx, [rsi+24]
    mov     [rdi+24], rcx
    mov     rcx, [rbx+32]               ; hWnd
    mov     edx, [rbx+40]               ; uMsg
    mov     r8,  rdi                    ; wParam = block
    mov     r9,  [rbx+48]               ; lParam = cookie
    call    [rbx+16]                    ; PostMessageW
    test    eax, eax
    jnz     .done
    mov     rcx, [rbx+24]               ; post failed: free block
    xor     edx, edx
    mov     r8,  rdi
    call    [rbx+8]                     ; HeapFree
.done:
    add     rsp, 0x20
    pop     rdi
    pop     rsi
    pop     rbx
    ret

    times 0x80 - ($ - $$) db 0xCC

; ---------------------------------------------------------------------------
; DWORD WINAPI worker_thunk(void *wctx)  - thread procedure for CreateThread
; Calls wctx->pFunc(wctx->pArg1, wctx->pArg2) (cdecl). Functions with one
; argument simply ignore the second one (caller-cleaned conventions).
; ---------------------------------------------------------------------------
worker_thunk:
    sub     rsp, 0x28                   ; shadow space + alignment
    mov     rax, rcx
    mov     rcx, [rax+8]                ; pArg1
    mov     rdx, [rax+16]               ; pArg2
    call    [rax]                       ; pFunc
    xor     eax, eax
    add     rsp, 0x28
    ret

    times 0xC0 - ($ - $$) db 0xCC
