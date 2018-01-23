
#include <StaticConstants.au3>
#include <GuiRichEdit.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#Include <GuiButton.au3>

#include ".\_include_nhn\_util.au3"

;openAboutWindow()



Func openSPKeyList()

	local $i=0
	Dim $aArray_2D[17][2]

	$aArray_2D[$i][0] = ";"
	$aArray_2D[$i][1] = "&#59;"

	$i=$i+1
	$aArray_2D[$i][0] = "&"
	$aArray_2D[$i][1] = "&#amp; or &#38;"

	$i=$i+1
	$aArray_2D[$i][0] = ","
	$aArray_2D[$i][1] = "&#44;"

	$i=$i+1
	$aArray_2D[$i][0] = ":"
	$aArray_2D[$i][1] = "&#58;"

	$i=$i+1
	$aArray_2D[$i][0] = "="
	$aArray_2D[$i][1] = "&#61;"

	$i=$i+1
	$aArray_2D[$i][0] = "$"
	$aArray_2D[$i][1] = "&#36;"

	$i=$i+1
	$aArray_2D[$i][0] = '"'
	$aArray_2D[$i][1] = "&#34; or  &quot;"

	$i=$i+1
	$aArray_2D[$i][0] = "\"
	$aArray_2D[$i][1] = "&#92;"

	$i=$i+1
	$aArray_2D[$i][0] = "["
	$aArray_2D[$i][1] = "&#91;"

	$i=$i+1
	$aArray_2D[$i][0] = "]"
	$aArray_2D[$i][1] = "&#93;"

	$i=$i+1
	$aArray_2D[$i][0] = ">"
	$aArray_2D[$i][1] = "&gt; or &#62;"


	$i=$i+1
	$aArray_2D[$i][0] = "<"
	$aArray_2D[$i][1] = "&lt; or &#60;"

	$i=$i+1
	$aArray_2D[$i][0] = "^"
	$aArray_2D[$i][1] = "&#94;"

	$i=$i+1
	$aArray_2D[$i][0] = "|"
	$aArray_2D[$i][1] = "&#124;"

	$i=$i+1
	$aArray_2D[$i][0] = "}"
	$aArray_2D[$i][1] = "&#123;"

	$i=$i+1
	$aArray_2D[$i][0] = "{"
	$aArray_2D[$i][1] = "&#125;"

	$i=$i+1
	$aArray_2D[$i][0] = "{space}"
	$aArray_2D[$i][1] = "&nbsp;"

	_ArrayDisplay($aArray_2D, "특수코드 문자표", Default, 32 + 64, Default, "문자|표기", Default)


EndFunc   ;==>Example

func openAboutWindow()

	local $iFormWidth=300,$iFormHeight=310
	;local $formAbout = GUICreate("GUITAR 정보", $iFormWidth, $iFormHeight,200,200,bitor($WS_BORDER, $WS_POPUP, $WS_CAPTION, $WS_SYSMENU ))

	local $aWinPos = WinGetPos($_gForm)
	local $iformLeft, $iformTop

	$iformLeft = $aWinPos[0] + ($aWinPos[2]/2) - ($iFormWidth/2)
	$iformTop = $aWinPos[1] + ($aWinPos[3]/2) - ($iFormHeight/1.5)

	local $formAbout = GUICreate("GUITAR " & _getLanguageMsg("information_info"), $iFormWidth, $iFormHeight,$iformLeft,$iformTop, $WS_EX_TOPMOST)

	local $picLogo = GUICtrlCreatePic (@ScriptDir & "\guitarlogo.jpg", 80, 20, 0,0)

	local $lbAbout = GUICtrlCreateLabel("GUITR v" & FileGetVersion(@ScriptDir & "\" & _GetScriptName() & ".exe") & @crlf &  @crlf & "Copyright (c) 2010-" & @YEAR & "  NAVER Corp." & @crlf &  @crlf  , 20, 110, 300, 70)

	local $lbHomepage = GUICtrlCreateLabel('https://github.com/naver/guitar', 20, 180, 300, 15)

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
				ShellExecute("https://github.com/naver/guitar")

		EndSelect
	WEnd

	GUIDelete ($formAbout)

endfunc