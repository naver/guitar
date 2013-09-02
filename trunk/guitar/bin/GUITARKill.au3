#AutoIt3Wrapper_Icon=GUITARKill.ico
#AutoIt3Wrapper_Res_Fileversion=1.0.0.39
#AutoIt3Wrapper_Res_FileVersion_AutoIncrement=p

#include-once

#include "UIACommon.au3"
#include ".\_include_nhn\_file.au3"


AutoItSetOption ( "TrayAutoPause" ,0)

main()

exit (0)


func main ()
;∏ﬁ¿Œ

$_sUserINIFile = @ScriptDir & "\guitar.ini"

local $sMainProgram = getReadINI("Environment","Main")
local $iProcessKillTimeInit


if ProcessExists($sMainProgram) <> 0  then

	$iProcessKillTimeInit = _TimerInit()

	do
		sleep (1000)
		send("{ESC}")
		;_debug($sMainProgram)
	Until _TimerDiff($iProcessKillTimeInit) > 30000  or (ProcessExists($sMainProgram) = 0 )

	if ProcessExists($sMainProgram) <> 0  then ProcessClose($sMainProgram)

endif

endfunc