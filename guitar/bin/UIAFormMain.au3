#include-once

Global enum $_iRichTextText, $_iRichTextStream, $_iRichTextCheckMsg
Global enum $_iResultAll =1 , $_iResultRun, $_iResultPass, $_iResultFail, $_iResultNotRun, $_iResultSkip, $_sResultSkipList, $_sResultNorRunList, $_iResultEnd
Global enum $_iSBLocInfo = 0, $_iSBTestResult, $_iSBTestResultIcon, $_iSBProgress, $_iSBStatusText

Global $_iRichTextEnd = $_iRichTextCheckMsg + 1

Global $_gForm
Global $_oIEScript
Global $_gEditScript
Global $_gHideScript
Global $_gTempScript
Global $_gRun
Global $_gLoad
Global $_gSave
Global $_gStop
Global $_gRefresh
Global $_gLinelist
Global $_gRichLog

Global $_gEmbeddedIEImageViwer
Global $_gObjEmbeddedIEImageViwer

Global $_gStatusBar
Global $_gScreenCapture
;Global $_gScriptFileName
Global $_sRichTextModified
global $_hTestResultImageList
global $_hTestResultIcon[3]


Global $_gProgress
Global $_gTestButton
Global $_aRichEditLastSelect

Global $_aDefaultCaptureFileList [1]
Global $_aPreErrorImageTarget [1]
Global $_aPreAllImageTarget [1]
Global $_aPreAllScriptFile [1]
Global $_aRunReportInfo [$_iResultEnd]


Global $_bScriptRunning
Global $_bScriptStopping
Global $_bScreenCapture

Global $_sLastFileOpenPath
gLOBAL $_bLastIncludeCheck

global $_gForm_hotkey_a0
global $_gForm_hotkey_a1
global $_gForm_hotkey_a2
global $_gForm_hotkey_a3
global $_gForm_hotkey_a4
global $_gForm_hotkey_a5

global $_gForm_mnu
global $_gForm_mnu_delete
global $_gForm_mnu_rename
global $_gForm_mnu_move
global $_gForm_mnu_move_list[21]

global $_sRealTimeTargetLast[4]

global $_hListViewImage
global $_gListViewPic
global $_runLastImageArray
global $_iListViewImageWidth = 340
global $_iListViewImageHeight = 80


#include <ProgressConstants.au3>
#include <StaticConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <GuiRichEdit.au3>
#include <ClipBoard.au3>
#include <GuiMenu.au3>

#include "UIACommon.au3"
#include "UIARun.au3"
#include "UIAAnalysis.au3"
#include "UIACapture.au3"

#include "UIAToolbar.au3"
#include "UIAHtml.au3"
#include "UIAImageList.au3"
#include "UIAFormSample.au3"
#include "GUITARImportTC.au3"

#include  "GUITARIEImageViwer.au3"

func _loadMainForm()
; 메인화면 생성

	local $iFormWidth = 1310
	local $iFormHeight = 830

	local $oIEForm


	local $iLastFormX, $iLastFormY, $iLastFormWidth, $iLastFormHeight
	local $aCurrentMonitorSize
	local $aObjectPos

	local $bMaxmize = False

	local $aStatusBarParts[5] = [70, 70 + 70, 70 + 70 + 24, 70 + 70 + 24 + 200, -1 ]

	HotKeySet("{TAB}", "_RichEditInsertTab")

	$iLastFormX = _readSettingReg ("LastMainX")
	$iLastFormY = _readSettingReg ("LastMainY")
	$iLastFormWidth = _readSettingReg ("LastMainWidth")
	$iLastFormHeight =  _readSettingReg ("LastMainHeight")

	if $iLastFormWidth < 700 then $iLastFormWidth = 920
	if $iLastFormHeight < 700 then $iLastFormHeight = 750

	$bMaxmize =  _iif(_readSettingReg ("LastMainMax")=1,True,False)

	if $iLastFormX < 0 then $iLastFormX = 0
	if $iLastFormY < 0 then $iLastFormY = 0

	;msg($iLastFormX & " " &  $iLastFormY )

	writeDebugLog("메인 윈도우 좌표 계산")
	$aCurrentMonitorSize = GetWorkAareFromPoint($iLastFormX + ($iFormWidth / 2) ,$iLastFormY + ( $iFormHeight / 2))

	$iFormWidth = $iLastFormWidth
	$iFormHeight = $iLastFormHeight

	;msg($aCurrentMonitorSize)
	; 최대 윈도우
	if $iFormWidth = -1 and  $iFormHeight =-1 then $bMaxmize = True

	if IsArray($aCurrentMonitorSize) then
		if $aCurrentMonitorSize[6] <= $iFormHeight or $aCurrentMonitorSize[5] <= $iFormWidth then
			;$iFormHeight = $aCurrentMonitorSize[4] -85

			$iFormWidth = $aCurrentMonitorSize[5] -100
			$iFormHeight = $aCurrentMonitorSize[6] - 100

		endif

	endif

	if $iLastFormX < $aCurrentMonitorSize[1] then $iLastFormX = $aCurrentMonitorSize[1]
	if $iLastFormY < $aCurrentMonitorSize[2] then $iLastFormY = $aCurrentMonitorSize[2]

	$_gForm = GUICreate($_sProgramName & " v" & FileGetVersion(@ScriptDir & "\" & _GetScriptName() & ".exe"), $iFormWidth,  $iFormHeight,$iLastFormX, $iLastFormY, bitor($WS_MAXIMIZEBOX, $WS_MINIMIZEBOX, $WS_SIZEBOX))

	writeDebugLog("메인 윈도우 생성 완료")


	GUISetState (@SW_LOCK,$_gForm)


	WinMove($_gForm,"",$iLastFormX,$iLastFormY,$iFormWidth,  $iFormHeight)

	;if $bMaxmize then WinSetState($_gForm,"",@SW_MAXIMIZE)

	changeFormTitle("")


	$_gForm_mnu = GUICtrlCreateContextMenu(GUICtrlCreateDummy())

	$_gForm_mnu_rename = GUICtrlCreateMenuItem(_getLanguageMsg ("main_quickmenurename"), $_gForm_mnu)
	$_gForm_mnu_delete = GUICtrlCreateMenuItem(_getLanguageMsg ("main_quickmenudelete"), $_gForm_mnu)

	;GUICtrlCreateInput("" , -1 , -1 , 1, 1, BitOR($WS_TABSTOP,$ES_READONLY)  )

	_GTCreateTab()
	;_GTAddTabItem("")

	$_gHideScript=_GUICtrlRichEdit_Create  ($_gForm, "", 10200, 10200, 100,100)
	$_gTempScript=_GUICtrlRichEdit_Create  ($_gForm, "", 10200, 10200, 100,100)

	;_GUICtrlRichEdit_SetFont($_gHideScript, $_EditFontSize, $_EditFontName)
	;_GUICtrlRichEdit_SetFont($_gTempScript, $_EditFontSize, $_EditFontName)

	; 에러로그 창
	$aObjectPos=getRichLineXY("Log")
	$_gRichLog = _GUICtrlRichEdit_Create($_gForm,"" , $aObjectPos[0], $aObjectPos[1], $aObjectPos[2], $aObjectPos[3], BitOR($ES_MULTILINE, $WS_VSCROLL,  $WS_HSCROLL ))
	_GUICtrlRichEdit_HideSelection($_gRichLog, True)
	changeLoglistBGColor(False)


	GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKHEIGHT + $GUI_DOCKRIGHT)
	;_GUICtrlRichEdit_AppendText($_gRichLog, " ")
	;_GuiCtrlRichEdit_SetSel($_gRichLog, 1,1)
	;_GUICtrlRichEdit_SetFont ($_gRichLog, 20, "굴림체")
	;_GUICtrlRichEdit_SetText($_gRichLog, "")
	;_GUICtrlRichEdit_SetFont ($_gRichLog, 20, "굴림체")
	_GUICtrlRichEdit_SetReadOnly($_gRichLog, True )


	; 뷰여용 IE 생성

	; 그룹창
	;$aObjectPos=getRichLineXY("Image")
	;CreateEmbeddedIEImageViwer($_gEmbeddedIEImageViwer, $_gObjEmbeddedIEImageViwer, $aObjectPos[0], $aObjectPos[1], $aObjectPos[2], $aObjectPos[3])
	;GUICtrlSetResizing($_gObjEmbeddedIEImageViwer, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKHEIGHT + $GUI_DOCKRIGHT)

	;
	CreateNewImageViwer()


	; 실시간 로그 창

	$_gStatusBar = _GUICtrlStatusBar_Create ($_gForm)
	viewRichEditLineNumber()

	;WinSetState ($_gForm,"",@SW_HIDE)
	;GUISetState()

	_GUICtrlStatusBar_SetParts ($_gStatusBar, $aStatusBarParts)

	If @OSTYPE = "WIN32_WINDOWS" Then
		$_gProgress = GUICtrlCreateProgress  (0, 0,-1 , -1)
		;GUICtrlSetResizing(-1, $GUI_DOCKRIGHT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		_GUICtrlStatusBar_EmbedControl ($_gStatusBar, $_iSBProgress, GUICtrlGetHandle($_gProgress))
	Else
		$_gProgress = GUICtrlCreateProgress(0, 0, -1, -1) ; marquee works on Win XP and above
		;GUICtrlSetResizing(-1, $GUI_DOCKRIGHT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		_GUICtrlStatusBar_EmbedControl ($_gStatusBar, $_iSBProgress, GUICtrlGetHandle($_gProgress))
		;_SendMessage(GUICtrlGetHandle($_gProgress), $PBM_SETMARQUEE, True, 200)
	EndIf


	setToolbar("DEFAULT")

	;_IENavigate ($_oIEScript, "about:blank")


	; 상태표시줄의 테스트 결과 아이콘 이미지
    $_hTestResultImageList = _GUIImageList_Create(16, 16, 5, 3)
    _GUIImageList_AddIcon($_hTestResultImageList , @ScriptDir &  "\icon.dll", 19)
    _GUIImageList_AddIcon($_hTestResultImageList , @ScriptDir &  "\icon.dll", 20)
	_GUIImageList_AddIcon($_hTestResultImageList , @ScriptDir &  "\icon.dll", 21)

	$_hTestResultIcon[0] = _GUIImageList_GetIcon($_hTestResultImageList, 0)
	$_hTestResultIcon[1] = _GUIImageList_GetIcon($_hTestResultImageList, 1)
	$_hTestResultIcon[2] = _GUIImageList_GetIcon($_hTestResultImageList, 2)


	; 캡쳐 폼 등에서 단축키 (alt+s)등이 작동되지 않아 메인폼을 최소화 한뒤 다시 복귀함
	;WinSetState($_gForm, "", @SW_MINIMIZE)
	;WinSetState($_gForm, "", @SW_RESTORE)


	; 상단 툴바 생성
	writeDebugLog("툴바 생성전")
	_loadToolBar($_gForm)

	CreateMainMenu ()

	$_runLastMainWindowPos [2] = -1



	writeDebugLog("윈도우 위치 조절 전")
	MainFormResize()
	MainStatusResize()
	writeDebugLog("윈도우 위치 조절 완료")


	setTestStatusBox(_getLanguageMsg("status_ready"))

	;GUISetState()

	;WinSetState($_gForm, "", @SW_MINIMIZE)

	if $bMaxmize then
		GUISetState(@SW_MAXIMIZE, $_gForm)
		MainFormResize()
		;GUISetState()
		;sleep (1500)
	endif

	GUISetState (@SW_UNLOCK,$_gForm)


endfunc


func CreateNewImageViwer ()

	local $aObjectPos=getRichLineXY("Image")
	local $bRet


	;if IsHWnd(GUICtrlGetHandle ( $_gListViewPic )) then GUICtrlDelete ( $_gListViewPic )
	;if IsHWnd($_gListViewImage) then _GUICtrlListView_Destroy($_gListViewImage)

	GUICtrlDelete ( $_gListViewPic )
	_GUICtrlListView_Destroy($_gListViewImage)


	$_gListViewImage = GUICtrlCreateListView("",  $aObjectPos[0], $aObjectPos[1], $aObjectPos[2], $aObjectPos[3], -1, BitOr($WS_EX_CLIENTEDGE, $LVS_EX_DOUBLEBUFFER))

	if $_gListViewImage <> 0 then
		$_gListViewPic = GUICtrlCreatePic("", -1, -1, 1, 1)
		GUICtrlSetResizing($_gListViewImage, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKHEIGHT + $GUI_DOCKRIGHT)

		_GUICtrlListView_SetView($_gListViewImage, 1)
		_GUICtrlListView_SetIconSpacing($_gListViewImage, $_iListViewImageWidth + 25, $_iListViewImageHeight)

		_GUICtrlListView_InsertColumn($_gListViewImage, 0, "", 0)
		_GUICtrlListView_InsertColumn($_gListViewImage, 1, "", 0)
		$bRet = True

	else

		$bRet = False
	endif

	return  $bRet

endfunc





func getRichLineXY($sObject)

	local $aRet[4]

	local $aFormPos = WinGetPos($_gForm)
	local $aTempPos

	local $iLine_Width = 50
	local $iImage_Height = 130
	local $iLog_Height = 150


	local const $iSpaceDefault = 10
	local const $iSpaceThin = 5
	local const $top = 55
	local const $bottom = 80
	local const $X = 0
	local const $Y = 1
	local const $W = 2
	local const $H = 3

	Switch $sObject

		case "Tab"

			$aTempPos = getRichLineXY("Image")

			$aRet[$x] = $iSpaceDefault
			$aRet[$w] = $aTempPos[$w] + 2
			$aRet[$y] = $top
			$aRet[$h] = 21

		case "Line"

			$aTempPos = getRichLineXY("Tab")

			$aRet[$x] = $iSpaceDefault
			$aRet[$y] = $aTempPos [$y] + $aTempPos [$h]
			$aRet[$w] = $iLine_Width

			$aTempPos = getRichLineXY("Log")
			$aRet[$h] = $aTempPos [$y] - $aRet[$y] - $iSpaceThin

		case "Edit"

			$aTempPos = getRichLineXY("Line")

			$aRet[$x] = $aTempPos [$x] + $aTempPos [$w]
			$aRet[$h] = $aTempPos [$h]
			$aRet[$y] = $aTempPos [$y]

			$aTempPos = getRichLineXY("Log")
			$aRet[$w] = $aTempPos [$w] - $iLine_Width + 1


		case "Log"

			$aTempPos = getRichLineXY("Image")

			$aRet[$x] = $iSpaceDefault
			$aRet[$w] = $aTempPos[$w]
			$aRet[$h] = $iLog_Height

			$aRet[$y] = $aTempPos[$y] - $iSpaceThin - $aRet[$h]


		case "Image"
			;debug($aFormPos[$w])

			$aRet[$x] = $iSpaceDefault
			$aRet[$w] = $aFormPos[$w] - ($iSpaceDefault * 3) - ($iSpaceDefault/2)
			$aRet[$h] = $iImage_Height
			$aRet[$y] = $aFormPos[$h] - $aRet[$h] - $bottom - $iSpaceDefault

	EndSwitch

	return $aRet

endfunc



func setScriptFileName ($sFile)
; 스크립트명 설정
	$_runScriptName = $sFile

	changeFormTitle($_runScriptName)

endfunc


func getScriptFileName ()
; 스크립트명 리턴
	return $_runScriptName
endfunc


; ------------------------------------------ onClick 모음 --------------------------------------------
func onClickNew()

	local $sTemplateFile

	; 신규 스크립트 작성, 클립보드 내용을 저장했다 복원 (richtext에서 클립보드가 문제 발생)

	_FormFindReplaceClose()

	if WinActive($_gForm) = 0 then return

	;if checkBrforeSave("C", True ) = "C" then return

	if getScriptFileName() <> "" and _GTCountTabItem() > 0  then
		_saveRecentFilePos(getScriptFileName())
	endif

	local $oTempClipBoard = ClipGet()

	if addNewNoNameTab() = -1 then return

	$_sRichTextModified = ""

	; 템플릿 파일이 있을 경우 기본으로 불러옴

	$sTemplateFile = $_runCommonScriptPath & "\" & getReadINI("SCRIPT","TemplateScript")
	if FileExists($sTemplateFile) then
		_GuiCtrlRichEdit_SetText ($_gEditScript, FileRead($sTemplateFile))
		_GUICtrlRichEdit_SetSel ($_gEditScript, -1,-1)
		$_sRichTextModified = _GuiCtrlRichEdit_getText  ($_gEditScript, False)
	endif

	RealTimeTargetCheckReset()

	clearLog ()

	setScriptFileName ("")

	;_GuiCtrlRichEdit_SetText ($_gEditScript, "")

	$_runScriptFileName  = ""
	$_runErrorImageTarget = ""

	redim $_aPreAllScriptFile [1]
	redim $_aRunImagePathList [1]
	redim $_aRunScriptPathList [1]

	; 신규 초기화된 변수를 저장

	;debug ("신규저장 : " & $_runScriptFileName)
	saveScriptEditInfo(_GTGetCurrentIndex())

	ClipPut($oTempClipBoard)

endfunc


func addNewNoNameTab()

	local $bRet

	$bRet = _GTAddTabItem($_sUntitledName)

	if $bRet <> -1 then $_sRichTextModified = ""

	; 저장되지 않은 파일인 경우 "(제목없음)"으로 타이틀 표시

	return $bRet

endfunc


func onImportTC()
	; TestCase 내용 Comment 형식으로 변환

	local $sScript, $sErrorText, $sRet, $iCount

	$sScript = _trim(_GUICtrlRichEdit_GetSelText($_gEditScript))

	if $sScript  = "-1" then
		_ProgramError(_getLanguageMsg ("main_tcconverterror"))
		return
	endif

	$sRet = TestCastInfoToArray($sScript, $sErrorText, $iCount)

	if $sErrorText <> "" then
		_ProgramError($sErrorText)
		return
	endif

	_ProgramInformation($iCount & _getLanguageMsg ("main_tcconvertdone"))

	_GUICtrlRichEdit_ReplaceText($_gEditScript, $sRet)


endfunc


func setupImagePathList($sFileName)

	local $sDefautScriptPath
	local $sDefautImagePath
	local $sScriptPath
	local $sScriptCommonImage
	local $sScriptCommonScript

	redim $_aRunImagePathList[1]
	redim $_aRunScriptPathList[1]

	; INI의 기본 폴더를 0번 폴더로 지정
	$sDefautImagePath = $_runCommonImagePath
	$sDefautScriptPath = $_runCommonScriptPath


	$sScriptPath = $_runScriptPath

	if $sDefautScriptPath = "" then _ProgramError(_getLanguageMsg ("main_commonscripterror") & " : " & $sDefautScriptPath)
	if $sDefautImagePath = "" then _ProgramError(_getLanguageMsg ("main_commonimageerror") & " : " & $sDefautImagePath)


	;debug($sDefautScriptPath)

	$sDefautImagePath = FileGetLongName($sDefautImagePath,1)
	$sDefautScriptPath = FileGetLongName($sDefautScriptPath,1)


	;debug($sScriptPath, $sFileName)
	$sScriptCommonImage = getServiceNameFormFile($sDefautImagePath, $sDefautScriptPath & "\",  $sScriptPath & "\" , $sFileName)
	$sScriptCommonScript = getServiceNameFormFile($sDefautScriptPath, $sDefautScriptPath & "\",  $sScriptPath & "\" , $sFileName)

	;debug("공용스트립트 :" & $sScriptCommonScript )
	;debug("서비스명:" & $sScriptCommonImage)

	;$_aRunImagePathList[0] = $sDefautImagePath & "\common

	$_aRunImagePathList[0] = $sDefautImagePath & "\public\"
	$_aRunScriptPathList[0] = $sDefautScriptPath  & "\public\"

	if $sScriptCommonImage <> "" then _ArrayAdd($_aRunImagePathList,$sScriptCommonImage)
	if $sScriptCommonScript <> "" then _ArrayAdd($_aRunScriptPathList,$sScriptCommonScript)

	;debug($_aRunImagePathList)

	_addImagePathList($sFileName)

endfunc


func getServiceNameFormFile($sDefautImagePath, $sCommoncriptPath, $sScriptPath, $sFile)

	local $sService
	local $iPos, $iPos2
	local $sSeletPath
	local $sServiceName

	$iPos = StringInStr($sFile,$sCommoncriptPath )
	if $ipos <> 0 then
		$sSeletPath = $sCommoncriptPath
	else
		$iPos = StringInStr($sFile,$sScriptPath )
		if $ipos <> 0 then $sSeletPath = $sScriptPath
	endif

	if $iPos = 1 then
		$iPos = stringlen($sSeletPath) + 1
		$iPos2 = StringInStr($sFile,"\", 0, 1, $iPos)

		;debug ($sFile, $iPos ,$iPos2)
		if $iPos2 <> 0 then
			$sServiceName=Stringmid($sFile,$iPos, $iPos2 - $iPos)
			if $sServiceName <> "" then $sService = $sDefautImagePath & "\" & $sServiceName& "\"
		endif

	endif

	return $sService

endfunc


func onClickStop()
	$_bScriptStopping = True
	;debug("정지요청")
endfunc


func onCloseTab()

	local $iTabIndex

	if checkBrforeSave("C", True ) = "C" then return

	$iTabIndex = _GTGetCurrentIndex()

	_GTDeleteTabItem($iTabIndex)

	if _GTCountTabItem() = 0 then onClickNew()

endfunc


func onClickLoad()
; 메뉴에서 불러 오기 클릭시

	local $sFileName
	local $iExistTabIndex

	_FormFindReplaceClose()

	if WinActive($_gForm) = 0 then return

	;if checkBrforeSave("C", True ) = "C" then return


	if $_sLastFileOpenPath = "" then $_sLastFileOpenPath = $_runScriptPath
	;debug($_sLastFileOpenPath)

	;SelectHotKey("null")
	$sFileName = FileOpenDialog ($_sProgramName & " - " & _getLanguageMsg ("main_open"), $_sLastFileOpenPath , "Script files (*" & $_sScriptFileExt &  ") |All files (*.*)",1,"", $_gForm)

	GUICtrlSetState($_gEditScript, $GUI_FOCUS)     ; the focus is on this button

	SelectHotKey("main")

	$_runErrorImageTarget = ""

	if $sFileName <> "" and FileExists ($sFileName) = 1 Then

		loadScript ($sFileName)
		setTestStatusBox(_getLanguageMsg("status_ready"))


	endif

endfunc


func onClickSave($bSaveOnly = False, $bNewSave = False)
; 메뉴에서 저장 클릭시

	_FormFindReplaceClose()

	if WinActive($_gForm) = 0 then return

	local $handle
	local $sFileName
	local $aScriptPos
	local $bReturn = False
	local $aLastScrollPos
	local $sSaveTitle
	local $sNewFile
	local $iCurrentVisibleLine
	local $sOldFilename
	local $iEncodingType = 0

	if $_sLastFileOpenPath = "" then $_sLastFileOpenPath = $_runScriptPath
	;debug("save 시작")
	$sOldFilename = getScriptFileName()
	$sFileName = $sOldFilename

	if $bNewSave  then
		$sSaveTitle = _getLanguageMsg ("main_saveas")
		$sNewFile = $sFileName
		$sFileName = ""

	else
		$sSaveTitle = _getLanguageMsg ("main_save")
		$sNewFile = $_sUntitledName & ".txt"
	endif

	if $sFileName = "" then $sFileName = FileSaveDialog  ($_sProgramName & " - " & $sSaveTitle , $_sLastFileOpenPath , "Script files (*" & $_sScriptFileExt &  ")",1,$sNewFile, $_gForm)
	if $sFileName = "" then return $bReturn
	; 이미 다른탭에서 편집하고 있을 경우

	;debug(_GTGetFileNameIndex($sFileName,_GTGetCurrentIndex()))
	if _GTGetFileNameIndex($sFileName,_GTGetCurrentIndex()) <> -1 then
		_ProgramError(_getLanguageMsg ("main_alreadyopenerror"))
		return
	endif

	if $bNewSave or ($sFileName <> $sOldFilename) and FileExists($sFileName) then
		if _ProgramQuestionYN(_getLanguageMsg ("main_savedeleteconfirm")) = "N" then Return
	endif

	setToolbar("DISABLE")
	_GTTabEnable (False)

	setStatusText($sFileName & ", Save")

	_saveRecentFilePos($sFileName)

	; 스크립트 확장자 자동추가
	if stringright("        " & $sFileName, 4) <> $_sScriptFileExt then
		$sFileName = $sFileName &  $_sScriptFileExt
	endif

	RealTimeTargetCheckReset()

	$_sRichTextModified = _GuiCtrlRichEdit_getText  ($_gEditScript, False)

	if FileExists($sFileName) = 1 then
		$iEncodingType = FileGetEncoding ($sFileName)
	Else
		if getIniBoolean(getReadINI("Environment","SaveUTF8")) = True then $iEncodingType = 128
		;msg(getReadINI("Environment","SaveUTF8"))
	endif


	$handle = fileopen($sFileName,2 + $iEncodingType )
	FileWrite($handle, _GuiCtrlRichEdit_getText  ($_gEditScript, True))
	fileclose($handle)

	$_sLastFileOpenPath = _GetPathName ($sFileName)

	$bReturn = True

	setScriptFileName ($sFileName)
	_GTLoadFile(_GTGetCurrentIndex(), $sFileName)
	;debug("save 전")
	;saveScriptEditInfo(_GTGetCurrentIndex())

	if $bSaveOnly = False then
		;debug("왔어")

		; 블럭 위치를 설정
		$aLastScrollPos = _GUICtrlRichEdit_GetScrollPos($_gEditScript)
		$aScriptPos = _GuiCtrlRichEdit_GetSel($_gEditScript)

		$iCurrentVisibleLine = _GUICtrlRichEdit_GetNumberOfFirstVisibleLine($_gEditScript)

		;debug("저장후 읽기1")
		loadScript ($sFileName, False, False)

		;debug("저장후 읽기2")

		; 블럭 위치를 재확인
		_GuiCtrlRichEdit_SetSel($_gEditScript, $aScriptPos[0], $aScriptPos[1])

		RichTextFocusCenter($_gEditScript, $iCurrentVisibleLine)

		;_GUICtrlRichEdit_ScrollLines ($_gEditScript, 15)
		;_GUICtrlRichEdit_ScrollToCaret($_gEditScript)
		;_GUICtrlRichEdit_SetScrollPos($_gEditScript, $aLastScrollPos[0], $aLastScrollPos[1])

	endif

	setTestStatusBox(_getLanguageMsg("status_ready"))

	setToolbar("DEFAULT")

	setStatusText($sFileName & ", Save")

	_GTTabEnable (True)


	return $bReturn

endfunc


func _getRecentFilePos($sFilename)

	_replaceFileNameforRegistry($sFileName)

	;debug("읽기 : " & Number(_readSettingReg($sFileName, "Location")))

	return Number(_readSettingReg($sFileName, "Location"))


endfunc


func _saveRecentFilePos($sFileName)

	local $aScriptPos = _GuiCtrlRichEdit_GetSel($_gEditScript)

	_replaceFileNameforRegistry($sFileName)

	;debug("저장 : " & $aScriptPos[0])

	_readSettingReg($sFileName, "|")

	_writeSettingReg($sFileName, $aScriptPos[0] , "Location")

endfunc


func _replaceFileNameforRegistry(byref $sFilename)

	$sFilename = StringReplace($sFilename, "\", "_")
	$sFilename = StringReplace($sFilename, ":", "_")

	;debug($sFileName)

endfunc


func onClickRefresh()
; 메뉴에서 스크립트 검사

	local $iScriptStart, $iScriptEnd
	local $bResult


	;debug($_aRunImagePathList)

	;debug($_aRunScriptPathList)

	_FormFindReplaceClose()

	if WinActive($_gForm) = 0 then return

	if checkBrforeSave() = "N" then return

	RealTimeTargetCheckReset()

	getScriptSelectRange($iScriptStart, $iScriptEnd, True)

	setToolbar("DISABLE")
	sleep(10)
	$bResult = UpdateRichText($_gEditScript, True, True, "", $iScriptStart, $iScriptEnd)
	sleep(10)
	setToolbar("DEFAULT")

	return $bResult

endfunc


func onClickImageMng($sImagePath = "" )

	local $bSearchSkip

	_FormFindReplaceClose()

	if getScriptFileName() = ""  then
		_ProgramError (_getLanguageMsg ("capture_saveerror1"))
		return
	endif

	_UpdateFolderFileInfo(False)

	if $sImagePath = "" then
		$sImagePath = _GetPathName(getScriptFileName())
		$bSearchSkip = False
	Else
		$bSearchSkip = True
	endif

	SelectHotKey("null")
	$_gListViewCurScript = getScriptFileName()
	$_gListViewCurPath = $sImagePath

	if stringright($_gListViewCurPath,1) = "\" then $_gListViewCurPath = StringTrimRight($_gListViewCurPath,1)

	if $sImagePath = "" then
		getImageListDataFormScript()

	else
		getImageListDataFormPath ($sImagePath)

	endif

	;msg($_gListViewData)

	_loadMngImage($bSearchSkip)

	setImageListView ()

	_waitListView()

	;onClickRefresh()

	SelectHotKey("main")

	RealTimeTargetCheckReset()


endfunc


func onClickLoopRun()

	local $iRet
	local $i
	local $iLoopCnt
	local $iTestCnt = 0

	local $iFormWidth = 200
	local $iFormHeight = 140

	local $aWinPos = WinGetPos($_gForm)
	local $iformLeft, $iformTop


	$iformLeft = $aWinPos[0] + ($aWinPos[2]/2) - ($iFormWidth/2)
	$iformTop = $aWinPos[1] + ($aWinPos[3]/2) - $iFormHeight


	$iLoopCnt = InputBox(_getLanguageMsg ("main_looptest"), _getLanguageMsg ("main_looptestingcount") & " :",999,Default,$iFormWidth, $iFormHeight,$iformLeft, $iformTop,Default,$_gForm)

	$iLoopCnt = number($iLoopCnt)

	if $iLoopCnt > 0 then

		for $i=1 to $iLoopCnt

			$iTestCnt += 1
			$iRet = onClickRetry()

			if $iRet = False or $_bScriptStopping = True then ExitLoop

			TrayTip($_sProgramName, _getLanguageMsg ("main_looptesting") & " : " & $i & "/" & $iLoopCnt ,5,1)

			sleep(3000)

		next

		setStatusText (_getLanguageMsg ("main_looptestingresult") & " : " & $iTestCnt & "/" & $iLoopCnt & ", " & $iRet)

	endif

endfunc


func onClickSampleLoad()

	local $bSearchSkip

	_FormFindReplaceClose()

	SelectHotKey("null")
	;msg($_gListViewData)

	LoadSampleForm()

	_waitSampleForm()

	SelectHotKey("main")


endfunc


func onClickRetry()
; 부분 실행

	_FormFindReplaceClose()

	if getToolbarStatus($_tbRetry) = False then return


	if WinActive($_gForm) = 0 then return

	local $aSelTextPos

	if getScriptFileName() = ""  then
		_ProgramError (_getLanguageMsg("capture_saveerror1"))
		return
	endif

	$aSelTextPos = _GuiCtrlRichEdit_GetSel($_gEditScript)

	if $aSelTextPos[0] = $aSelTextPos[1] Then
		_GUICtrlRichEdit_SetSel ($_gEditScript,0,-1,False)
	endif

	;if onClickRefresh() = true then
		return runRichScript (True, True)
	;endif

endfunc


func onClickRun()
; 메인 실행

	_FormFindReplaceClose()

	if getToolbarStatus($_tbStart) = False then return


	if WinActive($_gForm) = 0 then return

	if getScriptFileName() = ""  then
		_ProgramError (_getLanguageMsg("capture_saveerror1"))
		return
	endif

	;if onClickRefresh() = true then
		return runRichScript (False, True)
	;endif

endfunc


Func onClickCapture()
; 캡쳐 버튼

	local $aSelTextPos

	_FormFindReplaceClose()

	if WinActive($_gForm) = 0 then return

	if checkBrforeSave() = "N" then return

	if getScriptFileName() = "" then
		_ProgramError (_getLanguageMsg("capture_saveerror1"))
		return
	endif

	setToolbar("CAPTURE")

	if $_bScreenCapture = False then

		SelectHotKey("capture")

		$_sLastSavedFileName = ""

		$_sCapturePath = _GetPathName(getScriptFileName()) & "Image"
		$_sCaptureFirstImageFolder = $_sCapturePath

		$_aRichEditLastSelect = _GuiCtrlRichEdit_GetSel($_gEditScript)

		$_sCaptureFile  = ""

		$_aDefaultCaptureFileList = getDefaultCaptureFilename()


		;guisetstate(GUISetState() + @SW_DISABLE,$_gForm)

		;_FormCaptureLoad()

		;WinSetState($_gForm, "", @SW_RESTORE)
		;WinSetState($_gForm, "", @SW_hide)
		WinSetState($_gForm, "", @SW_MINIMIZE )
		;WinSetState($_gForm, "", @SW_HIDE )
		;WinSetState($_gForm, "", @SW_MINIMIZE )

		;onClickFormClose2()


		setScreenCaptureOn()

	endif

	RealTimeTargetCheckReset()

endfunc

; ---------------------------------------------------------------------------------------------------

func setWindowsFontSmoothing($bOn, $bMainWinShow, $hWin = "" )

	local $hLastWindow
	local $bWinShow
	local $tTimeInit


	if $hwin <> "" and WinExists($hwin) then
		$hLastWindow = $hwin
	elseif WinExists($_hBrowser) then
		$hLastWindow = $_hBrowser
	Else
		$hLastWindow = WinGetHandle("[ACTIVE]")
	endif

	_SetFontSmoothing(_iif($bOn,1,0))

	if IsObj($_gForm) then $_aRichEditLastSelect = _GuiCtrlRichEdit_GetSel($_gEditScript)


	;WinSetState ($_gForm, "", @SW_MINIMIZE)
	;WinSetState($hLastWindow, "",@SW_MINIMIZE)
	;if $bMainWinShow then WinSetState($_gForm, "",@SW_MINIMIZE)
	WinMinimizeAll ()

	sleep (100)
	$tTimeInit = _TimerInit()

	do

		$bWinShow = True

		WinSetState($hLastWindow,"",@SW_SHOWNA)
		;WinActivate($hLastWindow)

		if $bMainWinShow then

			WinSetState($_gForm,"",@SW_SHOWNA)
			;GUISetState (@SW_SHOW , $_gForm)
			;WinActivate($_gForm,"")
		endif

		if BitAnd(WinGetState($hLastWindow), 16) = 16 then $bWinShow = False
		if $bMainWinShow and BitAnd(WinGetState($_gForm), 16) = 16 then $bWinShow = False

		sleep (100)

	until $bWinShow or (_TimerDiff($tTimeInit) > 1000)

	if IsObj($_gForm) then  _GUICtrlRichEdit_SetSel ($_gEditScript, $_aRichEditLastSelect[1], $_aRichEditLastSelect[0], False)

endfunc


func getImageListDataFormScript()
	; 이미지 파일 관리

	local $i, $j, $k
	local $bResult
	local $iNewAdd
	local $iOldmax
	local $iNewCount
	local $aImageFile[1]
	local $j
	local $aImageSplit

	redim $_gListViewData [1][$_iImageLstEnd]

	;$_gListViewData [0][$_iImageLstName] = ""

	for $i= 1 to ubound($_aPreAllImageTarget) -1

		$aImageSplit= stringsplit($_aPreAllImageTarget[$i],",")

		redim $aImageFile[1]

		for $k= 1 to ubound($aImageSplit) -1

			$aImageSplit[$k] = _Trim($aImageSplit[$k])

			;debug($aImageSplit[$k] )
			$bResult = getCommnadImage($aImageSplit[$k], $aImageFile, False)

			$iOldmax = ubound($_gListViewData) -1
			$iNewAdd = ubound($aImageFile) -1
			$iNewCount = 0

			;debug($iOldmax, $iNewAdd)

			if $bResult then
				for $j= 1 to $iNewAdd
					if $aImageFile[$j] <> "" then
						if _ArraySearch($_gListViewData,$aImageFile[$j],0,0,0,0,1,$_iImageLstFullPath) = -1 then
							;debug($_gListViewData)
							;debug($aImageFile[$j])
							$iNewCount += 1
							redim $_gListViewData [$iOldmax + $iNewCount+ 1][$_iImageLstEnd]

							$_gListViewData[$iOldmax+$j][$_iImageLstName] = $aImageSplit[$k]
							$_gListViewData[$iOldmax+$j][$_iImageLstFullPath] = $aImageFile[$j]
							$_gListViewData[$iOldmax+$j][$_iImageLstUse] = True
						endif
					endif
				next

			endif
		next
	next


	if ubound($_gListViewData) > 1 then
		redim  $_gListViewData [ubound($_gListViewData) ][$_iImageLstEnd]
	endif

	;msg($_gListViewData)

endfunc

func setTestStatusBox($sStatus, $bError = False)
; 상단 테스트 정보 표시 업데이트

	setStatusBarText($_iSBTestResult, @tab & $sStatus)

	local $iIconID

	switch $sStatus

		case _getLanguageMsg("status_testing")
			if $bError then
				TraySetIcon(@ScriptDir &  "\icon.dll",-13)
				$iIconID = 2

			Else
				TraySetIcon(@ScriptDir &  "\icon.dll",-12)
				$iIconID = 1

			endif

		case _getLanguageMsg("status_ready")
			$iIconID = 0

		case _getLanguageMsg("status_fail")
			$iIconID = 2

		case _getLanguageMsg("status_success")
			$iIconID = 1

	EndSwitch

	_GUICtrlStatusBar_SetIcon($_gStatusBar, $_iSBTestResultIcon, $_hTestResultIcon[$iIconID])

	GUISetState()

endfunc


func setProgressBar ($iPercent = -1)
; 상태 진행바 업데이트

	local $i
	local $iTotal
	local $iRun

	if $iPercent = -1 then

		for $i=1 to $_iScriptRecursive
			$iTotal += $_runScriptTotal[$i]
			$iRun += $_runScriptRun[$i]
		next

		if $iRun > $iTotal then $iTotal = $iRun

		$iPercent = int($iRun / $iTotal  * 100)
	endif

	; 상태바가 잘못 표시되는 경우가 있어 항상 위치를 변경하도록 함
	MainStatusResize()

	GUICtrlSetData($_gProgress,$iPercent)
	;debug($iRun, $iTotal, $iPercent)

endfunc


Func _RichEditInsertTab()

	local $bTab = False
	local $sFocusControl

	$sFocusControl = ControlGetFocus ($_gForm)
	;debug(GUICtrlRead ($_gEditScript,1), $GUI_FOCUS)
	;debug(BitAND(GUICtrlRead ($_gEditScript,1), $GUI_FOCUS))
	if stringinstr($sFocusControl, "RICHEDIT") > 0 and WinActive($_gForm) <> 0 then
		;TrayTip ("탭","탭추가",1,1)

		_GUICtrlRichEdit_InsertText($_gEditScript,@Tab)


		$bTab = True
	endif

	if $bTab = False then
		setMainHotKey(False)
		send ("{TAB}")
		setMainHotKey(True)
	endif

EndFunc


func _gotoRichEditLine($sLine = "" , $bBlock = False, $bErrorNotice = False )


	local $iLineCount
	local $iLineIndex
	local $iErrorNumber
	local $aWinPos
	local $iBlockSize  = 0
	local $iDefaultLine = 1

	if WinActive($_gForm) = 0 then return

	$aWinPos = WinGetPos($_gForm)

	$aWinPos[0] += ($aWinPos[2] /2) - 100
	$aWinPos[1] += ($aWinPos[3] /3)

	$iLineCount = _GUICtrlEdit_GetLineCount($_gEditScript)
	;debug("errorline : "  & $_runFirstErrorLine)
	if $_runFirstErrorLine > 0  and $_runFirstErrorLine <= $iLineCount then $iDefaultLine = $_runFirstErrorLine

	if $sLine = "" then $sLine = InputBox("Go To Line", "Line:",$iDefaultLine,Default,200,140,$aWinPos[0],$aWinPos[1] ,Default,$_gForm)
	$iErrorNumber = @error
	$sLine = Number($sLine)



	if $sLine  > 0 and $sLine  <= $iLineCount then

		$iLineIndex = _GUICtrlEdit_LineIndex($_gEditScript, $sLine-1)

		if $bBlock then $iBlockSize = _GUICtrlRichEdit_GetLineLength($_gEditScript,$sLine)

		_GUICtrlEdit_SetSel($_gEditScript, $iLineIndex, $iLineIndex + $iBlockSize)
	else
		;if $iErrorNumber <> 1  and $bErrorNotice then _ProgramError("줄 번호가 전체 줄 수를 넘거나 잘못된 값 입니다.")
	endif

endfunc


func _ViewSplashText($sText)

	local $aWinPos
	local const $iWidth =600, $iHeight = 70
	local $iLeft, $iTop

	$aWinPos = WinGetPos($_gForm)

	$iLeft = $aWinPos[0] + ($aWinPos[2] /2) - ($iWidth/2)
	$iTop = $aWinPos[1] + ($aWinPos[3] /3) - ($iHeight/2)

	if $sText = "" then
		SplashOff  ()
	else
		;debug($iLeft, $iTop, $iWidth , $iHeight)
		SplashTextOn("1231321321", $sText  , $iWidth , $iHeight, $iLeft, $iTop , 1+32,"",9)
	endif


endfunc


func _ViewRuntimeToolTip()

	local $aWinPos, $aCurrentMonitorSize
	local const $ssplashTitle = "GUITARTTOOLTIP"
	local $sMsg

	if $_runToolTipTimer <> _NowCalc() and $_bScriptRunning = True  and $_runRunningToolTip = True then

		$aWinPos = WinGetPos($_hBrowser)

		if IsArray($aWinPos) then

			$aCurrentMonitorSize = GetAareFromPoint($aWinPos[0] + ($aWinPos[2]/2) ,$aWinPos[1]  + ($aWinPos[3]/2))

			if IsArray($aCurrentMonitorSize) then

				$sMsg  = "[" & _NowTime(5) & "] " & getStatusBarText ($_iSBStatusText)

				;ToolTip("[" & _NowTime(5) & "] " & GUICtrlRead ($_gLiveStatus) , $aCurrentMonitorSize[1], $aCurrentMonitorSize[2],"",Default)

				if ControlSetText($ssplashTitle, "", "Static1", $sMsg  ) = 0 then
					SplashTextOn($ssplashTitle, $sMsg  ,1024,35, $aCurrentMonitorSize[1], $aCurrentMonitorSize[2], 1+4,"",9)
				endif

			endif
		endif

		$_runToolTipTimer = _NowCalc()

	endif

endfunc


; ===================================================================
; _RefreshSystemTray($nDealy = 1000)
;
; Removes any dead icons from the notification area.
; Parameters:
;   $nDelay - IN/OPTIONAL - The delay to wait for the notification area to expand with Windows XP's
;       "Hide Inactive Icons" feature (In milliseconds).
; Returns:
;   Sets @error on failure:
;       1 - Tray couldn't be found.
;       2 - DllCall error.
; ===================================================================
Func _RefreshSystemTray($nDelay = 1000)
; Save Opt settings
    Local $oldMatchMode = Opt("WinTitleMatchMode", 4)
    Local $oldChildMode = Opt("WinSearchChildren", 1)
    Local $error = 0
    Do; Pseudo loop
        Local $hWnd = WinGetHandle("classname=TrayNotifyWnd")
        If @error Then
            $error = 1
            ExitLoop
        EndIf

        Local $hControl = ControlGetHandle($hWnd, "", "Button1")

    ; We're on XP and the Hide Inactive Icons button is there, so expand it
        If $hControl <> "" And ControlCommand($hWnd, "", $hControl, "IsVisible") Then
            ControlClick($hWnd, "", $hControl)
            Sleep($nDelay)
        EndIf

        Local $posStart = MouseGetPos()
        Local $posWin = WinGetPos($hWnd)

        Local $y = $posWin[1]
        While $y < $posWin[3] + $posWin[1]
            Local $x = $posWin[0]
            While $x < $posWin[2] + $posWin[0]
                DllCall("user32.dll", "int", "SetCursorPos", "int", $x, "int", $y)
                If @error Then
                    $error = 2
                    ExitLoop 3; Jump out of While/While/Do
                EndIf
                $x = $x + 8
            WEnd
            $y = $y + 8
        WEnd
        DllCall("user32.dll", "int", "SetCursorPos", "int", $posStart[0], "int", $posStart[1])
    ; We're on XP so we need to hide the inactive icons again.
        If $hControl <> "" And ControlCommand($hWnd, "", $hControl, "IsVisible") Then
            ControlClick($hWnd, "", $hControl)
        EndIf
    Until 1

; Restore Opt settings
    Opt("WinTitleMatchMode", $oldMatchMode)
    Opt("WinSearchChildren", $oldChildMode)
    SetError($error)
EndFunc; _RefreshSystemTray()


func viewRichEditLineNumber()

	local $iCurrentVisibleLine = _GUICtrlRichEdit_GetNumberOfFirstVisibleLine($_gEditScript)
	local $iRicheditCursor = ControlCommand($_gForm, "", $_gEditScript, "GetCurrentLine", "")
	local $i
	local $sNumber

	if $_runLastRicheditFirstVisibleLine <> $iCurrentVisibleLine then

		for $i = 0 to 100
			$sNumber &= $iCurrentVisibleLine + $i & @cr
		next

		;GUICtrlSetData  ($_gLinelist,  $sNumber)
		_GUICtrlRichEdit_SetText($_gLinelist,  $sNumber)

		$_runLastRicheditFirstVisibleLine = $iCurrentVisibleLine

	endif

	if $_runLastRicheditCursor <> $iRicheditCursor then

		setStatusBarText($_iSBLocInfo , "Ln " & $iRicheditCursor)
		;ControlSetText ($_gForm,"",$_gLineStatus,$iRicheditCursor)

		$_runLastRicheditCursor = $iRicheditCursor
	endif

	MainFormResize()

endfunc


func MainFormResize()

	local $aCurrentImageListPos, $aObjectPos
	local $aCurrentMainWindowPos = WinGetPos ($_gForm)
	local $aCurrentRichLogPos
	local $iToolbarWidth
	local $i, $iTabCount

	; reset
	if $_runLastMainWindowPos [2] = ""  then $_runLastMainWindowPos = $aCurrentMainWindowPos

	; mini 에서 복원된 경우 기존 값을 초기화 하여 다시 그리도록 함.
	if  BitAnd(WinGetState($_gForm), 16) = 16 then
		$_runLastMainWindowPos [3] = 1
		return
	endif


	; Richedit 상자를 수동으로 변경함 (크기가 변경되거나)
	if $_runLastMainWindowPos [2] <> $aCurrentMainWindowPos[2] or $_runLastMainWindowPos [3] <> $aCurrentMainWindowPos[3]   Then

		;GUISetState (@SW_LOCK,$_gForm)


		$_runLastMainWindowPos = $aCurrentMainWindowPos
		$aCurrentImageListPos = ControlGetPos("","", ControlGetHandle($_gForm,"",$_gObjEmbeddedIEImageViwer))

		;debug("왔어1")
		; 윈도우가 mini 에서 복원된 경우 상태표시줄만 업데이트 하고 탈출
		if $_runLastMainWindowPos [3] <>  1 Then


			$aObjectPos = getRichLineXY("Tab")
			;ControlMove("","", ControlGetHandle($_gForm,"",$_ETabMain), $aObjectPos[0], $aObjectPos[1], $aObjectPos[2], $aObjectPos[3])
			GUICtrlSetPos ($_ETabMain, $aObjectPos[0], $aObjectPos[1], $aObjectPos[2], $aObjectPos[3])


			$aObjectPos = getRichLineXY("Log")
			ControlMove("","", ControlGetHandle($_gForm,"",$_gRichLog), $aObjectPos[0], $aObjectPos[1], $aObjectPos[2], $aObjectPos[3])

			; 숨겨져 있는 모든 richedit에 대해 크기조절작업 수행
			$iTabCount = _GTCountTabItem()

			for $i= 0 to $iTabCount -1
				$aObjectPos = getRichLineXY("Line")
				ControlMove("","", ControlGetHandle($_gForm,"",$_ETabInfo[$i][$_ETab_RichLineHwnd]), $aObjectPos[0], $aObjectPos[1], $aObjectPos[2], $aObjectPos[3])
				GUISetState()

				$aObjectPos = getRichLineXY("Edit")
				ControlMove("","", ControlGetHandle($_gForm,"",$_ETabInfo[$i][$_ETab_RichEditHwnd]), $aObjectPos[0], $aObjectPos[1], $aObjectPos[2], $aObjectPos[3])
				GUISetState()
			next

			; 상단 이미지 버튼들의 크기를 조절함

			$iToolbarWidth = ($aCurrentImageListPos[2] + 6) / ($_tbEnd - $_tbNew)

			_WinAPI_SetWindowPos($_hToolbar, "", 1, 1, 2000, 100 , $SWP_NOZORDER)

			;_GUICtrlToolbar_SetButtonWidth($_hToolbar,$iToolbarWidth, $iToolbarWidth)

			;_GUICtrlToolbar_SetButtonSize($_hToolbar,53, $iToolbarWidth)

			_GUICtrlToolbar_SetStyleFlat($_hToolbar, True)

			;GUISetState()

			_GUICtrlStatusBar_Resize($_gStatusBar)

			_viewLastUseedImage()

			;msg("왔어")
			;GUISetState()

		endif

		MainStatusResize()

		;GUISetState (@SW_UNLOCK,$_gForm)

	endif

endfunc


func MainStatusResize()

	_GUICtrlStatusBar_EmbedControl ($_gStatusBar, $_iSBProgress , GUICtrlGetHandle($_gProgress))

	GUISetState()
	;_GUICtrlStatusBar_EmbedControl ($_gStatusBar, $_iSBTestResult, GUICtrlGetHandle($_gTestStatus ))

endfunc


func getStatusBarText($iID)

_GUICtrlStatusBar_GetText ($_gStatusBar,$iID)

endfunc


func setStatusBarText($iID, $sText, $iColor = 0, $iBkColor = -1)
	_GUICtrlStatusBar_SetText ($_gStatusBar, $sText , $iID)
	;_GUICtrlStatusBar_SetColor ($_gStatusBar, $sText , $iID, $iColor = 0, $iBkColor = -1)

endfunc


func changeFormTitle($sFilename)

	local $sNewTitle

	if $sFilename = "" then $sFilename = "(" & $_sUntitledName &  ")"

	if $sFilename <> "" then $sNewTitle = $sFilename & " - "
	$sNewTitle &= $_sProgramName & " v" & FileGetVersion(@ScriptDir & "\" & _GetScriptName() & ".exe")
	WinSetTitle ( $_gForm, "", $sNewTitle )

endfunc