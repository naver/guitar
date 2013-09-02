#include-once
#include <File.au3>
#include ".\_include_nhn\_http.au3"
#include ".\_include_nhn\_util.au3"


opt("MustDeclareVars",1)


func _UnicodeURLEncodeSMS ($str)

	;_debug(_URLEncode("한글 테스트 입니다. !@#$%^&*()""" & "'111"))

	local $i
	local $ret = ""
	local $temp

	for $i=1 to StringLen($str)

		$temp = stringmid($str,$i,1)
		;_debug($temp)
		;_debug(dec(StringReplace(StringToBinary($temp),'0x', '', 1)))

		if dec(StringReplace(StringToBinary($temp),'0x', '', 1)) > 128 then
			;$temp = stringmid($str,$i,1)
			$temp &= " "

		endif

		$ret &= _UnicodeURLEncodeByte($temp)

	next

	return $ret

EndFunc


Func _UnicodeURLEncodeByte($UnicodeURL)
	local $UnicodeBinary
	local $UnicodeBinary2
	Local $EncodedString
	local $UnicodeBinaryChar
	local $UnicodeBinaryLength

	$UnicodeBinary = StringToBinary ($UnicodeURL)
    $UnicodeBinary2 = StringReplace($UnicodeBinary, '0x', '', 1)
    $UnicodeBinaryLength = StringLen($UnicodeBinary2)

	if $UnicodeBinaryLength = 6 then $UnicodeBinaryLength = 4

    For $i = 1 To $UnicodeBinaryLength Step 2

        $UnicodeBinaryChar = StringMid($UnicodeBinary2, $i, 2)
        If StringInStr("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890", BinaryToString ('0x' & $UnicodeBinaryChar)) Then
            $EncodedString &= BinaryToString ('0x' & $UnicodeBinaryChar)
		ElseIf StringInStr(" ", BinaryToString ('0x' & $UnicodeBinaryChar)) Then
			$EncodedString &= "+"
			;$EncodedString &= ""
        Else
            $EncodedString &= '%' & $UnicodeBinaryChar
        EndIf

		;_debug ($EncodedString)
    Next
    Return $EncodedString
EndFunc   ;==>_UnicodeURLEncode

