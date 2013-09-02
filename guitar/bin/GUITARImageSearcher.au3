#AutoIt3Wrapper_Icon=GUITARImageSearcher.ico
#AutoIt3Wrapper_Res_Fileversion=1.0.0.15
#AutoIt3Wrapper_Res_FileVersion_AutoIncrement=p

#include-once

#include <StaticConstants.au3>
#include <GuiConstantsEx.au3>
#include <GuiListView.au3>
#include <GUIConstantsEx.au3>
#include <ListViewConstants.au3>
#include <WindowsConstants.au3>
#include <GuiListView.au3>
#Include <Misc.au3>
#Include <Array.au3>
#include <GUIComboBox.au3>

#include ".\_include_nhn\_util.au3"
#include ".\_include_nhn\_file.au3"
#include ".\_include_nhn\_ImageGetInfo.au3"

#include "UIACommon.au3"
#include "GUITARLanguage.au3"

Global enum $_iImageLstName ,$_iImageLstFullPath, $_iImageLstUse,  $_iImageLstEnd

Global $_gImageForm
Global $_gImageListView
Global $_gListViewData [1][$_iImageLstEnd]
Global $_gLastListImageIndex
Global $_gListViewImage
Global $_gListViewImageFrame
Global $_gListViewImagePositionY
Global $_gListViewMsPaint

Global $_sLastListViewPath

Global $_gListViewSearch
Global $_gListViewNameCopy
Global $_gListViewDelete
Global $_gListViewRename
Global $_gListViewMove
Global $_gListViewEnd
Global $_gListViewRun
Global $_gRadioScript
Global $_gRadioPath
Global $_gListViewPath
Global $_gListViewPathOpen
Global $_gListViewPathSelect
Global $_gListViewScript
Global $_gFileSearch

Global $_gListViewCurPath
Global $_gListViewCurScript

Global $_sListviewFirstImageFolder

global $_bSorted = False


main()

func main()

	local $sDumyScript, $sDumyUserIni, $bDumyRemote

	; 랭귀지 리소스 읽기
	_loadLanguageResource(_loadLanguageFile(getReadINI("Environment","Language")))




	AutoItSetOption("GUICloseOnESC", 0)

	TraySetState()
	TraySetToolTip($_sProgramName & " Image Search")


	_setCommonPathVar()

	$_runImageEditor = getReadINI("environment","ImageEditor")
	if $_runImageEditor = "" or FileExists($_runImageEditor) = 0 then $_runImageEditor = "mspaint.exe"

	;_msg($_sProgramName)
	;_msg($_runImageEditor)

	_loadMngImage()

	_waitListView()


endfunc


func _checkSelectImageList()


	local $aSelectInfo
	local $iNewIndex
	local $bSelect

	local $bResult = False

	$aSelectInfo = _GUICtrlListView_GetSelectedIndices($_gImageListView, True)

	if IsArray($aSelectInfo) then
		if UBound($aSelectInfo) > 1 then $bSelect = True
	endif

	if $bSelect then

		$iNewIndex = $aSelectInfo[ubound($aSelectInfo)-1]
		;DEBUG($iNewIndex)
		if $_gLastListImageIndex <> $iNewIndex then
			$_gLastListImageIndex = $iNewIndex
			;debug($iNewIndex)
			viewSelecteListviewImage ($iNewIndex)
			$bResult =  True
		endif
	Else
		$_gLastListImageIndex = -1
	endif

	Return $bResult

endfunc


func setListViewLastImageFolderComboListUpdate($bAddCommPath)

	local $i
	local $sList = ""
	local $aFolderList = _getRecentImageFolder()
	local $sCommImgPath
	local $sCommSCPath
	local $sSCPath

	_GUICtrlComboBox_ResetContent($_gListViewPath)

	_GUICtrlComboBox_BeginUpdate($_gListViewPath)

	$sCommImgPath =  $_runCommonImagePath
	$sCommSCPath =  $_runCommonScriptPath
	$sSCPath =  $_runScriptPath

	_GUICtrlComboBox_AddString($_gListViewPath, $_sListviewFirstImageFolder)
	if $_sListviewFirstImageFolder <> $sCommImgPath  then _GUICtrlComboBox_AddString($_gListViewPath, $sCommImgPath)
	if $_sListviewFirstImageFolder <> $sCommSCPath  then _GUICtrlComboBox_AddString($_gListViewPath, $sCommSCPath)
	if $_sListviewFirstImageFolder <> $sSCPath  then _GUICtrlComboBox_AddString($_gListViewPath, $sSCPath)

	for $i=1 to ubound($aFolderList) -1
		if $_sListviewFirstImageFolder <> $aFolderList[$i] _
			and $sCommImgPath <> $aFolderList[$i] _
			and $sCommSCPath <> $aFolderList[$i] _
			and $sSCPath <> $aFolderList[$i]  then _GUICtrlComboBox_AddString($_gListViewPath, $aFolderList[$i])

	next
	_GUICtrlComboBox_EndUpdate($_gListViewPath)
	_GUICtrlComboBox_SetCurSel($_gListViewPath, 0)

endfunc


func _loadMngImage()

	local $x, $y , $xadd, $yadd
	local $aListWidth[$_iImageLstEnd]
	local $i
	local $iWidthSum = 10
	local $iDefaultTextWidth = 20
	local $iDefaultButtonWidth = 30
	local $iFormLeft = 10
	local $iFormTop = 10
	local $iFormWidth = 980
	local $iLVStyle, $iLVExtStyle
	Local $iExWindowStyle = BitOR($WS_EX_DLGMODALFRAME, $WS_EX_CLIENTEDGE)
	Local $iExListViewStyle = BitOR($LVS_EX_FULLROWSELECT, $LVS_EX_SUBITEMIMAGES, $LVS_EX_GRIDLINES, $LVS_EX_CHECKBOXES, $LVS_EX_DOUBLEBUFFER)
	local $msg

	; 버튼 생성

	;Opt("GuiOnEventMode", 0)

	$x = $iFormLeft + 10
	$y = $iFormTop + 10

	$_gImageForm = GUICreate($_sProgramName & " Image Searcher" & " v" & FileGetVersion(@ScriptDir & "\" & _GetScriptName() & ".exe"), $iFormWidth, 650,default,default,default,default)

	$y += 20
	$xAdd = 150
	$_gFileSearch = GUICtrlCreateInput("", $x  , $y , $xAdd, $iDefaultTextWidth)

	$x += $xAdd + 10
	$xAdd = 100
	$_gListViewRun = GUICtrlCreateButton(_getLanguageMsg("imgsearch_search") & "(S)",$x , $y-5,$xAdd,$iDefaultButtonWidth,$BS_DEFPUSHBUTTON)

	$x += $xAdd + 20
	$xAdd = 70
	GUICtrlCreateLabel(_getLanguageMsg("imgsearch_imagepath"), $x, $y + 5, $xAdd, $iDefaultButtonWidth)

	$x += $xAdd
	$xAdd = 380
	$_gListViewPath = GUICtrlCreateCombo($_gListViewCurPath , $x , $y  , $xAdd, $iDefaultButtonWidth, $CBS_DROPDOWNLIST)
	;$_sListviewFirstImageFolder = getReadINI("Script","CommonScriptPath")
	$_sListviewFirstImageFolder = _readSettingReg("LastImaseSearchFolder")

	if $_sListviewFirstImageFolder = "" then $_sListviewFirstImageFolder = getReadINI("Script","CommonScriptPath")


	$x += $xAdd + 10
	$xAdd = 90
	$_gListViewPathSelect = GUICtrlCreateButton(_getLanguageMsg("imgsearch_chnagepath"),$x , $y ,$xAdd,$iDefaultTextWidth)
	$x += $xAdd + 5
	$_gListViewPathOpen = GUICtrlCreateButton(_getLanguageMsg("imgsearch_openexp"), $x, $y, $xAdd,$iDefaultTextWidth)
	;_GUICtrlButton_Enable($_gListViewPathSelect,False)
	;_GUICtrlButton_Enable($_gListViewPathOpen,False)
	;GUICtrlSetState($_gListViewPath, $GUI_DISABLE)



	;;GUICtrlCreateButton("검색", 10,700,10,10)
	;$xadd = 100
	;$_gListViewSearch = GUICtrlCreateButton("검색(&S)", $x, $y, $xadd, $iDefaultButtonWidth)

	$x = 500
	$xAdd = 110

	; 리스트뷰
	$x = $iFormLeft + 10
	$y += 40

	$aListWidth[$_iImageLstName] = 200
	$aListWidth[$_iImageLstFullPath] = 630
	$aListWidth[$_iImageLstUse] = 100

	for $i= 0 to ubound($aListWidth) -1
		$iWidthSum += $aListWidth[$i]
	next

	$iLVStyle = BitOR($LVS_REPORT, $LVS_SHOWSELALWAYS)
	$iLVExtStyle = BitOR($WS_EX_CLIENTEDGE, $LVS_EX_GRIDLINES, $LVS_EX_CHECKBOXES, $LVS_EX_FULLROWSELECT)
	$yadd = 300
	$_gImageListView = GUICtrlCreateListView(_getLanguageMsg("imgsearch_name") & "|" & _getLanguageMsg("imgsearch_path"), $x , $y, $iWidthSum, $yadd, $iLVStyle, $iLVExtStyle)
	;$_gImageListView = GUICtrlCreateListView("이름|경로|사용여부", $x , $y, $iWidthSum, $yadd, -1, $iExWindowStyle)

	_GUICtrlListView_SetExtendedListViewStyle($_gImageListView, $iExListViewStyle)

	for $i=  0 to ubound($aListWidth) -1
		GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, $i, $aListWidth[$i])
	next

	$y += $yadd + 10
	$x = 250
	$xadd = 110
	$yadd = 20

	$_gListViewNameCopy =GUICtrlCreateButton(_getLanguageMsg("imgsearch_namecopy") & "(&N)", $x, $y, $xadd, $iDefaultButtonWidth)
	$x += $xadd + 10

	$_gListViewMsPaint =GUICtrlCreateButton(_getLanguageMsg("imgsearch_edit") & "(&P)", $x, $y, $xadd, $iDefaultButtonWidth)
	;GUICtrlSetOnEvent(-1, "_deleteImageList")
	$x += $xadd + 10


	$_gListViewRename = GUICtrlCreateButton(_getLanguageMsg("imgsearch_rename") & "(&R)", $x, $y, $xadd, $iDefaultButtonWidth)

	$x += $xadd + 10
	$_gListViewMove = GUICtrlCreateButton(_getLanguageMsg("imgsearch_move") & "(&M)", $x, $y, $xadd, $iDefaultButtonWidth)

	$x += $xadd + 10
	$_gListViewDelete = GUICtrlCreateButton(_getLanguageMsg("imgsearch_delete") & "(&D)", $x, $y, $xadd, $iDefaultButtonWidth)

	;GUICtrlSetOnEvent(-1, "_BtnHit")

	$x += $xadd + 10
	$_gListViewEnd = GUICtrlCreateButton(_getLanguageMsg("imgsearch_close") & "(&X)", $x, $y, $xadd, $iDefaultButtonWidth)
	;GUISetOnEvent(-1, "CLOSEClicked")

	GUICtrlCreateGroup(_getLanguageMsg("imgsearch_imgsearch"), $iFormLeft, $iFormTop, $iFormWidth - $iFormLeft * 2  , 430)

	$y += 50

	GUICtrlCreateGroup(_getLanguageMsg("imgsearch_selectimg"), $iFormLeft, $y, $iFormWidth - $iFormLeft * 2 , 190)

	$_gListViewImageFrame = GUICtrlCreateLabel(" ",10000, -1000 ,0, 0, $SS_BLACKFRAME)

	$y += $yadd + 5
	$_gListViewImagePositionY = $y


	$_gListViewImage = GUICtrlCreatePic("", -1,  -1, 1, 1)

	;GUISetOnEvent($GUI_EVENT_CLOSE, "_unloadMngImage", $_gImageForm )

	MouseBusy (True)
	setListViewLastImageFolderComboListUpdate(True)
	MouseBusy (False)

	GUISetState(@SW_SHOW)

endfunc


func _changeImagePath()

	local $sNewPath

	$sNewPath = FileSelectFolder("Choose a folder.", "",1,GUICtrlRead ($_gListViewPath), $_gImageForm)

	if $sNewPath <> "" then
		_writeRecentImageFolder ($sNewPath)
		$_sListviewFirstImageFolder = $sNewPath
		GUICtrlSetData  ($_gListViewPath, $sNewPath)
		setListViewLastImageFolderComboListUpdate(False)


	endif

endfunc


func _waitListView()

	local $nMsg

	_GUICtrlListView_RegisterSortCallBack($_gImageListView)

	Do
		sleep (1)
		$nMsg = GUIGetMsg()

		Switch $nMsg

			Case $GUI_EVENT_CLOSE, $_gListViewEnd
				_writeSettingReg("LastImaseSearchFolder",GUICtrlRead  ($_gListViewPath))
				_unloadMngImage()
				return ""
			;case $_gListViewSearch
			;	_refreshImageList()
			case $_gListViewDelete
				_deleteImageList()
			case $_gListViewRename
				_renameImageList()
			case $_gListViewMove
				_moveImageList()
			case $_gListViewMsPaint
				_runMsPaint()
			case $_gListViewPathSelect
				_changeImagePath ()
			case $_gListViewRun
				_GUICtrlButton_Enable($_gListViewRun,False)
				sleep(500)
				_refreshImageList ()
				;sleep(100)
				_GUICtrlButton_Enable($_gListViewRun,True)
			case $_gListViewNameCopy
				_copyImageName ()

			case $_gListViewPathOpen
				ShellExecute("explorer.exe" , GUICtrlRead  ($_gListViewPath))


			Case $_gRadioScript
				if (BitAND(GUICtrlRead($_gRadioScript), $GUI_CHECKED) = $GUI_CHECKED) then
					_GUICtrlButton_Enable($_gListViewPathSelect,False)
					_GUICtrlButton_Enable($_gListViewPathOpen,False)
					GUICtrlSetState($_gListViewPath, $GUI_DISABLE)

					;Debug ("스크립트" & $nMsg & $_gRadioScript )
				endif
			Case $_gRadioPath
				if (BitAND(GUICtrlRead($_gRadioPath), $GUI_CHECKED) = $GUI_CHECKED) then
					_GUICtrlButton_Enable($_gListViewPathSelect,True)
					_GUICtrlButton_Enable($_gListViewPathOpen,True)
					_GUICtrlButton_Enable($_gListViewPath,True)
					GUICtrlSetState($_gListViewPath, $GUI_ENABLE)

					;Debug ("경로" & $nMsg )
				endif
			case $_gImageListView
				;debug("왔어")
				_GUICtrlListView_SortItems($_gImageListView, GUICtrlGetState($_gImageListView))
				;_GUICtrlListView_SortItems($_gImageListView, 1)
				GUISetState()

		EndSwitch

				;sleep(10)
        _checkSelectImageList ()

    Until False

endfunc

func _runMsPaint()

    Local $hLV = ControlGetHandle($_gImageForm, "", $_gImageListView)
    Local $iCnt
	local $bDelete =False
	local $aItem
	local $sImageFile
	local $bFound = False


	$iCnt = ControlListView($_gImageForm, "", $hLV, "GetItemCount")

	For $n = 0 To $iCnt - 1
		if _GUICtrlListView_GetItemChecked ($_gImageListView, $n)  OR ControlListView($_gImageForm, "", $hLV, "IsSelected", $n)  then
			$sImageFile = getImageListViewFullPathName($n)
			ShellExecute($_runImageEditor,"""" & $sImageFile & """")
			$bFound = True
			ExitLoop
		endif
	Next

	if $bFound = False then  _ProgramInformation(_getLanguageMsg("imgsearch_selecterror"))

endfunc

func _copyImageName ()


    Local $hLV = ControlGetHandle($_gImageForm, "", $_gImageListView)
    Local $iCnt
	local $bDelete =False
	local $aItem
	local $sImageFile
	local $sClip = ""

	$iCnt = ControlListView($_gImageForm, "", $hLV, "GetItemCount")

	For $n = 0 To $iCnt - 1
		if _GUICtrlListView_GetItemChecked ($_gImageListView, $n)  OR ControlListView($_gImageForm, "", $hLV, "IsSelected", $n)  then

			$sClip = $sClip  & getPrefImageName(_GetFileName(getImageListViewFullPathName($n))) & @crlf

		endif
	Next

	if $sClip  <> "" then ClipPut($sClip)


endfunc

func getImageListViewFullPathName($iIndex)

	local $aItem

	$aItem = _GUICtrlListView_GetItem(GUICtrlGetHandle($_gImageListView), $iIndex, $_iImageLstFullPath)

	return $aItem [3]

endfunc

func setImageListView()

	local $i
	;_msg($_gListViewData)
	_GuICtrlListView_DeleteAllItems(GUICtrlGetHandle($_gImageListView))


	;_msg($_gListViewData)
	;_msg($_gListViewData [0][$_iImageLstName])


		;_GUICtrlListView_AddArray($_gImageListView, $_gListViewData)
		;debug(ubound($_gListViewData) -1)
		for $i=1 to ubound($_gListViewData) -1
			_AddListViewRow($_gImageListView, $i, _iif($i = ubound($_gListViewData) -1, True, False))
			;_msg("x")
		next



		;if $_bSorted = False then
			_GUICtrlListView_SortItems($_gImageListView, 2)
			_GUICtrlListView_SortItems($_gImageListView, 0)
			$_bSorted = True
		;endif

		$_gLastListImageIndex = -1

		if ubound($_gListViewData) > 1 then
			_GUICtrlListView_ClickItem(GUICtrlGetHandle($_gImageListView), 0, "left", False, 1)
			_checkSelectImageList()
		endif


endfunc


Func _AddListViewRow($hWnd, $i, $bAutoResize  )

	;debug($_gListViewData[$i][0])
	Local $iIndex = _GUICtrlListView_AddItem($hWnd, $_gListViewData[$i][0], -1, _GUICtrlListView_GetItemCount($hWnd) + 9999)
	if $bAutoResize then _GUICtrlListView_SetColumnWidth($hWnd, 0, $LVSCW_AUTOSIZE_USEHEADER)

	For $x = 1 To ubound($_gListViewData,2) -2
		;debug($_gListViewData[$i][$x])
		_GUICtrlListView_AddSubItem($hWnd, $iIndex, $_gListViewData[$i][$x], $x , -1)
		if $bAutoResize then  _GUICtrlListView_SetColumnWidth($hWnd, $x - 1, $LVSCW_AUTOSIZE)
	Next

EndFunc   ;==>_AddRow


func _unloadMngImage()

	_GUICtrlListView_UnRegisterSortCallBack($_gImageListView)

	GUIDelete($_gImageForm)
	;debug("왔어")

endfunc

func _renameImageList()

    Local $hLV = ControlGetHandle($_gImageForm, "", $_gImageListView)
    Local $iCnt
	local $bFound = False
	local $aItem
	local $sImageFile
	local $sNewFile
	local $sOldFile
	local $iRenameCoount = 0
	local $n

	$iCnt = ControlListView($_gImageForm, "", $hLV, "GetItemCount")


	For $n = 0 To $iCnt - 1

		if _GUICtrlListView_GetItemChecked ($_gImageListView, $n)  then $iRenameCoount += 1

	next

	if $iRenameCoount > 1 then
		_ProgramInformation(_getLanguageMsg("imgsearch_multiselect"))
		return
	endif

	For $n = 0 To $iCnt - 1

		if _GUICtrlListView_GetItemChecked ($_gImageListView, $n)   or (ControlListView($_gImageForm, "", $hLV, "IsSelected", $n) and  $iRenameCoount = 0) then

			$bFound = True
			$sOldFile = _GetFileName(getImageListViewFullPathName($n))
			$sNewFile = _Trim(InputBox($_sProgramName & " " & _getLanguageMsg("imgsearch_rename"), _getLanguageMsg("imgsearch_imgnameinput"),  $sOldFile ,"",500,150,Default,Default,0,$_gImageForm))

			if $sNewFile <> "" and $sOldFile <> $sNewFile then

				if stringlower(Stringright("       " & $sNewFile,4)) <> ".png" then $sNewFile = $sNewFile & ".png"

				$sNewFile = Stringreplace(getImageListViewFullPathName($n),$sOldFile & ".png", $sNewFile)

				FileMove(getImageListViewFullPathName($n), $sNewFile)


				;debug("왔어1:" & $sNewFile)
				$_bUpdateForderFileList = True

				;_refreshImageList ()

				; 파일 제목도 바꿀것
				;debug("왔어2:" & $sNewFile)
				_GUICtrlListView_SetItem(GUICtrlGetHandle($_gImageListView), getPrefImageName(_GetFileName($sNewFile)), $n, $_iImageLstName)
				_GUICtrlListView_SetItem(GUICtrlGetHandle($_gImageListView), $sNewFile, $n, $_iImageLstFullPath)

				exitloop

			endif

		endif
	Next

	if $bFound = False then
		_ProgramInformation(_getLanguageMsg("imgsearch_selecterror"))
	Else
		viewSelecteListviewImage (-1)
		$_gLastListImageIndex = -1
	endif

EndFunc

func _moveImageList()

    Local $hLV = ControlGetHandle($_gImageForm, "", $_gImageListView)
    Local $iCnt
	local $bDelete =False
	local $aItem
	local $sImageFile
	local $sNewPath
	local $iRenameCoount = 0
	local $n

	$iCnt = ControlListView($_gImageForm, "", $hLV, "GetItemCount")


	_writeRecentImageFolder ($sNewPath)

	For $n = 0 To $iCnt - 1

		if _GUICtrlListView_GetItemChecked ($_gImageListView, $n) or (ControlListView($_gImageForm, "", $hLV, "IsSelected", $n) and  $iRenameCoount = 0)  then


			;if $sNewPath = "" then $sNewPath = FileSelectFolder("Choose a folder.", "",1,GUICtrlRead ($_gListViewPath), $_gImageForm)

			$sNewPath = GUICtrlRead ($_gListViewPath)

			if $sNewPath = $_sLastListViewPath then
				_ProgramInformation(_getLanguageMsg("imgsearch_imgpatherror"))
				return
			endif

			if $sNewPath = "" then return

			if $bDelete = False then
				if _ProgramQuestion(_getLanguageMsg("imgsearch_imgmoveconfirm") & @crlf & @crlf &  $sNewPath) = False then	return
			endif


			$sImageFile = getImageListViewFullPathName($n)
			_GUICtrlListView_DeleteItem($hLV, $n)
			$bDelete = True

			;_msg($sImageFile)

			;debug($sImageFile, $sNewPath & "\" & _GetFilename($sImageFile)  & ".png")
			FileMove($sImageFile, $sNewPath & "\" & _GetFilename($sImageFile)  & ".png")

			$n=$n-1
		endif
	Next

	if $bDelete = False then
		_ProgramInformation(_getLanguageMsg("imgsearch_selecterror"))
	Else
		viewSelecteListviewImage (-1)
		$_gLastListImageIndex = -1
		$_bUpdateForderFileList = True
	endif

EndFunc

func _deleteImageList()

    Local $hLV = ControlGetHandle($_gImageForm, "", $_gImageListView)
    Local $iCnt
	local $bDelete =False
	local $aItem
	local $sImageFile
	local $iRenameCoount = 0
	local $n

	$iCnt = ControlListView($_gImageForm, "", $hLV, "GetItemCount")

	For $n = 0 To $iCnt - 1

		;if _GUICtrlListView_GetItemChecked ($_gImageListView, $n)  OR ControlListView($_gImageForm, "", $hLV, "IsSelected", $n)  then
		if _GUICtrlListView_GetItemChecked ($_gImageListView, $n) or (ControlListView($_gImageForm, "", $hLV, "IsSelected", $n) and  $iRenameCoount = 0)  then
			if $bDelete = False then
				if _ProgramQuestion(_getLanguageMsg("imgsearch_imgdeleteconfirm")) = False then return ""
			endif

			$sImageFile = getImageListViewFullPathName($n)
			_GUICtrlListView_DeleteItem($hLV, $n)
			$bDelete = True

			;debug($sImageFile)
			FileDelete($sImageFile)

			$n=$n-1
		endif
	Next

	if $bDelete = False then
		_ProgramInformation(_getLanguageMsg("imgsearch_selecterror"))
	Else
		viewSelecteListviewImage (-1)
		$_gLastListImageIndex = -1
		$_bUpdateForderFileList = True
	endif

EndFunc

Func _refreshImageList()

	MouseBusy (True)

	getImageListDataFormPath(GUICtrlRead ($_gListViewPath))

	$_sLastListViewPath = GUICtrlRead ($_gListViewPath)

 	setImageListView()

	MouseBusy (False)

EndFunc

func viewSelecteListviewImage($iIndex)

	local $x = 20
	local $y = $_gListViewImagePositionY
	local $iWidth
	local $iHeight
	local $iTempBMP = @TempDir & "\listview.bmp"
	local $aImageInfo
	local $sImageFile
	local $aItem

	;debug($_gListViewImagePositionY)

	if $iIndex <> -1 then

		$sImageFile = getImageListViewFullPathName($iIndex)


		GUICtrlDelete($_gListViewImage)
		_PNG2BMP ($sImageFile, $iTempBMP)

		$aImageInfo = _ImageGetInfo($iTempBMP)
		$iWidth = _ImageGetParam($aImageInfo, "Width")
		$iHeight = _ImageGetParam($aImageInfo, "Height")

		$_gListViewImage = GUICtrlCreatePic($iTempBMP, $x,  $y, $iWidth, $iHeight)
		GUICtrlSetPos ( $_gListViewImageFrame , $x-1,$y-1, $iWidth+2,$iHeight+2)

	Else
		GUICtrlSetPos($_gListViewImage ,10000,10000,0,0)
		GUICtrlSetPos ( $_gListViewImageFrame,  10000,10000,0,0)
		GUISetState()
	endif

	GUISetState()

	;FileDelete($iTempBMP)

endfunc


func getImageListDataFormPath($sPath)

	local $i
	local $aSearchList[1]
	local $sSearchText
	redim $_gListViewData[1][$_iImageLstEnd]

	$sSearchText = _trim(GUICtrlRead($_gFileSearch))
	$aSearchList = _GetFileNameFromDir($sPath, "*" & $sSearchText & "*.png", 1)
	;debug($sPath)
	;_msg($aSearchList)
	if IsArray($aSearchList) then
		redim $_gListViewData[ubound($aSearchList) ][$_iImageLstEnd]

		for $i= 1 to ubound($aSearchList) -1

			$_gListViewData[$i][$_iImageLstName] = getPrefImageName(_GetFileName($aSearchList[$i]))
			$_gListViewData[$i][$_iImageLstFullPath] = $aSearchList[$i]
			$_gListViewData[$i][$_iImageLstUse] = ""

		next
	endif

EndFunc


func getPrefImageName($sStr)

	local $iLen = StringLen($sStr)

	if StringInStr($sStr,"_") > 0 Then $iLen = StringInStr($sStr,"_") -1

	return stringleft($sStr,$iLen)

endfunc
