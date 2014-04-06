#include-once
#Include <array.au3>
#include ".\_include_nhn\_util.au3"

Global $_sLanguageName
Global $_oLanguageDictionary
Global $_aLanguageCache[1][3]

;_loadLanguageResource(_loadLanguageFile("english"))

;_debug(_getLanguageMsg("aaa", "x1", "x2"))
;_debug(_getLanguageMsg("aa", "x1", "x2"))

; 언어 리소스 파일 정보 얻기
func _loadLanguageFile($sLanguageName)

	local $sFile
	local $sExt = ".lng"

	$_sLanguageName = $sLanguageName

	Switch  $sLanguageName

		case "english"
			$sFile = @ScriptDir & "\english" & $sExt


		case else
			$sFile = @ScriptDir & "\korean" & $sExt
			$_sLanguageName = "korean"

	EndSwitch



	return $sFile

endfunc


; 언어 리소스 파일 내부 정보 읽기
func _loadLanguageResource($sFile)

	local $aFileContents
	local $iTabPos, $i
	local $sKey, $sValue

	$_oLanguageDictionary = 0
	$_oLanguageDictionary = ObjCreate("Scripting.Dictionary")

	_FileReadToArray($sFile,$aFileContents)

	for $i=1 to ubound($aFileContents) -1

		$iTabPos = StringInStr($aFileContents[$i],@tab)

		if $iTabPos <> 0 then
			$sKey = StringLower(_trim(stringleft($aFileContents[$i],$iTabPos-1)))
			$sValue = _trim(stringtrimleft($aFileContents[$i],$iTabPos))

			;if $sKey <> "" and $sValue <> "" then
				;_debug("추가 : " & $sKey, $sValue)
				;$oDictionary.add ($sKey, "K" & $sValue)
				$_oLanguageDictionary.add ($sKey,  $sValue)
			;endif
		endif
	next

endfunc


func _getLanguageMsg($sID, $sParam1="", $sParam2="", $sParam3="", $sParam4="", $sParam5="")

	local $sMessage

	;_debug($sID)

	$sID = StringLower($sID)

	$sMessage = _getLanguageMsgcache($sID)

	;debug("캐시:" & $sMessage)

	if $sMessage = "" then
		If $_oLanguageDictionary.Exists($sID) Then
			$sMessage= $_oLanguageDictionary.item ($sID)
			_addLanguageMsgcache($sID, $sMessage)
		else
			$sMessage= "undefined : " & $sID
			_msg($sMessage)
		endif
	endif

	$sMessage = stringreplace($sMessage, "@crlf", @crlf)
	$sMessage = stringreplace($sMessage, "@lf", @lf)
	$sMessage = stringreplace($sMessage, "%1", $sParam1)
	$sMessage = stringreplace($sMessage, "%2", $sParam2)
	$sMessage = stringreplace($sMessage, "%3", $sParam3)
	$sMessage = stringreplace($sMessage, "%4", $sParam4)
	$sMessage = stringreplace($sMessage, "%5", $sParam5)

	return $sMessage

endfunc


func _addLanguageMsgcache($sID, $sMsg)

	redim $_aLanguageCache[ubound($_aLanguageCache,1) + 1][3]

	$_aLanguageCache[ubound($_aLanguageCache)-1][1] = $sID
	$_aLanguageCache[ubound($_aLanguageCache)-1][2] = $sMsg
	;debug($sID, $sMsg)

endfunc


func _getLanguageMsgcache($sID)

	local $iIndex
	local $sRet = ""

	$iIndex =  _ArraySearch($_aLanguageCache,$sID,0,0,0,0,1,1)

	if $iIndex <> -1 then $sRet = $_aLanguageCache[$iIndex][2]

	return $sRet

endfunc



func _writeLanguageMsgcache()

	local $sTemp

	$sTemp = _getLanguageMsg("report_testserver")
	$sTemp = _getLanguageMsg("report_testscript")
	$sTemp = _getLanguageMsg("report_testrun")
	$sTemp = _getLanguageMsg("information_teststop")
	$sTemp = _getLanguageMsg("information_testpause")
	$sTemp = _getLanguageMsg("report_testend")
	$sTemp = _getLanguageMsg("report_result")
	$sTemp = _getLanguageMsg("report_pass")
	$sTemp = _getLanguageMsg("report_fail")
	$sTemp = _getLanguageMsg("report_testresult")
	$sTemp = _getLanguageMsg("report_target")
	$sTemp = _getLanguageMsg("report_run")
	$sTemp = _getLanguageMsg("report_notrun")
	$sTemp = _getLanguageMsg("report_skip")
	$sTemp = _getLanguageMsg("common_timeminute")
	$sTemp = _getLanguageMsg("report_testtime")
	$sTemp = _getLanguageMsg("report_version")
	$sTemp = _getLanguageMsg("status_fail")
	$sTemp = _getLanguageMsg("status_success")
	$sTemp = _getLanguageMsg("report_detail")
	$sTemp = _getLanguageMsg("report_create")
	$sTemp = _getLanguageMsg("report_sendsms")
	$sTemp = _getLanguageMsg("report_sendemail")
	$sTemp = _getLanguageMsg("error_emailsend")
	$sTemp = _getLanguageMsg("report_testend")

endfunc
