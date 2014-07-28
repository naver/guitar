#include-once

Global enum $_iScriptCheckIDOK = 0 , $_iScriptCheckIDCommnadNotFound , $_iScriptCheckIDImageNotFound, $_iScriptCheckIDIncludeFileNotFound , $_iScriptCheckIDTargetNotFound, $_iScriptCheckIDUnknownError
Global enum $_iScriptAllCheckOK = 0, $_iScriptAllCheckError , $_iScriptAllCheckSkip, $_iScriptAllCheckComment

Global enum $_iScriptRaw, $_iScriptCheck, $_iScriptCheckMessage, $_iScriptCommand, $_iScriptCommandStartPos,  $_iScriptPrimeCommand, $_iScriptTarget, $_iScriptTargetStartPos,  $_iScriptCheckCode, $_iScriptLine, $_iScriptEnd

Global enum $_iCommandName, $_iCommandText, $_iCommandEnd
Global enum $_iImageCacheName = 1, $_iImageCacheResult, $_iImageCacheList

Global enum $_iVarName = 1 , $_iVarValue, $_iVarCount, $_iVarFile

Global Const $_sCommandBrowserRun = "BrowserRun"
Global Const $_sCommandBrowserEnd = "BrowserEnd"
Global Const $_sCommandNavigate = "Navigate"
Global Const $_sCommandClick = "Click"
Global Const $_sCommandInput = "Input"
Global Const $_sCommandAttach = "Attach"
Global Const $_sCommandAssert = "Assert"
Global Const $_sCommandIf = "If"
Global Const $_sCommandIfNot = "IfNot"
Global Const $_sCommandTextAsert = "TextAsert"
Global Const $_sCommandTextIf = "TextIf"
Global Const $_sCommandTextIfNot = "TextIfNot"
Global Const $_sCommandInclude = "Include"
Global Const $_sCommandSet = "Set"
Global Const $_sCommandSleep = "Sleep"
Global Const $_sCommandKeySend = "KeySend"
Global Const $_sCommandMouseMove ="MouseMove"
Global Const $_sCommandMouseDrag ="MouseDrag"
Global Const $_sCommandMouseDrop ="MouseDrop"
Global Const $_sCommandRightClick ="RightClick"
Global Const $_sCommandSuccess = "Success"
Global Const $_sCommandFail = "Fail"
Global Const $_sCommandCapture = "Capture"
Global Const $_sCommandMouseHide = "MouseHide"
Global Const $_sCommandMouseWheelUp = "MouseWheelUp"
Global Const $_sCommandMouseWheelDown = "MouseWheelDown"
Global Const $_sCommandDoubleClick = "DoubleClick"
Global Const $_sCommandComma = "Comma"
Global Const $_sCommandValueIf = "ValueIf"
Global Const $_sCommandValueIfNot = "ValueIfNot"
Global Const $_sCommandExcute = "Excute"
Global Const $_sCommandSwipe = "Swipe"
Global Const $_sCommandGoHome = "GoHome"
Global Const $_sCommandBlockStart = "BlockStart"
Global Const $_sCommandBlockEnd = "BlockEnd"
Global Const $_sCommandLoop = "Loop"
Global Const $_sCommandSplitChar = @cr
Global Const $_sCommandListSplitChar = "|"
Global Const $_sCommandImageSearchSplitChar = chr(1)
Global Const $_sCommandFullScreenWork = "FullScreenWork"
Global Const $_sCommandAreaCapture = "AreaCapture"
Global Const $_sCommandVariableSet = "VariableSet"
Global Const $_sCommandTagAttribGet = "TagAttribGet"
Global Const $_sCommandTagAttribSet = "TagAttribSet"
Global Const $_sCommandAreaWork = "AreaWork"
Global Const $_sCommandPartSet = "PartSet"
Global Const $_sCommandLogWrite = "LogWrite"
Global Const $_sCommandSingleQuotationChange = "SingleQuotationChange"
Global Const $_sCommandAU3Run = "AU3Run"
Global Const $_sCommandAU3VarRead = "AU3VarRead"
Global Const $_sCommandAU3VarWrite = "AU3VarWrite"
Global Const $_sCommandProcessAttach = "ProcessAttach"
Global Const $_sCommandLongTab = "LongTab"
Global Const $_sCommandLocationTab = "LocationTab"
Global Const $_sCommandLocationLongTab = "LocationLongTab"
Global Const $_sCommandLocationDoubleTab  = "LocationDoubleTab"
Global Const $_sCommandTargetCapture = "TargetCapture"
Global Const $_sCommandTagCountGet = "TagCountGet"
Global Const $_sCommandJSRun = "JSRun"
Global Const $_sCommandJSInsert = "JSInsert"
Global Const $_sCommandWDSessionCreate = "WDSessionCreate"
Global Const $_sCommandWDSessionDelete = "WDSessionDelete"
Global Const $_sCommandWDAcceptAlert = "WDAcceptAlert"
Global Const $_sCommandWDDismissAlert = "WDDismissAlert"

Global Const $_sCommandWDNavigateBack = "WDNavigateBack"
Global Const $_sCommandWDNavigateForward = "WDNavigateForward"
Global Const $_sCommandWDNavigateRefresh = "WDNavigateRefresh"


Global Const $_sScriptFileExt = ".txt"

Global $_aCommandText
Global $_aCommandSplitText
Global $_aTargetExcludeText


#include "UIACommon.au3"
#include "UIARun.au3"

func _setCommonVar()
; 초기 공용 변수 읽기
	local $i, $aOther, $aOtherItem

	setWriteINI("environment", "StopRequest", "0")

	$aOther = StringSplit(getReadINI("BROWSER", "OTHER"),"|")

	redim $_aBrowserOTHER [ubound($aOther)][3]

	if ubound($aOther) > 1 and $aOther[1] <> "" then
		for $j=1 to ubound($aOther)-1
			$aOtherItem = StringSplit($aOther[$j],":")
			$_aBrowserOTHER[$j][1] = $aOtherItem[1]
			$_aBrowserOTHER[$j][2] = $aOtherItem[2]

		next

		;msg($_aBrowserOTHER)
	endif

	; 신규 추가되는 INI의 기본 값을 설정함.
	if getReadINI("Environment","ImageCapture") = "" then setWriteINI("environment", "ImageCapture", "True")
	if getReadINI("Environment","TrayToolTip ") = "" then setWriteINI("environment", "TrayToolTip ", "True")
	if getReadINI("HTML_TAG","HighlightDelay") = "" then setWriteINI("HTML_TAG", "HighlightDelay", "500")
	if getReadINI("Environment","ErrorResumeLevel") = "" then setWriteINI("Environment", "ErrorResumeLevel", "SCRIPT")
	if getReadINI("ALARM","EmailSummary") = "" then setWriteINI("ALARM", "EmailSummary", "True")
	if getReadINI("environment","ErrorLineSelect") = "" then setWriteINI("environment", "ErrorLineSelect", "True")
	if getReadINI("environment","VerifyTime") = "" then setWriteINI("environment", "VerifyTime", "200")
	if getReadINI("BROWSER","OTHER") = "" then setWriteINI("BROWSER", "OTHER", "AVD:emulator.exe|VNC:vncviewer.exe")
	if getReadINI("Report","XMLReport") = "" then setWriteINI("Report", "XMLReport", "False")

	if getReadINI("SCRIPT","WorkPath") = "" then
		if getReadINI("SCRIPT","ScriptPath") <> "" then
			setWriteINI("SCRIPT", "WorkPath", StringReplace(getReadINI("SCRIPT","ScriptPath"),"\TestCase", "" ))
		endif
	endif

	; 시스템 언어 리소스 읽기
	_loadLanguageResource(_loadLanguageFile(getReadINI("Environment","Language")))
	_loadTestCaseHeaderText()


	_setCommonPathVar()


	$_runPreRun = replacePathAlias(getReadINI("SCRIPT","PreRun"))

	$_aCommandText = getCommandText()
	$_aCommandSplitText = getCommandSplitText()

	$_aTargetExcludeText = getTargetExcludeList()

	$_runTrayToolTip = getIniBoolean(getReadINI("Environment","TrayToolTip "))
	$_runFullSizeImage = getIniBoolean(getReadINI("Report","FullSizeImage"))
	$_runComputerName = getReadINI("Report","TestServerName")
	$_runCommandSleep = getReadINI("environment","CommandSleep")
	$_runVerifyTime = number(getReadINI("environment","VerifyTime"))
	$_runErrorResume = getReadINI("Environment","ErrorResumeLevel")

	; 에러시 재 실행 단위를 기본 "SCRIPT" 로 지정
	if $_runErrorResume <> "LINE" AND $_runErrorResume <> "TEST"  then $_runErrorResume = "SCRIPT"

	$_runPageSleep = getReadINI("environment","PageSleep")
	$_runWaitTimeOut = getReadINI("environment","TimeOut")
	$_runMouseDelay = getReadINI("environment","MouseDelay")
	$_runTolerance = getReadINI("environment","MaxImageTolerance")
	$_runCommaDelay = getReadINI("environment","CommaDelay")
	$_runDebugLog = getIniBoolean(getReadINI("environment","DebugLog"))
	$_runAlwaysImageEdit = getIniBoolean(getReadINI("environment","AlwaysImageEdit"))
	$_runImageEditor = getReadINI("environment","ImageEditor")
	$_runUnknowWindowList = getReadINI("environment","UnknowWindowList")
	$_runScriptErrorCheck = getIniBoolean(getReadINI("Environment","ScriptErrorCheck"))
	$_runPreCheck = getIniBoolean(getReadINI("Environment","PreCheck"))
	$_runMouseMoveSleep = getIniBoolean(getReadINI("Environment","MouseMoveSleep"))
	$_runAVICapture = getIniBoolean(getReadINI("Environment","AVICapture"))
	$_runRunningToolTip = getIniBoolean(getReadINI("Environment","RunningToolTip"))
	$_runRunningImageCapture = getIniBoolean(getReadINI("Environment","ImageCapture"))
	$_runErrorLineSelect = getIniBoolean(getReadINI("environment","ErrorLineSelect"))

	$_runHTMLTimeColor  = getIniBoolean(getReadINI("Report","HTMLTimeColor"))
	$_runXMLReport  = getIniBoolean(getReadINI("Report","XMLReport"))

	$_runBrowserWidth = Number(getReadINI("BROWSER","BrowserWidth"))
	$_runBrowserHeight = Number(getReadINI("BROWSER","BrowserHeight"))


	$_runReportPath = getRelativePath(getReadINI("Report","path"), @ScriptDir)
	$_runMultiImageRange = getReadINI("environment","MultiImageRange")

	$_runHighlightDelay = Number(getReadINI("HTML_TAG","HighlightDelay"))

	$_runResourcePath = @ScriptDir & "\Resource"
	$_runAVITempPath = @ScriptDir & "\AVI"

	if $_runComputerName = "" then $_runComputerName = @ComputerName

	_ProcessKillforIE(getReadINI("environment","ProcessKillList"))

	if $_runReportPath = "" then
		_ProgramError(_getLanguageMsg("error_reportpath") & " : " & getReadINI("Report","path"))
		exit(1)
	endif

	if number($_runCommaDelay) = 0 then $_runCommaDelay = 1000

	if $_runImageEditor = "" or FileExists($_runImageEditor) = 0 then $_runImageEditor = "mspaint.exe"

	;$_sDebugLogFile = $_runReportPath & "\" & "running_debug.log"
	$_sDebugLogFile = $_runReportPath & "\" & "running_debug_" & _GetLogDateTime() & ".log"


	$_sRunningLogFile = $_runReportPath & "\" & "running.log"
	$_sReportLogFile = $_runReportPath & "\" & "running_report.log"
	$_sErrorSumarryFile = $_runReportPath & "\" & "errorsummary.txt"

	SetKeyDelay()

	_setReportHtmlFile()

	;debug($_runDebugLog)

endfunc


func replacePathAlias($sStr)

	$sStr = stringreplace($sStr, "%WORKPATH%", $_runWorkPath)
	$sStr = stringreplace($sStr, "%SVNPATH%", $_runSVNPath)
	$sStr = stringreplace($sStr, "%BINPATH%", @ScriptDir)

	;debug($sStr)

	return $sStr

endfunc


func getCommandText()
; 명령어 전체를 배열로 추가

	local $aCommandList[100][$_iCommandEnd]
	local $iCommandCount

	$iCommandCount = 0

	addCommandList($iCommandCount, $_sCommandClick, $aCommandList, _getLanguageMsg("Command_Click"))
	addCommandList($iCommandCount, $_sCommandAssert, $aCommandList, _getLanguageMsg("Command_Assert"))
	addCommandList($iCommandCount, $_sCommandInclude, $aCommandList, _getLanguageMsg("Command_Include"))
	addCommandList($iCommandCount, $_sCommandSet, $aCommandList, _getLanguageMsg("Command_Set"))
	addCommandList($iCommandCount, $_sCommandSleep, $aCommandList, _getLanguageMsg("Command_Sleep"))
	addCommandList($iCommandCount, $_sCommandComma , $aCommandList, _getLanguageMsg("Command_Comma"))
	addCommandList($iCommandCount, $_sCommandNavigate, $aCommandList, _getLanguageMsg("CommandNavigate"))
	addCommandList($iCommandCount, $_sCommandAttach, $aCommandList, _getLanguageMsg("Command_Attach"))

	addCommandList($iCommandCount, $_sCommandInput, $aCommandList, _getLanguageMsg("Command_Input"))
	addCommandList($iCommandCount, $_sCommandBrowserRun, $aCommandList, _getLanguageMsg("Command_BrowserRun"))
	addCommandList($iCommandCount, $_sCommandBrowserEnd, $aCommandList, _getLanguageMsg("Command_BrowserEnd"))

	addCommandList($iCommandCount, $_sCommandIf, $aCommandList, _getLanguageMsg("Command_If"))
	addCommandList($iCommandCount, $_sCommandIfNot, $aCommandList, _getLanguageMsg("Command_IfNot"))
	addCommandList($iCommandCount, $_sCommandTextAsert, $aCommandList, _getLanguageMsg("Command_TextAsert"))
	addCommandList($iCommandCount, $_sCommandTextIf, $aCommandList, _getLanguageMsg("Command_TextIf"))
	addCommandList($iCommandCount, $_sCommandTextIfNot, $aCommandList, _getLanguageMsg("Command_TextIfNot"))

	addCommandList($iCommandCount, $_sCommandKeySend, $aCommandList, _getLanguageMsg("Command_KeySend"))
	addCommandList($iCommandCount, $_sCommandMouseMove, $aCommandList, _getLanguageMsg("Command_MouseMove"))
	addCommandList($iCommandCount, $_sCommandMouseDrag, $aCommandList, _getLanguageMsg("Command_MouseDrag"))
	addCommandList($iCommandCount, $_sCommandMouseDrop, $aCommandList, _getLanguageMsg("Command_MouseDrop"))
	addCommandList($iCommandCount, $_sCommandRightClick, $aCommandList, _getLanguageMsg("Command_RightClick"))
	addCommandList($iCommandCount, $_sCommandSuccess, $aCommandList, _getLanguageMsg("Command_Success"))
	addCommandList($iCommandCount, $_sCommandFail, $aCommandList, _getLanguageMsg("Command_Fail"))
	addCommandList($iCommandCount, $_sCommandCapture, $aCommandList, _getLanguageMsg("Command_Capture"))
	addCommandList($iCommandCount, $_sCommandMouseHide, $aCommandList, _getLanguageMsg("Command_MouseHide"))
	addCommandList($iCommandCount, $_sCommandMouseWheelUp , $aCommandList, _getLanguageMsg("Command_MouseWheelUp"))
	addCommandList($iCommandCount, $_sCommandMouseWheelDown , $aCommandList, _getLanguageMsg("Command_MouseWheelDown"))
	addCommandList($iCommandCount, $_sCommandDoubleClick , $aCommandList, _getLanguageMsg("Command_DoubleClick"))
	addCommandList($iCommandCount, $_sCommandExcute , $aCommandList, _getLanguageMsg("Command_Excute"))
	addCommandList($iCommandCount, $_sCommandValueIfNot , $aCommandList, _getLanguageMsg("Command_ValueIfNot"))
	addCommandList($iCommandCount, $_sCommandValueIf , $aCommandList, _getLanguageMsg("Command_ValueIf"))

	addCommandList($iCommandCount, $_sCommandSwipe , $aCommandList, _getLanguageMsg("Command_Swipe"))
	addCommandList($iCommandCount, $_sCommandGoHome , $aCommandList, _getLanguageMsg("Command_GoHome"))
	addCommandList($iCommandCount, $_sCommandBlockStart , $aCommandList, _getLanguageMsg("Command_BlockStart"))
	addCommandList($iCommandCount, $_sCommandBlockEnd , $aCommandList, _getLanguageMsg("Command_BlockEnd"))
	addCommandList($iCommandCount, $_sCommandLoop , $aCommandList, _getLanguageMsg("Command_Loop"))

	addCommandList($iCommandCount, $_sCommandFullScreenWork , $aCommandList, _getLanguageMsg("Command_FullScreenWork"))
	addCommandList($iCommandCount, $_sCommandAreaCapture , $aCommandList, _getLanguageMsg("Command_AreaCapture"))
	addCommandList($iCommandCount, $_sCommandVariableSet , $aCommandList, _getLanguageMsg("Command_VariableSet"))
	addCommandList($iCommandCount, $_sCommandTagAttribGet , $aCommandList, _getLanguageMsg("Command_TagAttribGet"))
	addCommandList($iCommandCount, $_sCommandTagAttribSet , $aCommandList, _getLanguageMsg("Command_TagAttribSet"))

	addCommandList($iCommandCount, $_sCommandAreaWork , $aCommandList, _getLanguageMsg("Command_AreaWork"))
	addCommandList($iCommandCount, $_sCommandPartSet , $aCommandList, _getLanguageMsg("Command_PartSet"))
	addCommandList($iCommandCount, $_sCommandLogWrite , $aCommandList, _getLanguageMsg("Command_LogWrite"))

	addCommandList($iCommandCount, $_sCommandSingleQuotationChange , $aCommandList, _getLanguageMsg("Command_SingleQuotationChange"))

	addCommandList($iCommandCount, $_sCommandAU3Run , $aCommandList, _getLanguageMsg("Command_AU3Run"))
	addCommandList($iCommandCount, $_sCommandAU3VarRead , $aCommandList, _getLanguageMsg("Command_AU3VarRead"))
	addCommandList($iCommandCount, $_sCommandAU3VarWrite , $aCommandList, _getLanguageMsg("Command_AU3VarWrite"))

	addCommandList($iCommandCount, $_sCommandProcessAttach , $aCommandList, _getLanguageMsg("Command_ProcessAttach"))
	addCommandList($iCommandCount, $_sCommandLongTab , $aCommandList, _getLanguageMsg("Command_LongTab"))
	addCommandList($iCommandCount, $_sCommandLocationTab , $aCommandList, _getLanguageMsg("Command_LocationTab"))
	addCommandList($iCommandCount, $_sCommandLocationLongTab , $aCommandList, _getLanguageMsg("Command_LocationLongTab"))
	addCommandList($iCommandCount, $_sCommandLocationDoubleTab , $aCommandList, _getLanguageMsg("Command_LocationDoubleTab"))

	addCommandList($iCommandCount, $_sCommandTargetCapture, $aCommandList, _getLanguageMsg("Command_TargetCapture"))

	addCommandList($iCommandCount, $_sCommandTagCountGet , $aCommandList, _getLanguageMsg("Command_TagCountGet"))

	addCommandList($iCommandCount, $_sCommandJSRun  , $aCommandList, _getLanguageMsg("Command_JSRun"))
	addCommandList($iCommandCount, $_sCommandJSInsert   , $aCommandList, _getLanguageMsg("Command_JSInsert"))

	addCommandList($iCommandCount, $_sCommandWDSessionCreate   , $aCommandList, _getLanguageMsg("Command_WDSessionCreate"))
	addCommandList($iCommandCount, $_sCommandWDSessionDelete   , $aCommandList, _getLanguageMsg("Command_WDSessionDelete"))

	addCommandList($iCommandCount, $_sCommandWDAcceptAlert   , $aCommandList, _getLanguageMsg("Command_WDAcceptAlert"))
	addCommandList($iCommandCount, $_sCommandWDDismissAlert    , $aCommandList, _getLanguageMsg("Command_WDDismissAlert"))

	addCommandList($iCommandCount, $_sCommandWDNavigateBack   , $aCommandList, _getLanguageMsg("Command_WDNavigateBack"))
	addCommandList($iCommandCount, $_sCommandWDNavigateForward    , $aCommandList, _getLanguageMsg("Command_WDNavigateForward"))
	addCommandList($iCommandCount, $_sCommandWDNavigateRefresh   , $aCommandList, _getLanguageMsg("Command_WDNavigateRefresh"))

	redim $aCommandList[$iCommandCount + 1][$_iCommandEnd]


	return $aCommandList

EndFunc


func getCommandSplitText()

	local $i, $j
	local $aSplit[ubound ($_aCommandText)][3]
	local $aTempSplit

	for $i = 1 to ubound ($_aCommandText) -1
		$aTempSplit = StringSplit($_aCommandText[$i][$_iCommandText], $_sCommandListSplitChar)

		$aSplit[$i][0] = ubound ($aTempSplit) -1
		for $j = 1 to ubound ($aTempSplit) -1
			$aSplit[$i][$j] = $aTempSplit[$j]
		next
	next

	;msg($aSplit)

	return $aSplit

endfunc


func addCommandList(byref $iCommandCount, $sCommand, byref $aCommandList, $sDefaultName)
; 명령어 추가

	local $i
	local $j
	local $aCommandText

	;$aCommandText = stringsplit( $sDefaultName & "|" & getReadINI("SCRIPT_COMMAND", $sCommand), "|")
	$aCommandText = stringsplit( $sDefaultName , "|")

	;debug($aCommandText)
	$aCommandText = _ArrayUnique($aCommandText,1,1,0)



	for $i=1 to ubound($aCommandText) -1
		$aCommandText[$i] = _trim($aCommandText[$i])
		if $aCommandText[$i]  <> "" then
			$iCommandCount += 1
			$aCommandList[$iCommandCount][$_iCommandName] = $sCommand
			$aCommandList[$iCommandCount][$_iCommandText] = $aCommandText[$i]
		endif
	next

endfunc


func getScript($aRowScript, byref $aResultScript, byref $sErrorMsgAll, $bImageCheck, $iScriptStartLine, $iScriptEndLine)
; 스크립트 문자열에서 스크립트를 분석하여 스크립트 배열구조로 리턴

	local $bResult

	local $aScript [1][$_iScriptEnd]
	local $sRawScript
	local $sCheckMessage

	local $sNewCommand
	local $sNewCommandStartPos
	local $sNewPrimeCommand
	local $sNewTarget
	local $sNewTargetStartPos
	local $sNewCheckCode
	local $bIncludeFileAdd = False
	local $bImageCheckLine
	local $iScriptLineCount

	if IsArray($aRowScript) then
		$iScriptLineCount = ubound($aRowScript)
	else
		$iScriptLineCount = 1
	endif

	;msg($iScriptLineCount)

	redim  $aScript [$iScriptLineCount][$_iScriptEnd]

	$sErrorMsgAll = ""
	$bResult = True

	for $i = 1 to ubound($aRowScript) -1

		if $bImageCheck then
			if ($i >= $iScriptStartLine and $i <= $iScriptEndLine) or  ($iScriptStartLine <= 0)then
				$bImageCheckLine = $bImageCheck
			Else
				$bImageCheckLine = False
			endif
		else
			$bImageCheckLine = $bImageCheck
		endif

		;debug("이미지검사 : " & $bImageCheckLine)

		$sRawScript = _Trim($aRowScript[$i])
		$aScript[$i][$_iScriptRaw] = _trim($aRowScript[$i])

		; 라인별로 스크립트 분석
		$aScript[$i][$_iScriptCheck] = getScriptLine($sRawScript,  $sNewCommand,  $sNewCommandStartPos, $sNewPrimeCommand, $sNewTarget, $sNewTargetStartPos, $sNewCheckCode,  $sCheckMessage, $bImageCheckLine, $bIncludeFileAdd, False, $i)
		;debug($sRawScript, $sCheckMessage)

		$aScript[$i][$_iScriptCommand] = $sNewCommand
		$aScript[$i][$_iScriptCommandStartPos] = $sNewCommandStartPos
		$aScript[$i][$_iScriptPrimeCommand] = $sNewPrimeCommand
		$aScript[$i][$_iScriptTarget] = $sNewTarget
		$aScript[$i][$_iScriptTargetStartPos] = $sNewTargetStartPos
		$aScript[$i][$_iScriptCheckCode] =$sNewCheckCode
		$aScript[$i][$_iScriptCheckMessage] = $sCheckMessage
		$aScript[$i][$_iScriptLine] = $i

		;debug($sCheckMessage)

		if $sCheckMessage <> "" then

			if $sErrorMsgAll <> "" then $sErrorMsgAll = $sErrorMsgAll & @crlf
			$sErrorMsgAll  = $sErrorMsgAll  & _getLanguageMsg("error_precheck") & " : " & $sRawScript &  " > " &  $sCheckMessage
		endif

		;if $aScript[$i][$_iScriptCheck] = $_iScriptAllCheckError  and $aScript[$i][$_iScriptCheckMessage] <> "" then $bResult = False
		if $aScript[$i][$_iScriptCheck] = $_iScriptAllCheckError   then $bResult = False

	next

	$aResultScript = $aScript

	return $bResult

endfunc

func checkCommentScript($sScript)
; 앞에 커맨트에 ";"가 있을 경우 True

	if stringleft($sScript  & " ", 1) =";" then
		return True
	Else
		return False
	endif
endfunc

func getScriptLine($sScript, byref $sNewCommandAll, byref $sNewCommandStartPosAll,  byref $sNewPrimeCommandAll, byref $sNewTargetAll, byref $sNewTargetStartPosAll, byref $sNewCheckCodeAll,  byref $sNewCheckMessageAll, $bImageCheck, $bIncludeFileAdd, $bUseCache, $iScriptLine)
;라인별로 스크립트 분석 결과 리턴 다중명령어는 |로 구분

	local $iResult
	local $bCommandFound
	local $sNewCommand
	local $sNewCommandStartPos
	local $sNewPrimeCommand
	local $sNewTarget
	local $sNewTargetStartPos
	local $sNewCheckCode
	local $sNewCheckMessage
	local $sRestScript
	local $iSearchIndex
	local $sRawScript
	local $aSearchCommandIndex [1000][3]
	local $aSearchCommandCount = 0
	local $iCommandStart
	local $bCommandFound

	$sNewCommandAll = ""
	$sNewCommandStartPosAll = ""
	$sNewPrimeCommandAll = ""
	$sNewTargetAll = ""
	$sNewTargetStartPosAll = ""
	$sNewCheckCodeAll = ""
	$sNewCheckMessageAll = ""
	$iSearchIndex = 0

	$sRawScript = $sScript
	$iResult = $_iScriptAllCheckOK

	if  checkCommentScript($sScript) = True Then
		$iResult = $_iScriptAllCheckComment

	elseif $sScript <> "" Then
		;debug("스트립트:" & $sScript)
		; 찾아야 될 명령어들만 List함

		for $i = 1 to ubound ($_aCommandText) -1
			for $j=1 to $_aCommandSplitText[$i][0]

				;$iCommandStart = StringInStr(" " & $sScript, " " & $_aCommandSplitText[$i][$j])
				;if $iCommandStart > 0 then

				if getCommandExcludeTarget (" " & $sScript & " " , " " & $_aCommandSplitText[$i][$j]) > 0  then

					$aSearchCommandCount +=1
					$aSearchCommandIndex[$aSearchCommandCount][1] = $i
					$aSearchCommandIndex[$aSearchCommandCount][2] = $j

				endif
			next
		next

		redim $aSearchCommandIndex[$aSearchCommandCount+1][3]

		;msg($aSearchCommandIndex)

		do
			; 명령줄 내에 다중 스크립트 분석 (명령이 없을 때 까지)
			writeConsoleDebug("getCommandAndTarget 시작")
			$bCommandFound = getCommandAndTarget($sScript, $sRestScript,  $sNewCommand, $sNewCommandStartPos,  $sNewPrimeCommand,  $sNewTarget, $sNewTargetStartPos, $sNewCheckCode , $sNewCheckMessage, $iSearchIndex, $bImageCheck, $bIncludeFileAdd, $bUseCache, $iScriptLine, $aSearchCommandIndex)
			writeConsoleDebug("getCommandAndTarget 종료")

			;msg("xxx" & $sNewCheckMessage)

			if $bCommandFound Then

				;if $sNewTarget = "" then $sNewTarget = $_sCommandSplitChar

				; 명령어 추가
				if $sNewCommandAll <> "" then $sNewCommandAll = $sNewCommandAll & $_sCommandSplitChar
				$sNewCommandAll = $sNewCommandAll & $sNewCommand

				if $sNewCommandStartPosAll <> "" then $sNewCommandStartPosAll = $sNewCommandStartPosAll & $_sCommandSplitChar
				$sNewCommandStartPosAll = $sNewCommandStartPosAll & $sNewCommandStartPos

				if $sNewPrimeCommandAll <> "" then $sNewPrimeCommandAll = $sNewPrimeCommandAll & $_sCommandSplitChar
				$sNewPrimeCommandAll = $sNewPrimeCommandAll & $sNewPrimeCommand

				if $sNewTargetAll <> "" then $sNewTargetAll = $sNewTargetAll & $_sCommandSplitChar
				$sNewTargetAll = $sNewTargetAll & $sNewTarget

				if $sNewTargetStartPosAll <> "" then $sNewTargetStartPosAll = $sNewTargetStartPosAll & $_sCommandSplitChar
				$sNewTargetStartPosAll = $sNewTargetStartPosAll & $sNewTargetStartPos

				if $sNewCheckCodeAll <> "" then $sNewCheckCodeAll = $sNewCheckCodeAll & $_sCommandSplitChar
				$sNewCheckCodeAll = $sNewCheckCodeAll & $sNewCheckCode

				;debug($sRawScript, $sNewCommandStartPos , $sNewTargetStartPos )

			endif

			if $sNewCheckMessage <> "" then

				$iResult = $_iScriptAllCheckError

				_StringAddNewLine ($sNewCheckMessageAll,$sNewCheckMessage)


			endif

			;debug($bIsImageErrorAll)

			;debug($bIsImageError)
			;if $bCommandFound or $bIsImageError = True Then

			;debug($bCommandFound, $bImageCheck, $sNewCheckCode)


			$sScript = $sRestScript


		until $sRestScript = ""

		;debug ($sCheckMessageAll)
		;until $sRestScript = "" or $sCheckMessage <> ""

		if $sNewCommandAll = "" then
			$iResult = $_iScriptAllCheckError
			$sNewCheckMessageAll = $_sLogText_Error & _getLanguageMsg("error_commandtargetnotfound")


		endif

		;$bResult = _iif($sNewCommandAll <> "", True, False)

	Else
		$iResult = $_iScriptAllCheckSkip
	endif

	;debug($sNewCheckMessageAll)
	return $iResult

endfunc


func getCommandExcludeTarget( $sScript, $sCommand )

	local $iCommandStart
	local $iSearchStart  = 1
	local $bTry

	; 탭이 단일 명령어 앞에 붙어 있는 경우 분석하지 못함, 일시적으로 @tab을 space로 변경하여 찾음
	$sScript = Stringreplace($sScript, @tab, " ")

	do
		$bTry = False

	;debug("재시도",$iSearchStart)

		$iCommandStart = StringInStr($sScript,  $sCommand, 0,1, $iSearchStart)

		if $iCommandStart > 0 then
			if CheckTargetText(StringLeft($sScript,$iCommandStart-1)) = True then
				$bTry = True
				$iSearchStart = $iCommandStart + stringlen($sCommand)
			ENDIF
		endif



	until $bTry = False

	;debug($sScript,  $sCommand, $iCommandStart)

	return $iCommandStart

endfunc


func CheckTargetText($sText)

	Local $bTarget = False
	local $sTemp
	local $iCount

	StringReplace ($sText,"""","")

	if mod(number(@extended),2) = 1 then $bTarget = True

	;debug("target sheck " & $sText, $sTemp, $bTarget, $iCount)

	return $bTarget

endfunc

Func getCommandAndTarget($sScript, byref $sRestScript, byref $sNewCommand, byref $sNewCommandStartPos, byref $sNewPrimeCommand,  byref $sNewTarget, byref $sNewTargetStartPos, byref $sNewCheckCode, byref $sNewCheckMessage, byref $iSearchIndex,  $bImageCheck, $bIncludeFileAdd, $bUseCache, $iScriptLine, byref $aSearchCommandIndex)
; 명령줄 내에 다중 스크립트 분석, $bImageCheck 스크립트 분석시 이미지의 존재 여부도 같이 검사하도록 하여 결과 내용에 기록함

	local $bResult
	local $i, $j
	local $sTarget
	local $sFoundCommand

	local $iCommandFoundLoc
	local $iFirstTargetLoc
	local $sFirstCommand
	local $sFirstPrimeCommand
	local $iFirstCommandLoc = 0
	local $iNextSearchIndex
	local $sSearchedScriptFile
	local $iFoundLoc

	local $iQuoteLoc1 = 0
	local $iQuoteLoc2 = 0

	local $aImageList[1]
	local $iCommandIndex
	local $iCommandSubIndex

	$sRestScript = ""
	$sNewCommand = ""
	$sNewCommandStartPos = ""
	$sNewPrimeCommand = ""
	$sNewTarget = ""
	$sNewTargetStartPos = ""
	$sNewCheckCode = ""
	$sNewCheckMessage = ""

	;debug($sScript)

	writeConsoleDebug("명령 나누기 시작 : " & $sScript)

	;sleep(1)

	for $i = 1 to ubound ($aSearchCommandIndex) -1
		;debug("찾기 " & $sScript, $_aCommandText[$i][$_iCommandText])
		;if stringinstr($sScript,$_aCommandText[$i][$_iCommandText]) then

		$iCommandIndex = $aSearchCommandIndex[$i][1]
		$iCommandSubIndex = $aSearchCommandIndex[$i][2]

		writeConsoleDebug("checkCommandInclude 시작 : " & $_aCommandText[$iCommandIndex][$_iCommandText])

		;$iFoundLoc = StringInStr(" " & $sScript, " " & $_aCommandSplitText[$iCommandIndex][$iCommandSubIndex],0,-1,StringLen($sScript) + 2)
		;$iFoundLoc = StringInStr(" " & $sScript, " " & $_aCommandSplitText[$iCommandIndex][$iCommandSubIndex])
		$iFoundLoc = getCommandExcludeTarget (" " & $sScript & " " ," " &  $_aCommandSplitText[$iCommandIndex][$iCommandSubIndex])
		;if $iFoundLoc > 1 then $iFoundLoc -= 1

		if $iFoundLoc > 0 then
			$sFoundCommand = $_aCommandSplitText[$iCommandIndex][$iCommandSubIndex]
			$iCommandFoundLoc = $iFoundLoc
		endif


		if $iCommandFoundLoc > 0 then
			; 따옴표로 된 경우 명령어에서 제외
			$iQuoteLoc1 = StringInStr ($sScript,"""",0,-1,stringlen($sScript))
			if $iQuoteLoc1 > 0 then
				$iQuoteLoc2 = StringInStr ($sScript,"""",0,-1,stringlen($sScript) - (stringlen($sScript) - $iQuoteLoc1) -1 )

				if $iCommandFoundLoc > $iQuoteLoc2 and $iCommandFoundLoc < $iQuoteLoc1 then $iCommandFoundLoc = 0
				;debug($iQuoteLoc1, $iQuoteLoc2, $iCommandFoundLoc,  $sScript)
			endif
		endif

		if $iCommandFoundLoc > 0 then

			;debug ($sScript)
			if $iCommandFoundLoc < $iFirstCommandLoc or $iFirstCommandLoc = 0 then
				$sFirstCommand = $sFoundCommand
				$iFirstCommandLoc = $iCommandFoundLoc
				$sFirstPrimeCommand = $_aCommandText[$iCommandIndex][$_iCommandName]
				;exitloop
			endif
		endif
	next

	writeConsoleDebug("명령 나누기 종료")

	if $sFirstCommand <> "" then

		$sNewCommand = $sFirstCommand
		$sNewPrimeCommand = $sFirstPrimeCommand
		$sNewCommandStartPos = $iSearchIndex + $iFirstCommandLoc
		;debug($sNewCommandStartPos)

		$sRestScript = StringRight($sScript, stringlen($sScript) - $iFirstCommandLoc - (stringlen($sFirstCommand)) )

		;debug($sRestScript)


		$iNextSearchIndex = $sNewCommandStartPos + stringlen($sFirstCommand)

		$bResult = True

		if checkSimpleCommand($sNewPrimeCommand) then
			$sNewCheckCode = $_iScriptCheckIDOK
			$sNewTargetStartPos = 0
			$sNewTarget = " "

		else
			$sNewTarget = getTarget(Stringleft($sScript,$iFirstCommandLoc), $iFirstTargetLoc)

			if $sNewTarget = "" then
				$sNewCheckMessage = $_sLogText_Error & _getLanguageMsg("error_commandtargetnotassign") & " : " & $sNewCommand
				$sNewCheckCode = $_iScriptCheckIDTargetNotFound
			Else
				$sNewTargetStartPos =  $iSearchIndex + $iFirstTargetLoc
				;debug($iSearchIndex, $sNewTargetStartPos)

				if $bImageCheck then
					;debug("왔어" & $bImageCheck)
					writeConsoleDebug("이미지 찾기 시작")
					if checkTartgetImageExists($sFirstPrimeCommand, $sNewTarget, $aImageList, $sNewCheckMessage, $bImageCheck, $bUseCache, $iScriptLine, True) = False then
						$sNewCheckCode = $_iScriptCheckIDImageNotFound
					endif

					writeConsoleDebug("이미지 찾기 종료")
				Else
					; 첨부파일만 확인
					checkTartgetImageExists($sFirstPrimeCommand, $sNewTarget, $aImageList, $sNewCheckMessage, $bImageCheck, $bUseCache, $iScriptLine, True)
				endif

				if $bIncludeFileAdd = True and  $sNewPrimeCommand = $_sCommandInclude then

					writeConsoleDebug("스크립트 찾기 시작")
					$sSearchedScriptFile = searchScriptFile(_GetFileName($sNewTarget) & _GetFileExt($sNewTarget), $sNewCheckMessage)
					if $sSearchedScriptFile <> "" then
						if $bIncludeFileAdd then _ArrayAdd($_aPreAllScriptFile, $sSearchedScriptFile )
					Else
						$sNewCheckCode = $_iScriptCheckIDIncludeFileNotFound
						;msg("에러")
						;debug($bIncludeFileAdd, $sNewPrimeCommand, $_sCommandInclude)
					endif
					writeConsoleDebug("스크립트 찾기 종료")

				endif


					;debug($_aPreAllImageTarget)

				if $bImageCheck = False and $bIncludeFileAdd = False then
					$sNewCheckCode = $_iScriptCheckIDOK
				endif
			endif
		endif

		$iSearchIndex =  $iNextSearchIndex

	Else
		$bResult = False
		$sRestScript = ""
		$sNewCheckCode = $_iScriptCheckIDCommnadNotFound
	endif


	;msg($bResult & $sCheckMessage)
	;debug($sNewCommand, $sNewPrimeCommand,$sNewTarget)
	return $bResult

endfunc


func eraseScriptExcludeText(byref $sRawScript, $sKey, $bErase)
; 따옴표로 처진것을 먼저 대상으로 선정하여 사용

	local $iQuoteLoc1 = 0
	local $iQuoteLoc2 = 0

	$sRawScript = StringReplace($sRawScript,'""',chr(1))

	$iQuoteLoc1 = StringInStr ($sRawScript,"""",0,-1,stringlen($sRawScript))
	;debug($sRawScript, $iQuoteLoc1)
	if $iQuoteLoc1 > 0 then $iQuoteLoc2 = StringInStr ($sRawScript,"""",0,-1,stringlen($sRawScript) - (stringlen($sRawScript) - $iQuoteLoc1) -1 )
	;debug($iQuoteLoc2)

	if $iQuoteLoc2 > 0 then
		$sRawScript = StringReplace($sRawScript,"""", $sKey )
	else
		if $bErase = True then

			for $i=1 to ubound ($_aTargetExcludeText) -1
				$sRawScript = StringReplace($sRawScript,$_aTargetExcludeText[$i] & " ", $sKey)
			next
		endif

		$sRawScript = StringReplace($sRawScript," ", $sKey )

		$sRawScript = $sKey & $sRawScript

		While StringInStr($sRawScript,$sKey & $sKey)
			$sRawScript = StringReplace($sRawScript,$sKey & $sKey, $sKey )
		wend
		;msg($sRawScript)
	endif

	$sRawScript = StringReplace($sRawScript,chr(1),'"')

EndFunc


func DeleteScriptExcludeText(byref $sRawScript)
; 스크립트 명령내용에서 불필요한 글자들을 제거한다.

		$sRawScript = _trim($sRawScript) & " "
		for $i=1 to ubound ($_aTargetExcludeText) -1
			$sRawScript = StringReplace($sRawScript,$_aTargetExcludeText[$i] & " ", "")
		next

		$sRawScript = _trim($sRawScript)

endfunc


func getTarget($sNewScript, byref $iFirstTargetLoc, $bErase = True)
; 명령어 내에서 작업 대상을 분석함

	local $sKey = chr(0)
	local $iFirst
	local $iLast
	local $sTartget
	local $sRawScript = $sNewScript
	local $iSearchStart

	$iSearchStart = Stringinstr($sNewScript,"")
	if $iSearchStart = 0 then $iSearchStart = Stringlen($sNewScript)

	;debug($sNewScript, $sRawScript)

	eraseScriptExcludeText($sRawScript, $sKey, $bErase)

	$iLast = StringInStr($sRawScript,$sKey,0,-1)

	if $iLast > 0 then
		$iFirst = StringInStr($sRawScript,$sKey,0,-1,$iLast-1) +1
		if $iFirst = 0 then $iFirst = 1
		;debug($sRawScript & " " & $iFirst & " "  & $iLast)

		$sTartget = StringMid($sRawScript,$iFirst, $iLast - $iFirst)
		$iFirstTargetLoc = StringInStr($sNewScript,$sTartget,0,-1,$iSearchStart)

		return $sTartget
	Else

		return ""
	endif

endfunc


Func checkTartgetImageExists($sPrimeCommand, $sScriptTarget, byref $aImageList, byref $sCheckMessage, $bImageCheck, $bUseCache, $iScriptLine, $bExisitCheckOnly)
; 명령어 지정된 이미지가 존재하는지 사전확인

	local $bResult
	local $tempImageFile [1]
	local $aImageListMulti
	local $i, $j
	local $bCheckResult
	local $bCheckCache
	local const $sCacheSplit = "|"
	local $aReservedWord[5]
	local $sCacheImageName


	$aReservedWord[1] = "["
	$aReservedWord[2] = "]"
	$aReservedWord[3] = "{"
	$aReservedWord[4] = "}"

	;msg("왔어")

	; 이미지 방식이 아닌 경우 (웹드라이버, TAG 방식) 바로 OK
	if getImageType($sScriptTarget) = False then return True

	$aImageListMulti = StringSplit($sScriptTarget,",")
	$bResult = True

	for $i=1 to ubound($aImageListMulti) -1

		$aImageListMulti[$i] = _Trim($aImageListMulti[$i])

		if getImageType($aImageListMulti[$i]) = True then

			if checkImageReqCommand($sPrimeCommand, $aImageListMulti[$i], True) then
				;debug($sScriptTarget, $bResult)

				_ArrayAdd($_aPreAllImageTarget, $aImageListMulti[$i])

				if $bImageCheck then

					$sCacheImageName = $sCacheSplit & $aImageListMulti[$i] & $sCacheSplit

					$bCheckCache = False

					if $bUseCache then

						if stringinstr($_RunImageCheckTrueCache,$sCacheImageName ) > 0 then
							$bCheckCache = True
							$bCheckResult = True
						elseif stringinstr($_RunImageCheckFalseCache, $sCacheImageName ) > 0 then
							$bCheckCache = True
							$bCheckResult = False
						endif

						if $bCheckCache then redim $tempImageFile [1]

					endif

					if $bCheckCache = False then
						;debug("이미지 찾기:" & $sCacheImageName)
						$bCheckResult = getCommnadImage($aImageListMulti[$i], $tempImageFile, $bExisitCheckOnly)
					endif

					if $bCheckResult = False then
						$bResult = False
						_StringAddNewLine ($sCheckMessage,$_sLogText_Error & _getLanguageMsg("report_imagenotfound") & " : " & $aImageListMulti[$i])
					Else
						$bResult = True
						for $j=1 to ubound($tempImageFile) -1
							_ArrayAdd($aImageList, $tempImageFile[$j])
						next
					endif

					if $bUseCache and $bCheckCache = False then
						if $bResult Then
							$_RunImageCheckTrueCache =   $sCacheImageName
						Else
							;debug("오류캐시 설정:" & $sCacheImageName)
							$_RunImageCheckFalseCache =   $sCacheImageName
						endif

					endif


				; 타겟에 특수문자가 포함된 경우 에러처리
					for $j=1 to ubound($aReservedWord) -1
						if StringInStr($aImageListMulti[$i],$aReservedWord[$j]) <> 0 then

							$bResult = False

							_StringAddNewLine ($sCheckMessage, $_sLogText_Error & _getLanguageMsg("error_usespchar") & " : " &$aImageListMulti[$i] & ", " &  """" & $aReservedWord[$j] & """")

						endif

					next
				endif

			Endif
		endif
	next

	return $bResult

EndFunc


func getCommnadImage($sScriptTarget, byref $aImageFile, $bExisitCheckOnly)
; 명령어 지정된 이미지를 찾아서 배열로 전달

	local $bResult
	local $aTempImageFile[1]
	local $iLastArraySize

	$aImageFile = $aTempImageFile


;~ 	for $i= 0 to ubound($_aRunImagePathList) -1 step 1
;~ 		$iLastArraySize = ubound($aImageFile)

;~ 		foundImageFile( $_aRunImagePathList[$i], $sScriptTarget, $aImageFile)
;~ 	next

	$aImageFile = _findFolderFileInfo($_sImageForderFileList, $sScriptTarget & $_cImageExt & $_sCommandImageSearchSplitChar & $sScriptTarget & "_", $bExisitCheckOnly)



	$bResult = _iif( ubound($aImageFile) > 1, True, False)

	return $bResult

endfunc


func searchScriptFile($sScriptFilename, byref $sErrorMsg, $bFirstSearchOnly = True)

	local $i,$j
	local $aSearchList
	local $aFoundFileList [1]
	local $bFound = False


	if StringInStr($sScriptFilename, $_cScriptExt) = 0 then $sScriptFilename = $sScriptFilename & $_cScriptExt

;~ 	for $i= ubound($_aRunImagePathList) -1 to 0 step -1
;~ 		;debug($_aRunImagePathList[$i], $sScriptFilename)
;~ 		$aSearchList = _GetFileNameFromDir($_aRunImagePathList[$i],$sScriptFilename, 1)

;~ 		for $j=1 to ubound($aSearchList) -1
;~ 			$bFound = True
;~ 			_ArrayAdd($aFoundFileList, $aSearchList[$j])
;~ 		next

;~ 		if $bFound and $bFirstSearchOnly then exitloop

;~ 	next

	$aFoundFileList = _findFolderFileInfo($_sScriptForderFileList, $sScriptFilename, False)


	$aFoundFileList = _ArrayUnique($aFoundFileList,1,1)

	if ubound($aFoundFileList) = 1 or IsArray($aFoundFileList) = 0  then
		$sErrorMsg = $_sLogText_Error & _getLanguageMsg("cmdreciver_scriptnotfound") & " : " & $sScriptFilename
		;FileWrite("c:\1.txt", $_sScriptForderFileList)
		return ""
	elseif ubound ($aFoundFileList) > 2 then
		$sErrorMsg = $_sLogText_Error & _getLanguageMsg("error_scriptduple") &  " " & _ArrayToString($aFoundFileList," , ")
		return ""
	endif

	;msg($aFoundFileList)
	return $aFoundFileList[1]

endfunc


Func foundImageFile($sPath, $sFilename, byref $aNewList)
; 이미지 찾기

	;debug ($sPath, $sFilename)
	;debug("xxx")
	;debug($aNewList)
	getImageFileList($sPath,$sFilename & ".png", $aNewList)
	;debug($aNewList)
	getImageFileList($sPath,$sFilename & "_*.png", $aNewList)

	;debug($aNewList)

Endfunc


Func getImageFileList($sPath, $sPattern, byref $aFlist)
; 지정된 폴더내의 하위 폴더로 파일을 찾아 누적된 배열로 리턴

	local $aNewList

	$aNewList = _GetFileNameFromDir($sPath,$sPattern, 1)

	if IsArray($aNewList) then
		if ubound($aNewList) > 1 then
			;redim $aFlist[ubound($aFlist) -1 + ubound($aNewList)-1]
			for $i= 1 to ubound($aNewList)-1
				if _ArraySearch($aFlist,$aNewList[$i],1,0) = -1 then _ArrayAdd($aFlist,$aNewList[$i])
			next

		endif
	endif


endfunc


Func _getPrimeCommand($sCommand)
; 명령어 내에 대표 명령어를 리턴함

	local $i

	for $i = 1 to ubound ($_aCommandText) -1
		if $sCommand = $_aCommandText [$i][$_iCommandText] then return $_aCommandText [$i][$_iCommandName]
	next

	return ""

endfunc


func getImageType($sScriptTarget)

	local $bRet

	$bRet = getVarType($sScriptTarget)
	if $bRet = False then $bRet = getIEObjectType($sScriptTarget)
	if $bRet = False then $bRet = isWebdriverParam($sScriptTarget)

	;debug(isWebdriverParam($sScriptTarget), $sScriptTarget)

	return not($bRet)

endfunc

func getVarType($sScriptTarget, $bExtractCheck = False)

	local $iPos = stringinstr( $sScriptTarget , "$" )
	local $bRet = False

	if $iPos <> 0 then
		$bRet = True
		if $bExtractCheck and $iPos <> 1 then $bRet = False
	endif

return $bRet

endfunc


func getIEObjectType($sScriptTarget)

	local $bRet

	if stringleft($sScriptTarget,1) = "[" and stringright($sScriptTarget,1) = "]" then
		$bRet = True
	else
		$bRet = False
	endif

	;debug("getIEObjectType : " & $sScriptTarget & ", " & $bRet)

	return $bRet

endfunc


func getIEObjectCondtion($sScriptTarget)

	local $sCondtion

	$sCondtion = stringtrimright(stringtrimleft($sScriptTarget,1),1)

	return $sCondtion

endfunc

func getVarNameValue($sScriptTarget, byref $sNewName, byref $sNewValue, $sConvertType ="," , $bExtractCheck = False)

	local $aTempSplit
	local $iSplitPoint
	local $bReturn
	local $sVarName
	local $sVarValue
	local $bVarAddInfo
	local $sConvertedNewValue

	if getVarType($sScriptTarget) = False then $bReturn =  False

	$iSplitPoint = StringInStr($sScriptTarget, "=")

	if $iSplitPoint > 0 then

		$sVarName = Stringleft($sScriptTarget,$iSplitPoint-1)

		if Stringleft($sVarName,1) <> "$" then return False

		$sNewName = _trim($sVarName)

		$sVarValue =StringTrimleft($sScriptTarget,$iSplitPoint)


		;$sNewValue = _trim($sVarValue)
		;debug("여기서 찾음")
		;ConvertVarFull (_trim($sVarValue), $sNewValue, $bVarAddInfo, $sConvertType, $bExtractCheck)

		ConvertVarFull ($sVarValue, $sNewValue, $bVarAddInfo, $sConvertType, $bExtractCheck)

		$bReturn = True
	Else
		$bReturn = False
	endif

	;debug($sNewName, $sNewValue)

	return $bReturn

endfunc


func sortImageListByOSBrowser(byref $aFileList, $sBrowser, $iStart = 2)

	local $sPostFixOS
	local $iLastFound = 0
	local $i, $j
	local $sTemp
	local $sBrowserPostFix

	$sBrowserPostFix = $sBrowser

	$sPostFixOS = stringreplace(@OSVersion,"_","")

	;debug("전")
	;debug($aFileList)

	;버그가 있어서 1이상인 경우에만 유니크 펑션 실행
	if ubound($aFileList) > 1 then $aFileList = _ArrayUnique($aFileList,1,1)
	;ConsoleWrite("error" & @error)
	;debug("후")
	;debug($aFileList)

	for $i= $iStart to ubound ($aFileList)-1
		if stringinstr($aFileList[$i], "_" & $sPostFixOS & "_" & $sBrowserPostFix) <> 0 then
			$iLastFound = $iLastFound + 1
			$stemp = $aFileList[$iLastFound]
			$aFileList[$iLastFound] = $aFileList[$i]
			$aFileList[$i] = $stemp
		endif
	next

	for $i= $iLastFound + 1 to ubound ($aFileList)-1
		if stringinstr($aFileList[$i], "_" & $sBrowserPostFix) <> 0 then
			$iLastFound = $iLastFound + 1
			$stemp = $aFileList[$iLastFound]
			$aFileList[$iLastFound] = $aFileList[$i]
			$aFileList[$i] = $stemp
		endif
	next

 endfunc


 func _addImagePathList($sNewPath)
; 추가할려는 폴더가 공용 폴더 0번이 아닌 경우 추가함

	;for $i=1 to ubound ($_aRunImagePathList) -1
	;	if $_aRunImagePathList[$i] = $sNewPath then
	;		return ""
	;	endif
	;next

	; 이미 추가된 폴더가 아니고, 신규 폴더이며, work 폴더 하위에 포함된 경우에만 검색 폴더로 추가 (c:\1.txt 와 같이 임의 디렉토리 지정시 파일찾는 시간이 오래 걸리)
	if $_aRunImagePathList[0] <> $sNewPath and ( stringinstr($sNewPath, $_runWorkPath) <> 0 )  then
		_ArrayAdd($_aRunImagePathList, $sNewPath)
		_ArrayAdd($_aRunScriptPathList, $sNewPath)
		_UpdateFolderFileInfo(False)
	endif
endfunc


func _deleteImagePathList($sNewPath)
; 추가할려는 폴더가 공용 폴더 0번이 아닌 경우 추가함

	for $i=1 to ubound ($_aRunImagePathList) -1
		if $_aRunImagePathList[$i] = $sNewPath then
			_ArrayDelete($_aRunImagePathList, $i)
			_ArrayDelete($_aRunScriptPathList, $i)
			_UpdateFolderFileInfo (False)
			exitloop
		endif
	next

endfunc



func getTCID($sScript)

	local $sID = ""
	local $sNewScript
	local $iValueStart

	$sNewScript = StringReplace($sScript, " ", "")
	$sNewScript = StringLower($sNewScript)

	if stringleft($sNewScript,4) = ";id=" then
		$iValueStart = Stringinstr($sScript,"=")
		$sID = _trim(stringtrimleft($sScript, $iValueStart))
		;debug("ID=" & $sID)
	endif

	return $sID

endfunc

func getTCEmailList($sScript)

	local $sID = ""
	local $sNewScript
	local $iValueStart

	$sNewScript = StringReplace($sScript, " ", "")
	$sNewScript = StringLower($sNewScript)

	if stringleft($sNewScript,11) = ";emaillist=" then
		$iValueStart = Stringinstr($sScript,"=")
		$sID = _trim(stringtrimleft($sScript, $iValueStart))
		;debug("ID=" & $sID)
	endif

	return $sID

endfunc


func getTCComment($sScript)

	local $sComment = ""
	local $sNewScript
	local $iValueStart

	$sNewScript = _Trim($sScript)

	$sNewScript = StringReplace($sScript, " ", "")
	$sNewScript = StringLower($sNewScript)

	if stringleft($sNewScript,2) = ";#" then
		$iValueStart = Stringinstr($sScript,"#")
		$sComment = "# " &  _trim(stringtrimleft($sScript, $iValueStart))
		;debug("ID=" & $sID)
	endif


	return $sComment

endfunc


func getTCHide($sScript)

	local $bValue = ""
	local $sNewScript
	local $iValueStart

	$sNewScript = StringReplace($sScript, " ", "")
	$sNewScript = StringLower($sNewScript)

	if stringleft($sNewScript,6) = ";hide=" then
		$iValueStart = Stringinstr($sScript,"=")
		$bValue = _trim(stringtrimleft($sScript, $iValueStart))
		;debug($bValue)
		if StringLower($bValue) = "on" or StringLower($bValue) = "true" or StringLower($bValue) = "1" then
			$bValue = "ON"
		Else
			$bValue = "OFF"
		endif

	endif

	return $bValue

endfunc


func checkImageReqCommand($sCommand, $sTarget, $bExcludeVarType)

	local $bResult = False

	Switch  $sCommand

		case $_sCommandClick,$_sCommandAssert, $_sCommandIf, $_sCommandIfNot, $_sCommandAttach, $_sCommandMouseMove, $_sCommandMouseDrag, $_sCommandMouseDrop, $_sCommandRightClick, $_sCommandDoubleClick, $_sCommandLongTab

			if $bExcludeVarType = True then
				$bResult =  getImageType($sTarget)
			Else
				$bResult = True
			endif

	EndSwitch

	return $bResult

EndFunc


func checkWaitCommand($sCommand)

	local $bResult = False

	Switch  $sCommand

		case $_sCommandNavigate, $_sCommandClick, $_sCommandDoubleClick,  $_sCommandMouseMove, $_sCommandMouseDrag, $_sCommandMouseDrop, $_sCommandRightClick, $_sCommandMouseWheelDown, $_sCommandMouseWheelUp, $_sCommandKeySend, $_sCommandInput, $_sCommandSwipe, $_sCommandGoHome, $_sCommandLongTab, $_sCommandLocationTab, $_sCommandLocationLongTab,  $_sCommandLocationDoubleTab

				$bResult = True


	EndSwitch

	return $bResult

EndFunc


func checkTagCommand($sCommand)

	local $bResult = False

	Switch  $sCommand

		case $_sCommandTagAttribGet , $_sCommandTagAttribSet, $_sCommandTagCountGet, $_sCommandJSRun, $_sCommandJSInsert

				$bResult = True

	EndSwitch

	return $bResult

EndFunc


func checkScriptErrorCheckCommand($sCommand)

	local $bResult = False

	;debug($sCommand)

	Switch  $sCommand

		case $_sCommandClick,  $_sCommandInput,  $_sCommandNavigate,  $_sCommandKeySend,  $_sCommandMouseDrop,  $_sCommandRightClick, $_sCommandDoubleClick, $_sCommandAttach

			$bResult = True

	EndSwitch

	return $bResult

EndFunc



func checkMouseHideCommand($sCommand)

	local $bResult = False

	;debug($sCommand)

	Switch  $sCommand

		case $_sCommandClick, $_sCommandAssert, $_sCommandAttach, $_sCommandIf, $_sCommandIfNot, $_sCommandMouseMove, $_sCommandMouseDrag, $_sCommandRightClick, $_sCommandDoubleClick, $_sCommandLongTab, $_sCommandLocationTab, $_sCommandLocationLongTab,  $_sCommandLocationDoubleTab

			$bResult = True

	EndSwitch

	return $bResult

EndFunc




func checkSimpleCommand($sCommand)

	local $bResult = False

	;debug($sCommand)

	Switch  $sCommand

		case $_sCommandSuccess, $_sCommandFail, $_sCommandCapture, $_sCommandBrowserEnd, $_sCommandMouseHide, $_sCommandMouseWheelUp , $_sCommandMouseWheelDown, $_sCommandComma, $_sCommandGoHome, $_sCommandBlockStart, $_sCommandBlockEnd, $_sCommandFullScreenWork, $_sCommandWDSessionDelete, $_sCommandWDAcceptAlert, $_sCommandWDDismissAlert, $_sCommandWDNavigateBack, $_sCommandWDNavigateForward, $_sCommandWDNavigateRefresh

			$bResult = True

	EndSwitch

	return $bResult

EndFunc

func checkTargetisBrowser($sTarget)

	local $bResult = False

	switch $sTarget
		case $_sBrowserIE ,$_sBrowserSA, $_sBrowserFF, $_sBrowserCR, $_sBrowserOP
			$bResult = True
	EndSwitch

	return $bResult
endfunc


func _findFolderFileInfo($sFileList, $sName, $bExisitCheckOnly)

	local $iFound
	local $iStart = 1
	local $iFStart
	local $iFSlash
	local $iFEnd
	local $sFile
	local $aFoundList [1]
	local $aName = StringSplit($sName,$_sCommandImageSearchSplitChar)
	local $i


	writeConsoleDebug("이미지배열 찾기 시작")

	for $i=1 to ubound($aName) -1

		$iStart = 1
		$sName = $aName[$i]

		Do
			$iFound = stringinstr($sFileList, "\" & $sName, 0,1,$iStart)

			if $iFound  > 0 then

				$iFEnd = stringinstr($sFileList, "|", 0,1,$iFound)
				$iFSlash = stringinstr($sFileList, "\", 0,-1,$iFEnd)

				; 경로명인경우
				if $iFound  < $iFSlash then
					$iStart = $iFound  + 1
					$iFound  = 0
				endif

				if $iFound > 0 then

					$iFStart = stringinstr($sFileList, "|", 0,-1,$iFound) + 1
					$iFSlash = stringinstr($sFileList, "\", 0,1,$iFound)
					$iFEnd = stringinstr($sFileList, "|", 0,1,$iFound)

					if $iFSlash > $iFStart then
						$sFile = stringmid($sFileList,$iFStart, $iFEnd - $iFStart)
						;debug ($iFStart, $iFEnd, $sFile )
						_ArrayAdd ($aFoundList, $sFile)
						writeConsoleDebug("이미지배열 찾음")
						if $bExisitCheckOnly then return $aFoundList

					endif

					$iStart = $iFEnd

				endif
			endif

		until $iFound = 0
	next

	;msg($aFoundList)

	if IsArray($aFoundList) Then _ArraySort($aFoundList,0,1,0)

	writeConsoleDebug("이미지배열 찾기 작업 종료")

	return $aFoundList

endfunc


func _getFolderFileInfo($aFolderList, byref $sFileList, $sWildCard)

	local $aFileList
	local $i, $j
	local $bDelete
	local $sTemp
	local $aList
	local $aAllList

	$sFileList = ""

	do
		$bDelete = False

		for $i=0 to ubound($aFolderList)-1 -1

		if stringright($aFolderList[$i],1) = "\" then $aFolderList[$i] = StringTrimRight($aFolderList[$i],1)

		for $j=1 to ubound($aFolderList) -1
			if StringInStr($aFolderList[$j] , $aFolderList[$i] & "\") > 0 then
				_ArrayDelete($aFolderList, $j)
				$bDelete = True
				exitloop
			endif
			if $bDelete then exitloop
		next

		if $bDelete then exitloop

		next

	until $bDelete = False

	;msg($aFolderList)


	if ubound($aFolderList) > 3 then
		$aFolderList[2] = $aFolderList[ubound($aFolderList)-1]
		redim $aFolderList[3]
	endif

	for $i=0 to ubound($aFolderList)-1
		;debug($aFolderList[$i], $i)

		$aList = _GetFileNameFromDir ($aFolderList[$i], $sWildCard, 1)

		if IsArray($aList) and  ubound($aList) > 1 then
			;if $sFileList = "" then $sFileList = $sFileList & "|"
			$sFileList = $sFileList & "|" &  _ArrayToString($aList,"|", 1,0)
		endif

	next

	;debug("이미지 리스트 정리 수행 " & $sWildCard)
	;debug($sFileList)

endfunc


func _UpdateFolderFileInfo($bForceUpdate)

	;msg("$_runScriptFileName: " & $_runScriptFileName & " , " & "$_bUpdateForderFileList:" & $_bUpdateForderFileList & " , " & "$bForceUpdate:" & $bForceUpdate)

	if $_bUpdateForderFileList or $bForceUpdate then
		;debug("파일 목록 업데이트")
		$_bUpdateForderFileList = False
		;debug($_aRunImagePathList)
		;$_sImageForderFileList = ""
		;$_sScriptForderFileList = ""
		_getFolderFileInfo($_aRunImagePathList, $_sImageForderFileList, "*" & $_cImageExt)
		;debug($_aRunImagePathList)
		_getFolderFileInfo($_aRunScriptPathList, $_sScriptForderFileList,"*" &  $_cScriptExt)
		;debug($_aRunScriptPathList)

		; 현재 탭의 변경된 파일정보를 업데이트 함

		;msg($_aRunScriptPathList)
		saveScriptEditInfo(_GTGetCurrentIndex())

	endif

endfunc





