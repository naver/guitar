#include-once
; 윈도우 레지스트리를 활용하여 GUITAR와 변수 정보를 교환하는데 사용함.

func _GUITAR_AU3VARWrite ($sName, $sValue)
	;_debug($sName, $sValue)
	return RegWrite("HKEY_LOCAL_MACHINE\Software\GUITAR\VAR" , $sName, "REG_SZ", $sValue)
endfunc

func _GUITAR_AU3VARRead ($sName)
	;_debug(RegRead("HKEY_LOCAL_MACHINE\Software\GUITAR\VAR" , $sName))
	return RegRead("HKEY_LOCAL_MACHINE\Software\GUITAR\VAR" , $sName)
endfunc

