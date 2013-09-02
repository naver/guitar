#include-once

#Include <Array.au3>

#include ".\_include_nhn\_util.au3"
#include ".\_include_nhn\_file.au3"
#include ".\_include_nhn\_http.au3"

#include "GUITARCommonTC.au3"

;main()

func mainxx()

	local $sRet, $sErrorText, $iCount
	local $sScript = FileRead("c:\test.txt")

	$sRet = TestCastInfoToArray($sScript, $sErrorText, $iCount)

	if $sErrorText <> "" then _ErrorExit($sErrorText)

	;debug($sRet)

endfunc


func addTestCaseTitle($aScript)
; 각 배열로 읽음

	;No.,대분류,중분류,소분류,기능,실행중요도,Test 조건,Step,기대결과
	local $i, $j, $iAddIndex
	local $sLine
	local $sFullText

	$_sUserINIFile = @ScriptDir & "\guitar.ini"

	if FileExists($_sUserINIFile) = 0 then _ErrorExit("GUITAR.INI file not found")


	for $i=1 to ubound($aScript) -1

		$sLine = ""

		for $j=1 to $_cMaxTestCaseField

			;debug($i,$j)
			$aScript[$i][$j] = _Trim($aScript[$i][$j])

			Switch $j

				case 1 ; NO
					if $aScript[$i][$j] <> "" then $sLine &= ";" & $_cTCReportID & " = " & $aScript[$i][$j] & @crlf

				case 2,3,4,5 ;대/중/소/기능
					if $j = 2 then $sLine &= ";# " & $_cTCReportDivision & " = "
					$sLine &= $aScript[$i][$j]
					if $j = 5 then
						$sLine &= @crlf
					else
						$sLine &= ">"
					endif

				case 6 ; 중요도
					if $aScript[$i][$j] <> "" then $sLine &= ";# " & $_cTCReportPriority & " = " & $aScript[$i][$j] & @crlf

				case 7 ; 조건
					$aScript[$i][$j] = StringReplace($aScript[$i][$j], @lf, @crlf & ";# " & $_cTCReportCondition & " = "  )
					if $aScript[$i][$j] <> "" then $sLine &= ";# " & $_cTCReportCondition & " = " & $aScript[$i][$j] & @crlf

				case 8 ; 스텝
					$aScript[$i][$j] = StringReplace($aScript[$i][$j], @lf, @crlf & ";# " & $_cTCReportStep & " = "  )
					if $aScript[$i][$j] <> "" then $sLine &= ";# " & $_cTCReportStep & " = " & $aScript[$i][$j] & @crlf

				case 9 ; 기대결과
					$aScript[$i][$j] = StringReplace($aScript[$i][$j], @lf, @crlf & ";# " & $_cTCReportExpectResult & " = " )
					if $aScript[$i][$j] <> "" then $sLine &= ";# " & $_cTCReportExpectResult & " = " & $aScript[$i][$j] & @crlf

			EndSwitch

			;if $sLine <> "" then $sFullText &= $sLine

		next

		if $sLine <> "" then $sFullText &= $sLine & @crlf & @crlf & @crlf
	next

	return $sFullText

endfunc


func TestCastInfoToArray($sScript, byref $sErrorText, byref $iCount)
; 각 배열로 읽음

	local $aScript = StringSplit($sScript, @crlf)
	local $aLine
	local $aTestCaseInfo[1][$_cMaxTestCaseField + 1]
	local $iNewAddIndex = 0
	local $i, $j, $iAddIndex
	local $sRet


	;No.,대분류,중분류,소분류,기능,실행중요도,Test 조건,Step,기대결과
	;debug($sScript)
	;debug(StringLen($sScript))

	for $i=1 to ubound($aScript) -1

		$aScript[$i] = _Trim($aScript[$i])

		;debug($aScript[$i])

		$aLine = StringSplit($aScript[$i],@tab)
		;debug(ubound($aLine)-1)

		if ubound($aLine)-1 > $_cMaxTestCaseField then
			$sErrorText =  $_cMaxTestCaseField & _getLanguageMsg("testcase_clipboardcheck") & " : " & ubound($aLine)-1
			exitloop
		endif

		; 신규 추가된 경우
		if ubound($aLine)-1  > $_cMaxTestCaseField - 3 then

			$iNewAddIndex += 1
			redim $aTestCaseInfo[$iNewAddIndex + 1][$_cMaxTestCaseField + 1]

			for $j=1 to ubound($aLine) -1
				$aTestCaseInfo[$iNewAddIndex][$j] = _Trim($aLine[$j])
			next

		else

			for $j= 1 to ubound($aLine) -1
				$aLine[$j] = _Trim($aLine[$j])
				if $aLine[$j] <> "" then
					$iAddIndex = $_cMaxTestCaseField - (ubound($aLine) -1) + $j

					if $aTestCaseInfo[$iNewAddIndex][$iAddIndex] <> "" then $aTestCaseInfo[$iNewAddIndex][$iAddIndex] &= @lf
					$aTestCaseInfo[$iNewAddIndex][$iAddIndex] &=  _Trim($aLine[$j])
				endif
			next

		endif

	next

	if ubound($aTestCaseInfo) = 1 and $sErrorText = "" then $sErrorText = _getLanguageMsg("testcase_clipboarderror1")

	if $sErrorText <> "" then $sErrorText &= @crlf & @crlf & "ID" & "," & _getLanguageMsg("testcase_division1") & "," & _getLanguageMsg("testcase_division2") & "," & _getLanguageMsg("testcase_division3") & "," & _getLanguageMsg("testcase_division4") & "," & _getLanguageMsg("testcase_priority") & "," & _getLanguageMsg("testcase_condition") & "," & "Step" & "," & _getLanguageMsg("testcase_expectresult")

	if $sErrorText = "" then $sRet = addTestCaseTitle($aTestCaseInfo)

	$iCount = ubound($aTestCaseInfo) - 1

	return $sRet

endfunc