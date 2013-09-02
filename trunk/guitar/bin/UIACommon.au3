#include-once

#include ".\_include_nhn\_util.au3"

#Include <Array.au3>

Global $_sProgramName = "GUITAR"
Global $_cScriptExt = ".txt"
Global $_cImageExt = ".png"

; --------------------

Global Const $_sBrowserIE = "IE"
Global Const $_sBrowserFF = "FIREFOX"
Global Const $_sBrowserSA = "SAFARI"
Global Const $_sBrowserCR = "CHROME"
Global Const $_sBrowserOP = "OPERA"
Global $_aBrowserOTHER[1][3]

Global Const $_sBrowserClassIE = "Internet Explorer_Server"
Global Const $_sBrowserClassFF = "MozillaUIWindowClass|MozillaWindowClass"
Global Const $_sBrowserClassSA = "WebViewWindowClass"
Global Const $_sBrowserClassCR = "Chrome_WidgetWin_0"
Global Const $_sBrowserClassOP = "OperaWindowClass"

Global $_sRemoteRiceiver = "GUITARCmdReceiver.exe"
Global $_sProgramUpdater = "GUITARUpdater.exe"
Global $_sImageSearcher = "GUITARImageSearcher.exe"
Global $_sAVICapture = "AVICapture.exe"

Global $_EditFontName = "Gulim"
Global $_EditFontSize = 9

Global $_runBrowser
Global $_runLastBrowser
Global $_hBrowser
Global $_oBrowser
Global $_runWaitTimeOut
Global $_runCommandSleep

Global $_runMobileOS
Global $_runInputType
Global $_runXMLCommandLinePath
Global $_runXMLPath
Global $_runXMLReport
GLOBAL $_runBUILDID
Global $_runLastRicheditFirstVisibleLine
Global $_runLastRicheditCursor
Global $_runLastMainWindowPos[5]
Global $_runLastLoadScript
Global $_runFullsizeImage
Global $_runComputerName
Global $_runScreenCapturePreName
Global $_runAlwaysFontsmoothing
Global $_runReportPath = ""
Global $_runWorkPath = ""
Global $_runCommonScriptPath = ""
Global $_runCommonImagePath = ""
Global $_runToolbarStatus
Global $_runPreRun = ""
Global $_runScriptPath = ""
Global $_runScriptName = ""
Global $_runSVNPath = ""
Global $_runWorkReportPath = ""
Global $_runFirstErrorLine
Global $_runBrowserWidth
Global $_runBrowserHeight
Global $_runCorrectionX = 0
Global $_runCorrectionY = 0
Global $_runUserCapturePath = ""
Global $_runCommaDelay = ""
Global $_runLastFailTCID = ""
Global $_aLastNavigateTime = 0
Global $_runScriptErrorCheck
Global $_runLastScriptErrorCheck
Global $_runResourcePath = ""
Global $_runCmdRunning  = False
Global $_runCmdRemote  = False
Global $_runPageSleep
Global $_runAreaCpatureExists
Global $_runMouseMoveSleep
Global $_runLogFileHanle
Global $_runEmailAddList=""
Global $_runFullScreenWork
Global $_runTrayToolTip
Global $_runUnknowWindowList
Global $_runReportLogHanle
Global $_runContinueTest
Global $_runHighlightDelay
Global $_runErrorResume
Global $_runHTMLTimeColor
Global $_runCmdLine[11]

Global $_runPreScriptRunned = False

Global $_runCommadLintTimeInit
Global $_runCommadLintTimeStart
Global $_runAreaWork [6]

Global $_runDebugLogFileHanle
Global $_runTolerance
Global $_runAlwaysImageEdit
Global $_runScriptFileName = ""
Global $_runPreCheck
Global $_runCleanBrowser
Global $_runErrorMsg = ""
Global $_runRetryRun
Global $_runMouseDelay
Global $_runAVICapture
Global $_runErrorLineSelect
Global $_runAVICapOn
Global $_runRunningImageCapture
Global $_runRunningToolTip
Global $_runMultiImageRange
Global $_runErrorCount = 0
Global $_runScreenCaptureCount = 0
Global $_runErrorImageTarget
Global $_runLastImageArray[1]
Global $_runDebugLog
Global $_runScriptTotal[100]
Global $_runScriptRun[100]
Global $_runScriptNotRunID[100]
Global $_runRecursiveID[100]
Global $_runRecursiveHide [100]
Global $_runRecursiveRunCount[100]
Global $_runRecursiveErrorCount[100]
Global $_runImageEditor
Global $_runToolTipTimer
Global $_runVerifyTime
Global $_runLastCommandStartTime
Global $_runMiniSizeForm = False
Global $_bUpdateForderFileList
Global $_sImageForderFileList
Global $_sScriptForderFileList

Global $_runAVITempPath

Global $_RunImageCheckTrueCache = ""
Global $_RunImageCheckFalseCache = ""

Global $_aRunVar[1][3]
Global $_aRunImagePathList[1]
Global $_aRunScriptPathList[1]

Global $_sDebugLogFile
Global $_sRunningLogFile
Global $_sReportLogFile

Global $_sUserINIFile

Global $_sControlLogFile

Global $_sUpdateLogFile = @ScriptDir & "\update.log"
Global $_sReceiverLogFile = @ScriptDir & "\receiver.log"

Global $_tDebugTimeDiff
Global $_tDebugMainTimeDiff



Global Enum $_ETab_Hwnd, $_ETab_Title, $_ETab_Filename, $_ETab_RichLineHwnd, $_ETab_RichEditHwnd, $_ETab_CDataSaved, $_ETab_CData1, $_ETab_CData2, $_ETab_CData3, $_ETab_CData4, $_ETab_CData5, $_ETab_CData6, $_ETab_CData7, $_ETab_CData8,  $_ETab_CData9, $_ETab_CData10,$_ETab_CData11,$_ETab_End

Global $_ETabMain, $_ETabMainHwnd
Global $_ETabInfo[20][$_ETab_End]


; ----------- 캡쳐 부분


; ------------------------------------------------------------------------------------


func _setCommonPathVar()


	if $_runWorkPath = "" then $_runWorkPath = getRelativePath(getReadINI("SCRIPT","WorkPath"), @ScriptDir)
	;if $_runWorkPath = "" then $_runWorkPath = getReadINI("SCRIPT","WorkPath")
	if $_runSVNPath = "" then $_runSVNPath = getReadINI("SCRIPT","SVNPath")



	$_runCommonScriptPath = $_runWorkPath & "\Common\Script"
	$_runCommonImagePath = $_runWorkPath & "\Common\Image"
	$_runScriptPath  = $_runWorkPath & "\TestCase"



endfunc



func getIniBoolean($sRet)
; Boolean 값으로 INI 읽기

		$sRet = StringLower($sRet)

		$sRet = _iif(($sRet == "on" or $sRet == "t" or $sRet == "true" or $sRet == "1"), True, False)

		return $sRet
endfunc


Func getTargetExcludeList()

	local $i
	local $aText

	$aText = StringSplit(getReadINI ("SCRIPT_TARGET", "ExcludeText"),"|")

	for $i=1 to ubound($aText) -1
		$aText[$i] = _Trim($aText[$i])
	next

	_arraySortByLen ($aText, False)

	return $aText

endfunc


; ------------------------------------------------------------------------------------------------
Func getReadINI($sSection, $sName)
	;debug(@ScriptDir & "\" & $_sProgramName & ".ini", $sSection, $sName)
	local $sValue

	$sValue = IniRead($_sUserINIFile , $sSection, $sName, "")

	;if $sValue = "" then $sValue = IniRead(@ScriptDir & "\" & $_sProgramName & ".ini", $sSection, $sName, "")

	return $sValue

EndFunc


Func setWriteINI($sSection, $sName, $sValue)
	return IniWrite($_sUserINIFile, $sSection, $sName, $sValue)
EndFunc



Func getReadRemoteINI($sName)

	local $sIniFile = "remote.ini"

	$sIniFile = _iif( $_runReportPath <> "", $_runReportPath, @ScriptDir) & "\" & $sIniFile

	return IniRead($sIniFile, "REMOTE", $sName, "")

EndFunc


Func setWriteRemoteINI($sName, $sValue)

	local $sIniFile = "remote.ini"

	$sIniFile = _iif( $_runReportPath <> "", $_runReportPath, @ScriptDir) & "\" & $sIniFile

	return IniWrite($sIniFile, "REMOTE", $sName, $sValue)

EndFunc


Func _writeSettingReg($sName, $sValue, $SubKey = "")

	Local $sRegRoot = "HKEY_LOCAL_MACHINE"

	;Local $sRegRoot = "HKEY_CURRENT_USER"

	if RegWrite($sRegRoot & "\Software\" & $_sProgramName & _iif($SubKey<>"", "\" & $SubKey , "") , $sName, "REG_SZ", $sValue) = 0 Then
		_ProgramError(_getLanguageMsg ("common_regwriteerror") & " " & "HKEY_LOCAL_MACHINE\Software\" & $_sProgramName & ", Error Code : " & @error)
	endif

endfunc


Func _readSettingReg($sName, $SubKey = "")

	Local $sRegRoot = "HKEY_LOCAL_MACHINE"
	;Local $sRegRoot = "HKEY_CURRENT_USER"
	return RegRead($sRegRoot & "\Software\" & $_sProgramName & _iif($SubKey<>"", "\" & $SubKey , ""), $sName)

endfunc

; ------------------------------------------------------------------------------------------------

Func _writeRemoteCommand($sCommand, $sValue, $sOption)

	setWriteRemoteINI("RemoteCommand", $sCommand)
	setWriteRemoteINI("RemoteCommandValue", $sValue)
	setWriteRemoteINI("RemoteCommandOption", $sOption)
	setWriteRemoteINI("RemoteCommandResult", "")

endfunc


Func _readRemoteCommand(byref $sCommand, byref $sValue, byref $sOption)

	$sCommand = getReadRemoteINI("RemoteCommand")
	$sValue = getReadRemoteINI("RemoteCommandValue")
	$sOption = getReadRemoteINI("RemoteCommandOption")

endfunc

Func _readRemoteCommandResult()

	return getReadRemoteINI("RemoteCommandResult")

endfunc


Func _writeRemoteCommandResult($sValue)

	setWriteRemoteINI("RemoteCommandResult", $sValue)

endfunc


Func _ProgramError($sMessage)
	Msgbox(16 +8192, $_sProgramName & " - " & "Error",$sMessage,0)
endfunc


Func _ProgramInformation($sMessage)
	Msgbox(64 + 8192 , $_sProgramName & " - " & "Information",$sMessage,0)
endfunc


func _ProgramQuestion($sMessage, $iIcon = 32)
	if msgbox(4  + $iIcon + 8192,$_sProgramName & " - " & "Confirm",$sMessage,0) = 6 then
		return True
	Else
		return False
	endif
endfunc

func _ProgramQuestionYNC($sMessage)

	local $bRet = msgbox(3  + 32 + 8192,$_sProgramName & " - " & "Confirm",$sMessage,0)


	if $bRet  = 6 then
		return "Y"
	elseif $bRet  = 2 then
		return "C"
	Else
		return "N"
	endif

endfunc


func _ProgramQuestionYN($sMessage)

	local $bRet = msgbox(1  + 32 + 8192,$_sProgramName & " - " & _getLanguageMsg ("common_confirm"),$sMessage,0)


	if $bRet  = 1 then
		return "Y"
	Else
		return "N"
	endif

endfunc


func writeDebugLog($sMessage)
	if $_runDebugLog then FileWrite($_runDebugLogFileHanle, _nowcalc() & " : " & $sMessage & @crlf)
endfunc


func writeConsoleDebug($sMessage)

	if $_tDebugMainTimeDiff = "" then $_tDebugMainTimeDiff = TimerInit()

	writeDebugLog(StringFormat("[%5d, %4d] ", int(TimerDiff($_tDebugMainTimeDiff)), int(TimerDiff($_tDebugTimeDiff))) &  " - " & $sMessage)
	$_tDebugTimeDiff = TimerInit()

endfunc


;debug( getRelativePath("JT", @ScriptDir))

func getRelativePath($sPath, $sDefautlPath)

	local $sNewPath = $sPath

	if FileExists($sPath) = 0 Then
		if stringright($sDefautlPath ,1) <> "\" then $sDefautlPath = $sDefautlPath & "\"
		$sPath = $sDefautlPath & $sPath
		;debug($sPath)
	endif

	$sPath = FileGetLongName($sPath,1)
	if FileExists($sPath) = 1 Then $sNewPath = $sPath

	return $sNewPath

endfunc



func writeRmoteLog($sText)

	local $i
	local $aLog
	local $iMaxLine = 100

	_FileReadToArray($_sControlLogFile, $aLog)

	FileDelete($_sControlLogFile)

	FileWriteLine($_sControlLogFile, _NowCalc() & " : " & $sText)


	for $i=1 to ubound($aLog) -1
		FileWriteLine($_sControlLogFile, $aLog[$i])
		if $i >= $iMaxLine then exitloop
	next

endfunc


;_writeRecentImageFolder("555")
;_msg(_getRecentImageFolder())

Func _writeRecentImageFolder($sFolder)

	local $i
	local $sTemp
	local $aOldList
	local $iAddCount

	$aOldList = _getRecentImageFolder()

	_writeSettingReg("RecentImageFolder1" , $sFolder)
	$iAddCount = 1

	for $i=1 to ubound($aOldList) -1
		if $aOldList[$i] <> $sFolder Then
			$iAddCount += 1
			_writeSettingReg("RecentImageFolder" & $iAddCount, $aOldList[$i] )
		endif
	next

EndFunc



Func _getRecentImageFolder()

	local $aRet[1]
	local $sTemp


	for $i=1 to 20
		$sTemp = _readSettingReg("RecentImageFolder" & $i)
		if $sTemp <> "" then _ArrayAdd( $aRet, $sTemp)
	next


	return $aRet
EndFunc


func _setReportHtmlFile()
	$_sControlLogFile = getRelativePath(getReadINI("Report","path"), @ScriptDir) & "\remote.log"
endfunc



func minute2hour($iMinute)

	local $sResult

	if $iMinute >= 60 then $sResult = int(($iMinute / 60))  & _getLanguageMsg ("common_timehour") & " "

	$sResult = $sResult  & mod($iMinute,60)  & _getLanguageMsg ("common_timeminute")

	return $sResult

endfunc



func MouseBusy($bBusy)

	Local $aMousePos
	Local $aMousePos2 =  MouseGetPos()

	;sleep(1)
	GUISetCursor (_iif($bBusy,15,2), _iif($bBusy,True,False))


	$aMousePos = MouseGetPos()

	if $aMousePos[0] <> $aMousePos2[0] or $aMousePos[1] <> $aMousePos2[1] then
		MouseMove($aMousePos[0]-1, $aMousePos[1])
		MouseMove($aMousePos[0], $aMousePos[1])
	endif

	;sleep(1)

endfunc


func checkAdminRun()

		;_msg (RunWait (@ComSpec & " /c" & @ScriptDir & "\1.exe"))
		If IsAdmin() = 0 Then
			_ProgramError(_getLanguageMsg ("common_adminerror"))
			exit(1)
		EndIf

endfunc
