;#include-once
#include ".\_include_nhn\_util.au3"
#include ".\_include_nhn\_json.au3"

;local $t= FileRead("c:\2014-03-27_18-26-29_res.txt")
;local $t= FileRead("c:\2.txt")
;_makeJsonCache ($t)
;_debug(_jsonquery ($t,"value"))


func _makeJsonCache (byref $sJson)

	; 짧은 인자로 변환, 원본 값과, 짧은 정보를 갖고 있는 배열을 리턴

	local $_JSONCACHE[1][3]
	const $_JSONSP = "__JSONSP__"

	local $sShortJson
	redim $_JSONCACHE[1][3]
	local $i, $iCurrentIndex, $iStartIndex, $iEndIndex, $iJsonCacheUbound
	const $iMaxSize = 2000

	$sShortJson = $sJson

	; 최초 값
	$iEndIndex = 1
	$iStartIndex = StringInStr($sShortJson,'"',0,1,$iEndIndex)

	;debug("$sShortJson " & $sShortJson)

	While ($iStartIndex > 0)

		$iEndIndex = StringInStr($sShortJson,'"',0,1,$iStartIndex + 1)
		;debug("$iEndIndex 1 " & $iEndIndex)
		;debug("$iStartIndex : " & $iStartIndex)

		; 끝이 없을 경우 마지막으로
		if $iEndIndex = 0 then $iEndIndex = Stringlen($sShortJson)

		; 특정 글자 이상인 경우 치환
		if ($iEndIndex - $iStartIndex > $iMaxSize) then
			;debug("왔어"			)
			;특정 문자열을 잘라서 해당 배열로 신규 추가
			$iJsonCacheUbound = ubound($_JSONCACHE,1)
			redim $_JSONCACHE[$iJsonCacheUbound + 1][3]

			$_JSONCACHE[$iJsonCacheUbound][1] = $_JSONSP & $iJsonCacheUbound & $_JSONSP
			$_JSONCACHE[$iJsonCacheUbound][2] = stringmid($sShortJson, $iStartIndex + 1, $iEndIndex - $iStartIndex -1)

			;기존 문자열을 약어로 대체
			$sShortJson = stringleft ($sShortJson , $iStartIndex) & $_JSONCACHE[$iJsonCacheUbound][1] & StringRight ($sShortJson  , stringlen($sShortJson) - $iEndIndex + 1)
			;debug("$sShortJson " & $sShortJson)
			$iEndIndex = $iStartIndex + stringlen ($_JSONCACHE[$iJsonCacheUbound][1]) + 1

			;debug ("len " & stringlen ($_JSONCACHE[$iJsonCacheUbound][1] + 1))
			;debug("$_JSONCACHE " )
			;debug($_JSONCACHE)

			;debug($sShortJson)

		endif

		;debug("$iEndIndex 2 " & $iEndIndex)
		$iStartIndex = StringInStr($sShortJson,'"',0,1,$iEndIndex + 1)

		;debug("$iStartIndex " & $iStartIndex)

	Wend

	$sJson = $sShortJson
	return $_JSONCACHE

endfunc



func _jdebug($sjson)

	; 긴 문자열을 줄이기 위해

	_makeJsonCache ($sjson)
	_debug (_JSONEncode(_JSONDecode($sjson),default,"    "))

endfunc



func _jsonquery(byref $sjson, $sPathName)
;debug(_jquery($t, "desiredCapabilities\platform"))

	;debug(_GetLogDateTime() & " 파싱 최초")
	local $i
	local $j
	local $oDecode
	local $aPathArray
	local $aNewPathArray
	local $aInnerPathArray
	local $aPathName = StringSplit($sPathName,"\")
	local $aRet = ""
	local $iNewIndex =-1
	local $aJsonCache
	local $iJsonCacheSeachIndex = 0
	local $sTest

	$oDecode = $sjson
	$aJsonCache = _makeJsonCache ($oDecode)
	$oDecode = _JSONDecode($oDecode)

	$aNewPathArray = $oDecode

	;debug(_GetLogDateTime() & " 파싱 시작")

	for $i=1 to ubound($aPathName)-1

		$aPathArray = $aNewPathArray

		if ubound($aPathArray,2) = 0 then
			; 1
			for $j=0 to ubound($aPathArray,1) -1
				;debug(ubound($aPathArray,2), $j)
				;msg($aPathArray)
				$aInnerPathArray = $aPathArray[$j]
				;_msg($aInnerPathArray)
				$iNewIndex = _jsonqueryinnersearch($aInnerPathArray , $aPathName[$i])
				if $iNewIndex <> -1 then
					$aNewPathArray = $aInnerPathArray [$iNewIndex][1]
					exitloop
				endif
			next

		else
			; 2

			$iNewIndex = _jsonqueryinnersearch($aPathArray, $aPathName[$i])
			if $iNewIndex = -1 then exitloop
			;msg ($aPathArray)
			$aNewPathArray = $aPathArray [$iNewIndex][1]

		endif

	Next

	if $iNewIndex <> -1  then
		$aRet = $aNewPathArray
		if $aRet = $_JSONNull then $aRet = ""
	endif

	SetError (1)

	; 캐쉬에서 꺼내 오기
	$iJsonCacheSeachIndex =  _ArraySearch($aJsonCache,$aRet,0,0,0,0,1,1)
	if $iJsonCacheSeachIndex > 0 then $aRet = $aJsonCache[$iJsonCacheSeachIndex][2]

	return $aRet

endfunc



func _jsonqueryinnersearch(byref $aPathArray, $sSearchKey)

	return _ArraySearch($aPathArray,$sSearchKey,0,0,0,0,1,0)

endfunc
