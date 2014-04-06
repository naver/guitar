#include-once


Global enum $_sLogText_Start = "시작 : "
Global enum $_sLogText_Testing = "실행 : "
Global enum $_sLogText_Error = "오류 : "
Global enum $_sLogText_Info = "정보 : "
Global enum $_sLogText_PreError = "준비 : "
Global enum $_sLogText_End = "종료 : "
Global enum $_sLogText_Result = "결과 : "

Global enum $_sLogText_BrowserCapture = "브라우저 화면 : "
Global enum $_sLogText_BrowserAVI = "동영상 화면 : "

Global Const $_sTransparentKey = "_투명"
Global Const $_sUntitledName = "제목없음"

Global Const $_iColorTarget = 0xff0000
Global Const $_iColorCommand  = 0x0000AA
Global Const $_iColorTargetHtml = 0x0000ff
Global Const $_iColorCommandHtml = 0xaa0000
Global Const $_iColorComment = 0x339900
Global Const $_iColorError = 0x00ffff


Global $_iScriptRecursive
Global $_iDebugTimeInit
Global $_bLastcheckWaitCommand
Global $_bScriptRunPaused = False
Global $_sNewLoopVar = ""
Global $_iNewLoopValue = 0

Global $_sHTMLPreCahr = chr(2)

Global $_aLastUseMousePos[4]


#include <Process.au3>
#Include <ScreenCapture.au3>
#include <Math.au3>

#include "UIACommon.au3"
#include "UIAFormMain.au3"
#include "UIAAnalysis.au3"
#include "GUITARAU3VAR.au3"
#include "GUITARWEBDRIVER.au3"


#include ".\_include_nhn\_ImageGetInfo.au3"
#include ".\_include_nhn\_ImageSearch.au3"
#include ".\_include_nhn\_monitor.au3"


func getScriptLevelName($sScriptName, $_iScriptRecursive, $bIsEnd)

	local $sLevelName

	if $_iScriptRecursive > 1 then
		;$sLevelName = "├" & _StringRepeat("─",$_iScriptRecursive-2) & "→"

		$sLevelName = _StringRepeat("│",$_iScriptRecursive-2)

		$sLevelName = $sLevelName  & _iif( $bIsEnd, "└","├")
		$sLevelName = $sLevelName  & "→ "

	endif
	$sLevelName = $sLevelName & _GetFileName($sScriptName)

	return $sLevelName

endfunc


Func checkScriptEndLine(byref $aScript, $index, $iRunEnd)

	local $bEnd = True
	local $iEndCount

	$iEndCount = _iif ($iRunEnd = -1 ,ubound($aScript) -1 , $iRunEnd)

	;debug($index + 1, $iEndCount, ubound($aScript))

	for $i = $index + 1 to $iEndCount

		if $aScript[$i][$_iScriptCheck] = $_iScriptAllCheckOK then
			$bEnd = False

			ExitLoop
		endif

	next

	return $bEnd

EndFunc

func runScript($sScriptName, $aScript, $iRunStart, $iRunEnd, byref $aRunCountInfo)
; 스크립트를 실행

	local $i
	local $j
	local $bResult = True
	local $aCommand
	local $aCommandPos
	local $aScriptRAW
	local $aPrimeCommand
	local $aTarget
	local $aTargetPos
	local $sErrorMsg
	local $aCurrentMousePos
	local $sScriptNameOnly
	local $sLogHeader
	local $iTcTotal
	local $bContineTest
	local $sNewTCID
	local $sNewTCHide
	local $sNewTCEmaillist
	local $sCommentMsg
	local $bExitLoop
	local $sTestDateTime
	local $sCurrentTarget
	local $sLastPrimeCommand
	local $sLastTestID = ""
	local $iLastAddPostion
	local $sNewTCComment
	local $bHeaderChange
	local $bSkipLine
	local $bSkipCommnad
	local $iBlockLevel = 1
	local $bLogWriteSkip
	local $aBlockSkip[100]
	local $aBlockLoop[100][6]
	local enum $iLoop_BlockLevel = 1 , $iLoop_BlockVar, $iLoop_BlockValue, $iLoop_BlockValueAdd, $iLoop_BlockStartLine
	local $bLoopStart = False
	local $bLoopRun = False
	local $iLastCommandStartTime
	local $bIncludeCommandExist
	local $iScriptEndLine
	local $bLastSkipLine
	local $sTCID

	$_runCommadLintTimeInit = _TimerInit()
	$_runCommadLintTimeStart = _Nowcalc()

	$_runScriptFileName = $sScriptName

	$aCurrentMousePos = MouseGetPos()

	if $_iScriptRecursive = 1 then
		writeRunLog($_sLogText_Start & $sScriptName)
	endif

	$_runRecursiveID [$_iScriptRecursive] = ""
	$_runRecursiveRunCount [$_iScriptRecursive] = 0
	$_runEmailAddList = ""
	$_runScriptNotRunID[$_iScriptRecursive] = ""

	$_runScriptRun[$_iScriptRecursive] = 0
	$_runRecursiveErrorCount[$_iScriptRecursive] = 0
	$_runRecursiveHide [$_iScriptRecursive] = "OFF"

	$iTcTotal = 0

	for $i = 1 to ubound ($aScript) -1
		if $iRunStart = 0 or ($i  >= $iRunStart and  $i  <= $iRunEnd - 1) then
			if $aScript[$i][$_iScriptCheck] = $_iScriptAllCheckOK then $iTcTotal += 1

			if $aScript[$i][$_iScriptCheck] = $_iScriptAllCheckComment then
				$sTCID = getTCID($aScript[$i][$_iScriptRaw])
				$_aRunReportInfo[$_iResultAll] += countRunReportInfoID($sTCID)
				if $sTCID <> "" then $_runScriptNotRunID[$_iScriptRecursive] &= $sTCID & @crlf
			endif

		endif
	next

	$aRunCountInfo[1] = $iTcTotal
	$aRunCountInfo[2] = 0
	$aRunCountInfo[3] = 0

	$_runScriptTotal[$_iScriptRecursive] = $iTcTotal


	$_iDebugTimeInit = _TimerInit()

	CloseUnknowWindow ($_runUnknowWindowList)

	$bIncludeCommandExist = False

	if $_iScriptRecursive = 1 and IsHWnd($_hBrowser) then hBrowswerActive ()

	; 종료 라인 (Tray 출력용)
	$iScriptEndLine = $iRunEnd
	if $iScriptEndLine = 0 then $iScriptEndLine = ubound ($aScript) -1

	for $i = 1 to ubound ($aScript) -1

		$_runCommadLintTimeInit = _TimerInit()
		$_runCommadLintTimeStart = _Nowcalc()


		$bSkipLine = False
		$bLogWriteSkip = False
		$bLoopStart = False
		$_runFullScreenWork = False
		$_runAreaWork[0] = False

		if $iRunStart = 0 or ($i  >= $iRunStart and  $i  <= $iRunEnd ) then

			$sScriptNameOnly = getScriptLevelName($sScriptName, $_iScriptRecursive, checkScriptEndLine($aScript, $i, $iRunEnd - 1))

			if $aScript[$i][$_iScriptCheck] = $_iScriptAllCheckOK then

				; 제외한 항목 갯수
				if $sLastTestID <> $_runRecursiveID [$_iScriptRecursive] and $_runRecursiveID [$_iScriptRecursive] <> ""  then
					$sLastTestID = $_runRecursiveID [$_iScriptRecursive]
					$_aRunReportInfo[$_iResultSkip] -= countRunReportInfoID($_runRecursiveID [$_iScriptRecursive])
					$iLastAddPostion = StringInstr($_aRunReportInfo[$_sResultSkipList], @crlf,0,-1,stringlen($_aRunReportInfo[$_sResultSkipList]))

					if $iLastAddPostion > 0 then
						$_aRunReportInfo[$_sResultSkipList] = StringLeft($_aRunReportInfo[$_sResultSkipList], $iLastAddPostion -1)
					Else
						$_aRunReportInfo[$_sResultSkipList] = ""
					endif

				endif

				if $bLoopRun = True then $aRunCountInfo[1] += 1

				$_runScriptRun[$_iScriptRecursive] += 1
				$aRunCountInfo[2] += 1

				setProgressBar()

				$sTestDateTime = _NowCalc()

				$_runRecursiveRunCount [$_iScriptRecursive] += 1

				$sLogHeader = "[" & $sScriptNameOnly & "/" & $_runRecursiveID [$_iScriptRecursive] & "/" & $aScript[$i][$_iScriptLine] & "] - "
				;$sLogHeader = "[" & $sScriptNameOnly & "/" & $_runRecursiveID [$_iScriptRecursive] & "/" & $_runRecursiveRunCount [$_iScriptRecursive] & " (" & $aScript[$i][$_iScriptLine] & ")" & "] - "

				$sCommentMsg = ""
				$aCommand = StringSplit($aScript[$i][$_iScriptCommand],$_sCommandSplitChar)
				$aCommandPos = StringSplit($aScript[$i][$_iScriptCommandStartPos],$_sCommandSplitChar)
				$aTarget = StringSplit($aScript[$i][$_iScriptTarget],$_sCommandSplitChar)
				$aTargetPos = StringSplit($aScript[$i][$_iScriptTargetStartPos],$_sCommandSplitChar)
				$aPrimeCommand = StringSplit($aScript[$i][$_iScriptPrimeCommand],$_sCommandSplitChar)
				$aScriptRAW = $aScript[$i][$_iScriptRaw]

				$iLastCommandStartTime = _Nowcalc()

				if $_runCmdRunning = False and $_runTrayToolTip = True then
					;TrayTip($_sProgramName & " [" & StringFormat("[%4d]", $aScript[$i][$_iScriptLine]) & "/" & StringFormat("[%4d]", $iRunEnd) & "]" , $aScriptRAW,30,1)
					TrayTip($_sProgramName & " [" & $aScript[$i][$_iScriptLine] & "/" & $iScriptEndLine & "]" , $aScriptRAW,30,1)
				endif

				;msg($aTarget)
				;_ArrayDisplay($aTarget)


				for $j=1 to ubound($aCommand) -1

					; 블럭 시작
					if $aPrimeCommand[$j] = $_sCommandBlockStart then

						$iBlockLevel += 1

						if $bSkipLine or $aBlockSkip[$iBlockLevel-1] then
							$aBlockSkip[$iBlockLevel] = True
						Else
							$aBlockSkip[$iBlockLevel] = False
							$bLogWriteSkip = False

							if $_sNewLoopVar <> "" then

								$aBlockLoop[$iBlockLevel][$iLoop_BlockLevel] = True
								$aBlockLoop[$iBlockLevel][$iLoop_BlockVar] = $_sNewLoopVar
								$aBlockLoop[$iBlockLevel][$iLoop_BlockValue] = $_iNewLoopValue
								$aBlockLoop[$iBlockLevel][$iLoop_BlockStartLine] = $i + 1
								$aBlockLoop[$iBlockLevel][$iLoop_BlockValueAdd] = 0

								$_sNewLoopVar = ""
								$_iNewLoopValue = ""

								;msg($aBlockLoop)
							endif

						endif


					endif

					; 블럭 종료
					if $aPrimeCommand[$j] = $_sCommandBlockend  then

						if $aBlockLoop[$iBlockLevel][$iLoop_BlockLevel] = True then

							getRunVar($aBlockLoop[$iBlockLevel][$iLoop_BlockVar], $aBlockLoop[$iBlockLevel][$iLoop_BlockValueAdd])

							;debug("증가값 " &  $aBlockLoop[$iBlockLevel][$iLoop_BlockValue] & "," &  $aBlockLoop[$iBlockLevel][$iLoop_BlockValueAdd] )

							; 변수값을 비교해 넘어갔을 경우 다음 명령 수행
							if $aBlockLoop[$iBlockLevel][$iLoop_BlockValue] <= $aBlockLoop[$iBlockLevel][$iLoop_BlockValueAdd]  then
								$aBlockLoop[$iBlockLevel][$iLoop_BlockLevel] = False
								$aBlockLoop[$iBlockLevel][$iLoop_BlockVar] = ""
								$aBlockLoop[$iBlockLevel][$iLoop_BlockValue] = 0
								$aBlockLoop[$iBlockLevel][$iLoop_BlockValueAdd] = 0
								$aBlockLoop[$iBlockLevel][$iLoop_BlockStartLine] = 0
								$bLoopStart = False
								$bLoopRun = False

							else
								; 남아 있을 경우 블럭시작 부분분터 재시작함.
								$aBlockLoop[$iBlockLevel][$iLoop_BlockValueAdd] += 1

								; 증가된  내용을 공용변수에 저장
								addSetVar ($aBlockLoop[$iBlockLevel][$iLoop_BlockVar] & "=" & $aBlockLoop[$iBlockLevel][$iLoop_BlockValueAdd], $_aRunVar)
								$bLoopStart = True

								;debug("변수값 " & $aBlockLoop[$iBlockLevel][$iLoop_BlockVar] & ":" & $aBlockLoop[$iBlockLevel][$iLoop_BlockValue] )

								; 뒤에서 빠지는것을을 미리 보정하여 원래 level을 유지하도록 함
								$iBlockLevel += 1
							endif
						endif

						$iBlockLevel -= 1
					endif

					;debug($iBlockLevel)

					if $aBlockSkip[$iBlockLevel] = true or $bSkipLine = True then
						; 처음부터 Skip인 경우 로그 적는 대상에서 제외할것
						if $j=1 then
							$bLogWriteSkip = True
							; 전체/실행 목록에서 하나씩  지움
							;$aRunCountInfo[2] -= 1
							;$aRunCountInfo[1] -= 1
						endif

						writeDebugTimeLog("SKIP --------------------------------:" & "command:" & $aCommand[$j] & ", target:" & $aTarget [$j] )
						ContinueLoop
					endif


					$_iDebugTimeInit = _TimerInit()

					writeDebugTimeLog("시작 -------------------------------------------------------------------------------------")

					writeDebugTimeLog ("command:" & $aCommand[$j] & ", target:" & $aTarget [$j])

					if $_runContinueTest and  $_runErrorResume = "LINE" then
						$bContineTest = True
					else
						$bContineTest = False
					endif

					; 타겟이 없고 명령만 있는경우

					if ubound($aTarget) -1 >= $j then
						$sCurrentTarget = $aTarget [$j]
					Else
						$sCurrentTarget = ""
					endif

					if $aPrimeCommand[$j] = $_sCommandInclude then



						if stringinstr($sLogHeader, "└") > 0  then
							$sLogHeader = stringreplace($sLogHeader, "└","├")
							$sScriptNameOnly = stringreplace($sScriptNameOnly, "└","├")
							$bHeaderChange = True
						else
							$bHeaderChange = False
						endif

						$bIncludeCommandExist = True
						;writeRunLog ($_sLogText_Testing & $sLogHeader & $aScriptRAW & " (시작)" & writePassFail(True), $i)

						writeDebugTimeLog("리포트 포맷 생성")
						;makeReportLogFormat($aCommand, $aCommandPos, $aTarget, $aTargetPos, $sScriptNameOnly, $_runRecursiveID [$_iScriptRecursive], $aScript[$i][$_iScriptLine] , getReportDetailTime(),  "P", $aScriptRAW & " (시작) ", $_runErrorMsg, $sCommentMsg)
						writeDebugTimeLog("리포트 포맷 생성 종료")

						if $bHeaderChange then
							$sScriptNameOnly = stringreplace($sScriptNameOnly, "├", "└")
							$sLogHeader = stringreplace($sLogHeader, "├", "└")
						endif

					endif

					$_runErrorMsg= ""

					; 스크립트 에러 검증이 켜져 있고, 이전 수행명령어가 검증이 필요한 경우 수행
					; 이전에 스크립트 오류가 발생한경우 바로 다음에는 스크립트 오류 검사를 제외함  (브라우저 접속시는 제외할것)
					if $_runScriptErrorCheck = True and checkScriptErrorCheckCommand ($sLastPrimeCommand) and $_runLastScriptErrorCheck <> True  then
						if $_runBrowser = $_sBrowserIE or $_runBrowser = $_sBrowserFF or  $_runBrowser = $_sBrowserCR  then
							if CheckScriptError($_runBrowser) then captureCurrentBorwser($_runErrorMsg, False)
						endif
					endif


					; 에러가 없는 경유 신규 명령어 실행
					if $_runErrorMsg= "" then $bResult = runCommand($aCommand[$j], $aPrimeCommand[$j], $sCurrentTarget , $sCommentMsg)

					;if $bResult = False then debug("에러 1" & $aScriptRAW )


					;debug("x1 = " & $bResult)

					if $aPrimeCommand[$j] = $_sCommandInclude then

						if $_runRecursiveErrorCount[$_iScriptRecursive + 1] > 0 then $bResult = False

						;writeRunLog ($_sLogText_Testing & $sLogHeader & $aScriptRAW & $sIncludeEndString, $i)
						writeDebugTimeLog("리포트 포맷 생성")
						writeDebugTimeLog("리포트 포맷 생성 종료")

						if $_runContinueTest = True then
							if checkScriptStopping() then
								$bContineTest = False
							Else
								$bContineTest = True
							endif
						endif

					endif

					;debug("x2 = " & $bResult)
					if $_runErrorMsg <> "" then
						;debug("에러 2" & $aScriptRAW )
						$bResult = False
						exitloop
					endif

					;debug("x22 = " & $bResult)

					; 조건문의 결과가 틀린 경우
					if ($aPrimeCommand[$j] == $_sCommandIf  or $aPrimeCommand[$j] == $_sCommandIfNot or $aPrimeCommand[$j] == $_sCommandTextIf  or $aPrimeCommand[$j] == $_sCommandTextIfNot  or  $aPrimeCommand[$j] == $_sCommandValueIf  or $aPrimeCommand[$j] == $_sCommandValueIfNot  ) then
						if $bResult == False then
						;if ($aPrimeCommand[$j] == $_sCommandIf and $bResult == False) or ($aPrimeCommand[$j] == $_sCommandIfNot and $bResult == True) then
							;debug ("조건문 실패 : " & $aPrimeCommand[$j] , $bResult)
							$bResult = True
							$bSkipLine = True
						endif
						$bResult = True
					endif

					;if $bResult = False then debug("에러 3" & $aScriptRAW )

					if $bResult = False or checkScriptStopping() then

						$bResult = False

						exitloop
					endif

					$sLastPrimeCommand = $aPrimeCommand[$j]

					writeDebugTimeLog("종료 ------------------------------------------------------------------------------------")

				next


				writeDebugTimeLog("html 로그 기록전")

				if $bResult = False then

					; 최종 에러라인을 기록하여 나중에 완료후 스크롤 이동시에 활용
					$_runFirstErrorLine = $i


					if $_aLastUseMousePos[1] <> "" then
						_StringAddNewLine($_runErrorMsg  , " (최근 사용 이미지 좌표 : " & $_aLastUseMousePos[1] & "," & $_aLastUseMousePos[2] & ")")
						;$_runErrorMsg = $_runErrorMsg  & " (최근 사용 이미지 좌표 : " & $_aLastUseMousePos[1] & "," & $_aLastUseMousePos[2] & ")"
					endif
				endif


				; 로그를 남기도록 하거나, 실패이면서 숨김인 경우 출력
				if (($bResult = False and $_runRecursiveHide [$_iScriptRecursive] = "ON") or ($_runRecursiveHide [$_iScriptRecursive] = "OFF") and $bLogWriteSkip = False) then

					;debug($bLogWriteSkip, $aScriptRAW )
					makeReportLogFormat($aCommand, $aCommandPos, $aTarget, $aTargetPos, $sScriptNameOnly, $_runRecursiveID [$_iScriptRecursive],  $aScript[$i][$_iScriptLine]  , getReportDetailTime(),  _iif($bResult,"P","F"), $aScriptRAW , $_runErrorMsg, $sCommentMsg)
					writeRunLog($_sLogText_Testing & $aScriptRAW & writePassFail($bResult), $i)

				endif

				writeDebugTimeLog("html 로그 기록후")


				if (($bResult = False and $_runRecursiveHide [$_iScriptRecursive] = "ON") or ($_runRecursiveHide [$_iScriptRecursive] = "OFF") and $bLogWriteSkip = False) then

					if $sCommentMsg <> "" then writeRunLog ($_sLogText_Info & $sLogHeader & $sCommentMsg, $i, False)
					if $_runErrorMsg <> "" then writeRunLog($_sLogText_Error & $sLogHeader & $_runErrorMsg, $i, False)

				endif

				$_runErrorMsg  = ""


				if $bResult = False then
					if	$_runLastFailTCID <> $_runRecursiveID [$_iScriptRecursive] and $_runRecursiveID [$_iScriptRecursive] <> "" then
						$_runLastFailTCID = $_runRecursiveID [$_iScriptRecursive]
						$_aRunReportInfo[$_iResultFail] += countRunReportInfoID($_runRecursiveID [$_iScriptRecursive])
					endif
				endif

				; 최종 종료
				if ($bResult = False and $bContineTest = False) or checkScriptStopping() then
					$bResult = False
					exitloop
				endif

			Elseif  $aScript[$i][$_iScriptCheck] = $_iScriptAllCheckComment then

				$bResult = True

				; Skip 처리된 경우 전체적으로 예외 처리할것
				if $bLogWriteSkip = False  and $aBlockSkip[$iBlockLevel] = False then

					; 커맨트 명령줄인 경우
					; ID값을 분석하여 기록할 것
					$sNewTCID = getTCID($aScript[$i][$_iScriptRaw])
					;debug ($sNewTCID)
					if $sNewTCID <> "" then
						$_runScriptNotRunID[$_iScriptRecursive] = stringreplace($_runScriptNotRunID[$_iScriptRecursive],  $sNewTCID & @crlf, "")
						$_runRecursiveID [$_iScriptRecursive] = $sNewTCID
						$_aRunReportInfo[$_iResultRun] += countRunReportInfoID($_runRecursiveID [$_iScriptRecursive])
						$_aRunReportInfo[$_iResultSkip] += countRunReportInfoID($_runRecursiveID [$_iScriptRecursive])
						;$_aRunReportInfo[$_sResultSkipList] = countRunReportInfoID($_runRecursiveID [$_iScriptRecursive])
						;debug(_GetFileName($sScriptName) & " (" & $_runRecursiveID [$_iScriptRecursive] & ")")
						;debug($_aRunReportInfo[$_sResultSkipList])
						_StringAddNewLine($_aRunReportInfo[$_sResultSkipList], _GetFileName($sScriptName) & " : " & $_runRecursiveID [$_iScriptRecursive] )
						;debug($_aRunReportInfo[$_sResultSkipList])
					endif

					$sNewTCComment = getTCComment($aScript[$i][$_iScriptRaw])

					if $sNewTCComment <> "" then
						if (($bResult = False and $_runRecursiveHide [$_iScriptRecursive] = "ON") or ($_runRecursiveHide [$_iScriptRecursive] = "OFF") and $bLogWriteSkip = False) then
							makeReportLogFormat("", "", "", "", $sScriptNameOnly, $_runRecursiveID [$_iScriptRecursive], $aScript[$i][$_iScriptLine] , getReportDetailTime(),  "P", "","",   $sNewTCComment)
						ENDIF

					endif

					$sNewTCHide = getTCHide($aScript[$i][$_iScriptRaw])
					if $sNewTCHide <> "" then $_runRecursiveHide [$_iScriptRecursive] = $sNewTCHide

					$sNewTCEmaillist = getTCEmailList($aScript[$i][$_iScriptRaw])
					if $sNewTCEmaillist <> "" then
						if $_runEmailAddList  <> "" then $_runEmailAddList  = $_runEmailAddList  & ";"
						$_runEmailAddList = $_runEmailAddList & $sNewTCEmaillist
					endif

				endif

			else
				$bResult = True
				;debug("예외 명령어 : " & $aScript[$i][$_iScriptRaw])

			endif

			; 테스트 실패 및 테스트 계속진행이 안될 경우 완전 종료
			if $bResult = False then

				;debug("에러 5" & $aScriptRAW & " " & $bResult)
				$_runRecursiveErrorCount[$_iScriptRecursive] += 1
				$aRunCountInfo[3] += 1
				$_runErrorCount = $_runErrorCount + 1
				setTestStatusBox ("테스트중", True)

			endif
		endif

		if $bLoopStart then
			$bLoopRun = True
			$i = $aBlockLoop[$iBlockLevel][$iLoop_BlockStartLine] -1
		endif

		$_runLastCommandStartTime = $iLastCommandStartTime

		$bLastSkipLine = $bSkipLine

	next

	;if $bResult = False then _viewLastUseedImage()

	if $_iScriptRecursive = 1 then

		writeRunLog($_sLogText_End & $sScriptName)
		writeRunLog($_sLogText_Result & _iif($bResult,"성공","실패"))

	endif

	if $bResult = False and $aRunCountInfo[3] = 0 then $aRunCountInfo[3] = 1


	MouseMove($aCurrentMousePos[0], $aCurrentMousePos[1],0)


	$_aRunReportInfo[$_sResultNorRunList] &= $_runScriptNotRunID[$_iScriptRecursive]



	return $bResult

endfunc


func runCommand($sScriptCommandText, $sScriptCommand, $sScriptTarget, byref $sCommentMsg)
; 명령어(단위)를 수행

	local $bResult = False
	local $sNewVarName
	local $sNewVarValue
	local $iCommandTimeInit
	local $bVarAddInfo
	local $iCommandSleep

	local $sSetValueNewName
	local $sSetValueNewValue
	local $sInputType

	writeDebugTimeLog("runCommand 펑션 시작")

	if checkScriptStopping() then Return False

	_setLastImageArrayInit()

	;debug($sScriptCommandText)

	; 변수 값을 실제 값으로 변경함
	if getVarType($sScriptTarget) and ($sScriptCommand <>  $_sCommandTagCountGet and $sScriptCommand <>  $_sCommandTagAttribGet and $sScriptCommand <> $_sCommandSet and $sScriptCommand <> $_sCommandVariableSet and $sScriptCommand <> $_sCommandValueIf and $sScriptCommand <> $_sCommandValueIfNot and $sScriptCommand <> $_sCommandExcute and $sScriptCommand <> $_sCommandLoop  and $sScriptCommand <>  $_sCommandPartSet and $sScriptCommand <>  $_sCommandSingleQuotationChange and $sScriptCommand <> $_sCommandAU3VarRead and $sScriptCommand <> $_sCommandJSRun ) then

		if ConvertVarFull($sScriptTarget, $sNewVarValue, $bVarAddInfo, ",", True) = False Then
			return False
		Else
			_StringAddNewLine( $sCommentMsg,$bVarAddInfo)
			$sScriptTarget = $sNewVarValue
		endif

	endif


	; 이전에도 click, 이고, 다음 command도 클릭일 경우 2배 쉬도록 함.
	;if checkWaitCommand ($sScriptCommand) and $_bLastcheckWaitCommand = True then
		;writeDebugTimeLog("runCommand 연속명으로 쉬기 : " & $_runCommandSleep * 2)
		;RunSleep($_runCommandSleep * 2)
	;endif


	; 웹드라이버 모드가 아닌 경우에만 창 설정을 확인
	if $_runWebdriver = False then
		writeDebugTimeLog("runCommand 윈도우 Active")
		;debug("명령시작:" & _NowCalc())
		; 브라우저 설정이 필요 없는 경우는 제외 !!!!!!!!!!!!!!!!! select
		Switch $sScriptCommand

			case $_sCommandClick,$_sCommandAssert, $_sCommandInput, $_sCommandBrowserEnd, $_sCommandIf, $_sCommandIfNot,  $_sCommandTextIf, $_sCommandTextIfNot, $_sCommandNavigate, $_sCommandTextAsert, $_sCommandMouseMove,  $_sCommandMouseDrag, $_sCommandMouseDrop, $_sCommandRightClick, $_sCommandCapture, $_sCommandMouseHide, $_sCommandSwipe, $_sCommandGoHome, $_sCommandTagAttribGet, $_sCommandTagAttribSet, $_sCommandTargetCapture, $_sCommandTagCountGet, $_sCommandJSRun , $_sCommandJSInsert

				; 전체작업대상인 경우 에러처리에서 예외
				if IsHWnd($_hBrowser) = 0  and $_runFullScreenWork = False  then

					$_runErrorMsg = "명령 실행 실패. 웹 브라우저가 생성되지 않았습니다. "
					captureCurrentBorwser($_runErrorMsg, True)
					return False
				Else
					; 외부 API로 메세지 창 임으로 브라우저 창을 오픈하는것을 제외로 함.

					if $sScriptCommand <> $_sCommandTextAsert and $sScriptCommand <> $_sCommandKeySend  then

						; 스크립트 오류창이 열린 경우 닫히도록 함.
						if $_runScriptErrorCheck = True and $_runBrowser = $_sBrowserIE then CheckScriptError($_runBrowser)



						if hBrowswerActive() = 0  and  ($_runBrowser <> $_sBrowserCR) then
							$_runErrorMsg = "명령 수행 전 웹 브라우저를 활성화 할 수 없습니다 : " & $sScriptCommandText & ", " & $sScriptTarget
							captureCurrentBorwser($_runErrorMsg, True)
							return False
						endif

					endif

				endif
			EndSwitch


		;debug("명령종료:" & _NowCalc())

		writeDebugTimeLog("runCommand 윈도우 Active 완료")
	endif

	;if TimerDiff($iCommandTimeInit) < $_runCommandSleep then


	; 테스트 대상이 브라우저가 아닌 경우 마우스를 숨기도록 함.
	if checkTargetisBrowser($_runBrowser) = False and checkMouseHideCommand($sScriptCommand) then moveMouseTop(0)

	$iCommandTimeInit = _TimerInit()

	writeDebugTimeLog("runCommand 윈도우 닫기")


	;debug("명령수행 : " & $sScriptCommand)

	writeDebugTimeLog("runCommand 명령 수행 전")

	Switch  $sScriptCommand

		case $_sCommandClick
			$bResult = commandClick($sScriptTarget, "left")
			;if $bResult then RunSleep($_runPageSleep / 2)

		case $_sCommandBrowserRun
			$bResult = commandBrowserRun($sScriptTarget)

		case $_sCommandBrowserEnd
			$bResult = commandBrowserEnd()

		case $_sCommandNavigate
			; 키를 입력을 빠르게 하여 URL 입력
			SetKeyDelay(0)

			$bResult = commandNavigate($sScriptTarget, True)

			if $bResult = True and $_runScriptErrorCheck = True then
				;msg("왔어 : " & $sScriptTarget & " " & $_runLastScriptErrorCheck)
				if CheckScriptError($_runBrowser) = True then
					$_runErrorMsg = "브라우저 자바스크립트 오류발생"
					captureCurrentBorwser($_runErrorMsg, False)
					$bResult = False
				endif
			endif

			_StringAddNewLine($sCommentMsg, "URL : " & $sScriptTarget)

			SetKeyDelay()
			;if $bResult then RunSleep($_runPageSleep * 2)

		case $_sCommandInput

			if $_runInputType = "UNICODE" or $_runInputType = "ANSI"  Then
				$sInputType = $_runInputType
			else
				$sInputType = ""
			endif

			if $sInputType = "" then $sInputType = _iif(checkTargetisBrowser($_runBrowser),"UNICODE", "ANSI")

			$bResult = commandKeySend($sScriptTarget,$sInputType)

			writeDebugTimeLog("$_sCommandInput 완료")
			runsleep($_runCommandSleep )

		case $_sCommandKeySend
			$bResult = commandKeySend($sScriptTarget,"ANSI")
			writeDebugTimeLog("$_sCommandKeySend 완료")
			runsleep($_runCommandSleep )

		case $_sCommandAssert
			$bResult = commandAssert($sScriptTarget, $_runWaitTimeOut, True, False, True )

		case $_sCommandIf
			runsleep($_runCommandSleep * 2)
			$bResult = commandAssert($sScriptTarget,2000, False, True, True)
			_StringAddNewLine($sCommentMsg, "대상 찾기 : " & $sScriptTarget)
			_StringAddNewLine($sCommentMsg, "조건 : " & _iif($bResult,"만족","불만족"))

		case $_sCommandIfNot
			runsleep($_runCommandSleep * 2)
			$bResult = not(commandAssert($sScriptTarget,2000, False, True, False))
			_StringAddNewLine($sCommentMsg, "대상 찾기 : " & $sScriptTarget)
			_StringAddNewLine($sCommentMsg, "조건 : " & _iif($bResult,"만족","불만족"))

		case $_sCommandValueIf
			$bResult = commandValueIf($sScriptTarget, $sCommentMsg)


		case $_sCommandValueIfNot
			$bResult = not(commandValueIf($sScriptTarget, $sCommentMsg))

		case $_sCommandTextAsert
			$bResult = commandTextAsert($sScriptTarget)

		case $_sCommandTextIf
			runsleep($_runCommandSleep * 2)
			$bResult = commandTextAsert($sScriptTarget,2000, False)
			_StringAddNewLine($sCommentMsg, "Text 찾기  : " & $sScriptTarget)
			_StringAddNewLine($sCommentMsg, "조건:" & _iif($bResult,"만족","불만족"))

		case $_sCommandTextIfNot
			runsleep($_runCommandSleep * 2)
			$bResult = not(commandTextAsert($sScriptTarget,2000, False))
			_StringAddNewLine($sCommentMsg, "Text 찾기  : " & $sScriptTarget)
			_StringAddNewLine($sCommentMsg, "조건:" & _iif($bResult,"만족","불만족"))

		case $_sCommandInclude
			$bResult = commandInclude($sScriptTarget)

		case $_sCommandSet
			$bResult = commandSet($sScriptTarget, $sCommentMsg)

		case $_sCommandVariableSet
			$bResult = commandVariableSet($sScriptTarget)

		case $_sCommandExcute
			$bResult = commandExcute($sScriptTarget, $sCommentMsg)


		case $_sCommandAttach
			$bResult = commandAttach($sScriptTarget)

			if $bResult = True and $_runScriptErrorCheck = True then
				if CheckScriptError($_runBrowser) = True then
					captureCurrentBorwser($_runErrorMsg, False)
					$bResult = False
				endif
			endif

			;if $bResult  = True then
			;	if  $_runDebugLog  then captureCurrentBorwser($sCommentMsg, False)
			;endif

		case $_sCommandProcessAttach
			$bResult = commandProcessAttach($sScriptTarget)


		case $_sCommandSleep
			$bResult = commandSleep($sScriptTarget)


		case $_sCommandMouseMove
			$bResult = commandMouseDragandDrop($sScriptTarget, "move")

		case $_sCommandMouseDrag
			$bResult = commandMouseDragandDrop($sScriptTarget, "drag")

		case $_sCommandMouseDrop
			$bResult = commandMouseDragandDrop($sScriptTarget, "drop")

		case $_sCommandRightClick
			$bResult = commandClick($sScriptTarget, "right")

		case $_sCommandSuccess
			$bResult = True

		case $_sCommandFail

			captureCurrentBorwser($_runErrorMsg, False)
			$bResult = False

		case $_sCommandCapture
			$bResult  = captureCurrentBorwser($sCommentMsg, False)
			if $bResult  = False then _StringAddNewLine ( $_runErrorMsg , "이미지캡쳐에 실패하였습니다.")

		case $_sCommandMouseHide
			moveMouseTop()
			$bResult = True

		case $_sCommandMouseWheelUp
			MouseWheel("up")
			runsleep($_runCommandSleep * 2)
			$bResult = True

		case $_sCommandMouseWheelDown
			MouseWheel("down")
			runsleep($_runCommandSleep * 2)
			$bResult = True

		case $_sCommandDoubleClick
			$bResult = commandClick($sScriptTarget, "double")

		case $_sCommandComma
			; 지정된 $_runCommandSleep 시간 만큼 쉰다.
			runsleep($_runCommaDelay)

			$bResult = True

		case $_sCommandSwipe
			; X1Y1 -> X2Y2 좌표로 드래그&드롭한다. (1~9 수치)
			$bResult = commandSwipe($sScriptTarget)

		case $_sCommandGoHome
			$bResult = commandGoHome()

			; 블럭 설정, 시작
		case $_sCommandBlockStart, $_sCommandBlockend
			$bResult = True

		case $_sCommandLoop
			$bResult = commandLoop($sScriptTarget, $_sNewLoopVar, $_iNewLoopValue)

		case $_sCommandFullScreenWork
			$_runFullScreenWork = True
			$bResult = True

		case $_sCommandAreaCapture
			$bResult = commandAreaCapture($sScriptTarget, $sCommentMsg)

		case $_sCommandTagAttribGet
			$bResult = commandTagAttribGet($sScriptTarget, $sCommentMsg)

		case $_sCommandTagAttribSet
			$bResult = commandTagAttribSet($sScriptTarget, $sCommentMsg)

		case $_sCommandAreaWork
			$bResult = commandAreaWork($sScriptTarget, $sCommentMsg)

		case $_sCommandPartSet
			$bResult = commandPartSet($sScriptTarget, $sCommentMsg)

		case $_sCommandLogWrite
			$sCommentMsg = $sScriptTarget
			$bResult = True

		case $_sCommandSingleQuotationChange
			$bResult = CommandSingleQuotationChange($sScriptTarget)

		case $_sCommandAU3Run
			$bResult = CommandAU3Run($sScriptTarget)

		case $_sCommandAU3VarRead
			$bResult = CommandAU3VarRead($sScriptTarget, $sCommentMsg)

		case $_sCommandAU3VarWrite
			$bResult = CommandAU3VarWrite($sScriptTarget)

		case $_sCommandLongTab
			$bResult = commandClick($sScriptTarget, "long")

		case $_sCommandLocationTab
			$bResult = commandLocationTab($sScriptTarget, "location")

		case $_sCommandLocationLongTab
			$bResult = commandLocationTab($sScriptTarget, "locationlong")

		case $_sCommandLocationDoubleTab
			$bResult = commandLocationTab($sScriptTarget, "locationdouble")

		case $_sCommandTargetCapture
			$bResult = commandTargetCapture($sScriptTarget)

		case $_sCommandTagCountGet
			$bResult = commandTagCountGet($sScriptTarget, $sCommentMsg)

		case $_sCommandJSRun
			$bResult = commandJSRun($sScriptTarget, $sCommentMsg)

		case $_sCommandJSInsert
			$bResult = commandJSInsert($sScriptTarget, $sCommentMsg)

		case $_sCommandWDSessionCreate
			$bResult = commandWDSessionCreate($sScriptTarget, $sCommentMsg)

		case $_sCommandWDSessionDelete
			$bResult = commandWDSessionDelete()

		case Else
			$_runErrorMsg = "처리 가능한 명령가 아님 : " & $sScriptCommand
			$bResult = False


EndSwitch


writeDebugTimeLog("runCommand 명령 수행 후 : " & $sScriptTarget )

;RunSleep(10)

if checkWaitCommand ($sScriptCommand) then

	if checkScriptErrorCheckCommand ($sScriptCommand) then
		$iCommandSleep = $_runCommandSleep
	else
		$iCommandSleep = $_runCommandSleep - 60
	endif

	writeDebugTimeLog("runCommand Commond Sleep : " & $iCommandSleep  )
	RunSleep($iCommandSleep)

	$_bLastcheckWaitCommand = True
Else
	$_bLastcheckWaitCommand = False
endif

writeDebugTimeLog("runCommand 분기후 : " & $sScriptTarget  )

	;debug("명령수행 결과 : " & $bResult)

	;if $bResult = True then $_runErrorImageTarget =""

	if $bResult <> True then $bResult = False

	return $bResult

endfunc



func checkTagType($sNewValue, $iArgCount)

	local $iCount
	local $bRet  = False


	StringReplace($sNewValue, ":", "")
	$iCount = @extended

	if StringLeft($sNewValue,1) = "[" and StringRight($sNewValue,1) = "]"  and $iCount = $iArgCount then $bRet = True

	return $bRet

endfunc
; ----------------------------------------- Command ------------------------------------------------


Func commandWDSessionDelete()
; 세션종료
	local $shost, $aParamInfo
	local $bReturn = False

	if $_webdriver_current_sessionid = "" then
		WriteGuitarWebDriverError ( "생성된 Webdriver 세션정보가 없습니다." )
	else
		if _WD_delete_session () then
			$bReturn = True
			$_runWebdriver = False
			$_webdriver_current_sessionid =  ""
			$_webdriver_connection_host = ""
			_setCurrentBrowserInfo()
		else

			WriteGuitarWebDriverError ("Webdriver 세션 종료에 실패하였습니다. " )
		endif
	endif

	return $bReturn

EndFunc


Func commandWDSessionCreate($sScriptTarget, byref $sCommentMsg)
;세션생성

	local $shost, $aParamInfo
	local $bReturn = False

	if getWebdriverConnectionInfo($sScriptTarget, $shost, $aParamInfo) then
		if _WD_create_session ($shost, $aParamInfo) then
			$bReturn = True
			$_runWebdriver = True
			_setCurrentBrowserInfo()
			; 윈도우 크기 변경
			_setBrowserWindowsSize ("")
		else
			_StringAddNewLine ( $_runErrorMsg , "Webdriver 세션 생성에 실패하였습니다. " & $_webdriver_last_errormsg)
		endif
	else
		_StringAddNewLine ( $_runErrorMsg , "Webdriver 세션 생성 정보가 바르지 않습니다. {host=호스트정보,환경정보1=값1,환경정보n=값n}")
	endif
	_StringAddNewLine($sCommentMsg, "세션정보 : " & $shost & " , " & $_webdriver_current_sessionid)
	return $bReturn

EndFunc


func commandTargetCapture($sScriptTarget)
;대상캡쳐

	local $bRet = False
	local $sCommentMsg
	local $iTagEndLoc
	local $iImageFileNameStartLoc
	local $sTagInfo = $sScriptTarget
	local $sImageFileName

	$iTagEndLoc = Stringinstr($sScriptTarget,"]",0,-1,Stringlen($sScriptTarget))

	if $iTagEndLoc  = 0 then
		_StringAddNewLine ( $_runErrorMsg , "대상캡쳐 명령은 Tag지정 방식으로만 사용 가능합니다.")
		return $bRet
	endif

	$iImageFileNameStartLoc = Stringinstr($sScriptTarget,",",0,-1,Stringlen($sScriptTarget))

	if $iImageFileNameStartLoc > $iTagEndLoc then
	; 파일명이 지정된 경우 분리
		$sTagInfo = _Trim(Stringleft($sScriptTarget,$iImageFileNameStartLoc-1))
		$sImageFileName = "," & _Trim(StringTrimLeft($sScriptTarget,$iImageFileNameStartLoc))

		;debug($sTagInfo, $sImageFileName)

	endif

	$bRet = commandAssert($sTagInfo, $_runWaitTimeOut, True, False, True )

	if $bRet then
		$bRet  = commandAreaCapture($_aLastUseMousePos[3] & $sImageFileName, $sCommentMsg)
		if $bRet  = False then _StringAddNewLine ( $_runErrorMsg , "이미지캡쳐에 실패하였습니다.")
	endif


	return $bRet

endfunc


func commandProcessAttach($sScriptTarget)

	local $bRet  = False
	local $sProcessExe
	local $aPlist, $aWinList
	local $i

	getBrowserFullName ($sScriptTarget)

	$sProcessExe = getBrowserExe($sScriptTarget)


	;10 초 동안 대기
	if $sProcessExe = "" then
		_StringAddNewLine ( $_runErrorMsg , "브라우저나 실행파일에 대한 정보가 없습니다. : " & $sScriptTarget)
		Return False
	endif


	for $i=1 to 5

		$aPlist = getBrowserWindowAll($sProcessExe, $aWinList)

		; 프로세스가 존재하지 않거나, 배열을 찾은 경우 바로 종료
		if ProcessExists($sProcessExe) = 0 or  ubound($aPlist) > 1 then exitloop

		sleep (1000)

	next

	if ubound($aPlist) > 1 then
		$_runBrowser = $sScriptTarget
		$_hBrowser = $aPlist [1]

		;debug($_runBrowser, $_hBrowser)
		;msg($aPlist )

		_setCurrentBrowserInfo()

		WinActivate($_hBrowser)

		$bRet = True
	Else
		_StringAddNewLine ( $_runErrorMsg , "지정된 프로세스명이 실행중이지 않습니다. : " & $sProcessExe)
	endif

	return $bRet

endfunc


Func CommandAU3VarWrite($sScriptTarget)

	local $bRet  = False
	local $sNewName, $sNewValue, $iValueStart, $bTargetError

	$iValueStart = StringInStr($sScriptTarget,"=",True,1)

	$sNewName = _Trim(stringleft($sScriptTarget, $iValueStart-1))
	$sNewValue = stringTrimleft($sScriptTarget, $iValueStart)

	if $sNewName = "" or $sNewValue = "" then $bTargetError = True
	;if $sNewName = "" then $bTargetError = True

	if $bTargetError then
		_StringAddNewLine ( $_runErrorMsg , "명령 대상 값이 잘못 설정 되었습니다. ""AU3변수명=저장 할 값""")
		Return False
	endif

	_GUITAR_AU3VARWrite ($sNewName, $sNewValue)

	$bRet = True

	return $bRet

endfunc


Func CommandAU3VarRead($sScriptTarget,byref $sCommentMsg)

	local $bResult = True
	local $sNewValue
	local $sNewName
	local $bExtractCheck = False

	if getVarNameValue($sScriptTarget,  $sNewName, $sNewValue,"," ,$bExtractCheck) = False then
		$bResult = False
		_StringAddNewLine ( $_runErrorMsg , "변수 설정 정보가 잘못되었습니다.  ""$변수명=AU3변수명""")
	else
		$sNewValue = _GUITAR_AU3VARRead(_Trim($sNewValue))
		_StringAddNewLine($sCommentMsg, "변수정보 : " & $sNewName & "=" & $sNewValue)

		if addSetVar ($sNewName & "=" & $sNewValue, $_aRunVar, $bExtractCheck) = False Then
			_StringAddNewLine ( $_runErrorMsg , "변수 설정 정보가 잘못되었습니다.  ""$변수명=AU3변수명""")
			$bResult = False
		endif

	endif

	return $bResult

endfunc


Func CommandAU3Run($sScriptTarget)

	local $bRet  = False
	local $iExitCode
	local $sAutoitExe = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\AutoIt v3\Autoit" , "InstallDir") & "\AutoIt3.exe"
	local $sWorkPath

	$sWorkPath = @WorkingDir
	FileChangeDir (_GetPathName($_runScriptFileName))
	$sScriptTarget = FileGetShortName($sScriptTarget, 1)
	FileChangeDir ($sWorkPath)

	if FileExists($sScriptTarget) = 0 Then
		_StringAddNewLine( $_runErrorMsg, 'AU3 파일이 존재하지 않습니다. : ' & $sScriptTarget)
		return $bRet
	endif

	if FileExists($sAutoitExe) = 0 Then
		_StringAddNewLine( $_runErrorMsg, 'AutoIt V3가 설치되지 않았습니다.')
		return $bRet
	endif

	$iExitCode = ShellExecuteWait($sAutoitExe, $sScriptTarget)

	if $iExitCode = 0 then
		$bRet = True
	else
		_StringAddNewLine( $_runErrorMsg, 'AU3 파일 실행종료 코드가 오류 입니다. Exitcode : ' & $iExitCode)
	endif

	return $bRet

endfunc


Func CommandSingleQuotationChange ($sScriptTarget)

	local $sGetVar
	local $sNewName = $sScriptTarget

	if getRunVar($sNewName, $sGetVar) = False then
		_StringAddNewLine( $_runErrorMsg, "변수 정보 설정이 잘못 되었거나 값이 설정되지 않았습니다. : " &  _Trim($sNewName))
		;debug($sNewName,  $sGetVar)
		Return False
	endif

	$sGetVar = stringreplace($sGetVar, "'", "''")

	;debug($sNewName, $sGetVar)

	addSetVar ($sNewName & "=" & $sGetVar, $_aRunVar, True)

	return true

endfunc


;부분설정
Func commandPartSet($sScriptTarget,byref $sCommentMsg)

	local $bReturn = False
	local $sPartVar
	local $sFullVar
	local $sFullVarContext
	local $sPartNumber
	local $aTempSplit
	local $sSplitChar = chr(1)
	local $iSplitCount
	local $sSetVar

	if StringRegExp($sScriptTarget,"^\$.+\s*=\s*\$.+,\s*\d",0) = 0 then
		_StringAddNewLine( $_runErrorMsg, '대상 지정 형태가 바르지 않습니다. (예, "$부분=$전체,3") : ' & $sScriptTarget)
		return $bReturn
	endif

	$aTempSplit = StringSplit($sScriptTarget,"=")
	$sPartVar = _trim($aTempSplit[1])
	$aTempSplit = StringSplit($aTempSplit[2],",")



	$sFullVar = _trim($aTempSplit[1])
	$sPartNumber = number($aTempSplit[2])

	; 기존 변수 값을 가져옴
	if getRunVar($sFullVar, $sFullVarContext) = False then
		_StringAddNewLine( $_runErrorMsg, "변수 정보 설정이 잘못 되었거나 값이 설정되지 않았습니다. : " &  _Trim($sFullVar))
		Return False
	endif

	$sFullVarContext = StringReplace($sFullVarContext, ",", $sSplitChar)
	$sFullVarContext = StringReplace($sFullVarContext, @TAB, $sSplitChar)

	$aTempSplit = StringSplit($sFullVarContext,$sSplitChar)

	$iSplitCount = ubound($aTempSplit) - 1
	if not ($sPartNumber >= 1 and  $sPartNumber <= $iSplitCount) then
		_StringAddNewLine( $_runErrorMsg, "부분설정 할 범위가 잘못 지정 되었습니다. 전체 : " &  $iSplitCount & "개")
		Return False
	endif

	$sSetVar = $sPartVar & "=" & $aTempSplit[$sPartNumber]

	$bReturn = commandSet($sSetVar, $sCommentMsg)

	return $bReturn

endfunc


;부분대상작업
Func commandAreaWork($sXY, byref $sCommentMsg)

	local $bReturn = False
	local $iX1, $iX2, $iY1, $iY2
	local $aAreaPos
	local $sCaptureFileName
	local $bParsingError


	$aAreaPos = getXYAreaPosition($sXY , $sCommentMsg, $bParsingError)

	if ubound($aAreaPos)-1 <> 4 or $bParsingError = True  then
		;debug($bParsingError)
		$_runErrorMsg = '대상 좌표값이 바르지 않습니다. 브라우저 기준 상대좌표로 "X1,Y1,X2,Y2" 형태이어야 합니다. (예, "100,100,120,150") : ' & $sXY
		return $bReturn
	endif

	$bReturn = True

	; 0 = 부분작업상태, 1~4 좌표값 (매번 명령줄 마다 초기화함)
	$_runAreaWork[0] = True
	$_runAreaWork[1] = Number($aAreaPos[1])
	$_runAreaWork[2] = Number($aAreaPos[2])
	$_runAreaWork[3] = Number($aAreaPos[3])
	$_runAreaWork[4] = Number($aAreaPos[4])

	; 상대좌표로 지정
	$_runAreaWork[5] = True

	return $bReturn

endfunc


func commandJSRun($sScriptTarget, byref $sCommentMsg)

	local $bTargetError = False
	local $sJSScriptName
	local $bResult
	local $aImageFile
	local $x, $y
	local $bFileNotFoundError
	local $sTempSplit
	local $Object
	local $oMyError
	local $bVarAddInfo
	local $sNewName, $sNewValue
	local $sJSReturn = ""

	$sNewValue = $sScriptTarget

	if $_runWebdriver = False then

		$bTargetError = NOT( getIEObjectType($sNewValue))

		if $bTargetError = False then

			$sTempSplit = StringSplit(StringTrimRight($sNewValue,1),":")
			;debug($sTempSplit)
			if ubound($sTempSplit) < 6 then $bTargetError = tRUE
		endif

		if $bTargetError then
			_StringAddNewLine ( $_runErrorMsg , "대상 값이 잘못 설정 되었습니다. ""[TAG명:TAG속성비교값:찾을 TEXT값:순번:실행스크립트명]""")
			Return False
		endif

		$sJSScriptName = _Trim($sTempSplit [ubound($sTempSplit)-1])

		if $sJSScriptName = "" then
			_StringAddNewLine ( $_runErrorMsg , "실행할 JS가 지정되지 않았습니다." )
			Return False
		endif

		;"$이미지정보=[sdsdsds:Text]" 속성읽기 한다.
		$bResult = getRunCommnadImageAndSearchTarget ($sNewValue, $aImageFile,  $x , $y, True , $_runWaitTimeOut, $bFileNotFoundError, False)

		if $bResult  then
			; 찾은경우

			$Object = $aImageFile[1]
			$oMyError = ObjEvent("AutoIt.Error","UIAIE_NullError")

			SetError(0)
			;debug($Object.document.domain)
			$Object.document.parentWindow.execScript($sJSScriptName)
			;$Object.document.parentWindow.eval($sJSScriptName)


			if @error <> 0 then
				$bResult = False
				;msg("오류")
				_StringAddNewLine ( $_runErrorMsg , "JS 실행에 실패 하였습니다. " & $sScriptTarget )
			Else

				;addSetVar ($sNewName & "=" & $sJSReturn, $_aRunVar)
				;_StringAddNewLine( $sCommentMsg, "변수정보 : " & $sNewName & "=" & $sJSReturn)
			endif

			$oMyError = ObjEvent("AutoIt.Error")

		endif

	else
		; WEB드라이버 형태인 경우

		; 분리되지 않은 chr(0)으로 전달


		if getVarNameValue($sScriptTarget,  $sNewName, $sNewValue, chr(0)) = False then $bTargetError = True

		IF $bTargetError = False THEN $bTargetError = NOT(isWebdriverParam($sNewValue))

		if $bTargetError then
			_StringAddNewLine ( $_runErrorMsg , "대상 값이 잘못 설정 되었습니다. ""$변수명={자바스크립트}""")
			Return False
		endif

		$sJSScriptName = StringTrimRight(StringTrimLeft($sNewValue,1),1)

		if $sJSScriptName = "" then
			_StringAddNewLine ( $_runErrorMsg , "실행할 JS가 지정되지 않았습니다." )
			Return False
		endif
		;debug($sJSScriptName, $sJSReturn)
		$bResult = _WD_execute_script ($sJSScriptName, $sJSReturn)

		if $bResult Then
			addSetVar ($sNewName & "=" & $sJSReturn, $_aRunVar, True)
			_StringAddNewLine( $sCommentMsg, "변수정보 : " & $sNewName & "=" & $sJSReturn)
		else
			WriteGuitarWebDriverError ()
		endif


	endif

	return $bResult

endfunc


func commandJSInsert($sScriptTarget, byref $sCommentMsg)

	local $bTargetError = False
	local $sJSScriptContents
	local $bResult
	local $aImageFile
	local $x, $y
	local $bFileNotFoundError
	local $sTempSplit
	local $Object
	local $oMyError

	$bTargetError = NOT( getIEObjectType($sScriptTarget))

	if $bTargetError = False then
		$sTempSplit = StringSplit(StringTrimRight($sScriptTarget,1),":")
		;debug($sTempSplit)
		if ubound($sTempSplit) < 6 then $bTargetError = tRUE
	endif

	if $bTargetError then
		_StringAddNewLine ( $_runErrorMsg , "대상 값이 잘못 설정 되었습니다. ""[TAG명:TAG속성비교값:찾을 TEXT값:순번:추가할 JS스크립트내용]""")
		Return False
	endif

	$sJSScriptContents = _Trim($sTempSplit [ubound($sTempSplit)-1])

	if $sJSScriptContents = "" then
		_StringAddNewLine ( $_runErrorMsg , "추가할 JS가 빈 내용입니다." )
		Return False
	endif

	;"$이미지정보=[sdsdsds:Text]" 속성읽기 한다.
	$bResult = getRunCommnadImageAndSearchTarget ($sScriptTarget, $aImageFile,  $x , $y, True , $_runWaitTimeOut, $bFileNotFoundError, False)

	if $bResult  then
		; 찾은경우

		$Object = $aImageFile[1]
		$oMyError = ObjEvent("AutoIt.Error","UIAIE_NullError")

		SetError(0)
		;debug ($sJSScriptContents)
		_IEHeadInsertEventScript2($Object, "", "", $sJSScriptContents)
		;ConsoleWrite(_IEDocReadHTML($Object) & @CRLF)

		if @error <> 0 then
			$bResult = False
			;msg("오류")
			_StringAddNewLine ( $_runErrorMsg , "JS 추가에 실패 하였습니다. " & $sJSScriptContents )
		endif

		$oMyError = ObjEvent("AutoIt.Error")

	endif

	return $bResult


endfunc


func commandTagCountGet($sScriptTarget, byref $sCommentMsg)

	local $sNewName, $sNewValue
	local $bTargetError = False
	local $bResult

	local $bFileNotFoundError
	local $iTagCount

	local $sTempSplit
	local $Object

	local $oMyError
	local $sTempBrowser

	if getVarNameValue($sScriptTarget,  $sNewName, $sNewValue) = False then $bTargetError = True

	IF $bTargetError = False THEN $bTargetError = NOT( getIEObjectType($sNewValue))

	if $bTargetError then
		_StringAddNewLine ( $_runErrorMsg , "명령 대상 값이 잘못 설정 되었습니다. ""$변수명=[TAG명:속성값:TEXT값]""")
		Return False
	endif

	$sNewValue = getIEObjectCondtion($sNewValue)

	seterror(0)
	$oMyError = ObjEvent("AutoIt.Error","UIAIE_NullError")
	$sTempBrowser = _IEAttach2($_hBrowser,"HWND")

	if _IEPropertyGet ($sTempBrowser, "hwnd") <> $_hBrowser then
		_StringAddNewLine ( $_runErrorMsg , "IE 브라우저에서만 Object방식으로 사용이 가능합니다." )
		return False
	endif

	$Object = IEObjectSearchFromObject($sTempBrowser, $sNewValue, True)

	$iTagCount = number(ubound($Object) -1)
	if $iTagCount < 0 then $iTagCount = 0

	addSetVar ($sNewName & "=" & $iTagCount, $_aRunVar)
	_StringAddNewLine( $sCommentMsg, "변수정보 : " & $sNewName & "=" & $iTagCount)

	return True

endfunc



func commandTagAttribGet($sScriptTarget, byref $sCommentMsg)

	local $bResult
	local $x
	local $y
	local $aImageFile
	local $bFileNotFoundError
	local $aWinPos
	local $sTagAttribValue
	local $sTagAttribName
	local $sNewName
	local $sNewValue
	local $bTargetError = False
	local $battributeError = False
	local $sTempSplit
	local $Object
	local $i
	local $oMyError
	local $bSpecified
	local $sWEbElementID


	if $_runWebdriver = False then

		if getVarNameValue($sScriptTarget,  $sNewName, $sNewValue) = False then $bTargetError = True

		IF $bTargetError = False THEN $bTargetError = NOT(getIEObjectType($sNewValue))

		if $bTargetError = False then
			$sTempSplit = StringSplit(StringTrimRight($sNewValue,1),":")
			if ubound($sTempSplit) < 6 then $bTargetError = tRUE
		endif

		if $bTargetError then
			_StringAddNewLine ( $_runErrorMsg , "명령 대상 값이 잘못 설정 되었습니다. ""$변수명=[TAG명:TAG속성비교값:찾을 TEXT값:순번:읽을 속성명]""")
			Return False
		endif

		$sTagAttribName = _Trim($sTempSplit [ubound($sTempSplit)-1])

		if $sTagAttribName = "" then
			_StringAddNewLine ( $_runErrorMsg , "읽을 속성명이 지정되지 않았습니다." )
			Return False
		endif

		;"$이미지정보=[sdsdsds:Text]" 속성읽기 한다.
		$bResult = getRunCommnadImageAndSearchTarget ($sNewValue, $aImageFile,  $x , $y, True , $_runWaitTimeOut, $bFileNotFoundError, False)

		if $bResult  then
			; 찾은경우

			$Object = $aImageFile[1]

			if $sTagAttribName <> "style" then

				$sTagAttribValue = Execute("$Object." & $sTagAttribName)

				if @error <> 0 then
					;msg($sTagAttribValue)
					;$sTagAttribValue = Execute("$Object.attributes." & $sTagAttribName & ".value()")
					;debug($Object.getAttributeNode(_Trim($sTagAttribName)))

					;ieattribdebug($Object)

					;$sTagAttribValue = Execute("$Object.attributes." & _Trim($sTagAttribName) & ".nodevalue()")


					for $i=0 to $Object.attributes.length -1
						$oMyError = ObjEvent("AutoIt.Error","UIAIE_NullError")
						$bSpecified = $Object.attributes($i).specified
						if @error <> 0 then $battributeError = True
						if $bSpecified then

							if $Object.attributes($i).nodeName = _Trim($sTagAttribName) then
								$sTagAttribValue = $Object.attributes($i).nodeValue
							endif
						endif
						$oMyError = ObjEvent("AutoIt.Error")
					next


				endif
			Else
				$sTagAttribValue = Execute("$Object.style.cssText")

			endif

			if @error <> 0 then
				$bResult = False
				;msg("오류")
				_StringAddNewLine ( $_runErrorMsg , "대상을 찾았으나, 속성 정보 읽기에 실패 하였습니다. " & $sTagAttribName )
			elseif $battributeError = True  then
				$bResult = False
				_StringAddNewLine ( $_runErrorMsg , "속성 정보 읽기에 실패 하였습니다. " & $sTagAttribName )
			else
				;msg($sTagAttribName & " " &  $sTagAttribValue)
				; 저장시 특수 문자는 html 형태로 encoding 할 것
				addSetVar ($sNewName & "=" & $sTagAttribValue, $_aRunVar, True)
				_StringAddNewLine( $sCommentMsg, "변수정보 : " & $sNewName & "=" & $sTagAttribValue)
				;debug($sTagAttribValue, $sTagAttribValue)

			endif
		endif
	else

		; 웹드라이버 명령인 경우

		; 분리되지 않은 chr(0)으로 전달
		if getVarNameValue($sScriptTarget,  $sNewName, $sNewValue, chr(0)) = False then $bTargetError = True

		IF $bTargetError = False THEN $bTargetError = NOT(isWebdriverParam($sNewValue))

		if $bTargetError = False then
			$sTempSplit = StringSplit(StringTrimLeft(StringTrimRight($sNewValue,1),1),":")
			if ubound($sTempSplit) <> 4  then $bTargetError = tRUE
		endif

		if $bTargetError then
			_StringAddNewLine ( $_runErrorMsg , "명령 대상 값이 잘못 설정 되었습니다. ""$변수명={검색방식:검색조건:읽을 속성명]""")
			Return False
		endif

		$sTagAttribName = _Trim($sTempSplit [ubound($sTempSplit)-1])

		if $sTagAttribName = "" then
			_StringAddNewLine ( $_runErrorMsg , "읽을 속성명이 지정되지 않았습니다." )
			Return False
		endif


		$sWEbElementID = _WD_find_element_with_highlight_by (_Trim($sTempSplit[1]), $sTempSplit[2], $_runRetryRun , $_runHighlightDelay )

		if $sWEbElementID <> "" then
			$bResult = _WD_get_element_attribute($sWEbElementID, _Trim($sTempSplit[3]), $sTagAttribValue)
		endif

		if $bResult Then
			addSetVar ($sNewName & "=" & $sTagAttribValue, $_aRunVar, True)
			_StringAddNewLine( $sCommentMsg, "변수정보 : " & $sNewName & "=" & $sTagAttribValue)
		else
			WriteGuitarWebDriverError ()
		endif


	endif

	return $bResult

endfunc


; 속성쓰기
func commandTagAttribSet($sScriptTarget, byref $sCommentMsg)

	local $bResult
	local $x
	local $y
	local $aImageFile
	local $bFileNotFoundError
	local $aWinPos
	local $sTagAttribValue
	local $sTagAttribName
	local $sNewName
	local $sNewValue
	local $bTargetError = False
	local $sTempSplit
	local $Object
	local $iValueStart
	local $sExcute
	local $iErrorCode

	local $oMyError



	$iValueStart = StringInStr($sScriptTarget,"]")
	$iValueStart = StringInStr($sScriptTarget,"=",True,1,$iValueStart)

	$sNewName = _Trim(stringleft($sScriptTarget, $iValueStart-1))
	$sNewValue = _Trim(stringTrimleft($sScriptTarget, $iValueStart))

	if $sNewName = "" or $sNewValue = "" then $bTargetError = True

	;debug($sNewName, $sNewValue)

	if $bTargetError = False then $bTargetError = NOT(getIEObjectType($sNewName))

	if $bTargetError = False then
		$sTempSplit = StringSplit(StringTrimRight($sNewName,1),":")
		if ubound($sTempSplit) < 6 then $bTargetError = True
	endif

	if $bTargetError then
		_StringAddNewLine ( $_runErrorMsg , "명령 대상 값이 잘못 설정 되었습니다. ""{TAG명:TAG속성비교값:찾을 TEXT값:순번:변경 할 속성명]=변경 할 속성 값""")
		Return False
	endif

	$sTagAttribName = _Trim($sTempSplit [ubound($sTempSplit)-1])

	if $sTagAttribName = "" then
		_StringAddNewLine ( $_runErrorMsg , "변경할 속성명이 지정되지 않았습니다." )
		Return False
	endif

	;"$이미지정보=[sdsdsds:Text]" 속성읽기 한다.
	$bResult = getRunCommnadImageAndSearchTarget ($sNewName, $aImageFile,  $x , $y, True , $_runWaitTimeOut, $bFileNotFoundError, False)

	if $bResult  then
		; 찾은경우

		$Object = $aImageFile[1]
		;$sExcute = "$__Objectx." & $sTagAttribName & " = """  & $sNewValue & """"
		;debug($sExcute)
		;$x= Execute($sExcute)

		; http://msdn.microsoft.com/en-us/library/ms533043.aspx



		$oMyError = ObjEvent("AutoIt.Error","UIAIE_NullError")

		SetError(0)

		;debug("2 " & @error)


		if $sNewValue = "False" then
			$sNewValue = False
		elseif $sNewValue = "True" then
			$sNewValue = True
		endif


		;debug("3 " & @error)

		switch  $sTagAttribName

			case "border"
				$Object.border = $sNewValue

			case "caption"
				$Object.caption = $sNewValue

			case "checked"
				$Object.checked = $sNewValue

			case "disabled"
				$Object.disabled = $sNewValue

			case "height"
				$Object.height = $sNewValue

			case "href"
				$Object.href= $sNewValue

			case "id"
				$Object.id = $sNewValue

			case "index"
				$Object.index = $sNewValue

			case "innertext"
				$Object.innertext = $sNewValue

			case "link"
				$Object.link = $sNewValue

			case "name"
				$Object.name = $sNewValue

			case "readOnly"
				$Object.readOnly = $sNewValue

			case "selected"
				$Object.selected = $sNewValue
				;$iErrorCode = @error
				;debug($iErrorCode)

			case "src"
				$Object.src = $sNewValue

			case "target"
				$Object.target = $sNewValue

			case "text"
				$Object.text = $sNewValue

			case "title"
				$Object.title = $sNewValue

			case "value"
				$Object.value = $sNewValue

			case "width"
				$Object.width = $sNewValue

			case Else
				$bResult = False
				_StringAddNewLine ( $_runErrorMsg , "변경 할 수 없는 속성 입니다. ")

		EndSwitch

		;debug("4 " & @error)

		if @error <> 0 then
			$bResult = False
			_StringAddNewLine ( $_runErrorMsg , "대상을 찾았으나, 속성 정보 변경에 실패 하였습니다. " & $sTagAttribName )
		else
			;$Object.fireEvent("OnChange")
			;$Object.fireEvent("OnClick")
		endif

		$oMyError = ObjEvent("AutoIt.Error")

	endif


	return $bResult

endfunc


func commandLoop($sScriptTarget , byref $sLoopVar, byref $iLoopValue)

	local $sNewName, $sNewValue, $sGetVar
	local $bReturn
	local $sResultString
	local $sConvertType = " "

	;변수 정보 초기화

	if getVarNameValue($sScriptTarget,  $sNewName, $sNewValue, $sConvertType) = False then
		_StringAddNewLine ( $_runErrorMsg , "명령 대상 값이 잘못 설정 되었습니다. ""$변수명=반복횟수""")
		;debug($sScriptTarget,  $sNewName, $sNewValue)
		Return False
	endif

	$sNewValue = number($sNewValue)

	if $sNewValue = 0 then
		_StringAddNewLine ( $_runErrorMsg , "반복회수는 1 이상으로 지정되어야 합니다.")
		Return False
	endif

	$sLoopVar = $sNewName
	$iLoopValue = $sNewValue

	Return True

endfunc


Func commandGohome()

	local $bReturn = False
	local $aWinPos, $aMousePos
	local $iX1, $iY1
	local $sOSType

	getRunVar("$GUITAR_모바일OS",$sOSType)

	if $sOSType = "IOS" then
		; 윈도우 해상도를 찾음
		$aWinPos = WinGetPos($_hBrowser)
		$aMousePos = MouseGetPos()

		if IsArray($aWinPos) then

			$bReturn = True

			$iX1 = $aWinPos[0] + ($aWinPos[2] /2)
			$iY1 = $aWinPos[1] + ($aWinPos[3] /2)

			MouseClick("right",$ix1, $iy1,1, $_runMouseDelay)

		endif

		MouseMove($aMousePos[0],$aMousePos[1] ,0)
	elseif $sOSType = "ANDROID" then
		$bReturn = commandKeySend("{HOME}","ANSI")
	else
		_StringAddNewLine ( $_runErrorMsg , '"$GUITAR_모바일OS" 시스템 변수가 설정되지 않음, "IOS" 혹은 "ANDROID"로 설정되어야 함')
	endif

	return $bReturn

endfunc


;부분캡쳐
Func commandAreaCapture($sXY, byref $sCommentMsg)

	local $bReturn = False
	local $iX1, $iX2, $iY1, $iY2
	local $aAreaPos
	local $sCaptureFileName
	local $i
	local $bWindowCapture = True
	local $bScreenCapture = True
	local $bParsingError

	$aAreaPos = getXYAreaPosition($sXY & ",", $sCommentMsg, $bParsingError)

	;debug($aAreaPos)
	;debug($bParsingError)

	;if StringRegExp($sXY,"^\d{1,4},\d{1,4},\d{1,4},\d{1,4}",0) = 0 and (not (stringleft($sXY,7) = "0,0,0,0" or stringleft($sXY,11) = "-1,-1,-1,-1")) then
	;	$_runErrorMsg = '대상 좌표값이 바르지 않습니다. 브라우저 기준 상대좌표로 "X1,Y2,X2,Y2,파일명(옵션)" 형태이어야 합니다. (예, "100,100,120,150") : ' & $sXY
	;	return False
	;endif

	if ubound($aAreaPos) -1 < 4 then
		$_runErrorMsg = '대상 좌표값이 바르지 않습니다. 브라우저 기준 상대좌표로 "X1,Y2,X2,Y2,파일명(옵션)" 형태이어야 합니다. (예, "100,100,120,150") : ' & $sXY
		return False
	endif

	;debug($aAreaPos)

	for $i=1 to 4
		$aAreaPos[$i] = number($aAreaPos[$i])
		$bWindowCapture = $bWindowCapture and ($aAreaPos[$i] = 0)
		$bScreenCapture = $bScreenCapture and ($aAreaPos[$i] = -1)
	next

	$sCaptureFileName = _Trim($aAreaPos[5])
	if $sCaptureFileName <> "" then
		if stringright($sCaptureFileName,4) <> $_cImageExt then $sCaptureFileName = $sCaptureFileName & $_cImageExt
	endif


	;debug($aAreaPos)

	; 윈도우나, 스크린 캡쳐인 경우 좌표를 변경할것
	if $bWindowCapture then

		$bReturn  = captureCurrentBorwser($sCommentMsg, False, $_hBrowser, "", $sCaptureFileName)

	elseif $bScreenCapture  then

		$bReturn  = captureCurrentBorwser($sCommentMsg, True, $_hBrowser, "", $sCaptureFileName)

	else

		$bReturn  = captureCurrentBorwser($sCommentMsg, False, $_hBrowser, $aAreaPos, $sCaptureFileName)

	endif


	if $bReturn  = False then _StringAddNewLine ( $_runErrorMsg , "이미지캡쳐에 실패하였습니다.")

	$_runAreaCpatureExists = True

	return $bReturn

endfunc


Func commandSwipe($sXY)

	local $bReturn = False
	local $iX1, $iX2, $iY1, $iY2 , $sCommentMsg
	local $aWinPos
	local $aXY
	local $iWidth
	local $iHeight
	local $iAddx1, $iAddx2, $iAddy1, $iAddy2
	local $iStepX, $iStepY
	local $iStep = 10, $iMouseSpeed = 100
	local $iLoopCount
	local $x, $y
	local $iMax, $bError

	$aXY = getXYAreaPositionPercent($sXY, 4,  $bError)

	if $bError = True then
		;msg($sCommentMsg)
		$_runErrorMsg = "좌표 정보가 바르지 않음. X1%,Y1%,X2%,Y2% 형태 (값:0~100%, 예: 오른쪽으로 쓸어넘기기 = 90%,50%,10%,50%) : " & $sXY
		$bReturn = False
		return $bReturn
	endif

	; 윈도우 해상도를 찾음
	$aWinPos = _WinGetClientPos($_hBrowser)

	if IsArray($aWinPos) then

		$bReturn = True

		$iX1 = $aWinPos[0] + ($aWinPos[2] * ($aXY[1] / 100) - ($aWinPos[2]/100/2))
		$iY1 = $aWinPos[1] + ($aWinPos[3] * ($aXY[2] / 100) - ($aWinPos[3]/100/2))
		$iX2 = $aWinPos[0] + ($aWinPos[2] * ($aXY[3] / 100) - ($aWinPos[2]/100/2))
		$iY2 = $aWinPos[1] + ($aWinPos[3] * ($aXY[4] / 100) - ($aWinPos[3]/100/2))

		if $iX2 > $aWinPos[0] + $aWinPos[2] then $iX2 = $aWinPos[0] + $aWinPos[2]
		if $iY2 > $aWinPos[1] + $aWinPos[3] then $iY2 = $aWinPos[1] + $aWinPos[3]


		MouseMove($ix1, $iy1, 1)

		if $_runMobileOS = "IOS" then
			MouseClickDrag("left",$ix1, $iy1,$ix2, $iy2,30)
		else
			sleep(100)
			MouseDown("")
			sleep(100)

			MouseMove($ix1 + ($ix2-$ix1)*0.1, $iy1 + ($iy2-$iy1)*0.1, 100)
			;MouseMove($ix1 - ($ix2-$ix1)*0.1, $iy1 - ($iy2-$iy1)*0.1, 10)
			MouseMove($ix1 + ($ix2-$ix1)*1.1, $iy1 + ($iy2-$iy1)*1.1, 10)

			sleep(100)
			MouseMove($ix2, $iy2, 10)

			sleep(1000)
			Mouseup("")

		endif

	endif


	return $bReturn

endfunc



Func commandExcute($sScriptTarget, byref $sCommentMsg)

	local $sNewName, $sNewValue, $sGetVar
	local $bReturn
	local $sExcuteReturn
	local $sResultString
	local $sConvertType = " "

	if getVarNameValue($sScriptTarget,  $sNewName, $sNewValue, $sConvertType) = False then
		_StringAddNewLine ( $_runErrorMsg , "명령 대상 값이 잘못 설정 되었습니다. ""$변수명=비교값""")
		;debug($sScriptTarget,  $sNewName, $sNewValue)
		Return False
	endif

	convertHtmlChar ($sNewValue)


	$sExcuteReturn = Execute($sNewValue)

	if @error <> 0 then
		;debug(@error, $sExcuteReturn)
		;debug("계산명령:" & $sNewValue)
		$sResultString = " (수행결과 : 실행실패)"
		$bReturn = False
	Else
		$sResultString = " (수행결과 : " & $sExcuteReturn & ")"
		;debug($sNewName & "=" & $sExcuteReturn, $_aRunVar)
		addSetVar ($sNewName & "=" & $sExcuteReturn, $_aRunVar)
		$bReturn = True
	endif

	_StringAddNewLine($sCommentMsg, "명령수행 : "  &  $sNewValue & $sResultString)

	return $bReturn

EndFunc

; 같으면

Func commandValueIf($sScriptTarget, byref $sCommentMsg)

	local $sNewName, $sNewValue, $sGetVar
	local $sConvertNewValue
	local $sConvertGetValue
	local $bReturn

	if getVarNameValue($sScriptTarget,  $sNewName, $sNewValue) = False then
		_StringAddNewLine ( $_runErrorMsg , "명령 대상 값이 잘못 설정 되었습니다.2 ""$변수명=비교값""")
		;debug($sScriptTarget,  $sNewName, $sNewValue)
		Return False
	endif

	if getRunVar($sNewName, $sGetVar) = False then
		_StringAddNewLine( $_runErrorMsg, "변수 정보 설정이 잘못 되었거나 값이 설정되지 않았습니다. : " &  _Trim($sNewName))
		;debug($sNewName,  $sGetVar)
		Return False
	endif


	$sConvertNewValue = $sNewValue
	convertHtmlChar ($sConvertNewValue)

	$sConvertGetValue = $sGetVar
	convertHtmlChar ($sConvertGetValue)

	;debug($sConvertNewValue, $sConvertGetValue)
	if $sConvertNewValue <> $sConvertGetValue then
		$bReturn = False
	Else
		$bReturn = True

	endif

	_StringAddNewLine($sCommentMsg, "변수비교 : " & $sGetVar & "=" &  $sNewValue & " (" & _iif($bReturn,"일치","불일치") & ")")

	return $bReturn

EndFunc


func commandAttach($sScriptTarget, $iTimeOut = $_runWaitTimeOut)
;선택

	local $tTimeInit
	local $bResult = False
	local $aImageFile
	local $i
	local $aBrowserExe [1]
	local $sWinTitleList
	local $iLastCount = 0
	local $bScreenCapture = False
	local $bImageSearch = False
	local $bObjectSearch = False
	local $iRetHandle
	local $bObjectSearch
	local $sSearchType, $sSearchValue, $sSearchResultID


	sleep (1000)


	if $_runWebdriver = False then

		if $_runLastBrowser <> "" then

			_ArrayAdd($aBrowserExe,$_runLastBrowser)
		Else

			for $i=1 to ubound($_aBrowserOTHER)-1
				if _ArraySearch($aBrowserExe,$_aBrowserOTHER[$i][1],1,0,0,0,1) = -1 then _ArrayAdd($aBrowserExe,$_aBrowserOTHER[$i][1])
			next

			if _ArraySearch($aBrowserExe,$_sBrowserIE,1,0,0,0,1) = -1 then _ArrayAdd($aBrowserExe,$_sBrowserIE)
			if _ArraySearch($aBrowserExe,$_sBrowserFF,1,0,0,0,1) = -1 then _ArrayAdd($aBrowserExe,$_sBrowserFF)
			if _ArraySearch($aBrowserExe,$_sBrowserSA,1,0,0,0,1) = -1 then _ArrayAdd($aBrowserExe,$_sBrowserSA)
			if _ArraySearch($aBrowserExe,$_sBrowserCR,1,0,0,0,1) = -1 then _ArrayAdd($aBrowserExe,$_sBrowserCR)
			if _ArraySearch($aBrowserExe,$_sBrowserOP,1,0,0,0,1) = -1 then _ArrayAdd($aBrowserExe,$_sBrowserOP)

		endif

		;debug ($_runLastBrowser)

		Opt("WinDetectHiddenText", 1)

			$sScriptTarget = _Trim($sScriptTarget)

			writeDebugTimeLog("attach 변경전 handle " & $_hBrowser)

				RunSleep (100)
				$tTimeInit = _TimerInit()



				do
					for $i = 1 to ubound($aBrowserExe) -1

						;debug($aImageFile)

						; 첫번째가 아니면서 IE가 아닌 경우에는 검색시도 하지 않을것
						;if $bObjectSearch and $i > 1 and $aBrowserExe[$i] <> $_sBrowserIE then ContinueLoop

						;debug("찾으러 " & $aBrowserExe[$i] & $i )

						if $iLastCount = 1 then $bScreenCapture = True

						;debug($iLastCount, $bScreenCapture)

						if $_runScriptErrorCheck = True then CheckScriptError($aBrowserExe[$i])


						if $_runErrorMsg = "" then $bResult = searchBrowserWindow($aBrowserExe[$i] , $sScriptTarget, $sWinTitleList, $bScreenCapture, $iRetHandle)

						if $bResult then

							writeDebugTimeLog("attach 성공 1차")
							$_runBrowser = $aBrowserExe[$i]
							$_hBrowser = $iRetHandle
							;msg($_hBrowser)



							if hBrowswerActive() = 0 then
								_StringAddNewLine ( $_runErrorMsg , "선택된 브라우저 윈도우를 활성화 할 수 없습니다.")
								$bResult = False
							endif

							_setCurrentBrowserInfo()

							writeDebugTimeLog("attach 성공 2차")
						endif

						RunSleep (10)

						; 테스트 중단
						if checkScriptStopping() then return False
						if $_runErrorMsg <> "" then exitloop
						if $bResult then exitloop

					next

					if _TimerDiff($tTimeInit) > $iTimeOut then $iLastCount += 1

				until $bResult or $iLastCount > 1 or $_runErrorMsg <> ""



		if $bResult = False then
			_StringAddNewLine ( $_runErrorMsg , "지정된 윈도우를 찾을 수 없습니다. : " & $sScriptTarget & @crlf & " 윈도우 List : " & $sWinTitleList)

			captureCurrentBorwser($_runErrorMsg, True)
		else
			; 성공인 경우 에러 멧세지를 리셋하여 초기화함 (재검증시 윈도우가 사라진 경우 hwnd가 0으로 되는 경우 가 있어 쓰레기가 남음)
			$_runErrorMsg = ""
		endif

		writeDebugTimeLog("attach 변경후 handle " & $_hBrowser)
		writeDebugTimeLog("attach 변경 결과 " & $bResult)

		Opt("WinDetectHiddenText", 0)


	else


		if getWebdriverParamTypeAndValue($sScriptTarget, $sSearchType, $sSearchValue) then

			$tTimeInit = _TimerInit()

			do
				setStatusText (getTargetSearchRemainTimeStatusText($tTimeInit, $iTimeOut, $sScriptTarget))
				$bResult = _WD_switch_to_window($sSearchType, $sSearchValue, $_runRetryRun , $_runHighlightDelay)
				if $bResult = False then RunSleep (500)
			until ($bResult = True) or (_TimerDiff($tTimeInit) > $iTimeOut) or (checkScriptStopping())


			_debug( $bResult , checkScriptStopping())
			if $bResult  = False and checkScriptStopping() = False then
				_StringAddNewLine ( $_runErrorMsg , "지정된 윈도우를 찾을 수 없습니다. : " & $sScriptTarget )
			endif

		else

			_StringAddNewLine ( $_runErrorMsg , "Webdriver 테스트 입력정보가 바르지 않습니다. {검색방식:검색조건}")

		endif

	endif

	return $bResult

endfunc


func commandVariableSet($sScriptName)
;참조설정

	local $bResult = True

	local $sNewValue
	local $sNewName

	if getVarNameValue($sScriptName,  $sNewName, $sNewValue) = False then
		$bResult = False
		_StringAddNewLine ( $_runErrorMsg , "설정 정보가 잘못되었습니다.  ""$테이블변수명=참조Line값""")
	elseif number($sNewValue) < 1 then
		$bResult = False
		_StringAddNewLine ( $_runErrorMsg , "참조 설정 값은 0보다 큰 수를 입력해야 합니다. : " & number($sNewValue))
	else
		RestTableValueIndex($sNewName, number($sNewValue))
		;debug ($bResult)
	endif

	return $bResult

endfunc


func commandSet($sScriptName, byref $sCommentMsg)

	; 공용 실행 변수에 값을 대입한다.
	local $bResult = True
	local $sNewValue
	local $sNewName
	local $bExtractCheck = True

	if getVarNameValue($sScriptName,  $sNewName, $sNewValue,"," ,$bExtractCheck) = False then
		$bResult = False
		_StringAddNewLine ( $_runErrorMsg , "변수 설정 정보가 잘못되었습니다.  ""$변수명=내용""")
	else
		;debug("새로운변수:" , $sNewName, $sNewValue)
		_StringAddNewLine( $sCommentMsg, "변수정보 : " & $sNewName & "=" & $sNewValue)

		if addSetVar ($sNewName & "=" & $sNewValue, $_aRunVar, $bExtractCheck) = False Then
			_StringAddNewLine ( $_runErrorMsg , "변수 설정 정보가 잘못되었습니다.  ""$변수명=내용""")
			$bResult = False
		endif
		;debug("새로운변수 END:" , $sNewName, $sNewValue, $bResult)
	endif

	return $bResult

endfunc


func commandInclude($sScriptName)

	local $aRowScript
	local $sErrorMsgAll
	local $aScript
	local $bResult
	local $sSearchScriptFile
	local $aRunCountInfo [4] = [0,0,0,0]
	local $sLastImagePath
	local $oldScriptFile

	$sScriptName = FileGetLongName($sScriptName,1)

	;if FileExists($sScriptName) = 0 then
	;	$sScriptName  = FileGetLongName(_GetPathName($_runScriptFileName) & $sScriptName,1)
		;debug($sScriptName )
	;endif

	;if FileExists($sScriptName) = 0 then
		$sSearchScriptFile = searchScriptFile(_GetFileName($sScriptName) & _GetFileExt($sScriptName), $sErrorMsgAll)

		;msg($sSearchScriptFile)

		if $sSearchScriptFile <> "" then $sScriptName = $sSearchScriptFile
		if $sErrorMsgAll <> "" then
			$_runErrorMsg = $sErrorMsgAll
			return False
		endif
	;endif

	if FileExists($sScriptName) = 0 then
		$_runErrorMsg = "스크립트 파일 없음 : " & $sScriptName
		;writeRunLog(writePassFail(False))
		return  False
	endif

	; 이전 이미지 폴더를 삭제하고, include 이후에 다시 추가
	$sLastImagePath = $_aRunImagePathList[ubound ($_aRunImagePathList) -1]

	_deleteImagePathList($sLastImagePath)
	$_bUpdateForderFileList = True
	_addImagePathList(_GetPathName($sScriptName))

	_FileReadToArray($sScriptName,$aRowScript)

	if getScript($aRowScript, $aScript, $sErrorMsgAll, True,0 ,0 ) = False then
		$_runErrorMsg = "스크립트 파일 분석 오류 " & @crlf & $sErrorMsgAll
		;writeRunLog(writePassFail(False))
		$bResult = False
	Else
		;debug($sScriptName)

		; 로그의 짝을 맞춰주기 위해 수행
		;writeRunLog(writePassFail(True))

		$_iScriptRecursive += 1
		$oldScriptFile = $_runScriptFileName
		$bResult = runScript($sScriptName, $aScript, 0, 0, $aRunCountInfo)
		$_runScriptFileName = $oldScriptFile
		$_iScriptRecursive -= 1
	endif

	_deleteImagePathList(_GetPathName($sScriptName))
	$_bUpdateForderFileList = True
	_addImagePathList($sLastImagePath)

	return $bResult

endfunc


func commandBrowserEnd()

	local $bResult = False


	if $_runWebdriver = False  then

		Switch $_runBrowser

			;case $_sBrowserIE
			;if _IEQuit($_oBrowser) = 1 then $bResult = True

			case $_sBrowserCR, $_sBrowserOP
				hBrowswerActive ()
				sleep(100)
				send("^{F4}")
				$bResult = True

			case Else
				if WinClose($_hBrowser) <> 0 then $bResult = True

		EndSwitch

		$_runBrowser = ""
		$_hBrowser = ""

	else
		$bResult = _WD_close_window()

	endif

	_setCurrentBrowserInfo()

	if $bResult = False then
		$_runErrorMsg = "브라우저 닫기에 실패"
		captureCurrentBorwser($_runErrorMsg, True)
	endif

	RunSleep (1000)

	return $bResult

endfunc



func commandAssert($sScriptTarget,$TimeOut, $bIsErrorCheck, $bFullSearch, $bExpect)

	local $bResult = False
	local $x
	local $y
	local $aImageFile
	local $bFileNotFoundError
	local $aWinPos
	local $sSearchType, $sSearchValue

	$bResult = getRunCommnadImageAndSearchTarget ($sScriptTarget, $aImageFile,  $x , $y, $bIsErrorCheck, $TimeOut, $bFileNotFoundError, $bFullSearch)

	;msg($bResult)
	;MouseMove($x, $y,1)
	;sleep(5000)

	if $bIsErrorCheck = False and $bFileNotFoundError = False then $_runErrorMsg = ""

	return $bResult

endfunc


func commandLocationTab($sScriptTarget, $bButton)

	local $x,$y, $bResult
	local $aWinPos, $aXY, $bError

	$bResult = False

	$aXY = getXYAreaPositionPercent($sScriptTarget, 2,  $bError)

	if $bError = False then

		$aWinPos = _WinGetClientPos($_hBrowser)

		$x = $aWinPos[0] + ($aWinPos[2] * ($aXY[1] / 100))
		$y = $aWinPos[1] + ($aWinPos[3] * ($aXY[2] / 100))

		MouseMove($x, $y,1)

		if $bButton = "locationlong" then
			MouseMove($x, $y,1)
			MouseDown("left")
			sleep (2000)
			Mouseup("left")
		elseif $bButton = "locationdouble" then
			MouseClick("left", $x, $y)
			sleep(250)
			MouseClick("left", $x, $y)
		else
			;debug("locationtab " , $x, $y)
			MouseClick("left", $x, $y)
		endif

		$bResult = True

	endif

	return $bResult

endfunc


func commandClick($sScriptTarget, $bButton)

	local $bResult = False
	local $x
	local $y
	local $aImageFile
	local $bFileNotFoundError
	local $ioldClickDelay
	local $aWinPos
	local $iDelay = $_runMouseDelay
	local $iClickCount

	local $sWebElementID
	local $sWebAction
	local $iWebActionButton

	writeDebugTimeLog("Command Click 이미지 찾기")

	$bResult = getRunCommnadImageAndSearchTarget ($sScriptTarget, $aImageFile,  $x , $y, True, $_runWaitTimeOut, $bFileNotFoundError)

	writeDebugTimeLog("Command Click 이미지 찾기 완료")

	if  $bResult = True  then

		if $_runWebdriver = False  then

			addCorrectionYX( $x ,  $y)

			hBrowswerActive ()
			writeDebugTimeLog("Command Click active  완료")
			runsleep(10)
			MouseMove($x, $y,$iDelay)
			runsleep(10)


			if $bButton = "double" then
				;$bButton="left"
				$iClickCount = 2
			Else
				$iClickCount = 1
			endif

			if $bButton = "double" then
				;$ioldClickDelay = AutoItSetOption("MouseClickDownDelay", 100)
				MouseClick("left", $x, $y)
				sleep(250)
				MouseClick("left", $x, $y)
				;AutoItSetOption("MouseClickDownDelay", $ioldClickDelay)
			elseif $bButton = "long" then
				MouseMove($x, $y,$iDelay)
				MouseDown("left")
				sleep (2000)
				Mouseup("left")

			Else
				MouseMove($x-1, $y-1,$iDelay)
				runsleep(10)
				MouseMove($x+1, $y+1,$iDelay)
				runsleep(10)
				MouseMove($x-1, $y-1,$iDelay)
				runsleep(10)
				MouseMove($x+1, $y+1,$iDelay)
				runsleep(10)

				;debug($iClickCount)

				MouseClick($bButton,$x, $y,$iClickCount,$iDelay)

			endif

		else
			; WEBDRIVER 모드인 경우

			$sWebElementID = $x

			$x=0
			$y=0

			addCorrectionYX( $x ,  $y)

			$iWebActionButton = 0
			$sWebAction = "/click"

			if $bButton = "right" then $iWebActionButton = 2
			if $bButton = "double" then $sWebAction = "/doubleclick"

			$bResult = _WD_MoveAndAction($sWebElementID, $sWebAction , $iWebActionButton, $x, $y)

			if $bResult = False then WriteGuitarWebDriverError ()

		endif
		Sleep(10)
		;moveMouseTop()

	endif

	writeDebugTimeLog("Command Click 명령 완료")

	return $bResult

endfunc


func commandMouseMove($sScriptTarget)

	local $bResult
	local $x
	local $y
	local $aImageFile
	local $bFileNotFoundError

	$bResult = getRunCommnadImageAndSearchTarget ($sScriptTarget, $aImageFile,  $x , $y, True, $_runWaitTimeOut, $bFileNotFoundError)

	writeDebugTimeLog("Command 마우스 이동전")

	if  $bResult = True  then

		addCorrectionYX( $x ,  $y)

		hBrowswerActive ()
		MouseMove($x  , $y,$_runMouseDelay)
		RunSleep(100)
	endif

	writeDebugTimeLog("Command 마우스 이동후")
	return $bResult

endfunc


func addCorrectionYX(byref $x , byref $y)

		if $_runCorrectionX <> 0 or $_runCorrectionY <> 0 then

			$x = $x + $_runCorrectionX
			$y = $y + $_runCorrectionY

			$_runCorrectionY = 0
			$_runCorrectionX = 0

			addSetVar ("$GUITAR_X좌표보정=0", $_aRunVar)
			addSetVar ("$GUITAR_Y좌표보정=0", $_aRunVar)

		endif

endfunc




func getBrowserIDFromExe($sExe)

	local $sID

	$sExe = StringLower($sExe)

	if $sExe = getReadINI("BROWSER", $_sBrowserIE) then $sID = $_sBrowserIE
	if $sExe = getReadINI("BROWSER", $_sBrowserFF) then $sID = $_sBrowserFF
	if $sExe = getReadINI("BROWSER", $_sBrowserSA) then $sID = $_sBrowserSA
	if $sExe = getReadINI("BROWSER", $_sBrowserCR) then $sID = $_sBrowserCR
	if $sExe = getReadINI("BROWSER", $_sBrowserOP) then $sID = $_sBrowserOP


	if $sID = "" then

		for $j=1 to ubound($_aBrowserOTHER) -1
			if StringLower($_aBrowserOTHER[$j][2]) = $sExe then $sID = $_aBrowserOTHER[$j][1]
		next

	endif

	return $sID

endfunc


func getBrowserExe($sBrowser)

	local $sBexe
	local $aOther
	local $aOtherItem
	local $j

	Switch $sBrowser

		case $_sBrowserIE, $_sBrowserFF, $_sBrowserSA, $_sBrowserCR, $_sBrowserOP

			$sBexe = getReadINI("BROWSER", $sBrowser)

		case Else
			for $j=1 to ubound($_aBrowserOTHER) -1
				if $_aBrowserOTHER[$j][1] = $sBrowser then $sBexe = $_aBrowserOTHER[$j][2]
			next

	EndSwitch

	return $sBexe

endfunc


func CloseAllBrowser($sBrowser ="")

	local $sBrowserEXE
	local $i, $j
	local $sWinlistText
	local $aWinlist
	local $iTimeDiff

	writeDebugTimeLog("CloseAllBrowser 시작")

	if $sBrowser <> "" then

		$sBrowserEXE = getReadINI("BROWSER", $sBrowser)

		do
			ProcessClose($sBrowserEXE)

		until (ProcessExists($sBrowserEXE) = 0)

	else

		for $i=1 to 5

			switch $i

				case 1
					$sBrowserEXE =  getReadINI("BROWSER", $_sBrowserIE)
				case 2
					$sBrowserEXE =  getReadINI("BROWSER", $_sBrowserFF)
				case 3
					$sBrowserEXE =  getReadINI("BROWSER", $_sBrowserSA)
				case 4
					$sBrowserEXE =	getReadINI("BROWSER", $_sBrowserCR)
				case 5
					;강제로 종료 할 경우 다음에 경고창이 발생됨
					$sBrowserEXE =	getReadINI("BROWSER", $_sBrowserOP)

			EndSwitch

			$aWinlist = getBrowserWindowAll($sBrowserEXE, $sWinlistText)

			for $j=1 to ubound($aWinlist) -1
				winclose($aWinlist[$j])
			next

			if ubound($aWinlist) > 1 then  sleep (1000)

			writeDebugTimeLog("CloseAllBrowser loop 전")

			$iTimeDiff = _Timerinit()

			; 5초 이상 지속 될 경우 자동으로 다음 진행
			do
				ProcessClose($sBrowserEXE)
			until (ProcessExists($sBrowserEXE) = 0 or _TimerDiff($iTimeDiff) > 5)

			writeDebugTimeLog("CloseAllBrowser loop 후")

		next
	endif

	writeDebugTimeLog("CloseAllBrowser 종료")

endfunc


func getBrowserFullName(byref $sScriptTarget)

	if $sScriptTarget = "FF" then $sScriptTarget = "FIREFOX"
	if $sScriptTarget = "CR" then $sScriptTarget = "CHROME"
	if $sScriptTarget = "SA" then $sScriptTarget = "SAFARI"
	if $sScriptTarget = "OP" then $sScriptTarget = "OPERA"

endfunc

func commandBrowserRun($sScriptTarget)

	local $sRunkey
	local $bResult = True
	local $sBrowserEXE
	local $aBrowserClassFF = StringSplit($_sBrowserClassFF,"|")
	local $iLoopCnt = 0
	local $sTempBrowser
	local $sTempBrowser2
	local $iTimerInit = _TimerInit()
	local $bLoadWait = True
	local $aFireFoxhWnd[1], $i, $j, $aWinList, $hFireFoxNewhwnd
	local $x, $y
	local $sTempBrowser
	local $iErrorCode
	local $i
	local $aTempPos
	local $oMyError

	getBrowserFullName ($sScriptTarget)

	if $sScriptTarget <> "" Then

		;debug($sScriptTarget)
		$sBrowserEXE = getReadINI("BROWSER", $sScriptTarget)

		if $sBrowserEXE = "" Then
			$_runErrorMsg = "브라우저 실행 파일명이 ini에 설정되지 않음 : " & $sScriptTarget
			$bResult = False
			return False
		endif

		;msg($_runCmdRunning)
		;msg(getIniBoolean(getReadINI("Environment","CloseAllBrowser")))

	endif


	;if $_runCmdRunning = True and getIniBoolean(getReadINI("Environment","CloseAllBrowser")) then
	;	CloseAllBrowser()
	;endif


	Switch $sScriptTarget

			case $_sBrowserIE

			$bLoadWait = False
			$iTimerInit = _TimerInit()

			$_runBrowser = $_sBrowserIE
			;$_oBrowser = _IECreate("about:blank",0,1,1,1)

			$oMyError = ObjEvent("AutoIt.Error","UIAIE_NavigateError")



			writeDebugTimeLog(" IE 생성 전")


			for $i=1 to 3


				$sTempBrowser = _IECreate("about:blank",0,1,1,1)

				writeDebugTimeLog(" IE 생성 후 1")

				$_hBrowser = _IEPropertyGet ($sTempBrowser, "hwnd")

				writeDebugTimeLog(" IE 생성 후 2")

				$sTempBrowser2 = _IEAttach2($_hBrowser,"hwnd")
				$iErrorCode=@error
				writeDebugTimeLog(" IE 생성 _IEAttach2 결과 " & $iErrorCode)

				If $iErrorCode <> 0 Then
					writeDebugTimeLog("command commandBrowserRun IE HWND Error hwnd : " & $_hBrowser & ", error code : " & $iErrorCode)
				else
					exitloop
				endif

				sleep (3000)

			next


			$oMyError = ObjEvent("AutoIt.Error")

			do
				runsleep(1000)
			until (hBrowswerActive () <> 0 ) and StringInStr(WinGetTitle($_hBrowser), "Internet Explorer") > 0 OR (_TimerDiff($iTimerInit) > $_runWaitTimeOut)


		case $_sBrowserFF

			$_runBrowser = $_sBrowserFF
			$_hBrowser = ""

			for $i=1 to 2
				$aWinList = WinList("[CLASS:" & $aBrowserClassFF[$i] & "]")
				for $j=1 to ubound($aWinList) -1
					_ArrayAdd($aFireFoxhWnd, $aWinList[$j][1])
				next
			next

			;msg($aFireFoxhWnd)
			if ShellExecute($sBrowserEXE,"about:blank")  then

				$hFireFoxNewhwnd = ""

				RunSleep (1000)

				do
					RunSleep (1000)
					$iLoopCnt += 1

					for $i=1 to 2
						$aWinList = WinList("[CLASS:" & $aBrowserClassFF[$i]   &"]")
						for $j=1 to ubound($aWinList) -1

							if _ArraySearch($aFireFoxhWnd,$aWinList[$j][1],1,0) = -1 then
								if IsHWnd($aWinList[$j][1]) <> 0 then

									; 공백인 윈도우 타이틀인 경우 제외
									if _Trim($aWinList[$j][0]) <> "" then

										$hFireFoxNewhwnd = $aWinList[$j][1]
										writeDebugTimeLog("FF 윈도우 찾음 : " & $aWinList[$j][0] & " " & $aWinList[$j][1])
										$aTempPos =WinGetPos($aWinList[$j][1])
										writeDebugTimeLog("FF 윈도우 위치 : " & $aTempPos[0] & $aTempPos[1] & $aTempPos[2] & $aTempPos[3] )
										exitloop
									endif
								endif
							endif
						next
					next


				until $hFireFoxNewhwnd <> ""  or $iLoopCnt > $_runWaitTimeOut / 1000

				;msg($hFireFoxNewhwnd)

				if $hFireFoxNewhwnd <> "" then
					$_hBrowser = $hFireFoxNewhwnd
				else
					$_hBrowser = ""
					$bResult = False
				endif

				;writeDebugTimeLog("New FF hwnd : " & $_hBrowser)

			Else
				$bResult = False
			endif

		case $_sBrowserSA

			$sRunkey = "about:" & Random()
			$_runBrowser = $_sBrowserSA

			if ShellExecute ($sBrowserEXE ,$sRunkey) then
				WinWait($sRunkey, "",  $_runWaitTimeOut / 1000)
				WinActivate($sRunkey)
				$_hBrowser = WinGetHandle($sRunkey)
			else
				$bResult = False
			endif

		case $_sBrowserCR

			$sRunkey = "about:blank"
			$_runBrowser = $sScriptTarget
			$_hBrowser = ""

			if ShellExecute ($sBrowserEXE ,$sRunkey) then
				WinWait($sRunkey, "",  $_runWaitTimeOut / 1000)
				WinActivate($sRunkey)
				if WinActive($sRunkey) then $_hBrowser = WinGetHandle($sRunkey)
			else
				$bResult = False
			endif

		case $_sBrowserOP

			$sRunkey = "opera:about"
			$_runBrowser = $sScriptTarget
			$_hBrowser = ""

			if ShellExecute ($sBrowserEXE ,$sRunkey) then

				$iTimerInit =  _TimerInit()

				opt("WinTitleMatchMode",2)
				do

					$sRunkey = " - Opera"
					WinActivate($sRunkey)
					if WinActive($sRunkey) then $_hBrowser = WinGetHandle($sRunkey)

					$sRunkey = "About Opera"
					WinActivate($sRunkey)
					if WinActive($sRunkey) then $_hBrowser = WinGetHandle($sRunkey)

					$sRunkey = "Welcome to Opera"
					WinActivate($sRunkey)
					if WinActive($sRunkey) then  send("{ENTER}")

					$sRunkey = "환영합니다"
					WinActivate($sRunkey)
					if WinActive($sRunkey) then  send("{ENTER}")


			until _TimerDiff($iTimerInit) > $_runWaitTimeOut or  $_hBrowser <> ""
			opt("WinTitleMatchMode",1)

			else
				$bResult = False
			endif

		case else
			$_runErrorMsg = $_runBrowser & " 브라우저 실행 정보가 없습니다."
			$bResult = False

	EndSwitch

	if IsHWnd($_hBrowser) = 0 then RunSleep(1000)
	if IsHWnd($_hBrowser) = 0 then RunSleep(1000)
	if IsHWnd($_hBrowser) = 0 then RunSleep(1000)

	if IsHWnd($_hBrowser) = False then
		$_runErrorMsg = $_runBrowser & " 브라우저 실행 실패"
		captureCurrentBorwser($_runErrorMsg, True)
		$bResult = False

	Elseif $bResult then

		if $bLoadWait then sleep (500)

		;IE가 아닌경우 브라우저 주소창이 나올떄 까지 대기
		if $_runBrowser <> $_sBrowserIE then

			hBrowswerActive()

			RunSleep(50)
			SendSleep("^l" , 100)
			RunSleep(50)
			SendSleep("!d", 100)

			setTestHotKey(False)
			sleep(50)
			Send("{ESC}")
			sleep(50)
			Send("{ESC}")
			setTestHotKey(True)

			for $i=1 to 20
				hBrowswerActive()
				$_runErrorMsg = ""
				if getBrowserAdressPos($_runBrowser,  $x,  $y) = True then exitloop
				sleep(500)
				writeDebugTimeLog("commandCreate 주소창 확인 대기 " & $i)
			next

			if $_runErrorMsg <> "" then
				$_runErrorMsg = $_runBrowser & " 브라우저 실행 실패, " & $_runErrorMsg
				captureCurrentBorwser($_runErrorMsg, True)
				$bResult = False
			endif

		endif

		_setBrowserWindowsSize($_hBrowser)
		_setCurrentBrowserInfo()

	endif

	return $bResult

endfunc

func waitForBrowserDone($sScriptTarget, $bErrorCheck, $iTimeOut)

	local $bImageSearch = False
	local $aImageList
	local $i
	local $aRetPos
	local $x, $y
	local $sLoopCount = 5
	local $iStartX, $iStartY, $iEndX, $iEndY
	local $aWinPos

	Switch $sScriptTarget

		case $_sBrowserIE
			$bImageSearch = True

		case $_sBrowserFF, $_sBrowserSA, $_sBrowserCR, $_sBrowserOP

			$aWinPos = WinGetPos($_hBrowser)

			if IsArray($aWinPos) then

				$iStartX = $aWinPos[0]
				$iStartY = $aWinPos[1]
				$iEndX = $aWinPos[0] + $aWinPos[2]
				$iEndY = $aWinPos[1] + 120

				$bImageSearch = CheckResourceImage($sScriptTarget & "_DONE", $iStartX, $iStartY, $iEndX, $iEndY, $iTimeOut, $x, $y )

			endif

	EndSwitch

	if $bImageSearch = False and $bErrorCheck = True  then
		if $_bScriptStopping = False then _StringAddNewLine($_runErrorMsg , $sScriptTarget & " 브라우저가 URL 입력 대기 상태가 아닙니다.")
	endif

	return $bImageSearch

endfunc


func commandNavigate($sURL, $bRetry)

	local $bResult = False
	local $oBrowserControlID
	local $sTempClip
	local $sTempBrowser
	local $oMyError
	local $i
	local $bTimeout = False
	local $iTimeOut
	Local $iErrorCode
	local $x, $y
	local $bNavigate

	$_runErrorMsg = ""


	if $_runWebdriver Then
		if _WD_navigate($sURL) then
			$bResult = True
		else
			_StringAddNewLine ( $_runErrorMsg , "Webdriver에서 오류가 발생되었습니다. : " & $_webdriver_last_errormsg)
		endif

	else


		for $i= 1 to 3

			$_runErrorMsg = ""

			writeDebugTimeLog("commandNavigate moveMouseTop 전 재시도:" & $i)

			if hBrowswerActive () = 0 then
				$_runErrorMsg = "창을 활성화 할 수 없습니다."
				$bResult = False
			endif

			writeDebugTimeLog("commandNavigate moveMouseTop 전")

			moveMouseTop()

			writeDebugTimeLog("commandNavigate moveMouseTop 후")

			Switch $_runBrowser

				case $_sBrowserIE

					;SendSleep("!D")
					;RunSleep(1000)
					;$oBrowserControlID = ControlGetFocus($_hBrowser,"")

					;if $oBrowserControlID = "" then
					;	$_runErrorMsg = "URL 입력창에 포커스를 설정할 수 없습니다."
					;	return False
					;endif

					;ControlSetText ($_hBrowser,"",$oBrowserControlID,$sURL)
					;ControlSend($_hBrowser,"",$oBrowserControlID, "{ENTER}")

					;
					;debug("1" & $_hBrowser, $sTempBrowser)

					;debug("Attach 전 " & $_hBrowser & " " & $sURL)

					;checkIE9FontSmoothingSetting()

					 writeDebugTimeLog("commandNavigate IEAttach 전 : " & $_hBrowser & " " & IsHWnd($_hBrowser) )
					 $sTempBrowser = _IEAttach2($_hBrowser,"HWND")
					 $iErrorCode=@error
					 If @error <> 0 Then writeDebugTimeLog("commandNavigate error id : " & $iErrorCode)

					 writeDebugTimeLog("commandNavigate IEAttach 후")


					;debug("2" & $_hBrowser, $sTempBrowser)

					if $sTempBrowser <> 0  then
						seterror(0)
						$oMyError = ObjEvent("AutoIt.Error","UIAIE_NavigateError")

						writeDebugTimeLog("commandNavigate _IENavigate 전")

						$_aLastNavigateTime = _TimerInit()
						$bNavigate = _IENavigate($sTempBrowser, $sURL, 0)

						if $bNavigate = -1  then

							writeDebugTimeLog("commandNavigate _IELoadWait 전")
							_IELoadWait ($sTempBrowser,100, $_runWaitTimeOut / 2)
							_IELoadWait ($sTempBrowser,100, $_runWaitTimeOut / 2)
							if _IELoadWait ($sTempBrowser,100, 1000) = 1 then
								$bResult = True
								;debug(_TimerDiff($_aLastNavigateTime))
								$_aLastNavigateTime = _TimerDiff($_aLastNavigateTime)
								;debug($_aLastNavigateTime)
								writeDebugTimeLog("commandNavigate _IELoadWait 후 성공")
							else

								if getIniBoolean(getReadINI("Report","FullSizeImage")) = True then
									$bResult = False
									_StringAddNewLine($_runErrorMsg , "웹 페이지 로딩이 완료되지 않았습니다.")
									writeDebugTimeLog("commandNavigate _IELoadWait 후 실패")
								else
									$bResult = False
									_StringAddNewLine($_runErrorMsg , "웹 페이지 로딩에 실패하였습니다. Timeout")
									writeDebugTimeLog("commandNavigate _IELoadWait 에러가 발생되었으나, Skip")
								endif
							endif

						Else
							 ;debug($_oBrowser)
							$_runErrorMsg = $sURL & " 페이지로 연결 할 수 없습니다."
							$bResult = False

						endif


						$oMyError = ObjEvent("AutoIt.Error")

						if $_runErrorMsg <> "" then $bResult = False

					Else
						$_runErrorMsg = "Navigate 할 수 없는 IE 브라우저 창이 선택되어 있습니다."
						$_runErrorMsg &= "Vista 이상의 시스템의 경우 사용자 계정 컨트롤 설정이 되어 있을경우 오류가 발생될 수 있습니다. 제어판 > 시스템 및 보안 > 관리 센터 > 사용자 계정 컨트롤 설정을 '최고 낮음'으로 설정하여 사용하시기 바랍니다. "
						$bResult = False
					endif

					writeDebugTimeLog("commandNavigate IE 작업 완료")

				case $_sBrowserSA, $_sBrowserFF, $_sBrowserCR, $_sBrowserOP

					WinSetOnTop($_hBrowser,"",1)

					writeDebugTimeLog("commandNavigate Top 후 ")

					hBrowswerActive()

					writeDebugTimeLog("commandNavigate hBrowswerActive 후 ")

					$_runErrorMsg = ""
					if getBrowserAdressPos($_runBrowser,  $x,  $y) = False then
						setTestHotKey(False)
						sleep(50)
						Send("{ESC}")
						sleep(50)
						Send("{ESC}")
						setTestHotKey(True)
					endif

					; 마우스를 왼쪽 가운데로 클릭 (ctrl + l이 작동되도록 빈화면 클릭)
					writeDebugTimeLog("commandNavigate 마우스 이동 전")
					;setMouseClickLeftMiddle()

					if getBrowserAdressPos($_runBrowser,  $x,  $y) = True then

						;setMouseClickLeftDown()
						;debug($x, $y)

						MouseClick("",$x,$y,10,2)

						hBrowswerActive()

						writeDebugTimeLog("hBrowswerActive()2 후")

						setTestHotKey(False)
						sleep(50)
						Send("{ESC}")
						setTestHotKey(True)

						RunSleep(10)
						SendSleep("^l")
						SendSleep("{DEL}")
						RunSleep(10)
						SendSleep("!d")


						RunSleep(10)
						SendSleep("^a")
						RunSleep(10)
						SendSleep("{DEL}")
						RunSleep(10)
						writeDebugTimeLog("delete 중간")

	;~ 					RunSleep(50)
	;~ 					SendSleep("^l")
	;~ 					RunSleep(50)
	;~ 					SendSleep("!d")
	;~ 					RunSleep(50)
	;~ 					SendSleep("^l")
	;~ 					RunSleep(50)
	;~ 					SendSleep("!d")
	;~ 					RunSleep(50)
	;~ 					SendSleep("^l")
	;~ 					RunSleep(50)
	;~ 					RunSleep(100)
	;~ 					SendSleep("^l")

						RunSleep(10)
						SendSleep("^a")
						RunSleep(10)
						SendSleep("{DEL}")
						RunSleep(10)
						SendSleep("^a")

						writeDebugTimeLog("hBrowswerActive()3 전")

						hBrowswerActive()

						;_SendUnicode($sURL)
						;RunSleep(10)
						;$bResult = True

						writeDebugTimeLog("_SendClipboard 전")


						if _SendClipboard($sURL) = False then
							$_runErrorMsg = "URL 입력을 위한 클립보드 사용중 오류가 발생되었습니다."
						else
							$bResult = True
						endif

						if $bResult then SendSleep("{ENTER}")

						writeDebugTimeLog("접속 :" & $sURL)

						$_aLastNavigateTime = _TimerInit()

						RunSleep(100)

					endif

					WinSetOnTop($_hBrowser,"",0)
					hBrowswerActive()


			EndSwitch

			;RunSleep(1000)

			writeDebugTimeLog("commandNavigate waitForBrowserDone 전")

			$bTimeout = False

			; debugtimeout 이라도 최소 20초 이상을 Timeout으로 사용

			$iTimeOut = $_runWaitTimeOut
			if $iTimeOut  < 20000 then $iTimeOut   = 20000

			; 빨리 나오는 경우가 있음으로 1,2, $iTimeOut으로 3번 재확인 함,


			if $bResult and ($_runBrowser <> $_sBrowserIE) then

				if waitForBrowserDone($_runBrowser, False, $iTimeOut )  = False  then
					writeDebugTimeLog("waitForBrowserDone 4차 완료 실패")
					$bTimeout = True
					$bResult = False
					if $_bScriptStopping = False then

						if getIniBoolean(getReadINI("Report","FullSizeImage")) = True then
							_StringAddNewLine($_runErrorMsg , "웹 페이지 로딩이 완료되지 않았습니다.")
						else
							$bResult = True
							writeDebugTimeLog("commandNavigate _IELoadWait 에러가 발생되었으나, Skip")
						endif
					endif
				endif

				if $bResult = True then $_aLastNavigateTime = _TimerDiff($_aLastNavigateTime)

			endif



	;~ 		if $bResult and ($_runBrowser <> $_sBrowserIE) then

	;~ 			waitForBrowserDone($_runBrowser, False, 1000)
	;~ 			writeDebugTimeLog("waitForBrowserDone 1차 완료")

	;~ 			if waitForBrowserDone($_runBrowser, False, 2000)  = False and $_bScriptStopping = False then
	;~ 				writeDebugTimeLog("waitForBrowserDone 2차 완료")
	;~ 				runsleep (500)
	;~ 				if waitForBrowserDone($_runBrowser, False, 2000 )  = False and $_bScriptStopping = False then
	;~ 					writeDebugTimeLog("waitForBrowserDone 3차 완료")
	;~ 					runsleep (500)
	;~ 					if waitForBrowserDone($_runBrowser, False, $iTimeOut )  = False  then
	;~ 						writeDebugTimeLog("waitForBrowserDone 4차 완료 실패")
	;~ 						$bTimeout = True
	;~ 						$bResult = False
	;~ 						if $_bScriptStopping = False then

	;~ 							if getIniBoolean(getReadINI("Report","FullSizeImage")) = True then
	;~ 								_StringAddNewLine($_runErrorMsg , "웹 페이지 로딩이 완료되지 않았습니다.")
	;~ 							else
	;~ 								$bResult = True
	;~ 								writeDebugTimeLog("commandNavigate _IELoadWait 에러가 발생되었으나, Skip")
	;~ 							endif
	;~ 						endif
	;~ 					endif
	;~ 					writeDebugTimeLog("waitForBrowserDone 4차 완료")
	;~ 				endif
	;~ 			endif

	;~ 			if $bResult = True then $_aLastNavigateTime = _TimerDiff($_aLastNavigateTime)

	;~ 		endif

			writeDebugTimeLog("commandNavigate waitForBrowserDone 후, Timeout : " & $bTimeout)


			if $bResult = True or $_bScriptStopping = True then exitloop

			writeDebugTimeLog("commandNavigate 재시도")

		next

		if $bResult = True and $i > 1 then writeDebugTimeLog("commandNavigate 재시도성공")

		if $bResult = False then
			$_aLastNavigateTime = 0
			captureCurrentBorwser($_runErrorMsg, False)
		Else
			runsleep (100)
		endif
	endif

	return $bResult

endfunc


func _SendClipboard($string)

	local $bRet
	local $sOldClipText = ClipGet()

	if Clipput($string) = 1 then
		send("^v")
		$bRet = True
	endif

	return $bRet

endfunc


func getBrowserAdressPos($sScriptTarget, byref $x, byref $y)

	local $bImageSearch = False
	local $aImageList
	local $i
	local $aRetPos
	local $iStartX, $iStartY, $iEndX, $iEndY
	local $aWinPos

	$x=0
	$y=0

	$aWinPos = WinGetPos($_hBrowser)

	if IsArray($aWinPos) then

		$iStartX = $aWinPos[0]
		$iStartY = $aWinPos[1]
		$iEndX = $aWinPos[0] + $aWinPos[2]
		$iEndY = $aWinPos[1] + 120

		$bImageSearch = CheckResourceImage($sScriptTarget & "_ADDRESS", $iStartX, $iStartY, $iEndX, $iEndY, 5000, $x, $y )

	endif

	if $bImageSearch = False then
		_StringAddNewLine($_runErrorMsg , $sScriptTarget & " 주소창 위치를 확인 할 수 없습니다")
	else

		; 왼쪽으로 빈공간으로 좌표 이동
		Switch $sScriptTarget

			case $_sBrowserFF
				$x -= 110

			case $_sBrowserSA
				$x -= 100

			case $_sBrowserCR
				$x -= 100

			case $_sBrowserOP
				$x -= 20
		EndSwitch

	endif

	return $bImageSearch

endfunc



func commandSleep($iSec)

	local $bResult

	RunSleep ($iSec * 1000)

	;debug($iSec * 1000)

	$bResult = True

	return $bResult

endfunc


func commandInput($sText)

	local $bResult
	local $sTemp
	local $iDelay

	;$sTemp = ClipGet()
	;ClipPut($sText)
	;sleep(10000)
	;send("^v")

	$iDelay = Number(getReadINI("Environment","InputDelay"))
	if $iDelay = 0 then $iDelay = 500
	sleep($iDelay)

	if $_runWebdriver = False  then

		if ControlSend($_hBrowser,"",ControlGetFocus($_hBrowser,""),$sText) = 0 then
			$_runErrorMsg = "문자열을 입력 할 수 있는 Control이 현재 설정되지 않았습니다."
			$bResult = False
			captureCurrentBorwser($_runErrorMsg, False)
		Else
			$bResult = True
		endif

	else
		$bResult = _WD_send_keys($sText)
		if $bResult = False then WriteGuitarWebDriverError()
	endif
	sleep(100)

	return $bResult

endfunc


func commandKeySend($sText, $sType = "ANSI")

	local $bResult
	local $hCurrentWin
	local $bCorrectWindow = True
	local $sClassList
	local $iDelay


	; 대상 윈도우가 브라우저가 아닌 경우 ANSI 방식으로 입력 할 것
	convertHtmlChar($sText)


	if $_runWebdriver = False  then

		$hCurrentWin = WinGetHandle("[ACTIVE]")

		;if _ProcessGetName(WinGetProcess($hCurrentWin)) = getBrowserExe($_runBrowser) then $bCorrectWindow = True

		; 전체작업일 경우 윈도우에 제한을 두지 않고 입력함.
		;if $_runFullScreenWork then $bCorrectWindow = True


		;debug($sType, $sText)


		if $bCorrectWindow then

			$iDelay = Number(getReadINI("Environment","InputDelay"))
			if $iDelay = 0 then $iDelay = 500
			sleep($iDelay)


			setTestHotKey(False)

			if $sType = "ANSI" then
				send($sText)
			Else

				;debug(Opt("SendKeyDelay"))
				;debug(Opt("SendKeyDownDelay"))

				_SendUnicode($sText)

			endif

			setTestHotKey(True)

			$bResult = True

		Else
			$_runErrorMsg = "키보드를 입력할 수 없는 화면입니다. 타이틀 : " & WinGetTitle($hCurrentWin)
			;debug("ClassList : " & $sClassList )
			;debug("Porcess : " & _ProcessGetName(WinGetProcess($hCurrentWin) ))

			captureCurrentBorwser($_runErrorMsg, True)
			$bResult = False
		endif
		;SendKeepActive ("")
		;debug($sText, Stringlen($sText))
		;send($sText)
	Else
		$bResult = _WD_send_keys($sText)
		if $bResult = False then WriteGuitarWebDriverError()
	endif


	return $bResult

endfunc




func CaptureTextActiveWindow(byref $sClipText)

	local $bResult = True
	local $aMousePos
	local $sOldClipText = ClipGet()
	local $sClipError = "Clipboard 작업중 오류가 발생되었습니다."
	local $i
	local $bClipBoardError = False

	$sClipText = ""

	;마우스 위치 저장
	$aMousePos = MouseGetPos()


	;마우스 왼쪽 로 클릭
	;setMouseClickLeftDown()
	;sleep(10)


	;mouseClick("left")
	;sleep(10)

	;CTRL + a 눌러
	send("^a")
	sleep(500)


	;이전 클립보드 내용을 저장
	$sOldClipText = ClipGet()

	;CTRL + c 복사

	for $i= 1 to 5
		send("^c")
		sleep(500)
		if $sOldClipText <> ClipGet() then exitloop
	next


	for $i= 1 to 5
		$sClipText = ClipGet()
		if @error then $bClipBoardError = True
		if $bClipBoardError = False then ExitLoop
		sleep (500)
	next


	if @error then
		_StringAddNewLine($_runErrorMsg , "Clipboard 읽기 작업중 오류가 발생되었습니다. Errorcode : " & @error)
		$bResult = False
	endif

	ClipPut($sOldClipText)

	;마우스 왼쪽 가운데로 클릭
	;setMouseClickLeftTop()
	;sleep(100)
	;mouseClick("left")

	;블럭 해제를 위해 TAB 키 10번
;~ 	send("{TAB}")
;~ 	sleep(10)
;~ 	send("{TAB}")
;~ 	sleep(10)
;~ 	send("{TAB}")
;~ 	sleep(10)
;~ 	send("{TAB}")
;~ 	sleep(10)
;~ 	send("{TAB}")
;~ 	sleep(10)
;~ 	send("{TAB}")
;~ 	sleep(10)
;~ 	send("{TAB}")
;~ 	sleep(10)
;~ 	send("{TAB}")
;~ 	sleep(10)
;~ 	send("{TAB}")
;~ 	sleep(10)
;~ 	send("{TAB}")
;~ 	sleep(10)
;~ 	send("{TAB}")
;~ 	sleep(10)
;~ 	send("{TAB}")
;~ 	sleep(10)
;~ 	send("{TAB}")
;~ 	sleep(10)
;~ 	send("{TAB}")
;~ 	sleep(10)
;~ 	send("{TAB}")
;~ 	sleep(10)
;~ 	send("{TAB}")
;~ 	sleep(10)
;~ 	send("{TAB}")
;~ 	sleep(10)


;~ 	send("{LEFT}")
;~ 	sleep(10)
;~ 	send("{LEFT}")
;~ 	sleep(10)
;~ 	send("{LEFT}")
;~ 	sleep(10)
;~ 	send("{LEFT}")
;~ 	sleep(10)

;~ 	send("{HOME}")
;~ 	sleep(10)



	;마우스 위치 복원
	MouseMove($aMousePos[0],$aMousePos[1] ,0)

	;클립보드 내용을 리턴
	return $bResult

endfunc

func commandTextAsert($sText, $iTimeOut = $_runWaitTimeOut, $bIsErrorCheck = True )

	local $bResult = False
	local $sLocalText
	local $sTemp
	local $aTextAsert
	local $i
	local $tTimeInit = _TimerInit()
	local $iFoundCount = 0
	local $sNotFoundString = ""
	local $sConvertChar
	local $sTempBrowser, $oMyError

	do

		if $_runBrowser = $_sBrowserIE then

			seterror(0)
			$oMyError = ObjEvent("AutoIt.Error","UIAIE_NullError")
			$sTempBrowser = _IEAttach2($_hBrowser,"HWND")

			if _IEPropertyGet ($sTempBrowser, "hwnd") <> $_hBrowser then
				_StringAddNewLine ( $_runErrorMsg , "IE 브라우저를 사용할 수 없습니다.")
				return False
			endif

			$sLocalText = IEObjectGetAllInnerHtml($sTempBrowser)


			;debug("내용:" & $sLocalText)

		else
			if CaptureTextActiveWindow($sLocalText) = False then exitloop
		endif
		;$sLocalText = TCaptureXCaptureActiveWindow(WinGetHandle("[ACTIVE]"))

		$aTextAsert = StringSplit($sText,",")

		$iFoundCount = 0
		$sNotFoundString = ""

		for $i=1 to ubound($aTextAsert) -1
			$aTextAsert[$i] = _Trim($aTextAsert[$i])

			; 특수 문자를 변환한뒤 검사할것
			$sConvertChar = $aTextAsert[$i]
			convertHtmlChar ($sConvertChar)

			if StringInStr($sLocalText,$sConvertChar,1) > 0 then
				$iFoundCount +=1
			Else
				if $sNotFoundString <> "" then $sNotFoundString = $sNotFoundString & ", "
				$sNotFoundString = $sNotFoundString & $aTextAsert[$i]
			endif
		next

		if (ubound($aTextAsert) -1 = $iFoundCount) and ($iFoundCount > 0) then  $bResult = True

		;debug("찾은갯수 : " & $iFoundCount, $bResult)

		if $bResult = False then runsleep(1000)

	until $bResult or _TimerDiff($tTimeInit) > $iTimeOut or checkScriptStopping() = True


	if not $bResult then

		if $bIsErrorCheck then
			_StringAddNewLine($_runErrorMsg , "문자열을 찾을 수 없음 : " & $sNotFoundString)
			captureCurrentBorwser($_runErrorMsg, False)
		endif

		;debug("text:" & $sLocalText)

	endif

	if $bIsErrorCheck = False  then $_runErrorMsg = ""

	return $bResult

endfunc


func commandMouseDragAndDrop($sScriptTarget, $sType)

	local $bResult
	local $x
	local $y
	local $aImageFile
	local $bFileNotFoundError
	local $sWebElementID
	local $sWebDriverAction = ""

	$bResult = getRunCommnadImageAndSearchTarget ($sScriptTarget, $aImageFile,  $x , $y, True, $_runWaitTimeOut, $bFileNotFoundError)

	if  $bResult = True  then

		if $_runWebdriver = False  then
			hBrowswerActive ()
			addCorrectionYX( $x ,  $y)
			if $sType = "drag" then
				MouseMove($x , $y,1)
				MouseDown ("left")
			elseif $sType = "drop" then
				MouseMove($x , $y,5)
				Mouseup ("left")
			elseif $sType = "move" then
				MouseMove($x , $y,1)
			endif
				RunSleep(1)
		else
			$sWebElementID = $x

			$x=0
			$y=0

			addCorrectionYX( $x ,  $y)

			if $sType = "drop" then $sWebDriverAction = "/buttonup"
			if $sType = "drag" then $sWebDriverAction = "/buttondown"
			if $sType = "move" then $sWebDriverAction = "/moveto"

			$bResult = _WD_MoveAndAction($sWebElementID, $sWebDriverAction ,  0, $x, $y)

			if $bResult = False then WriteGuitarWebDriverError()

		endif

	endif

	return $bResult

endfunc


; -----------------------------------------------------------------------------------------------------

func getRunCommnadImage($sScriptTarget,byref $aImageFile, $bPreView = True )
; 명령어 지정된 이미지를 찾아서 배열로 전달

	local $bResult
	local $i
	local $aTempImageFile[1]
	local $iLastArraySize
	local $aReportImage

	$aImageFile = $aTempImageFile

	;debug($_aRunImagePathList)
	;debug($sScriptTarget)

;~ 	for $i= 0 to ubound($_aRunImagePathList) -1 step 1

;~ 		$iLastArraySize = ubound($aImageFile)

;~ 		foundImageFile( $_aRunImagePathList[$i], $sScriptTarget, $aImageFile)
;~ 		;debug($aImageFile)
;~ 		sortImageListByOSBrowser ($aImageFile,$_runBrowser, $iLastArraySize)
;~ 	next
;~

	$aImageFile = _findFolderFileInfo($_sImageForderFileList, $sScriptTarget & $_cImageExt & $_sCommandImageSearchSplitChar & $sScriptTarget & "_", False)



	; 리포트 폴더에 대상 파일이 있을 경우 추가함

	$aReportImage = _GetFileNameFromDir ($_runWorkReportPath , $sScriptTarget & $_cImageExt, 1)

	if IsArray($aReportImage) then

		for $i=1 to ubound($aReportImage) -1
			_ArrayAdd($aImageFile, $aReportImage[$i])
			;debug($aReportImage[$i])
		next



	endif

	if ubound($aImageFile) <= 1 then
		$_runErrorMsg = "이미지 파일이 존재하지 않음 : " & $sScriptTarget
		$bResult = False
	Else
		$_runLastImageArray = $aImageFile
		$_runLastImageArray [0] = $sScriptTarget
		$bResult = True
	endif

	$_runErrorImageTarget = $sScriptTarget

	if $bResult = True then
		for $i=1 to ubound($aImageFile) -1
			writeDebugTimeLog($aImageFile[$i])
		next
		if $bPreView then _viewLastUseedImage()
		sleep(10)
	endif

	return $bResult

endfunc


; JS 오류 확인
func CheckScriptError($sBrowserType)

	local $iStartX, $iStartY, $iEndX, $iEndY
	local $bScriptError = False
	local $aWinPos
	local $sErrorImageName
	local $x,$y
	local $sIEErrorMsgboxinfo = "[Class:Internet Explorer_TridentDlgFrame]"


	writeDebugTimeLog("스크립트 오류 확인 시작")



	if $sBrowserType = $_sBrowserIE Then

		writeDebugTimeLog("IE 오류창 확인 : " & WinExists($sIEErrorMsgboxinfo) )
		if WinExists($sIEErrorMsgboxinfo) Then $bScriptError = True

	endif


	if $bScriptError  = False then

		Switch $sBrowserType

			case $_sBrowserIE, $_sBrowserFF, $_sBrowserCR

				$aWinPos = WinGetPos($_hBrowser)



				if IsArray($aWinPos) = False then return $bScriptError


				Switch $sBrowserType

					case $_sBrowserIE

						$iStartX = $aWinPos[0]
						$iStartY = $aWinPos[1] + $aWinPos[3] - 40
						$iEndX = $aWinPos[0] + 50
						$iEndY = $aWinPos[1]+ $aWinPos[3]

						$sErrorImageName = "SCRIPTERROR_IE"

					case $_sBrowserFF

						$iStartX = $aWinPos[0] + $aWinPos[2] - 180
						$iStartY = $aWinPos[1] + $aWinPos[3] - 30
						$iEndX = $aWinPos[0] + $aWinPos[2] - 60
						$iEndY = $aWinPos[1]+ $aWinPos[3]

						$sErrorImageName = "SCRIPTERROR_FF"

					case $_sBrowserCR

						$iStartX = $aWinPos[0] + $aWinPos[2] - 150
						$iStartY = $aWinPos[1] + 45
						$iEndX = $aWinPos[0] + $aWinPos[2] - 60
						$iEndY = $aWinPos[1] + 80

						$sErrorImageName = "SCRIPTERROR_CR"

				EndSwitch

				;debug($iStartX, $iStartY, $iEndX, $iEndY)

				if $bScriptError = False then $bScriptError = CheckResourceImage($sErrorImageName, $iStartX, $iStartY, $iEndX, $iEndY, 0, $x, $y)

			case else
				writeDebugTimeLog("스크립트 오류 Skip")

		EndSwitch

	endif

	writeDebugTimeLog("스크립트 오류 확인 종료")

	if $bScriptError = True then
		$_runErrorMsg = "브라우저 자바스크립트 오류발생"
		captureCurrentBorwser($_runErrorMsg, True)
		if $sBrowserType = $_sBrowserIE and  WinExists($sIEErrorMsgboxinfo) Then WinClose($sIEErrorMsgboxinfo)
	endif

	$_runLastScriptErrorCheck = $bScriptError



	return $bScriptError

endfunc


func getTransparentImageAndColor($sFile)

	local $iColor = ""

	if StringInStr($sFile,$_sTransparentKey) <> 0 then  $iColor = getTransparentImageColor($sFile)

	return $iColor

endfunc


func CheckResourceImage($sImageName, $iStartX, $iStartY, $iEndX, $iEndY, $iTimeOut, byref $x, byref $y)

	local $aResourceImage [1]

	local $aRetPos
	local $i
	local $bFound = False
	local $iTimeInit = _TimerInit()
	local $iCurTolerance
	local $bCRCCheck
	local $iTransparentColor


	$x = 0
	$y = 0

	if IsHWnd($_hBrowser) and WinExists($_hBrowser) then

		foundImageFile ($_runResourcePath, $sImageName, $aResourceImage)

		;writeDebugTimeLog("$aResourceImage ubound : " & ubound($aResourceImage))

		if ubound($aResourceImage) < 2 or $aResourceImage = "" then
			_StringAddNewLine($_runErrorMsg , "시스템 필수 이미지 파일이 존재 하지 않습니다. " & $_runResourcePath & "\" & $sImageName & "*" & $_cImageExt)
			_StringAddNewLine($_runErrorMsg , "프로그램이 설치된 GUITAR\BIN 폴더를 최신버전으로 업데이트 한 뒤 사용하시기 바랍니다.")
			return $bFound
		endif

		;msg($aScriptErrorImage)

		$iCurTolerance = int($_runTolerance / 10)

		do

			for $i= 1 to ubound($aResourceImage) -1

				$iTransparentColor = getTransparentImageAndColor ($aResourceImage[$i])
				if _ImageSearchArea2($aResourceImage[$i],1, $iStartX, $iStartY, $iEndX, $iEndY, $x, $y, $iCurTolerance, $aRetPos, False, $bCRCCheck, $iTransparentColor ) = 1 then $bFound = True
				if $bFound then exitloop
				;debug(checkScriptStopping())
			next

			$iCurTolerance += $iCurTolerance
			if $iCurTolerance > $_runTolerance then $iCurTolerance = $_runTolerance

			if $iTimeOut > 0 then runsleep(100)
			;debug(_TimerDiff($iTimeInit)  , $iTimeOut )

		until (_TimerDiff($iTimeInit)  > $iTimeOut or $bFound ) or $bFound or checkScriptStopping() = True

	endif

	;msg(checkScriptStopping())

	return $bFound

endfunc


Func RunSleep($iTime)

	local $iTimeDiff
	local $iTimeUnit = 10

	$iTimeDiff = _Timerinit()

	do
		;_waitFormMain()
		if $iTime > $iTimeUnit then
			sleep($iTimeUnit)
		Else
			sleep($iTime)
		endif

		_ViewRuntimeToolTip()

	;debug(_TimerDiff($iTimeDiff) , $iTime)
	until _TimerDiff($iTimeDiff) > $iTime or checkScriptStopping()

endfunc

Func SendSleep($sKey, $iTime = 10)
; 명령어를 전달하고 기본값을 쉼
	Send($sKey)
	RunSleep($iTime)
endfunc

func getRunCommnadImageAndSearchTarget ($sScriptTarget, byref $aImageFile,  byref $x , byref $y, $bWait, $iTimeOut, byref $bFileNotFoundError, $isFullSearch = False)

	local $bResult = False
	local $aImageList[2]
	local $a
	local $bAllSearch, $bAllSearchImage
	local $aSearchResult[1][10][6]
	local $i
	local $j
	local $aRetPos
	local $aImageRoad [1]
	local $sPositionImage
	local $aWinPos
	local $oTag = ""
	local $aTemprunAreaWork = $_runAreaWork
	local $aMaxImageInfo
	local $bMultiFastSearch, $bMultiFastSearchCount
	local $iFastTimeOut
	local $bVerify
	local $sSearchType,  $sSearchValue, $sSearchResultID
	local $tTimeInitAll

	$bFileNotFoundError = False
	$aImageFile = $aImageRoad
	$bMultiFastSearchCount = 0

	;debug ($aImageList)
	;debug($bWait)

	; TAG 방식인 경우 ","로 나누지 않고 하나로 처리함
	if getIEObjectType($sScriptTarget) = False and isWebdriverParam ($sScriptTarget) = False then
		$aImageList = StringSplit($sScriptTarget,",")
	else
		$aImageList[1] = $sScriptTarget
	endif

	if $_runWebdriver = False and isWebdriverParam ($sScriptTarget) = True then
		_StringAddNewLine ( $_runErrorMsg , "Webdriver 세션모드가 아닙니다. Webdriver 형태 명령은 '세션생성' 명령 사용후 사용하시기 바랍니다. " & $sScriptTarget)
		return False
	endif


	if ubound($aImageList) >  2 then
		; 인접 이미지 확인인 경우 0.5초 대기후 검색하도록 함(모든 이미지가 로드될 때 까지 기다림)
		$bAllSearch = True
		$bMultiFastSearch = True

		; 전체 이미지중에 가장큰 이미들의 정보를 미리 가져옴
		$aMaxImageInfo = getMaxSizeFormImageList($aImageList)

		;msg($aMaxImageInfo)
	Else
		$bAllSearch = False
	endif

	do
		$bMultiFastSearchCount +=1

		if $bMultiFastSearchCount > 1  then
			$bMultiFastSearch = False
		endif

		$iFastTimeOut = $iTimeOut

		if $bAllSearch then
			redim $aSearchResult[1][10][6]
			redim $aSearchResult[ubound($aImageList)][1000][6]
		endif

		for $i=1 to ubound($aImageList) -1

			$aImageList[$i] = _Trim($aImageList[$i])

			if $i = ubound($aImageList) -1 then $sPositionImage = $aImageList[$i]

			if getIEObjectType($aImageList[$i]) = False and isWebdriverParam ($aImageList[$i]) = False then
				; 이미지 방식 경우

				writeDebugTimeLog("이미지 읽어 오기" )
				if getRunCommnadImage($aImageList[$i], $aImageFile) = False  then
					$bFileNotFoundError = True
					$bResult = False
				else
					writeDebugTimeLog("이미지 읽어 오기 완료")
					;if $i > 1 then $iTimeOut = 1

					; 2개 이상 다중 이미지 찾기 일때 찾고자 하는 영역을 최소화 함.
					if $i > 1 then $_runAreaWork = getMultiSearchArea ($aSearchResult, $aMaxImageInfo, $i, $_runMultiImageRange)

					; 빠른찾기 이면서 2번째 이상인 경우 timeout을 1초로 가져감 (첫번째 이미지를 찾았음으로 빨리 시작)
					if $bMultiFastSearch then $iFastTimeOut = 500

					; 빠른 검색이면서 첫번째 이미지 검색일 경우 기존과 같이 검색할것
					if $i = 1  and  $bMultiFastSearch then
						$bAllSearchImage = False
						$iFastTimeOut = $iTimeOut
					else
						$bAllSearchImage = $bAllSearch
					endif

					$bVerify = not(checkTargetisBrowser($_runBrowser) and $_runVerifyTime <> 0)

					;debug($i, $_hBrowser)
					;debug($aImageFile)

					if SearchTargetVerify($_hBrowser, $aImageFile , $x , $y, $bWait, $iFastTimeOut, $bAllSearchImage, $aRetPos, $isFullSearch, $bVerify) = False then

						$bResult = False
						;debug ("찾지 못함")
						;debug ($aImageFile)

						if ($bWait = True and checkScriptStopping() = False)  then
							; 빠른 찾기가 아닌 경우에만 에러를 기록함.
							if $bMultiFastSearch = False then $_runErrorMsg = setImageSearchError ($aImageList[$i], $aImageFile)
						endif

						if $bAllSearch then _StringAddNewLine ( $_runErrorMsg ,"이미지들이 서로 인접한곳에 있지 않습니다 : "  & $sScriptTarget)

						exitloop

					Else

						;debug ("찾음")
						;debug ($aImageFile)


						if $bAllSearch then
							writeDebugTimeLog("에러 의심구역1")
							;debug($x)

							; 다중 결과가 있을 경우
							if IsArray($x) then

								for $j= 1 to ubound($x) -1
									$aSearchResult[$i][$j][1] = $x[$j]
									$aSearchResult[$i][$j][2] = $y[$j]
									$aSearchResult[$i][$j][3] = $aRetPos[4]
									$aSearchResult[$i][$j][4] = $aRetPos[5]
									$aSearchResult[$i][$j][5] = $aImageList[$i]
								next
								writeDebugTimeLog("에러 의심구역2")
							else
								$aSearchResult[$i][1][1] = $aRetPos[2]
								$aSearchResult[$i][1][2] = $aRetPos[3]
								$aSearchResult[$i][1][3] = $aRetPos[4]
								$aSearchResult[$i][1][4] = $aRetPos[5]
								$aSearchResult[$i][1][5] = $aImageList[$i]
							endif

						endif

						$bResult = True
					endif
				endif

			elseif  getIEObjectType($aImageList[$i]) = True then
			; TAG 방식 찾기

				; IE Object 방식 경우
				; 현재 브라우저가 IE가 아닌 경우 오류 처리
				if $_runBrowser = $_sBrowserIE then

					$bResult = SearchIEObjectTarget($_hBrowser,$aImageList[$i], $x, $y, $aRetPos, $oTag, $bWait , $iTimeOut)

					if $bResult  = False then
						if ($bWait = True and checkScriptStopping() = False)  then
							if IsArray($aRetPos) then
								_StringAddNewLine ( $_runErrorMsg ,$aRetPos[0] & " : "  & $aImageList[$i])
								captureCurrentBorwser($_runErrorMsg, False)
							endif
						endif
					else
						;좌표 0번 배열에 찾은 Tag를 리턴함.
						$aImageFile = $aImageRoad
						_ArrayAdd($aImageFile, $oTag)
					endif

				else
					_StringAddNewLine ( $_runErrorMsg ,"IE 브라우저에서만 Tag방식으로 대상을 지정 할 수 있습니다.")
				endif
			elseif  isWebdriverParam ($aImageList[$i]) = True then
			; WEBDriver 방식 찾기
				$tTimeInitAll = _TimerInit()

				if getWebdriverParamTypeAndValue($aImageList[$i],  $sSearchType,  $sSearchValue) then
					do
						setStatusText (getTargetSearchRemainTimeStatusText($tTimeInitAll, $iTimeOut, $aImageList[$i]))
						$sSearchResultID = _WD_find_element_with_highlight_by($sSearchType, $sSearchValue, $_runRetryRun , $_runHighlightDelay)
						if $sSearchResultID = "" then RunSleep (500)
					until $sSearchResultID <> "" or (_TimerDiff($tTimeInitAll) > $iTimeOut) or (checkScriptStopping())

					if $sSearchResultID <> "" then
						$bResult = True
						$x = $sSearchResultID
						; X값에 검색된 ID값을 전달
					else
						if checkScriptStopping() = False then WriteGuitarWebDriverError ()
					endif
				else
					_StringAddNewLine ( $_runErrorMsg , "Webdriver 테스트 입력정보가 바르지 않습니다. {검색방식:검색조건}")
				endif

			endif

		next


		if $bResult and IsArray($aRetPos) then
			; 최신 사용 이미지 크기

			$aRetPos[1] = $aRetPos[2]
			$aRetPos[2] = $aRetPos[3]
			$aRetPos[3] = $aRetPos[1] + $aRetPos[4]
			$aRetPos[4] = $aRetPos[2] + $aRetPos[5]

		endif

		;debug($aSearchResult)

		writeDebugTimeLog("이미지 읽어 오기 완료 2차 ")

		if $bAllSearch and $bResult then
			$bResult = selectMultiImage($aSearchResult, $aImageRoad, $x, $y, $_runMultiImageRange, $sPositionImage, $aRetPos)
			if $bResult = False and $bMultiFastSearch = False then
				if $_runErrorMsg  = "" then
					$_runErrorMsg = "이미지들이 서로 인접한곳에 있지 않습니다 : "  & $sScriptTarget
					;debug($_runErrorMsg)
					captureCurrentBorwser($_runErrorMsg, False)

				endif
			endif

		endif

		writeDebugTimeLog("이미지 읽어 오기 완료 3차 " )

		if $bResult = True then

			$aWinPos = WinGetPos($_hBrowser)

			if IsArray($aWinPos) then
				$_aLastUseMousePos[1] = $x - $aWinPos[0]
				$_aLastUseMousePos[2] = $y  - $aWinPos[1]
			endif


			if IsArray($aRetPos) then
				$_aLastUseMousePos[3] = ""
				$_aLastUseMousePos[3] = $_aLastUseMousePos[3] & ($aRetPos[1] - $aWinPos[0]) & ","
				$_aLastUseMousePos[3] = $_aLastUseMousePos[3] & ($aRetPos[2] - $aWinPos[1]) & ","
				$_aLastUseMousePos[3] = $_aLastUseMousePos[3] & ($aRetPos[3] - $aWinPos[0]) & ","
				$_aLastUseMousePos[3] = $_aLastUseMousePos[3] & ($aRetPos[4] - $aWinPos[1])
			endif

		endif

		$_runAreaWork = $aTemprunAreaWork

		; 재시도를 위하 기존의 에러 정보를 초기화 함.
		if $bMultiFastSearch and $bResult = False then
			$_runErrorMsg = ""
		endif

	until $bMultiFastSearch = False or $bResult = True or checkScriptStopping() = True

	return $bResult

endfunc


func getMaxSizeFormImageList(byref $aImageList)

	local $aImageFile, $i, $j
	local $aImageInfo, $iImageWidth, $iImageHeight
	local $aImageFile
	local $aMaxImageInfo[ubound($aImageList)][3]

	for $i=1 to ubound($aImageList) -1

		$aMaxImageInfo[$i][1] = 0
		$aMaxImageInfo[$i][2] = 0

		getRunCommnadImage(_Trim($aImageList[$i]), $aImageFile, False)
		;debug($aImageList[$i])
		;debug($aImageFile)

		for $j=1 to ubound($aImageFile) -1
			; 이미지 파일 크기 확인

			;debug("이미지 확인 : " & $aImageFile[$j])
			getImageSize($aImageFile[$j], $iImageWidth, $iImageHeight)

			if $aMaxImageInfo[$i][1] < $iImageWidth then $aMaxImageInfo[$i][1] = $iImageWidth
			if $aMaxImageInfo[$i][2] < $iImageHeight then $aMaxImageInfo[$i][2] = $iImageHeight

		next

	next


	return $aMaxImageInfo

endfunc


func getMultiSearchArea(byref $aSearchResult, byref $aMaxImageInfo, $iCurrentImageIndex, $iAddBoder)

	local $aRetArea[6]
	local $i
	local $iMax = 999999
	local $iLeft=$iMax , $iTop=$iMax, $iBottom=$iMax * (-1), $iRight=$iMax * (-1)

	;msg($aSearchResult)
	; 1부터 현재까지의 전체 영역의 가장 최저값을 구하기 (윈쪽, 오른쪽, 위, 아래)
	for $i=1 to $iCurrentImageIndex -1

		for $j= 1 to ubound($aSearchResult,2) -1

			;writeDebugTimeLog("기존 정보 취합 " & $j & " " & $aSearchResult[$i][$j][1])

			if $aSearchResult[$i][$j][1] = "" then ExitLoop

			if $iLeft > $aSearchResult[$i][$j][1] then $iLeft = $aSearchResult[$i][$j][1]
			if $iTop > $aSearchResult[$i][$j][2] then $iTop = $aSearchResult[$i][$j][2]

			if $iRight  < $aSearchResult[$i][$j][1] + $aSearchResult[$i][$j][3] then $iRight = $aSearchResult[$i][$j][1] + $aSearchResult[$i][$j][3]
			if $iBottom < $aSearchResult[$i][$j][2] + $aSearchResult[$i][$j][4] then $iBottom = $aSearchResult[$i][$j][2] + $aSearchResult[$i][$j][4]

			;debug($aSearchResult[$i][$j][1], $aSearchResult[$i][$j][2], $aSearchResult[$i][$j][3], $aSearchResult[$i][$j][4])

		next
	next


	;debug("최종1 :" & $iLeft, $iTop, $iRight, $iBottom)

	for $i= $iCurrentImageIndex to ubound($aMaxImageInfo) -1
		;debug("증가감값 : " & $aMaxImageInfo[$i][1], $aMaxImageInfo[$i][2])
		$iLeft = $iLeft - $aMaxImageInfo[$i][1] - $iAddBoder
		$iRight += $aMaxImageInfo[$i][1] + $iAddBoder

		$iTop = $iTop - $aMaxImageInfo[$i][2] - $iAddBoder
		$iBottom += $aMaxImageInfo[$i][2] + $iAddBoder

	next

	;debug("최종2 :" & $iLeft, $iTop, $iRight, $iBottom)
	; 남아 있는 이미지들중에 이미지명 별로 가장 큰정보를 찾아서 그들의 합 을 구합

	; 임시로 $_runAreaWork 값을 설정하여 사용함
	$aRetArea[0] = _iif($iLeft=$iMax, False, True)
	$aRetArea[1] = $iLeft
	$aRetArea[2] = $iTop
	$aRetArea[3] = $iRight
	$aRetArea[4] = $iBottom

	; 좌표 사용시 절대 좌표로 계산
	$aRetArea[5] = False


	return $aRetArea

endfunc


func selectMultiImage(byref $aSearchResult, byref $aImageRoad, byref  $x,byref  $y, $iAddBoder, $sPositionImage, byref $aRetPos)

	local $i, $j
	local $bFound = False

	if ubound($aImageRoad) <> ubound($aSearchResult) then
		redim $aImageRoad [ubound($aSearchResult)]
	endif

	;debug($aSearchResult)

	for $i=1 to ubound($aSearchResult,2) -1

		for $j=1 to ubound($aSearchResult) -1
			$aImageRoad[$j] = ""
		next

		$aImageRoad[1] = $i

		selectMultiImageRec($aSearchResult, $aImageRoad, $iAddBoder)

		$bFound = checkMultiImageAllFound($aImageRoad)

		;debug($aSearchResult)

		if $bFound then exitloop

	next

	if $bFound then getMultiImagePos($aSearchResult, $aImageRoad, $x, $y , $sPositionImage, $aRetPos)

	return $bFound

endfunc

func selectMultiImageRec(byref $aSearchResult, byref $aImageRoad,  $iAddBoder)

	local $i, $j, $k
	local $bFound = False
	local $iUp
	local $iDown
	local $iLeft
	local $iRight
	local $iSearchIndex
	local $bWidthCompare
	local $bHeightCompare
	local $iBaseLeft, $iBaseRight, $iBaseUp, $iBaseDown
	local $iTargetLeft, $iTargetRight, $iTargetUp, $iTargetDown
	local $bCompareLeft
	local $iMax
	local $iMin
	local $bExistFound

	for $i=1 to ubound($aSearchResult) -1

		if $aImageRoad[$i] <> "" then ContinueLoop

		for $j=1 to ubound($aSearchResult,2) -1

			if $aSearchResult[$i][$j][1] = "" then exitloop

			;$bExistFound = False

			;for $k = 1 to ubound($aImageRoad)  -1
			;	if $k = $j then $bExistFound = True
			;next

			if $bExistFound then ContinueLoop

			for $iSearchIndex =1 to ubound($aImageRoad)  -1

				$bWidthCompare = False
				$bHeightCompare = False

				if $aImageRoad[$iSearchIndex] = "" or $iSearchIndex = $i then ContinueLoop

				$iBaseLeft = $aSearchResult[$iSearchIndex][$aImageRoad[$iSearchIndex]][1]
				$iBaseUp = $aSearchResult[$iSearchIndex][$aImageRoad[$iSearchIndex]][2]
				$iBaseRight = $aSearchResult[$iSearchIndex][$aImageRoad[$iSearchIndex]][1] + $aSearchResult[$iSearchIndex][$aImageRoad[$iSearchIndex]][3]
				$iBaseDown = $aSearchResult[$iSearchIndex][$aImageRoad[$iSearchIndex]][2] + $aSearchResult[$iSearchIndex][$aImageRoad[$iSearchIndex]][4]

				$iTargetLeft = $aSearchResult[$i][$j][1]
				$iTargetUp = $aSearchResult[$i][$j][2]
				$iTargetRight = $aSearchResult[$i][$j][1] + $aSearchResult[$i][$j][3]
				$iTargetDown = $aSearchResult[$i][$j][2] + $aSearchResult[$i][$j][4]

				;debug("Base Left,Right: " & $iBaseLeft, $iBaseRight )
				;debug("Target Left, Right: " & $iTargetLeft, $iTargetRight)
				;debug(($iTargetLeft > $iBaseLeft) , ($iTargetRight > $iBaseRight) , ($iTargetLeft - $iBaseRight))

				; 좌, 우 비교


				;debug("Base : " & $aSearchResult[$iSearchIndex][$aImageRoad[$iSearchIndex]][5] & " "  & $aImageRoad & " " & $iSearchIndex)
				;debug("Target : " & $aSearchResult[$i][$j][5]&  " " & $i & " " & $j)

				;debug("Base Left, Right : " & $iBaseLeft, $iBaseRight)
				;debug("Base Up,Down : " & $iBaseUp, $iBaseDown)
				;debug("Target Left, Right: " & $iTargetLeft, $iTargetRight)
				;debug("Target Up, Down: " & $iTargetUp, $iTargetDown)


				if     (($iTargetLeft < $iBaseLeft) and ($iTargetRight < $iBaseRight) and ($iBaseLeft - $iTargetRight < $iAddBoder) ) _
				   or  (($iTargetLeft > $iBaseLeft) and ($iTargetRight > $iBaseRight) and ($iTargetLeft - $iBaseRight < $iAddBoder) ) then
					; 높이가 작은것 대비 50%이상은 포함된 경우 정상
					if _Max($iTargetDown ,$iBaseDown) - _min($iTargetUp ,$iBaseUp) < $aSearchResult[$iSearchIndex][$aImageRoad[$iSearchIndex]][4] +  $aSearchResult[$i][$j][4] - (_min($aSearchResult[$iSearchIndex][$aImageRoad[$iSearchIndex]][4] ,  $aSearchResult[$i][$j][4]) / 2)  then

						$bWidthCompare= True
					endif
					;debug("Width Compare : " & $aSearchResult[$i][$j][5] & " " & $bWidthCompare &  " " & $i & " " & $j)

				endif

				; 상, 하 비교
				if     (($iTargetUp < $iBaseUp) and ($iTargetDown < $iBaseDown) and ($iBaseUp - $iTargetDown < $iAddBoder) ) _
				   or  (($iTargetUp > $iBaseUp) and ($iTargetDown > $iBaseDown) and ($iTargetUp - $iBaseDown < $iAddBoder) ) then

					; 넓이가가 작은것 대비 50%이상은 포함된 경우 정상
					if _Max($iTargetRight ,$iBaseRight) - _min($iTargetLeft ,$iBaseLeft) < $aSearchResult[$iSearchIndex][$aImageRoad[$iSearchIndex]][3] +  $aSearchResult[$i][$j][3] - (_min($aSearchResult[$iSearchIndex][$aImageRoad[$iSearchIndex]][3] , $aSearchResult[$i][$j][3]) / 2 )    then
						;debug ( "$iTargetRight =" & $iTargetRight)
						;debug ( "$iBaseRight =" & $iBaseRight)
						;debug ( "$iTargetLeft =" & $iBaseLeft)
						;debug ( "$iBaseLeft =" & $iBaseLeft)
						;debug ( "max - min =" & _Max($iTargetRight ,$iBaseRight) - _min($iTargetLeft ,$iBaseLeft))


						;debug ( "base width  =" & $aSearchResult[$iSearchIndex][$aImageRoad[$iSearchIndex]][3])
						;debug ( "target width  =" & $aSearchResult[$i][$j][3])
						;debug ( "- 1/2  =" & _min($aSearchResult[$iSearchIndex][$aImageRoad[$iSearchIndex]][3] , $aSearchResult[$i][$j][3]) / 2 )
						;debug ( "- 1/2  =" & _min(number($aSearchResult[$iSearchIndex][$aImageRoad[$iSearchIndex]][3]) , number($aSearchResult[$i][$j][3])))

						;debug ( $aSearchResult[$iSearchIndex][$aImageRoad[$iSearchIndex]][3] +  $aSearchResult[$i][$j][3] - (_min($aSearchResult[$iSearchIndex][$aImageRoad[$iSearchIndex]][3] , $aSearchResult[$i][$j][3]) / 2 )  )

						$bHeightCompare = True
					endif
					;debug("Height Compare : " & $aSearchResult[$i][$j][5] & " " & $bHeightCompare &  " " & $i & " " & $j)

				endif

;~ 				; 오른쪽, 아래 기준
;~ 				$iLeft = ($aSearchResult[$iSearchIndex][$aImageRoad[$iSearchIndex]][1]) - ($aSearchResult[$i][$j][1] + $aSearchResult[$i][$j][3])
;~ 				$iRight = $aSearchResult[$i][$j][1] - ($aSearchResult[$iSearchIndex][$aImageRoad[$iSearchIndex]][1] + $aSearchResult[$iSearchIndex][$aImageRoad[$iSearchIndex]][3])
;~ 				$iUp = ($aSearchResult[$iSearchIndex][$aImageRoad[$iSearchIndex]][2]) - ($aSearchResult[$i][$j][2] + $aSearchResult[$i][$j][4])
;~ 				$iDown =  $aSearchResult[$i][$j][2]  - ($aSearchResult[$iSearchIndex][$aImageRoad[$iSearchIndex]][2] + $aSearchResult[$iSearchIndex][$aImageRoad[$iSearchIndex]][4])

;~ 				$bWidthCompare = ($iLeft < $iAddBoder and $iLeft > 0 - $iAddBoder) or ($iRight < $iAddBoder and $iRight > 0 - $iAddBoder)
;~ 				$bHeightCompare = ($iUp < $iAddBoder and $iUp > 0 - $iAddBoder)  or ($iDown < $iAddBoder and $iDown > 0 - $iAddBoder)

;~ 				; 왼쪽, 위 기준
;~ 				$iLeft = ($aSearchResult[$iSearchIndex][$aImageRoad[$iSearchIndex]][1]) - ($aSearchResult[$i][$j][1])
;~ 				$iRight = $aSearchResult[$i][$j][1] - ($aSearchResult[$iSearchIndex][$aImageRoad[$iSearchIndex]][1])
;~ 				$iUp = ($aSearchResult[$iSearchIndex][$aImageRoad[$iSearchIndex]][2]) - ($aSearchResult[$i][$j][2] )
;~ 				$iDown =  $aSearchResult[$i][$j][2]  - ($aSearchResult[$iSearchIndex][$aImageRoad[$iSearchIndex]][2])

;~ 				$bWidthCompare = $bWidthCompare  or  ($iLeft < $iAddBoder and $iLeft > 0 - $iAddBoder) or ($iRight < $iAddBoder and $iRight > 0 - $iAddBoder)
;~ 				$bHeightCompare =$bHeightCompare or ($iUp < $iAddBoder and $iUp > 0 - $iAddBoder)  or ($iDown < $iAddBoder and $iDown > 0 - $iAddBoder)


				if $bWidthCompare or  $bHeightCompare  then

					$bFound = True

					$aImageRoad [$i] = $j

					;debug("add : " & $aSearchResult[$i][$j][5] )

					;debug($aImageRoad)
					;debug($iLeft, $iRight,$iUp,  $iDown)

					selectMultiImageRec($aSearchResult, $aImageRoad,  $iAddBoder)

					exitloop

				endif
			next

			$bFound = checkMultiImageAllFound($aImageRoad)

			if $bFound then exitloop
			$aImageRoad[$i] = ""

		next

		$bFound = checkMultiImageAllFound($aImageRoad)
		if $bFound then exitloop

	next

endfunc

func checkMultiImageAllFound(byref $aImageRoad)

	local $j
	local $bFound = True

	for $j=1 to ubound($aImageRoad) -1
		if $aImageRoad[$j] = "" then  $bFound = False
	next

	return $bFound

endfunc


func getMultiImagePos(byref $aSearchResult, $aImageRoad, byref  $x,byref  $y, $sPositionImage, byref $aRetPos)

	local $i
	local $iMaxLeft = 100000000
	local $iMaxTop =  100000000
	local $iMaxRight = -100000000
	local $iMaxBottom = -10000000
	local $aImagePos[5]

	for $i = 1 to ubound($aImageRoad) -1
		;debug($aSearchResult[$i][$aImageRoad[$i]][5], $aSearchResult[$i][$aImageRoad[$i]][1], $aSearchResult[$i][$aImageRoad[$i]][2])

		if  $aSearchResult[$i][$aImageRoad[$i]][5] = $sPositionImage then
			;msg($sPositionImage)
			if $aSearchResult[$i][$aImageRoad[$i]][1] < $iMaxLeft then $iMaxLeft = $aSearchResult[$i][$aImageRoad[$i]][1]
			if $aSearchResult[$i][$aImageRoad[$i]][2] < $iMaxTop then $iMaxTop = $aSearchResult[$i][$aImageRoad[$i]][2]

			if $aSearchResult[$i][$aImageRoad[$i]][1] + $aSearchResult[$i][$aImageRoad[$i]][3] > $iMaxRight then $iMaxRight = $aSearchResult[$i][$aImageRoad[$i]][1] + $aSearchResult[$i][$aImageRoad[$i]][3]
			if $aSearchResult[$i][$aImageRoad[$i]][2] + $aSearchResult[$i][$aImageRoad[$i]][4]  > $iMaxBottom then $iMaxBottom = $aSearchResult[$i][$aImageRoad[$i]][2] + $aSearchResult[$i][$aImageRoad[$i]][4]
		endif

	next

	$x = int($iMaxLeft + (($iMaxRight - $iMaxLeft) /2))
	$y = int($iMaxTop + (($iMaxBottom - $iMaxTop) /2))
	;debug("Left : " & $iMaxLeft)
	;debug("Top : " & $iMaxTop)
	;debug("Right : " & $iMaxRight)
	;debug("Bottom : " & $iMaxBottom)


	$aImagePos[1] = $iMaxLeft
	$aImagePos[2] = $iMaxTop
	$aImagePos[3] = $iMaxRight
	$aImagePos[4] = $iMaxBottom

	$aRetPos = $aImagePos
endfunc


Func SearchIEObjectTarget($hBrowser, $sTarget,byref $x, byref $y, byref $aRetPos, byref $oTag, $bLoopSearch, $iTimeOut)

	local $sTempBrowser
	local $oMyError
	local $bIESearch
	local $bResult = False
	local $aIEObjectInfo
	local $aRetIEPos [6]

	local $tTimeInitAll

	local $iOldStyleWidth
	local $iOldStyleStyle
	local $iOldStyleColor


	$oTag = ""
	$tTimeInitAll = _TimerInit()

	do


		seterror(0)
		$oMyError = ObjEvent("AutoIt.Error","UIAIE_NullError")
		$sTempBrowser = _IEAttach2($hBrowser,"HWND")

		if _IEPropertyGet ($sTempBrowser, "hwnd") <> $hBrowser then
			_StringAddNewLine ( $_runErrorMsg , "IE 브라우저에서만 Object방식으로 사용이 가능합니다. : "  & $sTarget)
			return False
		endif

		setStatusText (getTargetSearchRemainTimeStatusText($tTimeInitAll, $iTimeOut, $sTarget))
		$bIESearch = IEObjectSearch($sTempBrowser, getIEObjectCondtion($sTarget),True, $aIEObjectInfo)

		$oMyError = ObjEvent("AutoIt.Error")

		if $bIESearch then

			$bResult = True
			$x = $aIEObjectInfo[2]
			$y = $aIEObjectInfo[3]

			; imageSeatch에서 return 되는 결과 그대로 활용하기 위해 배열 위치를 맞춤
			$aRetIEPos[2] = $aIEObjectInfo[4]
			$aRetIEPos[3] = $aIEObjectInfo[5]
			$aRetIEPos[4] = $aIEObjectInfo[6] - $aIEObjectInfo[4]
			$aRetIEPos[5] = $aIEObjectInfo[7] - $aIEObjectInfo[5]

			$aRetPos = $aRetIEPos
			$oTag = $aIEObjectInfo[1]

			; 부분실행인경우 깜빡임 모드를 추가 할 것
			if $_runRetryRun = True and $_runHighlightDelay > 0  then

				$iOldStyleWidth = $aIEObjectInfo[1].style.borderWidth
				$iOldStyleStyle = $aIEObjectInfo[1].style.borderStyle
				$iOldStyleColor = $aIEObjectInfo[1].style.borderColor

				if $iOldStyleWidth = "0" then $iOldStyleWidth = ""
				if $iOldStyleStyle = "0" then $iOldStyleStyle = ""
				if $iOldStyleColor = "0" then $iOldStyleColor = ""

				$aIEObjectInfo[1].style.borderWidth = "2"
				$aIEObjectInfo[1].style.borderStyle = "solid"
				$aIEObjectInfo[1].style.borderColor  = "red"

				sleep($_runHighlightDelay)

				$aIEObjectInfo[1].style.borderWidth = $iOldStyleWidth
				$aIEObjectInfo[1].style.borderStyle = $iOldStyleStyle
				$aIEObjectInfo[1].style.borderColor  = $iOldStyleColor

			endif
		else
			$aRetIEPos[0] = $aIEObjectInfo[0]
			$aRetPos = $aRetIEPos

		endif

		sleep (500)

	until ($bResult = True) or ((_TimerDiff($tTimeInitAll) > $iTimeOut or $bLoopSearch = False)) or (checkScriptStopping())

	return $bResult

endfunc


Func SearchTargetVerify($hWindow, $sFile, byref $x, byref $y, $bLoopSearch, $iTimeOut, $bAllSearch, Byref $aRetPos, $bFullSearch, $bVerify)

	; 모바일 경우 재검증을 시도함 (특정시간 이후 검색시 동일한 결과가 나오면 pass)

	local $bResult = False
	local $iLastX, $iLastY, $i
	local $aLastWorkArea
	local $bNewSearch = False
	local $iNewTimeOut


	$bResult = SearchTarget($hWindow, $sFile,  $x,  $y, $bLoopSearch, $iTimeOut, $bAllSearch,  $aRetPos, $bFullSearch)

	if $bVerify = False or $bResult = False or IsArray($x) then return $bResult

	$aLastWorkArea = $_runAreaWork

	for $i=1 to 5

		$_runAreaWork[0] = True
		$_runAreaWork[1] = $aRetPos[2]
		$_runAreaWork[2] = $aRetPos[3]
		$_runAreaWork[3] = $aRetPos[2] + $aRetPos[4]
		$_runAreaWork[4] = $aRetPos[3] + $aRetPos[5]

		$iLastX = $x
		$iLastY = $y

		$iNewTimeOut = 500

		if $bNewSearch then
			$_runAreaWork[0] = False
			$bNewSearch = False
			$iNewTimeOut = $iTimeOut
		endif

		; ini 지정된 시간만큼 대기하고 이미지 재검증
		sleep($_runVerifyTime)

		;debug ("재확인 " & $i)
		;debug($_runAreaWork)
		if $i > 1 then writeDebugTimeLog("이미지 재확인 Count  : "  & $i)

		$bResult  = SearchTarget($hWindow, $sFile,  $x,  $y, $bLoopSearch, $iNewTimeOut, $bAllSearch,  $aRetPos, $bFullSearch)

		if ($bResult = True and $iLastX = $x and $iLastY = $y) or IsArray($x) then exitloop

		$bNewSearch = True

	next




	$_runAreaWork = $aLastWorkArea

	return $bResult

endfunc


Func SearchTarget($hWindow, $sFile, byref $x, byref $y, $bLoopSearch, $iTimeOut, $bAllSearch, Byref $aRetPos, $bFullSearch)
; 이미지 찾기

	local $bResult = False
	local $tTimeInitAll
	local $tTimeInitUnit
	local $aWinPos, $aWinPosOrg
	local $aMousePos
	local $sImageFiles[1]
	local $bImageFound = False
	local $iRemainTime
	local $iRetryCount
	local $sTempPos
	local $aImageRangeXY
	local $aSearchPos [4]
	local $aSearchNewPos [4]
	local $iSearchCount = 0
	local $iMouseMoveCount = 0
	local $iMouseMoveSleepTimer
	local $iTolerance
	local $iLoopCount
	local $iBaseTolerance
	local $bCRCCheck
	local $aImageTolerance[1]
	local $aFullScreenPos
	local $iTransparentColor

	if IsHWnd($hWindow) = 0  then
		$_runErrorMsg = "대상 웹 브라우저 창이 존재 하지 않습니다.  Window Handle : " & $hWindow
		return
	endif

	if IsArray($sFile) = False then
		redim $sImageFiles[2]
		$sImageFiles[1]  = $sFile
	Else
		$sImageFiles = $sFile
	endif

	;msg($sImageFiles)
	for $i=1 to ubound($sImageFiles) -1
		if FileExists($sImageFiles[$i]) = 0 then
			return False
		endif
		;debug("이미지 찾기 : " & $sImageFiles[$i])
	next


	$iBaseTolerance = 30

	;$iBaseTolerance = $iBaseTolerance  + int(($_runTolerance - $iBaseTolerance) / 2)
	;debug($_runTolerance, $iBaseTolerance )

	if $iBaseTolerance  >  $_runTolerance then  $iBaseTolerance = $_runTolerance

	$iTolerance = $iBaseTolerance

	$tTimeInitAll = _TimerInit()
	$aWinPos = WinGetPos($hWindow)
	$aWinPosOrg = $aWinPos
	$aMousePos = MouseGetPos()
	$iRetryCount = 0

	; 전체대상작업으로 설정된 경우 검색 위치를 화면 전체로 함.
	if $_runFullScreenWork then

		$aFullScreenPos = GetAareFromPoint($aWinPos[0] + ($aWinPos[2]/2) ,$aWinPos[1]  + ($aWinPos[3]/2))

		$aWinPos[0] = $aFullScreenPos[1]
		$aWinPos[1] = $aFullScreenPos[2]
		$aWinPos[2] = $aFullScreenPos[3]
		$aWinPos[3] = $aFullScreenPos[4]

		;debug("전체 스크린크기 진행")
		;debug($aWinPos)

	endif

	if $_runAreaWork[0] = True then

		; 현재 윈도우 크기에 상대좌표를 추가함
		if $_runAreaWork[5] = True then
			$aWinPos[0] = $aWinPos[0] + $_runAreaWork[1]
			$aWinPos[1] = $aWinPos[1] + $_runAreaWork[2]
			$aWinPos[2] = $_runAreaWork[3] - $_runAreaWork[1]
			$aWinPos[3] = $_runAreaWork[4] - $_runAreaWork[2]
		else
			$aWinPos[0] = $_runAreaWork[1]
			$aWinPos[1] = $_runAreaWork[2]

			; 윈도우 보다 큰 경우 위도우 크기만으로 지정
			if $aWinPos[0] < $aWinPosOrg[0] then $aWinPos[0] = $aWinPosOrg[0]
			if $aWinPos[1] < $aWinPosOrg[1] then $aWinPos[1] = $aWinPosOrg[1]

			$aWinPos[2] = $_runAreaWork[3] - $aWinPos[0]
			$aWinPos[3] = $_runAreaWork[4] - $aWinPos[1]

			if $aWinPos[2] > $aWinPosOrg[2] then $aWinPos[2] = $aWinPosOrg[2]
			if $aWinPos[3] > $aWinPosOrg[3] then $aWinPos[3] = $aWinPosOrg[3]


			;debug($aWinPosOrg)
			;debug($_runAreaWork)
			;debug($aWinPos)


		endif

	endif

	$iMouseMoveSleepTimer = _TimerInit()

	writeDebugTimeLog("이미지 찾기 시작 : 윈도우 위치 " & $aWinPos[0] & ", " & $aWinPos[1])

	redim $aImageTolerance[ubound($sImageFiles)]

	do
		$iLoopCount += 1
		;debug (TimerDiff($tTimeInit) , $iTimeOut)
		$tTimeInitUnit = _TimerInit()

		for $i=1 to ubound($sImageFiles) -1

			writeDebugTimeLog("이미지 파일정보 " & $i & ", " & $sImageFiles[$i])

			$iRemainTime = int(($iTimeOut - _TimerDiff($tTimeInitAll )) / 1000)
			if $iRemainTime < 0 then $iRemainTime = 0

			;if (int($iTimeOut / 1000) - $iRemainTime) > 5 then  $iTolerance = $_runTolerance

			if $iLoopCount > 1 then

				; 5초 이내에 최대 Tolerance으로 테스트 진행
				$iTolerance = $iBaseTolerance +  int ((_TimerDiff($tTimeInitAll) / 1000) * ($_runTolerance- $iBaseTolerance))

				;debug("$iTolerance = " &  $iTolerance)
			endif

			if $iTolerance > $_runTolerance or $bFullSearch = True then $iTolerance =  $_runTolerance

			if $iTolerance > $aImageTolerance[$i] then $aImageTolerance[$i] = $iTolerance
			;if $iTolerance > $_runTolerance then $iTolerance =  $_runTolerance


			;setStatusText ("이미지 검색중 : " & $sImageFiles[$i] & ", " & $iRemainTime & "초 남음" & @crlf)
			getTargetSearchRemainTimeStatusText($tTimeInitAll, $iTimeOut, $sImageFiles[$i])

			if checkScriptStopping() then Return False

			$aImageRangeXY = getImageRangeXY($sImageFiles[$i])

			$aSearchPos [0] = $aWinPos[0]
			$aSearchPos [1] = $aWinPos[1]
			$aSearchPos [2] = $aWinPos[0] + $aWinPos[2]
			$aSearchPos [3] = $aWinPos[1] + $aWinPos[3]

			;debug ($aSearchPos)


			if IsArray($aImageRangeXY) and $iRemainTime > 5 and $bLoopSearch = True and ($bAllSearch = False) then
				getImageRangeOver($aImageRangeXY, $aSearchNewPos, $aSearchPos, $iSearchCount , $iSearchCount)
				$aSearchPos = $aSearchNewPos
			endif

			; 최대 크기인경우
			if $aSearchPos[2] = $aWinPos[0] + $aWinPos[2] and $aSearchPos [3] = $aWinPos[1] + $aWinPos[3] then
				; MAX 인 경우
				if $iTolerance = $_runTolerance and $bFullSearch = False  and $bCRCCheck = False  and $aImageTolerance[$i] <  $_runTolerance + 20  then
					$aImageTolerance[$i] = $aImageTolerance[$i] + 2
				endif
			endif

			$iTolerance = $aImageTolerance[$i]

			;debug($aSearchPos)
			writeDebugTimeLog("이미지 찾기 시작 진짜 : "  &  " x1=" & $aSearchPos[0]  &  " y1=" & $aSearchPos[1]  &  " x2=" & $aSearchPos[2] &  " y2=" & $aSearchPos[3]  & ", SearchCount : " & $iSearchCount )

			;if WinActive($hWindow) = 0 Then WinActivate($hWindow)
			$iTransparentColor = getTransparentImageAndColor ($sImageFiles[$i])
			if _ImageSearchArea2($sImageFiles[$i],1,$aSearchPos[0],$aSearchPos[1],$aSearchPos[2],$aSearchPos[3], $x, $y, $iTolerance, $aRetPos, $bAllSearch, $bCRCCheck, $iTransparentColor) = 1 then $bImageFound = True
			writeDebugTimeLog("이미지 찾기 시작 진짜 종료 ")
			;debug("찾은 범위 : ")
			;debug( $aSearchPos)

			if checkScriptStopping() then exitloop
			if $bImageFound  = True then
				writeDebugTimeLog("이미지 찾음: " &   " x=" & $x  &  " y=" & $y &  " count=" & ubound($x) &  " tolerance=" &  $iTolerance &   " x배열=" & ubound($x) )
				writeDebugTimeLog("이미지 찾음 (진짜): " &   " x=" & $x - $aWinPos[0] &  " y=" & $y - $aWinPos[1]  )
				$bResult =  $bImageFound
				exitloop
			endif
		next

		if $iSearchCount < 1.5 then
			$iSearchCount += 0.3
		elseif $iSearchCount < 4 then
			$iSearchCount += 1
		elseif $iSearchCount < 7 then
			$iSearchCount += 2
		endif

		; 1초가 넘어가면 범위를 MAX로 검사하도록 함
		if _TimerDiff($tTimeInitAll) > 3000 then
			$iSearchCount  = 10
		endif

		if checkScriptStopping() or $bResult = True then exitloop

		do
			RunSleep (50)
		until $bResult or (_TimerDiff($tTimeInitUnit) > 50) or $bLoopSearch = False

		if $_runMouseMoveSleep and _TimerDiff($iMouseMoveSleepTimer) > 1000  then
			$iMouseMoveSleepTimer = _TimerInit()
			$iMouseMoveCount += 1
			;debug("마우스 이동")
			MouseMove($aMousePos[0],$aMousePos[1] + mod($iMouseMoveCount, 2))
		endif

	until ($bResult = True) or ((_TimerDiff($tTimeInitAll) > $iTimeOut or $bLoopSearch = False))
	;until $bResult  or (TimerDiff($tTimeInitAll) > $iTimeOut) or $bLoopSearch = False

	writeDebugTimeLog("이미지 디버그 "  & $bResult  & " " & _TimerDiff($tTimeInitAll) & " " &  $iTimeOut & " " &  $bLoopSearch)

	if _TimerDiff($tTimeInitAll) > 3000 then writeDebugTimeLog("주의! 3초이상 지연")


	if $bResult  = False and  $bLoopSearch = True and (_TimerDiff($tTimeInitAll) < $iTimeOut) then
		;msg ("이미지 디버그 "  & $bResult  & " " & _TimerDiff($tTimeInitAll) & " " &  $iTimeOut & " " &  $bLoopSearch)
	endif


	return $bResult

endfunc


Func checkScriptStopping()

	checkStopRequest()

	if $_bScriptStopping = true  then
		;debug("사용자 실행 중단 요청")
		$_runErrorMsg = "사용자 실행 중단"
		Return True
	else
		Return False
	endif

endfunc


Func ScrollMoveAndCheck($bisPgTop, $isCheckEnable = True)
; 스크롤 진행, 최상위 혹은 단위로 아래로 진행, $isCheckEnable = 스크롤 한 뒤 이전화면과 동일한지 여부를 비교

	local $bScrollNotEnd
	local $aWinPos
	local $sScrollBarBefore = @ScriptDir & "\temp_scrollbefore.png"
	local $sScrollBarAfter = @ScriptDir & "\temp_scrollafter.png"

	local $iBarLeft
	local $iBarTop
	local $iBarWidth
	local $iBarHeight
	local $aFoundPos
	local $iTolerance
	local $iloopcnt

	local $x
	local $y

	$aWinPos = WinGetPos($_hBrowser)

	$iBarLeft = $aWinPos[0] + $aWinPos[2] - 23
	$iBarTop = $aWinPos[1] + 75
	$iBarWidth = $aWinPos[0] + $aWinPos[2] - 12
	$iBarHeight = $aWinPos[1] + $aWinPos[3] - 10

	if $isCheckEnable then
		if FileExists($sScrollBarBefore) then FileDelete($sScrollBarBefore)
		_ScreenCapture_Capture($sScrollBarBefore,$iBarLeft,$iBarTop,$iBarWidth,$iBarHeight)
		sleep(100)
		if FileExists($sScrollBarBefore) = 0 then
			$_runErrorMsg = "스크롤을 통해 전체화면 이미지 찾기 작업 실패"
			return False
		endif
	endif

	ScrollPage($bisPgTop)

	if $isCheckEnable then
		if _ImageSearchArea($sScrollBarBefore,1,$iBarLeft - 1,$iBarTop -1 ,$iBarWidth + 2,$iBarHeight + 2, $x, $y, $iTolerance, $aFoundPos) = 1 then
			$bScrollNotEnd = False
		else
			;debug("못찾아~ : " & $iTolerance)
			$iloopcnt += 1
			if $iloopcnt > 5 then $iTolerance += 10
			;_ScreenCapture_Capture($sScrollBarAfter,$iBarLeft,$iBarTop,$iBarWidth,$iBarHeight)
			$bScrollNotEnd = True
		endif
	Else
		$bScrollNotEnd = True
	endif

	return $bScrollNotEnd

endfunc



func setMouseClickLeftDown()
	; 제목 표시줄을 클릭

	local $aWinPos

	hBrowswerActive ()

	$aWinPos = WinGetPos($_hBrowser)

	; 윈도우가 max 이면 border를 뺄것

	if IsArray($aWinPos) then

	WinGetPosWithoutBorder($aWinPos)
	;debug($aWinPos[1], $aWinPos[3])
	;debug(WinGetClientSize("[active]"))

	; 마우스를 상단으로 이동
		MouseClick("left",$aWinPos[0] + 2,$aWinPos[1] + $aWinPos[3] -2 ,1,1)
	endif

endfunc


func setMouseClickLeftTop()
	; 제목 표시줄을 클릭

	local $aWinPos

	hBrowswerActive ()

	$aWinPos = WinGetPos($_hBrowser)


	if IsArray($aWinPos) then

	; 마우스를 상단으로 이동
		WinGetPosWithoutBorder($aWinPos)
		MouseClick("left",$aWinPos[0] + 30,$aWinPos[1] + 10,1,1)
	endif

endfunc

func setMouseClickLeftMiddle()

	local $aWinPos

	hBrowswerActive ()

	$aWinPos = WinGetPos($_hBrowser)

	if IsArray($aWinPos) then

		; 마우스를 상단으로 이동
		WinGetPosWithoutBorder($aWinPos)
		MouseClick("left",$aWinPos[0] + 2,$aWinPos[1] + ($aWinPos[3]/2),1,1)
	endif

endfunc

Func ScrollPage($bisPgTop = False)
; 페이지 스크롤,  최초, 혹은 한단계씩 아래로 내림

	local $aWinPos

	hBrowswerActive ()

	$aWinPos = WinGetPos($_hBrowser)

	; 마우스를 상단으로 이동
	MouseClick("left",$aWinPos[0] + 10,$aWinPos[1] + ($aWinPos[3]/2),1,1)
	;sleep(100)
	;moveMouseTop()

	if $bisPgTop then

		send("{PGUP}")
		send("{PGUP}")
		send("{PGUP}")
		send("{PGUP}")
		send("{PGUP}")
		send("{PGUP}")
		send("{PGUP}")
		send("{PGUP}")
		send("{PGUP}")
		send("{PGUP}")
		send("{PGUP}")
		send("{PGUP}")
		send("{PGUP}")
		send("{PGUP}")
		send("{PGUP}")
		send("{PGUP}")
		send("{PGUP}")
		send("{PGUP}")

		;RunSleep(200)

	Else
		send("{PGDN}")
		;RunSleep(200)
	endif

endfunc


Func moveMouseTop($sMouseDelay = $_runMouseDelay)
; 명령 실행후 화면 캡쳐에 마우스가 표시되거나 잘못된 화면이 표시되시 않도록 최상단 위로 이동
	local $aWinPos[3]

	$aWinPos = WinGetPos($_hBrowser)

	if IsArray($aWinPos) = 0 then
		; 현재 작업창의 좌표를 얻지 못할경우 0,0으로 이동
		redim $aWinPos[3]
		$aWinPos[0] =0
		$aWinPos[1] =0
	endif

	sleep(1)
	MouseMove($aWinPos[0] + 30 ,$aWinPos[1]+ 10,$sMouseDelay)
	sleep(1)

	;debug($aWinPos)

endfunc


func writeRunLog($sMessage, $sLineNumber = "", $bNewLine = True )

	$sMessage = getLogLineNumber($sLineNumber) & " > " & getReportDetailTime()  & " "  & $sMessage

	WriteLoglist ($sMessage & @crlf)

	ControlFocus($_gEditScript, "", "")

	FileWrite($_runLogFileHanle,$sMessage & @crlf)

endfunc


func setStatusText($sMessage, $bCRLF = True )
	$sMessage = stringreplace($sMessage,@cr,"")
	$sMessage = stringreplace($sMessage,@lf,"")

	;_GUICtrlStatusBar_SetText ($_gStatusBar, $sMessage, 2)
	setStatusBarText($_iSBStatusText, $sMessage)
	sleep(1)
	_ViewRuntimeToolTip()
	writeDebugTimeLog("Status Message : " & $sMessage)
endfunc


func writeReportLog($sMessage)
	;debug($sMessage)
	FileWrite($_runReportLogHanle, $sMessage & @crlf)
endfunc


func writeDebugTimeLog($sMsg, $oTimer = $_iDebugTimeInit)
	writeDebugLog(StringFormat("[%4d] ",_TimerDiff($oTimer)) & $sMsg)
endfunc



func getLogLineNumber($iNumber)

	$iNumber = number($iNumber)

	if $iNumber = 0 Then
		return "     "
	else
		return StringFormat("%5d", $iNumber)
	endif

endfunc

func getLogRunningTime($iSec)

	local $sRet

	;debug($iSec)
	$iSec = round($iSec / 1000 ,1)
	;debug($iSec & " -")

	if $iSec = 0 Then
		$iSec = "0.1"
	endif

	;debug($iSec & " --")

	if stringinstr($iSec,".") = 0 then $iSec &= ".0"

	$sRet = "(" & $iSec & "s)"
	$sRet =  stringleft($sRet ,8)

	return $sRet

endfunc


func getReportDetailTime()

	return _DateTimeFormat($_runCommadLintTimeStart,5) & " " & getLogRunningTime(_TimerDiff($_runCommadLintTimeInit))


endfunc

func makeReportLogFormat($aCommand, $aCommandPos, $aTarget, $aTargetPos,  $sScriptName, $sID, $sNo, $sTestDateTime,  $sResult, $sScript, $sErrorMsg, $sComment)

	; $sScriptName , $sID , $sNo, $sDate , $sResult & ,$sNewScript , $sErrorMsg , $sComment

	local $sKey = Chr(1)
	local $sNewScript
	local $sNewErrorMsg
	local $sNewCommnet
	local $i
	local $iAddTextSize =0
	local $a
	local $addText


	if IsArray($aCommand) then
		$sNewScript = changeString($sScript, $aCommand, $aCommandPos, "#" & hex($_iColorCommandHtml,6) ,  $aTarget, $aTargetPos, "#" & hex ($_iColorTargetHtml,6) )
	Else
		$sNewScript = $sScript
	endif
	;debug($sScript)
	;debug($sNewScript)

	;debug($aCommand)
	;debug($aCommandPos)
	;debug($aTarget)
	;debug($aTargetPos)


	$sNewErrorMsg = $sErrorMsg
	$sNewCommnet = $sComment


	$sNewCommnet = StringReplace($sNewCommnet,$_sHTMLPreCahr & "<", $_sHTMLPreCahr & "GT;")
	$sNewCommnet = StringReplace($sNewCommnet,$_sHTMLPreCahr & ">", $_sHTMLPreCahr & "LT;")


	$sNewErrorMsg = StringReplace($sNewErrorMsg,$_sHTMLPreCahr & "<", $_sHTMLPreCahr & "GT;")
	$sNewErrorMsg = StringReplace($sNewErrorMsg,$_sHTMLPreCahr & ">", $_sHTMLPreCahr & "LT;")


	$sNewCommnet = StringReplace($sNewCommnet,"<", "&lt;")
	$sNewCommnet = StringReplace($sNewCommnet,">", "&gt;")

	$sNewErrorMsg = StringReplace($sNewErrorMsg,"<", "&lt;")
	$sNewErrorMsg = StringReplace($sNewErrorMsg,">", "&gt;")

	$sNewCommnet = StringReplace($sNewCommnet,$_sHTMLPreCahr & "GT;",  "<")
	$sNewCommnet = StringReplace($sNewCommnet,$_sHTMLPreCahr & "LT;", ">")

	$sNewErrorMsg = StringReplace($sNewErrorMsg,$_sHTMLPreCahr & "GT;",  "<")
	$sNewErrorMsg = StringReplace($sNewErrorMsg,$_sHTMLPreCahr & "LT;", ">")



	$sNewErrorMsg = StringReplace($sNewErrorMsg,@crlf, "<BR>")
	$sNewCommnet = StringReplace($sNewCommnet,@crlf, "<BR>")

	; 엔코코드 찌꺼기 정보가 남아 있을 경우 null 처리하도록 함
	$sNewErrorMsg = StringReplace($sNewErrorMsg,@cr, "")
	$sNewErrorMsg = StringReplace($sNewErrorMsg,@lf, "")

	$sNewCommnet = StringReplace($sNewCommnet,@cr, "")
	$sNewCommnet = StringReplace($sNewCommnet,@lf, "")

	;debug("Error1:" & $sErrorMsg)
	;debug("Error2:" & $sNewErrorMsg)
	;debug("Comment1:" & $sComment)
	;debug("Comment2:" & $sNewCommnet)

	writeReportLog($sScriptName & $sKey & $sID & $sKey &  $sNo & $sKey &  $sTestDateTime & $sKey &  $sResult & $sKey &  $sNewScript & $sKey &  $sNewErrorMsg & $sKey &  $sNewCommnet)

endfunc


func setupLogFile($sScriptName, $sReportLog )

	$_runLogFileHanle = FileOpen($sScriptName, 2)
	$_runReportLogHanle = FileOpen($sReportLog, 2)

endfunc

func setupDebugLogFile($sDebugLog)

	if $_runDebugLog then
		$_runDebugLogFileHanle = FileOpen($sDebugLog, 2)
	endif

endfunc


func closeLogFile()
; 로그 파일 닫기
	FileClose($_runLogFileHanle)
	FileClose($_runReportLogHanle)
	if $_runDebugLog then FileClose($_runDebugLogFileHanle)
endfunc


func getFormatImageName($aImageList, $bIncludeFileName)
; link 로 보여줄 이미지문자열에는 <>로 둘러싸서 리턴, 옵션으로 이름이 지정된 경우 뒤에 추가

	local $sList
	local $newImageList [2]
	local $i

	if IsArray($aImageList) = 0 then
		$newImageList[1] = $aImageList
	Else
		$newImageList = $aImageList
	endif

	for $i=1 to UBOUND($newImageList)-1
		if $sList <> "" then $sList = $sList & @crlf
		$sList = $sList  & $_sHTMLPreCahr & "<" & $newImageList[$i] & $_sHTMLPreCahr & ">" & _iif($bIncludeFileName, " " &  $newImageList[$i], "")
	next

	return $sList

endfunc


func setImageSearchError($sScriptTarget, $aImageFile)
; 이미지 찾기 관련 에러 로그 문구를 만들어서 리턴
	local $sErrorMsg
	;debug($sBrowserCapture)
	$_runErrorImageTarget = $sScriptTarget
	;_ArrayAdd($_aPreErrorImageTarget, $sScriptTarget)

	$sErrorMsg = "이미지 찾기 오류 : " & $sScriptTarget


	if $_runRetryRun = False then
		$sErrorMsg = $sErrorMsg & @crlf
		copyErrorImage($sErrorMsg, $aImageFile)
		captureCurrentBorwser($sErrorMsg, False)
	endif

	return $sErrorMsg

endfunc


func copyErrorImage(byref $sErrorMsg, $aImageFile)

	local $sBrowserCapture
	local $i

	if $_runRunningImageCapture = False then return

	;$sErrorMsg = $sErrorMsg & @crlf & "찾는 이미지 : "

	for $i=1 to ubound($aImageFile) -1
		$_runScreenCaptureCount += 1
		$sBrowserCapture = $_runWorkReportPath & $_runScreenCapturePreName & $_runScreenCaptureCount & $_cImageExt
		filecopy ($aImageFile[$i],   $sBrowserCapture)
		_StringAddNewLine ($sErrorMsg ,getFormatImageName($sBrowserCapture, False ) & @crlf & $aImageFile[$i] & @crlf)
	next

endfunc

func captureCurrentBorwser(byref $sErrorMsg, $bDeskTop, $hCurBrowser = $_hBrowser, $aCaptureArea = "", $sCaptureFileName = "")

	local $sBrowserCapture
	local $sCapList
	local $sAVIFile
	local $sCapturePath
	local $bRet = False

	if $_runRunningImageCapture = False then return

	if $aCaptureArea = "" Then
		$sCapturePath = $_runWorkReportPath
	Else
		$sCapturePath = $_runUserCapturePath
	endif

	if $sCaptureFileName = "" then
		$_runScreenCaptureCount += 1
		$sBrowserCapture = $sCapturePath & $_runScreenCapturePreName & StringFormat("%0003d",Number ($_runScreenCaptureCount)) & $_cImageExt
	Else
		$sBrowserCapture = $_runUserCapturePath & "\" &  $sCaptureFileName
	endif

	writeDebugTimeLog("창 캡쳐 시작")

	;msg($sBrowserCapture)

	if FileExists(_GetPathName($sBrowserCapture)) = 0 then DirCreate(_GetPathName($sBrowserCapture))

	if FileExists($sBrowserCapture) then FileDelete($sBrowserCapture)

	writeDebugTimeLog("창 캡쳐 준비 완료")

	saveBrowserScreen($sBrowserCapture, $bDeskTop, $hCurBrowser, $aCaptureArea)

	writeDebugTimeLog("창 캡쳐 종료")

	if FileExists($sBrowserCapture) then  $bRet = True

	_StringAddNewLine ( $sErrorMsg , $_sLogText_BrowserCapture)
	_StringAddNewLine ( $sErrorMsg ,getFormatImageName($sBrowserCapture, False) )

;~ 	if $_runAVICapOn then

;~ 		$sAVIFile = stringreplace($sBrowserCapture,$_cImageExt , ".avi")
;~ 		$sCapList = _avi_getcapturelist()
;~ 		; 30초 추가해서 캡쳐 요청
;~ 		$sCapList = _avi_getLastAVIList ($sCapList, _avi_getCaptureTime(30 +  _DateDiff( 's',$_runLastCommandStartTime,_NowCalc())))
;~ 		;debug("AVI 캡쳐 요청 : " & $sAVIFile )
;~ 		_avi_setSavelist($sAVIFile , $sCapList)

;~ 		_StringAddNewLine ( $sErrorMsg ,$_sLogText_BrowserAVI)
;~ 		_StringAddNewLine ( $sErrorMsg ,getFormatImageName($sAVIFile, False) )

;~ 	endif

	return $bRet

endfunc


Func saveBrowserScreen($sFileName, $bDeskTop, $hCurBrowser, $aCaptureArea = "" )
;	현재 표시되는 브라우저를 파일로 저장함
	;debug("캡쳐파일명:" & $sFileName)

	local $iCaptureStartX = 0
	local $iCaptureStartY = 0
	local $iCaptureWidth = -1
	local $iCaptureHeight = -1
	local $oMyError
	local $i

	if IsArray($aCaptureArea) Then

		$iCaptureStartX = $aCaptureArea[1]
		$iCaptureStartY = $aCaptureArea[2]
		$iCaptureWidth = $aCaptureArea[3]
		$iCaptureHeight = $aCaptureArea[4]

	endif

	writeDebugTimeLog("캡쳐 윈도우 크기 확인 완료 : " & $sFileName)

	if FileExists($sFileName) then FileDelete($sFileName)

	writeDebugTimeLog("캡쳐 이전 파일 삭제")

	writeDebugTimeLog("잠김 모드 확인 : " & _isWorksatationLocked())


	;ScrollPage(True)

	if $_runWebdriver then
	; webdriver 모드인 경우
		writeDebugTimeLog("웹드라이버 캡쳐")
		_WD_get_screenshot_as_file ($sFileName)

	elseif $bDeskTop then

		writeDebugTimeLog("전체 윈도우 캡쳐")
		_ScreenCapture_Capture ($sFileName)

	else
		;msg($iCaptureStartX & " " &  $iCaptureStarty & " " &   $iCaptureWidth & " " &  $iCaptureHeight)

		writeDebugTimeLog("부분 윈도우 캡쳐 : " & $sFileName & "," &  $hCurBrowser  & "," & $iCaptureStartX  & "," & $iCaptureStarty & "," &  $iCaptureWidth & "," &  $iCaptureHeight)

		_ScreenCapture_CaptureWnd($sFileName,$hCurBrowser,$iCaptureStartX,$iCaptureStarty, $iCaptureWidth, $iCaptureHeight,True)

	endif

	writeDebugTimeLog("saveBrowserScreen 캡쳐 작업 완료")

EndFunc


func getProcessIDandHandle(byref $sBrowserType, byref $hBrowser)
; 블럭 실행으로 실행시 자동으로 브라우저를 선택하지 못할 경우 사용자가 브라우저를 선택하도록 함 (5초)

	local $bCancel
	local $hWinHandle
	local $sProcessName
	local $i
	local $aBrowserInfo[6 + ubound($_aBrowserOTHER) -1]
	local $iTimeInit
	local $dll = DllOpen("user32.dll")


	$aBrowserInfo[1] = $_sBrowserIE
	$aBrowserInfo[2] = $_sBrowserFF
	$aBrowserInfo[3] = $_sBrowserSA
	$aBrowserInfo[4] = $_sBrowserCR
	$aBrowserInfo[5] = $_sBrowserOP

	for $i=1 to ubound($_aBrowserOTHER) -1
		$aBrowserInfo[5 + $i] = $_aBrowserOTHER[$i][1]
	next


	;msg($aBrowserInfo)

	do

		$iTimeInit = _TimerInit()

		TrayTip($_sProgramName, "테스트 할 브라우저를 선택 후 CTRL키를 누르세요" & @crlf &  "CTRL키를 누르지 않을 경우 5초 뒤에 자동 진행됩니다.",5,1)

		;debug(_TimerDiff($iTimeInit))
		;debug(checkScriptStopping())

		$_bScriptRunning = True
		$_bScriptStopping = False

		do
			;debug(_TimerDiff($iTimeInit))
			sleep(200)

		until _TimerDiff($iTimeInit) > 5000 or checkScriptStopping() or _IsPressed("11", $dll)  = 1


		if checkScriptStopping() then
			TrayTip($_sProgramName, "테스트를 취소 하였습니다.",5,1)
			$_bScriptRunning = False
			$sBrowserType = ""
			exitloop
		endif

		$hWinHandle = WinGetHandle("[ACTIVE]")
		$sProcessName = _ProcessGetName(WinGetProcess($hWinHandle, ""))

		for $i = 1 to ubound($aBrowserInfo) -1
			if $sProcessName = getBrowserExe($aBrowserInfo[$i]) then
				;msg("찾음 " & $sProcessName & " , " & $aBrowserInfo[$i] & " " & getBrowserExe($aBrowserInfo[$i]))
				$sBrowserType = $aBrowserInfo[$i]
				$hBrowser = $hWinHandle
			endif
		next
		if $sBrowserType = "" then $bCancel = _ProgramQuestion("활성화된 브라우저를 찾지 못하였습니다. 재시도하시겠습니까?")

	until $sBrowserType <> "" or $bCancel = False


endfunc


Func searchBrowserWindow($sBrowserType, $sScriptTarget, byref $sWinTitleList, $bScreenCapture, byref $iRetHandle)
;선택,  브라우저 exe 를 기준으로 모든 윈도우에서 차례대로 이미지가 있는지 확인하고, 있을 경우 True

	local $aBrowserWindows
	local $x,$y, $j, $i, $k
	local $bResult
	local $aRetPos
	local $sErrorMsg
	local $bLogHeaderWrite = False

	local $iTabCount = 0
	local $sWinGetText
	local $oTag
	local $sLastErrorMsg
	local $hLastBrowser
	local $bObjectSearch
	local $aImageFile
	local $bFileNotFoundError

	;debug($sBrowserType)
	;debug($aBrowserWindows)

	$bObjectSearch = getIEObjectType($sScriptTarget)

	for $j=1 to 2

		writeDebugTimeLog("창 목록 가져오기 시작")
		$aBrowserWindows = getBrowserWindowAll(getBrowserExe($sBrowserType), $sWinTitleList)
		;debug("$j=" & $j)
		;debug($sWinTitleList)
		writeDebugTimeLog("창 목록 가져오기 완료 : " & ubound($aBrowserWindows) -1)

		for $i=1 to ubound($aBrowserWindows) -1

			runsleep(1)
			if checkScriptStopping()  then return False

			do

				; 재확인
				for $k= 2 to 2

					$iRetHandle = WinGetHandle($aBrowserWindows[$i])

					if $iRetHandle <> "" then
						writeDebugTimeLog("창 제목 : " & WinGetTitle($aBrowserWindows[$i]))

						; 크롬이 아니면서 핸들이 동일한 경우 검색 대상에서 제외
						;debug($_hBrowser , $iRetHandle, $sBrowserType, $_sBrowserCR)
						;if $_hBrowser = $iRetHandle and ($sBrowserType <> $_sBrowserCR ) then ContinueLoop

						;debug($i  & $aBrowserWindows[$i] & WinGetTitle($aBrowserWindows[$i]))

						;if $k = 2 then WinMinimizeAll ()


						;WinSetOnTop($aBrowserWindows[$i],"",1)

						if WinActive($aBrowserWindows[$i]) = 0 then WinActivate($aBrowserWindows[$i])

						writeDebugTimeLog("attach WinActive 완료")

						if WinActive($aBrowserWindows[$i]) <> 0  then


							;WinSetOnTop($aBrowserWindows[$i],"",1)

							; 느린 PC에서 오래 화면 전화하고 전체 이미지를 제대로 보여주는데 오래 걸리는 경우가 있음
							sleep(100)
							;debug($bScreenCapture , $j, $bLogHeaderWrite)
							if $bScreenCapture and $j = 2 then

								if $bLogHeaderWrite = False then

									$bLogHeaderWrite = True
									;_StringAddNewLine($_runErrorMsg,"지정된 윈도우를 찾을 수 없습니다." & _NowCalc())
									;_StringAddNewLine($_runErrorMsg,"")
									_StringAddNewLine($_runErrorMsg,"브라우저 화면 목록")

									; 이미지를 캡쳐함 (찾고자 하는 창의 이미지)

									;if $bObjectSearch = False then copyErrorImage($sErrorMsg, $sScriptTarget)
									copyErrorImage($sErrorMsg, $sScriptTarget)
									_StringAddNewLine($_runErrorMsg,$sErrorMsg)

									;debug ("한꺼번에 저장왔어")
								endif

								writeDebugTimeLog("창 attach 에러 확인 화면 캡쳐")
								_StringAddNewLine($_runErrorMsg,"윈도우 : " & WinGetTitle($aBrowserWindows[$i]))
								writeDebugTimeLog("창 attach 에러 확인 화면 캡쳐2")
								captureCurrentBorwser($_runErrorMsg, False, $aBrowserWindows[$i])
								writeDebugTimeLog("창 attach 에러 확인 화면 캡쳐3")
								_StringAddNewLine($_runErrorMsg,"")

								;WinSetOnTop($aBrowserWindows[$i],"",0)

							endif

							writeDebugTimeLog("attach 이미지 찾기 요청")
							sleep(100)

							if $bObjectSearch then
								;debug(WinGetTitle($aBrowserWindows[$i]))
								$sLastErrorMsg = $_runErrorMsg
								$bResult = SearchIEObjectTarget($aBrowserWindows[$i], $sScriptTarget, $x, $y, $aRetPos, $oTag, False , $_runWaitTimeOut)
								$_runErrorMsg = $sLastErrorMsg
							else
								;$bResult = SearchTarget($aBrowserWindows[$i], $sScriptTarget,$x,$y, False, $_runWaitTimeOut, False  ,$aRetPos, False )
								$hLastBrowser =  $_hBrowser
								$_hBrowser = $aBrowserWindows[$i]
								;debug($i, $_hBrowser)
								;debug($sScriptTarget)
								$sLastErrorMsg = $_runErrorMsg
								;debug("$sLastErrorMsg : " & $sLastErrorMsg)

								$bResult = getRunCommnadImageAndSearchTarget ($sScriptTarget, $aImageFile,  $x , $y, False , $_runWaitTimeOut, $bFileNotFoundError)
								;debug("$_runErrorMsg : " & $_runErrorMsg)
								; 모든 에러는 무시하도록 함

								; 파일찾기 실패인 경우 해당 오류를 우선으로 표시
								if $bFileNotFoundError = False then $_runErrorMsg = $sLastErrorMsg

								$_hBrowser = $hLastBrowser

							endif

							writeDebugTimeLog("attach top off")
							;WinSetOnTop($aBrowserWindows[$i],"",0)

							;debug ($bResult)

							writeDebugTimeLog("attach 이미지 찾기 완료")

							;두번째 재확인시 찾으면 찾은것으로 할 것

							if $bResult = False then exitloop

							if $bResult = True then
								if $k = 2 then
									writeDebugTimeLog("attach 이미지 찾음! : " & WinGetTitle($aBrowserWindows[$i]) )
									return $bResult
								else
									sleep (500)
									writeDebugTimeLog("attach 이미지 찾음 재검증 : " & WinGetTitle($aBrowserWindows[$i]) )
									$bResult = False
								endif
							endif

						endif

						WinSetOnTop($aBrowserWindows[$i],"",0)
					else
						writeDebugTimeLog("중간에 윈도우 핸들이 없어짐 : " & $aBrowserWindows[$i] )
					endif



				next


				;debug("error : " & $_runErrorMsg)

				if $sBrowserType = $_sBrowserCR then
					;if  StringInStr(WinGetText(""),"DummyWindowForActivation") then
						writeDebugTimeLog("크롬 TAB 클릭")
						send("^{TAB}")
					;endif
				endif

				if checkScriptStopping() then Return False

				writeDebugTimeLog("Tab count : " & $iTabCount)

			;until $iTabCount > 2 or $sBrowserType <> $_sBrowserCR
			until 1
		next

		RunSleep(10)
	next

	return False

EndFunc


func getBrowserWindowAll($sBrowserType, byref $sWinTitleList)
; 브라우저 exe 파일 기준으로 현재 모든 윈도우 핸들을 얻어롬

	local $handle
	local $aBrowserWindows[1]
	local $var, $i
	local $hCurrentWin = $_hBrowser
	local $sTempHandle

	writeDebugTimeLog("창 winlist 시작")
	$var = WinList()
	writeDebugTimeLog("창 winlist 완료")


	$sWinTitleList = ""


	if IsArray($var) then

		For $i = 1 to $var[0][0]

		  If $var[$i][0] <> "" AND BitAnd( WinGetState($var[$i][1]), 2)  Then

				if $sBrowserType = _ProcessGetName( WinGetProcess($var[$i][1])) then
					if $sWinTitleList  <> "" then $sWinTitleList  = $sWinTitleList  & ", "
					$sWinTitleList = $sWinTitleList & WinGetTitle($var[$i][1])
					_ArrayAdd($aBrowserWindows, $var[$i][1])
					;debug("Details", "Title=" & $var[$i][0] & @LF & _ProcessGetName( WinGetProcess($var[$i][1])))
				endif
			EndIf
		Next
	endif

	; 작업중인 윈도우는 맨 마지막에 위치하도록 할것
	For $i = 1 to ubound($aBrowserWindows) -2
		if $hCurrentWin = $aBrowserWindows[$i] then
			$aBrowserWindows[$i] = $aBrowserWindows[ubound($aBrowserWindows)-1]
			$aBrowserWindows[ubound($aBrowserWindows)-1] = $hCurrentWin
			exitloop
		endif
	next

	;debug($hCurrentWin)
	;debug($aBrowserWindows)


	writeDebugTimeLog("창 getBrowserWindowAll 완료")

	return $aBrowserWindows

EndFunc



Func _setCurrentBrowserInfo()
; 핸들 변경시 자동으로 레지스트리에 저장함

	_writeSettingReg ("LastBrowserType", $_runBrowser)
	_writeSettingReg ("LastBrowserName", $_hBrowser)

	;msg($_webdriver_current_sessionid)
	;msg($_webdriver_connection_host)

	_writeSettingReg ("LastWebdriverSessionid", $_webdriver_current_sessionid)
	_writeSettingReg ("LastWebdriverHost", $_webdriver_connection_host)

	if $_runBrowser <> "" then $_runLastBrowser = $_runBrowser
	;debug($_runBrowser, $_hBrowser)

EndFunc



Func _getLastBrowserInfo()
; 레지스트리에서 최신 사용된 브라우저 핸들을 얻어옴

	local $browserType
	local $hbrowser

	$browserType =  _readSettingReg("LastBrowserType")
	$hbrowser = _readSettingReg("LastBrowserName")

	$_webdriver_current_sessionid =  _readSettingReg("LastWebdriverSessionid")
	$_webdriver_connection_host = _readSettingReg("LastWebdriverHost")
	;msg($_webdriver_current_sessionid)
	;msg($_webdriver_connection_host)

	$hbrowser = Ptr ($hbrowser)
	;debug($browserType, $hbrowser)

	if WinExists( $hbrowser) Then
		$_runBrowser = $browserType
		$_hBrowser =  $hbrowser
	endif

EndFunc


Func writePassFail($bResult)
; 테스트 결과기록
	return _iif($bResult," -> P", " -> F")
endfunc


func getRunVar($sScriptTarget, byref $sNewValue)
; 실행 변수를 값을 찾아서 리턴

	local $i

	$sNewValue = ""

	switch $sScriptTarget

		case "$GUITAR_현재날짜와시간", "$GUITAR_CurrentDateTime"
			;$sNewValue = StringFormat("%04d년 %02d월 %02d일 %02d시 %02d분 %02d초", @YEAR, @MON ,@MDAY ,@HOUR , @MIN, @SEC, @MSEC)
			$sNewValue = StringFormat("%04d_%02d_%02d_%02d_%02d_%02d", @YEAR, @MON ,@MDAY ,@HOUR , @MIN, @SEC, @MSEC)
			return true

		case "$GUITAR_임의값", "$GUITAR_Random"
			$sNewValue =  StringFormat("%010d",Random(1,9999999999,1))
			return true

		case "$GUITAR_현재브라우저", "$GUITAR_CurrentBrowser"
			$sNewValue =  $_runBrowser
			return true

		caSE "$GUITAR_최근X좌표", "$GUITAR_RecentXPos"
			$sNewValue =  $_aLastUseMousePos[1]
			return true

		CASE "$GUITAR_최근Y좌표", "$GUITAR_RecentYPos"
			$sNewValue =  $_aLastUseMousePos[2]
			return true

		caSE "$GUITAR_최근전체좌표", "$GUITAR_RecentXYPos"
			$sNewValue =  $_aLastUseMousePos[3]
			return true

		CASE "$GUITAR_리포트경로", "$GUITAR_RrportPath"
			$sNewValue =  $_runWorkReportPath
			return true

		CASE "$GUITAR_XML경로", "$GUITAR_XMLPath"
			$sNewValue =  $_runXMLPath
			return true

		CASE "$GUITAR_스크립트경로", "$GUITAR_ScriptPath"
			$sNewValue =  StringTrimRight(_GetPathName($_runScriptFileName),1)
			return true

		CASE "$GUITAR_작업경로", "$GUITAR_WorkPath"
			$sNewValue =  $_runWorkPath
			return true

		CASE "$GUITAR_최근접속소요시간", "$GUITAR_RecentLoadingTime"
			$sNewValue =  $_aLastNavigateTime
			return true

		CASE "$GUITAR_X좌표보정", "$GUITAR_AdjustXPos"
			$sNewValue =  $_runCorrectionX
			return true

		CASE "$GUITAR_Y좌표보정", "$GUITAR_AdjustYPos"
			$sNewValue =  $_runCorrectionY
			return true

		CASE "$GUITAR_브라우저창크기", "$GUITAR_BrowserSize"
			$sNewValue =  $_runBrowserWidth & "," & $_runBrowserHeight
			return true

		CASE "$GUITAR_브라우저URL", "$GUITAR_BrowserURL"

			if $_runWebdriver = False then
				$sNewValue =  getCurrentURL()
			Else
				$sNewValue = _WD_get_url()
			endif
			return true

		CASE "$GUITAR_모바일OS", "$GUITAR_MobileOS"
			$sNewValue =  $_runMobileOS
			return true

		CASE "$GUITAR_입력방식", "$GUITAR_InputType"
			$sNewValue =  $_runInputType
			return true

		CASE "$GUITAR_입력방식", "$GUITAR_Webdriver"
			$sNewValue =  _Boolean($_runWebdriver)
			return true


		CASE "$GUITAR_CMDLINE1"
			$sNewValue =  $_runCmdLine[1]
			return true

		CASE "$GUITAR_CMDLINE2"
			$sNewValue =  $_runCmdLine[2]
			return true

		CASE "$GUITAR_CMDLINE3"
			$sNewValue =  $_runCmdLine[3]
			return true

		CASE "$GUITAR_CMDLINE4"
			$sNewValue =  $_runCmdLine[4]
			return true

		CASE "$GUITAR_CMDLINE5"
			$sNewValue =  $_runCmdLine[5]
			return true

		CASE "$GUITAR_CMDLINE6"
			$sNewValue =  $_runCmdLine[6]
			return true

		CASE "$GUITAR_CMDLINE7"
			$sNewValue =  $_runCmdLine[7]
			return true

		CASE "$GUITAR_CMDLINE8"
			$sNewValue =  $_runCmdLine[8]
			return true

		CASE "$GUITAR_CMDLINE9"
			$sNewValue =  $_runCmdLine[9]
			return true

		case Else

			checkTableValue($sScriptTarget)

			for $i= 1 to ubound($_aRunVar) -1

				if $_aRunVar[$i][$_iVarName] = $sScriptTarget then

					;debug($_aRunVar[$i][$_iVarName], $sScriptTarget)

					; 만약 테이블변수이면 최신 값으로 설정
					$sNewValue = $_aRunVar[$i][$_iVarValue]

					return true

				endif
			next

	EndSwitch

	return False

endfunc


func checkTableValue($sScriptTarget)

	local $iVarIndex = 0
	local $aFileReadArray
	local $iNewCount
	local $sVarFile
	local $bisTableVar = False

	$sVarFile = _GetPathName($_runScriptFileName) & $sScriptTarget & ".txt"

	; 테이블 변수 인 경우
	;debug("파일존재 확인 :" & FileExists($sVarFile), $sVarFile )
	if FileExists($sVarFile) = 1  then

		addNewTableValue($sScriptTarget, $iVarIndex, $sVarFile)

		$_aRunVar[$iVarIndex][$_iVarFile] = $sVarFile

		; 파일을 열어서 n 번째 값을 읽어옴
		_FileReadToArray($_aRunVar[$iVarIndex][$_iVarFile], $aFileReadArray)

		;debug($aFileReadArray)

		if ubound($aFileReadArray) -1 <= $_aRunVar[$iVarIndex][$_iVarCount] then
			$iNewCount = 1
		Else
			$iNewCount = $_aRunVar[$iVarIndex][$_iVarCount] + 1
		endif

		;debug($iNewCount)
		;debug($aFileReadArray[$iNewCount])

		$_aRunVar[$iVarIndex][$_iVarValue] = $aFileReadArray[$iNewCount]

		$_aRunVar[$iVarIndex][$_iVarCount] = $iNewCount

	endif

endfunc


func addNewTableValue($sScriptTarget, byref $iVarIndex, $sVarFile)

	; 기존 변수 값을 가져와서 없으면 신규로 추가

	$iVarIndex = getValueTableIndex($sScriptTarget)

	if $iVarIndex = 0 then
		; 신규 추가
		addSetVar ($sScriptTarget & "=null" , $_aRunVar)

		$iVarIndex = getValueTableIndex($sScriptTarget)

		$_aRunVar[$iVarIndex][$_iVarName] = $sScriptTarget
		$_aRunVar[$iVarIndex][$_iVarValue] = ""
		$_aRunVar[$iVarIndex][$_iVarCount] = 0
		$_aRunVar[$iVarIndex][$_iVarFile] = $sVarFile

	endif

endfunc

func RestTableValueIndex($sScriptTarget, $iResetIndex)


	local $iVarIndex = 0

	; 기존 변수 정보에 이미 추가되어 있는 경우
	addNewTableValue($sScriptTarget, $iVarIndex, "")

	$_aRunVar[$iVarIndex][$_iVarCount] = $iResetIndex - 1


endfunc


func getValueTableIndex($sScriptTarget)

	local $iVarIndex = 0
	local $i

		for $i=1 to ubound($_aRunVar) -1
			if $_aRunVar[$i][$_iVarName] = $sScriptTarget then
				$iVarIndex = $i
				exitloop
			endif
		next

	return  $iVarIndex

EndFunc

func checkTableValue2($sScriptTarget, $iResetIndex = "")

	local $i
	local $iVarIndex = 0
	local $aFileReadArray
	local $iNewCount
	local $sVarFile
	local $bisTableVar = False
	local $bRet = False

	; 기존 변수 정보에 이미 추가되어 있는 경우
	for $i=1 to ubound($_aRunVar) -1
		if $_aRunVar[$i][$_iVarName] = $sScriptTarget then
			$iVarIndex = $i
			exitloop
		endif
	next

	$sVarFile = _GetPathName($_runScriptFileName) & $sScriptTarget & ".txt"

	; 테이블 변수 인 경우
	;debug("파일존재 확인 :" & FileExists($sVarFile), $sVarFile )
	if FileExists($sVarFile) = 1  then

		if $iVarIndex = 0 then
			; 신규 추가
			addSetVar ($sScriptTarget & "=null" , $_aRunVar)

			for $i=1 to ubound($_aRunVar) -1
				if $_aRunVar[$i][$_iVarName] = $sScriptTarget then
					$iVarIndex = $i
					exitloop
				endif
			next

			$_aRunVar[$iVarIndex][$_iVarName] = $sScriptTarget
			$_aRunVar[$iVarIndex][$_iVarValue] = ""
			$_aRunVar[$iVarIndex][$_iVarCount] = 0
			$_aRunVar[$iVarIndex][$_iVarFile] = $sVarFile

		endif

		; 파일을 열어서 n 번째 값을 읽어옴
		_FileReadToArray($_aRunVar[$iVarIndex][$_iVarFile], $aFileReadArray)

		if ubound($aFileReadArray) -1 <= $_aRunVar[$i][$_iVarCount] then
			$iNewCount = 1
		Else
			$iNewCount = $_aRunVar[$i][$_iVarCount] + 1
		endif

		$_aRunVar[$i][$_iVarValue] = $aFileReadArray[$iNewCount]

		if $iResetIndex <> "" then
			$_aRunVar[$i][$_iVarCount] = $iResetIndex - 1
		else
			$_aRunVar[$i][$_iVarCount] = $iNewCount
		endif

		$bRet = True

	endif

	return $bRet

endfunc


; 변수쓰기
func addSetVar ($sVarString, byref $aVar, $bExtractCheck = False)
; $bExtractCheck = 정확하게 첫글자에 변수명 $가 있는 경우에만 찾음
; 테스트 변수 정보 값을 저장

	local $i
	local $sNewName
	local $iMaxVar
	local $sNewValue
	local $iNewIndex
	local $bVarAddInfo

	local $bResult
	local $aBrowserSize

	$iMaxVar = ubound($aVar)

	;debug("진행전:" & $sVarString)
	if getVarNameValue($sVarString,  $sNewName, $sNewValue, ",", $bExtractCheck) = False then Return False
	;debug("진행후:" & $sVarString)

	$iNewIndex = 0
	for $i= 1 to $iMaxVar -1
		if $aVar[$i][1] = $sNewName then
			$iNewIndex = $i
			exitloop
		endif
	next

	if $sNewName = "$GUITAR_X좌표보정" or $sNewName = "$GUITAR_AdjustXPos" then $_runCorrectionX = Number($sNewValue)
	if $sNewName = "$GUITAR_Y좌표보정" or $sNewName = "$GUITAR_AdjustYPos" then $_runCorrectionY = Number($sNewValue)
	if $sNewName = "$GUITAR_모바일OS" or $sNewName = "$GUITAR_MobileOS" then $_runMobileOS = $sNewValue
	if $sNewName = "$GUITAR_Webdriver" then $_runWebdriver = _Boolean($sNewValue)
	if $sNewName = "$GUITAR_입력방식" or $sNewName = "" then $_runInputType = $sNewValue
	if $sNewName = "$GUITAR_브라우저창크기" or $sNewName = "$GUITAR_BrowserSize" then
		$aBrowserSize = StringSplit($sNewValue, ",")
		$_runBrowserWidth = number($aBrowserSize[1])
		$_runBrowserHeight = number($aBrowserSize[2])

		if $_runBrowserWidth = 0 or $_runBrowserHeight = 0 then
			$bResult = False
			_StringAddNewLine( $_runErrorMsg, '"$GUITAR_브라우저창크기 = 800,600" 형태로 지정되어야 합니다. ')
			return $bResult
		endif
	endif


	if $iNewIndex = 0 then
		redim $aVar[$iMaxVar+1][$_iVarFile + 1]
		$iNewIndex = $iMaxVar
	endif

	$aVar[$iNewIndex][1] = $sNewName
	;$aVar[$iNewIndex][2] = $sNewValue
	;debug("addSetVar ConvertVarFull start")
	ConvertVarFull ($sNewValue, $aVar[$iNewIndex][2], $bVarAddInfo,",", $bExtractCheck)
	;debug("addSetVar ConvertVarFull end")
	;msg($aVar)

	return True

endfunc

func ConvertVarFull ($sNewValue, byref $sNewValueAll, byref $bVarAddInfo, $sConvertType=",", $bExtractCheck = False)

	local $i, $k
	local $aTempSplitTop
	local $aTempSplit
	local $sItemValue
	local $bVarType

	$sNewValueAll = ""
	$bVarAddInfo = ""
	$aTempSplitTop = StringSplit($sNewValue,$sConvertType)

	for $k=1 to ubound($aTempSplitTop) -1

		if $k > 1 then $sNewValueAll = $sNewValueAll & $sConvertType

		$aTempSplit = StringSplit($aTempSplitTop[$k],"|")

		for $i=1 to ubound($aTempSplit) -1
			; 변수일 경우 값을 찾아와서 입력
			;debug("Convert 변수명:" & $aTempSplit[$i]  )

			$sItemValue = $aTempSplit [$i]

			$bVarType = getVarType(_Trim($aTempSplit [$i]), $bExtractCheck)

			;debug("Convert 변수명:" & $sItemValue , $bExtractCheck, $bVarType )

			if $bVarType then

				if getRunVar(_Trim($aTempSplit [$i]), $sItemValue) = False then
					_StringAddNewLine( $_runErrorMsg, "변수 정보 설정이 잘못 되었거나 값이 설정되지 않았습니다. : " &  _Trim($aTempSplit [$i]))
					;msg($aTempSplit)
					return False
				endif

				if $bVarAddInfo <> "" then $bVarAddInfo = $bVarAddInfo & ". "
				$bVarAddInfo = $bVarAddInfo & $aTempSplit[$i] & "=" & $sItemValue

				;debug("변수명:" & $aTempSplit[$i] & ", value =" & $sItemValue & ", $bVarAddInfo=" & $bVarAddInfo )

				; 6/28 문자열 치환시 뒷 공백도 같이 복원하도록 함
				;$sNewValueAll = $sNewValueAll & $sItemValue
				$sNewValueAll = $sNewValueAll &  $sItemValue & StringReplace($aTempSplit [$i], _Trim($aTempSplit [$i]), "")
				;debug($aTempSplit [$i], "!!!")
			else
				$sNewValueAll = $sNewValueAll & $sItemValue
				;debug($aTempSplit [$i], "####")
			endif


		next
	next

	if $bVarAddInfo <> "" then   $bVarAddInfo = "변수정보 : " & $bVarAddInfo

	;_StringAddNewLine( $bVarAddInfo, "")

	return True

endfunc

;ConsoleWrite(TCaptureXCaptureActiveWindow(WinGetHandle("네이버")))

Func TCaptureXCaptureActiveWindow($hWIn)

	local $aWinPos
	local $oTCaptureX
	local $results
	local $resultAA
	local $resultActiveWindow

	if WinActive($hWIn) = 0 then  WinActivate($hWIn)
    $aWinPos = WinGetPos($hWIn)
    $oTCaptureX = ObjCreate("TCaptureX.TextCaptureX")
	if $oTCaptureX <> 0 then

;~ 		if $_runBrowser = $_sBrowserSA then
;~ 			$results = $oTCaptureX.GetFullTextAA(Dec(StringTrimLeft($hWIn, 2)))
;~ 		Else
;~ 			$results = $oTCaptureX.CaptureActiveWindow()
;~ 		endif


 			$resultAA = $oTCaptureX.GetFullTextAA(Dec(StringTrimLeft($hWIn, 2)))

 			$resultActiveWindow = $oTCaptureX.CaptureActiveWindow()

			$results = $resultAA & $resultActiveWindow


		;$results = $oTCaptureX.GetTextFromRect(Dec(StringTrimLeft($hWIn, 2)), $aWinPos[0]  , $aWinPos[1] , $aWinPos[2], $aWinPos[3])
	Else
		$_runErrorMsg = "TCaptureX.TextCaptureX 가 설치되지 않았습니다."
		$results = False
	endif

	;debug ($results)
    return $results
EndFunc



;getImageRangeOver($aOldPos,$aNewPos, $aMaxPos, 2 , 100)
;msg($aNewPos)
func getImageRangeOver($aOldPos, byref $aNewPos, $aMaxPos, $iXPer, $iYPer)

	local $iBaseX = 100
	local $iBaseY = 100

	$aNewPos[0] = $aMaxPos [0] +  $aOldPos[0] - $iBaseX * $iXPer
	if $aNewPos[0] < $aMaxPos [0] then $aNewPos[0] = $aMaxPos [0]

	$aNewPos[1] = $aMaxPos [1] +  $aOldPos[1] - $iBaseY * $iYPer
	if $aNewPos[1] < $aMaxPos [1] then $aNewPos[1] = $aMaxPos [1]

	$aNewPos[2] = $aMaxPos [0] + $aOldPos[0] + $aOldPos[2] + $iBaseX * $iXPer
	if $aNewPos[2] > $aMaxPos [2] then $aNewPos[2] = $aMaxPos [2]

	$aNewPos[3] = $aMaxPos [1] + $aOldPos[1] + $aOldPos[3] + $iBaseY * $iYPer
	if $aNewPos[3] > $aMaxPos [3] then $aNewPos[3] = $aMaxPos [3]


;~ 	$aNewPos[0] = $aMaxPos [0] +  $aOldPos[0] - ($aOldPos[2]) * ($iXPer -1)
;~ 	if $aNewPos[0] < $aMaxPos [0] then $aNewPos[0] = $aMaxPos [0]

;~ 	$aNewPos[1] = $aMaxPos [1] +  $aOldPos[1] - ($aOldPos[3]) * ($iYPer -1)
;~ 	if $aNewPos[1] < $aMaxPos [1] then $aNewPos[1] = $aMaxPos [1]

;~ 	$aNewPos[2] = $aMaxPos [0] + $aOldPos[0] + $aOldPos[2] + ($aOldPos[2]) * ($iXPer -1)
;~ 	if $aNewPos[2] > $aMaxPos [2] then $aNewPos[2] = $aMaxPos [2]

;~ 	$aNewPos[3] = $aMaxPos [1] + $aOldPos[1] + $aOldPos[3] + ($aOldPos[3]) * ($iYPer -1)
;~ 	if $aNewPos[3] > $aMaxPos [3] then $aNewPos[3] = $aMaxPos [3]



endfunc

;debug(getImageRangeXY("맛집_WIN2K_IE7_[071.258.010.020].png"))

func getImageRangeXY($sFileName)

	local $sPos
	local $i
	local $aNewPos = ""

	$sPos = _getmidstring($sFileName,"[","]",1)

	if $sPos <> "" then

		$aNewPos = StringSplit($sPos,".",2)

		for $i = 0 to ubound($aNewPos) -1
			$aNewPos [$i] = int ($aNewPos[$i])
		next

	endif

	return $aNewPos

endfunc


func _setBrowserWindowsSize($hWin, $bMoveOnly = False)

	local $aWinPos
	local $iWidth
	local $iHeight
	local $aCurWindowPos

	;debug("윈도우")

	$iWidth = $_runBrowserWidth
	$iHeight = $_runBrowserHeight


	if $_runWebdriver = False then


		if WinActive($hWin) = 0 then  WinActivate($hWin)

		;WinSetState($hWin,"", @SW_MAXIMIZE )

		sleep (100)

		$aWinPos = WinGetPos($hWin)

		;msg($aWinPos )


		if IsArray($aWinPos) then

			;debug("Width = " & $iWidth & ", Height = " & $iHeight)


			$aCurWindowPos = GetAareFromPoint($aWinPos[0] + ($aWinPos[2]/2) ,$aWinPos[1]  + ($aWinPos[3]/2))


			;if IsArray($aCurWindowPos) = 0  then writeRunLog("GetAareFromPoint 결과가 없음")

			;msg($aCurWindowPos)

			if $bMoveOnly then

				_MoveWindowtoWorkArea($hWin)

			else

				if $iHeight > $aCurWindowPos[4] or $iWidth > $aCurWindowPos[3] then
					WinSetState($hWin,"", @SW_MAXIMIZE )
				Else

					if BitAnd(WinGetState ( $hWin) , 32) then WinSetState($hWin,"", @SW_SHOWNORMAL)

					sleep (100)

					$aWinPos = WinGetPos($hWin)

					if IsArray($aWinPos) then
						$aCurWindowPos = GetAareFromPoint($aWinPos[0] + ($aWinPos[2]/2) ,$aWinPos[1]  + ($aWinPos[3]/2))


						if $iWidth > 0 then
							WinMove($hWin,"",$aWinPos[0], $aWinPos[1],$iWidth, $aWinPos[3])

						endif

						$aWinPos = WinGetPos($hWin)

						if $iHeight > 0 then
							WinMove($hWin,"",$aWinPos[0], $aWinPos[1],$aWinPos[2], $iHeight)

						endif

						sleep(200)

						_MoveWindowtoWorkArea($hWin)
					endif

				endif
			endif
		endif

		sleep(100)
	else
	;WEBdriver 모드에서 해상도 변경
		_WD_set_windowsize ($_webdriver_current_sessionid, $iWidth,$iHeight)
	endif

endfunc


Func TestCancelRequest()
; ESC키를 눌렀을 떄 처리

	;debug("ESC 눌림")
	;debug("ESC요청 : " & _NowCalc())

	;debug("정지요청예비 : " & _NowCalc())

	if $_bScriptRunning then
		;debug("정지요청 : " & _NowCalc())
		onClickStop ()

		;$_bScriptStopping = True
		; 스크립트 종료
	endif

Endfunc


func checkStopRequest()

	if getIniBoolean(getReadINI("environment","StopRequest")) then
		setWriteINI("environment", "StopRequest", "0")
		TestCancelRequest()
	endif

endfunc


func resetRunReportInfo()

	for $i=1 to ubound($_aRunReportInfo) - 1
		$_aRunReportInfo [$i] = 0
	next

	$_aRunReportInfo[$_sResultSkipList] = ""
	$_aRunReportInfo[$_sResultNorRunList] = ""

EndFunc



func countRunReportInfoID($sID)

	local $sTemp

	if $sID = "" then
		return 0
	Else

		StringReplace($sID,",","")
		return @extended + 1
	endif

endfunc


func UIAIE_NabigateError()

	$_runErrorMsg = "Naviagate 명령을 수행 할 수 없습니다."

endfunc

func UIAIE_NullError()
	SetError (1)
endfunc


Func SetKeyDelay($iDefault = -1)

	if $iDefault = -1 then $iDefault = getReadINI("environment","KeyDelay")

	AutoItSetOption ( "SendKeyDelay" , $iDefault)
	AutoItSetOption ( "SendKeyDownDelay" , $iDefault)

	;debug($iDefault)
	;sleep(100)


endfunc


func CloseUnknowWindow($sTitleList)

	local $sList
	local $i

	if $sTitleList <> "" then
		$sList = stringsplit ($sTitleList,"|")

		for $i=1 to ubound($sList) -1
			if WinExists("",$sList[$i]) = 1  then  WinClose("",$sList[$i])
		next
	endif

endfunc


func hBrowswerActive()

	local $iTimeInit
	local $bRet


	if $_runFullScreenWork = False then

		if WinActive($_hBrowser) = 0 then
			WinActivate($_hBrowser)
			sleep(1)
		endif

		if WinActive($_hBrowser) = 0  then
			$iTimeInit = _TimerInit()
			do
				WinActivate($_hBrowser)
				sleep(1)
			until (_TimerDiff($iTimeInit)  > 5000)  or (WinActive($_hBrowser) <> 0)
		endif

		$bRet = WinActive($_hBrowser)
	else
		$bRet = True

	endif

	return $bRet

endfunc


func checkIE9FontSmoothingSetting()

	global $_bcheckIE9Check

	if $_bcheckIE9Check = True then
		return
	else
		$_bcheckIE9Check = True
	endif

	local $sVer = FileGetVersion(@ProgramFilesDir & "\Internet Explorer\iexplore.exe")
	local $aTempSplit = StringSplit($sVer , ".")
	local $sMSg = ""

	if $aTempSplit[1] = "9" and (FileExists(@ProgramFilesDir & "\Internet Explorer\DWrite.dll") = 0)then

		$sMSg = $sMSg & "IE 9은 시스템의 ClearType 옵션의 설정이 적용되지 않아 캡쳐된 이미지가 틀려질 수 있습니다." & @cr
		$sMSg = $sMSg & "아래 devcode 게시판 글을 참조하여 패치를 적용한뒤 사용하시기 바랍니다." & @cr & @cr

		_ProgramInformation($sMSg)

	endif

endfunc



func getXYAreaPositionPercent($sXY, $iCount, byref $bError)

	local $bRet
	local $i
	local $sLog

	$bError = False

	$bRet = StringSplit($sXY,",")

	if $iCount <> ubound($bRet) -1 then
		$bError = True
		return $bRet
	endif

	for $i=1 to ubound($bRet) -1

		$bRet[$i] = _Trim($bRet[$i])

		if stringright($bRet[$i] ,1) = "%" then
			$bRet[$i] = Number(stringTrimRight($bRet[$i],1))
			if $bRet[$i] > 100 or $bRet[$i] < 0 then $bError = True
		else
			$bError = True
		endif

	next

	return $bRet

endfunc


func getXYAreaPosition($sXY,byref $sCommentMsg, byref $bError)

	local $bRet
	local $i
	local $sLog

	$bError = False

	$bRet = StringSplit($sXY,",")

	for $i=1 to ubound($bRet) -1

		$bRet[$i] = _Trim($bRet[$i])

		if $i <= 4 then
			$bRet[$i] = Execute($bRet[$i] )
			if @error <> 0  Then
				$bError = True
				;debug("연산오류:" & $bRet[$i])
			endif
			if IsNumber( $bRet[$i]) = 0  Then $bError = True
		endif

		if $i=1 then $sLog = "좌표정보 X1=" & $bRet[$i]
		if $i=2 then $sLog &= ", Y1=" & $bRet[$i]
		if $i=3 then $sLog &= ", X2=" & $bRet[$i]
		if $i=4 then $sLog &= ", Y2=" & $bRet[$i]

	next

	if $sLog <> "" then _StringAddNewLine( $sCommentMsg,$sLog)

	return $bRet

endfunc



func openNewIEBrowser()
; 부분실행시 신규 브라우저를 생성
	local $oMyError
	local $sTempBrowser
	local $sRetBrowser = ""
	local $hBrowser

	$oMyError = ObjEvent("AutoIt.Error","UIAIE_NavigateError")


	$sTempBrowser = _IECreate("about:blank",0,1,1,1)
	$hBrowser = _IEPropertyGet ($sTempBrowser, "hwnd")

	if $sTempBrowser <> 0  then $sRetBrowser = $hBrowser


	$oMyError = ObjEvent("AutoIt.Error")

	return $sRetBrowser

endfunc


Func getScriptFileIDLIneFromClipboard($sTempClip, byref $sScript, byref $sLine)

	local $sTempScript = ""
	local $sTempLine = 0
	local $i

	$sTempClip = stringreplace($sTempClip,@crlf," ")

	replaceTCFileString($sTempClip)

	$sTempClip = _Trim($sTempClip)

	$i= stringinstr($sTempClip, " ",0,-1, stringlen($sTempClip))

	if $i <> 0 then

		$sTempLine = number(stringright($sTempClip, stringlen($sTempClip) - $i))

		$sTempClip = StringLeft($sTempClip, $i)

		if $sTempLine <> 0 then
			$i= stringinstr($sTempClip, " ")

			if $i <> 0 then
				$sTempScript = StringLeft($sTempClip, $i)

				;debug("xx " & $sTempScript)
				;debug("xx " & $sTempID)

			endif
		endif
	else
		$sTempScript = $sTempClip
	endif


	$sTempLine = _Trim($sTempLine)


	$sTempScript = _Trim($sTempScript)
	$sTempLine = _Trim($sTempLine)


	if $sTempScript <> "" then

		$sScript  = $sTempScript
		$sLine = $sTempLine

	endif

endfunc


func getCurrentURL()

	local $oMyError = ObjEvent("AutoIt.Error","UIAIE_NullError")
	local $sTempBrowser = _IEAttach2($_hBrowser,"HWND")

	if _IEPropertyGet ($sTempBrowser, "hwnd") <> $_hBrowser then
		_StringAddNewLine ( $_runErrorMsg , "IE 브라우저에서만 사용 가능한 명령어입니다." )
		return ""
	endif

	return _IEPropertyGet ($sTempBrowser, "locationurl")

endfunc



func _setLastImageArrayInit()
	redim $_runLastImageArray [1]
	$_runLastImageArray[0] = ""
EndFunc



func  ieattribdebug($oList)
	for $i=0 to $oList.attributes.length -1
		if $oList.attributes($i).specified then
         ;debug($oList.attributes($i).nodeName &  " = " & $oList.attributes($i).nodeValue)
		endif
	next
EndFunc


func GUITAR_NullError ()
endfunc


func WriteGuitarWebDriverError ($sDefaultText = "Webdriver에서 오류가 발생되었습니다. ")
	_StringAddNewLine ( $_runErrorMsg , $sDefaultText & $_webdriver_last_errormsg)
endfunc



func getTargetSearchRemainTimeStatusText($tTimeInitAll, $iTimeOut, $sText)


	local $iRemainTime = int(($iTimeOut - _TimerDiff($tTimeInitAll )) / 1000)
	if $iRemainTime < 0 then $iRemainTime = 0

	return "대상 검색중 : " & $sText & ", " & $iRemainTime & "초 남음" & @crlf

EndFunc