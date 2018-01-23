#include-once

#include <IE.au3>
#include "UIACommon.au3"

; 파일 전체목록에서 그룹으로 된 리포트를 만들것 (제목, 파일list (;))
;_createUserCaptureReport("D:\_Autoit\guitar\report\21_검색쿼리2\2011_04_30_11_35_50\capture\1.htm","D:\_Autoit\guitar\report\21_검색쿼리2\2011_04_30_11_35_50\capture","제제목")

Func _createUserCaptureReport($sHtmlFile, $sPath, $sTitle, $sViewType)

	local $sHtml
	local $sTableHtml
	local $i
	local $sSplitChar = "_"
	local $aFileGoup
	Local $hFileOpen


	$aFileGoup = getUserCaptureFileGrop($sPath,$sSplitChar)

	for $i=1 to ubound($aFileGoup) -1
		$sTableHtml = $sTableHtml & getUserCaptureTable($aFileGoup[$i][1], $aFileGoup[$i][2], $sSplitChar, "(" & $i & "/" &  ubound($aFileGoup) -1  & ")", $sViewType)
	next

	if $sTableHtml = "" then $sTableHtml = "이미지 파일이 없습니다"

	addHtml ($sHtml,"<!DOCTYPE html PUBLIC ""-//W3C//DTD XHTML 1.0 Transitional//EN"" ""http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"">")
	addHtml ($sHtml,"<html xmlns=""http://www.w3.org/1999/xhtml"">")
	addHtml ($sHtml,"<TITLE>" & $sTitle & "</TITLE>")
	addHtml ($sHtml,"<BODY style='font-family:dotum; font-size: 12px;' >")
	addHtml ($sHtml,"<H1> " & $sTitle &  "</H1>")

	addHtml ($sHtml,"<BR>")
	addHtml ($sHtml,$sTableHtml)

	addHtml ($sHtml,"</BODY>")
	addHtml ($sHtml,"</HTML>")

	;filedelete ($sHtmlFile)
	$hFileOpen =  FileOpen ( $sHtmlFile, $FO_ANSI +  $FO_OVERWRITE)
	FileWrite($hFileOpen,$sHtml)
	FileClose($hFileOpen)

endfunc


func getUserCaptureTable($sGroupName, $sGroupList, $sSplitChar, $sAddTitle,  $sType)

	local $aGroupList = StringSplit($sGroupList,";")
	local $i
	local $sHtml = ""
	local $sFileTitle
	local $sTitle

	$sTitle = $sGroupName
	if stringright($sGroupName,stringlen($sSplitChar)) = $sSplitChar then $sTitle = stringtrimright($sGroupName, stringlen($sSplitChar))


	addHtml ($sHtml,"<H2> " & $sTitle & " " & $sAddTitle & "</H2>")

	addHtml ($sHtml,"<TABLE cellspacing='0' border='1' style='table-layout:fixed; font-family:dotum; font-size: 12px;' cellpadding='2'>")


	if $sType = "H" then

		for $i=1 to ubound($aGroupList) -1

			$sFileTitle = _GetFileName($aGroupList[$i])

			if stringleft($sFileTitle, stringlen($sGroupName)) = $sGroupName then
				$sFileTitle = stringtrimleft($sFileTitle, stringlen($sGroupName))
			endif
			;debug(_GetFileName($aGroupList[$i]))

			addHtml ($sHtml,"<TR style='background-color:#dcdcdc;' height='30px'>")
			addHtml ($sHtml,"<TD><B> " & $sFileTitle & " (" & $i & "/" &  ubound($aGroupList) -1  & ")" & "</B><BR>")
			addHtml ($sHtml,"<img border=1  style='border-color: black;' src='" & $aGroupList[$i]  & "'></TD>")
			addHtml ($sHtml,"</TR>")

		next
	else


		addHtml ($sHtml,"<TR style='background-color:#dcdcdc;' height='30px'>")

		for $i=1 to ubound($aGroupList) -1

			$sFileTitle = _GetFileName($aGroupList[$i])

			if stringleft($sFileTitle, stringlen($sGroupName)) = $sGroupName then
				$sFileTitle = stringtrimleft($sFileTitle, stringlen($sGroupName))
			endif
			;debug(_GetFileName($aGroupList[$i]))


			addHtml ($sHtml,"<TD><B> " & $sFileTitle & " (" & $i & "/" &  ubound($aGroupList) -1  & ")" & "</B><BR>")
			addHtml ($sHtml,"<img border=1  style='border-color: black;' src='" & $aGroupList[$i]  & "'></TD>")


		next

		addHtml ($sHtml,"</TR>")

	endif

	addHtml ($sHtml,"</TABLE>")

	addHtml ($sHtml,"<br>")

	return $sHtml

endfunc



func getUserCaptureFileGrop($sPath, $sSplitChar)

	local $aFileList
	local $aGourpList [1][3]
	local $i, $j
	local $iSplitCar
	local $sGroupName
	local $sGroupNameID
	local $sFileName

	$aFileList = _GetFileNameFromDir($sPath,"*" & $_cImageExt, 0)

	if $aFileList  = "" then return $aGourpList

	_ArraySort($aFileList,0,1)

	for $i=1 to ubound($aFileList) -1

		$sFileName = _GetFileName($aFileList[$i])
		$iSplitCar = stringinstr($sFileName,$sSplitChar)
		$sGroupName = _Trim(StringLeft($sFileName,$iSplitCar))

		if $sGroupName= "" then $sGroupName = "제목없음"

		$sGroupNameID = 0

		for $j=1 to ubound($aGourpList) -1
			if $aGourpList[$j][1] = $sGroupName Then
				$sGroupNameID = $j
			endif
		next

		$sFileName = StringReplace($aFileList[$i], $sPath, ".")
		$sFileName = StringReplace($sFileName, "\", "/")

		; 신규 그룹 추가
		if $sGroupNameID = 0 then
			$sGroupNameID= ubound($aGourpList)
			redim $aGourpList[$sGroupNameID+1][3]
			$aGourpList[$sGroupNameID][1] = $sGroupName
			$aGourpList[$sGroupNameID][2] = $sFileName
		else
			$aGourpList[$sGroupNameID][2] =  $aGourpList[$sGroupNameID][2] & ";" & $sFileName
		endif

	next

	return $aGourpList

endfunc








;Func addHtml(byref $sHtml, $sStr)

;	$sHtml &= $sStr & @crlf

;EndFunc