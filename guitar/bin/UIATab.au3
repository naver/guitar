#include ".\_include_nhn\_util.au3"

#include <GuiTab.au3>
#include <GUIConstantsEx.au3>
#include <ProgressConstants.au3>
#include <StaticConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <GuiRichEdit.au3>
#include <ClipBoard.au3>

#include <GuiMenu.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>

global $_TabContextMain
global $_TabContextClose
global $_TabLastIndex


Opt('MustDeclareVars', 1)

func _GTCreateTab()

	local $aObjectPos = getRichLineXY("Tab")

	; 탭 메인 생성

	$_ETabMain = GUICtrlCreateTab($aObjectPos[0], $aObjectPos[1], $aObjectPos[2], $aObjectPos[3])
	;GUICtrlSetResizing(-1, $GUI_DOCKRIGHT)
	$_ETabMainHwnd = GUICtrlGetHandle($_ETabMain)

	$_TabContextMain = GUICtrlCreateContextMenu($_ETabMain)
	$_TabContextClose = GUICtrlCreateMenuItem("닫기(&C)", $_TabContextMain)

endfunc


func _GTTabEnable($bSwitch)

	local $iValue

	if $bSwitch then
		$iValue = $GUI_ENABLE
	else
		$iValue = $GUI_DISABLE
	endif

	GUICtrlSetState ($_ETabMain, $iValue)

endfunc


func _GTGetTitle ($iIndex)
	return _GUICtrlTab_GetItemText($_ETabMain, $iIndex)
endfunc


func _GTCountTabItem ()
	return _GuICtrlTab_GetItemCount($_ETabMain)
endfunc


func _GTDeleteTabItem($iIndex)

	local $i, $j
	local $iTabCount
	local $iNewFoocusTabIndex

	$iTabCount = _GuICtrlTab_GetItemCount($_ETabMain) -1

	_GUICtrlRichEdit_Destroy($_ETabInfo[$iIndex][$_ETab_RichEditHwnd])
	_GUICtrlRichEdit_Destroy($_ETabInfo[$iIndex][$_ETab_RichLineHwnd])

	for $i=$iIndex to $iTabCount -1
		for $j=1 to ubound($_ETabInfo,2) -1
			;debug("_GTDeleteTabItem : " & $iTabCount, $i, $j)
			$_ETabInfo[$i][$j] = $_ETabInfo[$i+1][$j]
		next
	next

	;debug("tab 데이터 삭제 : " & $iTabCount)
	for $j=1 to ubound($_ETabInfo,2) -1
		$_ETabInfo[$iTabCount][$j] = ""
	next

	_GUICtrlTab_DeleteItem($_ETabMain, $iIndex)

	sleep(1)

	;_msg("xxx")

	$iNewFoocusTabIndex = $iIndex

	if $iTabCount = $iIndex then $iNewFoocusTabIndex -= 1

	_GTSelectTab($iNewFoocusTabIndex)

endfunc


func _GTGetFileNameIndex($sFileName, $iExcludeIndex = -1)

	local $i, $iIndex = -1
	local $iTabCount = _GuICtrlTab_GetItemCount($_ETabMain) -1

	; $iExcludeIndex 특정 ID를 제외하고 찾을 때
	for $i=0 to $iTabCount
		;debug($_ETabInfo[$i][$_ETab_Filename] , $sFileName, $i)
		if $_ETabInfo[$i][$_ETab_Filename] = $sFileName and ($i <> $iExcludeIndex) then
			$iIndex = $i
			exitloop
		endif

	next

	return $iIndex

endfunc


func _GTGetCurrentIndex()
	return _GUICtrlTab_GetCurSel($_ETabMain)
endfunc


func _GTLoadFile($iIndex, $sFile)

	;debug("_GTLoadFile : ", $iIndex, $sFile)

	$_ETabInfo[$iIndex][$_ETab_Filename] = $sFile
	$_ETabInfo[$iIndex][$_ETab_Title] = _trim(_GetFileNameAndExt ($sFile))

	;debug("타이틀 : " & $_ETabInfo[$iIndex][$_ETab_Title])

	_GTChangeTitle($iIndex, $_ETabInfo[$iIndex][$_ETab_Title])

endfunc


func _GTChangeTitle($iIndex, $sText)

	_GUICtrlTab_SetItemText($_ETabMain, $iIndex, $sText)


endfunc


func _GTRichEditModifiedCheck()

	local $iCurrentIndex = _GTGetCurrentIndex()
	local $sTitle =  _GUICtrlTab_GetItemText($_ETabMain, $iCurrentIndex)

	if stringinstr($sTitle,"*") = 0 then
		if _checkRichTextModified() = True then _GTChangeTitle($iCurrentIndex, $sTitle & " * ")
	endif

endfunc


func _GTCheckSaveFile($iIndex)

	local $bRet = True

	if stringinstr(_GUICtrlTab_GetItemText($_ETabMain, $iIndex),"*") <> 0 then $bRet = False

	return $bRet

endfunc


func _GTAddTabItem($sTitle)

	; 하단 편집기 창
	local $iAddTabIndex = _GuICtrlTab_GetItemCount($_ETabMain)
	local $aRichNumberPos
	local $aObjectPos
	; 탭 메인 생성
	;debug($aObjectPos)

	; 최대를 초과함
	if $iAddTabIndex = ubound($_ETabInfo) then
		$iAddTabIndex = -1
		_ProgramError("최대 탭 허용개수를 초과 하였습니다." & @crlf & "기존 탭을 닫고 사용하시기 바랍니다.")
		return $iAddTabIndex
	endif




	; 신규 탭 항목 생성
	$_ETabInfo[$iAddTabIndex][$_ETab_Hwnd] = GUICtrlCreateTabItem ( $sTitle)

	$aObjectPos = getRichLineXY("Line")
	$_ETabInfo[$iAddTabIndex][$_ETab_RichLineHwnd]  = _GUICtrlRichEdit_Create ($_gForm,"", $aObjectPos[0], $aObjectPos[1], $aObjectPos[2], $aObjectPos[3])


	$aObjectPos = getRichLineXY("Edit")
	$_ETabInfo[$iAddTabIndex][$_ETab_RichEditHwnd]  = _GUICtrlRichEdit_Create ($_gForm, "", $aObjectPos[0], $aObjectPos[1], $aObjectPos[2], $aObjectPos[3], BitOR($ES_MULTILINE, $WS_VSCROLL,  $WS_HSCROLL ))



	;GUICtrlCreateButton($sTitle, 10 + ($iAddTabIndex*15), 280, 50, 20)

	GUICtrlCreateTabItem("")

	GUISetState()

	;debug("추가 Index : " & $iAddTabIndex)

	_GTSelectTab($iAddTabIndex)


	$aRichNumberPos = _GUICtrlRichEdit_GetRECT($_gLinelist)


	local $sRichFontCode = 0

	_GuiCtrlRichEdit_SetRECT($_gLinelist, $aRichNumberPos[0], $aRichNumberPos[1]+1, $aRichNumberPos[2]-10, $aRichNumberPos[3])
	_GUICtrlRichEdit_SetReadOnly($_gLinelist,True)
	_GUICtrlRichEdit_SetParaAlignment($_gLinelist, "r")
	_GUICtrlRichEdit_SetBkColor ( $_gLinelist, "0xCCCCCC" )

	_GuiCtrlRichEdit_SetEventMask($_gEditScript, $ENM_MOUSEEVENTS)

	_GUICtrlRichEdit_SetFont($_gLinelist, $_EditFontSize, $_EditFontName)
	_GUICtrlRichEdit_SetFont($_gEditScript, $_EditFontSize, $_EditFontName)

	_GuiCtrlRichEdit_SetTabStops($_gEditScript, 0.25)

	_GuiCtrlRichEdit_HideSelection($_gEditScript, False)

	_GuiCtrlRichEdit_SetLimitOnText($_gEditScript, 32767)
	_GuiCtrlRichEdit_SetLimitOnText($_gTempScript, 32767)
	_GuiCtrlRichEdit_SetLimitOnText($_gHideScript, 32767)

	$_runLastRicheditFirstVisibleLine = -1

	;debug("okdddd")

	_GTSelectTab($iAddTabIndex)

	return $iAddTabIndex

endfunc


func _GTSelectTab($iIndex)

	local $i

	;debug("Tab select old, new : " & $_TabLastIndex, $iIndex)

	_GUICtrlTab_SetCurSel($_ETabMain, $iIndex)

	for $i=0 to _GuICtrlTab_GetItemCount($_ETabMain) -1
		;if $i <> $iIndex then
			;_debug("감추기 :" & $_ETabInfo[$i][$_ETab_RichLineHwnd], $i, $iIndex )

			ControlDisable($_gForm, "" , $_ETabInfo[$i][$_ETab_RichLineHwnd])
			ControlHide($_gForm, "", $_ETabInfo[$i][$_ETab_RichLineHwnd])

			ControlDisable($_gForm, "" , $_ETabInfo[$i][$_ETab_RichEditHwnd])
			ControlHide($_gForm, "", $_ETabInfo[$i][$_ETab_RichEditHwnd])
		;endif

	next

	GUISetState()

	if $iIndex > -1 then

		; 해당 탭의 편집중이 내부 스크립트 편집 정보 변수를 셋팅
		loadScriptEditInfo($iIndex)

		;_debug("보여주기  :" & $_ETabInfo[$iIndex][$_ETab_RichLineHwnd], $iIndex)
		ControlEnable($_gForm, "" , $_ETabInfo[$iIndex][$_ETab_RichLineHwnd])
		ControlShow($_gForm, "" , $_ETabInfo[$iIndex][$_ETab_RichLineHwnd])

		ControlEnable($_gForm, "" , $_ETabInfo[$iIndex][$_ETab_RichEditHwnd])
		ControlShow($_gForm, "" , $_ETabInfo[$iIndex][$_ETab_RichEditHwnd])

		$_gEditScript = $_ETabInfo[$iIndex][$_ETab_RichEditHwnd]
		$_gLinelist = $_ETabInfo[$iIndex][$_ETab_RichLineHwnd]


		sleep(1)

		ControlFocus($_gEditScript, "", "")

	endif

	$_TabLastIndex = $iIndex

endfunc