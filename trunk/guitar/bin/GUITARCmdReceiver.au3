#AutoIt3Wrapper_Icon=GUITARCmdReceiver.ico
#AutoIt3Wrapper_Res_Fileversion=1.0.0.40
#AutoIt3Wrapper_Res_FileVersion_AutoIncrement=p

#include-once
#include <Process.au3>
#Include <ScreenCapture.au3>

#include "UIACommon.au3"
#include ".\_include_nhn\_file.au3"
#include "GUITARLanguage.au3"

GLobal $_sScreenCaptureFile
Global $_aProceeKillList [1]
Global $_sLastRunSciprtList
Global $_bReceiverDebugLog

main()

func main ()
;메인

	local $sMainProgram
	local $sMainProgramFullPath
	local $sScriptPath
	local $sCommand
	local $sCommandValue
	local $sCommandOption
	local $sReportPath

	local $sNewPid
	local $sOldPid
	local $aPlist
	local $sCommandRunResult


	AutoItSetOption ( "TrayAutoPause" ,0)

	$_sUserINIFile = @ScriptDir & "\guitar.ini"

	if FileExists($_sUserINIFile) = 0 then _ErrorExit("GUITAR.INI file not found")

	_loadLanguageResource(_loadLanguageFile(getReadINI("Environment","Language")))

	$_bReceiverDebugLog = getIniBoolean(getReadINI("environment","DebugLog"))

	writeReceiverLog("프로그램 신규 실행")


	checkAdminRun()

	TraySetState()
	TraySetToolTip($_sProgramName & " Command Receiver")

	_setCommonPathVar()

	writeReceiverLog("관리자모드 실행 확인")


	$sReportPath = getRelativePath(getReadINI("Report","path"), @ScriptDir)

	_setReportHtmlFile()

	$_sScreenCaptureFile = $sReportPath & "\remote.png"
	$_sLastRunSciprtList = $sReportPath & "\lastrunscript.txt"


	; 레지스트리에서 최신의 실해중이 프로세스 ID를 얻어옴
	$sOldPid = _readSettingReg($_sRemoteRiceiver)
	$sMainProgram = getReadINI("Environment","Main")

	$sMainProgramFullPath = @ScriptDir & "\" & $sMainProgram

	writeReceiverLog("경로 설정 완료")
	writeReceiverLog("원격로그 경로 : " & $_sControlLogFile)


	; 해당 프로세스가 존재하면 로그 적고 종료


	$aPlist = ProcessList (_GetScriptName() & ".exe")

	if (ProcessExists($sOldPid) <> 0) and (ubound($aPlist) > 2) then
		writeRmoteLog($_sRemoteRiceiver & " " &  _getLanguageMsg("cmdreciver_exists") & " PID : " & $sOldPid)
		writeReceiverLog("중복 실행으로 종료")
		return
	endif

	writeReceiverLog("중복 실행 점검 완료")

	; 없으면 레지에 기록
	$sNewPid = ProcessExists($_sRemoteRiceiver)
	_writeSettingReg($_sRemoteRiceiver, $sNewPid)
	writeRmoteLog($_sRemoteRiceiver & " run PID:" & $sNewPid)

	;_debug($_runScriptPath)
	$_runReportPath = getRelativePath(getReadINI("Report","path"), @ScriptDir)

	_ArrayAdd($_aProceeKillList, getReadINI("BROWSER", $sMainProgram))
	_ArrayAdd($_aProceeKillList, getReadINI("BROWSER", $_sBrowserIE))
	_ArrayAdd($_aProceeKillList, getReadINI("BROWSER", $_sBrowserFF))
	_ArrayAdd($_aProceeKillList, getReadINI("BROWSER", $_sBrowserSA))
	_ArrayAdd($_aProceeKillList, getReadINI("BROWSER", $_sBrowserCR))

	_writeRemoteCommand( "","", "")

	writeReceiverLog("반복 진입")

	do
		$sCommandRunResult = False

		_readRemoteCommand($sCommand, $sCommandValue, $sCommandOption)
		;_debug(_nowcalc() , $sCommand, $sCommandValue)

		if $sCommand <> "" then

			_writeRemoteCommand( "","","")

			writeReceiverLog("명령 수행 : " &  $sCommand & ", " & $sCommandValue)

			Switch  StringLower($sCommand)

				case "run"
					$sCommandRunResult = ControlerRun($sMainProgram, $sMainProgramFullPath, $_runScriptPath, $sCommandValue, $sCommandOption,  $sMainProgramFullPath)

				case "stop"
					$sCommandRunResult = ControlerStop($sMainProgramFullPath)

				case "end"
					$sCommandRunResult = ControlerEnd($sMainProgram)

				case "capture"
					$sCommandRunResult = ControlerCapture($_sScreenCaptureFile)

			EndSwitch

			_writeRemoteCommandResult($sCommandRunResult)

		endif

		sleep (1000)

		TraySetToolTip ( @ScriptName & " Alive! " &  _NowCalc() )


	until False

endfunc


func SaveLastRunScriptList($sScriptFile)

	local $aScriptList
	local $i
	local $iMax
	local $bFound = False

	_FileReadToArray($_sLastRunSciprtList, $aScriptList)

	$iMax = ubound($aScriptList) -1
	if $iMax > 20 then $iMax = 20

	if $bFound = False then

		FileDelete($_sLastRunSciprtList)
		FileWriteLine($_sLastRunSciprtList,$sScriptFile)

		for $i = 1 to $iMax
			if $aScriptList[$i] <> $sScriptFile then
				FileWriteLine($_sLastRunSciprtList,$aScriptList[$i] )
			endif
		next

	endif

EndFunc


func ControlerRun($sMainProgram, $sProgramPath, $sScriptPath , $sScriptFile, $sOption , $sMainProgramFullPath)

	local $sNewScript
	local $iProcessKillTimeInit
	local $sRet = False
	local $sCmdLine

	if StringInStr($sScriptFile, $_cScriptExt) > 0 then $sScriptFile = _GetFileName($sScriptFile)
	;_debug($sProgramPath, $sScriptPath , $sScriptFile)

	if FileExists($sProgramPath) = 0 then
		writeRmoteLog(_getLanguageMsg("cmdreciver_filenotfound") & " : " & $sProgramPath)
		return $sRet
	endif

	$sNewScript = _GetFileNameFromDir($sScriptPath,$sScriptFile & $_cScriptExt , 1)

	if _trim($sScriptFile) = ""  then
		writeRmoteLog(_getLanguageMsg("cmdreciver_scriptselect"))
		return $sRet
	endif

	if StringInStr($sScriptFile,"?") > 0  then
		writeRmoteLog(_getLanguageMsg("cmdreciver_scripterror") & " : " & $sScriptFile)
		return $sRet
	endif


	if ubound($sNewScript) = 1 then
		writeRmoteLog(_getLanguageMsg("cmdreciver_scriptnotfound") & " : " & $sScriptFile)
		return $sRet
	endif


	if ProcessExists($sMainProgram) <> 0  then

		writeRmoteLog(_getLanguageMsg("cmdreciver_scriptstopreq2"))
		writeRmoteLog(_getLanguageMsg("cmdreciver_scriptendwait"))

		ControlerStop($sMainProgramFullPath)

		$iProcessKillTimeInit = _TimerInit()

		do
			sleep (1000)
		Until _TimerDiff($iProcessKillTimeInit) > 60000  or (ProcessExists($sMainProgram) = 0 )

		if ProcessExists($sMainProgram) <> 0  then
			writeRmoteLog(_getLanguageMsg("cmdreciver_scriptstop"))
			ControlerEnd($sMainProgram)
		endif

	endif

	;ControlerEnd()

	if $sOption <> "" then $sOption = '"' & $sOption & '"'

	SaveLastRunScriptList($sScriptFile)
	$sCmdLine = $sProgramPath & " " & '"' & $sNewScript[1] & '"' & " " &  $sOption & " /REMOTE"

	run($sCmdLine, _GetPathName($sProgramPath) )

	;_debug($sCmdLine)
	writeRmoteLog(_getLanguageMsg("cmdreciver_scriptrun") & " : " & $sCmdLine)

	$sRet = True

	return $sRet

endfunc


func ControlerStop($sProgramPath)

	local $sInifile

	$sInifile = _GetPathName($sProgramPath) &  $_sProgramName & ".ini"

	IniWrite($sInifile, "Environment", "StopRequest", 1)

	writeRmoteLog(_getLanguageMsg("cmdreciver_scriptstopreq1"))

	return True

endfunc


func ControlerCapture($_sScreenCaptureFile)

	local $sRet = True

	_ScreenCapture_Capture($_sScreenCaptureFile)

	if FileExists($_sScreenCaptureFile) = 0 then $sRet = False

	writeRmoteLog(_getLanguageMsg("cmdreciver_screencapture"))

	return $sRet

endfunc


func ControlerEnd($sMainProgram)

	local $i
	local $iKillMax

	for $i=1 to ubound($_aProceeKillList) -1

		$_aProceeKillList[$i] = _Trim($_aProceeKillList[$i])

		While ProcessExists($_aProceeKillList[$i])

			Processclose ($_aProceeKillList[$i])
		WEnd

	next

	Processclose($sMainProgram)

	writeRmoteLog(_getLanguageMsg("cmdreciver_processkill"))

	return True

endfunc


func writeReceiverLog($sText)

	if $_bReceiverDebugLog then
		FileWriteLine($_sReceiverLogFile, _NowCalc() & " : " & $sText)

		;debug ($sText)
	endif

endfunc