#include-once

#include "_IEScreenCapture.au3"
#include ".\_include_nhn\_util.au3"
#include <IE.au3>

local $oIE

local $oObj
local $sFile

;$oIE = _IECreate("http://www.naver.com/")
;$oIE = _IEAttach("Internet Explorer")
$oIE = _IEAttach("³×ÀÌ¹ö")
;$oIE = _IEAttach("_IE_")
;local $i
;for $i=1 to 1
;_IEScreenCapture($oIE, "c:\1.png" )
;next

$oObj = _IEGetObjById ($oIE, "query")

_debug($oObj.type)
;$oObj = _IELinkGetCollection ($oIE,220)
;$oObj.Style.backgroundColor = 0xffff00
;$oObj.Style.Color = 0xff0000

;$sFile = @DesktopDir & '\test.jpg'
;_IEElementCapture($oIE, $oObj, $sFile ,1)

;ShellExecute ( $sFile)

;_IEQuit($oIE)