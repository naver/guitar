#include ".\_include_nhn\_util.au3"

#include <GUIConstantsEx.au3>
#Include <GuiButton.au3>
#include <GuiRichEdit.au3>

;Global Const $_iColorTarget = 0xff0000
;Global Const $_iColorCommand  = 0x0000AA
;Global Const  $_iColorTargetHtml = 0x0000ff
;Global Const $_iColorCommandHtml = 0xaa0000
;Global Const $_iColorComment = 0x339900
;Global Const $_iColorError = 0x00ffff


Global $_iColorLabelX
Global $_iColorLabelY

Global $_aSampleDataList[1][6]
Global $_iSelectedSampleID
Global $_gfrmSample
Global $_SampleHideRichText
Global $_iSampleDataListCount = 0

Global $_btnSampleAdd
Global $_btnSampleNext
Global $_btnSampleBefore
Global $_btnSampleClose
Global $_iSampleViewPage

Global $_iSampleMaxPage = 5
Global $_iSampleLastPage = 1

;Global  $_SampleHideRichText2

;LoadSampleForm()

func loadSampleList()

	redim $_aSampleDataList[1][6]
	redim $_aSampleDataList[1000][6]

	$_iSampleDataListCount = 0



	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = "-"

	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = "_"
	$_aSampleDataList[$_iSampleDataListCount][2] = "* 브라우저 관리"

	;001
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_001c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_001s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_001d")

	;002
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_002c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_002s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_002d")

	;003
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_003c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_003s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_003d")

	;004
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_004c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_004s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_004d")


	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = "-"

	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = "_"
	$_aSampleDataList[$_iSampleDataListCount][2] = "* 마우스 "


	;005
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_005c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_005s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_005d")


	;006
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_006c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_006s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_006d")


	;007
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_007c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_007s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_007d")


	;008
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_008c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_008s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_008d")


	;009
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_009c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_009s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_009d")


	;010
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_010c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_010s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_010d")


	;011
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_011c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_011s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_011d")


	;012
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_012c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_012s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_012d")


	;013
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_013c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_013s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_013d")

	;014
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_014c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_014s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_014d")


;~ 	$_iSampleDataListCount += 1
;~ 	$_aSampleDataList[$_iSampleDataListCount][1] = "쓸어넘기기"
;~ 	$_aSampleDataList[$_iSampleDataListCount][2] = "화면넘기기 위해 ^target:95-25^로 ^command:쓸어넘기기^한다."
;~ 	$_aSampleDataList[$_iSampleDataListCount][3] = "X1Y1 좌표를 클릭하여 X2Y2 좌표로 드래그하여, 모바일 테스트환경에서 쓸어넘기기 효과를 냅니다."

;~ 	$_iSampleDataListCount += 1
;~ 	$_aSampleDataList[$_iSampleDataListCount][1] = "홈으로가기"
;~ 	$_aSampleDataList[$_iSampleDataListCount][2] = "^command:홈으로가기^한다."
;~ 	$_aSampleDataList[$_iSampleDataListCount][3] = "작업화면의 가운데로 마우스 이동후 오른쪽 버튼을 클릭합니다. 모바 일테스트환경(아이폰)에서 홈으로가기 효과를 냅니다."



	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = "-"

	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = "_"
	$_aSampleDataList[$_iSampleDataListCount][2] = "* 조건문"

	;017
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_017c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_017s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_017d")


	;018
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_018c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_018s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_018d")


	;019
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_019c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_019s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_019d")


	;020
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_020c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_020s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_020d")


	;021
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_021c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_021s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_021d")


	;022
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_022c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_022s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_022d")



	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = "-"

	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = "_"
	$_aSampleDataList[$_iSampleDataListCount][2] = "* 키보드"


	;015
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_015c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_015s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_015d")


	;016
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_016c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_016s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_016d")


	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = "-"

	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = "_"
	$_aSampleDataList[$_iSampleDataListCount][2] = "* 확인"

	;023
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_023c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_023s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_023d")


	;024
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_024c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_024s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_024d")

	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = "-"

	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = "_"
	$_aSampleDataList[$_iSampleDataListCount][2] = "* 대기 "


	;025
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_025c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_025s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_025d")


	;026
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_026c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_026s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_026d")



	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = "-"

	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = "_"
	$_aSampleDataList[$_iSampleDataListCount][2] = " * 테이블 변수"

	;029
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_029c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_029s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_029d")


	;030
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_030c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_030s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_030d")


	;031
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_031c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_031s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_031d")

	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = "-"


	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = "_"
	$_aSampleDataList[$_iSampleDataListCount][2] = " * 캡쳐"


	;032
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_032c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_032s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_032d")


	;033
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_033c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_033s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_033d")


	;034
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_034c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_034s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_034d")


	;035
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_035c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_035s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_035d")


	;036
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_036c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_036s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_036d")


	;037
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_037c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_037s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_037d")


	;038
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_038c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_038s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_038d")


	;039
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_039c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_039s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_039d")


	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = "-"

	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = "_"
	$_aSampleDataList[$_iSampleDataListCount][2] = " * 조건"


	;027
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_027c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_027s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_027d")


	;028
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_028c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_028s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_028d")

	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = "-"

	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = "_"
	$_aSampleDataList[$_iSampleDataListCount][2] = " * 실행"


	;040
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_040c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_040s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_040d")



	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = "-"

	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = "_"
	$_aSampleDataList[$_iSampleDataListCount][2] = " * 기타"


	;042
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_042c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_042s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_042d")


	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = "-"

	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = "_"
	$_aSampleDataList[$_iSampleDataListCount][2] = " * 블럭"


	;043
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_043c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_043s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_043d")


	;044
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_044c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_044s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_044d")

	;045
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_045c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_045s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_045d")

	;046
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_046c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_046s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_046d")

	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = "-"


	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = "_"
	$_aSampleDataList[$_iSampleDataListCount][2] = " * TAG 속성"

	;047
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_047c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_047s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_047d")


	;048
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_048c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_048s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_048d")

	;049
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_049c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_049s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_049d")


	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = "-"

	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = "_"
	$_aSampleDataList[$_iSampleDataListCount][2] = " * Autoit"

	;041
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_041c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_041s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_041d")

	;050
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_050c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_050s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_050d")

	;051
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_051c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_051s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_051d")

	;052
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_052c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_052s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_052d")

	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = "-"

	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = "_"
	$_aSampleDataList[$_iSampleDataListCount][2] = " * 프로세스"

	;053
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_053c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_053s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_053d")


	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = "-"

	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = "_"
	$_aSampleDataList[$_iSampleDataListCount][2] = " * 모바일"

	;054
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_054c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_054s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_054d")

	;055
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_055c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_055s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_055d")


	;056
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_056c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_056s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_056d")


	;057
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_057c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_057s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_057d")

	;058
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_058c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_058s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_058d")

	;059
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_059c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_059s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_059d")

	;060
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_060c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_060s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_060d")

	;061
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_061c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_061s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_061d")


	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = "-"


	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = "_"
	$_aSampleDataList[$_iSampleDataListCount][2] = " * WEBDRIVER"


	; WEBDRIVER
	;080
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_080c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_080s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_080d")

	;081
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_081c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_081s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_081d")

	;082
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_082c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_082s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_082d")

	;083
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_083c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_083s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_083d")

	;084
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_084c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_084s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_084d")

	;085
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_085c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_085s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_085d")

	;086
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_086c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_086s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_086d")


	;087
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_087c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_087s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_087d")



	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = "-"


	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = "_"
	$_aSampleDataList[$_iSampleDataListCount][2] = " * 시스템 변수"


	;  시스템 변경
	;062
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_162c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_162s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_162d")


	;063
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_163c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_163s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_163d")


	;064
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_164c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_164s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_164d")

	;065
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_165c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_165s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_165d")

	;066
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_166c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_166s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_166d")

	;067
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_167c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_167s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_167d")

	;068
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_168c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_168s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_168d")

	;069
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_169c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_169s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_169d")

	;070
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_170c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_170s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_170d")

	;071
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_171c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_171s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_171d")


	;072
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_172c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_172s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_172d")

	;073
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_173c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_173s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_173d")

	;074
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_174c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_174s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_174d")

	;075
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_175c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_175s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_175d")

	;076
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_176c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_176s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_176d")


	;077
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_177c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_177s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_177d")

	;078
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_178c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_178s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_178d")

	;079
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_179c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_179s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_179d")


	;090
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_190c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_190s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_190d")

	;091
	$_iSampleDataListCount += 1
	$_aSampleDataList[$_iSampleDataListCount][1] = _getLanguageMsg ("sample_191c")
	$_aSampleDataList[$_iSampleDataListCount][2] = _getLanguageMsg ("sample_191s")
	$_aSampleDataList[$_iSampleDataListCount][3] = _getLanguageMsg ("sample_191d")


	redim $_aSampleDataList[$_iSampleDataListCount + 1][ubound($_aSampleDataList,$UBOUND_COLUMNS) + 1]

endfunc


Func LoadSampleForm($iPage = 1)

	local $msg

	local $iFormWidth = 800
	local $iFormHeight = 720
	local $iBottomSpace = 60

	local $i, $j
	local $x, $y

	local $iLastFormX
	local $iLastFormY

	local $oGraphics

	$iLastFormX = _readSettingReg ("LastSampleX")
	$iLastFormY = _readSettingReg ("LastSampleY")

	; 모니터상에 있는 좌표인지 확인
	if number(GetMonitorFromPoint($iLastFormX, $iLastFormY)) = 0 then
		$iLastFormX = 0
		$iLastFormY = 0
	endif

	AutoItSetOption("GUICloseOnESC", 1)

	guisetstate(@SW_DISABLE,$_gForm)

	$_gfrmSample = GUICreate($_sProgramName & " Command Template", $iFormWidth, $iFormHeight,$iLastFormX, $iLastFormY, bitor($WS_MINIMIZEBOX, $WS_CAPTION, $WS_POPUP, $WS_SYSMENU, $WS_EX_COMPOSITED))

	GUICtrlCreateLabel (_getLanguageMsg ("sample_command") & ":",25,20)
	GUICtrlCreateLabel (_getLanguageMsg ("sample_sample") & ":",255,20)

	$_SampleHideRichText=_GUICtrlRichEdit_Create  ($_gfrmSample, "", $iFormWidth + 100, $iFormHeight+100, 300, 100)
	;$_SampleHideRichText2=_GUICtrlRichEdit_Create  ($_gfrmSample, "", 0, 250, 300, 100)
	_GUICtrlRichEdit_SetFont($_SampleHideRichText, 9, "Arial")
	;$_SampleHideRichText=_GUICtrlRichEdit_Create  (-1, "", $iFormWidth + 100, $iFormHeight +100, 100, 100)


	$_btnSampleBefore = GUICtrlCreateButton(_getLanguageMsg ("sample_before") & " (&B)",($iFormWidth / 2 ) - 200 - 10  , $iFormHeight -$iBottomSpace,100,30,$BS_DEFPUSHBUTTON)

	$_btnSampleNext = GUICtrlCreateButton(_getLanguageMsg ("sample_next") & " (&N)",($iFormWidth / 2 ) - 100 - 5  , $iFormHeight -$iBottomSpace,100,30,$BS_DEFPUSHBUTTON)

	$_btnSampleAdd = GUICtrlCreateButton(_getLanguageMsg ("sample_insert") & "(&A)",($iFormWidth / 2 )  , $iFormHeight -$iBottomSpace,100,30,$BS_DEFPUSHBUTTON)


	;$_btnSampleAdd = GUICtrlCreateButton("예제 삽입(&A)",($iFormWidth / 2 ) - 200 - 10 , $iFormHeight -40,100,30,$BS_DEFPUSHBUTTON)

	;$_btnSampleBefore = GUICtrlCreateButton("이전 (&B)",($iFormWidth / 2 ) - 100 - 5 , $iFormHeight -40,100,30,$BS_DEFPUSHBUTTON)

	;$_btnSampleNext = GUICtrlCreateButton("다음 (&N)",($iFormWidth / 2 )  , $iFormHeight -40,100,30,$BS_DEFPUSHBUTTON)

	;GUICtrlSetOnEvent($_btnSampleAdd, "onClickSampleAdd")


	$_btnSampleClose = GUICtrlCreateButton(_getLanguageMsg ("imgsearch_close") & " (&X)",($iFormWidth / 2 ) + 5 +100 , $iFormHeight - $iBottomSpace,100,30)


	loadSampleList()

	viewSamplePage($iPage)

EndFunc   ;==>Example


func getPageRange($iPage, byref $iPageStart, byref $iPageEnd)

	local $iPage1=1
	local $iPage2=27
	local $iPage3=54
	local $iPage4=81
	local $iPage5=104
	local $iPage6=136

	if $iPage = 1 then
		$iPageStart  = $iPage1
		$iPageEnd  = $iPage2 - 1
	elseif $iPage = 2 then
		$iPageStart  = $iPage2
		$iPageEnd  = $iPage3 - 1

	elseif $iPage = 3 then
		$iPageStart  = $iPage3
		$iPageEnd  = $iPage4 - 1
	elseif $iPage = 4 then
		$iPageStart  = $iPage4
		$iPageEnd  = $iPage5 - 1
	elseif $iPage = 5 then
		$iPageStart  = $iPage5
		$iPageEnd  = $iPage6 - 1

	else
		$iPageStart  = $iPage6
		$iPageEnd  = ubound ($_aSampleDataList)-1

	endif

	if $iPageEnd  >  ubound ($_aSampleDataList)-1 then $iPageEnd =  ubound ($_aSampleDataList)-1


endfunc


func viewSamplePage($iPage = 1)

	local $iPageStart
	local $iPageEnd


	MouseBusy (True)

	$_iSampleViewPage = $iPage

	_GUICtrlButton_Enable($_btnSampleBefore,False)
	_GUICtrlButton_Enable($_btnSampleNext,False)


	GUISetState (@SW_LOCK,$_gfrmSample)

	if $iPage <> $_iSampleLastPage then
		;debug("페이지 정보삭제 : " & $iPage)
		getPageRange($_iSampleLastPage,  $iPageStart,  $iPageEnd)
		disableSampleGUI($iPageStart, $iPageEnd)
	endif

	GUISetState (@SW_unLOCK,$_gfrmSample)
	GUISetState ()
	GUISetState (@SW_LOCK,$_gfrmSample)
	;getPageRange($iPage+1,  $iPageStart,  $iPageEnd)
	;disableSampleGUI($iPageStart, $iPageEnd)

	getPageRange($iPage,  $iPageStart,  $iPageEnd)

	enableSampleGUI($iPageStart, $iPageEnd)

	GUISetState(@SW_ENABLE, $_gfrmSample)

	if $iPage = 1 then
		_GUICtrlButton_Enable($_btnSampleBefore,False)
	Else
		_GUICtrlButton_Enable($_btnSampleBefore,True )
	endif

	if $iPage = $_iSampleMaxPage then
		_GUICtrlButton_Enable($_btnSampleNext,False)
	Else
		_GUICtrlButton_Enable($_btnSampleNext,True )
	endif

	GUISetState (@SW_UNLOCK,$_gfrmSample)

	GUISetState()

	MouseBusy (False)

	$_iSampleLastPage = $iPage

endfunc


func enableSampleGUI($iPageStart, $iPageEnd)

	local $i, $j, $x, $y
	local $iRadioSize = 230
	local $iGraphicID
	local $iGraphicCnt
	local $iYadd
	local $sLabelIDs
	local $tTimeInit  = _TimerInit()
	local $iLabelID

	GUISetFont(9, 400,0,"Arial")

	for $j=1 to 2

		$iYadd = 0

		for $i=$iPageStart to $iPageEnd

			$iYadd +=1

			if $_aSampleDataList[$i][4] = "" then
				;debug("추가")

				$x = 25
				$y = 20 + ($iYadd * 21)

				if $_aSampleDataList[$i][1] = "-" and $j = 2 then
				  ;                                                                                          _________________________________
					$_aSampleDataList[$i][4] &=  "|" & GUICtrlCreateLabel ("________________________________________________________________________________________________________",$x, $y-4)

				ElseIf $_aSampleDataList[$i][1] = "_" and $j = 2 then
				  ;

					$_aSampleDataList[$i][4] &=  "|" & GUICtrlCreateLabel ($_aSampleDataList[$i][2],$x, $y-4)



					;GUISetState (@SW_UNLOCK,$_gfrmSample)
					;$_aSampleDataList[$i][4] &=  GUICtrlCreateGraphic(24,$y + 8,600, 1)
					;GUISetState (@SW_LOCK,$_gfrmSample)

					;GUISetState()

					;GUISetState()

				Elseif $_aSampleDataList[$i][1] <> "-" and $_aSampleDataList[$i][1] <> "_" and $j=1 then

					$_aSampleDataList[$i][0] = GUICtrlCreateRadio($_aSampleDataList[$i][1], $x , $y, $iRadioSize, 20)
					$_aSampleDataList[$i][4] &=  "|" & $_aSampleDataList[$i][0]

					writeColorLabelLine($x + $iRadioSize , $y, $_aSampleDataList[$i][2], $_aSampleDataList[$i][3], $sLabelIDs)
					$_aSampleDataList[$i][4] &= "|" & $sLabelIDs
					$_aSampleDataList[$i][5]  = $sLabelIDs & "|"

					;debug("신규 : " & $_aSampleDataList[$i][0] & " -- " & $_aSampleDataList[$i][5])
					GUICtrlSetColor ($_aSampleDataList[$i][0] , 0)
					GUICtrlSetTip($_aSampleDataList[$i][0], $_aSampleDataList[$i][3])
					;GUICtrlSetOnEvent($_aSampleDataList[$i][0] , "onClickSampleSelect")

					if $iYadd=1 then
						GUICtrlSetState($_aSampleDataList[$i][0], $GUI_CHECKED)
						$_iSelectedSampleID = $I
					endif

				endif

			Else

				;if $j=1 then toggleSampleLine($_aSampleDataList[$i][4] , True)

			endif

		next


	next

endfunc


func disableSampleGUI($iPageStart, $iPageEnd)

	local $i, $j
	local $sTempSplit

	for $i=$iPageStart to $iPageEnd

		toggleSampleLine ($_aSampleDataList[$i][4] , False)

	next

endfunc


func toggleSampleLine(byref $sIDlist, $bEnable)

	local $j
	local $sTempSplit
	local $iValue

	if $bEnable then
		$iValue =  $GUI_ENABLE + $GUI_SHOW
	else
		$iValue = $GUI_HIDE
	endif

	$sTempSplit = StringSplit( $sIDlist ,"|")
	;debug($sTempSplit)
	;WinSetState($_gfrmSample , "", @SW_DISABLE)

	for $j=1 to ubound($sTempSplit) -1

		if $sTempSplit[$j] <> "" and $sTempSplit[$j] <> 0  then

			;debug($sTempSplit[$j])

			if $bEnable=False then
				;GUICtrlSetState($sTempSplit[$j], $iValue)
				GUICtrlDelete($sTempSplit[$j])
				$sIDlist = ""

			else
				;GUICtrlSetState($sTempSplit[$j], $iValue)
			endif
			;sleep (1)
		endif
	next

	;WinSetState($_gfrmSample , "", @SW_ENABLE)

endfunc


func _waitSampleForm()

	local $nMsg
	local $j
	local $iLabelIndex

	Do
		sleep (1)
		$nMsg = GUIGetMsg()

		for $j=1 to ubound($_aSampleDataList) -1

			If $nMsg = $_aSampleDataList[$j][0] And BitAND(GUICtrlRead($_aSampleDataList[$j][0]), $GUI_CHECKED) = $GUI_CHECKED then
					$_iSelectedSampleID = $j
			endif
		next

		Switch $nMsg

			Case $GUI_EVENT_CLOSE, $_btnSampleClose
				onClickSampleClose()
				return

			case $_btnSampleAdd
				onClickSampleAdd()
				onClickSampleClose()
				return

			case $_btnSampleBefore
				viewSamplePage($_iSampleViewPage-1)

			case $_btnSampleNext
				viewSamplePage($_iSampleViewPage+1)


		EndSwitch

    Until False

endfunc


func onClickSampleClose()


	local $aWinPos

	$aWinPos = WinGetPos($_gfrmSample)

	_writeSettingReg ("LastSampleX", $aWinPos[0])
	_writeSettingReg ("LastSampleY", $aWinPos[1])

	GUIDelete ($_gfrmSample)

	AutoItSetOption("GUICloseOnESC", 0)

	guisetstate(@SW_ENABLE,$_gForm)
	WinActivate($_gForm)
	SelectHotKey("main")

endfunc


func onClickSampleAdd()

	writeColorRichText($_SampleHideRichText , $_aSampleDataList[$_iSelectedSampleID][2])

endfunc



func writeColorRichText($_SampleHideRichText , $sText)

	local $aWord = StringSplit($sText,"^")
	local $aItem
	local $i
	local $sAddText
	local $sAddColor
	Local $aRichPos1
	Local $aRichPos2
	local $sRichStream

	_GUICtrlRichEdit_SetText($_SampleHideRichText, "")

	for $i=1 to ubound($aWord) -1

		_GUICtrlRichEdit_SetSel($_SampleHideRichText,-1,-1)

		$aRichPos1 = _GuiCtrlRichEdit_GetSel($_SampleHideRichText)

		$aItem = StringSplit($aWord[$i],":")
		if ubound($aItem) = 2 then

			$sAddText = $aItem[1]
			$sAddColor = 0
			_GUICtrlRichEdit_SetCharAttributes($_SampleHideRichText, "-bo")
		Else

			$sAddText = $aItem[2]

			if $aItem[1] = "target" Then
				$sAddColor = $_iColorTarget
			Else
				$sAddColor = $_iColorCommand
			endif
			_GUICtrlRichEdit_SetCharAttributes($_SampleHideRichText, "+bo")
		endif

		$sAddText = stringreplace($sAddText,";",":")

		;debug($sAddText)

		_GUICtrlRichEdit_AppendText  ($_SampleHideRichText, $sAddText)

		$aRichPos2 = _GuiCtrlRichEdit_GetSel($_SampleHideRichText)

		_GUICtrlRichEdit_SetSel($_SampleHideRichText,$aRichPos1[1], $aRichPos2[1])
		_GuiCtrlRichEdit_SetCharColor($_SampleHideRichText, $sAddColor)

	next

	;_GUICtrlRichEdit_AppendText  ($_SampleHideRichText, @crlf )
	_GUICtrlRichEdit_SetSel($_SampleHideRichText,0, -1)
	$sRichStream = _GUICtrlRichEdit_StreamToVar($_SampleHideRichText)


	$aRichPos1 = _GuiCtrlRichEdit_GetSel($_gEditScript)

	if $aRichPos1[0] = $aRichPos1[1] then
		_GUICtrlRichEdit_InsertText ($_gEditScript, " ")
		_GUICtrlRichEdit_SetSel($_gEditScript,$aRichPos1[0], $aRichPos1[0]+1)
	endif

	;debug($aRichPos1)

	_GUICtrlRichEdit_StreamFromVar($_gEditScript, $sRichStream)


endfunc


func writeColorLabelLine($x, $y, $sText, $sToolTip, byref $sLabelIDs)

	local $aWord = StringSplit($sText,"^")
	local $aItem
	local $i


	$_iColorLabelX = $x
	$_iColorLabelY = $y
	$sLabelIDs = ""

	for $i=1 to ubound($aWord) -1
		$aItem = StringSplit($aWord[$i],":")

		if ubound($aItem) = 2 then
			writeColorLabelWord("normal", $aItem[1] , $sToolTip, $sLabelIDs)
		Else
			writeColorLabelWord($aItem[1], $aItem[2], $sToolTip, $sLabelIDs)
		endif
	next

endfunc


func writeColorLabelWord($sType, $sText, $sToolTip, byref $sLabelIDs)

	local $aNewLebelSize
	local $aNewLebelID
	local $iFontSize = 9
	local $icorrectionY

	convertHtmlChar($sText)

	Switch $sType

		case "normal"
			GUICtrlSetDefColor (0)
			GUISetFont($iFontSize, 400,0,"Arial")
			$icorrectionY  = $_iColorLabelY

		case "command"
			GUICtrlSetDefColor ( $_iColorCommandHtml) 	; Red
			GUISetFont($iFontSize, 800,0,"Arial")
			$icorrectionY  = $_iColorLabelY

		case "target"
			GUICtrlSetDefColor ($_iColorTargetHtml) 	; Red
			GUISetFont($iFontSize, 800,0,"Arial")
			$icorrectionY  = $_iColorLabelY

	EndSwitch

	$sText = stringreplace($sText,";",":")

	$aNewLebelID =   GUICtrlCreateLabel (stringreplace($sText,@cr,""),$_iColorLabelX, $icorrectionY)
	GUICtrlSetTip(-1, $sToolTip)
	$sLabelIDs = $sLabelIDs & "|" & $aNewLebelID
	;GUISetState()

	$aNewLebelSize = ControlGetPos("","",$aNewLebelID)

	$_iColorLabelX = $_iColorLabelX + $aNewLebelSize[2] - 8

endfunc