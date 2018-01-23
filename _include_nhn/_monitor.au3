#include-once
#include ".\_include_nhn\_util.au3"
#include <WinAPIGdi.au3>
#include <ScreenCapture.au3>

Global Const $CCHDEVICENAME             = 32
Global Const $MONITORINFOF_PRIMARY      = 0x00000001


;debug(GetFullMonitorSize())

;local $a
;$a = GetAareFromPoint(2100,100)
;_msg($a)


;_FullScreenCapture_Capture("c:\1.png")

Func  GetFullMonitorSize()

	Local $aPos, $aData = _WinAPI_EnumDisplayMonitors()
	local $aRet[3][3]
	local $aXY[5]

	; 전체 모니터 정보 얻기
	If IsArray($aData) Then

		ReDim $aData[$aData[0][0] + 1][5]
		For $i = 1 To $aData[0][0]
			$aPos = _WinAPI_GetPosFromRect($aData[$i][1])
			For $j = 0 To 3
				$aData[$i][$j + 1] = $aPos[$j]
			Next
		Next

	EndIf


	; 실제 크기 정보로 변경
	;_ArrayDisplay($aData, '_WinAPI_EnumDisplayMonitors')

	$aRet[1][1]  = 99999999999
	$aRet[1][2]  = 99999999999
	$aRet[2][1]  = -99999999999
	$aRet[2][2]  = -99999999999

	for $i=1 to ubound($aData) -1

		$aData[$i][3] = $aData[$i][1] + $aData[$i][3]
		$aData[$i][4] = $aData[$i][2] + $aData[$i][4]

		; 최소값  X
		if  $aRet[1][1] > $aData[$i][1]  then $aRet[1][1] = $aData[$i][1]
		if  $aRet[1][1] > $aData[$i][3]  then $aRet[1][1] = $aData[$i][3]

		;최소값 Y
		if  $aRet[1][2] > $aData[$i][2]  then $aRet[1][2] = $aData[$i][2]
		if  $aRet[1][2] > $aData[$i][4]  then $aRet[1][2] = $aData[$i][4]

		; 최대값  X
		if  $aRet[2][1] < $aData[$i][1]  then $aRet[2][1] = $aData[$i][1]
		if  $aRet[2][1] < $aData[$i][3]  then $aRet[2][1] = $aData[$i][3]

		;최대값 Y
		if  $aRet[2][2] < $aData[$i][2]  then $aRet[2][2] = $aData[$i][2]
		if  $aRet[2][2] < $aData[$i][4]  then $aRet[2][2] = $aData[$i][4]

	next

	$aXY[1] = $aRet[1][1]
	$aXY[2] = $aRet[1][2]
	$aXY[3] = $aRet[2][1]
	$aXY[4] = $aRet[2][2]
	;_ScreenCapture_Capture("c:\1.png",$aRet[1][1] , $aRet[1][2] , $aRet[2][1] , $aRet[2][2] )
	;_ArrayDisplay($aData, '_WinAPI_EnumDisplayMonitors')
	return $aXY

endfunc


func _FullScreenCapture_Capture ($sFile, $bCursor  = False)

	local $aRet=GetFullMonitorSize()
	return _ScreenCapture_Capture($sFile,$aRet[1] , $aRet[2] , $aRet[3] , $aRet[4] )

endfunc

Func  GetAllMonitorInfoRec(ByRef $aAllMonitorInfo, $x, $y )

	local $hMonitor
	local $iNewIndex
	local $arMonitorInfos[4]

	$hMonitor = GetMonitorFromPoint(1,12)

	If $hMonitor <> 0 Then

		If GetMonitorInfos($hMonitor, $arMonitorInfos) Then

			$iNewIndex = ubound($aAllMonitorInfo)
			redim $aAllMonitorInfo[$iNewIndex+1][ubound($aAllMonitorInfo,2)]

			for $i=0 to ubound($arMonitorInfos) -1
				$aAllMonitorInfo[$iNewIndex][$i] = $arMonitorInfos[$i]
			next
		endif

	EndIf

	return $aAllMonitorInfo

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

				;debug($aWinPos[0] + $aWinPos[2], $aTempSplit[3])
				;debug($aWinPos[1] + $aWinPos[3], $aTempSplit[4])
				GetMonitorInfos($hMonitor, $arMonitorInfos)
				$aNewPost  = $aTempSplit
				$bRelocate = True

			endif
		endif
	Else
		$hMonitor = GetMonitorFromPoint(1,1)
		GetMonitorInfos($hMonitor, $arMonitorInfos)
		$aNewPost  = StringSplit($arMonitorInfos[1],";")
		;debug($aNewPost)
		$bRelocate = True
	EndIf

	If $bRelocate then
		;debug(($aNewPost [3] - $aNewPost [1]) / 2)
		$iNewX = $aNewPost [1] + (($aNewPost [3] - $aNewPost [1]) / 2) - ($aWinPos[2]  / 2)
		$iNewY = $aNewPost [2] + (($aNewPost [4] - $aNewPost [2]) / 2) - ($aWinPos[3]  / 2)

		WinMove($hWIn,"",$iNewX, $iNewY)
		;debug("옴겼으")
	endif

	return $bRelocate

endfunc