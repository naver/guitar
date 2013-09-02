#include-once
#include <File.au3>
#include ".\_include_nhn\_http.au3"
#include ".\_include_nhn\_util.au3"
#include ".\_include_nhn\_sms.au3"

opt("MustDeclareVars",1)

;_debug(_SendNHNSMS("테스트 메일 내용","010-7140-0586"))

func _SendSMS ($str, $sTo)

	local  $ret = False

	if ShellExecuteWait(@ScriptDir & "\" & "SMSSend.exe", $sTo & " " & $sTo & " """  &  $str & """" , @ScriptDir,Default,@SW_HIDE) = 0 then $ret = true

	return $ret

EndFunc


