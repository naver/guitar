#include-once
#include <File.au3>
#include <array.au3>
#include ".\_include_nhn\_http.au3"
#include ".\_include_nhn\_util.au3"
#include ".\_include_nhn\_email.au3"
#include ".\_include_nhn\_json.au3"
#include ".\_include_nhn\_json_util.au3"

global const $_webdriver_timeout = 1000 * 60 * 3
global $_webdriver_current_sessionid
global $_webdriver_last_errormsg
global $_webdriver_last_elementid
global $_webdriver_connection_host
global $_webdriver_connection_param

func requestWebdriver($sType,$sCommand,$sParam, byref $sRet)

	local $sDebugTime = _GetLogDateTime()
	local $bSuccess = False
	local $sURLString
	local $isError = 0
	local $bHTTPError = 0
	local $bHTTPExtendErrorCode = 0

	$_webdriver_last_errormsg = ""

	$sURLString = "http://" & $_webdriver_connection_host & "/wd/hub/" & $sCommand

	_debug(_GetLogDateTime() & " COMMAND S, " & $sType & ", " & $sURLString & ", " & $sParam)

	$sRet = _WinhttpRequest($sURLString, $sType, $sParam, $_webdriver_timeout, 'Content-Type:application/json;charset=UTF-8')
	$bHTTPError = @error
	$bHTTPExtendErrorCode = @extended

	if $bHTTPError = 0 then

		if ($sRet = "") or (_Trim(_jsonquery($sRet, "status")) = "0") then $bSuccess = True

	endif

	;FileWrite(@ScriptDir & "\temp\" & $sDebugTime & "_req.txt", $sType & @crlf &  $_webdriver_connection_host & $sCommand & @crlf & $sParam)
	;FileWrite(@ScriptDir & "\temp\" & $sDebugTime & "_res.txt", $sRet)

	;_msg(stringlen($sRet))

	;_jdebug($sRet)


	if not($bSuccess) then

		local $iCRIndex

		if $bHTTPError = 0 then
			; 웹드라이버 오류

			$_webdriver_last_errormsg = _jsonquery($sRet, "value\message")
			if $_webdriver_last_errormsg = "" then $_webdriver_last_errormsg = _jsonquery($sRet, "value")
			$_webdriver_last_errormsg =  Stringreplace( $_webdriver_last_errormsg, @crlf , "\n")
			$_webdriver_last_errormsg =  Stringreplace( $_webdriver_last_errormsg, @cr , "\n")
			$_webdriver_last_errormsg =  Stringreplace( $_webdriver_last_errormsg, @lf , "\n")
			$iCRIndex =  StringInStr( $_webdriver_last_errormsg, "\n")

			if $iCRIndex <> 0 then  $_webdriver_last_errormsg = StringLeft( $_webdriver_last_errormsg, $iCRIndex -1)
		else
			; HTTP 오류
			$_webdriver_last_errormsg = "HTTP Error " & $bHTTPExtendErrorCode
		endif

		_debug("#### ERROR !!! : " &  $_webdriver_last_errormsg)

	endif

	_debug(_GetLogDateTime() & " COMMAND E, " &  $bSuccess)

	return $bSuccess

endfunc



;-----------------------------


func _WD_accept_alert()

	local $sRet

	return _getWebdriverParam("POST", "/accept_alert", $sRet)

endfunc

func _WD_dismiss_alert()

	local $sRet

	return _getWebdriverParam("POST", "/dismiss_alert", $sRet)

endfunc


func _WD_get_alert_text()

	local $sRet
	local $bSuccess = False


	if _getWebdriverParam("GET", "/alert_text", $sRet) then
		$sRet = _Trim(_jsonquery($sRet, "value"))
	else
		$sRet = ""
	endif

	return $sRet

endfunc

func _WD_set_windowsize($sSeeaion = $_webdriver_current_sessionid, $iwidth=0, $iheight=0)

	local $sRet
	local $bSuccess = False
	local $sCurrnetWindowHandle = _WD_current_window_handle()

	if $sCurrnetWindowHandle <> "" then
		$bSuccess = _getWebdriverParam("POST", "/window/" & $sCurrnetWindowHandle & "/size", $sRet, 'width', $iwidth,'height',$iheight)
	endif

	return $bSuccess

endfunc


func _WD_create_session ($sHost, $aParam)

	local $sRet
	local $bSuccess = False

	local $sConnectionInfo
	local $sParamInfo

	$_webdriver_connection_host = $sHost
	$_webdriver_connection_param = $aParam

	Switch ubound($aParam,1 )

		case 2

			$sParamInfo = _JSONObject( _
					$aParam[1][1], $aParam[1][2] _
				) _

		case 3

			$sParamInfo = _JSONObject( _
					$aParam[1][1], $aParam[1][2] , _
					$aParam[2][1], $aParam[2][2] _
				) _

		case 4

			$sParamInfo = _JSONObject( _
					$aParam[1][1], $aParam[1][2] , _
					$aParam[2][1], $aParam[2][2] , _
					$aParam[3][1], $aParam[3][2] _
				) _

		case 5

			$sParamInfo = _JSONObject( _
					$aParam[1][1], $aParam[1][2] , _
					$aParam[2][1], $aParam[2][2] , _
					$aParam[3][1], $aParam[3][2] , _
					$aParam[4][1], $aParam[4][2] _
				) _

		case 6

			$sParamInfo = _JSONObject( _
					$aParam[1][1], $aParam[1][2] , _
					$aParam[2][1], $aParam[2][2] , _
					$aParam[3][1], $aParam[3][2] , _
					$aParam[4][1], $aParam[4][2] , _
					$aParam[5][1], $aParam[5][2] _
				) _


		case 7

			$sParamInfo = _JSONObject( _
					$aParam[1][1], $aParam[1][2] , _
					$aParam[2][1], $aParam[2][2] , _
					$aParam[3][1], $aParam[3][2] , _
					$aParam[4][1], $aParam[4][2] , _
					$aParam[5][1], $aParam[5][2] , _
					$aParam[6][1], $aParam[6][2] _
				) _


		case 8

			$sParamInfo = _JSONObject( _
					$aParam[1][1], $aParam[1][2] , _
					$aParam[2][1], $aParam[2][2] , _
					$aParam[3][1], $aParam[3][2] , _
					$aParam[4][1], $aParam[4][2] , _
					$aParam[5][1], $aParam[5][2] , _
					$aParam[6][1], $aParam[6][2] , _
					$aParam[7][1], $aParam[7][2] _
				) _

		case 9

			$sParamInfo = _JSONObject( _
					$aParam[1][1], $aParam[1][2] , _
					$aParam[2][1], $aParam[2][2] , _
					$aParam[3][1], $aParam[3][2] , _
					$aParam[4][1], $aParam[4][2] , _
					$aParam[5][1], $aParam[5][2] , _
					$aParam[6][1], $aParam[6][2] , _
					$aParam[7][1], $aParam[7][2] , _
					$aParam[8][1], $aParam[8][2] _
				) _

		case 10

			$sParamInfo = _JSONObject( _
					$aParam[1][1], $aParam[1][2] , _
					$aParam[2][1], $aParam[2][2] , _
					$aParam[3][1], $aParam[3][2] , _
					$aParam[4][1], $aParam[4][2] , _
					$aParam[5][1], $aParam[5][2] , _
					$aParam[6][1], $aParam[6][2] , _
					$aParam[7][1], $aParam[7][2] , _
					$aParam[8][1], $aParam[9][2] , _
					$aParam[9][1], $aParam[0][2] _
				) _

	EndSwitch

	$sConnectionInfo = _JSONEncode( _JSONObject('desiredCapabilities', $sParamInfo))

;~ 	$sDrivertype = $_webdriver_type_appium then
;~ 	$sConnectionInfo = _JSONEncode( _
;~ 		_JSONObject('desiredCapabilities', _
;~ 			_JSONObject( _
;~ 				'app-activity','.ApiDemos', _
;~ 				'browserName','', _
;~ 				'app','E:\winapp\Appium\apk\apiDemos.apk', _
;~ 				'app-package','com.example.android.apis', _
;~ 				'device','Android', _
;~ 				'newCommandTimeout','6000', _
;~ 				'version','4.2' _
;~ 			) , 'sessionId',$_JSONNull _
;~ 		) _
;~ 	)

	if requestWebdriver("POST","session",$sConnectionInfo, $sRet) then
		;msg($sRet)
		$_webdriver_current_sessionid = _jsonquery($sRet, "sessionid")
		if $_webdriver_current_sessionid <> "" then $bSuccess = True
	endif

	return $bSuccess

EndFunc


func _WD_get_sessions()

	;http://code.google.com/p/selenium/wiki/JsonWireProtocol#/sessions
	; 현재 연결된 최신 ID값을 리턴

	local $sRet
	local $sSessions

	if requestWebdriver("GET","sessions","", $sRet) then
		$sRet = _Trim(_jsonquery($sRet, "value\id"))
	else
		$sRet = ""
	endif

	;debug($sRet)

	return $sRet
EndFunc


func _WD_get_session()

	local $sRet
	local $sSessionID

	if _getWebdriverParam("GET", "" , $sRet) then
		$sSessionID = _Trim(_jsonquery($sRet, "value\id"))
	endif

	return $sSessionID

EndFunc



func _WD_delete_session($sSessionID = $_webdriver_current_sessionid)

	local $sRet
	local $bSuccess

	$bSuccess = _getWebdriverParam("DELETE", "" , $sRet)
	$_webdriver_current_sessionid = ""

	return $bSuccess


EndFunc


func _WD_current_window_handle($sSeeaion = $_webdriver_current_sessionid)

	local $sRet
	local $bSuccess
	local $sCurrnetWindowHandle = ""

	;if requestWebdriver("GET", "session/" & $sSeeaion & "/window_handle" , "", $sRet) then $sCurrnetWindowHandle = _jsonquery($sRet, "value")
	if _getWebdriverParam("GET", "/window_handle" , $sRet) then $sCurrnetWindowHandle = _jsonquery($sRet, "value")

	return $sCurrnetWindowHandle

endfunc


func _WD_switch_to_windowhandle($sWindowHandleID)

	local $sRet

	return  _getWebdriverParam("POST", "/window" , $sRet, "name", $sWindowHandleID)

endfunc



func _WD_execute_script ($sScript, byref $sResult, $aParam1="", $aParam2="", $aParam3="", $aParam4="" , $aParam5="")

	local $sRet
	local $bSuccess

	$sResult = ""

	$bSuccess = _getWebdriverParam("POST", "/execute" , $sRet, "script", $sScript, "args", _JSONArray($aParam1, $aParam2, $aParam3, $aParam4, $aParam5))

	;_jdebug($sRet)

	$sResult = (_jsonquery($sRet, "value"))

	return $bSuccess

endfunc


func _WD_send_keys($sKeys)

	local $sRet
	local $bSuccess


	;$bSuccess = _getWebdriverParam("POST", "/keys" , $sRet, "value", $sKeys)

	; 항상 특수키를 초기화 함
	$sKeys = _WD_AU3KeyMapping ("\ue000" & $sKeys)

	; "\u" 문자열이 \\u로 변경되어 임의로 복원한뒤 전달함.
	$bSuccess = requestWebdriver("POST","session/" & $_webdriver_current_sessionid & "/keys", stringreplace(_JSONEncode(_JSONObject("value", _JSONArray($sKeys))),"\\u", "\u"), $sRet)
	;$bSuccess = requestWebdriver("POST","session/" & $_webdriver_current_sessionid & "/element/" & $_webdriver_last_elementid & "/value", stringreplace(_JSONEncode(_JSONObject("value", _JSONArray($sKeys, "\uE007"))),"\\u", "\u"), $sRet)

	return $bSuccess

endfunc

func _WD_back()

	local $sRet = ""

	return _getWebdriverParam("POST", "/back", $sRet)

endfunc


func _WD_close_window()

	local $sRet = ""

	return _getWebdriverParam("DELETE", "/window", $sRet)

endfunc


func _WD_forward()

	local $sRet = ""

	return _getWebdriverParam("POST", "/forward", $sRet)

endfunc


func _WD_get_screenshot_as_file($sSaveFile)

	local $sRet = ""
	local $sPngdata = ""
	local $bSuccess

	$bSuccess = _getWebdriverParam("GET", "/screenshot", $sRet)

	if $bSuccess then

		$sPngdata = (_jsonquery($sRet, "value"))

		if FileExists($sSaveFile) then FileDelete($sSaveFile)
		if $sPngdata <> "" then $bSuccess = _iif(FileWrite($sSaveFile,_Base64Decode($sPngdata)) = 1, True, False)

	endif

	return $bSuccess

endfunc

func _WD_move($sElementID, $iOffsetX=0, $iOffsetY=0)

	local $bSuccess = False
	local $sRet = ""

	$bSuccess = _getWebdriverParam("POST", "/moveto" , $sRet, "element",$sElementID, "xoffset" , $iOffsetX, "yoffset" , $iOffsetY )

	return $bSuccess

EndFunc


func _WD_click($sElementID, $sMouseButton)

	local $bSuccess = False
	local $sRet = ""

	$bSuccess = _getWebdriverParam("POST", "/element/" & $sElementID & "/click", $sRet)

	return $bSuccess

EndFunc



func _WD_get_element_attribute($sElementID, $sAttributeName, byref $sAttributeValue)

	local $sRet = ""
	local $bSuccess


	$sAttributeValue = ""

	if $sElementID <> ""  then	$bSuccess = _getWebdriverParam("GET", "/element/" & $sElementID & "/attribute/" & $sAttributeName , $sRet)

	if $bSuccess then

		$sAttributeValue = _jsonquery($sRet, "value")
		;debug($sRet)

	endif

	return $bSuccess

EndFunc



func _WD_find_element_by($sUsing, $sSearchTarget)

	local $sRet = ""
	local $bSuccess

	if _getWebdriverParam("POST", "/element", $sRet, 'value', $sSearchTarget, 'using',$sUsing) then
		;jdebug($sRet)
		$sRet = string(_jsonquery($sRet, "value\element"))
	else
		$sRet = ""
	endif

	;debug ($sRet)

	return $sRet

EndFunc



func _WD_focus_parentframe()

	; 배열로 ID값을 리턴

	local $sRet = ""
	local $bSuccess

	$bSuccess = _getWebdriverParam("POST", "/frame/parent", $sRet)


	return $bSuccess

EndFunc

func _WD_focus_frame($aFrameId)

	; 배열로 ID값을 리턴
	; id가 없을 경우 null 로 전달하여 main 으로 이동

	local $sRet = ""
	local $bSuccess

	if $aFrameId <> "" or IsNumber($aFrameId) then
		$bSuccess = _getWebdriverParam("POST", "/frame", $sRet, 'id', $aFrameId)


	else
		$bSuccess = _getWebdriverParam("POST", "/frame", $sRet)
	endif
	;_jdebug($sRet)

	return $bSuccess

EndFunc


func _WD_find_elements_by($sUsing, $sSearchTarget)

	; 배열로 ID값을 리턴

	local $sRet = ""
	local $bSuccess

	if _getWebdriverParam("POST", "/elements", $sRet, 'value', $sSearchTarget, 'using',$sUsing) then
		_jdebug($sRet)
		$sRet = _jsonquery($sRet, "value")
	else
		$sRet = ""
	endif

	return $sRet

EndFunc

func _WD_getReturnValue($sRet, $iIndex = 1)

	local $sNewValue = ""

	if IsArray($sRet) then
		if ubound($sRet) > 0 then $sNewValue= $sRet [$iIndex -1]
	else
		$sNewValue = _Trim($sRet)
	endif


	return $sNewValue

endfunc

func _WD_get_url()

	local $sRet = ""

	if  _getWebdriverParam("GET", "/url", $sRet) then

		$sRet = _Trim(_jsonquery($sRet, "value"))
	else
		$sRet = ""
	endif

	return $sRet

EndFunc

func _WD_navigate($sURL)

	local $sRet = ""

	return _getWebdriverParam("POST", "/url", $sRet, 'url', $sURL)


EndFunc


func _getWebdriverParam($sType, $sUrl, Byref $sRet,  $sParamN1 = "", $sParamV1 = "", $sParamN2 = "", $sParamV2 = "", $sParamN3 = "", $sParamV3 = "", $sParamN4 = "", $sParamV4 = "", $sParamN5 = "", $sParamV5 = "", $sParamN6 = "", $sParamV6 = "")

	local $sParamInfo = ""
	local $bSuccess

	if $sParamN1 = ""  then
		$sParamInfo = ""
	elseif $sParamN2 = ""  then
		$sParamInfo = _JSONEncode( _
			_JSONObject( _
				$sParamN1, $sParamV1 _
			) _
		)

	elseif $sParamN3 = "" then
		$sParamInfo = _JSONEncode( _
			_JSONObject( _
				$sParamN1, $sParamV1, _
				$sParamN2, $sParamV2 _
			) _
		)

	elseif $sParamN4 = "" then
		$sParamInfo = _JSONEncode( _
			_JSONObject( _
				$sParamN1, $sParamV1, _
				$sParamN2, $sParamV2, _
				$sParamN3, $sParamV3 _
			) _
		)

	elseif $sParamN4 = "" then
		$sParamInfo = _JSONEncode( _
			_JSONObject( _
				$sParamN1, $sParamV1, _
				$sParamN2, $sParamV2, _
				$sParamN3, $sParamV3, _
				$sParamN4, $sParamV4 _
			) _
		)

	elseif $sParamN5 = "" then
		$sParamInfo = _JSONEncode( _
			_JSONObject( _
				$sParamN1, $sParamV1, _
				$sParamN2, $sParamV2, _
				$sParamN3, $sParamV3, _
				$sParamN4, $sParamV4, _
				$sParamN5, $sParamV5 _
			) _
		)
	endif

	if $_webdriver_current_sessionid <> "" then
		$bSuccess = requestWebdriver($sType,"session/" & $_webdriver_current_sessionid & $sUrl, $sParamInfo, $sRet)
	Else
		$_webdriver_last_errormsg = "sessionid not exists"
		$bSuccess = False
	endif

	return $bSuccess

EndFunc



func _WD_AU3KeyMapping ($sStr)
	; http://code.google.com/p/selenium/wiki/JsonWireProtocol#/session/:sessionId/keys

	; Back space  \UE003
	$sStr = StringReplace($sStr,"{BACKSPACE}", "\UE003")
	$sStr = StringReplace($sStr,"{BS}", "\UE003")

	;Tab  \UE004
	$sStr = StringReplace($sStr,"{TAB}", "\UE004")

	;Clear  \UE005
	;non

	;Return1  \UE006
	;non

	;Enter1  \UE007
	$sStr = StringReplace($sStr,"{ENTER}", "\UE007")

	;Shift  \UE008
	$sStr = StringReplace($sStr,"{LSHIFT}", "\UE008")
	$sStr = StringReplace($sStr,"{RSHIFT}", "\UE008")

	;Control  \UE009
	$sStr = StringReplace($sStr,"{LCTRL}", "\UE009")
	$sStr = StringReplace($sStr,"{RCTRL}", "\UE009")

	;Alt  \UE00A
	$sStr = StringReplace($sStr,"{LALT}", "\UE009")
	$sStr = StringReplace($sStr,"{RALT}", "\UE009")

	;Pause  \UE00B
	$sStr = StringReplace($sStr,"{PAUSE}", "\UE00C")

	;Escape  \UE00C
	$sStr = StringReplace($sStr,"{ESCAPE}", "\UE00C")
	$sStr = StringReplace($sStr,"{ESC}", "\UE00C")

	;Space  \UE00D
	$sStr = StringReplace($sStr,"{SPACE}", "\UE00D")

	;Pageup  \UE00E
	$sStr = StringReplace($sStr,"{PGUP}", "\UE00E")

	;Pagedown  \UE00F
	$sStr = StringReplace($sStr,"{PGDN}", "\UE00F")

	;End  \UE010
	$sStr = StringReplace($sStr,"{END}", "\UE010")

	;Home  \UE011
	$sStr = StringReplace($sStr,"{HOME}", "\UE011")

	;Left arrow  \UE012
	$sStr = StringReplace($sStr,"{LEFT}", "\UE012")

	;Up arrow  \UE013
	$sStr = StringReplace($sStr,"{UP}", "\UE013")

	;Right arrow  \UE014
	$sStr = StringReplace($sStr,"{RIGHT}", "\UE014")

	;Down arrow  \UE015
	$sStr = StringReplace($sStr,"{DOWN}", "\UE015")

	;Insert  \UE016
	$sStr = StringReplace($sStr,"{INSERT}", "\UE016")
	$sStr = StringReplace($sStr,"{INS}", "\UE016")

	;Delete  \UE017
	$sStr = StringReplace($sStr,"{DEL}", "\UE017")
	$sStr = StringReplace($sStr,"{DELETE}", "\UE017")

	;Semicolon  \UE018
	;non

	;Equals  \UE019
	;$non

	;Numpad 0  \UE01A
	$sStr = StringReplace($sStr,"{NUMPAD0}", "\UE01A")

	;Numpad 1  \UE01B
	$sStr = StringReplace($sStr,"{NUMPAD1}", "\UE01B")

	;Numpad 2  \UE01C
	$sStr = StringReplace($sStr,"{NUMPAD2}", "\UE01C")

	;Numpad 3  \UE01D
	$sStr = StringReplace($sStr,"{NUMPAD3}", "\UE01D")

	;Numpad 4  \UE01E
	$sStr = StringReplace($sStr,"{NUMPAD4}", "\UE01E")

	;Numpad 5  \UE01F
	$sStr = StringReplace($sStr,"{NUMPAD5}", "\UE01F")

	;Numpad 6  \UE020
	$sStr = StringReplace($sStr,"{NUMPAD6}", "\UE020")

	;Numpad 7  \UE021
	$sStr = StringReplace($sStr,"{NUMPAD7}", "\UE021")

	;Numpad 8  \UE022
	$sStr = StringReplace($sStr,"{NUMPAD8}", "\UE022")

	;Numpad 9  \UE023
	$sStr = StringReplace($sStr,"{NUMPAD9}", "\UE023")

	;Multiply  \UE024
	$sStr = StringReplace($sStr,"{NUMPADMULT}", "\UE024")

	;Add  \UE025
	$sStr = StringReplace($sStr,"{NUMPADADD}", "\UE025")

	;Separator  \UE026
	;non

	;Subtract  \UE027
	$sStr = StringReplace($sStr,"{NUMPADSUB}", "\UE027")

	;Decimal  \UE028
	$sStr = StringReplace($sStr,"{NUMPADDOT}", "\UE028")

	;Divide  \UE029
	$sStr = StringReplace($sStr,"{NUMPADDIV}", "\UE029")

	;F1  \UE031
	$sStr = StringReplace($sStr,"{F1}", "\UE031")

	;F2  \UE032
	$sStr = StringReplace($sStr,"{F2}", "\UE032")

	;F3  \UE033
	$sStr = StringReplace($sStr,"{F3}", "\UE033")

	;F4  \UE034
	$sStr = StringReplace($sStr,"{F4}", "\UE034")

	;F5  \UE035
	$sStr = StringReplace($sStr,"{F5}", "\UE035")

	;F6  \UE036
	$sStr = StringReplace($sStr,"{F6}", "\UE036")

	;F7  \UE037
	$sStr = StringReplace($sStr,"{F7}", "\UE037")

	;F8  \UE038
	$sStr = StringReplace($sStr,"{F8}", "\UE038")

	;F9  \UE039
	$sStr = StringReplace($sStr,"{F9}", "\UE039")

	;F10  \UE03A
	$sStr = StringReplace($sStr,"{F10}", "\UE03A")

	;F11  \UE03B
	$sStr = StringReplace($sStr,"{F11}", "\UE03B")

	;F12  \UE03C
	$sStr = StringReplace($sStr,"{F12}", "\UE03C")

	;Command/Meta  \UE03D
	$sStr = StringReplace($sStr,"{COMMAND}", "\UE03D")
	$sStr = StringReplace($sStr,"{META}", "\UE03D")

	return $sStr

endfunc


