#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#Include <File.au3>
#Include <EditConstants.au3>
#Include <Constants.au3>
#include <GuiListView.au3>
#include <GuiImageList.au3>
#include <GDIPlus.au3>
#include <WinAPI.au3>


Func _ListViewImageLoad(byref $LV, byref $Pic, $FL2A, byref $hImageList, $GuitarListImageWidth, $GuitarListImageHeight)

    Local $hBmp, $iCnt = 0
	local $temp

	;_msg("ddd")
	_GUIImageList_Remove($hImageList)
	;debug("_GUIImageList_Remove = " & $temp , $hImageList)


	$temp = _GUiImageList_Destroy($hImageList)
	;debug("_GUiImageList_Destroy = " & $temp, $hImageList)

	;debug("b:" & _GUICtrlListView_GetItemCount(GUICtrlGetHandle($LV)))
	$temp = _GUICtrlListView_DeleteAllItems(GUICtrlGetHandle($LV))
	;debug("_GUICtrlListView_DeleteAllItems = " & $temp)

	;debug(_GUICtrlListView_GetItemCount(GUICtrlGetHandle($LV)))


	ToolTip("")

	$hImageList = ""
	_hBmpToPicControl($Pic, $hBmp)
	GUICtrlSetImage($Pic, "")

	$hImageList = _GUiImageList_Create($GuitarListImageWidth , $GuitarListImageHeight, 5, 3)

	_GUICtrlListView_SetImageList($LV, $hImageList, 0)

	For $i = 1 To ubound($FL2A) -1

		$hBmp = _GetImage($FL2A[$i], $GuitarListImageWidth, $GuitarListImageHeight)
		_GUiImageList_Add($hImageList, $hBmp)
		_WinAPI_DeleteObject($hBmp)
		$temp = _GUICtrlListView_AddItem($LV, $iCnt + 1,$iCnt)
		;debug("추가 : " & $temp)
		_GUICtrlListView_AddSubItem($LV, $iCnt, $FL2A[$i],1)
		_GUICtrlListView_SetItemImage($LV, $iCnt, $iCnt)
		$iCnt += 1
	Next

	;sleep (1)

EndFunc

Func _GetImage($sFile, $iMW, $iMH, $iBkClr = 0xCCCCCC)

    Local $hBmp1, $hBitmap, $hGraphic, $hImage, $iW, $iH, $aGS, $hBmp2
    _GDIPlus_Startup()
    $hBmp1 = _WinAPI_CreateBitmap($iMW, $iMH, 1, 32)
    $hBitmap = _GDIPlus_BitmapCreateFromHBITMAP($hBmp1)
    $hGraphic = _GDIPlus_ImageGetGraphicsContext($hBitmap)
    _WinAPI_DeleteObject($hBmp1)
    _GDIPlus_GraphicsClear($hGraphic, BitOR(0xFF000000, $iBkClr))
    $hImage = _GDIPlus_ImageLoadFromFile($sFile)
    $iW = _GDIPlus_ImageGetWidth($hImage)
    $iH = _GDIPlus_ImageGetHeight($hImage)


    $aGS = _GetScale($iW, $iH, $iMW, $iMH)
    _GDIPlus_GraphicsDrawImageRect($hGraphic, $hImage, $aGS[0], $aGS[1], $aGS[2], $aGS[3])
    _GDIPlus_ImageDispose($hImage)
    _GDIPlus_GraphicsDispose($hGraphic)
    $hBmp2 = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hBitmap)
    _GDIPlus_BitmapDispose($hBitmap)
    _GDIPlus_Shutdown()
    Return $hBmp2

EndFunc


Func _GetScale($iW, $iH, $iMW, $iMH)

    Local $aRet[4]
	local $iMax

	;_debug ($iW, $iH, $iMW, $iMH)

    If $iW < $iMW And $iH < $iMH Then
		; 크기가 영역보다 작은 경우
		;_debug("case 1")
        $aRet[2] = $iW
        $aRet[3] = $iH
        $aRet[0] = ($iMW - $aRet[2])/2
        $aRet[1] = ($iMH - $aRet[3])/2

	ElseIf $iW > $iMW And $iH > $iMH Then
		; 크기가 영역보다 가로세로 모두 작은 경우
		;_debug("case 4")

		$iMax = ($iW/$iMW)
		if ($iH/$iMH) > $iMax then $iMax = ($iH/$iMH)

        $aRet[2] = $iW/$iMax
        $aRet[3] = $iH/$iMax
        $aRet[0] = ($iMW - $aRet[2])/2
        $aRet[1] = ($iMH - $aRet[3])/2

	ElseIf $iW > $iMW Then

		;_debug("case 3")
        $aRet[2] = $iW/($iW/$iMW)
        $aRet[3] = $iH/($iW/$iMW)
        $aRet[0] = 0
        $aRet[1] = ($iMH - $aRet[3])/2

    ElseIf $iH > $iMH Then

		;_debug("case 2")
        $aRet[2] = $iW/($iH/$iMH)
        $aRet[3] = $iH/($iH/$iMH)
        $aRet[0] = ($iMW - $aRet[2])/2
        $aRet[1] = 0

    EndIf

    Return $aRet

EndFunc

Func _hBmpToPicControl($iCID, ByRef $hBmp, $iFlag = 0)
    Local Const $STM_SETIMAGE = 0x0172
    Local Const $IMAGE_BITMAP = 0
    Local $hOldBmp
    $hOldBmp = GUICtrlSendMsg($iCID, $STM_SETIMAGE, $IMAGE_BITMAP, $hBmp)
    If $hOldBmp Then _WinAPI_DeleteObject($hOldBmp)
    If $iFlag Then _WinAPI_DeleteObject($hBmp)
EndFunc

func _FileListToArrayFullPath($sPath, $sPattern = "*", $iOption = 0)

	local $asList[1], $asListEmpty[1], $iErrorCode

	if StringRight($sPath,1) <> "\" then $sPath &= "\"

	$asList = _FileListToArray($sPath, $sPattern , $iOption)

	if @error <> 0 then
		return SetError(@error,0,$asListEmpty)
	endif

	for $i=1 to ubound($asList) -1
		$asList[$i] = $sPath & $asList[$i]
	next

	return $asList

endfunc