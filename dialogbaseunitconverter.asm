.386
.model flat, stdcall
option casemap: none

include         C:\masm32\include\windows.inc
include         C:\masm32\include\user32.inc
include         C:\masm32\include\kernel32.inc
includelib      C:\masm32\lib\user32.lib
includelib      C:\masm32\lib\kernel32.lib


ICO_MAIN                equ     1000h
DLG_MAIN                equ     1
IDC_TEXT                equ     100
IDC_EDITBASEUNITX       equ     101
IDC_EDITBASEUNITY       equ     102
IDC_EDITPIXELX          equ     103
IDC_EDITPIXELY          equ     104
IDC_TOUNIT              equ     200
IDC_TOPIXEL             equ     201

.const
szText          db      '一个对话框基本单位对应像素数', 0DH, 0AH
                db      '水平方向(X轴)： %d', 0DH, 0AH
                db      '竖直方向(Y轴)： %d', 0
szCaption       db      'msg', 0

.data?
hInstance       dd      ?
szBuffer        db      256 dup(?) 
dwDialogunitX   dd      ?
dwDialogunitY   dd      ?
dwTranslated    dd      ?

.code
_ProcDlgMain    proc    uses ebx edi esi, hWnd, uMsg, wParam, lParam

        mov     eax, uMsg
        .if eax == WM_CLOSE
                invoke  EndDialog, hWnd, NULL
        .elseif eax == WM_INITDIALOG
                invoke  GetDialogBaseUnits
                mov     ebx, eax
                shr     eax, 16
                mov     dwDialogunitY, eax
                movzx   ebx, bx
                mov     dwDialogunitX, ebx
                invoke  wsprintf, offset szBuffer, offset szText, ebx, eax
                invoke  SetDlgItemText, hWnd, IDC_TEXT, offset szBuffer
        .elseif eax == WM_COMMAND
                mov     eax, wParam
                .if     ax == IDC_TOPIXEL
                        ; pixelX = (dialogunitX * baseunitX) / 4 
                        ; pixelY = (dialogunitY * baseunitY) / 8 
                        invoke  GetDlgItemInt, hWnd, IDC_EDITBASEUNITX, offset dwTranslated, FALSE
                        .if     dwTranslated == TRUE
                                mul     dwDialogunitX
                                mov     ebx, 4
                                div     ebx
                                invoke  SetDlgItemInt, hWnd, IDC_EDITPIXELX, eax, FALSE
                        .endif
                        invoke  GetDlgItemInt, hWnd, IDC_EDITBASEUNITY, offset dwTranslated, FALSE
                        .if     dwTranslated == TRUE
                                mul     dwDialogunitY
                                mov     ebx, 8
                                div     ebx
                                invoke  SetDlgItemInt, hWnd, IDC_EDITPIXELY, eax, FALSE
                        .endif
                .elseif ax == IDC_TOUNIT
                        ; dialogunitX = (pixelX * 4) / baseunitX 
                        ; dialogunitY = (pixelY * 8) / baseunitY 
                        invoke  GetDlgItemInt, hWnd, IDC_EDITPIXELX, offset dwTranslated, FALSE
                        .if     dwTranslated == TRUE
                                mov     ebx, 4
                                mul     ebx
                                div     dwDialogunitX
                                invoke  SetDlgItemInt, hWnd, IDC_EDITBASEUNITX, eax, FALSE
                        .endif
                        invoke  GetDlgItemInt, hWnd, IDC_EDITPIXELY, offset dwTranslated, FALSE
                        .if     dwTranslated == TRUE
                                mov     ebx, 8
                                mul     ebx
                                div     dwDialogunitY
                                invoke  SetDlgItemInt, hWnd, IDC_EDITBASEUNITY, eax, FALSE
                        .endif 
                .endif
        .else
                mov     eax, FALSE
                ret
        .endif
        ; 此处与窗口过程正好相反，处理完成返回TRUE， 交给系统处理返回FALSE
        mov     eax, TRUE
        ret
_ProcDlgMain    endp

start:
        invoke  GetModuleHandle, NULL
        mov     hInstance, eax
        invoke  DialogBoxParam, hInstance, DLG_MAIN, NULL, offset _ProcDlgMain, NULL
        invoke  ExitProcess, NULL
        end     start