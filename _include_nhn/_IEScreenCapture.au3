#include-once

#include <ScreenCapture.au3>
#include <IE.au3>
#Include <WinAPI.au3>

Global $_IeScrollError


;local $oIE
;local $oIEObj
;$oIE = _IEAttach("How to")
;$oIE = _IEAttach("Internet Explorer")
;$oIE = _IEAttach("Áê´Ï¾î")
;$oIE = _IEAttach("³×ÀÌ¹ö")
;_IEScreenCapture($oIE, "c:\1.png" )
;$oIEObj = _IEGetObjByname  ($oIE, "query")
;$oIEObj = _IEGetObjByname  ($oIE, "news_h")

;_IEElementCapture($oIE, $oIEObj, "c:\1.jpg", 5)

func _IEScreenCapture(byref $oIE, $sImageFile)

	local $oIEhwnd

	local $ibodyWidth
	local $ibodyHeight
	local $ibodyLeft
	local $ibodyTop

	local $iConentsWidth
	local $iConentsHeight

	local $i, $j

	local $iXloopCount
	local $iYloopCount

	local $iXloopMod
	local $iYloopMod

	local $iXCurrent
	local $iYCurrent

	local $tempGraphics
	local $hMainImage
	local $hGraphic
	local $hBitmap
	local $hIbtmap

	local $bRet

	local $aIEFramePosion
	local $oIEBody

	local $bScrollError

	$oIEhwnd = _IEPropertyGet ($oIE, "hwnd" )
	$oIEBody = $oIE.document.body

	;_WinAPI_SetForegroundWindow($oIEhwnd)
	WinSetState($oIEhwnd,"",@SW_SHOW)
	WinActivate($oIEhwnd)

	$aIEFramePosion = _WinAPI_GetWindowRect (ControlGetHandle (HWnd($oIEhwnd),"","[CLASS:Internet Explorer_Server; INSTANCE:1]"))
	;_debug("xxxx", DllStructGetData($x, "Left"), DllStructGetData($x, "Top") , DllStructGetData($x, "Right"), DllStructGetData($X, "Bottom"))
	$ibodyLeft = DllStructGetData($aIEFramePosion, "Left") + 2
	$ibodyTop = DllStructGetData($aIEFramePosion, "Top") + 2

	;_debug("xxxx", DllStructGetData($aIEFramePosion, "Right") - $ibodyLeft, DllStructGetData($aIEFramePosion, "Bottom") - $ibodyTop)

	local $xx = $oIE.document.body

	;$ibodyLeft = _IEPropertyGet ($oIEBody, "screenx" ) + 2
	;$ibodyTop = _IEPropertyGet ($oIEBody, "screeny" ) + 2
	;_debug("$ibodyLeft", $ibodyLeft,  $ibodyTop)

	$bScrollError = checkScrollError($oie)

	$ibodyWidth = $oIE.document.documentElement.clientWidth()
	$ibodyHeight = $oIE.document.documentElement.clientHeight()

	if $ibodyHeight = 0 and $ibodyHeight = 0 then
		$ibodyWidth = $oIE.document.body.clientWidth()
		$ibodyHeight = $oIE.document.body.clientHeight()
	endif

	;_debug("test", $oIE.document.documentElement.offsetWidth(), $oIE.document.documentElement.offsetHeight())
	;_debug("test", $oIE.document.body.clientWidth(), $oIE.document.body.clientHeight())

	if $bScrollError then
		$iConentsWidth =  $ibodyWidth
		$iConentsHeight = $ibodyHeight
	Else
		$iConentsWidth =  $oIE.document.body.scrollWidth()
		$iConentsHeight = $oIE.document.body.scrollHeight()
	endif

	if $iConentsWidth < $ibodyWidth then $iConentsWidth = $ibodyWidth
	if $iConentsHeight < $ibodyHeight then $iConentsHeight = $ibodyHeight

	;_debug ("$ibodyWidth" , $ibodyWidth , $ibodyHeight)
	;_debug ("$iConentsWidth" , $iConentsWidth , $iConentsHeight)


	$iXloopCount = Floor($iConentsWidth / $ibodyWidth)
	$iYloopCount = Floor($iConentsHeight / $ibodyHeight)

	$iXloopMod = Mod($iConentsWidth , $ibodyWidth)
	$iYloopMod = Mod($iConentsHeight , $ibodyHeight)

	$bRet = _GDIPlus_Startup()

	$tempGraphics = _GDIPlus_GraphicsCreateFromHWND(_WinAPI_GetDesktopWindow())
	$hMainImage = _GDIPlus_BitmapCreateFromGraphics($iConentsWidth, $iConentsHeight, $tempGraphics)
	_GDIPlus_GraphicsDispose($tempGraphics)
	$hGraphic = _GDIPlus_ImageGetGraphicsContext($hMainImage)

	For $i=0 To $iXloopCount
		For $j=0 To $iYloopCount
			;_debug ($i * $ibodyWidth, $j * $ibodyHeight)

			;$oIE.document.documentElement.croll($i * $ibodyWidth, $j * $ibodyHeight)
			;$oIE.document.body.scrollTop(int($j) * int($ibodyHeight))
			;$oIE.document.body.scrollLeft($i * $ibodyWidth)
			;_debug($bScrollError)
			if not $bScrollError then $oIE.document.parentWindow.scroll($i * $ibodyWidth, $j * $ibodyHeight)

			$hBitmap = _ScreenCapture_Capture ("", $ibodyLeft, $ibodyTop, $ibodyLeft + $ibodyWidth,$ibodyTop + $ibodyHeight, False)
			$hIbtmap = _GDIPlus_BitmapCreateFromHBITMAP($hBitmap)
			_WinAPI_DeleteObject($hBitmap)

			$iXCurrent = $i * $ibodyWidth
			If $i = $iXloopCount Then $iXCurrent -= $ibodyWidth - $iXloopMod

			$iYCurrent = $j * $ibodyHeight
			If $j = $iYloopCount Then $iYCurrent -= $ibodyHeight - $iYloopMod
			_GDIPlus_GraphicsDrawImage($hGraphic, $hIbtmap, $iXCurrent, $iYCurrent)
			_GDIPlus_BitmapDispose ($hIbtmap)
		Next
	Next

	if not $bScrollError then $oIE.document.parentWindow.scroll(0, 0)
	if FileExists($sImageFile) then FileDelete($sImageFile)
	_GDIPlus_ImageSaveToFile($hMainImage, $sImageFile)


	; Clean up resources
	_GDIPlus_GraphicsDispose($hGraphic)
	_GDIPlus_ImageDispose($hMainImage)

	; Shut down GDI+ library
	_GDIPlus_Shutdown()

	return FileExists($sImageFile)

endfunc

func checkScrollError (byref $oIE)

	$_IeScrollError = False
	_IEErrorHandlerDeregister ()
	_IEErrorHandlerRegister ("ieScrollErrorHandle")
	$oIE.document.parentWindow.scroll (0,0)
	_IEErrorHandlerDeregister ()

	return $_IeScrollError

endfunc


Func _WinAPI_SetActiveWindow($hWnd)
	Local $aResult = DllCall("user32.dll", "bool", "SetActiveWindow", "hwnd", $hWnd)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc

Func _WinAPI_SetForegroundWindow($hWnd)
	Local $aResult = DllCall("user32.dll", "bool", "SetForegroundWindow", "hwnd", $hWnd)
	If @error Then Return SetError(@error, @extended, False)
	sleep (100)
	Return $aResult[0]
EndFunc

Func ieScrollErrorHandle()
	$_IeScrollError = True
endfunc

Func IEErrFunc()

	local $ErrorScriptline
	local $ErrorNumber
	local $ErrorNumberHex
	local $ErrorDescription
	local $ErrorWinDescription
	local $ErrorSource
	local $ErrorHelpFile
	local $ErrorHelpContext
	local $ErrorLastDllError
	local $ErrorOutput

	; Important: the error object variable MUST be named $oIEErrorHandler
	$ErrorScriptline = $oIEErrorHandler.scriptline
	$ErrorNumber = $oIEErrorHandler.number
	$ErrorNumberHex = Hex($oIEErrorHandler.number, 8)
	$ErrorDescription = StringStripWS($oIEErrorHandler.description, 2)
	$ErrorWinDescription = StringStripWS($oIEErrorHandler.WinDescription, 2)
	$ErrorSource = $oIEErrorHandler.Source
	$ErrorHelpFile = $oIEErrorHandler.HelpFile
	$ErrorHelpContext = $oIEErrorHandler.HelpContext
	$ErrorLastDllError = $oIEErrorHandler.LastDllError
	$ErrorOutput = ""
	$ErrorOutput &= "--> COM Error Encountered in " & @ScriptName & @CR
	$ErrorOutput &= "----> $ErrorScriptline = " & $ErrorScriptline & @CR
	$ErrorOutput &= "----> $ErrorNumberHex = " & $ErrorNumberHex & @CR
	$ErrorOutput &= "----> $ErrorNumber = " & $ErrorNumber & @CR
	$ErrorOutput &= "----> $ErrorWinDescription = " & $ErrorWinDescription & @CR
	$ErrorOutput &= "----> $ErrorDescription = " & $ErrorDescription & @CR
	$ErrorOutput &= "----> $ErrorSource = " & $ErrorSource & @CR
	$ErrorOutput &= "----> $ErrorHelpFile = " & $ErrorHelpFile & @CR
	$ErrorOutput &= "----> $ErrorHelpContext = " & $ErrorHelpContext & @CR
	$ErrorOutput &= "----> $ErrorLastDllError = " & $ErrorLastDllError
	MsgBox(0,"COM Error", $ErrorOutput)
	SetError(1)
	Return

EndFunc  ;==>MyErrFunc


func _IEElementCapture(byref $oIE, byref $oIEObj, $sImageFile, $iBoderSize = 0 )

	local $oIEhwnd

	local $ibodyLeft
	local $ibodyTop
	local $ibodyWidth
	local $ibodyHeight

	local $iObjWidth
	local $iObjHeight
	local $iObjLeft
	local $iObjTop

	local $aIEFramePosion

	local $iScrollX = 0
	local $iScrollY = 0

	local $iBoderAddHeight
	local $iBoderAddWidth

	$oIEhwnd = _IEPropertyGet ($oIE, "hwnd" )

	WinActivate ($oIEhwnd, "")

	$aIEFramePosion = _WinAPI_GetWindowRect (ControlGetHandle (HWnd($oIEhwnd),"","[CLASS:Internet Explorer_Server; INSTANCE:1]"))
	$ibodyLeft = DllStructGetData($aIEFramePosion, "Left")
	$ibodyTop = DllStructGetData($aIEFramePosion, "Top")

	$ibodyWidth = $oIE.document.documentElement.clientWidth()
	$ibodyHeight = $oIE.document.documentElement.clientHeight()

	if $ibodyHeight = 0 and $ibodyHeight = 0 then
		$ibodyWidth = $oIE.document.body.clientWidth()
		$ibodyHeight = $oIE.document.body.clientHeight()
	endif

	;ConsoleWrite("$ibodyTop=" & $ibodyTop & @cr )
	;ConsoleWrite("$ibodyHeight=" & $ibodyHeight & @cr)

	;ConsoleWrite ( "$oIEObj.getBoundingClientRect=" & Number($oIEObj.getBoundingClientRect().top) & " IEtop=" & $ibodyTop + $ibodyHeight & @cr)

	;ConsoleWrite("Number($oIEObj.getBoundingClientRect().right)=" & Number($oIEObj.getBoundingClientRect().right) & @cr)
	;ConsoleWrite("$ibodyWidth=" & $ibodyWidth & @cr)

	;if  $oIEObj.getBoundingClientRect().left = $oIEObj.getBoundingClientRect().right then
	;	$oIEObj = $oIEObj.parent
	;endif

	if Number($oIEObj.getBoundingClientRect().top) < 0 then $iScrollY = $oIE.document.body.scrollTop + Number($oIEObj.getBoundingClientRect().top) - 50
	if Number($oIEObj.getBoundingClientRect().bottom) > $ibodyHeight then $iScrollY = $oIE.document.body.scrollTop + (Number($oIEObj.getBoundingClientRect().bottom) - $ibodyHeight) + 50
	if Number($oIEObj.getBoundingClientRect().left) < 0 then $iScrollX = $oIE.document.body.scrollLeft + Number($oIEObj.getBoundingClientRect().Left) -50
	if Number($oIEObj.getBoundingClientRect().right) > $ibodyWidth then $iScrollX = $oIE.document.body.scrollLeft + (Number($oIEObj.getBoundingClientRect().right) - $ibodyWidth) + 50

	;if Number($oIEObj.getBoundingClientRect().top) < 0 then $iScrollY = $oIE.document.body.scrollLeft + $iObjTop
	;if Number($oIEObj.getBoundingClientRect().top) > $ibodyHeight then $iScrollY = $iObjTop

	if $iScrollY <> 0 or $iScrollX <> 0 then

		;ConsoleWrite ("X:" & $iScrollX & @cr)
		;ConsoleWrite ("Y:" & $iScrollY & @cr)

		if $iScrollX = 0 then $iScrollX = $oIE.document.body.scrollLeft
		if $iScrollY = 0 then $iScrollY = $oIE.document.body.scrollTop

		$oIE.document.parentWindow.scroll($iScrollX, $iScrollY)
		sleep (500)
	endif

	$iObjLeft = $oIEObj.getBoundingClientRect().left + $ibodyLeft
	$iObjTop = $oIEObj.getBoundingClientRect().top + $ibodyTop
	$iObjWidth = $oIEObj.getBoundingClientRect().right + $ibodyLeft
	$iObjHeight = $oIEObj.getBoundingClientRect().bottom + $ibodyTop


	ConsoleWrite ( "ÀÌ¹ÌÁö Ä¸ÃÄ $iObjLeft=" & $iObjLeft & " $iObjTop=" & $iObjTop & @cr)
	ConsoleWrite ( "ÀÌ¹ÌÁö Ä¸ÃÄ $iObjWidth=" & $iObjWidth & " $iObjHeight=" & $iObjHeight & @cr)

	;ConsoleWrite ( "$iObjLeft=" & $oIEObj.offsetLeft & " $iObjTop=" & $oIEObj.offsetWidth & @cr)

	if FileExists($sImageFile) then FileDelete($sImageFile)


	$iBoderAddHeight = ($iObjHeight - $iObjTop) * ($iBoderSize  / 100)
	$iBoderAddWidth = ($iObjWidth - $iObjLeft) * ($iBoderSize  / 100)



	if $iBoderAddWidth > $iBoderAddHeight then $iBoderAddWidth = $iBoderAddHeight


	_ScreenCapture_Capture ( $sImageFile, int($iObjLeft - $iBoderAddWidth), int($iObjTop - $iBoderAddHeight), int($iObjWidth +  $iBoderAddWidth), int($iObjHeight + $iBoderAddHeight), False)

EndFunc

