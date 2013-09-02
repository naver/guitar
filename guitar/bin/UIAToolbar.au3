#include-once

#include ".\_include_nhn\_util.au3"

#include <WinAPI.au3>

#include <Constants.au3>
#include <GuiConstantsEx.au3>
#include <GuiToolbar.au3>
#include <GuiImageList.au3>
#include <GuiToolTip.au3>

#include <WindowsConstants.au3>
#include <EditConstants.au3>
#include <GuiTab.au3>

global Enum $_tbNew = 1000, $_tbOpen, $_tbHotList, $_tbOpenR, $_tbOpenI, $_tbNewSave, $_tbSave,$_tbTemplate, $_tbRefresh, $_tbStart, $_tbStop, $_tbRetry, $_tbCapture, $_tbImageMng, $_tbHelp, $_tbReport, $_tbEnd
global $_hToolbar


func _loadToolBar(byref $hGUI)

local $hImage
local $hToolTip
local $aToolbarTip[2000]
local $iToolbarwidth


$_hToolbar = _GUICtrlToolbar_Create($hGUI, BitOR($BTNS_BUTTON,$BTNS_SHOWTEXT),$TBSTYLE_EX_DRAWDDARROWS)

;GUICtrlSetResizing($_hToolbar, $GUI_DOCKLEFT + $GUI_DOCKTOP  + $GUI_DOCKRIGHT)
$hImage = _GUIImageList_Create(16, 16, 5, 3)
$hToolTip = _GUIToolTip_Create($_hToolbar, $TTS_ALWAYSTIP)
_GUICtrlToolbar_SetToolTips($_hToolbar, $hToolTip)

_GUICtrlToolbar_SetImageList($_hToolbar, $hImage)
_GUICtrlToolbar_AddBitmap ($_hToolbar, 1, -1, $IDB_STD_SMALL_COLOR)

_GUIImageList_Addicon($hImage, "icon.dll",0)
_GUIImageList_Addicon($hImage, "icon.dll",1)
_GUIImageList_Addicon($hImage, "icon.dll",2)
_GUIImageList_Addicon($hImage, "icon.dll",3)
_GUIImageList_Addicon($hImage, "icon.dll",4)
_GUIImageList_Addicon($hImage, "icon.dll",5)
_GUIImageList_Addicon($hImage, "icon.dll",6)
_GUIImageList_Addicon($hImage, "icon.dll",7)
_GUIImageList_Addicon($hImage, "icon.dll",9)
_GUIImageList_Addicon($hImage, "icon.dll",10)
_GUIImageList_Addicon($hImage, "icon.dll",11)
_GUIImageList_Addicon($hImage, "icon.dll",12)
_GUIImageList_Addicon($hImage, "icon.dll",13)
_GUIImageList_Addicon($hImage, "icon.dll",14)
_GUIImageList_Addicon($hImage, "icon.dll",15)
_GUIImageList_Addicon($hImage, "icon.dll",16)


;~ _GUIImageList_Addicon($hImage, "open2.ico") ; 16
;~ _GUIImageList_Addicon($hImage, "refresh.ico")
;~ _GUIImageList_Addicon($hImage, "start.ico")
;~ _GUIImageList_Addicon($hImage, "continue.ico")
;~ _GUIImageList_Addicon($hImage, "stop.ico")
;~ _GUIImageList_Addicon($hImage, "Capture.ico")
;~ _GUIImageList_Addicon($hImage, "recent.ico")


$aToolbarTip[$_tbNew] = _GUICtrlToolbar_AddString($_hToolbar, "신규")
_GUICtrlToolbar_AddButton($_hToolbar, $_tbNew, $STD_FILENEW, $aToolbarTip[$_tbNew])

$aToolbarTip[$_tbOpen] = _GUICtrlToolbar_AddString($_hToolbar, "열기" )
_GUICtrlToolbar_AddButton($_hToolbar, $_tbOpen, $STD_FILEOPEN , $aToolbarTip[$_tbOpen])

$aToolbarTip[$_tbHotList] = _GUICtrlToolbar_AddString($_hToolbar, "빨리열기")
_GUICtrlToolbar_AddButton($_hToolbar, $_tbHotList, 30 , $aToolbarTip[$_tbHotList])

$aToolbarTip[$_tbOpenR] = _GUICtrlToolbar_AddString($_hToolbar, "최근열기")
_GUICtrlToolbar_AddButton($_hToolbar, $_tbOpenR, 15 , $aToolbarTip[$_tbOpenR])

$aToolbarTip[$_tbOpenI] = _GUICtrlToolbar_AddString($_hToolbar, "참조열기")
_GUICtrlToolbar_AddButton($_hToolbar, $_tbOpenI, 16 , $aToolbarTip[$_tbOpenI])

;$aToolbarTip[$_tbNewSave] = _GUICtrlToolbar_AddString($_hToolbar, "새이름" & @cr & "저장(A)")
;_GUICtrlToolbar_AddButton($_hToolbar, $_tbNewSave, $STD_FILESAVE  , $aToolbarTip[$_tbNewSave])

$aToolbarTip[$_tbSave] = _GUICtrlToolbar_AddString($_hToolbar, "저장")
_GUICtrlToolbar_AddButton($_hToolbar, $_tbSave, $STD_FILESAVE  , $aToolbarTip[$_tbSave])



;_GUICtrlToolbar_AddButtonSep ($_hToolbar)

;$aToolbarTip[$_tbRefresh] = _GUICtrlToolbar_AddString($_hToolbar, "검사(U)")
;_GUICtrlToolbar_AddButton($_hToolbar, $_tbRefresh, 17 , $aToolbarTip[$_tbRefresh])

_GUICtrlToolbar_AddButtonSep ($_hToolbar)

$aToolbarTip[$_tbStart] = _GUICtrlToolbar_AddString($_hToolbar, "전체실행")
_GUICtrlToolbar_AddButton($_hToolbar, $_tbStart, 18 , $aToolbarTip[$_tbStart])

$aToolbarTip[$_tbRetry] = _GUICtrlToolbar_AddString($_hToolbar, "부분실행")
_GUICtrlToolbar_AddButton($_hToolbar, $_tbRetry, 19 , $aToolbarTip[$_tbRetry])

$aToolbarTip[$_tbStop] = _GUICtrlToolbar_AddString($_hToolbar, "중지" )
_GUICtrlToolbar_AddButton($_hToolbar, $_tbStop, 22 , $aToolbarTip[$_tbStop])

_GUICtrlToolbar_AddButtonSep ($_hToolbar)

$aToolbarTip[$_tbCapture] = _GUICtrlToolbar_AddString($_hToolbar, "캡쳐" )
_GUICtrlToolbar_AddButton($_hToolbar, $_tbCapture, 20 , $aToolbarTip[$_tbCapture])

$aToolbarTip[$_tbImageMng] = _GUICtrlToolbar_AddString($_hToolbar, "IMG관리")
_GUICtrlToolbar_AddButton($_hToolbar, $_tbImageMng, 21 , $aToolbarTip[$_tbImageMng])

_GUICtrlToolbar_AddButtonSep ($_hToolbar)


$aToolbarTip[$_tbTemplate] = _GUICtrlToolbar_AddString($_hToolbar, "템플릿" )
_GUICtrlToolbar_AddButton($_hToolbar, $_tbTemplate, 29  , $aToolbarTip[$_tbTemplate])

$aToolbarTip[$_tbReport] = _GUICtrlToolbar_AddString($_hToolbar, "리포트")
_GUICtrlToolbar_AddButton($_hToolbar, $_tbReport, 27, $aToolbarTip[$_tbReport])

$aToolbarTip[$_tbHelp] = _GUICtrlToolbar_AddString($_hToolbar, "도움말" )
_GUICtrlToolbar_AddButton($_hToolbar, $_tbHelp, 28,$aToolbarTip[$_tbHelp])

;$aToolbarTip[$_tbEnd] = _GUICtrlToolbar_AddString($_hToolbar, "종료")
;_GUICtrlToolbar_AddButton($_hToolbar, $_tbEnd, 23, $aToolbarTip[$_tbEnd])


$iToolbarwidth = 62


_GUICtrlToolbar_SetButtonWidth($_hToolbar,$iToolbarwidth, $iToolbarwidth)

;_GUICtrlToolbar_SetButtonWidth($_hToolbar,$iToolbarwidth, $iToolbarwidth)
;_GUICtrlToolbar_SetButtonWidth($_hToolbar,82, 82)
_GUICtrlToolbar_SetMaxTextRows($_hToolbar, 2)


 _GUICtrlToolbar_SetStyleFlat($_hToolbar, True)

;Register WM_NOTIFY  events
;GUIRegisterMsg($WM_NOTIFY, "WM_Notify")

GUIRegisterMsg($WM_NOTIFY, "_WM_NOTIFY")
GUIRegisterMsg($WM_COMMAND, "_WM_COMMAND")

GUISetState()

endfunc


; Write message to memo
Func MemoWrite($sMessage = "")
	ConsoleWrite( $sMessage & @CRLF)
EndFunc   ;==>MemoWrite

func getToolbarStatus($bID)

	local $aButton

	$aButton = _GUICtrlToolbar_GetButtonInfo ($_hToolbar, $bID)

	if bitand($aButton[1], $TBSTATE_ENABLED) = $TBSTATE_ENABLED then
		;debug("좋아")
		return True
	else
		;debug("안됨")
		return False
	endif
EndFunc


Func _SetMenuTexts($hWnd, $hMenu)
	Local $fState


		;_GUICtrlMenu_SetItemEnabled($hWnd, $_gForm_mnu_delete, False, False)

EndFunc   ;==>_SetMenuTexts


func setMenuMoveList()

	local $i
	local $iMenuStartID = 0x2000
	local $aFolderList = _getRecentImageFolder()
	local $iMaxListCount = ubound($aFolderList) -1

	$_gForm_mnu_move = _GUICtrlMenu_CreateMenu()

	redim $_gForm_mnu_move_list[$iMaxListCount+2]

	for $i=1 to $iMaxListCount
		$_gForm_mnu_move_list[$i] = $iMenuStartID  + $i
		_GUICtrlMenu_InsertMenuItem($_gForm_mnu_move, $i-1, $aFolderList[$i], $_gForm_mnu_move_list[$i])
	next

	$_gForm_mnu_move_list[$iMaxListCount + 1] = $iMenuStartID + $iMaxListCount + 1

	_GUICtrlMenu_InsertMenuItem($_gForm_mnu_move, $iMaxListCount , "직접 지정", $_gForm_mnu_move_list[$iMaxListCount + 1])

	;redim $_gForm_mnu_move_list[$iMaxListCount+2]

	;msg($_gForm_mnu_move_list)

	return $iMenuStartID

endfunc



Func _WM_COMMAND($hWnd, $iMsg, $iwParam, $ilParam)

	local $iparam = _WinAPI_LoWord ($iwParam)
	local $i, $iIndex = 0
	local $sMovePath
	local $sNewPath

	if $iparam >= $_gForm_mnu_move_list[1] and $iparam <= $_gForm_mnu_move_list[1] + ubound($_gForm_mnu_move_list)-1  Then

		;debug($iparam , $_gForm_mnu_move_list[1], $_gForm_mnu_move_list[1] + ubound($_gForm_mnu_move_list)-1 )

		for $i=1 to ubound($_gForm_mnu_move_list) -1
			if $iparam = $_gForm_mnu_move_list[$i] then
				$iIndex = $i
				exitloop
			endif
		next

		if $iIndex <> 0 then
			$sMovePath = _GUICtrlMenu_GetItemText($_gForm_mnu_move, $i-1)

			if $sMovePath = "직접 지정" then

				$sMovePath = FileSelectFolder("Choose a folder.", "",1, _GetPathName($_runScriptFileName))

			endif

			if $sMovePath  <> "" then
				_writeRecentImageFolder ($sMovePath)
				_mnu_target_move($sMovePath)
			endif

		endif

	endif

EndFunc   ;==>WM_COMMAND


Func _WM_NOTIFY($hWndGUI, $MsgID, $wParam, $lParam)

	#forceref $hWndGUI, $MsgID, $wParam
	Local $tNMHDR, $event, $hwndFrom, $code, $i_idNew, $dwFlags, $lResult, $idFrom, $i_idOld, $hWndTab
	Local $tNMTOOLBAR, $tNMTBHOTITEM
	local $hwndFrom
	Local $tMsgFilter, $hMenu
	local $aMousePos
	local $iStartPos, $iEndPos
	local $sMSG
	local $hWndListView

	$tNMHDR = DllStructCreate($tagNMHDR, $lParam)
	$hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
	$code = DllStructGetData($tNMHDR, "Code")

	$hWndListView = GUICtrlGetHandle($_gListViewImage)

	Switch $hwndFrom

		Case $_gEditScript

			Switch $Code
				Case  $EN_MSGFILTER
					$tMsgFilter = DllStructCreate($tagMSGFILTER, $lParam)
					If DllStructGetData($tMsgFilter, "msg") = $WM_RBUTTONUP Then
						$hMenu = GUICtrlGetHandle($_gForm_mnu)


							RealTimeTargetCheck(True, $iStartPos, $iEndPos)
							if _trim($_sRealTimeTargetLast[1]) <> "" then
								_GUICtrlMenu_SetItemText($hMenu, $_gForm_mnu_delete, '"' & $_sRealTimeTargetLast[1] & '"'  & " 삭제", False)
								_GUICtrlMenu_SetItemText($hMenu, $_gForm_mnu_rename, '"' & $_sRealTimeTargetLast[1] & '"'  & " 이름 변경", False)

								if _GUICtrlMenu_IsMenu($_gForm_mnu_move) <> 0 then
									_GUICtrlMenu_DestroyMenu($_gForm_mnu_move)
									_GUICtrlMenu_RemoveMenu($hMenu, 2)
								endif

								setMenuMoveList()

								_GUICtrlMenu_InsertMenuItem($hMenu, 2, '"' & $_sRealTimeTargetLast[1] & '"'  & " 이동" , setMenuMoveList() , $_gForm_mnu_move)

								_GUICtrlMenu_TrackPopupMenu($hMenu, $hWndGUI)
							endif
					EndIf
			EndSwitch




		Case $_hToolbar

			if $_runToolbarStatus <> "DISABLE" then

				Switch $code

					Case $NM_LDOWN

						$idFrom = DllStructGetData($tNMHDR, "IDFrom")

						;debug(_GUICtrlToolbar_IndexToCommand($_hToolbar,_GUICtrlToolbar_GetHotItem($_hToolbar)))
						$sMSG = _GUICtrlToolbar_IndexToCommand($_hToolbar,_GUICtrlToolbar_GetHotItem($_hToolbar))
						switch  $sMSG

							case $_tbNew
								onClickNew()

							case $_tbOpen
								onClickLoad()

							case $_tbHotList
								viewHotlist()

							case $_tbOpenR
								viewRecentFilelist()

							case $_tbOpenI
								if $_bLastIncludeCheck = False then onClickRefresh()
								viewIncludeFilelist()

							case $_tbSave
								onClickSave()

							case $_tbNewSave
								onClickSave(False, True)


							case $_tbTemplate
								onClickSampleLoad()

							case $_tbRefresh
								;onClickRefresh()

							Case $_tbStart
								onClickRun()

							case $_tbStop
								;debug("중지 누름")
								onClickStop()

							case $_tbRetry
								onClickRetry()

							case $_tbCapture
								onClickCapture()

							case $_tbImageMng
								onClickImageMng()

							case $_tbReport
								onClickOpenReport()

							case $_tbHelp
								viewHelp()

							case $_tbEnd
								_exit()



						EndSwitch


				EndSwitch

			endif

		Case $_ETabMainHwnd

			Switch $code

				Case $TCN_SELCHANGE

					_GTSelectTab (_GUICtrlTab_GetCurSel($_ETabMainHwnd))

			EndSwitch



        Case $hWndListView

            Switch $code

                Case $NM_CLICK
					;ToolTip(_GUICtrlListView_GetItemText($hWndListView, _GUICtrlListView_GetNextItem($hWndListView) & '"',1))
					;GUICtrlSetTip($hWndListView, _GUICtrlListView_GetItemText($hWndListView, _GUICtrlListView_GetNextItem($hWndListView) & '"',1))
                Case $NM_DBLCLK
					;Run("paint " _GUICtrlListView_GetItemText($hWndListView, _GUICtrlListView_GetNextItem($hWndListView)) & """")
					ToolTip("")
					ShellExecute ("mspaint.exe",'"' & _GUICtrlListView_GetItemText($hWndListView, _GUICtrlListView_GetNextItem($hWndListView) & '"',1))

					;ConsoleWrite(_GUICtrlListView_GetItemText($hWndListView, ($DoubleClick)))
                Case $LVN_KEYDOWN
                    ;$tInfo = DllStructCreate('hwnd hWndFrom;int_ptr IDFrom;int Code;int_ptr VKey;int Flags', $ilParam)
                    ;Switch BitAnd(DllStructGetData($tInfo, "VKey"), 0xFFFF)
                    ;    Case $VK_UP
                    ;    Case $VK_DOWN
                    ;EndSwitch

                Case $LVN_HOTTRACK

					local $listviewpos = ControlGetPos("","",$_gListViewImage)
					local $mousepos = GUIGetCursorInfo()

					;debug($listviewpos[1], $listviewpos2[1])

					if IsArray($listviewpos) = 1  and IsArray($mousepos) = 1 then

						if $listviewpos[1] + 20 > $mousepos[1]  or  $listviewpos[3] + $listviewpos[1] - 20  < $mousepos[1]  then
							ToolTip("")
						else

							Local $tInfo = DllStructCreate($tagNMLISTVIEW, $lParam)
							Local $iItem = DllStructGetData($tInfo, "Item"), $iSubItem = DllStructGetData($tInfo, "SubItem")
							If Not ($iItem = -1) Then
								ToolTip(_GUICtrlListView_GetItemText($hWndListView, $iItem ,1))
							Else
								ToolTip("")
							EndIf

						endif
					endif

            EndSwitch



	EndSwitch

	Return $GUI_RUNDEFMSG

EndFunc   ;==>_WM_NOTIFY

func onClickOpenReport()

	local $sDashBoardReport

	$sDashBoardReport = getReadINI("REPORT", "DashboardHost")

	if getIniBoolean(getReadINI("Report","OpenDashboardReport")) and $sDashBoardReport <> "" then
		; 대시보드 URL로 오픈
		$sDashBoardReport = $sDashBoardReport
	Else
		$sDashBoardReport = $_runReportPath
	endif

	$sDashBoardReport = $sDashBoardReport & "\report.htm"

	ShellExecute($sDashBoardReport )

endfunc


func onClickOpenRemoteManager()

	local $sDashBoardReport

	$sDashBoardReport = getReadINI("REPORT", "DashboardHost")

	if getIniBoolean(getReadINI("Report","OpenDashboardReport")) and $sDashBoardReport <> "" then
		; 대시보드 URL로 오픈
		$sDashBoardReport = $sDashBoardReport

		$sDashBoardReport = $sDashBoardReport & "\remote.jsp"

		ShellExecute($sDashBoardReport )
	else
		_ProgramError("GUITAR.INI 파일에 원격관리에 필요한 설정들이 되어 있지 않습니다." & @crlf & "원격관리를 사용하기 위해서는 Tomcat이 설치되어 하며, INI 설정([REPORT] 부분)도 변경이 필요 합니다." & @crlf & "보다 자세한 설정 방법은 매뉴얼을 참고하시기 바랍니다." )

	endif

endfunc


func viewRecentFilelist()

	;if WinActive($_hToolbar) = 0 then return

	setOptionsText("RECENT")
	createOptions ()
	ShowMenu()

endfunc


func viewHotlist()

	;if WinActive($_hToolbar) = 0 then return

	setOptionsText("HOTLIST")
	createOptions ()
	ShowMenu()

endfunc


func viewIncludeFilelist()

	;if WinActive($_hToolbar) = 0 then return

	setOptionsText("INCLUDE")
	createOptions ()
	ShowMenu()

endfunc

func setToolbar($sType)

	local $bButtonA
	local $bButtonB

	Switch $sType
		case "DEFAULT"
			$bButtonA = True
			$bButtonB = False
			AllMenuDisable(False)

		case "TEST"
			$bButtonA = False
			$bButtonB = True
			AllMenuDisable(True)

		case "CAPTURE"
			$bButtonA = False
			$bButtonB = False
			AllMenuDisable(True)

		Case "DISABLE"
			$bButtonA = False
			$bButtonB = False

			AllMenuDisable(True)

	EndSwitch

	$_runToolbarStatus = $sType

	_GUICtrlToolbar_EnableButton ($_hToolbar, $_tbNew, $bButtonA)
	_GUICtrlToolbar_EnableButton ($_hToolbar, $_tbOpen, $bButtonA)
	_GUICtrlToolbar_EnableButton ($_hToolbar, $_tbHotList, $bButtonA)

	_GUICtrlToolbar_EnableButton ($_hToolbar, $_tbOpenR, $bButtonA)
	_GUICtrlToolbar_EnableButton ($_hToolbar, $_tbOpenI, $bButtonA)
	_GUICtrlToolbar_EnableButton ($_hToolbar, $_tbNewSave, $bButtonA)
	_GUICtrlToolbar_EnableButton ($_hToolbar, $_tbSave, $bButtonA)
	_GUICtrlToolbar_EnableButton ($_hToolbar, $_tbTemplate,$bButtonA)
	_GUICtrlToolbar_EnableButton ($_hToolbar, $_tbStart, $bButtonA)
	_GUICtrlToolbar_EnableButton ($_hToolbar, $_tbStop, $bButtonA)
	_GUICtrlToolbar_EnableButton ($_hToolbar, $_tbRetry, $bButtonA)
	_GUICtrlToolbar_EnableButton ($_hToolbar, $_tbCapture, $bButtonA)
	_GUICtrlToolbar_EnableButton ($_hToolbar, $_tbImageMng, $bButtonA)

	_GUICtrlToolbar_EnableButton ($_hToolbar, $_tbReport, $bButtonA)
	_GUICtrlToolbar_EnableButton ($_hToolbar, $_tbHelp, $bButtonA)
	_GUICtrlToolbar_EnableButton ($_hToolbar, $_tbEnd, $bButtonA)

	_GUICtrlRichEdit_SetReadOnly($_gEditScript, not($bButtonA))

	_GUICtrlToolbar_PressButton ($_hToolbar, $_tbNew, False)
	_GUICtrlToolbar_PressButton ($_hToolbar, $_tbOpen, False)
	_GUICtrlToolbar_PressButton ($_hToolbar, $_tbHotList, False)

	_GUICtrlToolbar_PressButton ($_hToolbar, $_tbOpenR, False)
	_GUICtrlToolbar_PressButton ($_hToolbar, $_tbOpenI, False)
	_GUICtrlToolbar_PressButton ($_hToolbar, $_tbNewSave, False)
	_GUICtrlToolbar_PressButton ($_hToolbar, $_tbSave, False)
	_GUICtrlToolbar_PressButton ($_hToolbar, $_tbTemplate,False)
	_GUICtrlToolbar_PressButton ($_hToolbar, $_tbStart, False)
	_GUICtrlToolbar_PressButton ($_hToolbar, $_tbStop, False)
	_GUICtrlToolbar_PressButton ($_hToolbar, $_tbRetry, False)
	_GUICtrlToolbar_PressButton ($_hToolbar, $_tbCapture, False)
	_GUICtrlToolbar_PressButton ($_hToolbar, $_tbImageMng, False)
	_GUICtrlToolbar_PressButton ($_hToolbar, $_tbReport, False)
	_GUICtrlToolbar_PressButton ($_hToolbar, $_tbHelp, False)
	_GUICtrlToolbar_PressButton ($_hToolbar, $_tbEnd, False)

endfunc

func _mnu_target_move($sMoveDir)

	local $sNewTarget,  $iStartPos,  $iEndPos,  $ImageList
	local $sDeleteMsg = "삭제" , $i
	local $sAnswer
	local $bMoveResult

	get_mnutargetinfo( $sNewTarget,  $iStartPos,  $iEndPos,  $ImageList, $sDeleteMsg)


	if $sNewTarget <> "" then

		for $i=1 to ubound($ImageList) -1
			;debug($ImageList[$i], $sMoveDir & "\" & _GetFileNameAndExt($ImageList[$i]))
			$bMoveResult = FileMove($ImageList[$i], $sMoveDir & "\" & _GetFileNameAndExt($ImageList[$i]))
			if $bMoveResult = 0 then  _ProgramError ("파일을 이동하지 못하였습니다." & @cr & @cr & $ImageList[$i])
		next


		_UpdateFolderFileInfo (True)

		onClickRefresh()

		RealTimeTargetCheck(True, $iStartPos, $iEndPos)

	else
		_ProgramError("선택된 대상이 없습니다. 대상을 지정 한 뒤 사용하시기 바랍니다.")

	endif


endfunc

func _mnu_target_delete()

	local $sNewTarget,  $iStartPos,  $iEndPos,  $ImageList
	local $sDeleteMsg = "삭제" , $i
	local $sAnswer

	get_mnutargetinfo( $sNewTarget,  $iStartPos,  $iEndPos,  $ImageList, $sDeleteMsg)

	if $sNewTarget <> "" then

		if $sDeleteMsg <> "" then
			$sAnswer = _ProgramQuestionYNC ($sDeleteMsg)
		else
			$sAnswer = "Y"
		endif

		if $sAnswer ="C" then return

		if $sAnswer ="Y" then

			for $i=1 to ubound($ImageList) -1
				if FileDelete($ImageList[$i]) = 0 then  _ProgramError ("파일을 삭제하지 못하였습니다." & @cr & @cr & $ImageList[$i])

			next

			_UpdateFolderFileInfo (True)
		endif

		_GuiCtrlRichEdit_SetSel($_gEditScript, $iStartPos, $iEndPos)
		_GuiCtrlRichEdit_ReplaceText($_gEditScript, "")

		RealTimeTargetCheck(True, $iStartPos, $iEndPos)
	else
		_ProgramError("선택된 대상이 없습니다. 대상을 지정 한 뒤 사용하시기 바랍니다.")

	endif


endfunc



func _mnu_target_rename()

	local $sNewTarget,  $iStartPos,  $iEndPos,  $ImageList
	local $sReplaceText ="이름변경"
	local $sNewFileName, $sNewFullName, $sOldFileName, $sNewName
	local $sAnswer
	local $iformLeft, $iformTop
	local $aWinPos = WinGetPos($_gForm)
	local $iFormHeight = 140
	local $iFormWidth = 300

	get_mnutargetinfo( $sNewTarget,  $iStartPos,  $iEndPos,  $ImageList, $sReplaceText)

	if $sNewTarget <> "" then

		if $sReplaceText <> "" then
			$sAnswer = _ProgramQuestionYNC ($sReplaceText)
		else
			$sAnswer = "Y"
		endif

		if $sAnswer ="C" then return

		if $sAnswer ="Y" then

			$iformLeft = $aWinPos[0] + ($aWinPos[2]/2) - ($iFormWidth/2)
			$iformTop = $aWinPos[1] + ($aWinPos[3]/2) - ($iFormHeight/2)

			$sNewName = _trim(InputBox("이름 변경", "변경할 이름:",$sNewTarget,Default,$iFormWidth,$iFormHeight,$iformLeft,$iformTop,Default,$_gForm))

			if $sNewName = "" then return

			for $i=1 to ubound($ImageList) -1


				$sOldFileName = _GetFileName($ImageList[$i])
				;debug($sOldFileName)
				$sOldFileName = stringtrimleft( $sOldFileName, stringlen($sNewTarget))
				;debug($sOldFileName, stringlen($sNewTarget) )
				$sNewFileName = $sNewName & $sOldFileName

				$sNewFullName = _GetPathName($ImageList[$i]) & "\" & $sNewFileName  & _GetFileExt($ImageList[$i])
				;debug($ImageList[$i])
				;debug($sNewFullName)

				if FileMove($ImageList[$i], $sNewFullName) = 0 then  _ProgramError ("파일이름을 변경하지 못하였습니다." & @cr & @cr & $sNewFullName & @cr & "->" & @cr & $ImageList[$i])

			next

		endif

		_GuiCtrlRichEdit_SetSel($_gEditScript, $iStartPos, $iEndPos)
		_GuiCtrlRichEdit_ReplaceText($_gEditScript, $sNewName)

		_UpdateFolderFileInfo(True)

		RealTimeTargetCheck(True, $iStartPos, $iEndPos)
	else
		_ProgramError("선택된 대상이 없습니다. 대상을 지정 한 뒤 사용하시기 바랍니다.")

	endif

endfunc



func get_mnutargetinfo(byref $sNewTarget, byref $iStartPos, byref $iEndPos, byref $ImageList, byref $sMsg)

	RealTimeTargetCheck(True, $iStartPos, $iEndPos)

	$sNewTarget = _trim($_sRealTimeTargetLast[1])

	$ImageList = $_runLastImageArray

	if ubound($ImageList) > 1 then

		$sMsg = '"' & $sNewTarget & '"' & "의 이미지 파일도 같이 " & $sMsg & "하시겠습니까?" & @cr & @cr

		for $i=1 to ubound($ImageList) -1
			$sMsg = $sMsg & $ImageList[$i] & @cr
		next
	else

		$sMsg = ""

	endif

endfunc
