AutoItSetOption("MustDeclareVars", 1)

#include-once
#Include <Misc.au3>
#Include <WinAPI.au3>
#include ".\_include_nhn\_util.au3"


Global $_bWinhttpRequestError

Func _WinhttpRequest($sURL, $sMethod = "GET", $sParam = "", $iTimeout = 31000, $sHeader = "Content-Type:text/html; charset=utf-8")
	; form header
	; application/x-www-form-urlencoded

	local $i
	local $oHTTP
	local $oHTTPError
	local $sHeaderSplit
	local $sHeaderSplitItem
	local $sRet
	local $sHTTPStatus
	local $sHTTPStatusText

	$_bWinhttpRequestError = 0

	$oHTTPError = ObjEvent("AutoIt.Error","_WinhttpRequestError")
	$oHTTP = ObjCreate("winhttp.winhttprequest.5.1")

	With $oHTTP
		$sHeaderSplit = StringSplit($sHeader,"|",2 )

		.SetTimeouts($iTimeout,$iTimeout,$iTimeout,$iTimeout)

		if $sMethod <> "GET" then
			.Open($sMethod, $sURL,0)
		Else
			.Open($sMethod, $sURL & _iif($sParam<> "" , "?"& $sParam, ""),0)
		endif

		.SetRequestHeader ("Cache-Control", "no-cache")

		for $sHeaderSplit in StringSplit($sHeader,"|",2 )
			$sHeaderSplitItem = StringSplit($sHeaderSplit,":")

			.SetRequestHeader ($sHeaderSplitItem[1], $sHeaderSplitItem[2])

		next

		if  $sMethod <> "GET" then
			.Send($sParam)
		Else
			.Send()
		endif

		.WaitForResponse($iTimeout)
		$sHTTPStatus = .status

		$sRet = BinaryToString(.ResponseBody,4)

		$sHTTPStatusText = .statustext

	EndWith

	;debug($sHTTPStatus)

	if ($_bWinhttpRequestError) or ($sHTTPStatus = 404)Then Return SetError(1, $sHTTPStatus, "")
	;if ($_bWinhttpRequestError) Then Return SetError(1, 0, "")

	return $sRet

EndFunc

Func _WinhttpRequestError()

	$_bWinhttpRequestError = True
	;$_oHTTPError.clear

Endfunc

Func _UnicodeURLEncode($UnicodeURL, $bANSI = False)

	local $UnicodeBinary
	local $UnicodeBinary2
	local $EncodedString
	local $UnicodeBinaryLength
	local $i
	local $UnicodeBinaryChar
	local $iDecodeType
	Local $EncodedString

	if $bANSI then
		$iDecodeType = 1
	else
		$iDecodeType = 4
	endif

    $UnicodeBinary = StringToBinary ($UnicodeURL, $iDecodeType)
    $UnicodeBinary2 = StringReplace($UnicodeBinary, '0x', '', 1)
    $UnicodeBinaryLength = StringLen($UnicodeBinary2)

    For $i = 1 To $UnicodeBinaryLength Step 2
        $UnicodeBinaryChar = StringMid($UnicodeBinary2, $i, 2)
		; 기존 코드에서 모든 특수문자를 encoding 하도록 수정
        ;If StringInStr("$-_.+!*'(),;/?:@=&abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890", BinaryToString ('0x' & $UnicodeBinaryChar, 4)) Then
		If StringInStr("1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz", BinaryToString ('0x' & $UnicodeBinaryChar, 4)) Then
            $EncodedString &= BinaryToString ('0x' & $UnicodeBinaryChar)
        Else
            $EncodedString &= '%' & $UnicodeBinaryChar
        EndIf
    Next

	seterror(0)
    Return $EncodedString

EndFunc   ;==>_UnicodeURLEncode


Func _UnicodeURLDecode($toDecode, $bANSI = False)

    Local $sContents = "", $iCharCount
    Local $aryHex = StringSplit($toDecode, "")
	local $iIndex
	local $iDecodeType
	local $sByte

	$iIndex = 1

	if $bANSI then
		$iDecodeType = 1
		$iCharCount = 2
	else
		$iDecodeType = 4
		$iCharCount = 3
	endif

	while $iIndex <= ubound($aryHex) -1

		$sByte = _ArrayGetByte($aryHex, $iIndex, 1)

		If $sByte = "%" Then

			$sByte = _ArrayGetByte($aryHex, $iIndex, 2)

			;_debug("read : " & $sByte , $iIndex )

			if dec($sByte) > 127 then

				for $j=1 to $iCharCount -1
					_ArrayGetByte( $aryHex, $iIndex, 1)
					$sByte &= _ArrayGetByte( $aryHex, $iIndex, 2)
				next

				;_debug("read : " & $sByte , $iIndex )

				$sByte = BinaryToString(Binary("0x" & $sByte ), $iDecodeType)

				$sContents = $sContents & $sByte

			Else
				$sContents = $sContents & chr(dec($sByte))
			EndIf

		Else
			$sContents = $sContents & $sByte
		endif
	wend

    Return $sContents

EndFunc   ;==>_UnicodeURLDecode

;_debug(_UnicodeURLDecode("%EB%82%98%EB%8A%94%20%EA%B0%80%EC%88%98%EB%8B%A4"))

Func _ANSIURLEncode($UnicodeURL)

	Return  _UnicodeURLEncode($UnicodeURL, True)

EndFunc


Func _ANSIURLDecode($UnicodeURL)

	Return  _UnicodeURLDecode($UnicodeURL, True)

EndFunc

func _ArrayGetByte(byref $aArray, byref $iIndex, $iCount)

	local $iMaxBound, $i
	local $ret = ""

	$iMaxBound = ubound($aArray) -1

	for $i=1 to $iCount

		if $iMaxBound < $iIndex Then exitloop

		$ret &= $aArray[$iIndex]

		$iIndex += 1
	next

	return $ret

endfunc

Func _IEGetCookies ( $_Url )

	local $sCookies
    local $oIE = ObjCreate ( 'InternetExplorer.Application' )

    If Not IsObj ( $oIE ) Then Return SetError ( 1, 0, 0 )
    $oIE.Visible = 0
    $oIE.Navigate ( $_Url )
    Do
        Sleep ( 100 )
    Until Not $oIE.Busy
    $sCookies = $oIE.document.cookie
    $oIE.quit

    Return $sCookies

EndFunc ;==> _IEGetCookies ( )