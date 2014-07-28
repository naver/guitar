#include-once
#include ".\_include_nhn\_webdriver.au3"
#include "GuitarWebdriver.au3"


Local Enum $_EWXP_TYPE = 1, $_EWXP_VALUE

local $x

func _WD_XpathGetShotPathlist($sElementID, byref $aShotXpathList)

	local $i
	local $aParentElementAttribute = _WD_XpathGetSearchTemplate ()
	local $aMainElementAttribute = _WD_XpathGetSearchTemplate ()
	local $aParentElementAttribute
	local $aMainElementXpathList
	local $aParentElementXpathList [1]
	local $aMainElementXpathDeleteList [1]
	local $aParentElementXpathDeleteList
	local $sParentElementID
	local $sParentElementTagName

	local $sInfoMessage
	local $bSuccess  = False

	$aShotXpathList = $aMainElementXpathDeleteList

	if $sElementID = "" then

		$sInfoMessage = "지정된 Xpath 에 해당하는 정보를 찾을수 없습니다."

		return $sInfoMessage
	endif

	_WD_XpathGetElementAttribute($sElementID, $aMainElementAttribute, 0)
	_debug("현재 element 정보 " & $sElementID)
	_debug($aMainElementAttribute)


	; 속성 정보를 기반으로 기본 xptah 경로 생성
	$aMainElementXpathList = _WD_XpathMakeString($aMainElementAttribute, 0,  $aMainElementXpathDeleteList)
	_WD_XpathVerification($aMainElementXpathList, $aMainElementXpathDeleteList, $sElementID)


	; 단독 속성정보로 찾아지지 않는 경우
	;if ubound($aMainElementXpathList) = 1 then
		;_msg("더 찾으러")
		; 속정정보가 전혀 없을 경우 TAG 정보를 기본으로 추가함
		if ubound($aMainElementXpathDeleteList) = 1 then _ArrayAdd($aMainElementXpathDeleteList, "//" & $aMainElementAttribute[1][$_EWXP_VALUE])

		; 최대 10 회 까지 부모 조합으로 진행
		$sParentElementID = $sElementID

		for $i=1 to 3

			$sParentElementID = _WD_find_element_from ($sParentElementID, "xpath","..")

			if $sParentElementID <> "" then

				$aParentElementAttribute = _WD_XpathGetSearchTemplate ()

				_WD_XpathGetElementAttribute($sParentElementID, $aParentElementAttribute, $i)

				if $i=1 then $sParentElementTagName = $aParentElementAttribute[1][$_EWXP_VALUE]

				;_debug("부모 검색 : " & $sParentElementID)
				;_debug($aParentElementAttribute)

				$aParentElementXpathList  = _WD_XpathMakeString($aParentElementAttribute, $i, $aMainElementXpathDeleteList)

				;_msg("시작"  & $sParentElementID)
				;_msg($aParentElementXpathList)
				_WD_XpathVerification($aParentElementXpathList, $aParentElementXpathDeleteList, $sElementID)

				;_msg($aParentElementXpathList)

				if ubound($aParentElementXpathList) <> 1 then
					for $j=1 to ubound($aParentElementXpathList)-1
						_ArrayAdd($aMainElementXpathList, $aParentElementXpathList[$j])
					next
					exitloop
				endif

			endif

		next

	;endif


	$aShotXpathList = $aMainElementXpathList


	; 글자 크기로 소트함
	if ubound($aShotXpathList) > 1 then
		for $i=1 to ubound($aShotXpathList) -2
			for $j=2 to ubound($aShotXpathList) -1
				if stringlen($aShotXpathList[$i]) > stringlen($aShotXpathList[$j]) then _Swap($aShotXpathList[$i], $aShotXpathList[$j])
			next
		next
	endif


	if ubound($aShotXpathList) > 1 then $bSuccess = True

	return $bSuccess

	;msg($aMainElementXpathList)
	;_debug($aMainElementXpathList)
	;_msg($aMainElementXpathDeleteList)

endfunc


func  _WD_XpathParentVerification($sParentElementTagName,  $aXpathDeleteList, $sElementID)

	local $aElements
	local $i
	local $aCountElements
	local $aXpathAddList [1]
	local $aIDReturn
	local $sTestXpath

	for $i=1 to ubound($aXpathDeleteList) -1
		$sTestXpath = "//" & $sParentElementTagName & StringTrimLeft($aXpathDeleteList[$i],1)
		_debug($sTestXpath)
		$aElements = _WD_find_elements_by("xpath", $sTestXpath)
		_debug("검증 찾은 갯수 :  -- " & ubound($aElements))

		; 10개 이내이면 찾도록 함
		if ubound($aElements) > 0  and ubound($aElements) < 20 then

			for $j=1 to ubound($aElements) -1
				$sTestXpath ="//" & $sParentElementTagName & "[" & $j & "]" & StringTrimLeft($aXpathDeleteList[$i],0)
				$aCountElements = _WD_find_elements_by("xpath", $sTestXpath)
				_debug($sTestXpath & " " & ubound($aCountElements))
				if ubound($aCountElements) = 1 then
					; 값을 읽어서 원본 ID와  같은 경우에만 추가
					$aIDReturn = $aCountElements[0]
					$aIDReturn = $aIDReturn[1][1]
					_debug(" 찾은 ID " & $aIDReturn)
					if $aIDReturn = $sElementID then _ArrayAdd($aXpathAddList, $sTestXpath)
				else
					if ubound($aCountElements) > 0 then
						$aIDReturn = $aCountElements[0]
						_debug ($aIDReturn)
					endif
				endif
			next
		endif
	next

	return $aXpathAddList

endfunc

func  _WD_XpathVerification(byref $aXpathList, byref $aXpathDeleteList, $sElementID)

	local $aNewXpathList
	local $aXpathAddList
	local $aElements
	local $sTemp[1]
	local $sTemp[1]
	local $aIDReturn

	$aXpathDeleteList = $sTemp
	$aXpathAddList = $sTemp

	for $i=1 to ubound($aXpathList) - 1
		$aElements = _WD_find_elements_by("xpath", $aXpathList[$i])

		_debug("검증 찾은 갯수 : " & $aXpathList[$i] & "  -- " & ubound($aElements))
		if ubound($aElements) = 1 then
			; 값을 읽어서 원본 ID와  같은 경우에만 추가
			$aIDReturn = $aElements[0]
			$aIDReturn = $aIDReturn[1][1]

			if $aIDReturn = $sElementID then _ArrayAdd($aXpathAddList, $aXpathList[$i])

		else
			_ArrayAdd($aXpathDeleteList, $aXpathList[$i])
		endif
	next

	$aXpathList =  $aXpathAddList

	return $aXpathList

endfunc


func _WD_XpathMakeString($aElementAttribute, $iParentLevel, $aMainElementXpathDeleteList)
	; 1개 대상으로 가능한 모든 조합을 리턴

	local $i, $j
	local $sNewXpath
	local $aXPath[1]
	local $aParentXPath[1]
	local $aCopy = $aXPath



	for $i=2 to ubound($aElementAttribute) -1

		if  $aElementAttribute[$i][$_EWXP_VALUE] <> "" then
			$sNewXpath = ""

			switch $aElementAttribute[$i][$_EWXP_TYPE]

				case "text"
					; 부모 레벨에서 TEXT는 제외 (너무 많은 text가 검색에 사용됨)
					$sNewXpath = _WD_XpathMakeTextString ( $aElementAttribute[1][$_EWXP_VALUE], $aElementAttribute[$i][$_EWXP_VALUE])
				case else
					$sNewXpath = "//" & $aElementAttribute[1][$_EWXP_VALUE] & "[@" & $aElementAttribute[$i][$_EWXP_TYPE] & "='" & $aElementAttribute[$i][$_EWXP_VALUE] & "']"

			EndSwitch

			if $sNewXpath <> "" then _ArrayAdd($aXPath, $sNewXpath)

		endif

	next

	if $iParentLevel <> 0 then

		; 부모 기반으로 추가시 삭제된것과 조합하여 List 생성
		for $i=1 to ubound($aMainElementXpathDeleteList)-1
			for $j=1 to ubound($aXPath)-1
				$sNewXpath = $aXPath[$j] & StringTrimLeft($aMainElementXpathDeleteList[$i],_iif($iParentLevel=1,1,0))
				_ArrayAdd($aParentXPath, $sNewXpath)
			next
		next

		$aXpath = $aParentXPath

	endif

	return $aXpath

endfunc


func _WD_XpathMakeTextString ($aTagName, $sText)

	local $sXpathTextString
	local $iMaxTextLen = 10

	if stringlen($sText) > $iMaxTextLen then
		$sText = Stringleft($sText, $iMaxTextLen)
		$sXpathTextString = "//" & $aTagName & "[contains(.,'" & $sText & "')]"
	else
		$sXpathTextString = "//" & $aTagName & "[.='" & $sText & "']"
	endif

	return $sXpathTextString

endfunc


func _WD_XpathGetElementAttribute($sElementID, byref $aElementAttribute, $iParentLevel)

	local $i
	local $sVaule

	;_msg(_WD_get_element_tagname($sElementID))
	$aElementAttribute[1][$_EWXP_VALUE] = _WD_get_element_tagname($sElementID)

	for $i=2 to ubound($aElementAttribute) -1
		if  $aElementAttribute[$i][1] <> "" then
			; 부모 레벨 이상인 경우 text는 수집 제외
			if not ($iParentLevel > 0 and $aElementAttribute[$i][$_EWXP_TYPE] = "text") then
				if _WD_get_element_attribute($sElementID, $aElementAttribute[$i][1], $sVaule) then $aElementAttribute[$i][2] = $sVaule
			endif
		endif
	next

endfunc

func _WD_XpathGetSearchTemplate ()

	local $i=0
	local $aPriority [100][3]

	$i+=1
	$aPriority[$i][$_EWXP_TYPE] = "tag"
	$i+=1
	$aPriority[$i][$_EWXP_TYPE] = "class"
	$i+=1
	$aPriority[$i][$_EWXP_TYPE] = "id"
	$i+=1
	$aPriority[$i][$_EWXP_TYPE] = "name"
	$i+=1
	$aPriority[$i][$_EWXP_TYPE] = "title"
	$i+=1
	$aPriority[$i][$_EWXP_TYPE] = "alt"
	$i+=1
	$aPriority[$i][$_EWXP_TYPE] = "text"
	$i+=1
	$aPriority[$i][$_EWXP_TYPE] = "innertext"
	$i+=1
	$aPriority[$i][$_EWXP_TYPE] = "value"

	redim $aPriority [$i][3]

	return $aPriority

endfunc

