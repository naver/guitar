opt("MustDeclareVars",1)

#include-once
#include <misc.au3>
#include <file.au3>
#include <String.au3>
#include <Date.au3>
#include <WinAPI.au3>

Global $__debugoff = ""
Global $__debugfile

func _IsExeMode ()

	if StringRight( @ScriptFullPath,4) = ".exe" then
		return 1
	Else
		return 0
	endif

endfunc


func _debug($strmsg, $strmsg2="_EMPTY_", $strmsg3="_EMPTY_", $strmsg4="_EMPTY_", $strmsg5="_EMPTY_")

	local $strValue

	if $__debugoff = "" then

		$strValue = _ArrayToText($strmsg)
		consolewrite($strValue)

		if string($strmsg2) <> "_EMPTY_" then consolewrite(" | " & $strmsg2)
		if string($strmsg3) <> "_EMPTY_" then consolewrite(" | " & $strmsg3)
		if string($strmsg4) <> "_EMPTY_" then consolewrite(" | " & $strmsg4)
		if string($strmsg5) <> "_EMPTY_" then consolewrite(" | " & $strmsg5)

		consolewrite(@crlf)

		if $__debugfile <> "" then
			FileWriteLine($__debugfile, $strValue)
		endif
	endif

	sleep (1)

endfunc

Func _ArrayToText($strArray)

	local $ArraySize
	local $ret
	local $i,$j,$k,$q


	if ubound($strArray,4) then
		$ArraySize = 4
	elseif ubound($strArray,3) then
		$ArraySize = 3
	elseif ubound($strArray,2) then
		$ArraySize = 2
	elseif ubound($strArray) then
		$ArraySize = 1
	else
		$ArraySize = 0
	endif

	select
		case $ArraySize = 0

			$ret = $strArray

		case $ArraySize = 1
			for $i= 0 to ubound($strArray)-1
						$ret = $ret & "[" & $i & "] = " &  $strArray[$i] & @crlf
			next

		case $ArraySize = 2
			for $i= 0 to ubound($strArray)-1
				for $j= 0 to ubound($strArray,2)-1
						$ret = $ret & "[" & $i & "][" & $j & "] = " &  $strArray[$i][$j] & @crlf
				next
			next

		case $ArraySize = 3
			for $i= 0 to ubound($strArray)-1
				for $j= 0 to ubound($strArray,2)-1
					for $k= 0 to ubound($strArray,3)-1
						$ret = $ret & "[" & $i & "][" & $j & "][" & $k & "] = " &  $strArray[$i][$j][$k] & @crlf
					next
				next
			next

		case $ArraySize = 4

			for $i= 0 to ubound($strArray)-1
				for $j= 0 to ubound($strArray,2)-1
					for $k= 0 to ubound($strArray,3)-1
						for $q= 0 to ubound($strArray,4)-1
						$ret = $ret & "[" & $i & "][" & $j & "][" & $k & "][" & $q & "] = " &  $strArray[$i][$j][$k][$q] & @crlf
						next
					next
				next
			next

	endselect

	return $ret

endfunc

Func _Msg($strValue="", $strValueName = "_none_", $isTrayIcon="")

	local $tempTitle
	local $tempclip

	if $strValueName="_none_" then $strValueName = @ScriptName

	$tempTitle = $strValueName
	$strValue = _ArrayToText($strValue)

	if $isTrayIcon <> "" then
		; 트레이 아이콘으로 표시
		traytip ( $tempTitle,"" ,1,1)
		traytip ( $tempTitle,$strValue ,6000,1)
	else
		$tempclip=clipget()
		clipput ( $strValue )
		msgbox (0,$tempTitle,$strValue)
		clipput ($tempclip)
	endif

endFunc


func _ErrorExit ($error_msg)
	_Error($error_msg)
	seterror (1)

	exit(-1)

endfunc

func _Error($error_msg)
	msgbox(16,@ScriptName,$error_msg)
endfunc


Func _GetScriptName()
	local $tempName
	$tempName  = stringreplace(stringlower(@scriptname),".au3","")
	$tempName  = stringreplace($tempName,".exe","")
	return $tempName
Endfunc


Func _killPid($sPID)
    If IsString($sPID) Then $sPID = ProcessExists($sPID)
    If Not $sPID Then Return SetError(1, 0, 0)
    Return Run(@ComSpec & " /c taskkill /F /PID " & $sPID & " /T", @SystemDir, @SW_HIDE)
EndFunc


func _KillProc($strProc, $strexcept = "")

	; 와일드 카드 허용 프로세서 죽이기
	; notepa*
	local $_plist

	$_plist= _GetAllProcess($strProc)
	;_msg($_plist)
	for $i = 1 to ubound($_plist) -1
		if not(stringinstr($_plist[$i][1],$strexcept) <> 0 and $strexcept <> "" )then
			;if stringinstr($_plist[$i][1],_GetScriptName() & ".exe") = 0 then
			;_msg($_plist[$i][1])
  				processclose($_plist[$i][2])
  			;endif
  		endif
	next

endFunc



func _GetAllProcess($strProc)

	; 와일드 카드 허용 프로세서 죽이기
	; notepa*

	local $_plist[1][3]
	local $_findProc
	local $_ProcList
	;local $strProc
	local $i
	local $_isWild

	$_findProc = stringreplace(stringlower($strProc),"*","")
	if $_findProc <> stringlower($strProc) then $_isWild=1
	$_ProcList = ProcessList()

	;_msg(($_ProcList)	)
	for $i  = 1 to ubound($_ProcList) -1
  		$_ProcList[$i][0] = stringlower($_ProcList[$i][0])
  		;if ($_isWild and stringinstr($_findProc,$_ProcList[$i][0]) = 1) or $_ProcList[$i][0] = $_findProc then
  		if (stringinstr($_ProcList[$i][0],$_findProc) = 1) or $_ProcList[$i][0] = $_findProc then

  			redim $_plist[ubound($_plist)+1][3]
  			;_msg(ubound($_plist)-1)
  			$_plist[ubound($_plist)-1][1]=$_ProcList[$i][0]
  			$_plist[ubound($_plist)-1][2]=$_ProcList[$i][1]
			;_msg($_ProcList[$i][1])
  		endif
	next

	return $_plist

endFunc


func _CmdlineCheck($minArgCount,$MaxArgCount,$strErrorMsg)
	if not (ubound($cmdline) >=  $minArgCount + 1 and ubound($cmdline) <=  $MaxArgCount + 1) then
		_ErrorExit("Please check command line option " & @crlf  & @crlf & _GetScriptName() & ".exe " &  $strErrorMsg)
	endif
endfunc


func _GetCommandArg($strArg,byref $strArgVar)

	local $i

	for $i=1 to ubound ($cmdline) -1
		if stringinstr(stringlower($cmdline[$i] & "="), stringlower($strArg)) = 1  then
			$strArgVar = stringreplace($cmdline[$i],$strArg & "=" ,"")
			$strArgVar = _getCommandArgFilter(stringreplace($strArgVar,$strArg,""))
			return true
		endif
	next

	return false

endfunc

func _GetCommandExists($strArg)

	local $i

	for $i=1 to ubound ($cmdline) -1

		if stringinstr(stringlower($cmdline[$i]), stringlower($strArg)) = 1  then
			return true
		endif

	next

	return false

endfunc


func _getCommandArgFilter($strArg)

	local $sRet

	$sRet = $strArg

	if stringleft($sRet,1) = '"' then $sRet = StringTrimLeft($sRet,1)
	if StringRight($sRet,1) = '"' then $sRet = StringTrimRight($sRet,1)

	return $sRet

endfunc


func _CheckSingleRun($sEXEFile = "")

	if $sEXEFile = "" then $sEXEFile = _GetScriptName() & ".exe"

	if ubound(_GetAllProcess($sEXEFile),1) <= 2  then
		return True
	else
		return False
	endif


endfunc


func _GetFileNameAndExt($strFile)

	return _GetFileName($strFile) & _GetFileExt($strFile)

endfunc


func _GetFileExt($strFile)

	local $szDrive, $szDir, $szFName, $szExt

	_PathSplit($strFile, $szDrive, $szDir, $szFName, $szExt)

	return $szExt

endfunc


func _GetFileName($strFile)

	local $szDrive, $szDir, $szFName, $szExt

	_PathSplit($strFile, $szDrive, $szDir, $szFName, $szExt)

	return $szFName

endfunc


func _GetPathName($strFile)

	local $szDrive, $szDir, $szFName, $szExt

	_PathSplit($strFile, $szDrive, $szDir, $szFName, $szExt)

	return $szDrive & $szDir

endfunc

func _Trim ($sStr)
	return StringStripWS($sStr, 3)
EndFunc


func _Boolean($sStr)

	local $bRet

	Switch  StringStripWS(StringLower($sStr),3)
		case "t", "true", "1"
			$bRet = True
		case Else
			$bRet = False
	EndSwitch

	return $bRet

endfunc

func _StringLenUnicode($sStr)

	local $i
	local $iStringCount =0

	for $i = 1 to stringlen($sStr)
		$iStringCount = $iStringCount + 1
		if asc(stringmid($sStr,$i,1)) >= 0x80 then $iStringCount = $iStringCount + 1
	next

	return $iStringCount

EndFunc


func _StringLoss($sStr, $iCount, $iArrow, $sSPlit = "")

	local $sLoss = "..."
	local $sRet = ""
	local $aSplit
	local $i, $j
	local $sRetLeft
	local $sRetRight
	local $iUbound

	if _StringLenUnicode($sStr) > $iCount Then

		if $sSPlit <> "" then
			$aSplit = StringSplit($sStr, $sSPlit)
			$iUbound = ubound ($aSplit) -1
			if $iArrow > 0 Then
				for $i= 1 to $iUbound
					$sRet = $sRet & $aSplit[$i]
					$sRet = $sRet  & _iif($i <> $iUbound, $sSPlit, "")
					if $i <> $iUbound then
						if _StringLenUnicode($sRet) + _StringLenUnicode($sSPlit) + _StringLenUnicode($aSplit[$i + 1]) > $iCount then exitloop
					endif
				next
			elseif $iArrow < 0 Then
				for $i= 1 to $iUbound
					$sRet = $aSplit[ubound ($aSplit) - $i ] & $sRet
					$sRet = _iif($i <> $iUbound, $sSPlit, "") & $sRet
					if $i <> ubound ($aSplit) -1 then
						if _StringLenUnicode($sRet) + _StringLenUnicode($sSPlit) + _StringLenUnicode($aSplit[$iUbound -$i]) > $iCount then exitloop
					endif
				next
			elseif $iArrow = 0 Then
				for $i= 1 to $iUbound
					if mod ($i,2) = 1 then
						$j = $j + 1

						$sRetLeft = $sRetLeft & $aSplit[$j]
						$sRetLeft = $sRetLeft & _iif($i <> $iUbound, $sSPlit, "")
					Else
						$sRetRight = $aSplit[ubound ($aSplit) -$j] & $sRetRight
						$sRetRight = _iif($i <> $iUbound, $sSPlit, "") & $sRetRight
						;debug($aSplit[ubound ($aSplit) - $i + 1])
						;debug("#" & $sRetLeft & " _ " & $sRetRight)
					endif

					if $i <> $iUbound then
						if _StringLenUnicode($sRetRight) + _StringLenUnicode($sSPlit) + _StringLenUnicode($sRetLeft) + _StringLenUnicode($sSPlit) + _StringLenUnicode($aSplit[_iif (mod ($i+1,2), $j + 1 , ubound ($aSplit) - $j - 1)]) > $iCount then exitloop
					endif


				next
			endif
		else
			if $iArrow = 0 Then
				;$sRet = _iif ($iArrow > 0, _StringLeftUnicode($sStr,$iCount), _StringRightUnicode($sStr,$iCount))
			else
				$sRet = _iif ($iArrow > 0, _StringLeftUnicode($sStr,$iCount), _StringRightUnicode($sStr,$iCount))
			endif
		endif


		if $iArrow = 0 Then
			;if $sRetLeft + $sSPlit + $sRetRight <> $sStr then
				$sRet = $sRetLeft & $sLoss & $sRetRight
		else
			if $sRet <> $sStr then $sRet = _iif($iArrow > 0 , $sRet & $sLoss, $sLoss & $sRet)
		endif

	Else
		$sRet = $sStr
	endif

	return $sRet

EndFunc


Func _StringFormatUnicode($sStr, $sVar0 = "", $sVar1 = "", $sVar2 = "", $sVar3 = "",$sVar4 = "", $sVar5 = "", $sVar6 = "", $sVar7 = "", $sVar8 = "", $sVar9 = "")

	local $sAddChr = chr(1)
	local $sCurStr
	local $iAddCount
	local $sRet

	$sCurStr = $sVar0

	$sVar0 &= _StringRepeat($sAddChr, _StringLenUnicode($sVar0) - StringLen($sVar0))
	$sVar1 &= _StringRepeat($sAddChr, _StringLenUnicode($sVar1) - StringLen($sVar1))
	$sVar2 &= _StringRepeat($sAddChr, _StringLenUnicode($sVar2) - StringLen($sVar2))
	$sVar3 &= _StringRepeat($sAddChr, _StringLenUnicode($sVar3) - StringLen($sVar3))
	$sVar4 &= _StringRepeat($sAddChr, _StringLenUnicode($sVar4) - StringLen($sVar4))
	$sVar5 &= _StringRepeat($sAddChr, _StringLenUnicode($sVar5) - StringLen($sVar5))
	$sVar6 &= _StringRepeat($sAddChr, _StringLenUnicode($sVar6) - StringLen($sVar6))
	$sVar7 &= _StringRepeat($sAddChr, _StringLenUnicode($sVar7) - StringLen($sVar7))
	$sVar8 &= _StringRepeat($sAddChr, _StringLenUnicode($sVar8) - StringLen($sVar8))
	$sVar9 &= _StringRepeat($sAddChr, _StringLenUnicode($sVar9) - StringLen($sVar9))

	$sRet = StringFormat ($sStr, $sVar0, $sVar1, $sVar2, $sVar3, $sVar4, $sVar5, $sVar6, $sVar7, $sVar8, $sVar9)

	$sRet = stringreplace($sRet,$sAddChr,"")

	return $sRet

endfunc

func _StringLeftUnicode($sStr, $iCount)
	return _StringUnicodeDeleteAsc1(stringleft(_StringUnicodeAddAsc1($sStr),$iCount))
endfunc

func _StringRightUnicode($sStr, $iCount)
	return _StringUnicodeDeleteAsc1(stringRight(_StringUnicodeAddAsc1($sStr),$iCount))
endfunc


func _StringUnicodeDeleteAsc1($sStr)
	return StringReplace($sStr, chr(1),"")
endfunc

func _StringUnicodeAddAsc1($sStr)

	local $i
	local $sNewStr
	local $iStringCount =0
	local $sCurChar

	for $i = 1 to stringlen($sStr)
		$sCurChar = stringmid($sStr,$i,1)
		if asc($sCurChar) >= 0x80 then $sNewStr &= chr(1)
		$sNewStr &= $sCurChar
	next

	return $sNewStr

EndFunc



Func _GetMidString($strall , $strFirst, $strLast, $Start = 1)
	;_msg(_GetMidString("11123456","1","6",3))

    local $i
    local $j
    local $ret_temp

    $strall = stringtrimleft($strall,$start-1)
    ;debug($strall)

    $i = stringInStr($strall, $strFirst, $Start)
    ;debug($i)

    $strall = stringtrimleft($strall,$i+ stringlen($strFirst)-1)
    ;debug($strall)


    If $i <> 0 Then $j = stringInStr($strall, $strLast)

    If $i <> 0 And $j <> 0 Then
        $ret_temp = stringLeft($strall, $j-1)
    Else
        $ret_temp = ""
    EndIf


    return $ret_temp

EndFunc



Func _GetLogDateTime()

	local $sTestStartTime =  _NowCalc()

	return StringReplace(Stringleft( $sTestStartTime,10),"/","-") & "_" & stringreplace(stringright( $sTestStartTime,8), ":","-")

endfunc


func _arraySortByLen(byref $aArray, $bOrder = True)

	local $i, $j
	local $sTemp, $bChange
	local $iFLen, $iSLen


	for $i=1 to ubound($aArray) -2
		for $j= $i + 1 to ubound($aArray) -1

			$iFLen = _StringLenUnicode( $aArray[$i])
			$iSLen = _StringLenUnicode( $aArray[$j])

			$bChange = False

			if $bOrder Then
				if $iFLen > $iSLen then $bChange = True
			Else
				if $iFLen < $iSLen then $bChange = True
			endif

			if $bChange Then
				;debug("Change " ,$aArray[$i], $aArray[$j])
				$sTemp = $aArray[$i]
				$aArray[$i] = $aArray[$j]
				$aArray[$j] = $sTemp
			endif
		next
		;_msg($aArray)
	next

endfunc

func _Swap(byref $val1, byref  $val2)

	local $val3

	$val3 = $val1
	$val1 = $val2
	$val2 = $val3

EndFunc


func _StringAddNewLine(byref $sStr, $sNewStr)

	if $sStr <> "" then $sStr = $sStr & @crlf
	$sStr = $sStr & $sNewStr

endfunc



Func _SendUnicode($string)

	local $sStrArray = StringToASCIIArray ($string)
	local $sNewStr = ""
	local $sUncode
	local $iSendKeyDownDelay = opt("SendKeyDownDelay")
	local $iSendKeyDelay = opt("SendKeyDelay")

	; asc 256 이하일 때는 asc 방식으로 전달함

    For $i = 0 to ubound($sStrArray) -1
		;debug ($sStrArray[$i])
		$sUncode = chrw($sStrArray[$i])
		if $sStrArray[$i] < 256 then $sUncode = "{ASC " & asc($sUncode) & "}"
		$sNewStr = $sNewStr & $sUncode
    Next

	;opt("SendKeyDownDelay", 0)
	;opt("SendKeyDelay", 0)

	;debug($sNewStr)
	send($sNewStr)

	opt("SendKeyDownDelay", $iSendKeyDownDelay)
	opt("SendKeyDelay", $iSendKeyDelay)

EndFunc



Func _TimerInit($from=0)
	Local $t = dllcall("kernel32.dll","int","GetTickCount")
	return $t[0] - $from
EndFunc

func _TimerDiff($trel)
    Return _TimerInit($trel)
EndFunc


func WinGetPosWithoutBorder(byref $aPos)
; SM_CXSIZEFRAME = 32
; http://msdn.microsoft.com/en-us/library/ms724385(VS.85).aspx

	local $iBorder

	$iBorder = _WinAPI_GetSystemMetrics(32)

	$aPos[0] = $aPos[0]  + $iBorder
	$aPos[1] = $aPos[1]  + $iBorder
	$aPos[2] = $aPos[2]  - ($iBorder * 2)
	$aPos[3] = $aPos[3]  - ($iBorder * 2)

endfunc


Func _StringAddThousandsSep($sString, $sThousands = ",", $sDecimal = ".")
    Local $aNumber, $sLeft, $sResult = "", $iNegSign = "", $DolSgn = ""
    If Number(StringRegExpReplace($sString, "[^0-9\-.+]", "\1")) < 0 Then $iNegSign = "-" ; Allows for a negative value
    If StringRegExp($sString, "\$") And StringRegExpReplace($sString, "[^0-9]", "\1") <> "" Then $DolSgn = "$" ; Allow for Dollar sign
    $aNumber = StringRegExp($sString, "(\d+)\D?(\d*)", 1)
    If UBound($aNumber) = 2 Then
        $sLeft = $aNumber[0]
        While StringLen($sLeft)
            $sResult = $sThousands & StringRight($sLeft, 3) & $sResult
            $sLeft = StringTrimRight($sLeft, 3)
        WEnd
        $sResult = StringTrimLeft($sResult, 1); Strip leading thousands separator
        If $aNumber[1] <> "" Then $sResult &= $sDecimal & $aNumber[1] ; Add decimal
    EndIf
    Return $iNegSign & $DolSgn & $sResult ; Adds minus or "" (nothing)and Adds $ or ""
EndFunc ;==>_StringAddThousandsSep


func _WinGetClientPos($hWnd)

	local $aWinPos, $aClientSize, $aClientPos[4] = [0,0,0,0]
	local $iBorder

	$aWinPos = WinGetPos($hWnd)

	if IsArray($aWinPos) then
	;debug($aWinPos)

		$aClientSize = WinGetClientSize($hWnd)

		$iBorder = ($aWinPos[2] - $aClientSize[0]) / 2
		;debug($iBorder )

		;debug($iBorder)

		$aClientPos[0] = $aWinPos[0] + $iBorder
		$aClientPos[1] =$aWinPos[1] + ($aWinPos[3] - $aClientSize[1] - $iBorder)
		$aClientPos[2] = $aClientSize[0]
		$aClientPos[3] = $aClientSize[1]
		;debug($aWinPos)
	endif

	return $aClientPos

endfunc


func _FileWriteLarge($sFile, $sText)

	local $i
	local const $iSizeLimit = 100000
	local $iTextSize = StringLen($sText)
	local $iCount = int($iTextSize / $iSizeLimit) + 1

	FileDelete($sFile)

	for $i= 1 to $iCount
		;debug(($i-1) * $iSizeLimit + 1, $iSizeLimit)
		FileWrite($sFile, stringmid($sText , ($i-1) * $iSizeLimit + 1, $iSizeLimit))
	next

endfunc


func _ScriptLogWrite($sText, $bDelete = False)

	local $sLogFile = @ScriptDir & "\" & _GetScriptName() & ".log"
	local $sLogText

	if $bDelete then FileDelete($sLogFile)

	$sLogText = _nowcalc() & " : " & $sText

	FileWriteLine($sLogFile, $sLogText)

endfunc


func _DateFromMonth($MonthName)
;달이름을 입력받아 해당 달의 숫자를 리턴함

	local $sRet


	for $i=1 to 12
		if _trim($MonthName) = _DateToMonth($i, 1) or _trim($MonthName) = _DateToMonth($i) or _trim($MonthName) = StringLeft(_DateToMonth($i,1),3) Then
			$sRet = $i
		endif
	next

	return $sRet

endfunc


Func _isWorksatationLocked()

	local $res=0
	local $h=DllCall("User32.dll","int","OpenInputDesktop","int",0,"int",0,"int",0x0001)
	if $h[0]=0 then $res=1
	DllCall("user32.dll", "int", "CloseDesktop", "int", $h[0])

	$res = _iif($res=1, True, False)

	return  $res
EndFunc
