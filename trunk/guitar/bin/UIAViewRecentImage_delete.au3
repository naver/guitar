#include-once

#include <GUIConstantsEx.au3>
#include <EditConstants.au3>
#Include <GuiButton.au3>
#include <GDIPlus.au3>

#include "UIACommon.au3"
#include ".\_include_nhn\_ImageGetInfo.au3"

global $_aPicListArray[100]
global $_aTitleListArray[100]

func _viewPNGImages($x, $y, $aPicFile, $aTitle = "", $sTitlePost = "RIGHT")
; 이미지 정보를 화면에 표시

	local $i
	local $iImageX
	local $iImageY

	local $iTitleX
	local $iTitleY

	local $iBaseY
	local $iAddAfterY
	local $iAddBeforeY

	local $iImageWidth
	local $iImageHeight
	local $iTempBMP = @TempDir & "\lastuse.bmp"
	local $aImageInfo
	local $iHideHieght

	local $aObjectPos


	for $i=1 to ubound($_aPicListArray) -1

		if $_aPicListArray[$i] <> 0  then
			GUICtrlDelete($_aPicListArray[$i])
			$_aPicListArray[$i] = 0
		endif

		if $_aTitleListArray[$i] <> 0  then
			GUICtrlDelete($_aTitleListArray[$i])
			$_aTitleListArray[$i]  = 0
		endif

	next

	$aObjectPos = getRichLineXY("Image")


	if IsArray($aPicFile) then

		for $i=1 to ubound($aPicFile) -1

			_PNG2BMP ($aPicFile[$i], $iTempBMP)
			$aImageInfo = _ImageGetInfo($iTempBMP)

			$iImageWidth = _ImageGetParam($aImageInfo, "Width")
			$iImageHeight = _ImageGetParam($aImageInfo, "Height")

			$iBaseY = $iImageHeight
			$iAddAfterY = 0
			$iAddBeforeY = 0

			if $iBaseY < 10 then $iBaseY = 10

			if IsArray($aTitle) then

				Switch $sTitlePost

					case "RIGHT"
						$iTitleX = $x + _ImageGetParam($aImageInfo, "Width") + 10
						$iTitleY = $y + ($iBaseY / 2) - 5
					case "DOWN"
						$iTitleX = $x
						$iTitleY = $y + _ImageGetParam($aImageInfo, "Height")
						$iAddAfterY = 15

					case "TOP"
						$iTitleX = $x
						$iTitleY = $y
						$iAddBeforeY = 15

				EndSwitch

			endif


			$iImageX = $x
			$iImageY = $y + $iAddBeforeY


			; 보여지는 영역을 넘어갈 경우 보이지 않은 영역 form+100 에 이미지를 표시하도록 함
			if $aObjectPos[1] + $aObjectPos[3] < $iImageY + $iImageHeight  then

				;debug($aObjectPos[1] + $aObjectPos[3] , $iImageY + $iImageHeight)
				$iHideHieght = 100
			else
				$iHideHieght = 0
			endif


			$_aPicListArray[$i] = GUICtrlCreatePic($iTempBMP, $iImageX, $iImageY + $iHideHieght, $iImageWidth, $iImageHeight)
			GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKHEIGHT + $GUI_DOCKWIDTH)
			GUICtrlSetTip(-1, $aTitle[$i] )


			if IsArray($aTitle) then

				$_aTitleListArray[$i] = GUICtrlCreateLabel("" & $aTitle[$i] & "", $iTitleX, $iTitleY + $iHideHieght,$aObjectPos [2] - $iTitleX,12, $SS_SIMPLE)

				GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKHEIGHT)

				GUICtrlSetTip(-1, $aTitle[$i] )

			endif

			$y = $y + $iBaseY + $iAddAfterY + 5 + $iAddBeforeY

			GUISetState()
		next

	endif

	FileDelete($iTempBMP)

endfunc


