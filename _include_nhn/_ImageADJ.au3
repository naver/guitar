#include <Color.au3>
#include <Array.au3>
#include <ScreenCapture.au3>
#include <GUIConstantsEx.au3>
#include <GUIConstantsEx.au3>


#include "_ImageSearch.au3"

Example()

Func Example()

	local $aSkipPoint, $iTransparentColor, $iBackgroundColor
	local $aHexPoint
	local $iImageWidth,  $iImageHeight
	local $sImage = "c:\33.png"


	_GDIPlus_Startup() ;initialize GDI+


	; 이미지 정보 읽기
	local $aHexPoint = getImageHexData($sImage, $iImageWidth,  $iImageHeight)
	;debug($aHexPoint)
	;debug($iImageWidth, $iImageHeight)

	; 이미지 분석


	Local Const $iWidth = 150, $iHeight = 150
	Local $iColor = 0
	Local $hGUI = GUICreate("GDI+ example", $iWidth, $iHeight) ;create a test GUI

	Local $hBitmap = _GDIPlus_BitmapCreateFromFile($sImage)
    local $hGraphic = _GDIPlus_GraphicsCreateFromHWND($hGUI)
    ;_GDIPlus_GraphicsDrawImage($hGraphic, $hBitmap, 0, 0)

	; 색칠 재수행
	GUISetState(@SW_SHOW)

	$iBackgroundColor = _GDIPlus_BitmapGetPixel ( $hBitmap, 0,0 )
	$iBackgroundColor = StringRight(hex($iBackgroundColor),6)
	$iTransparentColor = "0xFF" & $iBackgroundColor
	;$iTransparentColor = "0xFFFF0000"

	;_msg(hex(_GDIPlus_BitmapGetPixel ( $hBitmap, 0,0 )))
	;_msg($iBackgroundColor)


	$aSkipPoint = PixcelAnalysis($aHexPoint, $iImageWidth, $iImageHeight, $iBackgroundColor, 0.1)
	CreateTransparentImage($hBitmap, "c:\3.png", $aSkipPoint, $iTransparentColor )



	Local $hGraphics = _GDIPlus_GraphicsCreateFromHWND($hGUI) ;create a graphics object from a window handle
	_GDIPlus_GraphicsDrawImage($hGraphics, $hBitmap, 0, 0) ;copy negative bitmap to graphics object (GUI)

	;_GDIPlus_ImageSaveToFile($hBitmap, "c:\3.png")

	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE


	;cleanup GDI+ resources
	_GDIPlus_GraphicsDispose($hGraphics)
	_GDIPlus_Shutdown()
	GUIDelete($hGUI)


EndFunc   ;==>Example


func CreateTransparentImage($hBitmap, $sFile, $aSkipPoint, $iTransparentColor )

	for $i=1 to ubound($aSkipPoint) -1
		;_debug($hBitmap, $aSkipPoint[$i][1], $aSkipPoint[$i][2])
		_GDIPlus_BitmapSetPixel($hBitmap, $aSkipPoint[$i][1]-1, $aSkipPoint[$i][2]-1, $iTransparentColor)
	next

	_GDIPlus_ImageSaveToFile($hBitmap, $sFile)

endfunc


Func PixcelAnalysis($sHex, $width, $height, $iBackgroundColor, $iMaxCount)

	local $x, $y, $i
	local $iNewColor, $iNewColorIndex
	local $aSkipPoint[1][3], $iSkipIndex
	local $aPixcelInfo[$width * $height +1][7]
	local $aPixcelInfoUnique
	local $iBGColorR = ("0x" & StringMid($iBackgroundColor,1 ,2))
	local $iBGColorG = ("0x" & StringMid($iBackgroundColor,3 ,2))
	local $iBGColorB = ("0x" & StringMid($iBackgroundColor,5 ,2))

	;debug($iBackgroundColor)
	;debug(dec("0x" & StringMid($iBackgroundColor,1 ,2)), $iBGColorG, $iBGColorB)

	; 모든 포인트의 칼라 값을 분석함
	for $y=1 to $height

		for $x=1 to $width

			$i = (($y -1) * $width + $x)
			;debug($i)
			$aPixcelInfo[$i][1] = $x
			$aPixcelInfo[$i][2] = $y

			; R,G,B 전체 칼러
			$aPixcelInfo[$i][0] = StringMid($sHex,1 + ($i-1) * 8,6)
			; R,G,B
			$aPixcelInfo[$i][3] = "0x" & StringMid($sHex,1 + ($i-1) * 8,2)
			$aPixcelInfo[$i][3] = abs($aPixcelInfo[$i][3] - $iBGColorR)
			$aPixcelInfo[$i][4] = "0x" &StringMid($sHex,1 + ($i-1) * 8 + 2,2)
			$aPixcelInfo[$i][4] = abs($aPixcelInfo[$i][4] - $iBGColorG)
			$aPixcelInfo[$i][5] = "0x" &StringMid($sHex,1 + ($i-1) * 8 + 4,2)
			$aPixcelInfo[$i][5] = abs($aPixcelInfo[$i][5] - $iBGColorB)

			; 전체값
			$aPixcelInfo[$i][6] = $aPixcelInfo[$i][3] + $aPixcelInfo[$i][4] + $aPixcelInfo[$i][5]

		next

	next

	;ArrayDisplay($aPixcelInfo)
	_ArraySort($aPixcelInfo,1,1,0,5)
	;ArrayDisplay($aPixcelInfo)

	;msg($aPixcelInfo)

	$iMaxCount

	$iNewColor = -1
	$iNewColorIndex = 0

	$aPixcelInfoUnique = _ArrayUnique($aPixcelInfo, 1)

	$iMaxCount = ubound($aPixcelInfoUnique) * $iMaxCount
	;_ArrayDisplay($aPixcelInfoUnique)
	;_debug(ubound($aPixcelInfoUnique),  ubound($aPixcelInfo))


	for $i=1 to ubound($aPixcelInfo) -1

		if $iNewColor <> $aPixcelInfo[$i][0] then
			$iNewColorIndex = $iNewColorIndex + 1
			$iNewColor = $aPixcelInfo[$i][0]
		endif

		;_debug($iNewColorIndex)

		if $iNewColorIndex > $iMaxCount and $aPixcelInfo[$i][0] <> $iBackgroundColor then

			; 최초 실행시 4군데 추가할것
			if ubound($aSkipPoint) = 1 then
				redim $aSkipPoint [ubound($aSkipPoint) + 4][ubound($aSkipPoint,2)]
				$aSkipPoint [1][1] = 1
				$aSkipPoint [1][2] = 1

				$aSkipPoint [2][1] = $width
				$aSkipPoint [2][2] = 1

				$aSkipPoint [3][1] = 1
				$aSkipPoint [3][2] = $height

				$aSkipPoint [4][1] = $width
				$aSkipPoint [4][2] = $height
			endif


			$iSkipIndex = ubound($aSkipPoint)
			redim $aSkipPoint [$iSkipIndex+1][ubound($aSkipPoint,2)]
			$aSkipPoint [$iSkipIndex][1] = $aPixcelInfo[$i][1]
			$aSkipPoint [$iSkipIndex][2] = $aPixcelInfo[$i][2]
			$aSkipPoint [$iSkipIndex][0] = $aPixcelInfo[$i][0]
			;_debug($aPixcelInfo[$i][1], $aPixcelInfo[$i][2])
			;_ArrayDisplay($aSkipPoint)

		endif
	next

	;msg(ubound($aSkipPoint))
	;_ArrayDisplay($aSkipPoint)

	return $aSkipPoint
	_ArrayConcatenate
endfunc