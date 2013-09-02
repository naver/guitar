#include-once

#include "UIACommon.au3"
#include "UIAImageList.au3"

#include <GUIConstantsEx.au3>
#include <EditConstants.au3>
#Include <GuiButton.au3>
#include <GUIComboBox.au3>


#Include <ScreenCapture.au3>

#include <WindowsConstants.au3>
#include <Winapi.au3>
#include <Misc.au3>

#include <Date.au3>

;----- example 3 PNG work araund by Zedna
#include <WindowsConstants.au3>
#include <GDIPlus.au3>
#Include <WinAPI.au3>

#include ".\_include_nhn\_util.au3"
#include ".\_include_nhn\_ImageGetInfo.au3"

Global $_bScreenCapture = False

Global $_bCancelCapture
Global $_gCaptureForm
Global $_gSavePath
Global $_gAddTransparent
Global $_gFileName
Global $_gFileList
Global $_gFileSave
Global $_gCapture
Global $_gMsPaint
Global $_gPostFix
Global $_gDeleteXY
Global $_gImageMng
Global $_gCreateXY
Global $_gPutClipBoard
Global $_gCaptureImageFrame
Global $_gCaptureWindowHandle

Global $_hPNGImage
Global $_hPNGGraphic
Global $_hPNGBitmap

Global $_PicLeft = 30
Global $_PicTop = 270
Global $_PicWidth = 1920
Global $_Picheight = 1080
Global $_CurPicWidth
Global $_CurPicheight

global $_gBMPPic

Global $_sCapturePath
Global $_sCaptureFile

Global $_bScreenCaptureSuccess
Global $_iScreenMouseStatus

Global $_sLastUsedBrowserPostFix
Global $_sCurrentPostFix

Global $_sTempPicFile = @TempDir & "\temp_capture.png"
Global $_sTempPicBMPFile = @TempDir & "\temp_capture.bmp"

Global $_sImageRangeXY
Global $_sLastSavedFileName
Global $_sCaptureFirstImageFolder
Global $_bCaptureImageSaved
Global $_gCaptureStatus






func _FormCaptureLoad()

	local $iFormLeft = 10
	local $iFormTop = 10

	local $iFormWidth = 1000
	local $iFormHeight = 600

	local $x
	local $xAdd
	local $y
	local $yAdd

	local $i

	local $iDefaultTextWidth = 20
	local $iDefaultButtonWidth = 30
	local $iDefaultLeft = 20

	local $gPathSelect
	local $gPathOpen

	local $gEnd
	local $iLastFormX, $iLastFormY
	local $sHelp


	;$_gCaptureForm = GUICreate($_sProgramName, $iFormWidth,  $iFormHeight,-1,-1,"","",$_gForm)


	AutoItSetOption("GUICloseOnESC", 1)

	$iLastFormX = _readSettingReg ("LastCaptureX")
	$iLastFormY = _readSettingReg ("LastCaptureY")

	; 모니터상에 있는 좌표인지 확인
	if number(GetMonitorFromPoint($iLastFormX, $iLastFormY)) = 0 then
		$iLastFormX = 0
		$iLastFormY = 0
	endif

	$_gCaptureForm = GUICreate($_sProgramName & " Capture", $iFormWidth,  $iFormHeight, $iLastFormX, $iLastFormY ,default,default)


	GUICtrlCreateGroup(_getLanguageMsg ("Capture_Manager"),$iFormLeft, $iFormTop, $iFormWidth - $iFormLeft * 2 , 210)

	; 저장경로
	$x = $iDefaultLeft
	$y = 40
	$xAdd = 70
	GUICtrlCreateLabel(_getLanguageMsg ("Capture_SavePath") & " ", $x , $y, $x + $xAdd)

	$x += $xAdd
	$xAdd = 600 - 10
	$_gSavePath = GUICtrlCreateCombo("" , $x , $y - 5 , $xAdd, $iDefaultButtonWidth, $CBS_DROPDOWNLIST) ;

	$x += $xAdd
	$x += 10
	$xAdd = 90
	$gPathSelect = GUICtrlCreateButton(_getLanguageMsg ("capture_changepath"),$x , $y - 5,$xAdd,$iDefaultTextWidth)
	GUICtrlSetTip(-1, _getLanguageMsg ("capture_setpath"))
	$x += $xAdd + 5
	$gPathOpen = GUICtrlCreateButton(_getLanguageMsg ("imgsearch_openexp"),$x , $y - 5,$xAdd,$iDefaultTextWidth)
	GUICtrlSetTip(-1, _getLanguageMsg ("capture_openexptooltip"))



	$x = $iDefaultLeft
	$xAdd = 70
	$y +=  60
	GUICtrlCreateLabel(_getLanguageMsg ("capture_bestlist"), $iDefaultLeft, $y -25 , $xAdd)
	$_gFileList = GUICtrlCreateInput("" , $x + $xAdd , $y - 30 , 900 - 10, $iDefaultTextWidth, $ES_READONLY)

	; 파일명(제목)
	$y +=  10
	$x = $iDefaultLeft
	$xAdd = 70
	GUICtrlCreateLabel(_getLanguageMsg ("capture_filename") & "(&F) :", $x , $y, $x + $xAdd)
	$x += $xAdd
	$xAdd = 300 - 10
	$_gFileName = GUICtrlCreateCombo("" , $x , $y - 5 , $xAdd, $iDefaultButtonWidth)
	$x += $xAdd + 5
	$xAdd = 200
	$_gPostFix = GUICtrlCreateLabel("", $x , $y, $x + $xAdd, 15)

	$y += 25
	$x = $iDefaultLeft + 70
	$xAdd = 110
	$_gDeleteXY = GUICtrlCreateButton(_getLanguageMsg ("capture_positionremove") & "(&R)",$x , $y - 5,$xAdd,$iDefaultTextWidth)
	GUICtrlSetTip(-1, _getLanguageMsg ("capture_positionremove"))

 	$x = $x + $xAdd + 10
	$xAdd = 110
	$_gAddTransparent = GUICtrlCreateButton(_getLanguageMsg ("capture_addtrans") & '(&T)',$x , $y - 5,$xAdd,$iDefaultTextWidth)
	GUICtrlSetTip(-1, _getLanguageMsg ("capture_addtrans"))

	$x = $x + $xAdd + 10  + 50
	$xAdd = 110
	$_gCreateXY = GUICtrlCreateButton(_getLanguageMsg ("capture_positioncreate") & "(&O)",$x , $y - 5,$xAdd,$iDefaultTextWidth)
	GUICtrlSetTip(-1, _getLanguageMsg ("capture_positioncreate"))

	; 캡쳐, 저장, 종료
	$y +=  40

	$x = $iDefaultLeft + 70

	$_gCapture = GUICtrlCreateButton(_getLanguageMsg ("capture_capture") & "(&C)  " , $x , $y - 5 , $xAdd, $iDefaultButtonWidth)
	GUICtrlSetTip(-1, _getLanguageMsg ("capture_capture"))

	$x += $xAdd
	$x += 10

	$_gFileSave = GUICtrlCreateButton(_getLanguageMsg ("capture_save") & "(&S)  " , $x , $y - 5 , $xAdd, $iDefaultButtonWidth, $BS_DEFPUSHBUTTON)
	GUICtrlSetTip(-1, _getLanguageMsg ("capture_save"))

	$x += $xAdd
	$x += 10

	$_gMsPaint = GUICtrlCreateButton(_getLanguageMsg ("imgsearch_edit") & "(&P)" , $x , $y - 5 , $xAdd, $iDefaultButtonWidth)
	GUICtrlSetTip(-1, _getLanguageMsg ("imgsearch_edit"))

	$x += $xAdd
	$x += 10

	$_gPutClipBoard = GUICtrlCreateButton(_getLanguageMsg ("capture_fromclipboard") & "(&B)" , $x , $y - 5 , $xAdd, $iDefaultButtonWidth)
	GUICtrlSetTip(-1, _getLanguageMsg ("capture_fromclipboard"))

	$x += $xAdd
	$x += 10
	$_gImageMng = GUICtrlCreateButton(_getLanguageMsg ("capture_imagemanager") & "(&M)" , $x , $y - 5 , $xAdd, $iDefaultButtonWidth)
	GUICtrlSetTip(-1, _getLanguageMsg ("capture_imagemanager"))



	$x += $xAdd
	$x += 10
	$gEnd = GUICtrlCreateButton(  _getLanguageMsg ("imgsearch_close") & "(&X)" , $x , $y - 5 , $xAdd, $iDefaultButtonWidth)
	GUICtrlSetTip(-1, _getLanguageMsg ("imgsearch_close"))

	; 캡쳐 이미지
	$y +=  65
	$x = $iDefaultLeft
	$xAdd = 140
	;GUICtrlCreateLabel("캡쳐 이미지 : ", $x , $y, $x + $xAdd)

	GUICtrlCreateGroup(_getLanguageMsg ("capture_captureimage") ,$iFormLeft, $y, $iFormWidth - $iFormLeft * 2 , 330)

	$_gCaptureImageFrame= GUICtrlCreateLabel(" ",10000, -1000 ,0, 0, $SS_BLACKFRAME)

	$_gBMPPic = GUICtrlCreatePic("", 0, 0, 0, 0)

	; 하단실시간 로그창
	$_gCaptureStatus = GUICtrlCreateLabel("" , 0 , $iFormHeight - 18, $iFormWidth, 18, BitOR($SS_SIMPLE, $SS_SUNKEN))


	; 이벤트 등록
	Opt("GUIOnEventMode", 1)
	GUISetOnEvent($GUI_EVENT_CLOSE, "onClickFormClose", $_gCaptureForm)
	GUICtrlSetOnEvent($gPathSelect, "onClickPathSelect")
	GUICtrlSetOnEvent($gPathOpen, "onClickPathOpen")
	GUICtrlSetOnEvent($_gCapture, "setScreenCaptureOn")
	GUICtrlSetOnEvent($_gFileSave, "onClickFileSave")
	GUICtrlSetOnEvent($_gMsPaint, "onClickMsPaint")
	GUICtrlSetOnEvent($gEnd, "onClickFormClose")
	GUICtrlSetOnEvent($_gDeleteXY, "onClickDeleteXY")
	GUICtrlSetOnEvent($_gImageMng, "onClickCaptureImageMng")
	GUICtrlSetOnEvent($_gCreateXY, "onClickCreateXY")
	GUICtrlSetOnEvent($_gPutClipBoard, "onClickPutClipBoard")
	GUICtrlSetOnEvent($_gAddTransparent, "onClickAddTransparent")



	_setSavePath($_sCapturePath)

	setComboListUpdate()

	$_bCaptureImageSaved = True
	$_bScreenCapture = True

	sleep(1)
	;WinSetState($_gCaptureForm, "", @SW_SHOW)
	;GUISetState()
	sleep(1)

	_GDIPlus_StartUp()

	; 기본값 초기화

	;debug($_sCapturePath, $_sCaptureFile)
	;_setSavePath($_sCapturePath)

endfunc


func setCaptureLastImageFolderComboListUpdate()

	local $i
	local $sList = ""
	local $aFolderList = _getRecentImageFolder()

	_GUICtrlComboBox_ResetContent($_gSavePath)

	_GUICtrlComboBox_BeginUpdate($_gSavePath)
	;_msg($_sCaptureFirstImageFolder)
	_GUICtrlComboBox_AddString($_gSavePath, $_sCaptureFirstImageFolder )
	for $i=1 to ubound($aFolderList) -1
		if $_sCaptureFirstImageFolder <> $aFolderList[$i] then _GUICtrlComboBox_AddString($_gSavePath, $aFolderList[$i])
		;debug($_aDefaultCaptureFileList[$i])
	next
	_GUICtrlComboBox_EndUpdate($_gSavePath)
	_GUICtrlComboBox_SetCurSel($_gSavePath, 0)

endfunc


func setComboListUpdate()

	local $i
	local $sList  = ""

	_GUICtrlComboBox_ResetContent($_gFileName)

	_GUICtrlComboBox_BeginUpdate($_gFileName)
	for $i=1 to ubound($_aDefaultCaptureFileList) -1
		_GUICtrlComboBox_AddString($_gFileName, $_aDefaultCaptureFileList[$i][1])
		if $sList  <> "" then $sList  = $sList  & ", "
		$sList = $sList & $_aDefaultCaptureFileList[$i][1]

		if $i=1 then
			if 	$_aDefaultCaptureFileList[$i][2] <> "" then
				_setSavePath(stringtrimright(_GetPathName($_aDefaultCaptureFileList[$i][2]),1))
			else
				_setSavePath($_sCapturePath)
			endif
			;_msg("경로설정:" & _GetPathName(  $_aDefaultCaptureFileList[$i][2]))
		endif
		;debug($_aDefaultCaptureFileList[$i])
	next
	_GUICtrlComboBox_EndUpdate($_gFileName)
	_GUICtrlComboBox_SetCurSel($_gFileName, 0)

	GUICtrlSetData  ($_gFileList, $sList)

endfunc


func setScreenCaptureMouse()
	if $_bScreenCapture then
		if $_iScreenMouseStatus = 0 or $_iScreenMouseStatus = 2 then
			$_iScreenMouseStatus = 1
		Else
			$_iScreenMouseStatus = 2
		endif

	Else
		$_iScreenMouseStatus = 0
	endif
endfunc


func setScreenCaptureOn()

	local $bResult
	local $sCaptureName
	local $iLastCaptureWindow
	local $i
	local $sCaptureHelp

	$sCaptureHelp = _getLanguageMsg ("Capture_Tooltip0") & @cr
	$sCaptureHelp = $sCaptureHelp  &  "  " & _getLanguageMsg ("Capture_Tooltip1") & @cr
	$sCaptureHelp = $sCaptureHelp  &  "  " & _getLanguageMsg ("Capture_Tooltip2") & @cr
	$sCaptureHelp = $sCaptureHelp  &  "  " & _getLanguageMsg ("Capture_Tooltip3") & @cr
	$sCaptureHelp = $sCaptureHelp  &  "  " & _getLanguageMsg ("Capture_Tooltip4") & @cr


	SelectHotKey("capture")
	SetCaptureStatus ("")
	deleteCaptureName()

	$sCaptureName=_getSaveFile()
	if $sCaptureName = 0 then $sCaptureName = ""

	if $sCaptureName = 0 then
		if ubound($_aDefaultCaptureFileList) > 1 then
			$sCaptureName = $_aDefaultCaptureFileList[1][1]
		endif
	endif

	$_bCancelCapture = False

	$_bScreenCapture = True


	;TrayTip($_sProgramName, "화면 캡쳐 중 : " &  $sCaptureName & @Crlf & "캡쳐 시작/종료 단축키 :CTRL + SHIFT + X" ,5,1)
	TrayTip($_sProgramName, "화면 캡쳐 중 : " &  $sCaptureName & @Crlf & @Crlf & $sCaptureHelp ,5,1)
	if FileExists($_sTempPicFile) then FileDelete($_sTempPicFile)

	if IsHWnd ($_gCaptureForm) = 0 then _FormCaptureLoad()


	if IsHWnd ($_gCaptureForm) = 1 then
		_GUICtrlButton_Enable($_gCapture,False)
		WinSetState($_gCaptureForm, "", @SW_MINIMIZE)
	endif

	if IsHWnd($_gCaptureWindowHandle) then
		;debug("$_gCaptureWindowHandle")
		$iLastCaptureWindow = $_gCaptureWindowHandle
	else
		if IsHWnd($_hBrowser)  then
			$iLastCaptureWindow = $_hBrowser
			;debug("$_hBrowser")
		else
			_getLastBrowserInfo	()
			if IsHWnd($_hBrowser) then
				$iLastCaptureWindow = $_hBrowser
				;debug("$_hBrowser2")
			endif
		endif
	endif


	if IsHWnd($iLastCaptureWindow) then
		WinSetState("",$iLastCaptureWindow, @SW_SHOW)
		WinActivate($iLastCaptureWindow)
		;msg("윈도우 액티브")

	endif

	$_iScreenMouseStatus = 0

	$bResult = ScreenCapture()


	sleep(1)
	; 편집기를 열지 않도록 설정된 경우 캡쳐윈도우를 열지 않도록 함
	if not ($bResult = True and $_runAlwaysImageEdit = True) then
		WinSetState($_gCaptureForm, "" , @SW_SHOW)
		GUISetState(@SW_SHOW, $_gCaptureForm)
	endif
	sleep(1)

	SelectHotKey("")

	if $_bScreenCaptureSuccess and $_sImageRangeXY = "" then
		if _ProgramQuestion(_getLanguageMsg ("capture_positionerror")) = True  then
			setScreenCaptureOn()
			return
		endif
	endif

	if $bResult  = False then
		if FileExists($_sTempPicFile) then FileDelete($_sTempPicFile)
		if $_bCancelCapture = False then
			_ProgramError(_getLanguageMsg ("capture_sizeerror"))
		else
			SetCaptureStatus (_getLanguageMsg ("capture_cancel"))
		endif
	else
		SetCaptureStatus (_getLanguageMsg ("capture_done"))
		if $_runAlwaysImageEdit then

			onClickMsPaint()

		endif

		$_bCaptureImageSaved = False
	endif

	MouseBusy (True)

	setScreenCaptureOff()


	WinSetState($_gCaptureForm, "" , @SW_RESTORE)


	MouseBusy (False)

	WinActivate($_gCaptureForm)

	sleep (500)

	for $i=1 to 3
		if WinActivate($_gCaptureForm) <> 0 then exitloop
		sleep (100 * $i)
	next

	sleep (100)

	;WinSetOnTop ( $_gCaptureForm, "", 1)

	WinSetState($_gCaptureForm, "" , @SW_RESTORE)
	WinActivate($_gCaptureForm)

	;WinSetOnTop ($_gCaptureForm, "", 0)
	sleep (10)

EndFunc


func setScreenCaptureOff()

	local $iOldFileIndex

	;WinSetState($_gCaptureForm, "", @SW_SHOW)

	_GUICtrlButton_Enable($_gCapture,True)

	if FileExists($_sTempPicFile) = 1 then
		_GUICtrlButton_Enable($_gFileSave,True)
	Else
		_GUICtrlButton_Enable($_gFileSave,False)
	endif

EndFunc


func deleteCaptureName()

	local $iOldFileIndex

	if $_sLastSavedFileName <> "" then

		$iOldFileIndex = _ArraySearch($_aDefaultCaptureFileList,$_sLastSavedFileName,1,0,0,0,1,1)

		;debug("지우러옴:" & $iOldFileIndex )
		;msg($_sLastSavedFileName)
		;msg($_aDefaultCaptureFileList)

		if  $iOldFileIndex <> -1 then
			_ArrayDelete($_aDefaultCaptureFileList,$iOldFileIndex)
			;_ArrayAdd($_aDefaultCaptureFileList, $_sLastSavedFileName)
			$_sLastSavedFileName = ""
			setComboListUpdate ()
		endif
	endif

endfunc


func _getSavePath ()
	return GUICtrlRead ($_gSavePath)
endfunc


func _getSaveFile ()

	local $sRet = GUICtrlRead ($_gFileName)

	;if $sRet = 0 then $sRet = ""

	return $sRet
endfunc


func _setSavePath ($sPath)
	$_sCaptureFirstImageFolder = $sPath
	setCaptureLastImageFolderComboListUpdate()
	;GUICtrlSetData  ($_gSavePath, $sPath)
endfunc


func _setPostFix ($sPostFix)

	;debug($sPostFix)
	GUICtrlSetData  ($_gPostFix, $sPostFix)

endfunc


func _getPostFix ()
	return GUICtrlRead ($_gPostFix)
endfunc


func onClickCreateXY ()

	local $sNewXY
	local $sPos

	if $_aLastUseMousePos[1] = "" then
		_ProgramError(_getLanguageMsg ("capture_positioncopyerror") )
		return
	endif

	$sPos = getImageRangeXYFromString($_sImageRangeXY)

	;debug($sPos)

	;debug($_aLastUseMousePos)

	$sNewXY  = """|$GUITAR_RecentXPos| + " & $sPos[1] - $_aLastUseMousePos[1] & ","
	$sNewXY &= "|$GUITAR_RecentYPos| + " & $sPos[2] - $_aLastUseMousePos[2] & ","
	$sNewXY &= "|$GUITAR_RecentXPos| + " & $sPos[1] - $_aLastUseMousePos[1] + $sPos[3] & ","
	$sNewXY &= "|$GUITAR_RecentYPos| + " & $sPos[2] - $_aLastUseMousePos[2] + $sPos[4] & """"


	ClipPut($sNewXY)

	_ProgramInformation(_getLanguageMsg ("capture_positioncopy") & @crlf & @crlf & $sNewXY)

endfunc

func onClickCaptureImageMng ()


	Opt("GUIOnEventMode", 0)

	guisetstate(GUISetState() + @SW_DISABLE,$_gCaptureForm)

	onClickImageMng(_getSavePath() & "\" )


	guisetstate(GUISetState() + @SW_ENABLE,$_gCaptureForm)
	Opt("GUIOnEventMode", 1)

endfunc


func onClickFileSave()

	local $sNewFile
	local $sNewFilePattern
	local $sFileName = _trim(_getSaveFile())
	local $aDeleteList [1]
	local $aDeleteListTemp
	local $sDeleteList = ""
	local $i
	local $aGlobalImageSearch
	local $iArrayDeleteID
	local $sAnswer

	$_sLastSavedFileName = $sFileName

	if $sFileName = "" then
		_ProgramError(_getLanguageMsg ("capture_filenameerror"))
		return
	endif

	$sFileName = $sFileName & _getPostFix()

	$sNewFile = _getSavePath () & "\" & $sFileName

	SetCaptureStatus (_getLanguageMsg ("capture_filesave") & " " & $sNewFile)

	_GUICtrlButton_Enable($_gFileSave,False)

	; 동일 조건의 이름이 존재하는 경우 (OS 정보가 있는 경우)

	if StringInStr($sNewFile,"_[") > 0 then
		$sNewFilePattern = StringLeft($sNewFile, StringInStr($sNewFile,"_[") -1)
	else
		$sNewFilePattern = StringLeft($sNewFile, StringInStr($sNewFile,$_cImageExt) -1)
	endif

	$sNewFilePattern = StringReplace($sNewFilePattern, _GetPathName($sNewFile), "")

	;debug(_getSavePath () & "\" & $sNewFilePattern  & ".png")

	if FileExists (_getSavePath () & "\" & $sNewFilePattern  & $_cImageExt) then
		_ArrayAdd( $aDeleteList, _getSavePath () & "\"& $sNewFilePattern  & $_cImageExt)
	endif

	$aDeleteListTemp = _GetFileNameFromDir(_getSavePath () ,$sNewFilePattern & "_[*" & $_cImageExt, 0)
	;debug(_getSavePath() & " " & $sNewFilePattern & "_[*.png")

	if IsArray($aDeleteListTemp) and ubound($aDeleteListTemp) > 1 then
		if ubound ($aDeleteList) > 1 then _ArrayAdd($aDeleteListTemp, $aDeleteList[1])
		$aDeleteList = $aDeleteListTemp
	Else
		if IsArray($aDeleteListTemp) = False and $aDeleteList <> "" then  _ArrayAdd( $aDeleteList, $aDeleteListTemp)
	endif

	if ubound($aDeleteList) > 1 then
		$sDeleteList = _ArrayToString($aDeleteList,"|",1)
		;debug($sDeleteList)
		$sDeleteList = StringReplace($sDeleteList,"|",@crlf)
		;debug($sDeleteList)
	endif



	if $sDeleteList <> "" then $sDeleteList =  _getLanguageMsg ("capture_deletlist") & " " & @crlf & $sDeleteList & @crlf

	;debug($aDeleteList)
	;_msg($sDeleteList)

	if ubound($aDeleteList) > 1 then
		$sAnswer = _ProgramQuestionYNC(_getLanguageMsg ("capture_deleteconfirm") & @crlf & @crlf & $sDeleteList)
		if $sAnswer = "Y" then
			for $i=1 to ubound ($aDeleteList) -1
				if FileDelete($aDeleteList[$i]) = 0 then _ProgramError(_getLanguageMsg ("capture_deleteerror") & " " & $aDeleteList[$i])
			next

			_UpdateFolderFileInfo(True)

		Elseif $sAnswer = "C" then
			_GUICtrlButton_Enable($_gFileSave,True)
			return
		endif
	endif

	$aDeleteList = _findFolderFileInfo($_sImageForderFileList,  _trim(_getSaveFile()) & $_cImageExt & "|" &   _trim(_getSaveFile()) & "_", False )

	;debug("전체폴더 검색명:" & _GetPathname($sNewFilePattern), _trim(_getSaveFile()))


	if ubound($aDeleteList) > 1 then

		$iArrayDeleteID = _ArraySearch($aDeleteList, _GetPathname($sNewFile) ,  0,0,0,1,1)


		while $iArrayDeleteID <> -1
			_ArrayDelete($aDeleteList,$iArrayDeleteID)
			$iArrayDeleteID = _ArraySearch($aDeleteList, _GetPathname($sNewFile) ,  0,0,0,1,1)
		wend


	endif

	if ubound($aDeleteList) > 1 then
		$sDeleteList = _ArrayToString($aDeleteList,"|",1)
		;debug($sDeleteList)
		$sDeleteList = StringReplace($sDeleteList,"|",@crlf)
		;debug($sDeleteList)
	endif


	if $sDeleteList <> "" then $sDeleteList =  _getLanguageMsg ("capture_existslist") & " " & @crlf & $sDeleteList & @crlf

	if ubound($aDeleteList) > 1 then
		if _ProgramQuestion(_getLanguageMsg ("capture_existsconfirm") & @crlf & @crlf & $sDeleteList , 48) = False then
			_GUICtrlButton_Enable($_gFileSave,True)
			Return
		endif
	endif

	if FileExists(_GetPathName($sNewFile)) = 0 then DirCreate (_GetPathName($sNewFile))

	if FileExists($sNewFile) then
		if _ProgramQuestion(_getLanguageMsg ("capture_existsdeleteconfirm") & @crlf & @crlf & $sNewFile) = True then
			if FileDelete($sNewFile) = 0 then
				_ProgramError(_getLanguageMsg ("capture_existsdeleteerror")  & " " & $sNewFile)
				_GUICtrlButton_Enable($_gFileSave,True)
				return
			endif
		Else
			_ProgramInformation(_getLanguageMsg ("capture_saveerror1") & @crlf & @crlf & $sNewFile)
			_GUICtrlButton_Enable($_gFileSave,True)
			return
		endif
	endif

	if filecopy ($_sTempPicFile, $sNewFile)  = 0 then
		_ProgramError(_getLanguageMsg ("capture_saveerror2") & @crlf & $sNewFile)
		_GUICtrlButton_Enable($_gFileSave,True)
		return
	endif

	;_ProgramInformation("정상적으로 저장되었습니다.                  " & @crlf & @crlf & $sNewFile)
	SetCaptureStatus (_getLanguageMsg ("capture_savedone") & " " & $sNewFile)


	$_bUpdateForderFileList = True
	$_bCaptureImageSaved = True
	_GUICtrlButton_Enable($_gFileSave,True)

endfunc


func onClickPathOpen()

	ShellExecute("explorer.exe" , _getSavePath())

endfunc


func onClickAddTransparent()

	if stringinstr($_sCurrentPostFix , $_sTransparentKey) = 0 then $_sCurrentPostFix = $_sTransparentKey & $_sCurrentPostFix
	_setPostFix($_sCurrentPostFix)

EndFunc


func onClickDeleteXY()

	$_sCurrentPostFix = stringReplace($_sCurrentPostFix, "_" & $_sImageRangeXY, "")
	_setPostFix($_sCurrentPostFix)

endfunc


func onClickPathSelect()

	local $sNewPath

	;debug(_getSavePath())
	$sNewPath = FileSelectFolder("Choose a folder.",  "" ,1,_getSavePath(), $_gCaptureForm)


	if $sNewPath <> "" then
		;$_sCapturePath = $sNewPath
		_setSavePath ($sNewPath)
		_writeRecentImageFolder($sNewPath)
	endif

endfunc


func onClickMsPaint()

	local $sFileName = _trim(_getSaveFile())
	local $sNewFile


	MouseBusy (True)

	$sFileName = $sFileName & _getPostFix()

	$sNewFile = _getSavePath () & "\" & $sFileName

	if FileExists($_sTempPicFile) then
		;WinActivate($_gCaptureForm)
		guisetstate(GUISetState() + @SW_DISABLE,$_gCaptureForm)

		ShellExecuteWait ( $_runImageEditor,$_sTempPicFile)

		MouseBusy (True)

		LoadPic()

		sleep(1)
		GUISetState(@SW_SHOW, $_gCaptureForm)
		sleep(1)

		guisetstate(GUISetState() + @SW_ENABLE,$_gCaptureForm)

		GUICtrlSetState ($_gFileName,$GUI_FOCUS)

		MouseBusy (False)

		;WinActivate($_gCaptureForm)
	Else
		MouseBusy (False)
		_ProgramError(_getLanguageMsg ("capture_emptyerror"))
	endif

endfunc


func ScreenCapture()

	;$_bScreenCapture = not $_bScreenCapture
	$_bScreenCaptureSuccess = False

	While 1
		Sleep(10)
		;if not $_bScreenCapture or  = True then exitloop
		; 만약 자신 윈도우에 있는 경우라면 제외
		;if checkFormWindowRange() = True then exitloop
		;If _IsPressed("01") or $_iScreenMouseStatus = 1 Then
		if $_bCancelCapture = True then exitloop

		If $_iScreenMouseStatus = 1 Then

			$_gCaptureWindowHandle = WinGetHandle("[ACTIVE]")


			While _IsPressed("01")
				Sleep(10)
				if $_bCancelCapture = True then

					exitloop
				endif
			WEnd

			if $_bCancelCapture = True then

				exitloop
			endif
			_CreateDragGui()
			; 1회만 캡쳐 하도록 함

			exitloop
		EndIf
	WEnd

	;setScreenCaptureOff()

	if _getPostFix () <> $_sCurrentPostFix then _setPostFix($_sCurrentPostFix)

	$_bScreenCapture = False

	TrayTip($_sProgramName, "",1)

	if $_runAlwaysImageEdit = False then
		MouseBusy (True)
		LoadPic()
		MouseBusy (False)
	endif

	; 스크린 캡쳐가 실행된 경우
	;if $_bScreenCaptureSuccess = True then
		;loadpic()
	;endif
		;_GUICtrlButton_Enable($_gFileSave,False)

	return $_bScreenCaptureSuccess

endfunc


func CancelCapture()

	$_bCancelCapture = True

endfunc


Func _CreateDragGui()

	local $aPosMouseInitial
	local $gui_Drag
	local $aPosMouse
	local $aPosWin
	local $aPosLastMouse
	local $aImageRange[4]
	local $sImagePostFix
	local $iDefaultWidth = 25
	local $iDefaultHeight = 25

    $aPosMouseInitial = MouseGetPos()

    $gui_Drag = GUICreate("GuiDrag", $iDefaultWidth, $iDefaultHeight, $aPosMouseInitial[0], $aPosMouseInitial[1], $WS_POPUP, BitOR($WS_EX_TOOLWINDOW, $WS_EX_LAYERED,$WS_EX_TOPMOST))

    MouseMove($aPosMouseInitial[0] + $iDefaultWidth, $aPosMouseInitial[1] + $iDefaultHeight,0)

    GUICtrlCreateLabel("", 0, 0, $iDefaultWidth, 1)
    GUICtrlSetBkColor(-1, 0x00ff00)
    GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKHEIGHT)

    GUICtrlCreateLabel("", 0, 0, 1, $iDefaultHeight)
    GUICtrlSetBkColor(-1, 0x00ff00)
    GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH)

    GUICtrlCreateLabel("", 0,$iDefaultWidth -1 ,$iDefaultHeight,1)
    GUICtrlSetBkColor(-1, 0x00ff00)
    GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKHEIGHT)

    GUICtrlCreateLabel("", $iDefaultWidth - 1 ,0,1,$iDefaultHeight)
    GUICtrlSetBkColor(-1, 0x00ff00)
    GUICtrlSetResizing(-1, $GUI_DOCKRIGHT + $GUI_DOCKTOP + $GUI_DOCKWIDTH)

    ;GUISetBkColor(0xABCDEF)
    ;_WinAPI_SetLayeredWindowAttributes($gui_Drag, 0xABCDEF, 255)

    GUISetBkColor(0x000000)
    _WinAPI_SetLayeredWindowAttributes($gui_Drag, 0x000000, 255)

	GUISetState(@SW_SHOW)

	WinActivate($_gCaptureWindowHandle)

    While 1

        Sleep(10)

        $aPosMouse = MouseGetPos()

        Select
            Case ($aPosMouse[0] >= $aPosMouseInitial[0]) AND ($aPosMouse[1] >= $aPosMouseInitial[1])
                WinMove($gui_Drag, "", $aPosMouseInitial[0], $aPosMouseInitial[1], $aPosMouse[0] - $aPosMouseInitial[0], $aPosMouse[1] - $aPosMouseInitial[1])
            Case ($aPosMouse[0] < $aPosMouseInitial[0]) AND ($aPosMouse[1] >= $aPosMouseInitial[1])
                WinMove($gui_Drag, "", $aPosMouse[0], $aPosMouseInitial[1], $aPosMouseInitial[0] - $aPosMouse[0], $aPosMouse[1] - $aPosMouseInitial[1])
            Case ($aPosMouse[0] >= $aPosMouseInitial[0]) AND ($aPosMouse[1] < $aPosMouseInitial[1])
                WinMove($gui_Drag, "", $aPosMouseInitial[0], $aPosMouse[1], $aPosMouse[0] - $aPosMouseInitial[0], $aPosMouseInitial[1] - $aPosMouse[1])
            Case ($aPosMouse[0] < $aPosMouseInitial[0]) AND ($aPosMouse[1] < $aPosMouseInitial[1])
                WinMove($gui_Drag, "", $aPosMouse[0], $aPosMouse[1], $aPosMouseInitial[0] - $aPosMouse[0], $aPosMouseInitial[1] - $aPosMouse[1])
        EndSelect

        ;If _IsPressed("01") or $_iScreenMouseStatus = 2 Then

		; 중간에 취소한 경우 탈출 할것
		if $_bCancelCapture = True then exitloop

		If $_iScreenMouseStatus = 2 Then

            $aPosWin = WinGetPos($gui_Drag)

			if $_PicWidth < + $aPosWin[2] -1 or  $_Picheight  <  $aPosWin[3] -1 then

				ExitLoop
			endif

            ;debug( $aPosWin[0] & "x" & $aPosWin[1] & @CRLF & $aPosWin[2] & "x" & $aPosWin[3])

			;WinSetState("GuiDrag","",@SW_DISABLE )

			if FileExists($_sTempPicFile) then FileDelete($_sTempPicFile)
			$aPosLastMouse = MouseGetPos()
			MouseMove(1,1,0)
			_ScreenCapture_Capture($_sTempPicFile, $aPosWin[0] +1 , $aPosWin[1] +1  ,$aPosWin[0] + $aPosWin[2] -2 ,$aPosWin[1] + $aPosWin[3] -2)
			$_hPNGBitmap = _ScreenCapture_Capture ("", $aPosWin[0] +1 , $aPosWin[1] +1  ,$aPosWin[0] + $aPosWin[2] -2 ,$aPosWin[1] + $aPosWin[3] -2)

			$aImageRange[0] = $aPosWin[0] +1
			$aImageRange[1] = $aPosWin[1] +1
			$aImageRange[2] = $aPosWin[2] -2 + $aImageRange[0]
			$aImageRange[3] = $aPosWin[3] -2 + $aImageRange[1]

			;debug("캡쳐 윈도우 핸들 : " & WinGetTitle ($_gCaptureWindowHandle))


			MouseMove($aPosLastMouse[0],$aPosLastMouse[1],0)

			_GDIPlus_GraphicsDispose($_hPNGGraphic)
			_GDIPlus_ImageDispose($_hPNGImage)

			$_CurPicWidth = $aPosWin[2]
			$_CurPicheight = $aPosWin[3]

			$_bScreenCaptureSuccess = True

			$_sImageRangeXY = setImageRangeXY($_gCaptureWindowHandle, $aImageRange)

			$sImagePostFix = getImagePostFix($_gCaptureWindowHandle)


			$_sCurrentPostFix = ""

			if StringInStr( $sImagePostFix, "UNKNOW")  = 0 then

				if StringInStr( $sImagePostFix, $_sBrowserIE)  > 0 then
					$sImagePostFix = ""
				else
					$_sCurrentPostFix = $_sCurrentPostFix & "_" & $sImagePostFix
				endif

				$_sCurrentPostFix = $_sCurrentPostFix &  _iif($_sImageRangeXY <> "" , "_" & $_sImageRangeXY, "")

			endif

			$_sCurrentPostFix = $_sCurrentPostFix & ".png"

            ExitLoop
        EndIf
    WEnd

	GUIDelete()

EndFunc   ;==>_CreateDragGui

; Load PNG image
Func LoadPic()

	local $aImageInfo
	local $iWidth
	local $iHeight



	if FileExists($_sTempPicBMPFile) then FileDelete($_sTempPicBMPFile)

	_PNG2BMP($_sTempPicFile, $_sTempPicBMPFile)

	$aImageInfo = _ImageGetInfo($_sTempPicBMPFile)
	$iWidth = _ImageGetParam($aImageInfo, "Width")
	$iHeight = _ImageGetParam($aImageInfo, "Height")

	GUICtrlSetPos ( $_gBMPPic, $_PicLeft, $_PicTop, $iWidth  ,$iHeight )
	GUICtrlSetImage ( $_gBMPPic, $_sTempPicBMPFile)

	GUICtrlSetPos ( $_gCaptureImageFrame , $_PicLeft-1,$_PicTop-1, $iWidth+2,$iHeight+2)

	GUISetState()

	;GUISetState(@SW_SHOW)
    ;_GDIPlus_GraphicsDrawImage($_hPNGGraphic, $_hPNGImage, $_PicLeft, $_PicTop)
	;_GDIPlus_GraphicsDrawRect($_hPNGGraphic, $_PicLeft-1, $_PicTop-1,$_CurPicWidth -1,$_CurPicheight-1)

endfunc


func onClickFormClose2()

	local $aWinPos
	local $bRet
	local $iTemp


	; Clean up resources\
	;setToolbar("DEFAULT")

	;AutoItSetOption("GUICloseOnESC", 0)

	;GUISwitch($_gForm)

	$iTemp = guisetstate(@SW_ENABLE,$_gForm)
	$iTemp = WinSetState($_gForm, "", @SW_RESTORE)

	$iTemp = GUIDelete ($_gCaptureForm)


	;WinActivate($_gForm)

	;Opt("GUIOnEventMode", 0)

	;$_bScreenCapture = False

	;SelectHotKey("main")

endfunc


func onClickFormClose()

	local $aWinPos
	local $bRet
	local $iTemp

	if $_bCaptureImageSaved = False then
		$bRet = _ProgramQuestionYN(_getLanguageMsg ("capture_exitconfirm"))
		if $bRet ="N" then  return
	endif

	writeDebugTimeLog("onClickFormClose start")

	$aWinPos = WinGetPos($_gCaptureForm)

	_writeSettingReg ("LastCaptureX", $aWinPos[0])
	_writeSettingReg ("LastCaptureY", $aWinPos[1])

	; Clean up resources\
	setToolbar("DEFAULT")

	writeDebugTimeLog("setToolbar")

	AutoItSetOption("GUICloseOnESC", 0)

	GUISwitch($_gForm)

	$iTemp = GUIDelete ($_gCaptureForm)

	writeDebugTimeLog("GUIDelete ($_gCaptureForm) : " & $iTemp)

	$iTemp = guisetstate(@SW_ENABLE,$_gForm)

	writeDebugTimeLog("guisetstate(@SW_ENABLE,$_gForm) : " & $iTemp)

	$iTemp = WinSetState($_gForm, "", @SW_RESTORE)

	WinActivate($_gForm)

	writeDebugTimeLog("WinSetState($_gForm, "", @SW_RESTORE) : " & $iTemp)

	_GUICtrlRichEdit_SetSel ($_gEditScript,$_aRichEditLastSelect[0],$_aRichEditLastSelect[1],False)

	writeDebugTimeLog("WinSetState($_gForm, "", @SW_RESTORE)")

	Opt("GUIOnEventMode", 0)

	$_bScreenCapture = False

	SelectHotKey("main")

	writeDebugTimeLog("SelectHotKey(main)")

	;if $_bUpdateForderFileList then
		onClickRefresh()
	;endif

	writeDebugTimeLog("onClickFormClose")

	;UpdateRichText($_gEditScript)

endfunc


func onClickPutClipBoard()

	if _saveClipBoardToFile ($_sTempPicFile) then

		$_sImageRangeXY = ""

		_setPostFix (".png")

		LoadPic()

		if FileExists($_sTempPicFile) = 1 then
			_GUICtrlButton_Enable($_gFileSave,True)
		Else
			_GUICtrlButton_Enable($_gFileSave,False)
		endif



	endif

endfunc


func getImagePostFix($hActiveWindow)

	local $sCurrentBrowser
	local $sBrowserEXE
	local $sPostFixBrowser = "UNKNOWN"
	local $sPostFixOS
	local $sProcessExe
	local $aBrowserClassFF = StringSplit($_sBrowserClassFF,"|")
	local $i

	; 핸들의 Class 이름을 확인
	local $sClassNames


	$sProcessExe = _ProcessGetName(WinGetProcess($_gCaptureWindowHandle))


	if getReadINI("BROWSER", $_sBrowserIE) = $sProcessExe then $sCurrentBrowser = $_sBrowserIE
	if getReadINI("BROWSER", $_sBrowserFF) = $sProcessExe then $sCurrentBrowser = $_sBrowserFF
	if getReadINI("BROWSER", $_sBrowserSA) = $sProcessExe then $sCurrentBrowser = $_sBrowserSA
	if getReadINI("BROWSER", $_sBrowserCR) = $sProcessExe then $sCurrentBrowser = $_sBrowserCR
	if getReadINI("BROWSER", $_sBrowserOP) = $sProcessExe then $sCurrentBrowser = $_sBrowserOP

	for $i=1 to ubound($_aBrowserOTHER) -1
		if $_aBrowserOTHER[$i][2] = $sProcessExe then $sCurrentBrowser = $_aBrowserOTHER[$i][1]
	next


	if $sCurrentBrowser = "" then

		$sClassNames = WinGetClassList($_gCaptureWindowHandle)

		if StringInStr($sClassNames,$_sBrowserClassIE) <> 0 then
			$sCurrentBrowser = $_sBrowserIE
		elseif StringInStr($sClassNames,$aBrowserClassFF[1]) <> 0  or StringInStr($sClassNames,$aBrowserClassFF[2]) <> 0  then
			$sCurrentBrowser = $_sBrowserFF
		elseif StringInStr($sClassNames,$_sBrowserClassSA) <> 0 then
			$sCurrentBrowser = $_sBrowserSA
		elseif StringInStr($sClassNames,$_sBrowserClassCR ) <> 0 then
			$sCurrentBrowser = $_sBrowserCR
		elseif StringInStr($sClassNames,$_sBrowserClassOP ) <> 0 then
			$sCurrentBrowser = $_sBrowserOP
		else
			$sCurrentBrowser =  "UNKNOW"
		endif
	endif


	$sPostFixBrowser = $sCurrentBrowser
	$_sLastUsedBrowserPostFix = $sPostFixBrowser

	;if $sCurrentBrowser <> "" then
		;$sBrowserEXE = getReadINI("BROWSER", $sCurrentBrowser)
		;$sPostFixBrowser = $sCurrentBrowser &  stringleft(FileGetVersion($sBrowserEXE,"ProductVersion"),1)
		;$_sLastUsedBrowserPostFix = $sPostFixBrowser
	;else
		;if $_sLastUsedBrowserPostFix <> "" then
			;$sPostFixBrowser = $_sLastUsedBrowserPostFix
		;else
			;$sPostFixBrowser = ""
		;endif
	;endif

	$sPostFixOS = stringreplace(@OSVersion,"_","")

	;return $sPostFixOS & "_" & $sPostFixBrowser
	return  $sPostFixBrowser

 endfunc


 func getImageRangeXYFromString($sXY)

	local $sRet = ""
	local $aPos[5]
	local $i
	local $sXyCovert

	if StringLeft($sXY,1) = "[" and StringRight($sXY,1) = "]"  Then

		$sXyCovert = Stringmid($sXY,2,stringlen($sXY)-2)
		$aPos = StringSplit($sXyCovert,".")
	endif

	return $aPos

endfunc


 func setImageRangeXY($oHwnd, $aNewPos)

	local $sRet = ""
	local $aWinPos


	$aWinPos = WinGetPos($oHwnd)

	if IsArray($aWinPos) then

		if 0 > $aNewPos[0] - $aWinPos [0]  or 0 > $aNewPos[1] - $aWinPos [1] then
			$sRet= ""
		elseif $aWinPos[2] < $aNewPos[0] - $aWinPos [0]  or $aWinPos [3] < $aNewPos[1] - $aWinPos [1] then
			$sRet= ""
		else

			$sRet = "["
			$sRet = $sRet & "" & StringFormat ("%03d", $aNewPos[0] - $aWinPos [0]) & "."
			$sRet = $sRet & "" & StringFormat ("%03d", $aNewPos[1] - $aWinPos [1]) & "."
			$sRet = $sRet & "" & StringFormat ("%03d", $aNewPos[2] - $aNewPos [0]) & "."
			$sRet = $sRet & "" & StringFormat ("%03d", $aNewPos[3] - $aNewPos [1]) & "]"
		endif
	endif


	return $sRet

endfunc


Func _saveClipBoardToFile($sFile)

    Local $hBmp, $hImage
	Local $hGUI
	local $bRet = False

	; Create GUI

	GUISetState()

    If Not _ClipBoard_Open(0) Then
		_ProgramError(_getLanguageMsg ("capture_clipboardopenerror"))
	else
		$hBmp = _ClipBoard_GetDataEx($CF_BITMAP)
		if $hBmp <> 0 then

			_GDIPlus_Startup()
			$hImage = _GDIPlus_BitmapCreateFromHBITMAP($hBmp)

			; Save bitmap to file
			if FileExists($sFile) then FileDelete($sFile)
			_GDIPlus_ImageSaveToFile($hImage, $sFile) ;$sNewName)

			_GDIPlus_BitmapDispose($hImage)
			_GDIPlus_Shutdown()
			 $bRet = True
		Else
			_ProgramError(_getLanguageMsg ("capture_clipboardopenerror"))
		endif
		_ClipBoard_Close()
	endif

	return $bRet

EndFunc ;==>_Main


Func SetCaptureStatus ($sText)

	GUICtrlSetData  ($_gCaptureStatus, $sText)

endfunc
