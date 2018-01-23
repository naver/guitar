#AutoIt3Wrapper_Icon=GUITARCmdSender.ico
#AutoIt3Wrapper_Res_Fileversion=1.0.0.22
#AutoIt3Wrapper_Res_FileVersion_AutoIncrement=p

#include-once

#include "UIACommon.au3"
#include ".\_include_nhn\_file.au3"
#include "GUITARLanguage.au3"

main()

func main ()
;메인

	local $sCmdLine1
	local $sCmdLine2
	local $sCmdLine3
	local $sTemp1
	local $sTemp2
	local $sResult
	local $iExitCode = 1

	;opt ("TrayIconHide",1)
	;_debug($sProgramPath)

	if ubound($cmdline) > 1 Then $sCmdLine1 = $cmdline[1]

	if ubound($cmdline) > 2 Then $sCmdLine2 = $cmdline[2]

	if ubound($cmdline) > 1 then
		if $cmdline[1] = "null" then $cmdline[1] = ""
	endif

	if $sCmdLine1 = "" then exit

	$_sUserINIFile = @ScriptDir & "\guitar.ini"
	;_setCommonPathVar()

	$_runReportPath = getReadINI("Report","path")

	if $_runReportPath = "" then
		$_runReportPath = @ScriptDir
	else
		$_runReportPath = getRelativePath($_runReportPath, @ScriptDir)
	endif

	_setReportHtmlFile()

	;if ProcessExists($_sRemoteRiceiver) = 0 then
	;	_setReportHtmlFile()
	;	writeRmoteLog($_sRemoteRiceiver & " 이 서버에서 실행중이지 않아 명령을 전달하지 못하였습니다.")
	;endif

	;_debug($_runReportPath)
	for $i=3 to ubound($cmdline) -1
		$sCmdLine3 &= '"' &  $cmdline[$i] & '"' & " "
	next

	_writeRemoteCommand($sCmdLine1, $sCmdLine2, $sCmdLine3)

	_debug($sCmdLine3)

	writeRmoteLog($cmdline[1] & " command request." & $sCmdLine2 & " " & $sCmdLine3)

	for $i=1 to 90
		;_debug("wait :" & $i)
		if mod($i,10) = 0 then writeRmoteLog("reponse wait " & 90 - $i &"s" )
		$sResult = _readRemoteCommandResult()
		sleep (1000)
		if $sResult = "True" then
			$iExitCode = 0
			exitloop
		endif
	next

	;_readRemoteCommand($sTemp1, $sTemp2)
	;_debug($sTemp1, $sTemp2)

	if $iExitCode <> 0 Then
		writeRmoteLog($cmdline[1] & " command Failed. Check GUITARCmdReceiver.exe is running")
	else
		writeRmoteLog($cmdline[1] & " command done.")
	endif

	exit $iExitCode

endfunc