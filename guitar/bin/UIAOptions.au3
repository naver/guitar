#include-once

#include <GUIConstantsEx.au3>
#include <ButtonConstants.au3>

#include "UIACommon.au3"

global $_hOptionsContext
global $_aOptionsText[11][5]
global $_sOptionsType
global $_sOptionsSelect

func onClickOptionsAll($iNumber)

	local $sFileName

	$sFileName = $_aOptionsText[$iNumber][2]

	if FileExists($sFileName) = 1 then

		;checkBrforeSave("",True)

		; 파일열기 실패시 중단
		if loadScript ($sFileName) = False then return

		if $_aOptionsText[$iNumber][4] = "전체실행" then
			onClickRun()
		elseif $_aOptionsText[$iNumber][4] = "부분실행" then
			_GUICtrlRichEdit_SetSel ($_gEditScript,0,-1,False)
			onClickRetry()
		endif

	Else
		_ProgramError("지정된 파일을 찾을 수 없습니다. : " & $sFileName)
	endif

endfunc


Func createOptions()

	local $OptionsDummy, $OptionsCommon

	; At first create a dummy control for the options and a contextmenu for it
	$OptionsDummy = GUICtrlCreateDummy()
	$_hOptionsContext = GUICtrlCreateContextMenu($OptionsDummy)

	for $i=1 to ubound ($_aOptionsText) -1
		if $_aOptionsText[$i][2] <> "" then
			$_aOptionsText[$i][1] = GUICtrlCreateMenuItem($_aOptionsText[$i][3], $_hOptionsContext)
		endif
	next

EndFunc   ;==>Example2

Func setOptionsText($sOptionsType)

	redim $_aOptionsText[1][5]
	redim $_aOptionsText[31][5]
	local $aRecentList
	local $iMaxOption
	local $bHotListType = False

	$_sOptionsType = $sOptionsType
	if $_sOptionsType = "RECENT" then
		$aRecentList = _getRecentFileList()
	Elseif $_sOptionsType = "INCLUDE" then
		$aRecentList =  $_aPreAllScriptFile
	Elseif $_sOptionsType = "HOTLIST" then
		$aRecentList =  _getUserHotList()
		$bHotListType = True
	endif

	$iMaxOption = ubound ($aRecentList) -1
	if $iMaxOption > ubound($_aOptionsText) -1 then $iMaxOption = ubound($_aOptionsText) -1

	for $i=1 to $iMaxOption

		if $bHotListType then
			if $aRecentList[$i][1] <> "" then
				$_aOptionsText[$i][2] = $aRecentList[$i][1]
				$_aOptionsText[$i][4] = $aRecentList[$i][2]
				$_aOptionsText[$i][3] = "[" & $aRecentList[$i][2]  & "] " & _GetFileName($aRecentList[$i][1])  & " - " & $aRecentList[$i][1]
			endif
		else
			if $aRecentList[$i] <> "" then
				$_aOptionsText[$i][2] = $aRecentList[$i]
				$_aOptionsText[$i][3] = _GetFileName($aRecentList[$i]) & " - " & $aRecentList[$i]
			endif
		endif

	next

endfunc


; Show a menu in a given GUI window which belongs to a given GUI ctrl
Func ShowMenu()

	Local $arPos, $x, $y
	Local $hMenu = GUICtrlGetHandle($_hOptionsContext)

	AutoItSetOption ( "MouseCoordMode" ,2 )
	$arPos= MouseGetPos()
	AutoItSetOption ( "MouseCoordMode" ,1 )

	$x = $arPos[0]
	$y = $arPos[1]

	ClientToScreen($_gForm, $x, $y)
	TrackPopupMenu($_gForm, $hMenu, $x, $y)

EndFunc   ;==>ShowMenu

; Convert the client (GUI) coordinates to screen (desktop) coordinates
Func ClientToScreen($hWnd, ByRef $x, ByRef $y)
	Local $stPoint = DllStructCreate("int;int")

	DllStructSetData($stPoint, 1, $x)
	DllStructSetData($stPoint, 2, $y)

	DllCall("user32.dll", "int", "ClientToScreen", "hwnd", $hWnd, "ptr", DllStructGetPtr($stPoint))

	$x = DllStructGetData($stPoint, 1)
	$y = DllStructGetData($stPoint, 2)
	; release Struct not really needed as it is a local
	$stPoint = 0
EndFunc   ;==>ClientToScreen

; Show at the given coordinates (x, y) the popup menu (hMenu) which belongs to a given GUI window (hWnd)
Func TrackPopupMenu($hWnd, $hMenu, $x, $y)
	DllCall("user32.dll", "int", "TrackPopupMenuEx", "hwnd", $hMenu, "int", 0, "int", $x, "int", $y, "hwnd", $hWnd, "ptr", 0)
EndFunc   ;==>TrackPopupMenu


func _setRecentFileList($sFile)
; 최근 사용 파일을 목록을 보여줌

	local $sList
	local $aList
	local $aNewList [21]
	local $iNewListCount

	$aList = _getRecentFileList()

	$aNewList [1] = $sFile
	$iNewListCount = 1

	for $i=1 to ubound($aList) -1
		if $aList[$i] <> $sFile then
			$iNewListCount += 1
			$aNewList [$iNewListCount] = $aList[$i]
		endif
		if $iNewListCount >= 20 then ExitLoop
	next

	;_ArrayDisplay($aNewList)

	redim $aNewList[$iNewListCount+1]

	$sList = _ArrayToString($aNewList,"|",1)

	;xdebug($sList)


	_writeSettingReg("RecentFile",$sList)
	;RegWrite("HKEY_LOCAL_MACHINE\Software\" & $_sProgramName  , "RecentFile", "REG_SZ",$sList)

endfunc


func _getUserHotList()

	local $ahotlist[31][3]
	local $i
	local $aList
	local $ihotlistCount = 0

	for $i=1 to 30
		$aList = stringsplit(replacePathAlias(getReadINI("User_HotList", "List" & $i)) & ";",";")
		if $aList [1] <> "" then
			$ihotlistCount += 1
			if StringLower($aList [2]) <> "전체실행" and StringLower($aList [2]) <> "부분실행" then
				$aList [2] ="불러오기"
			endif
			$ahotlist[$ihotlistCount][1] = $aList [1]
			$ahotlist[$ihotlistCount][2] = $aList [2]
		endif
	next

	redim $ahotlist[$ihotlistCount+1][3]

	return $ahotlist

endfunc



func _getRecentFileList()

	return StringSplit(_readSettingReg("RecentFile"), "|")
	;return StringSplit(RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\" & $_sProgramName , "RecentFile"), "|")

endfunc
