#include <IE.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>

global $_oEmbeddedIEImageViwer

;GUITARIEImageViwer_Test()

func CreateEmbeddedIEImageViwer(byref $oIE, byref $oIE_Object, $iX, $iy, $iWidth, $iHeight)

	if IsObj($oIE_Object) = 1 then GUICtrlDelete($oIE_Object)

	$oIE = _IECreateEmbedded()
	$oIE_Object = GUICtrlCreateObj($oIE, $iX, $iy, $iWidth, $iHeight)
	GUICtrlSetState ( $oIE, @SW_SHOWNOACTIVATE )
	GUICtrlSetState ( $oIE_Object, @SW_SHOWNOACTIVATE )


	_IENavigate ($oIE, "about:blank")

EndFunc



func GUITARIEImageViwer_Test()

	local $oIE, $oIE_Object
	local $Msg

	GUICreate("Form1", 800, 600)

	GUISetState(@SW_SHOW)

	CreateEmbeddedIEImageViwer($oie, $oIE_Object, 0,0,400,500)


	local $file[3]

	$file[1] ="c:\1.png"
	$file[2] ="c:\2.png"

	_EmbeddedIEImageView ($oIE, $file, "abc ÇÑ±Û - (2)")

	While 1
		$Msg = GUIGetMsg()
		Switch $Msg
			Case $GUI_EVENT_CLOSE
				Exit
		EndSwitch
	WEnd

EndFunc



func _EmbeddedIEImageView(byref $oIE, $sFiles, $sTitle)

	local $sHTML, $i

	$sHTML = ""
	$sHTML &= "<HTML>" & @CR
	$sHTML &= "<BODY nowrap style='margin:10; font-family:dotum; font-size: 12px;'>" & @CR

	if $sTitle <> "" then $sHTML &= "<b style='margin:0'>" & $sTitle & "</b>" & @CR

	$sHTML &= "<ul type=circle>" & @CR

	for $i=1 to ubound ($sFiles) -1
		$sHTML &= "<li style='margin:4;text-indent:0pt' ><img align=absmiddle border=1 style='border-color:gray;' src='" & $sFiles[$i] & "'>" & " "  & $sFiles[$i] & @CR & " </li> <br>"
	next

	$sHTML &= "</ul>" & @CR
	$sHTML &= "</BODY>" & @CR
	$sHTML &= "</HTML>"

	_IEDocWriteHTML ($oIE, $sHTML)
	;_IEAction ($oIE, "refresh")

	;GUICtrlSetState ($_gObjEmbeddedIEImageViwer,$GUI_DISABLE)
	;GUICtrlSetState ($_gObjEmbeddedIEImageViwer,$GUI_ENABLE)

	;GUICtrlSetState ($_gObjEmbeddedIEImageViwer,$GUI_ENABLE)



endfunc