
#include <StaticConstants.au3>
#include <GuiRichEdit.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#Include <GuiButton.au3>

#include ".\_include_nhn\_util.au3"

;openAboutWindow()

func openAboutWindow()

	local $iFormWidth=300,$iFormHeight=310
	;local $formAbout = GUICreate("GUITAR Á¤º¸", $iFormWidth, $iFormHeight,200,200,bitor($WS_BORDER, $WS_POPUP, $WS_CAPTION, $WS_SYSMENU ))

	local $aWinPos = WinGetPos($_gForm)
	local $iformLeft, $iformTop

	$iformLeft = $aWinPos[0] + ($aWinPos[2]/2) - ($iFormWidth/2)
	$iformTop = $aWinPos[1] + ($aWinPos[3]/2) - ($iFormHeight/1.5)

	local $formAbout = GUICreate("GUITAR " & _getLanguageMsg("information_info"), $iFormWidth, $iFormHeight,$iformLeft,$iformTop, $WS_EX_TOPMOST)

	local $picLogo = GUICtrlCreatePic (@ScriptDir & "\guitarlogo.jpg", 80, 20, 0,0)

	local $lbAbout = GUICtrlCreateLabel("GUITR v" & FileGetVersion(@ScriptDir & "\" & _GetScriptName() & ".exe") & @crlf &  @crlf & "Copyright (c) 2010-2012 NHN Corp." & @crlf &  @crlf  , 20, 110, 300, 70)

	local $lbHomepage = GUICtrlCreateLabel('http://devcode.nhncorp.com/projects/guitar', 20, 180, 300, 15)

	local $btnOk = GUICtrlCreateButton(_getLanguageMsg("information_ok"), 105, 230, 90, 30, $BS_DEFPUSHBUTTON)

	local $msg

	GUICtrlSetFont($lbHomepage, 9, 400, 4)
	GUICtrlSetColor($lbHomepage, 0x0000ff)
	GUICtrlSetCursor($lbHomepage, 0)

	GUISetState()

	GUISetState(@SW_DISABLE, $_gForm)
	GUISetState(@SW_SHOW, $formAbout)

	While 1
		$msg = GUIGetMsg(1)
		Select
			Case $msg[1] = $formAbout And $msg[0] = $GUI_EVENT_CLOSE or  $msg[0] =  $btnOk  ; Modal close

				GUISetState(@SW_ENABLE, $_gForm)
				WinActivate($_gForm)
				ExitLoop

			Case $msg[1] = $formAbout And $msg[0] = $lbHomepage
				ShellExecute("http://devcode.nhncorp.com/projects/guitar")

		EndSelect
	WEnd

	GUIDelete ($formAbout)

endfunc