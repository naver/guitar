#include ".\_include_nhn\_util.au3"

;Private Declare Auto Function SystemParametersInfo Lib "user32" (ByVal uiAction As UInteger, ByVal uiParam As UInteger, ByRef pvParam As UInteger, ByVal fWinIni As UInteger) As Boolean

Global Const $SPI_GETFONTSMOOTHING = 74
Global Const $SPI_SETFONTSMOOTHING = 75
Global Const $SPIF_UPDATEINIFILE = 0x1
Global Const $SPIF_SENDCHANGE     = 2
Global Const $SPI_SETCLEARTYPE = 0x1049
Global Const $SPI_SETFONTSMOOTHINGTYPE = 0x200B

Global Const $SPI_GETFONTSMOOTHINGCONTRAST = 0x200C
Global Const $SPI_SETFONTSMOOTHINGCONTRAST = 0x200D

;_debug(_SetFontSmoothing(0))

Func _GetFontSmoothing()

	local $iResults
	local $pv = 0
	local $uiParam = 0
	local $fWinIni = 0
	;'Get font smoothing value and return true if font smoothing is turned on.
	;$iResults = SystemParametersInfo($SPI_GETFONTSMOOTHING, 0, $pv, 0)
	$iResults = DllCall( "User32","int","SystemParametersInfo","int",$SPI_GETFONTSMOOTHING,"int",0 ,"int*",$pv,"int",0)

	;_debug("error : " & @error, $pv)

	if IsArray($iResults) then

		If $iResults[3] > 0 Then
			return True
		Else
			return False
		EndIf
	Else
		return False
	endif

EndFunc

Func _SetFontSmoothing($iValue)

	local $iResults
	local $pv = 0
	local $uiParam = 0
	local $fWinIni = 0
		;'Get font smoothing value and return true if font smoothing is turned on.
	;$iResults = SystemParametersInfo($SPI_GETFONTSMOOTHING, 0, $pv, 0)

	;$iResults = DllCall( "User32","int","SystemParametersInfo","int",$SPI_SETCLEARTYPE,"BOOLEAN",_iif($iValue,True,False),"int*",$pv,"int",bitor ($SPIF_UPDATEINIFILE, $SPIF_SENDCHANGE))
	;_debug("error : " & @error)


	$iResults = DllCall( "User32","int","SystemParametersInfo","int",$SPI_SETFONTSMOOTHING,"BOOLEAN",_iif($iValue,True,False),"int*",$pv,"int",bitor($SPIF_UPDATEINIFILE,$SPIF_SENDCHANGE))
	sleep(100)
	$iResults = DllCall( "User32","int","SystemParametersInfo","int",$SPI_SETFONTSMOOTHING,"BOOLEAN",_iif($iValue,True,False),"int*",$pv,"int",bitor($SPIF_UPDATEINIFILE,$SPIF_SENDCHANGE))
	sleep(100)
	;_debug("error : " & @error)



EndFunc





Func _GetFontSmoothingContrast()

	local $iResults
	local $pv = 0
	local $uiParam = 0
	local $fWinIni = 0
	;  1000 to 2200. The default value is 1400.

	$iResults = DllCall( "User32","int","SystemParametersInfo","int",$SPI_GETFONTSMOOTHINGCONTRAST,"int",0 ,"int*",$pv,"int",0)

	;_debug("error : " & @error, $pv)

	if IsArray($iResults) then
		return $iResults[3]
	Else
		return ""
	endif

EndFunc

Func _SetFontSmoothingContrast($iValue)

	local $iResults
	local $pv = 0
	local $uiParam = 0
	local $fWinIni = 0
	;'Get font smoothing value and return true if font smoothing is turned on.
	;$iResults = SystemParametersInfo($SPI_GETFONTSMOOTHING, 0, $pv, 0)
	$iResults = DllCall( "User32","int","SystemParametersInfo","int",$SPI_SETFONTSMOOTHINGCONTRAST,"int",0 ,"int",$iValue,"int",bitor($SPIF_UPDATEINIFILE, $SPIF_SENDCHANGE))
	;_debug("error : " & @error)

EndFunc

