#include-once

;Global enum $_sLogText_Start = "시작 : "
;Global enum $_sLogText_Testing = "실행 : "
;Global enum $_sLogText_Error = "오류 : "
;Global enum $_sLogText_Info = "정보 : "
;Global enum $_sLogText_PreError = "준비 : "
;Global enum $_sLogText_End = "종료 : "
;Global enum $_sLogText_Result = "결과 : "
;Global Const $_iColorComment = 0x339900



#include <IE.au3>
#include "UIACommon.au3"
#include "GUITARXml.au3"

Global enum $_iTCRScriptName = 1 , $_iTCRScriptID, $_iTCRNumber, $_iTCRRumTime,  $_iTCRResult, $_iTCRText, $_iTCRErrorText, $_iTCRCommentText, $_iTCRSkip, $_iTCREnd
Global enum $_iTSScriptName =1,  $_iTSID, $_iTSDate, $_iTSTime,  $_iTSResult, $_iTSAllCount, $_iTSRun, $_iTSPassCount, $_iTSErrorCount, $_iTSNotRun, $_iTSRIAll, $_iTSRIRun, $_iTSRIPass, $_iTSRIFail, $_iTSRINotRun, $_iTSRISkip,  $_iTSLink, $_iTSEnd
Global $_aTSTitle[$_iTSEnd] =["", "TestCaseName", "ID","시작시간","소요시간","결과","대상","실행","성공","실패","미실행","대상","실행","성공","실패","미실행","제외","링크"]

;test()



;_createHtmlReport("c:\1.htm" , FileRead("D:\_Autoit\JT\running.log"),"테스트결과 : " & "111" , "", "" )

func test()

	local $sSummryReportFile = "c:\test\1.htm"
	local $aTestSummry [$_iTSEnd]

	$aTestSummry [$_iTSScriptName] = "12"
	$aTestSummry [$_iTSDate] = _NowCalc()
	$aTestSummry [$_iTSResult] = True
	$aTestSummry [$_iTSAllCount] = 100
	$aTestSummry [$_iTSRun] = 4
	$aTestSummry [$_iTSErrorCount] = 2
	$aTestSummry [$_iTSLink] = "1234/report.htm"

	_addNewTestResult($sSummryReportFile, $aTestSummry, 10, False)

endfunc


func _addNewTestResult($sSummryReportFile , $aTestSummry,  $iMaxNumber, $bSimple)

	local $sHtml = ""

	if FileExists($sSummryReportFile) = 0 then _createNewSummryReport($sSummryReportFile, $bSimple)

	$sHtml = FileRead($sSummryReportFile)

	if _getTestScriptCategory($sHtml, $aTestSummry[$_iTSScriptName])  = 0 Then
		_addNewTestScriptCategory($sHtml, $aTestSummry[$_iTSScriptName])
	endif

	_addNewTestScriptResult($sHtml, $aTestSummry, $iMaxNumber, $sSummryReportFile ,$bSimple )

	; 최신 카테고리를 맨 위로 이동
	_getTestScriptCategory($sHtml, $aTestSummry[$_iTSScriptName])

	_moveLastTestScriptResultFirst($sHtml, $aTestSummry[$_iTSScriptName])

	filedelete ($sSummryReportFile)
	_FileWriteLarge($sSummryReportFile,$sHtml)

endfunc


func _moveLastTestScriptResultFirst(byref $sHtml, $sScriptName)

	local $iStart, $iEnd, $sResultLines

	$iStart  = _getTestScriptCategory($sHtml, $sScriptName)
	$iEnd  = StringInstr($sHtml, "</TABLE>", 0, 1, $iStart  + 1)
	$iEnd  = StringInstr($sHtml, "<!--", 0, 1, $iEnd    + 1)

	;debug($iStart, $iEnd, Stringlen($sHtml))
	$sResultLines = Stringmid($sHtml , $iStart ,$iEnd - $iStart)

	;debug($sResultLines)

	$sHtml = stringreplace($sHtml, $sResultLines, "")

	$sHtml = stringreplace($sHtml, "<!--TEST_SCRIPT_START-->", "<!--TEST_SCRIPT_START-->" & $sResultLines)

endfunc


func _addNewTestScriptResult(byref $sHtml, $aTestSummry, $iMaxNumber, $sSummryReportFile, $bSimple)

	local $iTestScriptStart
	local $iTestScriptNewLine
	local $sNewHtml = ""
	local $sLinkURL
	local $iPathSplitPos

	$iTestScriptStart = _getTestScriptCategory($sHtml, $aTestSummry[$_iTSScriptName])

	$iTestScriptNewLine = _getTestScriptFirstLine($sHtml, $iTestScriptStart)

	if $bSimple = False then
		$sLinkURL = $aTestSummry[$_iTSLink]
	else
		$iPathSplitPos = Stringinstr($aTestSummry[$_iTSLink],"\")
		if $iPathSplitPos = 0 then $iPathSplitPos = Stringinstr($aTestSummry[$_iTSLink],"/")
		$sLinkURL = stringtrimleft($aTestSummry[$_iTSLink], $iPathSplitPos)

	endif

	;debug($aTestSummry[$_iTSAllCount] )

	addHtml ($sNewHtml,"")
	addHtml ($sNewHtml,"<TR style='' height='20px'>")

		addHtml ($sNewHtml,"	<TD ALIGN='CENTER' > " & "<a target='_blank' href='" & $sLinkURL & "'>" & $aTestSummry[$_iTSID] & "</a>" &  "</TD>")
		addHtml ($sNewHtml,"	<TD ALIGN='CENTER' > " & $aTestSummry[$_iTSTime] & "</TD>")
		addHtml ($sNewHtml,"	<TD ALIGN='CENTER' > <span style='color:" & _iif($aTestSummry[$_iTSResult],"lime","red") & ";' >  ● </SPAN></TD>")
		addHtml ($sNewHtml,"	<TD ALIGN='CENTER' > " & $aTestSummry[$_iTSAllCount] & "</TD>")
		addHtml ($sNewHtml,"	<TD ALIGN='CENTER' > " & $aTestSummry[$_iTSRun] & "</TD>")
		addHtml ($sNewHtml,"	<TD ALIGN='CENTER' > <span style='font-weight:bold;color:green;'> " & $aTestSummry[$_iTSRun] - $aTestSummry[$_iTSErrorCount] & "</SPAN></TD>")
		addHtml ($sNewHtml,"	<TD ALIGN='CENTER' > <span style='font-weight:bold;color:red;'> " & $aTestSummry[$_iTSErrorCount] & "</SPAN></TD>")
		addHtml ($sNewHtml,"	<TD ALIGN='CENTER' > " & $aTestSummry[$_iTSNotRun] & "</TD>")


		addHtml ($sNewHtml,"	<TD ALIGN='CENTER' > " & $aTestSummry[$_iTSRIAll] & "</TD>")
		addHtml ($sNewHtml,"	<TD ALIGN='CENTER' > " & $aTestSummry[$_iTSRIRun] & "</TD>")
		addHtml ($sNewHtml,"	<TD ALIGN='CENTER' > <span style='font-weight:bold;color:green;'> " & $aTestSummry[$_iTSRIPass] & "</SPAN></TD>")
		addHtml ($sNewHtml,"	<TD ALIGN='CENTER' > <span style='font-weight:bold;color:red;' >" & $aTestSummry[$_iTSRIFail] & "</SPAN></TD>")
		addHtml ($sNewHtml,"	<TD ALIGN='CENTER' > " & $aTestSummry[$_iTSRINotRun] & "</TD>")
		addHtml ($sNewHtml,"	<TD ALIGN='CENTER' > " & $aTestSummry[$_iTSRISkip] & "</TD>")


	addHtml ($sNewHtml,"</TR>")

	insertHtmlintoIndex($sHtml, $sNewHtml, $iTestScriptNewLine)

	_delOldTestScriptResult($sHtml, $iMaxNumber, $iTestScriptStart, $sSummryReportFile)

EndFunc

func _delOldTestScriptResult(byref $sHtml, $iMaxNumber, $iTestScriptStart, $sSummryReportFile)

	; MAX 이상부터는 삭제 Line - > Table  까지
	; 파일명을 확인하여 지울 폴더 선별
	; 폴더가 있을 경우 삭제

	local $iSearchIndex
	local $sSearchLink
	local $iCount = 0
	local $iDeleteStart = 0
	local $iEndLine = StringInStr($sHtml,"</TABLE>",0,1, $iTestScriptStart )
	local $shtmlLeft
	local $shtmlRight
	local $sDeleteFolder

	$iSearchIndex = $iTestScriptStart

	do
		$iSearchIndex = StringInStr($sHtml,"<TR",0,1, $iSearchIndex + 1)
		if $iSearchIndex  > $iEndLine or $iSearchIndex = 0  then exitloop
		$iCount += 1

		if $iCount > $iMaxNumber + 1 then
			if $iDeleteStart = 0 then $iDeleteStart = $iSearchIndex
			$sSearchLink = _GetMidString($sHtml,"href='","'", $iSearchIndex)

			;debug($sSearchLink, $iSearchIndex, $iCount)
			;$sDeleteFolder = _GetPathName($sSummryReportFile) & stringreplace(_GetPathName($sSearchLink),"/","")
			$sDeleteFolder = _GetPathName($sSummryReportFile) & stringreplace($sSearchLink,"/","\")
			;debug($sDeleteFolder)
			$sDeleteFolder = _GetPathName($sDeleteFolder)
			DirRemove($sDeleteFolder,1)
			;debug($sDeleteFolder)

		endif

	until False

	if $iDeleteStart <> 0 then

		$shtmlLeft = Stringleft($sHtml, $iDeleteStart -1)
		$shtmlRight = StringTrimLeft($sHtml, $iEndLine -1)

		$sHtml = $shtmlLeft & $shtmlRight

	endif

EndFunc


Func _getTestScriptFirstLine(byref $sHtml, $iTestScriptStart)
	;debug(StringMid($sHtml,  $iTestScriptStart,600))

	return (StringInStr($sHtml, "<!--TEST_CASE_START-->",0,1, $iTestScriptStart) + StringLen("<!--TEST_CASE_START-->"))

endfunc


Func _createNewSummryReport($sHtmlFile, $bSimple)

	local $sHtml

	addHtml ($sHtml,"<!DOCTYPE html PUBLIC ""-//W3C//DTD XHTML 1.0 Transitional//EN"" ""http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"">")
	addHtml ($sHtml,"<html xmlns=""http://www.w3.org/1999/xhtml"">")
	addHtml ($sHtml,"<HEAD>")
	addHtml ($sHtml,'<meta http-equiv="content-type" content="text/html; charset=euc-kr">')
	addHtml ($sHtml,"<TITLE> " & $_sProgramName &  " 리포트 </TITLE>")

	addHtml ($sHtml,"</HEAD>")
	addHtml ($sHtml,"<BODY style='font-family:dotum; font-size: 12px;' >")
	addHtml ($sHtml,"<H1> " & $_sProgramName &  " 리포트 </H1>")

	if $bSimple = False then
		addHtml ($sHtml,"<H2><a target='_remote' href='remote.jsp'>" & $_sProgramName & " 원격관리</a></h2>")
	endif

	addHtml ($sHtml,"<br>")

	addHtml ($sHtml,"<!--TEST_SCRIPT_START-->")
	addHtml ($sHtml,"<!--TEST_SCRIPT_END-->")
	addHtml ($sHtml,"</BODY>")
	addHtml ($sHtml,"</HTML>")

	filedelete ($sHtmlFile)
	_FileWriteLarge($sHtmlFile,$sHtml)

endfunc


func _addNewTestScriptCategory(byref $sHtml, $sScriptName)

	local $sNewHtml = ""
	local $iSearchIndex = 0
	local $sSearchScriptName
	local $sLastSearchScriptName
	local $sLastSearchIndex = 0
	local $iInsertIndex = 0

	do
		$iSearchIndex = StringInStr($sHtml,"<!--SCRIPT:",0,1, $sLastSearchIndex + 1)
		$sSearchScriptName = _GetMidString($sHtml,"<!--SCRIPT:", "-->", $iSearchIndex)

		$sLastSearchIndex = $iSearchIndex
		$iInsertIndex = $sLastSearchIndex

		if $sSearchScriptName  > $sScriptName then exitloop

	until $iSearchIndex = 0

	if $iInsertIndex = 0 then $iInsertIndex = StringInStr($sHtml,"<!--TEST_SCRIPT_END-->")


	;if $iSearchIndex <> 0 then $iInsertIndex = _iif($sLastSearchIndex <> 0,$sLastSearchIndex, $iSearchIndex)

	addHtml ($sNewHtml,"")
	addHtml ($sNewHtml,"<!--SCRIPT:" & $sScriptName & "-->")
	addHtml ($sNewHtml,"<H2> 테스트 스크립트 : " & $sScriptName & "</H2>")
	addHtml ($sNewHtml,"<TABLE cellspacing='0' border='1' style='table-layout:fixed; font-family:dotum; font-size: 12px;' cellpadding='2' width='800'>")

	addHtml ($sNewHtml,"<TR style='background-color:#dcdcdc;'>")

		addHtml ($sNewHtml,"	<TH width='15%' rowspan=2> " & $_aTSTitle[$_iTSID] &  "</TH>")
		addHtml ($sNewHtml,"	<TH width='8%' rowspan=2> " & $_aTSTitle[$_iTSTime] &  "</TH>")
		addHtml ($sNewHtml,"	<TH width='6%' rowspan=2> " & $_aTSTitle[$_iTSResult] &  "</TH>")
		addHtml ($sNewHtml,"	<TH width='30%' colspan=5> " & "LINE" &  "</TH>")
		addHtml ($sNewHtml,"	<TH width='36%' colspan=6> " & "ID" &  "</TH>")

	addHtml ($sNewHtml,"</TR>")


	addHtml ($sNewHtml,"<TR style='background-color:#dcdcdc;' height='30px'>")

		addHtml ($sNewHtml,"	<TH width='6%'> " & $_aTSTitle[$_iTSAllCount] &  "</TH>")
		addHtml ($sNewHtml,"	<TH width='6%'> " & $_aTSTitle[$_iTSRun] &  "</TH>")
		addHtml ($sNewHtml,"	<TH width='6%'> " & $_aTSTitle[$_iTSPassCount] &  "</TH>")
		addHtml ($sNewHtml,"	<TH width='6%'> " & $_aTSTitle[$_iTSErrorCount] &  "</TH>")
		addHtml ($sNewHtml,"	<TH width='6%'> " & $_aTSTitle[$_iTSNotRun] &  "</TH>")

		addHtml ($sNewHtml,"	<TH width='6%'> " & $_aTSTitle[$_iTSRIAll] &  "</TH>")
		addHtml ($sNewHtml,"	<TH width='6%'> " & $_aTSTitle[$_iTSRIRun] &  "</TH>")
		addHtml ($sNewHtml,"	<TH width='6%'> " & $_aTSTitle[$_iTSRIPass] &  "</TH>")
		addHtml ($sNewHtml,"	<TH width='6%'> " & $_aTSTitle[$_iTSRIFail] &  "</TH>")
		addHtml ($sNewHtml,"	<TH width='6%'> " & $_aTSTitle[$_iTSRINotRun] &  "</TH>")
		addHtml ($sNewHtml,"	<TH width='6%'> " & $_aTSTitle[$_iTSRISkip] &  "</TH>")

	addHtml ($sNewHtml,"</TR>")

	addHtml ($sNewHtml,"<!--TEST_CASE_START-->")

	addHtml ($sNewHtml,"</TABLE>")
	addHtml ($sNewHtml,"<BR><BR>")
	addHtml ($sNewHtml,"")

	;debug($iInsertIndex)

	insertHtmlintoIndex($sHtml, $sNewHtml, $iInsertIndex)

endfunc


func insertHtmlintoIndex(byref $sHtml, $sNewHtml, $iInsertIndex)

	local $shtmlLeft = ""
	local $shtmlRight = ""

	$shtmlLeft = Stringleft($sHtml, $iInsertIndex -1)
	$shtmlRight = StringTrimleft($sHtml, $iInsertIndex - 1)

	$sHtml = $shtmlLeft & $sNewHtml & $shtmlRight

EndFunc


func _getTestScriptCategory(byref $sHtml, $sScriptName)

	return StringInStr($sHtml, "<!--SCRIPT:" & $sScriptName & "-->")

endfunc


; ----------------------------------------------------------------------


Func _INetGetMHT( $url, $file )

	_IEErrorHandlerRegister()

    Local $msg = ObjCreate("CDO.Message")
    If @error Then Return False
    Local $ado = ObjCreate("ADODB.Stream")
    If @error Then Return False

    With $ado
        .Type = 2
        ;.Charset = "US-ASCII"
		.Charset = "EUC-KR"
        .Open
    EndWith

    $msg.CreateMHTMLBody($url, 0)
    $msg.DataSource.SaveToObject($ado, "_Stream")

    FileDelete($file)

    $ado.SaveToFile($file, 1)
	$ado = ""
    $msg = ""

	if FileExists($file) = 0 then _ProgramError ("리포트 파일 생성에 실패하였습니다.")

    Return True

EndFunc

Func _createHtmlReport($sHtmlFile, $sLog, $sTitle, $aNewAddInfo, $sCurrentPaht, $sScriptName, $sTestSkipID, $sTestNotRunID,  $bXMLCreate, byref $sXML, $sDashBoardReport)

	local $sHtml
	local $aAddInfo[1]

	local $aTestLog
	local $sDashboardHost
	local $aFailLog
	local $bFileSave

	$sDashboardHost = "../../report.htm"

	if IsArray($aNewAddInfo) = 0 Then
		_ArrayAdd($aAddInfo, $aNewAddInfo)
	Else
		$aAddInfo = $aNewAddInfo
	endif

	addHtml ($sHtml,"<!DOCTYPE html PUBLIC ""-//W3C//DTD XHTML 1.0 Transitional//EN"" ""http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"">")
	addHtml ($sHtml,"<html xmlns=""http://www.w3.org/1999/xhtml"">")
	addHtml ($sHtml,"<head><style tpye='text/css'>")
	addHtml ($sHtml,"TD { word-break:break-all;}")
	addHtml ($sHtml,"#TARGET { font-weight:bold; color:#0000FF;}")
	addHtml ($sHtml,"#COMMAND { font-weight:bold;color:#AA0000;}")
	addHtml ($sHtml,"#ERROR { font-weight:bold;color:#339900;}")
	addHtml ($sHtml,"#COMMENT { font-weight:bold;color:#339900;}")
	addHtml ($sHtml,"#RESULT { text-align : center;}")
	addHtml ($sHtml,"#TCID {}")
	addHtml ($sHtml,"#TCFILE {}")

	addHtml ($sHtml,"</style>")
	addHtml ($sHtml,'<meta http-equiv="content-type" content="text/html; charset=euc-kr">')
	addHtml ($sHtml,"<TITLE>" & $sTitle & "</TITLE>")

	;addHtml ($sHtml,"<script>")
	;addHtml ($sHtml,"function AutoResize(photo) {")
	;addHtml ($sHtml,"     var MaxWidth = 240;")
	;addHtml ($sHtml,"     if (MaxWidth < photo.width) {")
	;addHtml ($sHtml,"	     photo.width = MaxWidth;")
	;addHtml ($sHtml,"	     photo.height = photo.height - (photo.height * (photo.width - MaxWidth) / photo.width);")
	;addHtml ($sHtml,"	}")
	;addHtml ($sHtml,"}")
	;addHtml ($sHtml,"</script>")
	addHtml ($sHtml,"</head>")
	addHtml ($sHtml,"<BODY style='font-family:dotum; font-size: 12px;' >")
	addHtml ($sHtml,"<H1>" & $sScriptName & " 테스트 상세결과 </H1></a>")
	addHtml ($sHtml,"<H2><a target='_dashboard' href='" & $sDashboardHost & "'>" & $_sProgramName & " 리포트</a></H2>")
	addHtml ($sHtml,"<br>")

	for $i=1 to ubound($aAddInfo) -1
		addHtml ($sHtml,"<H2>" & $aAddInfo[$i] & "</H2>")
	next

	if $sTestSkipID <> "" Then

		addHtml ($sHtml,"<H2>" & "테스트 제외 ID 목록 : " & "</H2>")
		addHtml ($sHtml,_createTestSkipTable($sTestSkipID))

	endif

	$aFailLog = _getTestResultLog($sLog, $sCurrentPaht, True, "" )

	addHtml ($sHtml,"<!--ERROR_LOG_START-->")
	if ubound($aFailLog) <> 1 then
		addHtml ($sHtml,"<H2>" & "테스트 로그 (실패) :" & "</H2>")
		addHtml ($sHtml,_createAllResultTable($aFailLog, $sTestSkipID, $sTestNotRunID,  False, $sXML, $sDashBoardReport))
	endif

	addHtml ($sHtml,"<!--DETAIL_LOG_START-->")
	addHtml ($sHtml,"<H2>" & "테스트 로그 (전체):" & "</H2>")
	addHtml ($sHtml,_createAllResultTable(_getTestResultLog($sLog, $sCurrentPaht, False, $sTestSkipID), $sTestSkipID, $sTestNotRunID, $bXMLCreate, $sXML, $sDashBoardReport))

	addHtml ($sHtml,"</BODY>")
	addHtml ($sHtml,"</HTML>")

	filedelete ($sHtmlFile)

	_FileWriteLarge($sHtmlFile,$sHtml)

endfunc


func _createTestSkipTable($sTestSkipID)

	; 테스트에서 제외돈 ID를 추출하여 상단에 표시할 목록 생성
	local $sHtml, $i
	local $aSkipList = getTestSkipIDList($sTestSkipID)

	addHtml ($sHtml,"<TABLE cellspacing='0' border='1' style='table-layout:fixed; font-family:dotum; font-size: 12px;' cellpadding='2'>")

	addHtml ($sHtml,"<TR style='background-color:#dcdcdc;' height='30px'>")

		addHtml ($sHtml,"<TH width='240'> 테스트 스크립트 </TH>")
		addHtml ($sHtml,"<TH width='360'> 테스트케이스 ID  </TH>")

	addHtml ($sHtml,"</TR>")

	for $i=1 to ubound($aSkipList ) -1
		addHtml ($sHtml,"<TR >" , False)
		addHtml ($sHtml,"<TD >" & $aSkipList[$i][1] & "</TD>" , False)
		addHtml ($sHtml,"<TD >" & "<a href='#skip_" & $i & "'>" & $aSkipList[$i][2] & "</a><br>" & "</TD>" , False)
		addHtml ($sHtml,"</TR>")
	next

	addHtml ($sHtml,"</TABLE>")

	return $sHtml

endfunc


func checkTestSkipIDList($sTestSkipID, $sTestID)

	; 테스트에서 제외돈 ID를 추출하여 상단에 표시할 목록 생성
	local $bRet = False, $i
	local $aSkipList = getTestSkipIDList($sTestSkipID)

	for $i=1 to ubound($aSkipList ) -1
		if $aSkipList[$i][2] = $sTestID then
			$bRet = True
			exitloop
		endif
	next

	return $bRet

endfunc


func getTestSkipIDList($sTestSkipID)

	local $i, $iTempSplitID
	local $aSkipListTemp

	;$sTestSkipID = StringReplace($sTestSkipID, @crlf & @crlf, @crlf)

	$sTestSkipID = stringreplace($sTestSkipID,@crlf,chr(0))
	$aSkipListTemp = StringSplit($sTestSkipID,chr(0))

	local $iIDCount = ubound($aSkipListTemp)

	if $iIDCount = "" then $iIDCount = 1

	local $aSkipIDList [$iIDCount][3]

	for $i=1 to ubound($aSkipIDList) -1
		if $aSkipListTemp[$i] <> "" then
			$iTempSplitID = StringInStr($aSkipListTemp[$i],":")
			$aSkipIDList[$i][1] = _Trim(StringLeft($aSkipListTemp[$i], $iTempSplitID -1))
			$aSkipIDList[$i][2] = _Trim(StringTrimLeft($aSkipListTemp[$i], $iTempSplitID))
		endif
	next

	return $aSkipIDList

endfunc


Func _getTestResultLog($sLog, $sCurrentPath, $bFailOnly, $sTestSkipID)

	local $aResultLog[1][$_iTCREnd]
	local $sLastLog
	local $aTestLog
	local $iNewLogCount = 0
	local $aLogInfo [$_iTCREnd]
	local $aLogLine
	local $sKey = Chr(1)
	local $iCount = 0
	local $iErrorCount
	local $j
	local $aSkipIDList
	local $iSkipLineID
	local $sScriptFile, $sTestCaseID
	local $sLastSkipID , $sLastSkipFile

	;writeDebugTimeLog("리포트 파일 분석 시작")

	$aTestLog = Stringreplace($aTestLog , @crlf, @cr )
	$aTestLog = Stringsplit($sLog, @cr)

	;debug($aTestLog)
	; $sScriptName , $sID , $sNo , $sResult & ,$sNewScript , $sErrorMsg , $sComment

	redim $aResultLog[ubound($aTestLog) -1][$_iTCREnd]

	$aSkipIDList = getTestSkipIDList($sTestSkipID)

;debug(ubound($aTestLog) & ubound($aResultLog))
	for $i = 1 to ubound($aTestLog) -2

		$aLogLine = Stringsplit($aTestLog[$i], $sKey)

		;writeDebugTimeLog("리포트 분석 : " & $aTestLog[$i])

		$iSkipLineID = 0

		if $bFailOnly = False or ($bFailOnly and $aLogLine[5] ="F") then

			$iCount += 1
			;debug($aTestLog[$i])

			$aResultLog[$iCount][$_iTCRScriptName] = _trim(stringreplace($aLogLine[1],"+","&nbsp;&nbsp;&nbsp;"))
			$aResultLog[$iCount][$_iTCRScriptID] = stringreplace($aLogLine[2],",","<BR>")
			$aResultLog[$iCount][$_iTCRNumber] = $aLogLine[3]
			$aResultLog[$iCount][$_iTCRRumTime] = $aLogLine[4]
			$aResultLog[$iCount][$_iTCRResult] = $aLogLine[5]
			$aResultLog[$iCount][$_iTCRText] = $aLogLine[6]
			$aResultLog[$iCount][$_iTCRErrorText] = stringreplace($aLogLine[7],$sCurrentPath,".")
			$aResultLog[$iCount][$_iTCRCommentText] = stringreplace($aLogLine[8],$sCurrentPath,".")

			$sScriptFile = $aLogLine[1]
			replaceTCFileString ($sScriptFile)
			$sScriptFile = _trim(stringreplace($sScriptFile,"+", ""))

			$sTestCaseID = _Trim($aLogLine[2])

			; 계속 같은 제외 항목인 경우 2번째 부터 ID가 바뀔때 까지 예외 처리하도록 함

			if $sScriptFile = $sLastSkipFile  and $sTestCaseID = $sLastSkipID then
				$aResultLog[$iCount][$_iTCRSkip] = True
			else
				$sLastSkipFile = ""
				$sLastSkipID = ""
			endif

			for $j=1 to ubound($aSkipIDList) -1

				;debug($sScriptFile, $sTestCaseID)
				;debug($aSkipIDList[$j][1], $aSkipIDList[$j][2])
				if $aSkipIDList[$j][1] = $sScriptFile  and $aSkipIDList[$j][2] = $sTestCaseID then

					$sLastSkipFile = $sScriptFile
					$sLastSkipID = $sTestCaseID

					$aSkipIDList[$j][1] = ""
					$aSkipIDList[$j][2] = ""
					$iSkipLineID = $j

					$aResultLog[$iCount][$_iTCRSkip] = True
					exitloop
				endif

			next

			if $aLogLine[5] ="F" then

				$iErrorCount += 1

				if $bFailOnly then
					$aResultLog[$iCount][$_iTCRRumTime] = "<a href='#error_" & $iErrorCount & "'>" & $aResultLog[$iCount][$_iTCRRumTime] & "</a>"
				else
					$aResultLog[$iCount][$_iTCRRumTime] = "<a name='error_" & $iErrorCount & "'>" & $aResultLog[$iCount][$_iTCRRumTime] & "</a>"
				endif

			endif

			if $iSkipLineID <> 0  then
				$aResultLog[$iCount][$_iTCRScriptName] = "<a name='skip_" & $iSkipLineID & "'>" & $aResultLog[$iCount][$_iTCRScriptName] & "</a>"
			endif

		endif

	next



	;_ArrayDisplay($aResultLog)

	redim $aResultLog[$iCount+1][$_iTCREnd]

	;writeDebugTimeLog("리포트 파일 분석 완료")

	return $aResultLog

endfunc


func convertImageLink(byref $sNewLog)

	;$sNewLog = stringreplace($sNewLog,"<","<img border=1 src='")
	;$sNewLog = stringreplace($sNewLog,"\","/")
	;$sNewLog = stringreplace($sNewLog,">","'>")

	local $iStart = 1
	local $sOldString
	local $sNewString
	local $iBrowserTextStart
	local $sNewWidthHeight


	while stringinstr($sNewLog,"<",0,1,$iStart)

		$iStart = stringinstr($sNewLog,"<",0,1,$iStart) + 1

		if stringinstr($sNewLog,">",0,1,$iStart) > 0 then

			$sOldString = _GetMidString($sNewLog,"<",">", $iStart -1)

			$iBrowserTextStart = $iStart - 14
			if $iBrowserTextStart <= 0 then $iBrowserTextStart = 1

			;debug ($iBrowserTextStart,$iStart)
			; 14글자 이내에 원하는 글자가 있을 경우에, 그리고 Fullsize로 설정되지 않았을 경우에만

			if StringInStr($sNewLog,$_sLogText_BrowserCapture,0,1,$iBrowserTextStart,14) > 0 and $_runFullSizeImage = False then

				$sNewWidthHeight = getMaxHtmlPreviewRatio($sOldString)
				$sNewString = "<a target='BrowserScreen' href='" & $sOldString & "'><img " & $sNewWidthHeight & " border=1  style='border-color: black;' src='" & $sOldString  & "'></a>"
				;$sNewString = "<a target='BrowserScreen' href='" & $sOldString & "'><img onload=AutoResize(this) border=1  style='border-color: black;' src='" & $sOldString  & "'></a>"

			elseif StringInStr($sNewLog,$_sLogText_BrowserAVI,0,1,$iBrowserTextStart, 14) > 0 then
				$sNewString = "<a target='AVIScreen' href='" & $sOldString & "'>"  & _GetFileName($sOldString)  & _GetFileExt($sOldString)  & "</a>"
				;$sNewString = "<img width=240 height=200 border=1 src='" & $sOldString  & "' onclick=""window.open ('" & $sOldString & "','','target=BrowserScreen, resizable=yes');"" ></a>"
			else

				if $_runFullSizeImage = True then
					$sNewWidthHeight = ""
				Else
					$sNewWidthHeight = getMaxHtmlPreviewRatio($sOldString)
				endif

				$sNewString = "<img " & $sNewWidthHeight & " border=1 style='border-color: black;' src='" & $sOldString  & "'>"
				;$sNewString = "<img onload=AutoResize(this) border=1 style='border-color: black;' src='" & $sOldString  & "'>"
			endif

			;debug($_runWorkReportPath, $sOldString)

			;writeDebugTimeLog("이미지 저장 : " & $_runWorkReportPath & " " & $sOldString)

			$sNewString = stringreplace($sNewString,"\","/")

			$sNewLog = stringReplace($sNewLog,"<" & $sOldString & ">" ,$sNewString)
			$iStart = $iStart + stringlen($sNewString)

		endif
	wend

endfunc


func getMaxHtmlPreviewRatio($sLinkFileName)

	local $iImageWidth, $iImageHeight
	local $sFile, $iImageMaxSize
	local $iMaxPreviewSize = 240
	local $sNewWidthHeight = "", $iNewX, $iNewY
	local $iNewPreviewRatio

	$sFile = $_runWorkReportPath & "\" & stringreplace($sLinkFileName,"/","\")

	if FileExists($sFile) then

		getImageSize($sFile, $iImageWidth, $iImageHeight)

		$iImageMaxSize = number(_Max($iImageWidth, $iImageHeight))

		if $iMaxPreviewSize <  $iImageMaxSize then

			$iNewPreviewRatio = $iMaxPreviewSize/$iImageMaxSize

			;debug($iNewPreviewRatio)

			$iNewX = int($iImageWidth * $iNewPreviewRatio)
			$iNewY = int($iImageHeight * $iNewPreviewRatio)

			$sNewWidthHeight = "width=" & $iNewX & " height=" & $iNewY

		endif

	endif

	;debug($sFile, $sNewWidthHeight)

	return $sNewWidthHeight

endfunc


Func _createAllResultTable($aResultLog, $sTestSkipID, $sTestNotRunID,  $bXMLCreate, byref $sXML, $sDashBoardReport)

	local $i, $j
	local $sValue
	local $sHtml
	local $sAttrib
	local $aSplit
	local $aSplitItem
	local $iCount = 0
	local $sTRColor
	local enum $_GRX_ID = 1, $_GRX_STime, $_GRX_ETime, $_GRX_Time, $_GRX_ErrorText, $_GRX_Comment
	local $sXMLInfo [1][$_GRX_Comment + 1]
	local $sXMLInfoCount = 0
	local $sLastXmlTCID, $sXMLTime, $sXMLError, $sXMLSplit, $sXMLDate = @YEAR & "-" & @MON & "-" & @MDAY
	local $aSkipList,$aNotRunList, $aSkipListTemp

	;debug($sXMLDate)


	$sXML = ""

	addHtml ($sHtml,"<TABLE cellspacing='0' border='1' style='table-layout:fixed; font-family:dotum; font-size: 12px;' cellpadding='2'>")

	addHtml ($sHtml,"<TR style='background-color:#dcdcdc;' height='30px'>")

		addHtml ($sHtml,"<TH width='240'> 테스트 스크립트 </TH>")
		addHtml ($sHtml,"<TH width='180'> 테스트케이스 ID  </TH>")
		addHtml ($sHtml,"<TH width='40'>Line</TH>")
		addHtml ($sHtml,"<TH width='140'> 실행시간 </TH>")
		addHtml ($sHtml,"<TH width='30'> 결과 </TH>")
		addHtml ($sHtml,"<TH width='520'> 상세로그 </TH>")

	addHtml ($sHtml,"</TR>")

	for $i=1 to ubound($aResultLog,1) -1
		$sTRColor = ""

		if $aResultLog[$i][$_iTCRResult]="F" Then
			$sTRColor = "style='background-color:lightpink;'"
		elseif $aResultLog[$i][$_iTCRSkip]=True Then
			$sTRColor = "style='background-color:YELLOW;'"
		endif

		addHtml ($sHtml,"<TR " & $sTRColor & ">" , False)

		$sAttrib = ""


		for $j=1 to $_iTCRText

			$sValue = $aResultLog[$i][$j]

			$sAttrib = ""

			Switch $j

				case $_iTCRScriptName
					$sAttrib = "id=TCFILE"

				case $_iTCRScriptID
					$sAttrib = "id=TCID"


				case $_iTCRNumber
					$sAttrib = "id=TCNUMBER"

				case $_iTCRRumTime
					$sAttrib = "id=TCTIME"
					if $_runHTMLTimeColor and $sTRColor = "" then 	$sAttrib &= " " &  getTimeColor($sValue)

				case  $_iTCRResult
					$sAttrib = "id=RESULT"
					;if $sValue = "F" then $sAttrib &=" style='font-weight:bold;color:red;'"

				case $_iTCRText

					$sAttrib = "id=TCTEXT"



					if $aResultLog[$i][$_iTCRErrorText] <> "" then
						$aResultLog[$i][$_iTCRErrorText] = stringreplace($aResultLog[$i][$_iTCRErrorText], "<BR>",@crlf)

						convertImageLink ($aResultLog[$i][$_iTCRErrorText])
						if $sValue  <> "" then $sValue = $sValue  & "<BR>"
						$sValue = $sValue  & "<span id=ERROR>" &   $aResultLog[$i][$_iTCRErrorText] &  "</span>"

						;$sAttrib ="style='font-weight:bold;color: red;'"
					endif

					if $aResultLog[$i][$_iTCRCommentText] <> "" then
						$aResultLog[$i][$_iTCRCommentText] = stringreplace($aResultLog[$i][$_iTCRCommentText], "<BR>",@crlf)

						convertImageLink ($aResultLog[$i][$_iTCRCommentText])
						if $sValue  <> "" then $sValue = $sValue  & "<BR>"
						$sValue = $sValue  & "<span ID=COMMENT>" &   $aResultLog[$i][$_iTCRCommentText] & "</span>"

						;$sAttrib ="style='font-weight:bold;color: red;'"
					endif

			EndSwitch

			$sValue = _ReplaceALink ($sValue)

			if $sValue = "" then $sValue = "&nbsp;"

			$sValue = StringReplace($sValue,@crlf,"<BR>")

			addHtml ($sHtml,"<TD " & $sAttrib & ">" & $sValue & "</TD>" , False)
		next


		; XML 정보 취합

		if $bXMLCreate then
			if $aResultLog[$i][$_iTCRScriptID] <> ""  then

				if $aResultLog[$i][$_iTCRScriptID] <> $sLastXmlTCID  then
					; 기존 ID가 틀릴 경우 신규 추가
					$sXMLInfoCount += 1
					redim $sXMLInfo [$sXMLInfoCount + 1][$_GRX_Comment + 1]
					$sXMLInfo [$sXMLInfoCount][$_GRX_STime] = GR_XmlExceptHTMLCode($aResultLog[$i][$_iTCRRumTime])
					$sXMLInfo [$sXMLInfoCount][$_GRX_ID] = $aResultLog[$i][$_iTCRScriptID]
					$sXMLInfo [$sXMLInfoCount][$_GRX_Time] = 0
				endif

				$sXMLInfo [$sXMLInfoCount][$_GRX_ETime] = GR_XmlExceptHTMLCode($aResultLog[$i][$_iTCRRumTime])
				$sXMLInfo [$sXMLInfoCount][$_GRX_Time] += getReportTime($sXMLInfo [$sXMLInfoCount][$_GRX_STime])

				;debug($aResultLog[$i][$_iTCRScriptID], $sXMLInfo [$sXMLInfoCount][$_GRX_STime])

				if $aResultLog[$i][$_iTCRErrorText] <> "" then
					$sXMLInfo [$sXMLInfoCount][$_GRX_ErrorText] &= "Report : " & $sDashBoardReport & @crlf
					$sXMLInfo [$sXMLInfoCount][$_GRX_ErrorText] &= "Line : " & $aResultLog[$i][$_iTCRNumber]  & @crlf
					$sXMLInfo [$sXMLInfoCount][$_GRX_ErrorText] &= "Script : " & $aResultLog[$i][$_iTCRText]  & @crlf
					$sXMLInfo [$sXMLInfoCount][$_GRX_ErrorText] &= "Error Log : " & $aResultLog[$i][$_iTCRErrorText] & chr(0)

				endif

				$sLastXmlTCID = $sXMLInfo [$sXMLInfoCount][$_GRX_ID]


			else
				$sLastXmlTCID = ""
			endif
		endif

		addHtml ($sHtml,"</TR>")

	next

	addHtml ($sHtml,"</TABLE>")


	; 최종 정보 취합
	if $bXMLCreate then

		for $i= 1 to ubound($sXMLInfo) -1

			if $sXMLInfo [$i][$_GRX_ErrorText] = "" then
				$sXMLError = ""
			else
				$sXMLSplit = StringSplit($sXMLInfo [$i][$_GRX_ErrorText], chr(0))
				for $j=1 to ubound($sXMLSplit) -1
					$sXMLSplit[$j] = _Trim($sXMLSplit[$j])
					if $sXMLSplit[$j] <> "" then $sXMLError &= GR_XmlAddTestCaseError(GR_XmlMakeInfo("message","Test Fail"), GR_XmlCDATA($sXMLSplit[$j])) & @crlf
				next
			endif

			;debug("111 " & $sXMLInfo [$i][$_GRX_STime], $sXMLInfo [$i][$_GRX_ETime])

			$sXMLInfo [$i][$_GRX_STime] = $sXMLDate & " " & Stringleft($sXMLInfo [$i][$_GRX_STime], 8)
			$sXMLInfo [$i][$_GRX_ETime] = $sXMLDate & " " & Stringleft($sXMLInfo [$i][$_GRX_ETime], 8)

			;debug("222 " & $sXMLInfo [$i][$_GRX_STime], $sXMLInfo [$i][$_GRX_ETime])

			if $sXMLInfo [$i][$_GRX_STime] > $sXMLInfo [$i][$_GRX_ETime] then
				$sXMLInfo [$i][$_GRX_ETime] = _DateAdd($sXMLInfo [$i][$_GRX_ETime], "D", 1)
			endif

			;debug("333 " & $sXMLInfo [$i][$_GRX_STime], $sXMLInfo [$i][$_GRX_ETime])

			;$sXMLTime = _DateDiff("s", $sXMLInfo [$i][$_GRX_STime], $sXMLInfo [$i][$_GRX_ETime])

			$sXMLTime  = StringFormat("%.1f", number($sXMLInfo [$i][$_GRX_Time]))

			$aSplitItem = StringSplit(StringReplace($sXMLInfo [$i][$_GRX_ID] ,"<BR>", chr(0)), chr(0))

			for $j=1 to ubound($aSplitItem) -1
				$aSplitItem[$j] = _Trim($aSplitItem[$j])
				; 제외 ID가 아닌 경우 추가
				if checkTestSkipIDList($sTestSkipID, $aSplitItem[$j]) = False then
					if $aSplitItem[$j] <> "" then $sXML &= GR_XmlAddTestCase(GR_XmlMakeInfo("time",$sXMLTime) & " " & GR_XmlMakeInfo("name",$aSplitItem [$j]) , $sXMLError)
				endif
			next

		next

		; SKIP 과 notrun 리스트를 제외 목록에 추가
		$aSkipList = getTestSkipIDList($sTestSkipID)

		;msg($aNotRunList[$i] & stringlen($aNotRunList[$i]) )

		$aNotRunList = StringSplit($sTestNotRunID, @crlf)

		for $i=1 to ubound($aSkipList ) -1
			_ArrayAdd($aNotRunList, $aSkipList[$i][2])
		next


		for $i=1 to ubound($aNotRunList ) -1
			$sXMLError = GR_XmlAddTestCaseSkip ()

			$aSkipListTemp = StringSplit($aNotRunList[$i] ,"," )
			for $j=1 to ubound($aSkipListTemp) -1
				$aSkipListTemp[$j] = _Trim($aSkipListTemp[$j])
				if $aSkipListTemp[$j] <> "" then $sXML &= GR_XmlAddTestCase(GR_XmlMakeInfo("time","0") & " " & GR_XmlMakeInfo("name",$aSkipListTemp[$j]) , $sXMLError)
			next
		next



	endif

	return $sHtml

endfunc

Func addHtml(byref $sHtml, $sStr, $bAddCrlf = True )

	$sHtml &= $sStr
	if $bAddCrlf then $sHtml &= @crlf

EndFunc



Func getTimeColor($sTimeString)

	local $iTime
	local $sColor = ""

	$iTime = getReportTime($sTimeString)

	Switch $iTime

		case 1 to 2
			$sColor = "#FBFBEF"

		case 2 to 4
			$sColor = "#F5F6CE"

		case 4 to 10
			$sColor = "#F5DA81"

		case 10 to 50
			$sColor = "#FA8258"

		case 50 to 1000
			$sColor = "#FF0000"

	EndSwitch

	if $sColor <> "" then $sColor = "bgcolor='" & $sColor & "' "
	return $sColor

EndFunc


;~ local $sOrgStr = "abc def gh ijk lmn opqrst uvw xy z"
;~ local $aChaneText1[2]
;~ local $aChaneTextLoc1[2]
;~ local $aChaneText2[3]
;~ local $aChaneTextLoc2[3]
;~ local $sChageColor1 = "ttt"
;~ local $sChageColor2 = "ccc"


;~ $aChaneText2[1] ="def"
;~ $aChaneTextLoc2[1] =stringinstr($sOrgStr,$aChaneText2[1])

;~ $aChaneText1[1] ="gh"
;~ $aChaneTextLoc1[1] =stringinstr($sOrgStr,$aChaneText1[1])

;~ $aChaneText2[2] ="z"
;~ $aChaneTextLoc2[2] =stringinstr($sOrgStr,$aChaneText2[2])

;~ debug(changeString($sOrgStr, $aChaneText1, $aChaneTextLoc1, $sChageColor1,  $aChaneText2, $aChaneTextLoc2, $sChageColor2))

func changeString($sOrgStr, $aChaneText1, $aChaneTextLoc1, $sChageColor1,  $aChaneText2, $aChaneTextLoc2, $sChageColor2)

	local $sNewStr
	local $iCount
	local $aChaneTextAndLoc[ubound($aChaneText1) + ubound($aChaneText2) - 1][4]
	local $sPreText
	local $sChangeText
	local $iPreStart


	$iCount = 0

	for $i=1 to ubound($aChaneText1) -1
		$iCount += 1
		$aChaneTextAndLoc[$iCount][1] = $aChaneText1[$i]
		$aChaneTextAndLoc[$iCount][2] = int($aChaneTextLoc1[$i])
		$aChaneTextAndLoc[$iCount][3] = $sChageColor1
	next

	for $i=1 to ubound($aChaneText2) -1
		$iCount += 1
		$aChaneTextAndLoc[$iCount][1] = $aChaneText2[$i]
		$aChaneTextAndLoc[$iCount][2] = int($aChaneTextLoc2[$i])
		$aChaneTextAndLoc[$iCount][3] = $sChageColor2
	next

	_ArraySort($aChaneTextAndLoc,0,1,0,2)

	$iPreStart = 1
	$sNewStr = ""

	for $i=1 to ubound($aChaneTextAndLoc) -1

		if  $aChaneTextAndLoc[$i][2] > 0 then

			$sPreText = StringMid($sOrgStr, $iPreStart, $aChaneTextAndLoc[$i][2] - $iPreStart)
			$iPreStart = $aChaneTextAndLoc[$i][2] + stringlen($aChaneTextAndLoc[$i][1])

			if $aChaneTextAndLoc[$i][3] = "#" & hex ($_iColorTargetHtml,6) then
				;$sChangeText = "<span style='font-weight:bold;color:" & $aChaneTextAndLoc[$i][3] & ";'>" & $aChaneTextAndLoc[$i][1] & "</span>"
				$sChangeText = "<span id=TARGET>" & $aChaneTextAndLoc[$i][1] & "</span>"

			elseif $aChaneTextAndLoc[$i][3] = "#" & hex ($_iColorCommandHtml,6) then
				$sChangeText = "<span id=COMMAND>" & $aChaneTextAndLoc[$i][1] & "</span>"

			endif
			;debug($i & " pre : " &  $sPreText)

			$sNewStr = $sNewStr & $sPreText & $sChangeText

			;debug($i & " new : " &  $sNewStr)
		endif
	next

	$sPreText = StringMid($sOrgStr, $iPreStart, stringlen($sOrgStr) - $iPreStart + 1)
	;debug($sPreText)
	$sNewStr = $sNewStr & $sPreText

	;msg($sNewStr)

	return $sNewStr

endfunc


;debug(_ReplaceALink("우리는 http://www.naver/c 그리고 http://www.xxx.ccc/ddd"))

func _ReplaceALink($sStr)

	local $iOldStart
	local $sNewStr
	local $iNewStart
	local $iNewEndStart
	local $iNewEndCrlf
	local $iNewEndTag
	local $sNewLink
	local $sNewLeft
	local $sNewRight

	$sNewStr = $sStr
	$iOldStart = 1

	$iNewStart = StringInstr($sNewStr, "http://", 1, 1,$iOldStart)

	while $iNewStart <> 0

		;"<BR>"  or " " 있을 경우 해당 line을 끝으로 볼 것 (N번 루프 돌릴것)

		$iNewStart = StringInstr($sNewStr, "http://", 1, 1,$iOldStart)
		$iNewEndTag = StringInstr($sNewStr, "<", 1, 1,$iNewStart)
		$iNewEndCrlf = StringInstr($sNewStr, @crlf, 1, 1,$iNewStart)

		$iNewEndStart = $iNewEndTag

		if $iNewEndCrlf <> 0 and $iNewEndCrlf < $iNewEndTag then $iNewEndStart = $iNewEndCrlf

		if $iNewEndStart = 0 then $iNewEndStart = StringLen($sNewStr) + 1

		;debug($iOldStart, $iNewStart, $iNewEndStart)

		$sNewLeft = StringLeft($sNewStr,$iNewStart-1)

		;debug ("left : " & $sNewLeft)

		$sNewLink = StringMId($sNewStr, $iNewStart, $iNewEndStart - $iNewStart)

		$sNewLink  = "<A target='_new' href='" & $sNewLink  & "'>" & $sNewLink  & "</A>"

		;debug ("mid : " & $sNewLink)

		$sNewRight = Stringmid($sNewStr, $iNewEndStart, stringlen($sNewStr) - $iNewEndStart +1)

		;debug ("right : " & $sNewRight)

		$sNewStr = $sNewLeft & $sNewLink & $sNewRight

		$iOldStart = StringLen($sNewLeft) + Stringlen($sNewLink)

		$iNewStart = StringInstr($sNewStr, "http://", 1, 1,$iOldStart)

		;debug ("complete : " & $sNewStr)


	wend

	return $sNewStr

endfunc


; 16:46:20 (0.1s) 형태에서 0.1을 추출함
func getReportTime($sTimeString)

	return number(_GetMidString ($sTimeString,"(", "s)"))

endfunc