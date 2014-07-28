#include ".\_include_nhn\_util.au3"
#include <date.au3>
#Include <Array.au3>


;global  $_sErrorSumarryFile =  "D:\_Autoit\guitar\report\errorsummary2.txt"
;global  $sScriptName = "26_샘플서비스_SUS_IE_REAL"
;local $a =_getErrorSumarry($sScriptName, "2,6")
;local $b, $c
;$c= _getErrorSumarryInfo("서버aa", $a,False,"http://", $b)
;debug($c, $b)
;deleteSuccessListFormErrorSumarry($sScriptName)

; 타입별로 메세지를 생성함
func _getErrorSumarryInfo($sServerName, $aErrorInfo,  $sDashBoardReport, byref $sEmailContents)

	local $sRet

	$sEmailContents = ""
	local $iCount = ubound($aErrorInfo) -1

	if $iCount <= 0 then return ""

	$sRet = "[GUITAR] 누적오류, " & $aErrorInfo[1][1]
	if $iCount > 1 then $sRet =  $sRet & " 외 " & $iCount-1  & "건"
	$sRet =  $sRet & " (@" & $sServerName & ")"

	$sEmailContents = ""
	$sEmailContents = $sEmailContents &  "서버 : " & $sServerName & @crlf
	$sEmailContents = $sEmailContents &  "실행 스크립트  : " & $aErrorInfo[1][1] & @crlf
	$sEmailContents = $sEmailContents & "리포트 : " & $sDashBoardReport & @crlf
	$sEmailContents = $sEmailContents & @crlf
	$sEmailContents = $sEmailContents & "총 " & $iCount & "건" & @crlf

	for $i = 1 to ubound($aErrorInfo) -1
		$sEmailContents = $sEmailContents & "누적 " & $aErrorInfo[$i][0] & "회 (" & $aErrorInfo[$i][3] & @tab & $aErrorInfo[$i][4] & @tab & $aErrorInfo[$i][5] & ")" & @crlf
	next

	return $sRet

endfunc


; 특정 횟수 이상 오류가 발생된 경우 배열로 리턴하도록 함
Func _getErrorSumarry($sCount, $sScriptName, $sTestTime)

	; 26_샘플서비스_SUS_IE_REAL1,2014/07/17 17:34:15,샘플서비스_SUS_010,샘플SUS_TC002,8

	local $aFile
	local $aNewList [1][10]
	local $aRetList
	local $i
	local $aLine
	local $iSearchIndex
	local $bFound
	local $aCount


	$aCount = StringSplit($sCount,",")
	$aRetList = $aNewList

	_FileReadToArray ($_sErrorSumarryFile, $aFile,0)
	$aFile = _ArrayUnique($aFile,1)

	for $i=0 to ubound($aFile) -1

		$aLine = StringSplit($aFile[$i],",")
		$bFound = False

		for $j= 1 to ubound($aNewList) -1
			; 실행된 스크립트 기준으로
			; 기존에 있을 경우 Count 만 추가

			if $sScriptName = $aLine[1] then
				if $aLine[1] = $aNewList[$j][1] and $aLine[3] = $aNewList[$j][3]  and $aLine[4] = $aNewList[$j][4]  and $aLine[5] = $aNewList[$j][5]  then
					$bFound = True
					$aNewList[$j][0] = $aNewList[$j][0] + 1
					if $sTestTime = $aLine[2] then $aNewList[$j][2] = $sTestTime
					exitloop
				endif
			endif
		next

		; 신규 추가
		if $bFound = False then

			$iSearchIndex = ubound($aNewList)
			redim $aNewList[$iSearchIndex + 1][ubound($aNewList,2)]

			for $j=1 to ubound($aLine) -1
				$aNewList[$iSearchIndex][0] = 1
				$aNewList[$iSearchIndex][$j] = $aLine[$j]
			next

		endif

	next


	for $i=1 to ubound($aNewList) -1

		for $j=1 to ubound($aCount) -1

			if $aNewList[$i][0] = Number($aCount [$j])  and ($sTestTime = $aNewList[$i][2])then

				$iSearchIndex = ubound($aRetList)
				redim $aRetList[$iSearchIndex + 1][ubound($aRetList,2)]

				for $j=0 to ubound($aRetList,2) -1
					$aRetList[$iSearchIndex][$j] = $aNewList[$i][$j]
				next

			endif
		next

	next


	return $aRetList

EndFunc


; 메인스크립트 명을 기준으로 해당 스크립트 로그 내용을 모두 삭제함
func deleteSuccessListFormErrorSumarry($sScriptName)

	local $aFile
	local $i

	_FileReadToArray ($_sErrorSumarryFile, $aFile,0)

	for $i=0 to ubound($aFile) -1

		if StringInStr($aFile[$i], $sScriptName & ",") = 1 then
			$aFile[$i] = ""
		endif

	next

	$aFile = _ArrayUnique($aFile,1)
	;_msg($aFile)
	_FileWriteFromArray($_sErrorSumarryFile, $aFile,1)

endfunc