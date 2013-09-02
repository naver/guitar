#include ".\_include_nhn\_util.au3"

;_debug(GR_TestRrsult ())

Func GR_XmlAddTestSuite($sInfo, $sValue)

	local $sRet = ""

	$sRet = "<testsuite " & $sInfo
	$sRet &= ">" & @crlf
	$sRet &= $sValue & "</testsuite>" & @crlf

	return  $sRet

Endfunc


Func GR_XmlAddTestCase($sInfo, $sValue = "" )

	local $sRet = ""

	$sRet = @tab & "<testcase  " & $sInfo

	if $sValue = "" then
		$sRet &= "> </testcase>" & @crlf
	else
		$sRet &= ">" & @crlf
		$sRet &= $sValue
		$sRet &= @tab & "</testcase>" & @crlf
	endif

	return  $sRet

Endfunc


Func GR_XmlAddTestCaseError($sInfo, $sValue)

	local $sRet = ""

	$sRet = @tab & @tab & "<error " & $sInfo  & ">" & @crlf
	$sRet &= @tab & @tab &  @tab & GR_XmlCharConvert($sValue) & @crlf
	$sRet &= @tab & @tab & "</error>" & @crlf

	return  $sRet

Endfunc

Func GR_XmlAddTestCaseSkip()

	local $sRet = ""


	$sRet &= "<skipped/>" & @crlf

	return  $sRet

Endfunc


Func GR_XmlAddHeader()


	return '<?xml version="1.0" encoding="EUC-KR" ?>' & @crlf

Endfunc


Func GR_XmlMakeInfo($sInfoName, $sValue = "" )

	return  $sInfoName & '="' & GR_XmlCharConvert($sValue) & '" '

Endfunc


Func GR_XmlCharConvert($sText)

	$sText = $sText

	return $sText

Endfunc


Func GR_XmlExceptHTMLCode($sText)

	local $sRet = $sText, $ihStart, $ihEnd

	$ihStart = stringinstr($sRet, "<" )
	$ihEnd = stringinstr($sRet, ">" )

	while ($ihStart <> 0 and  $ihStart <> 0)

		$sRet = Stringleft($sRet,$ihStart-1) & StringTrimLeft ($sRet,$ihEnd)

		$ihStart = stringinstr($sRet, "<" )
		$ihEnd = stringinstr($sRet, ">" )
	wend

	return $sRet

Endfunc


Func GR_XmlCDATA($sText)

	return "<![CDATA[" & @crlf & $sText & @crlf & "]]>"

Endfunc


;16:46:20 (0.1s)


func GR_TestRrsult()

	local $sTestSuite, $sError, $sTestCaseList

	$sTestCaseList &= GR_XmlAddTestCase (GR_XmlMakeInfo("xxx",10))
	$sError = GR_XmlAddTestCaseError (GR_XmlMakeInfo("eee","10."),"Msg")
	$sTestCaseList &= GR_XmlAddTestCase (GR_XmlMakeInfo("yyy",11),$sError)
	$sTestCaseList &= GR_XmlAddTestCase (GR_XmlMakeInfo("zzz",12))
	$sTestSuite = GR_XmlAddTestSuite (GR_XmlMakeInfo("sss",13), $sTestCaseList)

	return GR_XmlAddHeader () & $sTestSuite

endfunc




