#include ".\_include_nhn\_util.au3"

Global $_sLanguageName
Global $_oLanguageDictionary

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
	local $oDictionary
	local $sKey, $sValue

	$oDictionary = ObjCreate("Scripting.Dictionary")

	_FileReadToArray($sFile,$aFileContents)

	for $i=1 to ubound($aFileContents) -1

		$iTabPos = StringInStr($aFileContents[$i],@tab)

		if $iTabPos <> 0 then
			$sKey = StringLower(_trim(stringleft($aFileContents[$i],$iTabPos-1)))
			$sValue = _trim(stringtrimleft($aFileContents[$i],$iTabPos))

			;if $sKey <> "" and $sValue <> "" then
				;_debug("추가 : " & $sKey, $sValue)
				;$oDictionary.add ($sKey, "K" & $sValue)
				$oDictionary.add ($sKey,  $sValue)
			;endif
		endif
	next

	$_oLanguageDictionary = $oDictionary

endfunc


func _getLanguageMsg($sID, $sParam1="", $sParam2="", $sParam3="", $sParam4="", $sParam5="")

	local $sMessage

	;_debug($sID)

	$sID = StringLower($sID)

	If $_oLanguageDictionary.Exists($sID) Then
		$sMessage= $_oLanguageDictionary.item ($sID)
	else
		$sMessage= "undefined : " & $sID
		_msg($sMessage)
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