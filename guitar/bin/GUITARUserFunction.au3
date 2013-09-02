#include-once
#include ".\_include_nhn\_util.au3"
#Include <Array.au3>

global $_kor_initial[30] = ["ㄱ", "ㄲ", "ㄴ", "ㄷ", "ㄸ", "ㄹ", "ㅁ", "ㅂ", "ㅃ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅉ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"]
global $_kor_medial[30] = ["ㅏ", "ㅐ", "ㅑ", "ㅒ", "ㅓ", "ㅔ", "ㅕ", "ㅖ", "ㅗ", "ㅘ", "ㅙ", "ㅚ", "ㅛ", "ㅜ", "ㅝ", "ㅞ", "ㅟ", "ㅠ", "ㅡ", "ㅢ", "ㅣ"]
global $_kor_final[30] = ["", "ㄱ", "ㄲ", "ㄳ", "ㄴ", "ㄵ", "ㄶ", "ㄷ", "ㄹ", "ㄺ", "ㄻ", "ㄼ", "ㄽ", "ㄾ", "ㄿ", "ㅀ", "ㅁ", "ㅂ", "ㅄ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"]


; 메일 발송 ini 정보를 참조하여 발송됨
func _SendMail($sFrom, $sToEmail, $sTitle, $sBody,  $AttachFiles = "", $bIsUseCID = False)

	local $SmtpServer = getReadINI("EMAIL","SMTPServer")
	local $IPPort = getReadINI("EMAIL","Port")
	local $Username = getReadINI("EMAIL","ID")
	local $Password = getReadINI("EMAIL","Password")
	local $FromAddress = getReadINI("EMAIL","EmailAddress")

	return _SendNaverMail($sFrom, $sToEmail, $sTitle, $sBody, $AttachFiles, $bIsUseCID, $SmtpServer , $FromAddress , $Username , $Password, $IPPort)

endfunc


;_debug(_SplitKoreanChar("딹 abc 한글"))
; 한글 자소 분리

func _SplitKoreanChar($sText, $bArrayType = False)
	return SplitKoreanDetail(SplitKorean($sText,True), $bArrayType)
endfunc

func SplitKorean($sText, $bArrayType = False)

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

	if $bArrayType then
		return $aRet
	else
		return _ArrayToString($aRet,"")

	endif

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

	if $bArrayType = False then $aRet = _ArrayToString($aRet,"",1,0)

	return $aRet

endfunc
