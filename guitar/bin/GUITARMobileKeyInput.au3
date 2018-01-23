#include ".\_include_nhn\_util.au3"
#include <Constants.au3>
#Include <Array.au3>
#include <Math.au3>

global $_kor_initial[30] = ["ㄱ", "ㄲ", "ㄴ", "ㄷ", "ㄸ", "ㄹ", "ㅁ", "ㅂ", "ㅃ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅉ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"]
global $_kor_medial[30] = ["ㅏ", "ㅐ", "ㅑ", "ㅒ", "ㅓ", "ㅔ", "ㅕ", "ㅖ", "ㅗ", "ㅘ", "ㅙ", "ㅚ", "ㅛ", "ㅜ", "ㅝ", "ㅞ", "ㅟ", "ㅠ", "ㅡ", "ㅢ", "ㅣ"]
global $_kor_final[30] = ["", "ㄱ", "ㄲ", "ㄳ", "ㄴ", "ㄵ", "ㄶ", "ㄷ", "ㄹ", "ㄺ", "ㄻ", "ㄼ", "ㄽ", "ㄾ", "ㄿ", "ㅀ", "ㅁ", "ㅂ", "ㅄ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"]

SplitKoreanDetail("예절")

func _iOSKoreanInput($sText, $iOSVer = "4.x")

	local $sSplitKoreanChar = SplitKoreanDetail(SplitKorean($sText), True)
	local $iChar
	local $bKeysend
	local $sKeyData
	local $aKeyData
	local $i, $j, $j

	for $i= 1 to ubound($sSplitKoreanChar) -1

		if checkScriptStopping() then exitloop

		$iChar = ascw($sSplitKoreanChar[$i])

		if ($iChar >= 12593 and $iChar <= 12643) or $iChar = ascw(" ") then
			$bKeysend = False
			$sKeyData = iOSKoreanKeyPostion($sSplitKoreanChar[$i])
		else
			$bKeysend = True
			$sKeyData = $sSplitKoreanChar[$i]
		endif

		if $bKeysend then
			_debug("send : " & $sSplitKoreanChar[$i])
			commandKeySend($sSplitKoreanChar[$i],"ANSI")
			sleep(300)
		else
			$aKeyData= StringSplit ($sKeyData,"|")
			for $j=1 to ubound($aKeyData)-1
				_debug("mouse : " & $aKeyData[$j])
				sleep(300)
				commandLocationTab($aKeyData[$j], "left")
			next
		endif

	next

EndFunc


func iOSKoreanKeyPostion($sChar)

	local $sRet
	local $iOSKeyLayout
	local $aOSKeyLayout[1][15]
	local $sTempSplit1, $sTempSplit2

	local $i, $j, $k

	local $iCharAdd = 10

	; X, Y 각각 100% 비율료 계산됨
	local $iLineX[5] = [0,6,10,20,6]
	local $iLineY[5] = [0,62,73,84,95]
	local $x, $y

	;_debug($sChar)

	; 한
	$iOSKeyLayout = "ㅂ,ㅈ,ㄷ,ㄱ,ㅅ,ㅛ,ㅕ,ㅑ,ㅐㅒ,ㅔㅖ" & "|"
	$iOSKeyLayout &= "ㅁ,ㄴ,ㅇ,ㄹ,ㅎ,ㅗ,ㅓ,ㅏ,ㅣ" & "|"
	$iOSKeyLayout &= "ㅋ,ㅌ,ㅊ,ㅍ,ㅠ,ㅜ,ㅡ" & "|"
	$iOSKeyLayout &= ",,,, "

	; 영

	; 숫자

	; 특수

	$sTempSplit1 = StringSplit($iOSKeyLayout,"|")

	redim $aOSKeyLayout[ubound($sTempSplit1)][ubound($aOSKeyLayout,2)]

	; 2차원 배열로 글자배열
	for $i= 1 to ubound($sTempSplit1) -1
		$sTempSplit2 = StringSplit($sTempSplit1[$i],",")
		for $j= 1 to ubound($sTempSplit2) -1
			$aOSKeyLayout[$i][$j] = $sTempSplit2[$j]
		next
	next

	;_debug ($aOSKeyLayout)
	;_debug(ubound($aOSKeyLayout,1))
	; 2차원 배열 주소 확인
	for $i= 1 to ubound($aOSKeyLayout,1) -1
		for $j= 1 to ubound($aOSKeyLayout,2) -1
			if StringInStr($aOSKeyLayout[$i][$j], $sChar) <> 0 then
				if $sChar = "ㅒ" or $sChar = "ㅖ" then
					; Shift 키 추가
					$sRet = $iLineX[1] & "%," & $iLineY[3] & "%|"
					;_debug($sRet & "dddd")
				endif

				$x = $iLineX[$i] + (($j-1) * $iCharAdd)
				$y = $iLineY[$i]

				_debug($x, $y)

				$sRet &= $x & "%," & $y & "%"

				exitloop
			endif
		next
		if $sRet <> "" then exitloop
	next


	return $sRet

EndFunc


func SplitKorean($sText)

	local $aRet[1]
	local $i
	local $ki, $km, $kf
	local $iWordasc


	For $i = 1 To StringLen($sText)
		;한글일경우에만 분리
		$iWordasc  = ascw(stringMid($sText, $i, 1))

		If $iWordasc >= dec("AC00") And $iWordasc <= dec("D7A3") Then

			$kf = ascw(stringMid($sText, $i, 1)) - ascw("가")
			$ki = Int($kf / (21*28))
			$kf = mod ($kf ,21*28)
			$km = Int($kf / 28)
			$kf = mod($kf, 28)

			;_debug($ki, $km, $kf)
			;_debug( $_kor_initial[$ki] & $_kor_medial[$km] & $_kor_final[$kf])
			_ArrayAdd ($aRet, $_kor_initial[$ki])
			_ArrayAdd ($aRet, $_kor_medial[$km])

			if $kf <> 0 then _ArrayAdd($aRet, $_kor_final[$kf])

		Else
			;한글이 아닐경우 그냥 출력
			;_debug (stringMid($sText, $i, 1))
			_ArrayAdd ($aRet, stringMid($sText, $i, 1))
		endif
	next



	return $aRet

endfunc


func SplitKoreanDetail($aText, $bArrayType = False)

	local $aRet[1]
	local $i
	local $iWordasc
	local $sNewChar1
	local $sNewChar2
	local $sNewChar3

	For $i = 1 To UBound($aText) -1

		$sNewChar1 = ""
		$sNewChar2 = ""
		$sNewChar3 = ""

		$iWordasc  = $aText[$i]

		switch  $iWordasc

			case "ㄲ"
				$sNewChar1 = "ㄱ"
				$sNewChar2 = "ㄱ"

			case "ㄸ"
				$sNewChar1 = "ㄷ"
				$sNewChar2 = "ㄷ"

			case "ㅃ"
				$sNewChar1 = "ㅂ"
				$sNewChar2 = "ㅂ"

			case "ㅆ"
				$sNewChar1 = "ㅅ"
				$sNewChar2 = "ㅅ"

			case "ㅉ"
				$sNewChar1 = "ㅈ"
				$sNewChar2 = "ㅈ"

			case "ㅘ"
				$sNewChar1 = "ㅗ"
				$sNewChar2 = "ㅏ"

			case "ㅙ"
				$sNewChar1 = "ㅗ"
				$sNewChar2 = "ㅐ"

			case "ㅚ"
				$sNewChar1 = "ㅗ"
				$sNewChar2 = "ㅣ"

			case "ㅝ"
				$sNewChar1 = "ㅜ"
				$sNewChar2 = "ㅓ"

			case "ㅞ"
				$sNewChar1 = "ㅜ"
				$sNewChar2 = "ㅔ"

			case "ㅟ"
				$sNewChar1 = "ㅜ"
				$sNewChar2 = "ㅣ"

			case "ㅢ"
				$sNewChar1 = "ㅡ"
				$sNewChar2 = "ㅣ"

			case "ㄳ"
				$sNewChar1 = "ㄱ"
				$sNewChar2 = "ㅅ"

			case "ㄵ"
				$sNewChar1 = "ㄴ"
				$sNewChar2 = "ㅈ"

			case "ㄶ"
				$sNewChar1 = "ㄴ"
				$sNewChar2 = "ㅎ"

			case "ㄺ"
				$sNewChar1 = "ㄹ"
				$sNewChar2 = "ㄱ"

			case "ㄻ"
				$sNewChar1 = "ㄹ"
				$sNewChar2 = "ㅁ"

			case "ㄼ"
				$sNewChar1 = "ㄹ"
				$sNewChar2 = "ㅁ"

			case "ㄽ"
				$sNewChar1 = "ㄹ"
				$sNewChar2 = "ㅅ"

			case "ㄾ"
				$sNewChar1 = "ㄹ"
				$sNewChar2 = "ㅌ"

			case "ㄿ"
				$sNewChar1 = "ㄹ"
				$sNewChar2 = "ㅍ"

			case "ㅀ"
				$sNewChar1 = "ㄹ"
				$sNewChar2 = "ㅎ"

			case "ㅄ"
				$sNewChar1 = "ㅂ"
				$sNewChar2 = "ㅅ"

			case else
				$sNewChar1 = $iWordasc

		EndSwitch

		if $sNewChar1 <> "" then _ArrayAdd ($aRet, $sNewChar1)
		if $sNewChar2 <> "" then _ArrayAdd ($aRet, $sNewChar2)
		if $sNewChar3 <> "" then _ArrayAdd ($aRet, $sNewChar3)

	next

	if $bArrayType = False then $aRet = _ArrayToString($aRet,"",1)

	return $aRet

endfunc
