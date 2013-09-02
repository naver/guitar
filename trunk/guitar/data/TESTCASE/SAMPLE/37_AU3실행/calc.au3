; AutoIt이 테스트 하는 시스템에 설치되어 있어야 함 (http://www.autoitscript.com/site/autoit/downloads/)
; c:\guitar\bin\etc\GUITARAU3VAR.au3 파일을 사전에 C:\Program Files\AutoIt3\Include 에 복사애 주어야 함.
;
; _GUITAR_AU3VARRead : GUITAR에서 저장된 변수값을 읽는 함수
; _GUITAR_AU3VARWrite : GUITAR에서 읽을 수 있도록 변수값을 저장하는 함수

#include-once
#include "GUITARAU3VAR.au3"

local $var1
local $var2
local $result

$var1 = _GUITAR_AU3VARRead ("값1")
$var2 = _GUITAR_AU3VARRead ("값2")

$result = $var1 * $var2

_GUITAR_AU3VARWrite ("곱하기결과", $result)

exit 0

; GUITAR에 스크립트에 오류를 전달하고자 할 때에는 exit 코드에 0이 아닌값을 사용하도록 함.
