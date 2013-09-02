#include-once

#include "UIACommon.au3"

#include <GUIConstantsEx.au3>
#include <EditConstants.au3>
#Include <GuiButton.au3>
#include <GUIComboBox.au3>

#include <Misc.au3>


;----- example 3 PNG work araund by Zedna
#include <WindowsConstants.au3>
#include <GDIPlus.au3>
#Include <WinAPI.au3>

#include ".\_include_nhn\_util.au3"


Global $_gFindReplaceForm
Global $_gFindReplaceLastFindText
Global $_gFindReplaceFindText
Global $_gFindReplaceReplaceText
Global $_gFindReplaceLastReplaceText
Global $_gFindReplaceFindCmd
Global $_gFindReplaceReplaceCmd
Global $_gFindReplaceCancel

;_FormFindReplaceLoad()

func _FormFindReplaceLoad()

	local $iFormWidth = 440
	local $iFormHeight = 120
	local $x
	local $xAdd
	local $y
	local $yAdd
	local $i
	local $msg

	local $aWinPos = WinGetPos($_gForm)
	local $iformLeft, $iformTop

	$iformLeft = $aWinPos[0] + ($aWinPos[2]/2) - ($iFormWidth/2)
	$iformTop = $aWinPos[1] + ($aWinPos[3]/2) - $iFormHeight

	if $_gFindReplaceForm <> "" then return

	$_gFindReplaceForm = GUICreate("Search and Replace", $iFormWidth,  $iFormHeight, $iformLeft,$iformTop, default, $WS_EX_TOPMOST)
	;$_gFindReplaceForm = GUICreate("찾기/바꾸기", $iFormWidth,  $iFormHeight, default,default, $WS_SIZEBOX )

	$msg = gUIGetStyle ($_gFindReplaceForm)

	GuiCtrlCreateLabel("Find What (&N):", 10,  15)
	$_gFindReplaceFindText = GUICtrlCreateInput($_gFindReplaceLastFindText , 120 , 10 , 200, 20)
	GuiCtrlCreateLabel("Replace With (&P):", 10,  45)
	$_gFindReplaceReplaceText = GUICtrlCreateInput($_gFindReplaceLastReplaceText , 120 , 40 , 200, 20)

	$_gFindReplaceFindCmd = GUICtrlCreateButton("Find Next (&F)",330 , 5,100,25,$BS_DEFPUSHBUTTON)
	$_gFindReplaceReplaceCmd = GUICtrlCreateButton("Replace All (&A)",330 , 35,100,25)
	$_gFindReplaceCancel = GUICtrlCreateButton("Cancel (&C)",330 , 65,100,25)

	GUISetState(@SW_SHOW, $_gFindReplaceForm)

	sleep(1)

	;debug("왔어")

	WinSetOnTop ($_gFindReplaceForm,"",True)

	setFindReplaceHotKey(True)

	;AutoItSetOption("GUICloseOnESC", 1)

endfunc

func _FormFindReplaceClose()
	;debug(WinGetHandle ($_gFindReplaceForm))


	if WinGetHandle($_gFindReplaceForm) <> 0  and $_gFindReplaceForm <> "" then
		WinSetOnTop ($_gFindReplaceForm,"",False)
		GUIDelete($_gFindReplaceForm)
		$_gFindReplaceForm = ""
		;_msg("dd")

		setFindReplaceHotKey(False)

		;debug("왔어")
	endif


endfunc


func _FindRichText($bSilent = False)

	local $sFindText = GUICtrlRead ($_gFindReplaceFindText)
	local $sFoundLoc
	local $iSearchStart
	local $bNotFound = True
	local $bReturn = False


	$_gFindReplaceLastFindText = $sFindText

	$iSearchStart = _GuiCtrlRichEdit_GetSel($_gEditScript)
	$iSearchStart = $iSearchStart [1]

	$sFoundLoc = _GUICtrlRichEdit_FindTextInRange($_gEditScript, $sFindText, $iSearchStart)

	if IsArray($sFoundLoc) then
		if $sFoundLoc[0] = -1 then
			$bNotFound = True
		Else
			$bNotFound = False
			_GUICtrlRichEdit_SetSel($_gEditScript, $sFoundLoc[0], $sFoundLoc[1], False)
			WinActivate($_gFindReplaceForm)
		endif
	endif

	if $bNotFound and $bSilent = False then
		;GUISetStyle (0x04CC0000,$iDisableTop, $_gFindReplaceForm )
		sleep(1)
		WinSetOnTop ($_gFindReplaceForm,"",False)
		sleep(1)
		WinActive($_gFindReplaceForm)
		_ProgramInformation("Can not find the string '" & $sFindText &  "'")
		if WinGetHandle($_gFindReplaceForm) <> 0  and $_gFindReplaceForm <> "" then WinSetOnTop ($_gFindReplaceForm,"",True)
		sleep(1)

	endif

	$bReturn = not($bNotFound)


	return $bReturn

endfunc


func _ReplaceRichText()

	local $sFindText = GUICtrlRead ($_gFindReplaceFindText)
	local $sReplaceText = GUICtrlRead ($_gFindReplaceReplaceText)
	local $iChangeCount = 0

	$_gFindReplaceLastFindText = $sFindText
	$_gFindReplaceLastReplaceText = $sReplaceText

	While _FindRichText(True) = True
		;debug($sReplaceText)
		$iChangeCount += 1
		_GUICtrlRichEdit_ReplaceText($_gEditScript, $sReplaceText, True)

	wend

	if $iChangeCount = 0 then
		sleep(1)
		WinSetOnTop ($_gFindReplaceForm,"",False)
		sleep(1)
		WinActive($_gFindReplaceForm)
		_ProgramInformation("Can not find the string '" & $sFindText &  "'")
		sleep(1)
		if WinGetHandle($_gFindReplaceForm) <> 0  and $_gFindReplaceForm <> "" then WinSetOnTop ($_gFindReplaceForm,"",True )
		sleep(1)
	Else
		sleep(1)
		WinSetOnTop ($_gFindReplaceForm,"",False)
		sleep(1)
		WinActive($_gFindReplaceForm)
		if WinGetHandle($_gFindReplaceForm) <> 0  and $_gFindReplaceForm <> "" then WinSetOnTop ($_gFindReplaceForm,"",True )
		sleep(1)

	endif


endfunc