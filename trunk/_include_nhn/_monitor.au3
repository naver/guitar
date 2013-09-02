#include-once
#include ".\_include_nhn\_util.au3"

Global Const $MONITOR_DEFAULTTONULL     = 0x00000000
Global Const $MONITOR_DEFAULTTOPRIMARY  = 0x00000001
Global Const $MONITOR_DEFAULTTONEAREST  = 0x00000002

Global Const $CCHDEVICENAME             = 32
Global Const $MONITORINFOF_PRIMARY      = 0x00000001


;GetMonitorFromPointTest()

;local $a
;$a = GetAareFromPoint(2100,100)
;_msg($a)

func GetMonitorFromPointTest()

local $hMonitor

$hMonitor = GetMonitorFromPoint(2002, 102)
;$hMonitor = GetMonitorFromPoint(-2, 0)
;$hMonitor = GetMonitorFromPoint(@DesktopWidth, 0)

If $hMonitor <> 0 Then
    Dim $arMonitorInfos[4]
    If GetMonitorInfos($hMonitor, $arMonitorInfos) Then _
        Msgbox(0, "Monitor-Infos", "Rect-Monitor" & @Tab & ": " & $arMonitorInfos[0] & @LF & _
                            "Rect-Workarea" & @Tab & ": " & $arMonitorInfos[1] & @LF & _
                            "PrimaryMonitor?" & @Tab & ": " & $arMonitorInfos[2] & @LF & _
                            "Devicename" & @Tab & ": " & $arMonitorInfos[3])
EndIf

Exit

endfunc


Func GetAareFromPoint($x, $y)

local $hMonitor
local $arMonitorInfos[4]
local $aPos[5]

	;debug("GetAareFromPoint : " & $x, $y)

	$hMonitor = GetMonitorFromPoint($x, $y)

	If $hMonitor <> 0 Then
		If GetMonitorInfos($hMonitor, $arMonitorInfos) Then
			$aPos = StringSplit($arMonitorInfos[0],";")
			$apos[3] = $apos[3] - $apos[1]
			$apos[4] = $apos[4] - $apos[2]

		endif
	Else
		$apos[1] =0
		$apos[2] =0
		$apos[3] =@DesktopWidth
		$apos[4] =@DesktopHeight

	endif

	return $aPos

endfunc


Func GetWorkAareFromPoint($x, $y)

local $hMonitor
local $arMonitorInfos[4]
local $aPos[7]

	;debug("GetAareFromPoint : " & $x, $y)

	$hMonitor = GetMonitorFromPoint($x, $y)

	If $hMonitor <> 0 Then
		If GetMonitorInfos($hMonitor, $arMonitorInfos) Then
			$aPos = StringSplit($arMonitorInfos[1],";")
			redim $apos[7]
		endif
	Else
		$apos[1] =0
		$apos[2] =0
		$apos[3] =@DesktopWidth
		$apos[4] =@DesktopHeight
	endif

	$apos[5] = $apos[3] - $apos[1]
	$apos[6] = $apos[4] - $apos[2]

	return $aPos

endfunc



Func GetMonitorFromPoint($x, $y)
	local $hMonitor
    $hMonitor = DllCall("user32.dll", "hwnd", "MonitorFromPoint", _
                                            "int", $x, _
                                            "int", $y, _
                                            "int", $MONITOR_DEFAULTTONULL)
    Return $hMonitor[0]
EndFunc


Func GetMonitorInfos($hMonitor, ByRef $arMonitorInfos)
	local $nResult
    Local $stMONITORINFOEX = DllStructCreate("dword;int[4];int[4];dword;char[" & $CCHDEVICENAME & "]")
    DllStructSetData($stMONITORINFOEX, 1, DllStructGetSize($stMONITORINFOEX))

    $nResult = DllCall("user32.dll", "int", "GetMonitorInfo", _
                                            "hwnd", $hMonitor, _
                                            "ptr", DllStructGetPtr($stMONITORINFOEX))
    If $nResult[0] = 1 Then
        $arMonitorInfos[0] = DllStructGetData($stMONITORINFOEX, 2, 1) & ";" & _
            DllStructGetData($stMONITORINFOEX, 2, 2) & ";" & _
            DllStructGetData($stMONITORINFOEX, 2, 3) & ";" & _
            DllStructGetData($stMONITORINFOEX, 2, 4)
        $arMonitorInfos[1] = DllStructGetData($stMONITORINFOEX, 3, 1) & ";" & _
            DllStructGetData($stMONITORINFOEX, 3, 2) & ";" & _
            DllStructGetData($stMONITORINFOEX, 3, 3) & ";" & _
            DllStructGetData($stMONITORINFOEX, 3, 4)
        $arMonitorInfos[2] = DllStructGetData($stMONITORINFOEX, 4)
        $arMonitorInfos[3] = DllStructGetData($stMONITORINFOEX, 5)
    EndIf

    Return $nResult[0]
EndFunc

;local $hWIn = WinGetHandle("자유게시판")
;_MoveWindowtoWorkArea($hWIn)

func _MoveWindowtoWorkArea($hWIn)

	local $aWinPos = WinGetPos($hWIn)
	local $hMonitor = GetMonitorFromPoint($aWinPos[0], $aWinPos[1])
	local $arMonitorInfos[4]
	local $aNewPost
	local $aTempSplit
	local $bRelocate = False
	local $iNewX
	local $iNewY

	;_msg($hMonitor)
	;_msg($aWinPos)

	; MAX 인 경우 제외
	if Bitand(WinGetState($hWIn), 32  ) = 32 then return



	if $hMonitor <> 0 then
		If GetMonitorInfos($hMonitor, $arMonitorInfos) Then
			$aTempSplit  = StringSplit($arMonitorInfos[1],";")

			if $aWinPos[0] + $aWinPos[2] > $aTempSplit[3] or $aWinPos[1] + $aWinPos[3] > $aTempSplit[4] Then

				;_debug($aWinPos[0] + $aWinPos[2], $aTempSplit[3])
				;_debug($aWinPos[1] + $aWinPos[3], $aTempSplit[4])
				GetMonitorInfos($hMonitor, $arMonitorInfos)
				$aNewPost  = $aTempSplit
				$bRelocate = True

			endif
		endif
	Else
		$hMonitor = GetMonitorFromPoint(1,1)
		GetMonitorInfos($hMonitor, $arMonitorInfos)
		$aNewPost  = StringSplit($arMonitorInfos[1],";")
		;_debug($aNewPost)
		$bRelocate = True
	EndIf

	If $bRelocate then
		;_debug(($aNewPost [3] - $aNewPost [1]) / 2)
		$iNewX = $aNewPost [1] + (($aNewPost [3] - $aNewPost [1]) / 2) - ($aWinPos[2]  / 2)
		$iNewY = $aNewPost [2] + (($aNewPost [4] - $aNewPost [2]) / 2) - ($aWinPos[3]  / 2)

		WinMove($hWIn,"",$iNewX, $iNewY)
		;_debug("옴겼으")
	endif

	return $bRelocate

endfunc