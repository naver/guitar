#AutoIt3Wrapper_Icon=GUITAR.ico
#AutoIt3Wrapper_Res_Fileversion=1.9.0.18
#AutoIt3Wrapper_Res_FileVersion_AutoIncrement=p


; /INI:D:\GUITAR_MAP\BIN / /WorkPath:D:\GUITAR_MAP\DATA


;#RequireAdmin

#include-once

#include <GuiEdit.au3>
#include <GuiStatusBar.au3>
#include <GuiConstantsEx.au3>
#include <GuiRichEdit.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>

#include <IE.au3>
#Include <File.au3>
#Include <Misc.au3>
#Include <Array.au3>
#include <Excel.au3>
#include <Sound.au3>

#include ".\_include_nhn\_util.au3"
#include ".\_include_nhn\_file.au3"
#include ".\_include_nhn\_http.au3"
#include ".\_include_nhn\_smscore.au3"
#include ".\_include_nhn\_email.au3"
#include ".\_include_nhn\_font.au3"
#include ".\_include_nhn\_ie2.au3"
#include ".\_include_nhn\_statusbar.au3"


#include "UIACommon.au3"
#include "UIAFormMain.au3"
#include "UIAOptions.au3"
#include "UIAFindReplace.au3"

#include "UIAUserCaptureHtml.au3"
#include "GUITARIEObject.au3"
#include "GUITARUserFunction.au3"
#include "UIAMenu.au3"
#include "UIAAbout.au3"
#include "UIATab.au3"
#include "GUITARARecord.au3"
#include "GUITARAImageList.au3"
#include "GUITARLanguage.au3"
#include "GuitarWebdriverXpath.au3"
#include "GuitarErrorReport.au3"

main()

func main ()
;메인

	Local $sScriptName = ""
	Local $aRecentFileList = _getRecentFileList()
	local $scmdRunFile
	local $iReturnCode
	local $sPreRun
	local $sErrorMsg

	_ScriptLogWrite("시작", True)

	_IEErrorNotify(False)

	$_runAlwaysFontsmoothing = ""

	getCommandLineInfo ($scmdRunFile, $_sUserINIFile, $_runCmdRemote)

	_ScriptLogWrite("cmdline 분석")

	if _CheckSingleRun() = False then


		_RemoteProgrammError("Another instance of GUITAR already exists!")

		_exit(1, True )
	endif

	if @DesktopHeight < 600 or @DesktopWidth < 800 then

		_RemoteProgrammError("Screen resolution too low" & @lf  &  "Set the minimum size of 800*600 or more")

		_exit(1, True )

	endif

	_ScriptLogWrite("해상도 확인 완료")


	TraySetState()
	TraySetToolTip($_sProgramName)


	if $_sUserINIFile <> "" then

		if FileExists($_sUserINIFile) = 0  then
			if FileExists(@ScriptDir & "\" & $_sUserINIFile) <> 0  then $_sUserINIFile = @ScriptDir & "\" & $_sUserINIFile
		endif

	Else
		; debug 용 설정파일을 우선 찾고, 없을 경우 기본 ini 로 설정하도록 함
		$_sUserINIFile = @ScriptDir & "\guitar_debug.ini"
		if FileExists($_sUserINIFile) = 0 then  $_sUserINIFile = @ScriptDir & "\guitar.ini"
	endif

	if FileExists($_sUserINIFile) = 0  then
		_RemoteProgrammError("file not exists : " & $_sUserINIFile)
		_exit(1, True)
	endif

	;debug("commandline script:" & $scmdRunFile & ", ini:" &  $_sUserINIFile & " ,remote:" & $_runCmdRemote)

	if $scmdRunFile = "" then
		if ubound($aRecentFileList) > 1 then $sScriptName = $aRecentFileList[1]
	Else
		$sScriptName = $scmdRunFile
	endif

	_ScriptLogWrite("사용자 INI 설정 확인 완료")

	_setCommonVar()


	setupDebugLogFile ($_sDebugLogFile)
	writeDebugLog("공용변수 로딩완료")


	if checkUACSetting() = False then _exit(1, True )

	;********************************************************************************
	checkAdminRun()
	;********************************************************************************
	_ScriptLogWrite("ADMIN 설정 확인 완료")

	;exit

	; 언어 리소스를 캐싱함
	_writeLanguageMsgcache ()

	if _isWorksatationLocked() then
		_RemoteProgrammError(_getLanguageMsg("error_systemlock"))
		_exit(1, True )
	endif


	Opt("GUIOnEventMode", 0)
	AutoItSetOption("MustDeclareVars", 1)
	AutoItSetOption("TrayIconDebug", 0)
	AutoItSetOption("GUICloseOnESC", 0)
	AutoItSetOption ( "TrayAutoPause" ,0)
	AutoItSetOption ( "TrayMenuMode" ,1)

	AutoItSetOption("MouseClickDownDelay", getReadINI("Environment","ClickDelay"))

	SelectHotKey("main")

	writeDebugLog("HOTKEY 설정 완료")
	_ScriptLogWrite("HOTKEY 설정 완료")

	;디버깅(au3로 실행) 할 때는 fontsmoothigoff 하지 않을것
	if _IsExeMode() = 0 then $_runAlwaysFontsmoothing = False

	; 첫번쨰 최근 연 파일을 기본 파일로 읽음
	if $_runAlwaysFontsmoothing == "" then $_runAlwaysFontsmoothing = getIniBoolean(getReadINI("Environment","AlwaysfontsmoothingOff"))
	if $_runAlwaysFontsmoothing = True then setWindowsFontSmoothing(False,False )

	sleep (100)

	if $scmdRunFile <> "" then $_runCmdRunning = True

	; IE가 아닌  경우 강제로 열려진 브라우져를 모두 종료, 커맨드 모드시에도 모두 종료 하도록 함
	if $_runCmdRunning = True and getIniBoolean(getReadINI("Environment","CloseAllBrowser")) then
		CloseAllBrowser()
	endif


	writeDebugLog("Main 로딩 전")

	_ScriptLogWrite("메인폼 로딩전")

	_loadMainForm()

	_ScriptLogWrite("메인폼 로딩완료")

	writeDebugLog("Main 로딩 완료")

	; 이전 이미지리스트를 목록을 가져오기 위한 작업
	setMenuMoveList ()

	setToolbar("DISABLE")

	_ScriptLogWrite("메뉴설정 완료")

	_GUICtrlRichEdit_SetReadOnly($_gEditScript, True)

	;GUISetState(@SW_RESTORE, $_gForm)
	WinSetState ($_gForm,"",@SW_SHOWNA)

	sleep(1)
	;debug(WinActivate($_gForm))

	writeDebugLog("윈도우 위치 이동전")

	_MoveWindowtoWorkArea($_gForm)

	sleep(10)

	_ScriptLogWrite("윈도우 위치조정 완료")

	if $scmdRunFile <> "" then
		onClickNew()
		sleep(1000)
		runPreRunShell(False)
	endif

	if FileExists($_runCommonScriptPath) = 0 then
		_RemoteProgrammError(_getLanguageMsg("error_scriptpathnotfound") & @cr & @cr & $_runCommonScriptPath)
	endif


	if $scmdRunFile <> "" then
		$_runCmdRunning = True
		if FileExists($scmdRunFile) = 0  then
			_RemoteProgrammError(_getLanguageMsg("error_scriptnotfound") & @cr & @cr & $scmdRunFile)
			_exit(1, True )
		endif
	endif


	;if $_runAVICapture then _runAVICapture()

	if $sScriptName <> "" and FileExists($sScriptName) = 1 then

		$sScriptName = FileGetLongName ($sScriptName)

		loadScript ($sScriptName, True, True)
	else
		onClickNew()
	endif

	_ScriptLogWrite("초기 로딩완료")
	writeDebugLog("초기 로딩 완료")

	setToolbar("DEFAULT")


	; rich를 다시 활성화 함
	_GUICtrlRichEdit_SetReadOnly($_gEditScript, False)


	if $scmdRunFile <> "" then
		$iReturnCode = runRichScript (False)
		if $iReturnCode = True then
			$iReturnCode = 0
		Else
			$iReturnCode = 1
		endif

		_exit($iReturnCode)
	endif

	if FileExists(@ScriptDir & "\readme.txt") then
		if getReadINI("UPDATE","ReadmeCRC") <> FileGetSize(@ScriptDir & "\readme.txt") Then
			setWriteINI("UPDATE","ReadmeCRC", FileGetSize(@ScriptDir & "\readme.txt"))
			ShellExecute(@ScriptDir & "\readme.txt")
		endif
	endif

	$_sRealTimeTargetLast[0] = _TimerInit()


	if $_runCmdRemote = False then checkIEUseClearType()

	writeDebugLog("전체 로딩 완료")

	_ScriptLogWrite("", True)

	While 1
		_waitFormMain()
	WEnd

endfunc


func getCommandLineInfo(byref $sScript, byref $sUserIni, byref $bRemote)
	local $i, $j

	$sScript = ""
	$sUserIni = ""
	$bRemote = False

	if ubound($cmdline) > 1 Then

		for $i= 1 to ubound($cmdline) -1
			if stringleft($cmdline[$i],1) = "/" then
				if StringUpper(stringleft($cmdline[$i],5)) = "/INI:" then $sUserIni = StringTrimLeft($cmdline[$i],5)
				if StringUpper(stringleft($cmdline[$i],10)) = "/WORKPATH:" then $_runWorkPath = StringTrimLeft($cmdline[$i],10)
				if StringUpper(stringleft($cmdline[$i],9)) = "/SVNPATH:" then $_runSVNPath = StringTrimLeft($cmdline[$i],9)
				if StringUpper(stringleft($cmdline[$i],7)) = "/REMOTE" then $bRemote = True
				if StringUpper(stringleft($cmdline[$i],17)) = "/FONTSMOOTHINGOFF" then 	$_runAlwaysFontsmoothing = False
				if StringUpper(stringleft($cmdline[$i],9)) = "/XMLPATH:" then $_runXMLCommandLinePath = StringTrimLeft($cmdline[$i],9)
				if StringUpper(stringleft($cmdline[$i],8)) = "/TESTID:" then $_runBUILDID = StringTrimLeft($cmdline[$i],8)

				for $j=1 to 9
					if StringUpper(stringleft($cmdline[$i],10)) = "/CMDLINE" & $j & ":" then $_runCmdLine[$j] = StringTrimLeft($cmdline[$i],10)
				next

			else
				$sScript = $cmdline[$i]
			endif
		next

	endif

endfunc

;~ func _runAVICapture()

;~ 	_endAVICapture()

;~ 	RUN ($_sAVICapture)

;~ endfunc


;~ func _endAVICapture()

;~ 	_avi_setCaptureEND(True)

;~ 	sleep (300)

;~ 	ProcessClose($_sAVICapture)
;~ 	ProcessClose($_sAVICapture)

;~ 	_RefreshSystemTray()

;~ endfunc


;~ func _startAVICapture()

;~ 	local $aWinPos = WinGetPos($_gForm)

;~ 	if  ProcessExists($_sAVICapture) = False or _avi_getCaptureRunning() = True then
;~ 		_runAVICapture()
;~ 		sleep (1000)
;~ 	endif

;~ 	;debug($aWinPos)
;~ 	_avi_setCaptureRun(True)
;~ 	_avi_setpos(GetAareFromPoint($aWinPos[0] + ($aWinPos[2]/2) ,$aWinPos[1]  + ($aWinPos[3]/2)))
;~ 	_avi_setCapturePath($_runAVITempPath)

;~ endfunc


;~ func _stopAVICapture()

;~ 	_avi_setCaptureStopReq(True)

;~ endfunc


func _waitFormMain()
; 대기, 상단 툴바 클릭에 따른 작동

	local $msg, $i
	local $hFindReplaceForm = ""
	local $iStartPost, $iEndPos

	if $_bScriptRunning then return

	sleep (1)
	sleep (1)

	if $_gFindReplaceForm <> "" then $hFindReplaceForm = WinGetHandle($_gFindReplaceForm)

	$msg = GuiGetMsg(1)

	viewRichEditLineNumber()

	;debug(_WinAPI_GetFocus (), $_gObjEmbeddedIEImageViwer, $_gEmbeddedIEImageViwer)


	;debug(_TimerDiff($_sRealTimeTargetLast[0]) )
	if _TimerDiff($_sRealTimeTargetLast[0]) > 100  and $_gEditScript = _WinAPI_GetFocus () and ($_bScriptRunning = False) then
		;GUICtrlSetState($GUI_FOCUS, $_gEditScript)
		;GUICtrlSetState ($_gObjEmbeddedIEImageViwer,$GUI_DISABLE)
		;debug("왔어 " & _now())
		$_gEditScript = _WinAPI_GetFocus ()
		$_sRealTimeTargetLast[0] = _TimerInit()
		RealTimeTargetCheck(False, $iStartPost, $iEndPos)
	endif

	if $msg[0] = 0 then return

	if $msg[1] = $hFindReplaceForm then
		;debug($hFindReplaceForm)
		$msg = $msg[0]

		Switch $msg

			case $_gFindReplaceFindCmd
				_FindRichText()

			case $_gFindReplaceReplaceCmd
				_ReplaceRichText()

			case $_gFindReplaceCancel, $GUI_EVENT_CLOSE
				_FormFindReplaceClose()
				;AutoItSetOption("GUICloseOnESC", 0)

		EndSwitch

		return

	Else
		$msg = $msg[0]
	endif


	Switch $msg

		; 파일

		Case $_GMFile_NewFile
			onClickNew()

		Case $_GMFile_Oepn
			onClickLoad()

		Case $_GMFile_OpenRecent
			viewRecentFilelist()

		Case $_GMFile_OpenQuick
			viewHotlist()

		Case $_GMFile_OpenInclude
			viewIncludeFilelist()

		case $_GMFile_ClipboardOpen
			onClipboardOpen()

		case $_GMFile_Close, $_TabContextClose
			onCloseTab()

		Case $_GMFile_Save
			onClickSave()

		Case $_GMFile_SaveAS
			onClickSave(False, True)

		Case $GUI_EVENT_CLOSE, $_GMFile_Exit
			_exit()


		; 편집
		case $_GMEdit_Undo
			_GUICtrlRichEdit_Undo($_gEditScript)

		case $_GMEdit_Cut
			_GUICtrlRichEdit_cut($_gEditScript)

		case $_GMEdit_Copy
			_GUICtrlRichEdit_copy($_gEditScript)

		case $_GMEdit_Paste
			_GUICtrlRichEdit_Paste($_gEditScript)

		case $_GMEdit_Delete
			_GUICtrlRichEdit_ReplaceText($_gEditScript, "")

		case $_GMEdit_SelectAll
			_GUICtrlRichEdit_SetSel($_gEditScript,0,-1)

		case $_GMEdit_Found
			_FormFindReplaceLoad()

		case $_GMEdit_Go
			_gotoRichEditLine()

		case $_GMEdit_CommentSet
			_ScriptCommentSet()

		case $_gForm_mnu_rename, $_GMEdit_TargetRename
			_mnu_target_rename()

		case $_gForm_mnu_delete, $_GMEdit_TargetDelete
			_mnu_target_delete()

		case $_GMEdit_XPathVerify
			onClickXPathVerify()


		case $_GMEdit_CommandTemplate
			onClickSampleLoad()


		Case $_GMEdit_TestCaseImport
			onImportTC()


		;실행
		case $_GMRum_Run
			onClickRun()

		case $_GMRum_RunBlock
			onClickRetry()

		case $_GMRum_RunLoop
			onClickLoopRun()

		case $_GMRum_Stop
			TestCancelRequest ()

		case $_GMRum_RestBrowser
			hotkyeResetBrowserHandle()

		case $_GMImage_Capture
			onClickCapture()

		case $_GMImage_Edit
			onClickImageMng()

		case $_GMImage_Explorer
			onRunImageSearch()


		; 리포트
		case $_GMReport_Report
			onClickOpenReport()

		case $_GMReport_OpenReportFoler
			openLastReportFolder()

		case $_GMReport_OpenRemoteManager
			onClickOpenRemoteManager()

		; 도구
		Case $_GMTool_PreRun
			runPreRunShell()
			_UpdateFolderFileInfo(True)

		Case $_GMTool_UserRun1
			runUserFunction1()


		Case $_GMTool_UserRun2
			runUserFunction2()


		Case $_GMTool_UserRun3
			runUserFunction3()


		Case $_GMTool_UserRun4
			runUserFunction4()


		Case $_GMTool_UserRun5
			runUserFunction5()

			;if $_RENowRecording = False then
				;_HookKeyBoardMouseRecord($_gForm)
			;else
				;debug(RecordToScript(_UnHookKeyBoardMouseRecord()))
			;endif

		Case $_GMTool_RunTestCaseExport
			ShellExecute(@ScriptDir & "\GUITARExportTC.exe")

		; 도움말
		Case $_GMHelp_Help
			viewHelp()

		Case $_GMHelp_HelpAutoitCommand
			ShellExecute("http://www.autoitscript.com/autoit3/docs/functions/")

		Case $_GMHelp_HelpAutoitKey
			viewHelpKey()

		Case $_GMHelp_About
			openAboutWindow()


	EndSwitch


	for $i=1 to ubound ($_aOptionsText) -1
		if $_aOptionsText[$i][2] <> "" and 	$_aOptionsText[$i][1] = $msg then onClickOptionsAll($i)
	next

endfunc

; ------------------------------------ 실행 전반적인 결정 --------------------------------------------

func _exit($iReturn = 0, $bLoadingError = False)
; 메인종료

	local $aWinPos
	local $iTabCount = _GTCountTabItem() -1
	local $iLastFormX,$iLastFormY, $iLastFormWidth, $iLastFormHeight
	local $iMax = 0


	if $bLoadingError = False then

		; 탭중에 저장이 안된것 확인할것
		for $i= 0 to $iTabCount

			if _GTCheckSaveFile($i) = False then

				_GTSelectTab($i)

				if checkBrforeSave("C") = "C" then return

			endif
		next

		setToolbar("DISABLE")
		guisetstate(GUISetState() + @SW_DISABLE,$_gForm)



		if  BitAnd(WinGetState($_gForm), 32) = 32 then
			$iMax = 1
			;WinSetState($_gForm,"" ,@SW_HIDE)
			WinSetState($_gForm,"" ,@SW_RESTORE)
			WinSetState($_gForm,"" ,@SW_HIDE)
		endif

		MouseBusy (True)


		sleep (1)

		$aWinPos = WinGetPos($_gForm)

		$iLastFormX = $aWinPos[0]
		$iLastFormY = $aWinPos[1]
		$iLastFormWidth = $aWinPos[2]
		$iLastFormHeight = $aWinPos[3]


		if  BitAnd(WinGetState($_gForm), 16) = 16 then
			;MIN 인 경우 아무것도 저장하지 않음

		elseif  BitAnd(WinGetState($_gForm), 32) = 32 then
			; MAX 이면 좌우 쪽으로 값을 추가함. Width 에는 -1
			;$iLastFormX += 10
			;$iLastFormX += 10

			;$iLastFormWidth = -1
			;$iLastFormHeight = -1
			$iMax = 1

		else
			_writeSettingReg ("LastMainX",$iLastFormX)
			_writeSettingReg ("LastMainY",$iLastFormY)
			_writeSettingReg ("LastMainWidth",$iLastFormWidth)
			_writeSettingReg ("LastMainHeight",$iLastFormHeight)

		endif



		_writeSettingReg ("LastMainMax",$iMax)

		TrayTip("","",1)

		;_endAVICapture()


		_saveRecentFilePos(getScriptFileName())
		_setRecentFileList (getScriptFileName())

		setToolbar("DISABLE")

		guisetstate(GUISetState() + @SW_DISABLE,$_gForm)

	endif

	closeLogFile()


	;_SetFontSmoothing(1)

	; 글꼴 끝 다듬기 강제 설정

	if FileExists($_sProgramUpdater & "_new") then
		FileDelete(_GetFileName($_sProgramUpdater) & ".bak")
		FileMove($_sProgramUpdater, _GetFileName($_sProgramUpdater) & ".bak" , 1)
		FileMove($_sProgramUpdater & "_new", $_sProgramUpdater)
	endif

	;opt("TrayIconHide",1)

	if getIniBoolean(getReadINI("UPDATE","Check")) then
		ProcessClose($_sProgramUpdater)
		run(@ScriptDir & "\" & $_sProgramUpdater & " /noautoupdate",@ScriptDir)
	endif


	if $_runAlwaysFontsmoothing = True  then setWindowsFontSmoothing(True,False)
;
	if IsHWnd ($_gForm)  = true  then


		WinSetState($_gForm, "", @SW_HIDE)

		GUIDelete ( $_gForm )

		MouseBusy (False)

	endif



	exit ($iReturn)



endfunc


; ----------------------------------------------- 스크립트 실행 -----------------------------------------------

func runRichScript($bIsRetry, $bAutoSave = False)
; 스크립트 메인 실행

	local $aRowScript
	local $aPreLoadRowScript
	local $aScript
	local $aPreloadScript
	local $sScriptName
	local $iRunStart
	local $iRunEnd
	local $sErrorMsgAll
	local $bResult = False
	local $aTestLogInfo[1]
	local $sNewBrowserType
	local $hNewBrowser
	local $sPreloadScript
	local $sReportFile
	local $sTestStartTime
	local $sTestEndTime
	local $sReportPath
	local $aRunCountInfo [4] = [0,0,0,0]
	local $sTestingTime
	local $sTempFileRead
	local $aProcessInfo
	local $i
	local $bWindowActive
	local $sNewBrowserCreate
	local $sTempReport

	local $sSummryReportFile = $_runReportPath & "\report.htm"
	local $sDashBoardReport
	local $sUserCaptureSubPath = "capture"
	local $sUserCaptureReportFile = "capturereport.htm"
	local $sAreaCaptureViewType
	local $bOldTrayToolTip
	local $siexplore = @ProgramFilesDir & "\Internet Explorer\iexplore.exe"
	local $sXML
	local $sReportDateTimeFolder
	local $sXMLOutputFile

	local $aErrorReport
	local $bCreateErrorSumarry
	local $sErrorSumarryTitle
	local $sErrorSumarryContents


	if $bAutoSave = true and _checkRichTextModified() = True then onClickSave(True)

	if checkBrforeSave("") = "N" then return $bResult

	clearLog()

	_GUICtrlRichEdit_SetReadOnly($_gEditScript, True)

	setToolbar("TEST")
	SelectHotKey("test")

	sleep(1)

	$sScriptName = getScriptFileName()

	resetRunReportInfo()

	setupLogFile($_sRunningLogFile, $_sReportLogFile)

	do

	; 테스트 진행중일때 로그창 배경색을 바꿈
	changeLoglistBGColor (True)
	$_bScriptRunPaused = False
	$_aLastNavigateTime = 0
	$_runErrorCount = 0
	$_runScreenCaptureCount = 0
	$_runFirstErrorLine = 0
	$_runAreaCpatureExists = False
	$_runErrorImageTarget = ""
	$sTestStartTime = _NowCalc()

	; 최우선으로 /BUILDID로 들어온 값을 사용하도록 함

	if $_runBUILDID <> "" then  $_runBUILDID = HudsonDateTimeConvert($_runBUILDID)

	if $_runBUILDID <> "" then
		$sReportDateTimeFolder = $_runBUILDID
	else
		$sReportDateTimeFolder = $sTestStartTime
	endif

	$sReportPath = getReportPath(_GetFileName($sScriptName), $sReportDateTimeFolder)

	$_runWorkReportPath = $sReportPath

	;debug("설정 : " & $_runWorkReportPath)

	$_runUserCapturePath = $sReportPath & "\" & $sUserCaptureSubPath
	$_runScreenCapturePreName = "\capture_"  & _GetFileName($sReportPath) & "_"


	; XML 파일이 생성될 위치
	if $_runXMLCommandLinePath <> "" Then
		$_runXMLPath = $_runXMLCommandLinePath
		$_runXMLReport = True
	else
		$_runXMLPath = $_runWorkReportPath
	endif

	addSetVar ("$GUITAR_AdjustXPos=0", $_aRunVar)
	addSetVar ("$GUITAR_AdjustYPos=0", $_aRunVar)
	addSetVar ("$GUITAR_BrowserSize=" & $_runBrowserWidth & "," & $_runBrowserHeight , $_aRunVar)

	_FileReadToArray($sScriptName,$aRowScript)





	;if $_runCmdRunning = True then

	for $i= 1 to 3
		WinActive($_gForm)
		$bWindowActive = WinActivate($_gForm)
		if $bWindowActive <> 0 then exitloop
		sleep(500)
	next

	if $bWindowActive  = 0   then
		$sErrorMsgAll = _getLanguageMsg("error_systemlock")
		writeRunLog($sErrorMsgAll )
		sleep(1)
		makeReportLogFormat("", "", "", "",  _GetFileName($sScriptName), 1, 1, _NowCalc(), "F",  _getLanguageMsg("log_precheck"), $sErrorMsgAll, "")
		exitloop
	endif

	if $bIsRetry then
		getScriptSelectRange($iRunStart, $iRunEnd, False)
		$_runAVICapOn =  False

	Else
;~ 		if $_runAVICapture then
;~ 			_startAVICapture()
;~ 			$_runAVICapOn =  True
;~ 		endif
	endif

	_UpdateFolderFileInfo(False)




	$_runCommadLintTimeInit = _TimerInit()
	$_runCommadLintTimeStart = _Nowcalc()

	if getScript($aRowScript, $aScript, $sErrorMsgAll, True, $iRunStart, $iRunEnd) = False  then

		$bResult = False
		writeRunLog($_sLogText_PreError & _getLanguageMsg("log_scriptanalysiserror") & " : " & $sErrorMsgAll )


		UpdateRichText($_gEditScript, True, True,  $aScript, 0, 0)
		makeReportLogFormat("", "", "", "",  _GetFileName($sScriptName), 1, 1, _NowCalc(), "F", _getLanguageMsg("log_precheck"),_getLanguageMsg("log_scriptanalysiserror") & " " & $sErrorMsgAll, "")

		;_ArrayDisplay($aScript)
	else
		;_ArrayDisplay($aScript)
		;debug($aScript)

		if $bIsRetry then
			; 중간실행
			$_runContinueTest = False
			$_runRetryRun =  True
			$_runWaitTimeOut = getReadINI("environment","DebugTimeOut")


			_getLastBrowserInfo ()


			; 최근 수행한 웹드라이버 세션이 있을 경우 자동으로 셋팅


;~ 			if $_webdriver_connection_host <> "" and $_runWebdriver = False then
;~ 				$sNewBrowserCreate = _ProgramQuestionYN(("이전 사용한 웹드라이버 세션을 사용하시겠습니까?" & @crlf & @crlf & $_webdriver_connection_host))
;~ 				if $sNewBrowserCreate ="Y" then
;~ 					$_runWebdriver = True
;~ 					$_runBrowser = ""
;~ 					$_hBrowser = ""
;~ 				else
;~ 					$_runWebdriver = False
;~ 					$_webdriver_current_sessionid = ""
;~ 					$_webdriver_connection_host = ""
;~ 				endif
;~ 			endif



			; 프로세스가 존재할 경우 브라우저 이름이  동일한지 확인
			if WinExists($_hBrowser) <> 0 then
				if getBrowserExe($_runBrowser) <> _ProcessGetName(WinGetProcess($_hBrowser, ""))  then
					$_runBrowser = ""
					$_hBrowser = ""
				endif
			endif



			if ($_runBrowser = "" or WinExists($_hBrowser) = 0) and $_runWebdriver = False  Then

				$sNewBrowserCreate = _ProgramQuestionYNC(_getLanguageMsg("information_browsersetting"))

				if $sNewBrowserCreate ="Y" then
					$hNewBrowser = openNewIEBrowser()
					if $hNewBrowser <> "" then $sNewBrowserType = $_sBrowserIE

					;debug($hNewBrowser, $_runBrowser)
				elseif $sNewBrowserCreate ="N" then
					getProcessIDandHandle($sNewBrowserType, $hNewBrowser)
				endif

				if $sNewBrowserType <> "" Then
					$_runBrowser = $sNewBrowserType
					$_hBrowser = $hNewBrowser
				Else
					$bResult = False
					writeRunLog($_sLogText_PreError & _getLanguageMsg("error_browserselectfail"))
					exitloop
				endif
			endif


			;msg("선택 브라우저 정보 : " & $_runBrowser & ", Handle:" & $_hBrowser)
			_setCurrentBrowserInfo()


			;if $_runBrowser = $_sBrowserIE then
			;	$_oBrowser = _IEAttach($_hBrowser,"HWND")
			;endif

			Switch $_runBrowser
				case $_sBrowserIE, $_sBrowserFF, $_sBrowserSA, $_sBrowserCR, $_sBrowserOP
					_setBrowserWindowsSize($_hBrowser, False)
				case else
					_setBrowserWindowsSize($_hBrowser, True )
			EndSwitch


		Else

			; 전체 새로 실행
			if $_runErrorResume = "TEST" then
				$_runContinueTest = False
			else
				$_runContinueTest = True
			endif

			;$_runContinueTest = getIniBoolean(getReadINI("environment","ContinueTest"))
			$_runWaitTimeOut = getReadINI("environment","TimeOut")
			$_runRetryRun = False
			redim $_aRunVar[1][$_iVarFile + 1]

			setupImagePathList(_GetPathName($sScriptName))
			$iRunStart = 0
			$iRunEnd = 0
			$_runBrowser = ""
			$_hBrowser = ""

			WinSetState($_gForm, "", @SW_MINIMIZE )

			MainStatusResize()

		endif
		;msg(_GetPathName($sScriptName))

		setTestStatusBox(_getLanguageMsg("status_testing"))

		;debug($iRunStart, $iRunEnd)

		;msg($_runBrowser)

		for $i=0 to ubound($_runRecursiveErrorCount) -1
			$_runRecursiveErrorCount[$i] = 0
		next


		$_iScriptRecursive = 1
		$_bScriptStopping = False

		_ArrayAdd($aTestLogInfo, _getLanguageMsg("report_testserver") & " : " & $_runComputerName)

		_ArrayAdd($aTestLogInfo, _getLanguageMsg("report_testscript") & " : " & _GetFileName($sScriptName) & " (" & $sScriptName & ")")

		TrayTip($_sProgramName, _getLanguageMsg("report_testrun") & " : " & _GetFileName($sScriptName) & @Crlf & _getLanguageMsg("information_teststop")  & " : ESC" & @Crlf & _getLanguageMsg("information_testpause")  & " : PAUSE",3,1)




		$sPreloadScript = getReadINI("SCRIPT","PreLoadScript")

		$bResult = True

		if $sPreloadScript <> ""  then

			if FileExists($sPreloadScript) = 0 then
				if FileExists($_runCommonScriptPath & "\" & $sPreloadScript) = 0 then
					$bResult = False
					writeRunLog($_sLogText_PreError & "Preload " & _getLanguageMsg("error_scriptnotfound") & " : " & $_runCommonScriptPath & "\" & $sPreloadScript)
					makeReportLogFormat("", "", "", "",  _GetFileName($sScriptName), 1, 1, _NowCalc(), "F", _getLanguageMsg("log_precheck") , "Preload " & _getLanguageMsg("error_scriptnotfound") & " : " &  $sPreloadScript, "")
				else
					$sPreloadScript = $_runCommonScriptPath & "\" & $sPreloadScript
				endif
			Else
				$sPreloadScript = FileGetLongName($sPreloadScript,1)
			endif

			if $bResult then
				_FileReadToArray($sPreloadScript,$aPreLoadRowScript)
				if getScript($aPreLoadRowScript, $aPreloadScript, $sErrorMsgAll, True, 0, 0) = False then
					writeRunLog($_sLogText_PreError & "PreLoad " & _getLanguageMsg("log_scriptanalysiserror") & " : " & $sErrorMsgAll)
					makeReportLogFormat("", "", "", "",  _GetFileName($sPreloadScript), 1, 1, _NowCalc(), "F", _getLanguageMsg("log_precheck") ,"PreLoad " & _getLanguageMsg("log_scriptanalysiserror") & " : " & $sErrorMsgAll, "")
					$bResult = False
				endif
			endif

		endif


		if $bResult = True then
			;debug(ubound($aPreloadScript))
			$_bScriptRunning = True

			$bOldTrayToolTip = $_runTrayToolTip
			$_runTrayToolTip  = False
			; 스크립트 파일이 있으면서, 부분실행이 최초인 경우에만 실행할것
			if $sPreloadScript <> "" and ($bIsRetry = False or $_runPreScriptRunned = False) then
				$bResult  = runScript($sPreloadScript, $aPreloadScript, 0,0, $aRunCountInfo)
				$_runPreScriptRunned = True
			endif

			$_runTrayToolTip = $bOldTrayToolTip

			if $bResult then $bResult  = runScript($sScriptName, $aScript, $iRunStart, $iRunEnd, $aRunCountInfo )
			$_bScriptRunning = False

			;debug("ErrorCount :" & $_runErrorCount )
			if $_runErrorCount > 0 then $bResult =  False
		endif

		$_aRunReportInfo[$_iResultRun] = $_aRunReportInfo[$_iResultRun] - $_aRunReportInfo[$_iResultSkip]
		$_aRunReportInfo[$_iResultPass] =  $_aRunReportInfo[$_iResultRun]  - $_aRunReportInfo[$_iResultFail]
		$_aRunReportInfo[$_iResultNotRun] =  $_aRunReportInfo[$_iResultAll]   - $_aRunReportInfo[$_iResultRun] - $_aRunReportInfo[$_iResultSkip]

		;msg($_aRunReportInfo[$_sResultNorRunList])
		$_aRunReportInfo[$_sResultNorRunList] = deleteSkipListFromNotRunList($_aRunReportInfo[$_sResultNorRunList], $_aRunReportInfo[$_sResultSkipList])
		;msg($_aRunReportInfo[$_sResultNorRunList])


		TrayTip("","",1)

		TrayTip($_sProgramName, _getLanguageMsg("report_testend") & " : " & _GetFileName($sScriptName)  & @Crlf & _getLanguageMsg("report_result") & " " & _iif($bResult,_getLanguageMsg("report_pass"),_getLanguageMsg("report_fail")),5,_iif($bResult,1,2))
		$sTestEndTime = _NowCalc()

		_ArrayAdd($aTestLogInfo, _getLanguageMsg("report_testend") & " : " & _iif($bResult,"<span style='color: blue;'>" & _getLanguageMsg("report_pass") & "</span>", "<span style='color: red;' >" & _getLanguageMsg("report_fail") & "</span>"))

		$sTempReport = _getLanguageMsg("report_testresult") & " (ID) : " & _getLanguageMsg("report_target") & "=" & $_aRunReportInfo[$_iResultAll] & ", " & _getLanguageMsg("report_run") & "=" & $_aRunReportInfo[$_iResultRun] & ", " & _getLanguageMsg("report_pass") & "=" & $_aRunReportInfo[$_iResultPass] & ", " & _getLanguageMsg("report_fail") & "=" & $_aRunReportInfo[$_iResultFail] & ", " & _getLanguageMsg("report_notrun") & "=" & $_aRunReportInfo[$_iResultNotRun] & ", " & _getLanguageMsg("report_skip") & "=" & $_aRunReportInfo[$_iResultSkip]
		_ArrayAdd($aTestLogInfo,$sTempReport)
		if $_runCmdRemote then writeRmoteLog($sTempReport)

		$sTempReport = _getLanguageMsg("report_testresult") & " (LINE) : " & _getLanguageMsg("report_target") & "=" & $aRunCountInfo[1] & ", " & _getLanguageMsg("report_run") & "=" & $aRunCountInfo[2] & ", " & _getLanguageMsg("report_pass") & "=" & $aRunCountInfo[2] - $aRunCountInfo[3] & ", " & _getLanguageMsg("report_fail") & "=" & $aRunCountInfo[3] & ", " & _getLanguageMsg("report_notrun") & "=" &  $aRunCountInfo[1] - $aRunCountInfo[2]
		_ArrayAdd($aTestLogInfo,$sTempReport)
		if $_runCmdRemote then writeRmoteLog($sTempReport)

		if $_aRunReportInfo[$_sResultSkipList] <> "" then
			$sTempReport = _getLanguageMsg("report_testskip") & " ID : <BR> " & stringreplace($_aRunReportInfo[$_sResultSkipList], @crlf, "<BR>" )
			;_ArrayAdd($aTestLogInfo,$sTempReport)
			if $_runCmdRemote then writeRmoteLog($sTempReport)
		endif

		_ArrayAdd($aTestLogInfo, _getLanguageMsg("report_testrun") & " : " & $sTestStartTime)

		;$sTestingTime = _DateDiff("n", $sTestStartTime, _NowCalc()) + 1 & " 분"

		$sTestingTime = minute2hour(_DateDiff("n", $sTestStartTime, $sTestEndTime) + 1)

		_ArrayAdd($aTestLogInfo,_getLanguageMsg("report_testtime") & " : " & $sTestingTime)
		_ArrayAdd($aTestLogInfo,"GUITAR " & _getLanguageMsg("report_version") & " : " & FileGetVersion(@ScriptDir & "\" & _GetScriptName() & ".exe"))

		setTestStatusBox(_iif($bResult,_getLanguageMsg("report_pass"),_getLanguageMsg("report_fail")))

		writeDebugTimeLog("테스트 완료 ")

		if $bIsRetry = False then

			; 부분캡쳐가 실행된 경우 별도 리포트 파일 생성할것
			if $_runAreaCpatureExists then

				if getReadINI("REPORT", "AreaCaptureView") <> "가로" then
					$sAreaCaptureViewType = "H"
				else
					$sAreaCaptureViewType = "V"
				endif

				_ArrayAdd($aTestLogInfo , _getLanguageMsg("report_capturereport") & " : " & "<a  target='_blank'  href='" & ".\" & $sUserCaptureSubPath & "\" & $sUserCaptureReportFile & "'>" & $sUserCaptureReportFile & "</a>" )
				_createUserCaptureReport($_runUserCapturePath & "\" & $sUserCaptureReportFile, $_runUserCapturePath,_GetFileName($sScriptName) & " " & _getLanguageMsg("report_capturereport"), $sAreaCaptureViewType)
			endif

			$sReportFile = $sReportPath & "\report.htm"

			; 윈격서버 대시보드 URL 설정
			$sDashBoardReport = _Trim(getReadINI("REPORT", "DashboardHost"))

			if $sDashBoardReport <> "" then

				if StringRight($sDashBoardReport,1) <> "/" then $sDashBoardReport &= "/"
				$sDashBoardReport &=  _GetFileName(FileGetLongName(_GetPathName($sReportPath))) & "/" &  _GetFileName($sReportPath) & "/report.htm"

			endif

			;debug("임시 리포트 : " & $_sRunningLogFile, $sReportFile )

			$bCreateErrorSumarry = getIniBoolean(getReadINI("ErrorAccumulate", "Alarm"))

			if $bCreateErrorSumarry then
				; 커맨드 모드 거나, 옵션에 의해 누적되도록 설정된 경우에만 On 할것 (수동실행등으로 누적기록될 수 있어 제한하도록 함)
				if not($_runCmdRunning = True or ($_runCmdRunning = False and getIniBoolean(getReadINI("ErrorAccumulate","CommandlineModeOnly")) = False ))  then $bCreateErrorSumarry = False
			endif

			writeDebugTimeLog("report 파일 생성 전 ")
			_createHtmlReport($sTestStartTime, $sReportFile , FileRead($_sReportLogFile),_GetFileName($sScriptName) & " " & _getLanguageMsg("report_detail") ,$aTestLogInfo, $sReportPath, _GetFileName($sScriptName), $_aRunReportInfo[$_sResultSkipList], $_aRunReportInfo[$_sResultNorRunList], $_runXMLReport , $sXML, $sDashBoardReport, $bCreateErrorSumarry)
			writeDebugTimeLog("report 파일 생성 후 ")
			if $_runXMLReport then

				$sXML = GR_XmlAddTestSuite (GR_XmlMakeInfo("failures",$_aRunReportInfo[$_iResultFail]) & GR_XmlMakeInfo("time",_DateDiff("s", $sTestStartTime,$sTestEndTime)) & GR_XmlMakeInfo("errors",0) & GR_XmlMakeInfo("skipped",$_aRunReportInfo[$_iResultSkip] + $_aRunReportInfo[$_iResultNotRun]) & GR_XmlMakeInfo("tests",$_aRunReportInfo[$_iResultAll]) & GR_XmlMakeInfo("name",_GetFileName($sScriptName)) , $sXML)
				$sXML = GR_XmlAddHeader() & $sXML

				if FileExists($_runXMLPath) = 0 then DirCreate(StringLower($_runXMLPath))

				$sXMLOutputFile = $_runXMLPath & "\report.xml"

				if FileExists($sXMLOutputFile) then FileDelete($sXMLOutputFile)

				;writeRunLog("테스트결과 XML 파일 생성 : " & $_runXMLOutput & " , " & _iif (FileWrite($_runXMLOutput,$sXML) = 1 ,"성공" ,"실패"))
				_FileWriteLarge($sXMLOutputFile,$sXML)
				writeRunLog("테스트결과 XML 파일 생성 : " & $sXMLOutputFile)

			endif


			; 장시간 테스트후 리소스가 초기화 되는 경우가 발생하여 오브젝트 재 로딩
			_loadLanguageResource(_loadLanguageFile(getReadINI("Environment","Language")))
			;SaveResultMHT("테스트결과 : " & _GetFileName($sScriptName) , $aTestLogInfo, getLogFileName($sScriptName))

			writeDebugTimeLog("report 파일 생성 후2 ")
			writeDebugTimeLog("report 파일 생성 후2 " & _getLanguageMsg("report_create"))
			writeDebugTimeLog("report 파일 생성 후2 " & $sReportFile)
			writeRunLog(_getLanguageMsg("report_create") & " : " & $sReportFile)
			writeDebugTimeLog("report 파일 열기 ")


			if getIniBoolean(getReadINI("Report","OpenReport")) and $_runCmdRemote = False then
				if getIniBoolean(getReadINI("Report","OpenDashboardReport")) and $sDashBoardReport <> "" then
					; 대시보드 URL로 오픈
					;ShellExecute($sDashBoardReport )

					if FileExists($siexplore) then
						run ($siexplore & " " &  $sDashBoardReport)
					else
						run ("cmd /c ""start " & $sDashBoardReport & """","",@SW_MINIMIZE)
					endif

				else
					;ShellExecute($sReportFile )

					if FileExists($siexplore) then
						run ($siexplore & " " &  $sReportFile)
					else

						run ("cmd /c ""start " & $sReportFile & """","",@SW_MINIMIZE)
					endif

				endif
			endif

			writeDebugTimeLog("report 저장 전 ")
			saveTotalReport($sSummryReportFile, _GetFileName($sScriptName), $sReportDateTimeFolder, $sTestStartTime, $sTestingTime, $bResult, $aRunCountInfo[1], $aRunCountInfo[2], $aRunCountInfo[3], stringreplace(stringreplace($sReportFile, $_runReportPath & "\",""), "\","/" ), $_aRunReportInfo, False)
			saveTotalReport($_runReportPath & "\" & _GetFileName(FileGetLongName(_GetPathName($sReportPath))) & "\report.htm", _GetFileName($sScriptName), $sReportDateTimeFolder,  $sTestStartTime, $sTestingTime, $bResult, $aRunCountInfo[1], $aRunCountInfo[2], $aRunCountInfo[3], stringreplace(stringreplace($sReportFile, $_runReportPath & "\",""), "\","/" ), $_aRunReportInfo, True)

			; 누적에러 확인하고 메일 및 SMS 발송
			if $bCreateErrorSumarry  then
				if $bResult = False then
					; 에러 카운트 정보 확인
					$aErrorReport = _getErrorSumarry(getReadINI("ErrorAccumulate", "Count"), _GetFileName($sScriptName), $sTestStartTime)
					; SMS 보내기

					if ubound($aErrorReport) > 1 then

						$sErrorSumarryTitle = _getErrorSumarryInfo($_runComputerName, $aErrorReport,$sDashBoardReport, $sErrorSumarryContents)

						if getIniBoolean(getReadINI("ErrorAccumulate","SMS"))  then
							writeRunLog("테스트결과 누적오류 SMS 발송")
							sendTestReportSMS(_GetFileName($sScriptName), $bResult, getReadINI("ErrorAccumulate","SMSList"), $sErrorSumarryTitle)
						endif


						if getIniBoolean(getReadINI("ErrorAccumulate","EMAIL"))  then
							sendTestReportEmail(_GetFileName($sScriptName), $bResult ,$sReportFile, $sReportPath, $sDashBoardReport, getReadINI("ErrorAccumulate","EmailList"), $sErrorSumarryTitle, $sErrorSumarryContents)
							writeRunLog("테스트결과 누적오류 EMAIL 발송")
						endif

					endif
				else
					; 테스트 성공일 경우 기존 남아 있는 에러 로그
					deleteSuccessListFormErrorSumarry(_GetFileName($sScriptName))

				endif
			endif

			writeDebugTimeLog("report 저장 경로 : " & $_runReportPath & "\" & _GetFileName(FileGetLongName(_GetPathName($sReportPath))) & "\report.htm")

			; 스크립트 폴더에 별도로 report.htm 파일 복사
			;filecopy($_runReportPath & "\" & StringLower(_GetFileName($sScriptName) & ".htm"), $_runReportPath & "\" & StringLower(_GetFileName($sScriptName) & "\report.htm"))

			;$sTempFileRead = FileRead($_runReportPath & "\" & StringLower(_GetFileName($sScriptName) & ".htm"))
			;$sTempFileRead = StringReplace($sTempFileRead , "'" & _GetFileName($sScriptName) &  "/" , "'./")
			;FileDelete($_runReportPath & "\" & StringLower(_GetFileName($sScriptName) & "\report.htm"))
			;FileWrite($_runReportPath & "\" & StringLower(_GetFileName($sScriptName) & "\report.htm"), $sTempFileRead)


			writeDebugTimeLog("report 저장 후 ")

			;saveTotalReport($iTSScriptName, $iTSDate, $iTSResult, $iTSAllCount, $iTSErrorCount, $iTSLink )

			;SMS 발송
			if getIniBoolean(getReadINI("ALARM","SMS")) and ($_runCmdRunning = True or ($_runCmdRunning = False and getIniBoolean(getReadINI("ALARM","CommandlineModeOnly")) = False )) then
				writeRunLog(_getLanguageMsg("report_sendsms"))
				if $bResult = False then sendTestReportSMS(_GetFileName($sScriptName), $bResult, getReadINI("ALARM","SMSList"))
			endif

			;Email 발송
			;debug ("메일보내기 :" & $_runCmdRemote & " " &  ($_runCmdRemote = True or ($_runCmdRemote = False and getIniBoolean(getReadINI("ALARM","CommandlineModeOnly")) = False )))
			if getIniBoolean(getReadINI("ALARM","EMAIL")) and ($_runCmdRunning = True or ($_runCmdRunning = False and getIniBoolean(getReadINI("ALARM","CommandlineModeOnly")) = False ))  then
				writeRunLog(_getLanguageMsg("report_sendemail"))
				writeDebugTimeLog("email 발송 전 ")
				if sendTestReportEmail(_GetFileName($sScriptName), $bResult ,$sReportFile, $sReportPath, $sDashBoardReport, getReadINI("ALARM","EmailList")) = False then
					writeRunLog($_sLogText_PreError & _getLanguageMsg("error_emailsend"))
				endif
				writeDebugTimeLog("email 발송 후 ")
			endif

		endif

	endif



	until True


	$_bScriptRunning = False
	; 테스트 종료후 로그창 배경색을 바꿈
	changeLoglistBGColor (False)

	writeDebugTimeLog("테스트 전체 종료 ")

	setStatusText(_getLanguageMsg("report_testend") & " (" & _iif($bResult,_getLanguageMsg("report_pass"),_getLanguageMsg("report_fail")) & ")")


	; 폴더가 빈 경우 삭제 (디버그용으로 실행시)
	if DirGetSize($sReportPath) <= 0  then DirRemove($sReportPath)

	if $_runCmdRemote then writeRmoteLog(_getLanguageMsg("report_testend") & " (" & _getLanguageMsg("report_result") & ":" & _iif($bResult,_getLanguageMsg("report_pass"),_getLanguageMsg("report_fail")) & ") : " & $sScriptName )




	WinActivate($_gForm)

	$_runLastMainWindowPos [2] = -1
	MainFormResize()


	MainStatusResize()

	;msg($_runLastImageArray)

	_viewLastUseedImage()

;~ 	if $_runAVICapOn then
;~ 		;debug("AVI 캡쳐 정지요청")
;~ 		_stopAVICapture()
;~ 	endif

	setProgressBar(0)
	setToolbar("DEFAULT")
	SelectHotKey("main")
	TraySetIcon()

	_GUICtrlRichEdit_SetReadOnly($_gEditScript, False)

	; 에러가 발생될 곳으로 이동 할 것
	if ($_runFirstErrorLine <> 0)  and ($_runErrorLineSelect = True) then

		_gotoRichEditLine($_runFirstErrorLine, True, False)

		RichTextFocusCenter($_gEditScript)

	endif

	closeLogFile()

	return $bResult

endfunc


func deleteSkipListFromNotRunList($sNotRunList, $sSkipList)

	local $aSplit = stringsplit($sSkipList,@crlf)
	local $i


	;msg($sNotRunList)
	;msg($aSplit)

	for $i=1 to ubound ($aSplit)-1
		$aSplit[$i] = _Trim($aSplit[$i])
		if $aSplit[$i] <> "" then $sNotRunList = stringreplace( $sNotRunList, $aSplit[$i] & @crlf, "" )
	next

	;msg($sNotRunList)

	return $sNotRunList

endfunc


func sendTestReportSMS($sScriptName, $bResult, $sSMSList, $sContext = "" )

	local $sList = StringSplit($sSMSList,",")
	local $i


	if $sContext  = "" then $sContext  = "[" & $_sProgramName & "] " & _getLanguageMsg("report_test") & " " & _getLanguageMsg("report_fail") & " (" & $sScriptName & ", " & _NowCalc() & ")"

	for $i=1 to ubound($sList)-1
		$sList[$i] = _Trim(StringReplace($sList[$i],"-",""))
		_SendSMS($sContext , $sList[$i])
	next

endfunc


func sendTestReportEmail($sScriptName, $bResult, $sReportFile, $sReportPath, $sDashBoardReport, $sEmailList, $sExTitle= "", $sExContents = "")

	local $sTitle
	local $sContents
	local $sList = StringReplace($sEmailList,",",";")
	local $sDashboardHost
	local $sNewHost
	local $aAttachFile
	local $sAttachList
	local $bAttachImage = getIniBoolean(getReadINI("ALARM","EmailImageAttach"))
	local $iDetailLogStart, $iErrorLogStart
	local $sErrorLogStart= "<!--ERROR_LOG_START-->"
	local $sDetailLogStart = "<!--DETAIL_LOG_START-->"
	local $sDetailLink
	local $bFullContents = not(getIniBoolean(getReadINI("ALARM","EmailSummary")))
	local $bRet
	local $bErrorSummaryEmail = False




	if $sExTitle = "" then
		$sTitle = "[" & $_sProgramName & "] " & _iif($bResult,_getLanguageMsg("report_pass"),_getLanguageMsg("report_fail")) & ", " & $sScriptName & " (@" & $_runComputerName & ")"
	else
		$bErrorSummaryEmail = True
		$sTitle =  $sExTitle
	endif


	if $sExContents = "" then
		$sContents  = FileRead($sReportFile)
	else
		$sContents  = $sExContents
	endif

	$sDashboardHost = getReadINI("REPORT", "DashboardHost")

	if $sDashboardHost = "" then

	endif
	;debug ($sDashboardHost)

	if $bAttachImage then
		$sNewHost = "cid:"
	else
		$sNewHost = $sDashboardHost & "/" & stringreplace(stringreplace($sReportPath, $_runReportPath & "\",""),"\","/") & "/"
	endif


	$sContents = StringReplace($sContents, "src='./" , "src='" & $sNewHost)
	$sContents = StringReplace($sContents, "href='./" , "href='" & $sNewHost)
	$sContents = StringReplace($sContents, "href='#" , "href='" & $sDashBoardReport & "#")
	$sContents = StringReplace($sContents, "../../" , $sDashboardHost & "/")
	;$sContents = StringReplace($sContents, "test01", "<img src='cid:capture_001.png'>")

	if $bAttachImage and ($bErrorSummaryEmail = False) then

		;$sContents = StringReplace($sContents, "<a target='BrowserScreen' href='./" ,  "<a target='BrowserScreen' href='cid:")

		$aAttachFile = _GetFileNameFromDir ($sReportPath , "*" & $_cImageExt, 0)

	endif

	;FileDelete("c:\1.htm")
	;FileWrite("c:\1.htm", $sContents)

	$sAttachList = ""

	if $_runEmailAddList <> "" then $sList  =  $sList & ";" & $_runEmailAddList

	$sList = StringReplace($sList," ","")
	$sList = StringReplace($sList,";;",";")

	;msg("email list : " & $sList)
	if IsArray($aAttachFile) then
		if ubound($aAttachFile) > 1 then $sAttachList = _ArrayToString($aAttachFile,";",1,0)
	endif

	if $bFullContents = False and $sExContents = "" then

		if $sDashBoardReport <> "" then
			$sDetailLink = "<H2> " & _getLanguageMsg("report_detaillog") & " : <a target='_detail' href='" & $sDashBoardReport &  "'>" & $sDashBoardReport & "</a></H2>"
			$iErrorLogStart = StringInStr($sContents,$sErrorLogStart) + Stringlen($sErrorLogStart)
			$sContents = StringLeft($sContents,$iErrorLogStart - 1) &  $sDetailLink & StringRight($sContents, stringlen($sContents) - $iErrorLogStart)
		endif

		$iDetailLogStart = StringInStr($sContents,$sDetailLogStart)
		$sContents = StringLeft($sContents,$iDetailLogStart -1)
		$sContents = $sContents & "</BODY>" & @crlf
		$sContents = $sContents & "</HTML>" & @cr

	endif

	if $bAttachImage then
		$bRet = _SendMail($_sProgramName, $sList, $sTitle, $sContents, $sAttachList, True)
	Else
		$bRet = _SendMail($_sProgramName, $sList, $sTitle, $sContents, "", False)
	endif

	return $bRet

endfunc


func getReportPath($sScriptName, $sTestStartTime)

	local $sPath

	;$sPath  =  $_runReportPath & "\" & $sScriptName & "\" & StringReplace(_DateTimeFormat( $sTestStartTime,2),"-","_") & "_" & stringreplace(_DateTimeFormat( $sTestStartTime,5), ":","_")
	$sPath  =  $_runReportPath & "\" & $sScriptName & "\" & StringReplace(Stringleft( $sTestStartTime,10),"/","-") & "_" & stringreplace(stringright( $sTestStartTime,8), ":","-")

	if FileExists($sPath) then DirRemove ( $sPath,1)
	if FileExists($sPath) = False then DirCreate (StringLower($sPath))

	$sPath = FileGetLongName($sPath)

	return $sPath

EndFunc

; -----------------------------------------------------------------------------------------

func loadScript($sFileName, $bScroll=True, $bNewTab = True)
; 신규스크립트 로드

	local $aLastEditPost
	local $iScrollPos
	local $iExistTabIndex
	local $bRet = False
	local $iTabIndex


	ToolTip("")

	$iExistTabIndex =  _GTGetFileNameIndex($sFileName)

	; 이미 열려진 파일이 있을경우 해당 탭을 다시 보여줌
	; 신규 오픈을 하려고 하는데, 기존에 이미 열려진 탭인 경우 제외
	if $iExistTabIndex <> -1  and $bNewTab = True then
		_GTSelectTab($iExistTabIndex)
		$bRet = True
		;debug("loadScript : " & "기존탭 있음 : " & $iExistTabIndex, $sFileName)
		return $bRet
	endif


	; 현재 상태가 변경되지 않은 "제목없음"일 경우 새로운창 열기라도 현재 창에서 열도록 함.

	$iTabIndex = _GTGetCurrentIndex()
	if _GTGetTitle($iTabIndex) = $_sUntitledName then $bNewTab = False

	; 신규 탭인데 최대 갯수를 초과 된 경우
	if $bNewTab = True then
		$iTabIndex = _GTAddTabItem(_GetFileNameAndExt($sFileName))

		;debug($iTabIndex)
		if $iTabIndex = -1 then return $bRet
	endif

	_GTTabEnable (False)

	;debug("loadScript1 : " & $iTabIndex,  $sFileName, _GTGetCurrentIndex())

	_GTLoadFile($iTabIndex,  $sFileName)

	writeConsoleDebug("로드 시작")

	setTestStatusBox(_getLanguageMsg("status_ready"))

	redim $_aRunImagePathList [1]
	redim $_aRunScriptPathList [1]

	_saveRecentFilePos ($_runScriptFileName)

	setStatusText ($sFileName & ", " & _getLanguageMsg("status_opening") & "...")

	setToolbar("DISABLE")

	clearLog ()

	setScriptFileName ($sFileName)
	_setRecentFileList ($sFileName)
	; 초기화

	_GuiCtrlRichEdit_SetText ($_gEditScript, FileRead($sFileName))
	;_GuiCtrlRichEdit_SetSel ($_gEditScript, 1, -1)
	;_GUICtrlRichEdit_SetFont($_gEditScript, $_EditFontSize, $_EditFontName)
	;_GUICtrlRichEdit_Deselect($_gEditScript)


	setupImagePathList(_GetPathName($sFileName))

	$_runScriptFileName = getScriptFileName()

	$_runLastLoadScript = $_runScriptFileName

	$_sLastFileOpenPath = _GetPathName ($sFileName)

	$_bUpdateForderFileList = True

	if $bScroll then
		$iScrollPos = _getRecentFilePos($sFileName)
	else
		$iScrollPos = -1
	endif



	UpdateRichText($_gEditScript, $_runPreCheck , $_runPreCheck,  "" ,0 ,0, $iScrollPos)



	$_sRichTextModified = _GuiCtrlRichEdit_getText  ($_gEditScript, False)

	setStatusText ($sFileName & ", " & _getLanguageMsg("status_open"))

	;debug("loadScript2 : " & $iTabIndex,  $sFileName, _GTGetCurrentIndex())
	_GTLoadFile($iTabIndex, $sFileName )

	saveScriptEditInfo($iTabIndex)

	writeConsoleDebug("로드 종료")

	_GTTabEnable (True)

	; 작업폴더내에 파일이 존재 하는지 확인, 없을 경우 경로창으로 표시됨
	checkLoadFolder($sFileName)

	$bRet = True

	return $bRet

endfunc


func saveScriptEditInfo($iIndex)

	; 현재 탭 변수 정보를 저장

	$_ETabInfo[$iIndex][$_ETab_CDataSaved] = True
	$_ETabInfo[$iIndex][$_ETab_CData1] = $_aRunImagePathList
	$_ETabInfo[$iIndex][$_ETab_CData2] = $_aRunScriptPathList
	$_ETabInfo[$iIndex][$_ETab_CData3] = $_runScriptFileName
	$_ETabInfo[$iIndex][$_ETab_CData4] = $_aPreAllScriptFile
	$_ETabInfo[$iIndex][$_ETab_CData5] = $_sLastFileOpenPath
	$_ETabInfo[$iIndex][$_ETab_CData6] = $_sRichTextModified
	$_ETabInfo[$iIndex][$_ETab_CData7] = $_runPreCheck
	$_ETabInfo[$iIndex][$_ETab_CData8] = $_runScriptName
	$_ETabInfo[$iIndex][$_ETab_CData9] = $_sImageForderFileList
	$_ETabInfo[$iIndex][$_ETab_CData10] = $_aPreErrorImageTarget
	$_ETabInfo[$iIndex][$_ETab_CData11] = $_aPreAllImageTarget


	;debug("탭이동 파일정보저장 : ", $iIndex, $_sImageForderFileList)

EndFunc


func loadScriptEditInfo($iIndex)

	; 이동 할 탭의 관련 정보를 불러옴

	if $_ETabInfo[$iIndex][$_ETab_CDataSaved] = True then

		$_bUpdateForderFileList = True

		$_aRunImagePathList = $_ETabInfo[$iIndex][$_ETab_CData1]
		$_aRunScriptPathList = $_ETabInfo[$iIndex][$_ETab_CData2]
		$_runScriptFileName = $_ETabInfo[$iIndex][$_ETab_CData3]
		$_aPreAllScriptFile = $_ETabInfo[$iIndex][$_ETab_CData4]
		$_sLastFileOpenPath = $_ETabInfo[$iIndex][$_ETab_CData5]
		$_sRichTextModified = $_ETabInfo[$iIndex][$_ETab_CData6]
		$_runPreCheck = $_ETabInfo[$iIndex][$_ETab_CData7]
		$_runScriptName = $_ETabInfo[$iIndex][$_ETab_CData8]
		$_sImageForderFileList = $_ETabInfo[$iIndex][$_ETab_CData9]
		$_aPreErrorImageTarget = $_ETabInfo[$iIndex][$_ETab_CData10]
		$_aPreAllImageTarget = $_ETabInfo[$iIndex][$_ETab_CData11]

		;msg($_aRunScriptPathList)

		;debug("읽기 : ", $iIndex, $_runScriptName)
	endif

	; 파일명 변경
	setScriptFileName ($_runScriptName)

EndFunc


func SaveResultMHT($sTitle, $aInfo, $sMHTFile)
; 파일을 HTML 로 저장한뒤 다시 mht 파일로 변경, 파일저장뒤 바로 삭제안되는 문제 있음

	local $sTempHtmlPre = @TempDir & "\" & $_sProgramName & "_report_"
	local $sTempHtml = $sTempHtmlPre & random() & ".htm"

	;createHtmlReport($sTempHtml, FileRead($_sRunningLogFile),$sTitle,$aInfo,"", "", "")

	_INetGetMHT("file://" & $sTempHtml, $sMHTFile )

	FileDelete($sTempHtmlPre & "*.htm")

endfunc


;------------------------------- RICHTEXT 관련 ------------------------------------
func UpdateRichText($oRichText, $bImageCheck, $bIncludeCheck, $aScritAnalysisInfo, $iScriptStartLine, $iScriptEndLine, $iDefaultPosLine = -1)
; 스크립트 내용에 대한 검증을 수행

	local $aRichEditPos
	local $sTempRichData
	local $iMaxLenght
	local $sTempPos
	local $oTempClipBoard
	local $bSuccess
	local $aLastScrollPos

	$_bLastIncludeCheck = $bIncludeCheck

	MouseBusy (True)

	setStatusText (_getLanguageMsg("status_scriptanalysis") & "...")

	writeConsoleDebug("폴더 정보 업데이트")
	_UpdateFolderFileInfo(False)
	writeConsoleDebug("폴더 정보 업데이트 완료")

	; 임시로 richtext 로 이동하여 해당곳에서 작업완료후 한번에 보여지는 곳으로 변경

	;writeConsoleDebug("파일 문석 시작")

	setToolbar("DISABLE")
	sleep (10)

	GUICtrlSetState ($oRichText, $GUI_DISABLE)

	_GUICtrlRichEdit_SetReadOnly($oRichText, True)

	$oTempClipBoard  = ClipGet()

	$aLastScrollPos = _GUICtrlRichEdit_GetScrollPos($oRichText)

	_GUICtrlRichEdit_HideSelection($oRichText,True)

	$aRichEditPos  = _GuiCtrlRichEdit_GetSel($oRichText)
	_GUICtrlRichEdit_Deselect($oRichText)

	;**************
	;$sTempRichData = _GUICtrlRichEdit_StreamToVar($oRichText, True)
	;_GUICtrlRichEdit_Deselect($_gHideScript)
	;_GUICtrlRichEdit_StreamFromVar($_gHideScript, $sTempRichData)

	RichTextStreamSwap($oRichText, $_gHideScript)

	;**************

	$iMaxLenght = _GUICtrlRichEdit_GetTextLength($_gHideScript,True,True  )

	_GUICtrlRichEdit_SetSel($_gHideScript, -1,-1, True)
	$sTempPos = _GuiCtrlRichEdit_GetSel($_gHideScript)
	_GUICtrlRichEdit_SetSel($_gHideScript, $sTempPos[0] - 1,$sTempPos[0], True)
	_GUICtrlRichEdit_ReplaceText($_gHideScript, "",False)

	writeConsoleDebug("파일 분석 변환전")

	$bSuccess = ConvertRichText($_gHideScript, $bImageCheck, $bIncludeCheck,  $aScritAnalysisInfo, $iScriptStartLine, $iScriptEndLine)

	writeConsoleDebug("파일 분석 변환후")

	;_GUICtrlRichEdit_Deselect($_gHideScript)
	_GUICtrlRichEdit_SetSel($_gHideScript,0,-1,True)


	;**************
	;$sTempRichData = _GUICtrlRichEdit_StreamToVar($_gHideScript)
	;_GUICtrlRichEdit_Deselect($oRichText)
	;_GUICtrlRichEdit_StreamFromVar($oRichText, $sTempRichData)
	;**************
	RichTextStreamSwap($_gHideScript, $oRichText)

	$iMaxLenght = _GUICtrlRichEdit_GetTextLength($oRichText,True,True )

	_GUICtrlRichEdit_SetSel($oRichText, -1,-1, True)
	$sTempPos = _GuiCtrlRichEdit_GetSel($oRichText)
	_GUICtrlRichEdit_SetSel($oRichText, $sTempPos[0] - 1,$sTempPos[0], True)
	_GUICtrlRichEdit_ReplaceText($oRichText, "",False)

	;원래 환경 복원 변환
	_GUICtrlRichEdit_HideSelection($oRichText,False)

	if $iDefaultPosLine <> -1 then
		_GuiCtrlRichEdit_SetSel($oRichText, $iDefaultPosLine, $iDefaultPosLine)
	else
		_GUICtrlRichEdit_SetSel($oRichText, $aRichEditPos[0] ,$aRichEditPos[1],False )
	endif

	_GUICtrlRichEdit_SetReadOnly($oRichText, False)

	GUICtrlSetState ($oRichText, $GUI_ENABLE)

	RichTextFocusCenter($oRichText)

	;_GUICtrlRichEdit_GotoCharPos($oRichText, $aRichEditPos[0])


	;_GUICtrlRichEdit_SetScrollPos($oRichText, $aLastScrollPos[0], $aLastScrollPos[1])


	ClipPut($oTempClipBoard)

	setToolbar("DEFAULT")

	;writeConsoleDebug("파일 분석 종료")

	;msg($_aPreAllScriptFile)

	;debug($bSuccess)

	setStatusText (_getLanguageMsg("status_scriptanalysisend"))

	MouseBusy (False)

	return $bSuccess

endfunc


func RichTextFocusCenter($oRichText, $iFirstVisibleLine= 0)

	local const $iDefaultScroll = 10
	local $iCurrentVisibleLine, $iCurrentLine, $iNewScrollLine
	local $aCurPos


	$aCurPos = _GUICtrlRichEdit_GetSel($oRichText)
	$iCurrentVisibleLine = _GUICtrlRichEdit_GetNumberOfFirstVisibleLine($oRichText)
	$iCurrentLine = _GUICtrlRichEdit_GetLineNumberFromCharPos ($oRichText, $aCurPos[0])

	if $iFirstVisibleLine <> 0 Then
		$iNewScrollLine = $iFirstVisibleLine - $iCurrentVisibleLine
	else
		$iNewScrollLine = ($iCurrentLine - $iDefaultScroll) - $iCurrentVisibleLine
	endif


	;debug("스크롤 : " & $iCurrentVisibleLine & ", " & $iCurrentLine & ", " & $iNewScrollLine)

	_GUICtrlRichEdit_ScrollLines ($oRichText, $iNewScrollLine)

	_GUICtrlRichEdit_ScrollToCaret($oRichText)

endfunc


func RichTextStreamSwap($oRichTextSrc, $oRichTextTgr)

	local $iMaxLenghtSrc, $iMaxLenghtTgr
	local $sTempRichData
	local $iMaxSize = 32000

	local $iStart = 0
	local $iEnd = 0

	$iMaxLenghtSrc = _GUICtrlRichEdit_GetTextLength($oRichTextSrc)

	;debug("src 원본 전체 크기 :" & _GUICtrlRichEdit_GetTextLength($oRichTextSrc))

	do

		$iEnd = $iStart + $iMaxSize

		if $iEnd > $iMaxLenghtSrc then $iEnd = -1

		;debug($iStart, $iEnd)

		_GUICtrlRichEdit_SetSel($oRichTextSrc, $iStart, $iEnd, True)

		$sTempRichData = _GUICtrlRichEdit_StreamToVar($oRichTextSrc, True)

		if $iStart = 0 then
			_GUICtrlRichEdit_SetSel($oRichTextTgr, -1, -1, True)
		else
			_GUICtrlRichEdit_AppendText($oRichTextTgr, " ")
			$iMaxLenghtTgr = _GUICtrlRichEdit_GetTextLength($oRichTextTgr)
			;debug("$iMaxLenghtTgr" , $iMaxLenghtTgr)
			;debug(_GUICtrlRichEdit_SetSel($oRichTextTgr, $iMaxLenghtTgr-1,$iMaxLenghtTgr, True))
		endif

		_GUICtrlRichEdit_StreamFromVar($oRichTextTgr, $sTempRichData)

		$iStart += $iEnd + 1

		;debug("target size1 :" & _GUICtrlRichEdit_GetTextLength($oRichTextTgr))

	until $iEnd = -1

	;debug("trg 원본 전체 크기 :" & _GUICtrlRichEdit_GetTextLength($oRichTextTgr))


endfunc


func ConvertRichText($oRichText, $bImageCheck, $bIncludeCheck,  $aScritAnalysisInfo, $iScriptStartLine, $iScriptEndLine )
; 스크립트 검증 결과를 기반으로 RichText 내의 글씨색깔을 변경 (메인)

	local $aRichScript
	local $sRichScript
	local $aRichEditPos
	local $aScriptPos
	local $i
	local $sNewCommandAll, $sNewCommandStartPosAll, $sNewPrimeCommandAll,  $sNewTargetAll, $sNewTargetStartPosAll,  $sNewCheckCodeAll,   $sCheckMessage
	local $iCheckScript
	local $iNewRichScriptIndex
	local $iSearchIndex
	local $iRichScriptSearchIndex
	local $aTemp[1]
	local $bSuccess = True
	local $bImageCheckLine

	redim $_aPreErrorImageTarget [1]
	redim $_aPreAllImageTarget [1]
	redim $_aPreAllScriptFile [1]

	$_RunImageCheckTrueCache = ""
	$_RunImageCheckFalseCache = ""

	;_GUICtrlRichEdit_HideSelection($oRichText,True)
	;_GUICtrlRichEdit_SetReadOnly($oRichText, True)
	$iRichScriptSearchIndex = 0

	_GUICtrlRichEdit_SetSel($oRichText, 0,-1, True)
	_GUICtrlRichEdit_SetCharBkColor($oRichText)
	_GuiCtrlRichEdit_SetCharColor($oRichText)

	ClearLoglist()

	$aRichScript = StringSplit(_GuiCtrlRichEdit_getText  ($oRichText), @crlf)
	$aRichEditPos  = _GuiCtrlRichEdit_GetSel($oRichText)

	writeConsoleDebug("반복 전")

	; 비교
	for $i= 1 to ubound($aRichScript) -1

		if $bImageCheck then
			if ($i >= $iScriptStartLine and $i <= $iScriptEndLine) or  ($iScriptStartLine <= 0)then
				$bImageCheckLine = $bImageCheck
			Else
				$bImageCheckLine = False
			endif
		else
			$bImageCheckLine = $bImageCheck
		endif

		$sCheckMessage = ""

		$sRichScript = _Trim($aRichScript[$i])

		$aScriptPos = _GUICtrlRichEdit_FindTextinRange($oRichText, $sRichScript, $iRichScriptSearchIndex, -1)

		if IsArray($aScriptPos) then

			$iRichScriptSearchIndex = $aScriptPos[1]

			_GuiCtrlRichEdit_SetSel($oRichText, $aScriptPos[0], $aScriptPos[1])

			writeConsoleDebug("단위 " & $i & " " & _GuiCtrlRichEdit_GetSelText  ($oRichText))

			if $aScritAnalysisInfo = "" then

				writeConsoleDebug("명령라인 분석 시작")
				$iCheckScript = getScriptLine($sRichScript,  $sNewCommandAll, $sNewCommandStartPosAll , $sNewPrimeCommandAll, $sNewTargetAll, $sNewTargetStartPosAll , $sNewCheckCodeAll,  $sCheckMessage, $bImageCheckLine, $bIncludeCheck, True, $i)
				writeConsoleDebug("명령라인 분석 종료")
			Else
				$iCheckScript = $aScritAnalysisInfo[$i][$_iScriptCheck]
				$sNewCommandAll = $aScritAnalysisInfo[$i][$_iScriptCommand]
				$sNewCommandStartPosAll = $aScritAnalysisInfo[$i][$_iScriptCommandStartPos]
				$sNewPrimeCommandAll = $aScritAnalysisInfo[$i][$_iScriptPrimeCommand]
				$sNewTargetAll = $aScritAnalysisInfo[$i][$_iScriptTarget]
				$sNewTargetStartPosAll = $aScritAnalysisInfo[$i][$_iScriptTargetStartPos]
				$sNewCheckCodeAll = $aScritAnalysisInfo[$i][$_iScriptCheckCode]
				$sCheckMessage = $aScritAnalysisInfo[$i][$_iScriptCheckMessage]
			endif

			;if $sCheckMessage = "" then
			writeConsoleDebug("검사")

			if $iCheckScript = $_iScriptAllCheckComment Then
				writeConsoleDebug("커맨트색칠 시작")
				;msg($sRichScript)
				_GuiCtrlRichEdit_SetCharColor($oRichText, $_iColorComment )
				_GUICtrlRichEdit_SetCharAttributes($oRichText, "+bo", True )
				writeConsoleDebug("커맨트색칠 종료")
			else
				writeConsoleDebug("정상명령 색칠 시작 ")
				ChangeRichText($oRichText, $sRichScript, $sNewCommandAll, $sNewCommandStartPosAll, $sNewTargetAll, $sNewTargetStartPosAll, $sNewCheckCodeAll,  $aScriptPos[0])
			endif

			if $sCheckMessage <> "" then
				$bSuccess = False
				writeConsoleDebug("오류명령 색칠 시작 ")
				addPreErrorImageList($sCheckMessage)
				;msg($aScriptPos)

				WriteLoglist (getLogLineNumber($i) & " > " & $sCheckMessage & @crlf)

				_GuiCtrlRichEdit_SetSel($oRichText, $aScriptPos[0], $aScriptPos[1])
				_GUICtrlRichEdit_SetCharBkColor($oRichText, $_iColorError)
				;_GuiCtrlRichEdit_SetCharColor($oRichText, $_iColorError)

				writeConsoleDebug("오류명령 색칠 종료 ")

			endif

		endif
	next

	writeConsoleDebug("반복 후")

	$_aPreAllScriptFile = _ArrayUnique($_aPreAllScriptFile , 1,1)

	if IsArray($_aPreAllScriptFile) = 0 then $_aPreAllScriptFile = $aTemp

	return $bSuccess

endfunc


Func ChangeRichText($oRichText, $sRichScript, $sNewCommandAll, $sNewCommandStartPosAll, $sNewTargetAll, $sNewTargetStartPosAll, $sNewCheckCodeAll,  $iSearchStart)
; 라인별  RichText 내의 글씨색깔을 변경

	local $aScriptPos
	local $aCommandPos
	local $aTargetPos
	local $sCommandSplit
	local $sCommandStartPosSplit
	local $sTargetSplit
	local $sTargetStartPosSplit
	local $sCheckCodeSplit
	local $iCommansSearchIndex
	local $i
	local $sSearchedScriptFile
	local $sErrorMsg
	local $k
	local $aImageSplit

	;msg($sRichScript)

	$iSearchStart -= 1

	$sCommandSplit = StringSplit($sNewCommandAll,$_sCommandSplitChar)
	$sCommandStartPosSplit = StringSplit($sNewCommandStartPosAll,$_sCommandSplitChar)
	$sTargetSplit = StringSplit($sNewTargetAll,$_sCommandSplitChar)
	$sTargetStartPosSplit = StringSplit($sNewTargetStartPosAll,$_sCommandSplitChar)
	$sCheckCodeSplit = StringSplit($sNewCheckCodeAll,$_sCommandSplitChar)

	;msg($aScriptPos)

	for $i=1 to ubound($sTargetSplit) -1

		;debug($sCommandSplit[$i])
		;$aTargetPos = _GUICtrlRichEdit_FindTextinRange($oRichText, $sTargetSplit[$i], $aScriptPos[0], $aScriptPos[1])

		if $sTargetStartPosSplit[$i] > 0 then
			_GuiCtrlRichEdit_SetSel($oRichText, $iSearchStart + $sTargetStartPosSplit[$i]  , $iSearchStart + $sTargetStartPosSplit[$i] + stringlen($sTargetSplit[$i]))
			_GuiCtrlRichEdit_SetCharColor($oRichText, $_iColorTarget)
			_GUICtrlRichEdit_SetCharAttributes($oRichText, "+bo")
		endif

	next

	for $i=1 to ubound($sCommandSplit) -1

		if $sCommandStartPosSplit[$i] > 0 then
			;debug($sCommandStartPosSplit[$i])
			_GuiCtrlRichEdit_SetSel($oRichText, $iSearchStart + $sCommandStartPosSplit[$i]  , $iSearchStart + $sCommandStartPosSplit[$i] + stringlen($sCommandSplit[$i]))
			_GuiCtrlRichEdit_SetCharColor($oRichText, $_iColorCommand)
			_GUICtrlRichEdit_SetCharAttributes($oRichText, "+bo")
		endif

	next

endfunc


func _checkRichTextModified()
; 스크립트 편집창이 변경되었는지 확인

	local $bResult

	if StringCompare($_sRichTextModified,  _GuiCtrlRichEdit_getText  ($_gEditScript, False),1) = 0 then


		$bResult = False
	Else

		;debug ("원본 " & _GTGetCurrentIndex(), $_runScriptName, $_sRichTextModified)
		;debug ("수정 " & _GTGetCurrentIndex(), $_runScriptName ,_GuiCtrlRichEdit_getText  ($_gEditScript, False))

		$bResult = True
	endif

	return $bResult

endfunc


func getScriptSelectRange(byref $iStart,byref  $iEnd, $bFullSelect)
; 부분 실행을 위해 블럭이 설정된 범위를 파악하여 시작과 끝을 리턴

	local $sTempRichText
	local $aSelTextPos
	local $sRichText

	$sRichText = _GuiCtrlRichEdit_getText  ($_gEditScript, False)
	$aSelTextPos = _GuiCtrlRichEdit_GetSel($_gEditScript)

	if _GUICtrlRichEdit_IsTextSelected($_gEditScript) = True then
		if IsArray($aSelTextPos) then

			if stringmid($sRichText & " ",$aSelTextPos[0],1) = @cr then
				$aSelTextPos[0] += 1
			endif

			if stringmid($sRichText & " ",$aSelTextPos[1],1) = @cr then
				$aSelTextPos[1] -= 1
			endif

			$sTempRichText = stringleft($sRichText,$aSelTextPos[0])
			StringReplace($sTempRichText,@cr,"")
			$iStart = @extended + 1
			$sTempRichText = stringleft($sRichText,$aSelTextPos[1])
			StringReplace($sTempRichText,@cr,"")
			$iEnd  = @extended + 1
		endif
	Else
		if $bFullSelect = True  then
			$iStart = 0
			$iEnd = 0
		Else
			$iStart = _GuiCtrlRichEdit_GetFirstCharPosOnLine($sRichText,  $aSelTextPos[0])
			$iEnd = $iStart
		endif
	endif

endfunc


; ------------------------------------  화면 캡쳐 실행 준비 ----------------------------------------

func getDefaultCaptureFilename()
; 캡쳐시 기본 사용할 파일명을 저장

	local $i, $j
	local $aDefaultCaptureFileList[1][3]
	local $sCursorTarget
	local $aImageFile
	local $iAddCount = 0
	local $iStartPos, $iEndPos
	;이미지가 없는 파일 목록 (에러에서 걸린것들)
	;msg($_aPreErrorImageTarget)

	$sCursorTarget = getTargetFormRichEdit($_gEditScript, "CURSOR", False, $iStartPos, $iEndPos)

	if checkImageTarget($sCursorTarget) = False then $sCursorTarget = ""

	if $sCursorTarget <> "" then
		if getCommnadImage($sCursorTarget,  $aImageFile, False) = True then
			redim $aDefaultCaptureFileList[2][3]
			$aDefaultCaptureFileList[1][1] = $sCursorTarget
			if ubound($aImageFile) >=  2 then $aDefaultCaptureFileList[1][2] = $aImageFile[1]
		endif
	endif

	if ubound($aDefaultCaptureFileList) = 1 then

		for $i=1 to ubound($_aPreErrorImageTarget) -1
			if _ArraySearch($aDefaultCaptureFileList,$_aPreErrorImageTarget[$i],1,0,0,0,1,1) = -1 then
				$iAddCount += 1
				redim $aDefaultCaptureFileList[$iAddCount + 1][3]
				$aDefaultCaptureFileList[$iAddCount][1] = $_aPreErrorImageTarget[$i]
				$aDefaultCaptureFileList[$iAddCount][2] = ""
			endif
		next
	endif


	;msg($aDefaultCaptureFileList)

	;if $_runErrorImageTarget <> "" then
	;	msg($_runErrorImageTarget)
		;_ArrayAdd($aDefaultCaptureFileList,$_runErrorImageTarget)
	;endif

	;msg($aDefaultCaptureFileList)
	;msg($_aPreAllImageTarget)
	;다시 이미지 전체목록 추가
	;for $i=1 to ubound($_aPreAllImageTarget) -1
	;	_ArrayAdd($aDefaultCaptureFileList,$_aPreAllImageTarget[$i])
	;next

	;msg($aDefaultCaptureFileList)

	;$aDefaultCaptureFileList = _ArrayUnique($aDefaultCaptureFileList,1,1)

	;msg($aDefaultCaptureFileList)
	;msg($_aPreAllImageTarget)

	return $aDefaultCaptureFileList

endfunc


func  checkImageTarget($sName)

	local $i
	local $bImageTarget = False

	for $i=1 to ubound($_aPreAllImageTarget) -1
		if $_aPreAllImageTarget[$i] = $sName then
			$bImageTarget = True
			exitloop
		endif
	next

	return $bImageTarget

endfunc


func addPreErrorImageList($sCheckMessage)
; 에러 발생된 이미지를 배열로 저장

	local $aErrorMsg
	local $i
	local $iFoundLoc
	local $sErrorTarget
	local $aTemp

	$aErrorMsg = stringsplit($sCheckMessage,@lf)

	for $i=1 to ubound ($aErrorMsg) -1
		$iFoundLoc = stringinstr($aErrorMsg[$i], _getLanguageMsg("report_imagenotfound") & " : ")
		if $iFoundLoc > 0  then
			$iFoundLoc = stringinstr($aErrorMsg[$i]," : ",0,1,$iFoundLoc)
			$sErrorTarget = _trim(StringRight($aErrorMsg[$i], stringlen($aErrorMsg[$i]) - $iFoundLoc - 2))
			$aTemp = stringsplit($sErrorTarget,"|")
			_ArrayAdd($_aPreErrorImageTarget, _trim($aTemp[1]))
		endif
	next

endfunc


func checkBrforeSave($sType = "", $bSaveOnly = False)
; 파일 저장여부 확인 하여 필요시 저장 수행
	local $bRet = ""
	local $sFileName = $_runScriptFileName
	local $sNewName = "(" & $_sUntitledName & ")"

	if $sFileName = "" then $sFileName = $sNewName

	;debug($sType)
	if _checkRichTextModified() then
		if $sType  = "C" then
			$bRet = _ProgramQuestionYNC($sFileName & @crlf & @crlf &  _getLanguageMsg("information_save"))
		Else
			$bRet = _ProgramQuestionYN($sFileName & @crlf & @crlf &  _getLanguageMsg("information_save"))
		endif

		if $bRet = "Y" then
			if onClickSave($bSaveOnly) = False Then $bRet = "C"
		endif
	endif

	return $bRet

endfunc


func checkLoadFolder($sFile)

	if stringinstr($sFile, $_runWorkPath) = 0 then
		_RemoteProgrammError(_getLanguageMsg("error_workpath") & @crlf & @crlf & "Workpath : " & $_runWorkPath)
	endif

endfunc


func openLastReportFolder()

	if FileExists($_runWorkReportPath) = 1 then
		ShellExecute($_runWorkReportPath)
	else
		;debug($_runWorkReportPath)
		_ProgramInformation(_getLanguageMsg("error_reportlastpath"))
	endif

endfunc


Func _viewLastUseedImage()
; 최근 사용된 이미지 정보를 화면 하단에 표시함.

	;return true

	local $sLastImageTitle
	local $imghwnd
	local $iImageCount
	local $sTitle

	$iImageCount = ubound($_runLastImageArray) -1

	if $iImageCount > 0 then $sTitle = _getLanguageMsg("report_target") & " : " & $_runLastImageArray[0]
	;CreateNewEmbeddedIEImageViwer()
	;_EmbeddedIEImageView($_gEmbeddedIEImageViwer, $_runLastImageArray, $sTitle)


	;debug("이미지 표시")
	;debug($_runLastImageArray)
	; 이미지 중에 삭제된 것이 있을 경우 listview가 제대로 삭제되지 않아 오브젝트 자체를 삭제하고 생성
	;msg("왔어")
	CreateNewImageViwer()

	_ListViewImageLoad($_gListViewImage, $_gListViewPic, $_runLastImageArray, $_hListViewImage, $_iListViewImageWidth, $_iListViewImageHeight )


EndFunc


func clearLog()
; 화면 정리

	ClearLoglist()

	setStatusBarText($_iSBStatusText, "")

	_setLastImageArrayInit()
	_viewLastUseedImage()

endfunc


func ClearLoglist()

	_GUICtrlRichEdit_SetText  ($_gRichLog, "")

endfunc


func changeLoglistBGColor($bTesting)


	local $iColor

	if $bTesting  then
		$iColor = 0xE1FFE1
	Else
		$iColor = 0xE1FFFF

	endif

	_GUICtrlRichEdit_SetBkColor($_gRichLog, $iColor)

endfunc


func WriteLoglist($sText)
	; 로그창에 로그 남기기
	local $aRichPos, $iColor

	; 에러인 경우 빨간색으로 표시

	_GUICtrlRichEdit_SetFont ($_gRichLog, 9, _getLanguageMsg("font_default"))
	_GUICtrlRichEdit_AppendText($_gRichLog, $sText)

	if checkErrorLog($sText) then
		$iColor = "0x0000ff"
	else
		$iColor = "0x0"
	endif

	;debug( $iTextEnd, _GUICtrlRichEdit_GetTextLength($_gRichLog))

	$aRichPos = _GUICtrlRichEdit_GetSel($_gRichLog)

	_GuiCtrlRichEdit_SetSel($_gRichLog, $aRichPos[1] - Stringlen($sText), $aRichPos[1])

	_GuiCtrlRichEdit_SetCharColor($_gRichLog, $iColor)

	_GUICtrlRichEdit_SetFont ($_gRichLog, 9, _getLanguageMsg("font_default"))

	_GuiCtrlRichEdit_SetSel($_gRichLog, _GUICtrlRichEdit_GetFirstCharPosOnLine($_gRichLog), _GUICtrlRichEdit_GetFirstCharPosOnLine($_gRichLog) )


	_GUICtrlRichEdit_ScrollLines($_gRichLog, _GUICtrlRichEdit_GetLineCount($_gRichLog) -5)

	_GUICtrlRichEdit_ScrollToCaret($_gRichLog)

	;if $iColor = "0x0000ff" then msg("xxx")


endfunc


func checkErrorLog($sText)

	local $bRet = False

	if stringinstr($sText , "> " & $_sLogText_Error) <> 0  or stringinstr($sText , ") " & $_sLogText_Error) <> 0 then $bRet = True

	return $bRet

endfunc

func SelectHotKey ($sType)

	setTestHotKey(False)
	setCaptureHotKey(False)
	setMainHotKey(False)

	Switch $sType

		case "capture"
			setCaptureHotKey(True)

		case "test"
			setTestHotKey(True)

		case "main"
			setMainHotKey(True)

	EndSwitch

endfunc


func setCaptureHotKey($bOn)

	sleep(1)

	if $bOn then
		HotKeySet("{ESC}", "CancelCapture")
		HotKeySet("^+x", "setScreenCaptureMouse")
		HotKeySet("+!x", "setScreenCaptureMouse")
	else
		HotKeySet("{ESC}")
		HotKeySet("^+x")
		HotKeySet("+!x")
	endif

EndFunc


func setFindReplaceHotKey($bOn)

	sleep(1)

	if $bOn then
		HotKeySet("{ESC}", "_FormFindReplaceClose")
	else
		HotKeySet("{ESC}")
	endif

EndFunc


func setTestHotKey($bOn)

	sleep(1)

	if $bOn then
		HotKeySet("{ESC}","TestCancelRequest")
		HotKeySet("{PAUSE}","ScriptRunPause")
	else
		HotKeySet("{ESC}")
		HotKeySet("{PAUSE}")
	endif

EndFunc


func setMainHotKey($bOn)

	sleep(1)

	if $bOn then
		HotKeySet("{TAB}", "_RichEditInsertTab")
	Else
		HotKeySet("{TAB}")
	endif

EndFunc


func runPreRunShell($bFormCheck = True )

	if $bFormCheck and WinActive($_gForm) = 0 then return

	;msg($_runPreRun)

	if $_runPreRun <> "" then RunWait ($_runPreRun,"",@SW_SHOWDEFAULT)

	sleep(1)

endfunc


func viewHelpKey()

	if WinActive($_gForm) = 0 then return

	ShellExecute($_runResourcePath & "\key.htm")

endfunc


Func viewHelp()

	local $i

	if WinActive($_gForm) = 0 then return

	local $sMsg = ""

	$sMsg = $sMsg & _getLanguageMsg("help_default") & @crlf & @crlf & @crlf

	$sMsg = $sMsg & " " & @crlf

	;_ProgramInformation($sMsg)

	ShellExecute("http://dev.naver.com/projects/guitar/download/note/5078")

endfunc


func hotkyeResetBrowserHandle()

	if not WinActive($_gForm) then return

	$_runWebdriver = False
	$_runBrowser = ""
	$_hBrowser = ""
	$_webdriver_current_sessionid =  ""
	$_webdriver_connection_host = ""


	_setCurrentBrowserInfo()

	TrayTip($_sProgramName, _getLanguageMsg("information_reset"),3,1)

	;onClickRetry()

endfunc


func onRunImageSearch()

	if ProcessExists($_sImageSearcher) then
		WinActivate($_sProgramName & " Image Searcher")
	Else
		ShellExecute(@ScriptDir & "\" & $_sImageSearcher)
	endif

endfunc


func runUserFunctionAll($iNumber)

	local $sCommand =  replacePathAlias(getReadINI("User_Function","Function" & $iNumber))

	if $sCommand <> "" then
		RunWait (@ComSpec & " /c " & $sCommand,"",@SW_SHOWDEFAULT)
		_UpdateFolderFileInfo(True)
	else
		_ProgramInformation(_getLanguageMsg("error_usercommand"))
	endif

endfunc

func runUserFunction1()
	runUserFunctionAll("1")
endfunc

func runUserFunction2()
	runUserFunctionAll("2")
endfunc

func runUserFunction3()
	runUserFunctionAll("3")
endfunc

func runUserFunction4()
	runUserFunctionAll("4")
endfunc

func runUserFunction5()
	runUserFunctionAll("5")
	;_ViewSplashText("한글 입니다.")
endfunc


func getTargetFormRichEdit($oRichEdit, $sCheckType , $bPosCheck, byref $iStartPos, byref $iEndPos)

	local $sBlockText
	local $sBlockTextBefore
	local $sBlockPos
	local $iColor
	local $sStarget
	local $iIndexTargetSearch
	local $iIndexTargetStop
	local $iMaxSize = 1024
	local $sTempRichData
	local $sTextDummy
	local $i
	local $iNewLinePos
	local $bErase

	$iStartPos = 0
	$iEndPos = 0

	$sBlockText = _GUICtrlRichEdit_GetSelText($oRichEdit)
	$sBlockPos = _GUICtrlRichEdit_GetSel($oRichEdit)

	;ControlFocus($oRichEdit, "", "")
	;GUICtrlSetState($oRichEdit, $GUI_FOCUS)

	;debug("Text =" & $sBlockText & ", Color =" & hex($iColor))
	;GUICtrlSetData  ($_gLineStatus, ControlCommand($_gForm, "", $_gEditScript, "GetCurrentLine", ""))


	; 일시적으로 값을 읽어오지 못할경우 예외처리
	if IsArray($sBlockPos) = 0 then return  ""


	if $sCheckType = "BLOCK" and  $sBlockText <> "" and $sBlockPos[0] < $sBlockPos [1] then


		;$sTempRichData = _GUICtrlRichEdit_StreamToVar($oRichEdit)
		;_GUICtrlRichEdit_StreamFromVar($_gTempScript,$sTempRichData)
		;;_GUICtrlRichEdit_SetSel($_gTempScript,0,0)
		;$iColor = _GuiCtrlRichEdit_GetCharColor($_gTempScript)

		$iColor = _GuiCtrlRichEdit_GetCharColor($oRichEdit)
		_GUICtrlRichEdit_HideSelection($oRichEdit, False)

		if $_iColorTarget = $iColor then
			$iIndexTargetSearch = 1
			$sBlockText = $sBlockText & " "
			$sBlockText = StringReplace($sBlockText, ",", " ")
			$sBlockText = StringReplace($sBlockText, """", " ")
			$sBlockText = StringReplace($sBlockText, @TAB, " ")
			$sBlockText = StringReplace($sBlockText, @crlf, " ")
			$sBlockText = StringReplace($sBlockText, @cr, " ")
			$sBlockText = StringReplace($sBlockText, @lf, " ")

			$sStarget = getTarget($sBlockText , $iIndexTargetSearch)
		endif

	elseif $sCheckType = "CURSOR" and $sBlockPos[0] = $sBlockPos [1]  then


		;if $_iColorTarget <> $iColor then
		;	_GUICtrlRichEdit_SetSel($oRichEdit, $sBlockPos[0]+1, $sBlockPos[0] +1)
		;	$iColor = _GuiCtrlRichEdit_GetCharColor($oRichEdit)
		;	_GUICtrlRichEdit_SetSel($oRichEdit, $sBlockPos[0], $sBlockPos[0])
		;	_GUICtrlRichEdit_HideSelection($oRichEdit, False)
		;endif
		;debug(" 왔어 포커스가 있을 경우에만 검사할것 " )

		$iColor = _GuiCtrlRichEdit_GetCharColor($oRichEdit)
		_GUICtrlRichEdit_HideSelection($oRichEdit, False)

		if $_iColorTarget = $iColor then

			;debug($sBlockPos)
			$sBlockText =  _GUICtrlRichEdit_GetTextInRange($oRichEdit, $sBlockPos[0],$sBlockPos[0] + $iMaxSize )
			;debug("$sBlockTextBefore0 =" & $sBlockPos[0] , $iMaxSize)

			if $sBlockPos[0] > $iMaxSize then
				$sBlockTextBefore =  _GUICtrlRichEdit_GetTextInRange($oRichEdit, $sBlockPos[0] - $iMaxSize, $sBlockPos[0]  )
				;debug("$sBlockTextBefore1 =" & $sBlockTextBefore)
			Else
				$sBlockTextBefore =  _GUICtrlRichEdit_GetTextInRange($oRichEdit, 0, $sBlockPos[0] )
			endif

			$iNewLinePos = StringInStr ($sBlockTextBefore,@cr,0,-1,stringlen($sBlockTextBefore))

			$sBlockTextBefore = StringTrimLeft($sBlockTextBefore,$iNewLinePos)

			;debug($sBlockTextBefore)

			$sBlockTextBefore = StringReplace($sBlockTextBefore, """", """")

			if mod(number(@extended),2) = 1 then
				$bErase = False
			Else
				$bErase = True
			endif

			;debug($bErase)


			if $sBlockTextBefore = False then $sBlockTextBefore = ""

			$sBlockTextBefore = " " & $sBlockTextBefore
			$sBlockTextBefore = StringReplace($sBlockTextBefore, ",", " ")
			$sBlockTextBefore = StringReplace($sBlockTextBefore, """", " ")
			$sBlockTextBefore = StringReplace($sBlockTextBefore, @TAB, " ")
			$sBlockTextBefore = StringReplace($sBlockTextBefore, @crlf, " ")
			$sBlockTextBefore = StringReplace($sBlockTextBefore, @cr, " ")
			$sBlockTextBefore = StringReplace($sBlockTextBefore, @lf, " ")

			$iIndexTargetStop = Stringinstr($sBlockTextBefore, " ",0,-1,StringLen($sBlockTextBefore))

			;debug("$sBlockTextBefore =" & $sBlockTextBefore)
			;debug("$iIndexTargetStop =" & $iIndexTargetStop & ", len =" & StringLen($sBlockTextBefore))

			$sBlockTextBefore = StringTrimLeft($sBlockTextBefore, $iIndexTargetStop)

			$sBlockText = $sBlockTextBefore & $sBlockText & " "
			$sBlockText = StringReplace($sBlockText, ",", " ")
			$sBlockText = StringReplace($sBlockText, """", " ")
			$sBlockText = StringReplace($sBlockText, @TAB, " ")
			$sBlockText = StringReplace($sBlockText, @crlf, " ")
			$sBlockText = StringReplace($sBlockText, @cr, " ")
			$sBlockText = StringReplace($sBlockText, @lf, " ")

			$iIndexTargetStop = Stringinstr($sBlockText, " ")
			$sBlockText = StringLeft($sBlockText, $iIndexTargetStop)

			$iIndexTargetSearch = 1
			$sStarget = getTarget($sBlockText, $iIndexTargetSearch, $bErase)
		endif

	endif

	if $sStarget <> "" and $bPosCheck = True then

		for $i=1 to stringlen($sStarget)

			$sTextDummy =  _GUICtrlRichEdit_GetTextInRange($oRichEdit, $sBlockPos[0] - $i, $sBlockPos[0] - $i + stringlen($sStarget)+1)

			;debug($sTextDummy)

			$iStartPos = stringinstr($sTextDummy, $sStarget)

			if $iStartPos <> 0 then
				$iStartPos = $sBlockPos[0] - $i
				$iEndPos = $iStartPos + stringlen($sStarget)
				exitloop
			endif
		next

		;debug($iIndexTargetSearch, $iStartPos, $iEndPos)

	endif


	return $sStarget

endfunc


func RealTimeTargetCheck($bForceCheck, byref $iStartPos, byref $iEndPos)

	local $sNewTarget
	local $aImageFile

	if WinActive($_gForm) = 0 then return

	_GTRichEditModifiedCheck ()

	$sNewTarget  = getTargetFormRichEdit($_gEditScript,"CURSOR", $bForceCheck, $iStartPos, $iEndPos )

	;debug($sNewTarget)

	;블럭 포인터가 1초 이상 동일한 곳에 있을 경우 실행

	; 타겟이 이미지인 경우
	if $sNewTarget <> "" then
		if $sNewTarget  = $_sRealTimeTargetLast[1] then
			if (_TimerDiff($_sRealTimeTargetLast[2]) > 1000 and $_sRealTimeTargetLast[3] = False) or $bForceCheck = True then
				$_sRealTimeTargetLast[3] = True
				;debug("이미지 전체 갯수 : " & $_sImageForderFileList)
				if getCommnadImage($_sRealTimeTargetLast[1],  $aImageFile, False) = True then
					;debug($_sRealTimeTargetLast[1])
					;debug($aImageFile)


					$_runLastImageArray = $aImageFile
					$_runLastImageArray [0] = $_sRealTimeTargetLast[1]

				Else
					;debug("이미지 찾지 못함 Target = " & $_sRealTimeTargetLast[1])
					redim $aImageFile[1]
					$_runLastImageArray = $aImageFile
					$_runLastImageArray [0] = ""

				endif

				_viewLastUseedImage()

			endif
		else
			$_sRealTimeTargetLast[1] = $sNewTarget
			$_sRealTimeTargetLast[2] = _TimerInit()
			$_sRealTimeTargetLast[3] = False
		endif
	Else
		RealTimeTargetCheckReset()
	endif


endfunc

func RealTimeTargetCheckReset()

	$_sRealTimeTargetLast[1] = ""
	$_sRealTimeTargetLast[2] = 0
	$_sRealTimeTargetLast[3] = False

endfunc


func saveTotalReport($sSummryReportFile, $iTSScriptName, $iTSID, $iTSDate, $ITSTime,  $iTSResult, $iTSAllCount, $iTSRun,  $iTSErrorCount, $iTSLink, $aRunReportInfo, $bSimple)

	local $aTestSummry [$_iTSEnd]

	;$aTestSummry [$_iTSScriptName] = _GetFileName(FileGetLongName(_GetPathName(_GetPathName($iTSScriptName))))
	$aTestSummry [$_iTSScriptName] = $iTSScriptName
	$aTestSummry [$_iTSID] = $iTSID
	$aTestSummry [$_iTSDate] = $iTSDate
	$aTestSummry [$_iTSTime] = $ITSTime
	$aTestSummry [$_iTSResult] = $iTSResult
	$aTestSummry [$_iTSAllCount] = $iTSAllCount
	$aTestSummry [$_iTSRun] = $iTSAllCount
	$aTestSummry [$_iTSErrorCount] = $iTSErrorCount
	$aTestSummry [$_iTSNotRun] = $iTSAllCount - $iTSRun


	$aTestSummry [$_iTSRIAll] = $aRunReportInfo[$_iResultAll]
	$aTestSummry [$_iTSRIRun] = $aRunReportInfo[$_iResultRun]
	$aTestSummry [$_iTSRIPass] = $aRunReportInfo[$_iResultPass]
	$aTestSummry [$_iTSRIFail] = $aRunReportInfo[$_iResultFail]
	$aTestSummry [$_iTSRINotRun] = $aRunReportInfo[$_iResultNotRun]
	$aTestSummry [$_iTSRISkip] = $aRunReportInfo[$_iResultSkip]

	$aTestSummry [$_iTSLink] = $iTSLink

	;debug($aTestSummry[$_iTSAllCount] )

	_addNewTestResult($sSummryReportFile, $aTestSummry,  getReadINI("Report","LimitCount"), $bSimple)

endfunc

Func ScriptRunPause()

	local $iTimer = _TimerInit()

	;debug("왔어")

	; 테스트가 실행중이지 않을 때에는 무시하고 넘어감
	if $_bScriptRunning = False then return

	$_bScriptRunPaused = not $_bScriptRunPaused

	if checkScriptStopping() then $_bScriptRunPaused = False

	if not $_bScriptRunPaused then
		TrayTip($_sProgramName, _getLanguageMsg("tray_resumetest"), 3, 1)
	else

		$iTimer = ""

		While $_bScriptRunPaused
			Sleep(1000)

			if checkScriptStopping() then
				ScriptRunPause()
				return
			endif

			if _TimerDiff($iTimer) > 10 * 1000  or $iTimer = "" then
				TrayTip($_sProgramName, _getLanguageMsg("tray_pausetest"),3,1)
				$iTimer = _TimerInit()
			endif
		WEnd
	endif

EndFunc

func _ProcessKillforIE($sList)

	local $i
	local $aList = StringSplit($sList,";")

	for $i=1 to ubound($aList) - 1

		$aList[$i] = _trim($aList[$i])

		While ProcessExists($aList[$i]) <> 0 and $aList[$i] <> ""
			ProcessClose($aList[$i])
		WEnd
	next

endfunc


func checkIEUseClearType()

	if RegRead("HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main","UseClearType") = "yes" then
		_ProgramInformation(_getLanguageMsg("information_cleartype"))
	endif

EndFunc


func checkUACSetting()

	local $bError = True
	local $bRegValue

	$bRegValue = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System","EnableLUA")

	if $bRegValue <> "0" and $bRegValue <> "" then

		if _ProgramQuestionYN(_getLanguageMsg("information_uac")) ="N" then $bError = False

	endif

	return $bError

EndFunc


func onClipboardOpen()

	local $sScript, $sLine
	local $sClip
	local $sNewScript
	local $asFullScriptFile[1]

	$sClip = _Trim(ClipGet())

	getScriptFileIDLIneFromClipboard ($sClip, $sScript, $sLine)

	if $sScript <> "" then

		;debug($sScript, $sLine)
		; 클립보드에 잘못된 형태로 존재 할 경우
		_ViewSplashText(_getLanguageMsg("tray_filefound") & @crlf & @crlf & _getLanguageMsg("tray_scriptname") & " : " & $sScript & _iif($sLine <> "", ", Line : " & $sLine, ""))


		GUISetState (@SW_DISABLE,$_gForm)
		;GUISetState (@SW_LOCK,$_gForm)
		;TrayTip($_sProgramName, "클립보드 파일 열기, 파일 찾는 중... : " & $sClip,10)

		if stringright($sScript,4) =  $_cScriptExt then
			$sScript = StringTrimright($sScript, 4)
		endif

		$sNewScript = _GetFileNameFromDir($_runScriptPath, $sScript & $_cScriptExt , 1)

		if $sNewScript = "" or ubound($sNewScript) = 1 then
			$sNewScript = _GetFileNameFromDir($_runCommonScriptPath, $sScript & $_cScriptExt , 1)
		endif
		;TrayTip($_sProgramName,"",0)
		GUISetState (@SW_ENABLE,$_gForm)
		_ViewSplashText("")
		;msg($sNewScript)

		if $sNewScript <> "" and ubound($sNewScript) > 1  then

			if ubound($sNewScript) > 1 then
				$asFullScriptFile = $sNewScript
			Else
				_ArrayAdd($asFullScriptFile,$sNewScript)
			endif

		endif

		;debug($sFullScriptFile)

		for $i=1 to ubound ($asFullScriptFile) -1

			loadScript ($asFullScriptFile[$i])

			if $sLine > 0 then _gotoRichEditLine($sLine, False)
		next

	endif

	if ubound ($asFullScriptFile) = 1 then _ProgramError(_getLanguageMsg("information_quicksearch"))

endfunc



func HudsonDateTimeConvert($sDate)

	local $aSplit = StringSplit($sDate, "_")
	local $sRet, $i

	for $i=1 to ubound($aSplit) -1

		$sRet &= StringReplace($aSplit[$i],"-",_iif($i=1,"/",":")) & " "

	next

	$sRet = _Trim($sRet)

	if _DateTimeFormat($sRet, 5) = "" then $sRet = ""

	return $sRet

endfunc


func _RemoteProgrammError($str)

	local $sText = "Error : "

	if $_runCmdRemote = False then
		_ProgramError($str)
	else
		writeRmoteLog($sText & $str )
		ConsoleWrite($sText & $str & @crlf)
	endif

endfunc


func _ScriptCommentSet()

	local $iLineStart, $iLineEnd
	local $iCharStart, $iCharEnd
	local $sText
	local $aText
	local $iCommentStart
	local $bReSetComment = False

	getScriptSelectRange($iLineStart, $iLineEnd, False)

	if $iLineStart = 0 and $iLineEnd = 0 then

		$iLineStart = ControlCommand($_gForm, "", $_gEditScript, "GetCurrentLine", "")
		$iLineEnd = $iLineStart

	endif

	;debug($iLineStart, $iLineEnd)

	$iCharStart = _GuiCtrlRichEdit_GetFirstCharPosOnLine($_gEditScript, $iLineStart)
	$iCharEnd = _GuiCtrlRichEdit_GetFirstCharPosOnLine($_gEditScript, $iLineEnd) + _GUICtrlRichEdit_GetLineLength($_gEditScript, $iLineEnd)

	;debug($iCharStart, $iCharEnd)
	_GUICtrlRichEdit_Setsel($_gEditScript, $iCharStart, $iCharEnd)

	$sText = _GUICtrlRichEdit_GetSelText($_gEditScript)

	$aText = StringSplit($sText, @cr)


	if stringleft(_Trim($sText),1) = ";" then  $bReSetComment = True

	for $i=1 to ubound($aText) -1

		if $bReSetComment then

			if stringleft(_Trim($aText[$i]),2) = ";#" then
				$iCommentStart = StringInStr($aText[$i],";#")
				$aText[$i] = StringTrimleft($aText[$i], $iCommentStart+1)
			endif

			if stringleft(_Trim($aText[$i]),1) = ";" then
				$iCommentStart = StringInStr($aText[$i],";")
				$aText[$i] = StringTrimleft($aText[$i], $iCommentStart)
			endif

		else
			if stringleft(_Trim($aText[$i]),1) <> ";" then $aText[$i] = ";" & $aText[$i]

		endif

	next

	$sText = _ArrayToString($aText,@cr,1,0)

	_GUICtrlRichEdit_ReplaceText($_gEditScript, $sText,true )

	$iCharEnd = _GuiCtrlRichEdit_GetFirstCharPosOnLine($_gEditScript, $iLineEnd) + _GUICtrlRichEdit_GetLineLength($_gEditScript, $iLineEnd)

	_GUICtrlRichEdit_Setsel($_gEditScript, $iCharStart, $iCharEnd)

endfunc




func onClickXPathVerify()

	local $sScriptTarget
	local $aImageFile
	local $x, $y
	local $bResult
	local $bFileNotFoundError
	local $aShotXpathList
	local $sElementID
	local $i
	local $sResultText

	local $sClip
	local $sReturnXpath


	ClearLoglist()

	$sClip = _Trim(String(ClipGet()))

	$_runErrorMsg = ""
	writeRunLog ($_sLogText_Info  & "Xpath 재검증 시작 : "  & $sClip )

	if stringleft($sClip, 2) <> "//" and stringleft($sClip, 5) <> "/html"  then
		writeRunLog ($_sLogText_Error  & "클립보드 문자열이 내용이 Xpath 형태가 아닙니다." )
		return
	endif

	$sScriptTarget = "{xpath:" & $sClip & "}"
	$sReturnXpath = $sScriptTarget

	setTestHotKey(True)
	$_bScriptStopping = False
	$bResult = getRunCommnadImageAndSearchTarget ($sScriptTarget, $aImageFile,  $x , $y, True, 5, $bFileNotFoundError)
	setTestHotKey(False)

	if $bResult then

		$sElementID = $x
		$bResult = _WD_XpathGetShotPathlist($sElementID,  $aShotXpathList)
		if $bResult then
			writeRunLog ($_sLogText_Info  & "사용 가능한 Xpath 확인 : "  & ubound($aShotXpathList)-1 & "개" )
			for $i=1 to ubound($aShotXpathList)-1
				writeRunLog ($_sLogText_Info  & '"{xpath:' & $aShotXpathList [$i] & '}"')
			next

			$sReturnXpath = '"{xpath:' & $aShotXpathList[1] & '}"'
		Else
			writeRunLog ($_sLogText_Error  & "추가로 사용가능한 Xpath를 찾을 수 없습니다.")
		endif
		ClipPut($sReturnXpath & " ")
		_GUICtrlRichEdit_Paste($_gEditScript )
		ClipPut($sClip)
	else
		writeRunLog ($_sLogText_Error  & "대상을 찾을 수 없습니다.")
		writeRunLog ($_sLogText_Error  & $_runErrorMsg)
	endif

	writeRunLog ($_sLogText_Info  & "Xpath 재검증 종료"  )

	setStatusText ("")

endfunc