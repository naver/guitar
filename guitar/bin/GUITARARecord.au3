#include-once

#Include <Misc.au3>
#include <IE.au3>
#include <ARRAY.au3>
#include <Process.au3>

#include ".\_include_nhn\_util.au3"

Global Const $_REType_KeyDown = "KD"
Global Const $_REType_MouseDown = "MD"
Global Const $_REType_MouseUp = "MU"

Global Enum $_REType = 1, $_RETime, $_REData1, $_REData2, $_REWidth, $_REHeight, $_REBrowserID, $_REEnd
Global $_RecordEvent[1][$_REEnd]
Global $_REHwndKeyHook
Global $_REHwndMouseHook
Global $_REHwndDll
Global $_RETimeInit
Global $_RENowRecording = False


;_debug(RecordTest())
;_debug(RecordToScriptTest())
;_debug(RecordToScriptTest(RecordTest()))

func RecordToScriptTest($sData = "")

	local $aRecordData [1000][$_REEnd]
	local $aWinWorkPos[5]
	local $aRet, $i

	$aWinWorkPos[0] = 410
	$aWinWorkPos[1] = 610
	$aWinWorkPos[2] = 700
	$aWinWorkPos[3] = 900

	if $sData = "" then

		$i = 0

		$i += 1
		$aRecordData[$i][1] = "KD"
		$aRecordData[$i][2] = 2912
		$aRecordData[$i][3] = 5

		$i += 1
		$aRecordData[$i][1] = "KD"
		$aRecordData[$i][2] = 2912
		$aRecordData[$i][3] = 66

		$i += 1
		$aRecordData[$i][1] = "KD"
		$aRecordData[$i][2] = 2912
		$aRecordData[$i][3] = 13

		$i += 1
		$aRecordData[$i][1] = "MD"
		$aRecordData[$i][2] = 798
		$aRecordData[$i][3] = 500
		$aRecordData[$i][4] = 823

		$i += 1
		$aRecordData[$i][1] = "MU"
		$aRecordData[$i][2] = 924
		$aRecordData[$i][3] = 500
		$aRecordData[$i][4] = 823

		$i += 1
		$aRecordData[$i][1] = "MD"
		$aRecordData[$i][2] = 1184
		$aRecordData[$i][3] = 807
		$aRecordData[$i][4] = 946

		$i += 1
		$aRecordData[$i][1] = "MU"
		$aRecordData[$i][2] = 1188
		$aRecordData[$i][3] = 807
		$aRecordData[$i][4] = 946


		$i += 1
		$aRecordData[$i][1] = "MD"
		$aRecordData[$i][2] = 1284
		$aRecordData[$i][3] = 800
		$aRecordData[$i][4] = 946

		$i += 1
		$aRecordData[$i][1] = "MU"
		$aRecordData[$i][2] = 3388
		$aRecordData[$i][3] = 800
		$aRecordData[$i][4] = 1146

		$i += 1
		$aRecordData[$i][1] = "KD"
		$aRecordData[$i][2] = 2912
		$aRecordData[$i][3] = 65

		redim $aRecordData [$i+1][$_REEnd]
	else
		$aRecordData = $sData
	endif

	return RecordToScript($aRecordData)

	;_debug($aRet)

endfunc


func RecordTest()

	local  $hwMain = GUICreate("Macro Editor", 100,100,100,100)

	GUISetState(@SW_SHOW, $hwMain)

	local $iTimer = TimerInit()

	_HookKeyBoardMouseRecord($hwMain)

	Do


	until TimerDiff($iTimer) > 5000

	return _UnHookKeyBoardMouseRecord()

endfunc


func RecordToScript($aRecordData)

	local $aScript[1], $i, $j
	local $iLastClickInfo[$_REEnd]
	local $bLongTime, $bflicking
	local $iLongTime = 2000
	local $iSleepInterval = 500
	local $iflickingArea = 10
	local $iLastActionTime = 0
	local $sLastScriptCommand
	local $sX1Pos, $sY1Pos, $sX2Pos, $sY2Pos
	local $sScriptCommand
	local $sSleep
	local $bSkip
	local $bNoSleep
	local $aKeyBuffer
	local $bAreaOver
	local $bDelete

	; ASC 13, 32 ~ 126 값만 남기고 나머지는 삭제

	do
		$bDelete = False
		for $i=1 to ubound($aRecordData) -1
			;_debug($i , ubound($aRecordData) -1)
			if $aRecordData[$i][$_REType] = $_REType_KeyDown then
				if not($aRecordData[$i][$_REData1] = 13 or ( $aRecordData[$i][$_REData1] > 31 and  $aRecordData[$i][$_REData1] < 127)) then
					_ArrayDelete($aRecordData,$i)
					$bDelete = True
					exitloop
				endif
			endif
		next
	until $bDelete = False

	for $i=1 to ubound($aRecordData) -1

		$bNoSleep = False

		switch $aRecordData[$i][$_REType]

			case $_REType_KeyDown

				$sScriptCommand = ""

				if changeSpecialRecordKey($aRecordData[$i][$_REData1]) <> $aRecordData[$i][$_REData1] then

					$sScriptCommand = changeSpecialRecordKey($aRecordData[$i][$_REData1])  & "키를 누른다"

					; 이전에 "입력 명령인경우 바로 붙어서 사용하고 신규로 추가하지 않음
					if stringinstr($sLastScriptCommand, "입력") <> 0 then
						_debug($aScript[ubound($aScript)-1])
						$aScript[ubound($aScript)-1] &= " " & $sScriptCommand
						$sScriptCommand = ""
					endif

				else

					if $i <> ubound($aRecordData) -1 then
						; 연속된 문자를 입력할 경우 하나의 명령으로 처리
						if $aRecordData[$i+1][$_REType] = $_REType_KeyDown and changeSpecialRecordKey($aRecordData[$i+1][$_REData1]) = $aRecordData[$i+1][$_REData1] then
							;_debug("중복" & changeSpecialRecordKey($aRecordData[$i+1][$_REData1]), $aRecordData[$i+1][$_REData1])

							$aRecordData[$i+1][$_RETime] = $aRecordData[$i][$_RETime]
							$aRecordData[$i+1][$_REData1] = $aRecordData[$i][$_REData1] & "|" &  $aRecordData[$i+1][$_REData1]
							$aRecordData[$i][$_REData1] = ""

						endif

						; 다음 명령이 "누른다" 일경우 쉼표 제거
						if changeSpecialRecordKey($aRecordData[$i+1][$_REData1]) <> $aRecordData[$i+1][$_REData1] then $bNoSleep = True

					endif

					if $aRecordData[$i][$_REData1] <> "" then

						$aKeyBuffer = stringsplit($aRecordData[$i][$_REData1], "|")

						$aRecordData[$i][$_REData1] = ""

						for $j=1 to ubound($aKeyBuffer) -1
							$aRecordData[$i][$_REData1] &= chr($aKeyBuffer[$j])
						next

						$sScriptCommand = '"' & $aRecordData[$i][$_REData1] & '"' & " 입력한다."
					endif
				endif

			case $_REType_MouseDown

				$iLastClickInfo[$_RETime] = $aRecordData[$i][$_RETime]
				$iLastClickInfo[$_REData1] = $aRecordData[$i][$_REData1]
				$iLastClickInfo[$_REData2] = $aRecordData[$i][$_REData2]

			case $_REType_MouseUp



				; 최종 마우스를 UP 했을 때 명령을 판단해서 추가함
				$bLongTime = _iif( $aRecordData[$i][$_RETime] -  $iLastClickInfo[$_RETime] > $iLongTime , True, False)
				$bflicking = _iif( abs($aRecordData[$i][$_REData1] -  $iLastClickInfo[$_REData1]) > $iflickingArea  or abs($aRecordData[$i][$_REData2] -  $iLastClickInfo[$_REData2]) > $iflickingArea , True, False)

				;_debug($aRecordData[$i][$_REData1] , $aWinWorkPos[0], $aWinWorkPos[2])
				$sX1Pos = round ($aRecordData[$i][$_REData1]  / $aRecordData[$i][$_REWidth] * 100,0) & "%"
				$sY1Pos = round ($aRecordData[$i][$_REData2] / $aRecordData[$i][$_REHeight] * 100,0) & "%"

				$sX2Pos = round ($iLastClickInfo[$_REData1] / $aRecordData[$i][$_REWidth] * 100,0) & "%"
				$sY2Pos = round ($iLastClickInfo[$_REData2] / $aRecordData[$i][$_REHeight] * 100,0) & "%"

				$bAreaOver = False

				if $bflicking then

					$bLongTime = False

					_Swap($sX1Pos, $sX2Pos)
					_Swap($sY1Pos, $sY2Pos)

				endif

				; 작업 영역에서 벗어나지 않은 경우에만
				if $bAreaOver = False then

					if $bLongTime then
						$sScriptCommand = '"' & $sX1Pos & "," & $sY1Pos &  '"' & " 위치롱탭 한다."
						;
						;$_RecordEvent[$iIndex][$_REBrowserID]


					elseif $bflicking then
						$sScriptCommand = '"' & $sX1Pos & "," & $sY1Pos & "," & $sX2Pos & "," & $sY2Pos &  '"' & " 플리킹한다."
					else
						$sScriptCommand = '"' & $sX1Pos & "," & $sY1Pos &  '"' & " 위치탭한다."
					endif

				endif

		EndSwitch

		if $sScriptCommand <> "" then

			if $i <> ubound($aRecordData) -1 and $aRecordData[$i+1][$_RETime] - $iLastActionTime > $iSleepInterval and $bNoSleep = False  then

				for $j=1 to int(($aRecordData[$i+1][$_RETime] - $aRecordData[$i+1][$_RETime]) / $iSleepInterval) + 1
					$sSleep &= " ,"
				next
			else
				$sSleep = ""
			endif

			_ArrayAdd($aScript,$sScriptCommand & $sSleep)

			$iLastActionTime = $aRecordData[$i][$_RETime]

			$sLastScriptCommand = $sScriptCommand

			$sScriptCommand = ""

		endif

	next

	return $aScript

endfunc


func changeSpecialRecordKey($sText)

	local $sRet = $sText

	Switch $sText

		case 13
			$sRet = '"{ENTER}"'

	EndSwitch

	return $sRet

endfunc


func addKeyMouseEvent($sType, $sData1, $sData2 ="")

	local $iIndex = ubound($_RecordEvent)
	local $sBrowserID
	local $sWorkArea
	local $bSkip = False

	redim $_RecordEvent[$iIndex+1][$_REEnd]



	;현재 윈도우 크기를 얻어서 저장 할 것
	$sBrowserID = getBrowserIDFromExe (_ProcessGetName(WinGetProcess("[active]")))

	$sWorkArea = _WinGetClientPos(WinGetHandle("[active]"))

	; 좌표가 벗어나지 않는 경우에만 기록 할것
	if $sType = $_REType_MouseDown or $sType = $_REType_MouseUp then
		if $sData1 < $sWorkArea[0] or $sData1 > $sWorkArea[0] + $sWorkArea[2] then $bSkip = True
		if $sData2 < $sWorkArea[1] or $sData2 > $sWorkArea[1] + $sWorkArea[3] then $bSkip = True
	endif

	if $sBrowserID = "" then $bSkip = True

	_debug($bSkip)

	if $bSkip = False then

		$_RecordEvent[$iIndex][$_REType] = $sType
		$_RecordEvent[$iIndex][$_RETime] = int(TimerDiff($_RETimeInit))
		$_RecordEvent[$iIndex][$_REWidth] = $sWorkArea[2]
		$_RecordEvent[$iIndex][$_REHeight] = $sWorkArea[3]
		$_RecordEvent[$iIndex][$_REBrowserID] = $sBrowserID

		if $sType = $_REType_MouseDown or $sType = $_REType_MouseUp then
			$_RecordEvent[$iIndex][$_REData1] = $sData1 -  $sWorkArea[0]
			$_RecordEvent[$iIndex][$_REData2] = $sData2 -  $sWorkArea[1]
		Else
			$_RecordEvent[$iIndex][$_REData1] = $sData1
		endif
		_debug ("no xy ", $sData1, $sData2)
		_debug ($_RecordEvent[$iIndex][$_REType] & ", " &  $_RecordEvent[$iIndex][$_RETime]  & ", " &   $_RecordEvent[$iIndex][$_REData1]  & ", " &   $_RecordEvent[$iIndex][$_REData2]  & ", " &   $_RecordEvent[$iIndex][$_REWidth]  & ", " &   $_RecordEvent[$iIndex][$_REHeight])

	endif

endfunc


Func _UnHookKeyBoardMouseRecord()

	TrayTip($_sProgramName, "레코딩 종료",5,1)

	If IsDeclared("_REHwndMouseHook") Then
		DLLCall("user32.dll","int","UnhookWindowsHookEx","hwnd",$_REHwndMouseHook[0])
	EndIf
    DLLCall("user32.dll","int","UnhookWindowsHookEx","hwnd",$_REHwndKeyHook[0])
    DLLCall("kernel32.dll","int","FreeLibrary","hwnd",$_REHwndDll[0])

	$_RENowRecording = False
	return $_RecordEvent

EndFunc


Func _HookKeyBoardMouseRecord($gui)

	TrayTip($_sProgramName, "레코딩 시작",5,1)

	$_REHwndDll = DLLCall("kernel32.dll","hwnd","LoadLibrary","str",".\kh.dll")
	local $keyHOOKproc = DLLCall("kernel32.dll","hwnd","GetProcAddress","hwnd",$_REHwndDll[0],"str","KeyProc")
	$_REHwndKeyHook  = DLLCall("user32.dll","hwnd","SetWindowsHookEx","int",2, _
			"hwnd",$keyHOOKproc[0],"hwnd",$_REHwndDll[0],"int",0)
	local $mouseHOOKproc = DLLCall("kernel32.dll","hwnd","GetProcAddress","hwnd",$_REHwndDll[0],"str","MouseProc")
	$_REHwndMouseHook = DLLCall("user32.dll","hwnd","SetWindowsHookEx","int",7, _
			"hwnd",$mouseHOOKproc[0],"hwnd",$_REHwndDll[0],"int",0)
	DLLCall(".\kh.dll","int","SetValuesMouse","hwnd",$gui,"hwnd",$_REHwndMouseHook[0])

	GUIRegisterMsg(0x1400 + 0x0A30,"_RecordMouseMacro") ;ldown
	GUIRegisterMsg(0x1400 + 0x0A31,"_RecordMouseMacro") ;mouse
	GUIRegisterMsg(0x1400 + 0x0B30,"_RecordMouseMacro") ;mouse
	GUIRegisterMsg(0x1400 + 0x0B31,"_RecordMouseMacro") ;mouse
	GUIRegisterMsg(0x1400 + 0x0A32,"_RecordMouseMacro") ;mouse
	GUIRegisterMsg(0x1400 + 0x0B32,"_RecordMouseMacro") ;mouse
	GUIRegisterMsg(0x1400 + 0x0C30,"_RecordMouseMacro") ;mouse dbc
	GUIRegisterMsg(0x1400 + 0x0C31,"_RecordMouseMacro") ;mouse dbc
	GUIRegisterMsg(0x1400 + 0x0D30, "_RecordMouseMacro") ;mouse wheel up
	GUIRegisterMsg(0x1400 + 0x0D31, "_RecordMouseMacro") ;mouse wheel down

	DLLCall(".\kh.dll","int","SetValuesKey","hwnd",$gui,"hwnd",$_REHwndKeyHook[0])

	GUIRegisterMsg(0x0400 + 0x0A30,"_RecordKeyboardMacro") ;key down
	GUIRegisterMsg(0x0400 + 0x0A31,"_RecordKeyboardMacro") ;key up

	$_RETimeInit = TimerInit()

	$_RENowRecording = True
	redim $_RecordEvent[1][$_REEnd]

EndFunc


;=============================================================================
; This is the brains of the whole keyboard recording.
; On start record disable all GUI controls and record until ESC key is pressed
; As user presses keys, each keypress is inserted into event listbox with
; delays inserted between each keypress
;=============================================================================
Func _RecordKeyboardMacro($hWndGUI, $MsgID, $WParam, $LParam)

	Local $IsGetDelays = True
	local $time_init = TimerInit()

	If _IsPressed(Hex($WParam,2)) Then
		;_debug(chr($WParam))
		if stringleft($WParam,2) ="0x" then $WParam = StringTrimLeft($WParam,2)
		addKeyMouseEvent($_REType_KeyDown,dec($WParam))
	endif

EndFunc


Func _RecordMouseMacro($hWndGUI, $MsgID, $WParam, $LParam)

	Local $pressed = "01"

	If $MsgID - 7728 < 4 Then ;mouse button down
		$pressed = $MsgID - 7728 + 1
	ElseIf $MsgID - 7984 < 4 Then;mouse button up
		$pressed = $MsgID - 7984 + 1
	EndIf

	If _IsPressed($pressed)  Then
		addKeyMouseEvent($_REType_MouseDown,BitAND($LParam,0x0000FFFF) , BitShift($LParam,16))
		;_debug(hex($LParam))

	ElseIf _IsPressed($pressed) = 0 Then
		addKeyMouseEvent($_REType_MouseUp,BitAND($LParam,0x0000FFFF) , BitShift($LParam,16))

			;_GUICtrlListAddItem($Seqlist,$keyboardLayout[$pressed] & "  Release" & "  (" & BitAND($LParam,0x0000FFFF) & "," & BitShift($LParam,16) & ")")
	EndIf

endfunc
