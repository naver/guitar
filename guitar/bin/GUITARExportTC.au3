#AutoIt3Wrapper_Icon=GUITARExportTC.ico
#AutoIt3Wrapper_Res_Fileversion=1.0.0.2
#AutoIt3Wrapper_Res_FileVersion_AutoIncrement=p

#include-once

#Include <Array.au3>

#include ".\_include_nhn\_util.au3"
#include ".\_include_nhn\_file.au3"
#include ".\_include_nhn\_http.au3"
#include "UIACommon.au3"
#include "GUITARCommonTC.au3"
#include "GUITARLanguage.au3"

main()

func main()

	local $sURL
	local $aReportInfo
	local $sHtml
	local $sOutput = @ScriptDir & "\testcase.csv"

	;http://10.64.80.189:8080/16_테스트서비스SUS_IE_REAL/2011_08_17_14_26_08/report.htm
	;D:\_Autoit\guitar\report\16_테스트서비스SUS_IE_REAL\2011_08_17_14_26_08\report.htm

	;$sURL = "D:\_Autoit\guitar\report\커맨트테스트전체\2011_08_17_21_29_55\report.htm"
	;$sURL = "http://10.64.80.187:8080/map_vtpc4/MAP_MAPENEWAL_IE_TEST3/2011_08_17_21_16_17/report.htm"

	;D:\_Autoit\guitar\report\1234\2011_08_17_23_20_33\report.htm


	; 랭귀지 리소스 읽기

	$_sUserINIFile = @ScriptDir & "\guitar.ini"

	_loadLanguageResource(_loadLanguageFile(getReadINI("Environment","Language")))

	_loadTestCaseHeaderText()


	do
		if $sURL = "" then $sURL = InputBox("GuitarExportTC", _getLanguageMsg("testcase_importselect") & " :","",Default,600,150,Default,Default,Default)

		; Cancel 누를 경우 종료
		if @error=1 then exit
		;_debug(BinaryToString(InetRead($sURL)))
		if $sURL = "" then _Error(_getLanguageMsg("testcase_selecterror"))
	until $sURL <> ""

	if FileExists($sURL) Then
		$sHtml = FileRead($sURL)
	else
		$sHtml = BinaryToString(InetRead($sURL,1))
	endif

	if $sHtml = "" then _ErrorExit(_getLanguageMsg("testcase_importreaderror") & @crlf & @crlf & $sURL)

	TrayTip("GUITARExportTC", _getLanguageMsg("testcase_importread"),3,1)

	$aReportInfo = reportToArray($sHtml)

	$aReportInfo = uniqueReportInfo($aReportInfo)

	splitReportInfo ($aReportInfo)

	if ubound($aReportInfo) = 1 then _ErrorExit(_getLanguageMsg("testcase_importcommenterror") & @crlf & @crlf & $sURL)

	saveReportToCsv($aReportInfo, $sOutput)

	;_debug($aReportInfo )
	Msgbox(64,"GUITARExportTC",_getLanguageMsg("testcase_importdone") & @crlf & @crlf & $sOutput)

	;ShellExecute($sOutput)

endfunc


func saveReportToCsv($aReport, $sOutput)

	local $i, $j, $k, $sWriteText, $aDivision

	if FileExists($sOutput) then FileDelete($sOutput)

	FileWriteLine($sOutput, $_cTCReportFile & "," & $_cTCReportID & "," & $_cTCReportDivision1 &  "," & $_cTCReportDivision2 &  "," & $_cTCReportDivision3 &  "," & $_cTCReportDivision4 &  "," &  $_cTCReportPriority  &  "," & $_cTCReportCondition &  "," & $_cTCReportStep &  "," & $_cTCReportExpectResult &  "," & $_cTCReportAllComment)
	FileWriteLine($sOutput, "")

	for $i=1 to ubound($aReport) -1

		$sWriteText = ""

		for $j=1 to $_iExportCommentAll

			if $j=$_iExportDivision then
				$aDivision = StringSplit($aReport[$i][$j] & ">>>>", ">")

				for $k=1 to 4
					$sWriteText &= csvWarp($aDivision[$k])
					$sWriteText &= ","
				next

			else
				$aReport[$i][$j] = csvWarp($aReport[$i][$j])
				$sWriteText &= $aReport[$i][$j]
				$sWriteText &= ","
			endif

		next

		FileWriteLine($sOutput, $sWriteText)

	next

endfunc


func csvWarp($sText)

	$sText = StringReplace($sText, @crlf, @lf)
	$sText = StringReplace($sText, '"', '""')
	$sText = '"' & $sText & '"'

	return $sText

endfunc


func reportToArray($sHtml)

	local $aRet [1][$_iExportEnd]
	local $aTempHtml, $i

	local const $cTCFile = "<TD id=TCFILE>"
	local const $cTCID = "<TD id=TCID>"
	local const $cTCComment = "<TD id=TCTEXT><span ID=COMMENT>"

	local $aTempTCFile, $aTempTCID, $aTempTCComment
	local $iNewAddIndex = 0

	;_debug($sHtml)

	$aTempHtml = StringSplit($sHtml, @crlf)

	for $i=1 to ubound($aTempHtml) -1

		;_debug($aTempHtml[$i])
		if StringInStr($aTempHtml[$i], $cTCID) = 0 then ContinueLoop

		;_debug($aTempHtml[$i])

		$aTempTCFile = _trim(_getmidstring($aTempHtml[$i],$cTCFile,"</TD>",1))
		replaceTCFileString($aTempTCFile)
		$aTempTCFile = _Trim($aTempTCFile)

		$aTempTCID = _trim(_getmidstring($aTempHtml[$i],$cTCID,"</TD>",1))
		$aTempTCID = StringReplace($aTempTCID,"<BR> ", "<BR>")
		$aTempTCID = StringReplace($aTempTCID,"<BR>", @lf)

		$aTempTCComment = _getmidstring($aTempHtml[$i],$cTCComment,"</TD>",1)
		replaceTCCommentString($aTempTCComment)
		$aTempTCComment = _Trim($aTempTCComment)

		if stringleft($aTempTCComment,1) = "#" then $aTempTCComment = _trim(stringTrimleft($aTempTCComment,1))



		if $aTempTCID = "&nbsp;" then $aTempTCID = ""

		if $aTempTCID <> "" then

			;_debug($aTempHtml[$i])
			$iNewAddIndex += 1

			redim $aRet[$iNewAddIndex+1] [$_iExportEnd]

			$aRet[$iNewAddIndex][$_iExportFile] = $aTempTCFile
			$aRet[$iNewAddIndex][$_iExportID] = $aTempTCID
			$aRet[$iNewAddIndex][$_iExportIndex] = $aRet[$iNewAddIndex][$_iExportFile] & " \ " & $aRet[$iNewAddIndex][$_iExportID]
			$aRet[$iNewAddIndex][$_iExportCommentAll] = $aTempTCComment

		endif

	next

	return $aRet

endfunc


func splitReportInfo(byref $aReportInfo)

	local $aComment, $i, $j, $sNewComment

	for $i=1 to ubound($aReportInfo)-1

		$aComment = StringSplit($aReportInfo [$i][$_iExportCommentAll],@crlf)
		$sNewComment = ""

		for $j=1 to ubound($aComment) -1

			if stringinstr($aComment[$j], $_cTCReportDivision) = 1 then
				$aReportInfo [$i][$_iExportDivision] &= getSplitText($aComment[$j], $_cTCReportDivision) & @crlf

			elseif stringinstr($aComment[$j], $_cTCReportPriority) = 1 then
				$aReportInfo [$i][$_iExportPriority] &= getSplitText($aComment[$j], $_cTCReportPriority) & @crlf

			elseif stringinstr($aComment[$j], $_cTCReportCondition) = 1 then
				$aReportInfo [$i][$_iExportCondition] &= getSplitText($aComment[$j], $_cTCReportCondition) & @crlf

			elseif stringinstr($aComment[$j], $_cTCReportStep) = 1 then
				$aReportInfo [$i][$_iExportStep] &= getSplitText($aComment[$j], $_cTCReportStep) & @crlf

			elseif stringinstr($aComment[$j], $_cTCReportExpectResult) = 1 then
				$aReportInfo [$i][$_iExportExpectResult] &= getSplitText($aComment[$j], $_cTCReportExpectResult) & @crlf

			Else
				if $aComment[$j] <> "" then $sNewComment &= $aComment[$j] & @crlf
			endif

		next

		$aReportInfo [$i][$_iExportCommentAll] = _Trim($sNewComment)
		$aReportInfo [$i][$_iExportDivision] = _Trim ($aReportInfo [$i][$_iExportDivision])
		$aReportInfo [$i][$_iExportPriority] = _Trim ($aReportInfo [$i][$_iExportPriority])
		$aReportInfo [$i][$_iExportCondition] = _Trim ($aReportInfo [$i][$_iExportStep])
		$aReportInfo [$i][$_iExportStep] = _Trim ($aReportInfo [$i][$_iExportExpectResult])
		$aReportInfo [$i][$_iExportExpectResult] = _Trim ($aReportInfo [$i][$_iExportExpectResult])

	next

endfunc


func getSplitText($sAllText, $sTitle)

	local $sRet

	$sRet = _Trim(stringtrimleft($sAllText, stringlen($sTitle)))

	if stringleft($sRet,1) = ":" or stringleft($sRet,1) = "="  then $sRet = stringtrimleft($sRet,1)

	return $sRet

endfunc


func uniqueReportInfo($aReportInfo)

	local $aRet [1][$_iExportEnd]
	local $iExistsIndex
	local $iNewAddIndex = 0

	for $i=1 to ubound($aReportInfo)-1

		$iExistsIndex = _ArraySearch($aRet, $aReportInfo [$i][$_iExportIndex], 1,0,0,0,1,0)

		if $iExistsIndex = -1 then

			$iNewAddIndex += 1

			redim $aRet[$iNewAddIndex+1] [$_iExportEnd]

			$iExistsIndex = $iNewAddIndex

		endif

		$aRet[$iExistsIndex][$_iExportIndex] = $aReportInfo[$i][$_iExportIndex]
		$aRet[$iExistsIndex][$_iExportID] = $aReportInfo[$i][$_iExportID]
		$aRet[$iExistsIndex][$_iExportFile] = $aReportInfo[$i][$_iExportFile]

		if $aReportInfo[$i][$_iExportCommentAll] <> "" then $aRet[$iExistsIndex][$_iExportCommentAll] &= $aReportInfo[$i][$_iExportCommentAll] & @crlf

	next

	for $i=1 to ubound($aRet)-1

		$aRet[$i][$_iExportFile] = _trim($aRet[$i][$_iExportFile])
		$aRet[$i][$_iExportID] = _trim($aRet[$i][$_iExportID])
		$aRet[$i][$_iExportIndex] = _trim ($aRet[$i][$_iExportIndex])
		$aRet[$i][$_iExportCommentAll] = _trim($aRet[$i][$_iExportCommentAll])

	next

	return $aRet

endfunc


func replaceTCCommentString(byref $cTCCommnent)

	local $iHtmlStart
	local $sHtmlCode

	while stringinstr($cTCCommnent, "<") <> 0

		$iHtmlStart = stringinstr($cTCCommnent, "<")

		if $iHtmlStart <> "" then

			$sHtmlCode = _getmidstring($cTCCommnent, "<",">")
			;_debug("삭제될것 : " & $sHtmlCode)
			$cTCCommnent = StringReplace($cTCCommnent, "<" & $sHtmlCode & ">", "")

		endif
	wend

endfunc