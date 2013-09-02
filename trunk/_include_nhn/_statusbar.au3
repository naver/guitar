#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.6.1
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here


#include <GUIConstantsEX.au3>
#include <Constants.au3>
#include <WindowsConstants.au3>
#include <GuiStatusBar.au3>
#include <FontConstants.au3>
#include <WinAPI.au3>

Opt('MustDeclareVars', 1)


Func _WM_DRAWITEM($hWnd, $Msg, $wParam, $lParam)
    #forceref $hWnd, $Msg, $wParam, $lParam
    Local $tagDRAWITEMSTRUCT = DllStructCreate("uint cType;uint cID;uint itmID;" & _
    "uint itmAction;uint itmState;hwnd hItm;hwnd hDC;int itmRect[4];dword itmData", $lParam)
    Local $hItm = DllStructGetData($tagDRAWITEMSTRUCT, "hItm"); retrieve statusbar handle

    Switch _WinAPI_GetClassName($hItm);an example of how message handler does not have to rely on having global variable for statusbar in advance
;Switch $hItm
        Case "msctls_statusbar32"
;Case $hStatus
            Local $hDC = DllStructGetData($tagDRAWITEMSTRUCT, "hDC") ; device context for statusbar for color and/or font
            Local $iID = DllStructGetData($tagDRAWITEMSTRUCT, "itmID"); statusbar part number
    ; get 32-bit value in itmData when text has SBT_OWNERDRAW drawing type - pointer to struct with text and color
            Local $pParam = DllStructGetData($tagDRAWITEMSTRUCT, "itmData")
            Local $tParam = DllStructCreate("wchar[512];dword;dword;dword", $pParam)
    ; create RECT structure from itmRect byte array for part metrics
            Local $tRECT = DllStructCreate("int Left;int Top;int Right;int Bottom")
    ; metrics not same as non-ownerdrawn part for some reason, so 1 added for alignment
            DllStructSetData($tRECT, "Left", DllStructGetData($tagDRAWITEMSTRUCT, "itmRect", 1)+1)
            DllStructSetData($tRECT, "Top", DllStructGetData($tagDRAWITEMSTRUCT, "itmRect", 2)+1)
            DllStructSetData($tRECT, "Right", DllStructGetData($tagDRAWITEMSTRUCT, "itmRect", 3))
            DllStructSetData($tRECT, "Bottom", DllStructGetData($tagDRAWITEMSTRUCT, "itmRect", 4))
            _WinAPI_SetBkMode($hDC, $TRANSPARENT); otherwise text background set to 0xFFFFFF
            _WinAPI_SetTextColor($hDC, DllStructGetData($tParam, 2)); set part text colour from struct
            If Not DllStructGetData($tParam, 4) Then; check if background should be transparent
                Local $iBkColor = DllStructGetData($tParam, 3), $hStatusDC, $hBrushBk
                $hStatusDC = _WinAPI_GetDC($hItm)
                $hBrushBk = _WinAPI_CreateSolidBrush($iBkColor)
                _WinAPI_FillRect($hStatusDC, DllStructGetPtr($tRect), $hBrushBk)
                _WinAPI_DeleteObject($hBrushBk)
                _WinAPI_ReleaseDC($hItm, $hStatusDC)
            EndIf
        ; draw text to DC (can also use gdi32 TextOutW and ExtTextOut API's)
            _WinAPI_DrawText($hDC, DllStructGetData($tParam, 1), $tRect, $DT_LEFT)
    EndSwitch
    Return $GUI_RUNDEFMSG
EndFunc

Func _GUICtrlStatusBar_SetColor($hWnd, $sText = "", $iPart = 0, $iColor = 0, $iBkColor = -1)
;Author: rover - modified ownerdraw version of _GUICtrlStatusBar_SetText() from GuiStatusBar.au3
;Includes RGB2BGR() - Author: Siao - http://www.autoitscript.com/forum/index....=&showtopic=57161&view=findpos
;sets itmData element of statusbar DRAWITEMSTRUCT with pointer to struct with text and colour for part number
    ;If $Debug_SB Then _GUICtrlStatusBar_ValidateClassName($hWnd)
    Local $ret, $tStruct, $pStruct, $iBuffer
; In Microsoft Windows XP and earlier, the text for each part is limited to 127 characters.
; This limitation has been removed in Windows Vista.
; set sufficiently large buffer for use with Vista (can exceed XP limit of 128 chars)
    $tStruct = DllStructCreate("wchar Text[512];dword Color;dword BkColor;dword Trans")
    Switch $iBkColor
        Case -1
            DllStructSetData($tStruct, "Trans", 1)
        Case Else
            $iBkColor = BitAND(BitShift(String(Binary($iBkColor)), 8), 0xFFFFFF)
            DllStructSetData($tStruct, "Trans", 0)
            DllStructSetData($tStruct, "BkColor", $iBkColor)
    EndSwitch
    $iColor = BitAND(BitShift(String(Binary($iColor)), 8), 0xFFFFFF); From RGB2BGR() Author: Siao
    DllStructSetData($tStruct, "Text", $sText)
    DllStructSetData($tStruct, "Color", $iColor)
    $pStruct = DllStructGetPtr($tStruct)
    If _GUICtrlStatusBar_IsSimple($hWnd) Then $iPart = $SB_SIMPLEID
;FOR INTERNAL STATUSBARS ONLY
    If _WinAPI_InProcess($hWnd, $__ghSBLastWnd) Then
        $ret = _SendMessage($hWnd, $SB_SETTEXTW, BitOR($iPart, $SBT_OWNERDRAW), $pStruct, 0, "wparam", "ptr")
        Return $tStruct; returns struct to global variable
    EndIf
    Return 0
EndFunc ;==>_GUICtrlStatusBar_SetColor