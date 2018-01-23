#include <GDIPlus.au3>
#include <ScreenCapture.au3>
#include ".\_include_nhn\_util.au3"

;Example()

;ConsoleWrite(_ImageCropFromFile("c:\1.bmp", "c:\2.bmp", 10,10,50,100))
;ConsoleWrite(_ImageCropFromFile("D:\_Autoit\guitar\report\01_네이버검색_webdriver\2016-11-23_10-26-19\capture_2016-11-23_10-26-19_001.png", "D:\_Autoit\guitar\report\01_네이버검색_webdriver\2016-11-23_10-26-19\capture_2016-11-23_10-26-19_001__.png", 0,0, 17, 15))
;ConsoleWrite(_ImageCropFromFile("D:\_Autoit\guitar\report\01_네이버검색_webdriver\2016-11-23_10-26-19\capture_2016-11-23_10-26-19_001.png", "D:\_Autoit\guitar\report\01_네이버검색_webdriver\2016-11-23_10-26-19\capture_2016-11-23_10-26-19_001.png", 0,0, 1067, 915))


Func _ImageCropFromFile($sFromFile, $sToFile, $x1,$y1, $x2,$y2)

	Local $sFileName, $hClone, $hImage, $iX, $iY
	local $sTempFile =@TempDir & Random(1000000,10000000) & ".png"
	local $bResult = False

	;_debug($sFromFile & ", " &  $sToFile & ", " & $x1 & ", " & $y1 & ", " & $x2 & ", " & $y2)
	; Initialize GDI+ library
	_GDIPlus_Startup()

	; Capture 32 bit bitmap

	$sFileName = $sFromFile

	if FileExists ($sFileName) = 0 then return False

	$hImage = _GDIPlus_BitmapCreateFromFile ($sFileName)

	; Create 24 bit bitmap clone
	$hClone = _GDIPlus_BitmapCloneArea($hImage, $x1, $y1, $x2, $y2, $GDIP_PXF24RGB)
	;$hClone = _GDIPlus_BitmapCloneArea($hImage, $x1, $y1, $x2, $y2, $GDIP_PXF32PARGB)


	; Save bitmap to file
	_GDIPlus_ImageSaveToFile($hClone, $sTempFile)

	; Clean up resources
	_GDIPlus_ImageDispose($hClone)
	_GDIPlus_ImageDispose($hImage)
	;_WinAPI_DeleteObject($hBitmap)

	; Shut down GDI+ library
	_GDIPlus_Shutdown()

	if FileExists ($sToFile) then FileDelete($sToFile)
	FileMove($sTempFile, $sToFile)
	if FileExists ($sToFile) = 0 then return False

	return True

EndFunc   ;==>Example



func getImageSizeWithGDISetup($sFile, byref $iImageWidth, byref $iImageHeight )

	_GDIPlus_Startup()
	getImageSize($sFile,  $iImageWidth,  $iImageHeight )
	_GDIPlus_Shutdown()

endfunc



func getImageSize($sFile, byref $iImageWidth, byref $iImageHeight )

	local $hImage
	local $width
	local $height
	local $hBmp
	local $aSize
	local $tBits
	local $sHex


    $hImage = _GDIPlus_ImageLoadFromFile($sFile)
    $width = _GDIPlus_ImageGetWidth($hImage)
    $height = _GDIPlus_ImageGetHeight($hImage)

	$iImageWidth = number($width)
	$iImageHeight = number($height)

    _GDIPlus_ImageDispose($hImage)

	return

endfunc




; 이미지 파일 크기 조정
Func _ImageResizeFromFile($sFromFile, $sToFile, $iRatio)

	local $iW, $iH
	local $iNW, $iNH

	getImageSizeWithGDISetup ($sFromFile, $iW, $iH)

	$iNW = getRatioPixel($iW, $iRatio, False)
	$iNH = getRatioPixel($iH, $iRatio, False)

	;_debug ($iNW, $iNH)

	_GDIPlus_Startup()
	local  $hBitmap = _GDIPlus_ImageLoadFromFile($sFromFile)
	local  $hBitmap_Resized = _GDIPlus_ImageResize($hBitmap, $iNW , $iNH) ;resize image
	_GDIPlus_ImageSaveToFile ($hBitmap_Resized, $sToFile )
	_GDIPlus_ImageDispose($hBitmap)
	_GDIPlus_ImageDispose($hBitmap_Resized)
	_GDIPlus_Shutdown()

	return (FileExists($sToFile) = 1 )

EndFunc


; % 비율로  축소된 이미지의 좌표를 반환함, ZOOM =True 일 경우, 원본 크기 좌표로 반환함
func getRatioPixel($iPixel, $iRatio, $bZoom)

	Local $iRet

	if 	$bZoom = False then
		$iRet = int($iPixel * $iRatio / 100)
	Else
		$iRet = int($iPixel * (100/$iRatio))
	endif

	return $iRet

EndFunc
