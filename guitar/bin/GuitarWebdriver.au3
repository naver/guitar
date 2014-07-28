#include-once
#include ".\_include_nhn\_util.au3"
#include ".\_include_nhn\_webdriver.au3"

global $_WebdriverSearchTypeInfo [6][3]
global $_WebdriverSubFramePath = ""
global $_WebdriverMobileLastDragX = ""
global $_WebdriverMobileLastDragY = ""

$_WebdriverSearchTypeInfo[1][1]= "class"
$_WebdriverSearchTypeInfo[1][2]= "class name"

$_WebdriverSearchTypeInfo[2][1]= "css"
$_WebdriverSearchTypeInfo[2][2]= "css selector"

$_WebdriverSearchTypeInfo[3][1]= "id"
$_WebdriverSearchTypeInfo[3][2]= "id"

$_WebdriverSearchTypeInfo[4][1]= "name"
$_WebdriverSearchTypeInfo[4][2]= "name"

$_WebdriverSearchTypeInfo[5][1]= "xpath"
$_WebdriverSearchTypeInfo[5][2]= "xpath"


;local $a, $b
;local $x="   {css ,    123   456 }   "
;debug(getWebdriverParamTypeAndValue ($x, $a, $b))
;debug($a, $b)


; webdriver 형태 확인
func isWebdriverParam ($sStr)

	$sStr = _Trim($sStr)

	return _iif( stringLeft($sStr,1)= "{" and StringRight($sStr,1)= "}", True,False)

endfunc

func getWebdriverParam ($sStr)

	return _Trim(stringmid($sStr,2,stringlen($sStr)-2))

endfunc


; webdriver 검색 타입과, 대상 정보 추출
func getWebdriverParamTypeAndValue ($sStr, byref $sSearchType, byref $sSearchValue)

	local $i
	local $bSuccess = False
	local $sSearchTypeKey
	local $sSearchTypeIndex
	local $iSplitPos

	$sStr = _Trim($sStr)
	$sSearchType = ""
	$sSearchValue = ""

	if isWebdriverParam ($sStr) then
		$sStr = stringmid($sStr,2,stringlen($sStr)-2)
		$iSplitPos = StringInStr($sStr,":")

		if $iSplitPos > 0 then

			$bSuccess = True

			$sSearchTypeKey = StringLower(_Trim(Stringleft ($sStr, $iSplitPos -1)))
			$sSearchTypeIndex =  _ArraySearch($_WebdriverSearchTypeInfo,$sSearchTypeKey,0,0,0,0,1,1)


			$sSearchValue = StringStripWS(Stringmid ($sStr, $iSplitPos + 1, stringlen($sStr) - $iSplitPos + 1), $STR_STRIPLEADING)

			if $sSearchTypeIndex > 0 Then
				$sSearchType = $_WebdriverSearchTypeInfo[$sSearchTypeIndex][2]
			Else
				$sSearchType = $sSearchTypeKey
			endif
		endif

	endif

	return $bSuccess

endfunc


; 생성 관련 파라메터 정보 추출 및 커넥션 문자열 만들기\

;local $a, $b, $c
;debug(setWebdriverConnectionInfo("{host=172.165.22.22:1711,xxxx=c:\sss,yyty=111}",$a, $b))
;debug($a)
;debug($b)

func getWebdriverConnectionInfo($sParam, byref $sHost, byref $aParamInfo)

	local $bSuccess = True
	local $sConnectionInfo  = ""
	local $aDumyParamInfo[1][3]
	local $aMainParamInfo
	local $aSubParamInfo

	$aParamInfo = $aDumyParamInfo

	if isWebdriverParam($sParam)  then

		$sParam = _Trim(stringmid($sParam,2,stringlen($sParam)-2))
		$aMainParamInfo = StringSplit($sParam,",",1)

		redim $aParamInfo[ubound($aMainParamInfo,1) -1][3]

		for $i=1 to ubound ($aMainParamInfo) -1

			$aSubParamInfo = StringSplit($aMainParamInfo[$i],"=",1)
			; xxx=yyy 형태가 아닌 경우 바로 종료

			if ubound($aSubParamInfo) <> 3 then
				$bSuccess =False
				exitloop
			endif

			; 첫번째로 "host" 정보가 제공되어야 함.
			if $i=1 then
				if _Trim($aSubParamInfo[1]) = "host" Then
					$sHost = _Trim($aSubParamInfo[2])
				Else
					$bSuccess =False
					exitloop
				endif
			else
				$aParamInfo [$i-1][1] = _Trim($aSubParamInfo[1])

				$aParamInfo [$i-1][2] = _Trim($aSubParamInfo[2])

				; T/F 인 경우 해당 인자로 전달
				if StringLower($aParamInfo [$i-1][2]) = "true" then $aParamInfo [$i-1][2] = True
				if StringLower($aParamInfo [$i-1][2]) = "false" then $aParamInfo [$i-1][2] = False

			endif

		next

	endif

	return $bSuccess

endfunc


func _WD_getBrowserType()

	local $sbrowserType

	Switch StringLower(_Trim(_WD_getBrowserName()))
		case "chrome","firefox","internet explorer","ie","safari"
			$sbrowserType = "WEB"
	EndSwitch

	return $sbrowserType

endfunc


func _WD_getBrowserName()

	local $i, $j
	local $aSessions
	local $aSession
	local $acapabilities
	local $iSessionIndex = -1
	local $icapabilitiesIndex = -1
	local $sbrowserName
	local $sRet = ""
	local $sSessionID

	$sSessionID = $_webdriver_current_sessionid

	if _WD_get_sessions ($sRet) then
		;_jdebug($sRet)
		$aSessions = _jsonquery($sRet, "value")
		;$aSessions = $sRet

		;debug($aSessions)

		for $i=0 to ubound($aSessions) -1

			$aSession = $aSessions[$i]
			;debug($aSession)

			for $j=0 to ubound($aSession) -1
				;debug($aSession[$j][0],$aSession[$j][1] ,$sSessionID)
				if $aSession[$j][0] = "id" and $aSession[$j][1] = $sSessionID then
					$iSessionIndex = $i
				endif
				if $aSession[$j][0] = "capabilities" then $icapabilitiesIndex = $j
			next

			if $iSessionIndex > -1 then
				;_msg("왔어")
				$acapabilities = $aSession[$icapabilitiesIndex][1]

				for $j=0 to ubound($acapabilities) -1

					if $acapabilities[$j][0] = "browserName" then

						$sbrowserName = $acapabilities[$j][1]
						exitloop
					endif
				next
			endif

		next

	endif

	return $sbrowserName

endfunc

func _WD_MoveAndAction($sElementID, $sActionCommand, $Button = 0, $iOffsetX=0, $iOffsetY=0)

	local $bSuccess = False
	local $sRet = ""
	local $ElementX, $ElementY, $x, $y
	local $x, $y
	local $i
	local $iClickCount = 1
	local $sMobileCommand
	local $sBodyID

	$bSuccess = False

	;$iOffsetX = String($iOffsetX)
	;$iOffsetY = String($iOffsetY)


	if _WD_isTestPlatformWEB() then
		;웹 형태의 경우

		Switch $sActionCommand

			case "/moveto", "/click", "/buttondown", "/buttonup", "/doubleclick"


				if $sElementID <> "" then
					; TAG 형태로 찾아서 클릭
					; 플랫폼이 웹인 경우에만 이동후 클릭하도록
					$bSuccess = _getWebdriverParam("POST", "/moveto", $sRet, 'element', $sElementID,"xoffset",$iOffsetX,"yoffset", $iOffsety)

				else
					; 이미지 타입으로 찾아서 클릭
					$sBodyID = _WD_find_element_by("xpath", "//body")
					$bSuccess = _getWebdriverParam("POST", "/moveto" , $sRet, "element",$sBodyID, "xoffset", $iOffsetX, "yoffset" , $iOffsety)
				endif

				if $bSuccess and $sActionCommand <> "/moveto" then
					if $sElementID <> "" then $_webdriver_last_elementid = $sElementID
					sleep(1)
					;msg($sActionCommand)
					$bSuccess = _getWebdriverParam("POST", $sActionCommand, $sRet, 'button', $Button)
				endif

			case Else
				$_webdriver_last_errormsg = "Webdriver에서 지원하지 않는 명령입니다." & $sActionCommand
				$bSuccess = False

		EndSwitch

	else

		$_webdriver_last_elementid = $sElementID

		$bSuccess = _WD_get_element_location($sElementID,  $ElementX,  $ElementY)

		$x = $ElementX +  $iOffsetX
		$y = $ElementY +  $iOffsetY

		Switch $sActionCommand


			; "/longClick" 서버 사이드 오류 발생
			case  "/click", "/doubleclick"

				if $sActionCommand = "/doubleclick" then $iClickCount = 2

				;$bSuccess = _getWebdriverParam("POST", "/touch/tap" , $sRet, "element",  $sElementID, "touchCount", _iif($sActionCommand="/click","1","2"))
				;$bSuccess =_WD_execute_script ("mobile: tap", $sRet, "element",  $sElementID, "touchCount", _iif($sActionCommand="/click","1","2"))
				;$bSuccess = _getWebdriverParam("POST", "/execute" , $sRet, "script", "mobile: tap", "args", _JSONEncode(_JSONArray(_JSONObject("touchCount","2"))))
				;$bSuccess = requestWebdriver("POST","session/" & $_webdriver_current_sessionid & "/execute", _JSONEncode(_JSONObject("script", "mobile: tap","args",_JSONArray(_JSONObject("touchCount","2", "element",$sElementID)))), $sRet)
				;$bSuccess = requestWebdriver("POST","session/" & $_webdriver_current_sessionid & "/touch/tap", _JSONEncode(_JSONObject("element",number($sElementID) )), $sRet)
				;$bSuccess = requestWebdriver("POST","session/" & $_webdriver_current_sessionid & "/touch/cliock", _JSONEncode(_JSONObject("element",$sElementID )), $sRet)


				; Appium 용
				;for $i=1 to $iClickCount
				;	$bSuccess = requestWebdriver("POST","session/" & $_webdriver_current_sessionid & "/execute", _JSONEncode(_JSONObject("script", "mobile: tap" ,"args",_JSONArray(_JSONObject("x",$x , "y",$y ,"touchCount","1")))), $sRet)
				;next

				;Not yet implemented
				;$bSuccess = requestWebdriver("POST","session/" & $_webdriver_current_sessionid & "/touch/down", _JSONEncode(_JSONObject("x",$x,"y",$y )), $sRet)

				;Not yet implemented
				;$bSuccess = requestWebdriver("POST","session/" & $_webdriver_current_sessionid & "/buttondown", _JSONEncode(_JSONObject("x",$x,"y",$y )), $sRet)

				; Webdriver 기본
				$bSuccess = _getWebdriverParam("POST", "/element/" & $sElementID &  $sActionCommand, $sRet)

			case "/buttondown"
				$_WebdriverMobileLastDragX = $x
				$_WebdriverMobileLastDragY = $y
				$bSuccess = True

			case "/buttonup"
				$bSuccess = requestWebdriver("POST","session/" & $_webdriver_current_sessionid & "/execute", _JSONEncode(_JSONObject("script", "mobile: swipe","args",_JSONArray(_JSONObject("startX",$_WebdriverMobileLastDragX , "startY",$_WebdriverMobileLastDragY, "endX",$x , "endY",$y, "duration","1.8" )))), $sRet)
				$_WebdriverMobileLastDragX = ""
				$_WebdriverMobileLastDragY = ""

			case Else
				$_webdriver_last_errormsg = "Webdriver(Mobile)에서 지원하지 않는 명령입니다." & $sActionCommand
		EndSwitch

	endif

	return $bSuccess

EndFunc



func _WD_get_windowhandles()

	local $sRet
	local $aWindowHandles [1]

	if _getWebdriverParam("GET", "/window_handles" , $sRet) then
		$aWindowHandles = (_jsonquery($sRet, "value"))
	endif

	return $aWindowHandles

endfunc


func _WD_find_element_with_highlight_by($sUsing, $sSearchTarget, $bhighlight, $iDelay)

	local $sRet
	local $sID
	local $i
	local $aCurrentFrames

	$iDelay = Number($iDelay)

	if  _WD_isTestPlatformWEB() = True  then
		;debug ("프레임위치 : " & $_WebdriverSubFramePath)
		; 이전에 하위 프레임에 위치할 경우 메인으로 이동함
		if $_WebdriverSubFramePath <> "" then _WD_focus_frame($_JSONNull)
	endif

	$sID = _WD_find_element_by($sUsing, $sSearchTarget)

	; 메인화면에 없을 경우 하위 프레임을 검색함.
	if $sID = "" and  _WD_isTestPlatformWEB() = True Then

		; 전체 프레임 정보를 읽어옴
		do
		until _WD_get_allframes($aCurrentFrames)

		for $i=2 to ubound($aCurrentFrames) -1
			if _WD_go_frame($aCurrentFrames[$i][1]) = True then
				$_WebdriverSubFramePath = $aCurrentFrames[$i][1]
				$sID = _WD_find_element_by($sUsing, $sSearchTarget)
				if $sID <> "" then
					ExitLoop
				endif
			endif
		next

	endif

	if $sID <> "" then $_webdriver_last_elementid = $sID

	; 플랫폼이 웹일경우에만
	if $bhighlight and $sID <> "" and _WD_isTestPlatformWEB() = True  and ($iDelay > 0)  then
		_WD_execute_script ("arguments[0].setAttribute('style', 'color: yellow; border: 2px solid red;')",$sRet, _JSONObject("ELEMENT",$sID))
 		sleep($iDelay)
		_WD_execute_script ("arguments[0].setAttribute('style', '')",$sRet, _JSONObject("ELEMENT",$sID))
		sleep($iDelay)
	endif

	return $sID

endfunc


func _WD_get_allframes(byref $aAllFrames)
	; 2차원 배열로 현재의 모든 하위 프레임 정보를 읽어옴

	local $i, $j
	local $aTemp[2][3]
	local $bAllSearch = True
	local $iAllFramesUbound
	local $iAllFrameNewIndex
	local $aFrames
	local $aTemp

	; 최초 신입시
	if IsArray($aAllFrames) = False then
		$aAllFrames = $aTemp
		$aAllFrames[1][1] = "X"
	endif

	$iAllFramesUbound = ubound($aAllFrames,1)
	;debug("기존 : " & $iAllFramesUbound)
	for $i=1 to $iAllFramesUbound - 1
		; 방문 기록이 없으면 방문하여 신규 하위 frame을 추가
		if $aAllFrames[$i][2] = "" then
			$bAllSearch = False
			$aAllFrames[$i][2] = "S"
			if _WD_go_frame($aAllFrames[$i][1]) then
				$aFrames = _WD_find_elements_by("tag name", "iframe")
				;debug("신규추가 : " & ubound($aFrames,1))
				if ubound($aFrames,1) >  0 then
					;_msg("신규추가21 : " & ubound($aFrames,1))
					redim $aAllFrames[$iAllFramesUbound + ubound($aFrames,1)][3]
					;debug (ubound($aAllFrames,1))
					;msg($aFrames)
					;msg("신규추가22 : " & ubound($aFrames,1))
					;msg($aFrames)
					for $j=1 to ubound($aFrames,1)
						;debug("신규추가3: " & ubound($aFrames,1))
						;debug("증가:" &  ubound($aFrames,1) -1)
						$iAllFrameNewIndex = ($iAllFramesUbound -1) + $j
						$aTemp = $aFrames[$j-1]
						;_msg($aTemp)
						;debug ("추가:" & $iAllFrameNewIndex)
						$aAllFrames [$iAllFrameNewIndex][1] = $aAllFrames[$i][1] & "-" & $aTemp[1][1]
					next
				endif
			endif
		endif
	next

	return $bAllSearch

endfunc


func _WD_go_frame($sFrameID)

	; "0-11-22" 형태의 문자열 프레임 구조를 분석하여 해당 프레임으로 이동
	local $aID = StringSplit($sFrameID,"-")
	local $i
	local $bSuccess

	;debug("이동: " & $sFrameID)

	for $i=1 to ubound($aID,1)-1

		if $i=1 then
			$bSuccess = _WD_focus_frame($_JSONNull)
		else
			$bSuccess = _WD_focus_frame(_JSONObject("ELEMENT",$aID[$i]))
		endif

		if $bSuccess = False then ExitLoop
	next

	return $bSuccess

endfunc


func _WD_isTestPlatformWEB()

	if $_webdriver_testplatform = "" then $_webdriver_testplatform = _WD_getBrowserType()

	;_msg($_webdriver_testplatform)

	return _iif($_webdriver_testplatform = "WEB",True, False)

endfunc
