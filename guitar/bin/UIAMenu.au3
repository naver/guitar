#include-once

Global $_GMAccelTable[100][2]

Global $_GMFile
Global $_GMFile_NewFile
Global $_GMFile_Oepn
Global $_GMFile_Close
Global $_GMFile_Save
Global $_GMFile_SaveAS
Global $_GMFile_OpenQuick
Global $_GMFile_OpenRecent
Global $_GMFile_OpenInclude
Global $_GMFile_ClipboardOpen
Global $_GMFile_Exit

Global $_GMEdit
Global $_GMEdit_Undo
Global $_GMEdit_Cut
Global $_GMEdit_Copy
Global $_GMEdit_Paste
Global $_GMEdit_Delete
Global $_GMEdit_SelectAll
Global $_GMEdit_Found
Global $_GMEdit_Go

Global $_GMEdit_CommentSet

Global $_GMEdit_TargetRename
Global $_GMEdit_TargetDelete
Global $_GMEdit_CommandTemplate
Global $_GMEdit_XPathVerify
Global $_GMEdit_TestCaseImport

Global $_GMRum
Global $_GMRum_Run
Global $_GMRum_RunBlock
Global $_GMRum_RunLoop
Global $_GMRum_Pause
Global $_GMRum_Stop
Global $_GMRum_RestBrowser

Global $_GMImage
Global $_GMImage_Capture
Global $_GMImage_Edit
Global $_GMImage_Explorer

Global $_GMReport
Global $_GMReport_Report
Global $_GMReport_OpenReportFoler
Global $_GMReport_OpenRemoteManager

Global $_GMTool
Global $_GMTool_PreRun
Global $_GMTool_UserRun1
Global $_GMTool_UserRun2
Global $_GMTool_UserRun3
Global $_GMTool_UserRun4
Global $_GMTool_UserRun5
Global $_GMTool_RunTestCaseExport

Global $_GMHelp
Global $_GMHelp_Help
Global $_GMHelp_HelpAutoitKey
Global $_GMHelp_HelpAutoitCommand
Global $_GMHelp_About
Global $_GMHelp_Keylist


func AllMenuDisable($bDisable)

	local $iValue
	if $bDisable then
		$iValue = $GUI_DISABLE
	else
		$iValue = $GUI_ENABLE
	endif


	GUICtrlSetState ( $_GMFile, $iValue)
	GUICtrlSetState ( $_GMImage, $iValue)
	GUICtrlSetState ( $_GMEdit, $iValue)
	GUICtrlSetState ( $_GMRum, $iValue)
	GUICtrlSetState ( $_GMImage, $iValue)
	GUICtrlSetState ( $_GMReport, $iValue)
	GUICtrlSetState ( $_GMTool, $iValue)
	GUICtrlSetState ( $_GMHelp, $iValue)

endfunc

func CreateMainMenu()


	local $iGMACount =0

	; 파일
	$_GMFile = GUICtrlCreateMenu(_getLanguageMsg("mnu_file") & "(&F)")
	$_GMFile_NewFile = GUICtrlCreateMenuItem(_getLanguageMsg("mnu_file_new") & "(&N)" & @TAB & "CTRL+N", $_GMFile)
	$_GMFile_Oepn = GUICtrlCreateMenuItem("열기(&O)" & @TAB & "CTRL+O", $_GMFile)
	$_GMFile_Save = GUICtrlCreateMenuItem("저장(&S)" & @TAB & "CTRL+S", $_GMFile)
	$_GMFile_Close = GUICtrlCreateMenuItem("닫기(&C)" & @TAB & "CTRL+W", $_GMFile)
	$_GMFile_SaveAS = GUICtrlCreateMenuItem("다른 이름으로 저장(&A)", $_GMFile)
	GUICtrlCreateMenuItem("", $_GMFile)
	$_GMFile_OpenQuick = GUICtrlCreateMenuItem("빨리 열기(&U)", $_GMFile)
	$_GMFile_OpenRecent = GUICtrlCreateMenuItem("최근파일 열기(&R)", $_GMFile)
	$_GMFile_OpenInclude = GUICtrlCreateMenuItem("참조파일 열기(&I)", $_GMFile)
	$_GMFile_ClipboardOpen = GUICtrlCreateMenuItem("클립보드 열기 (&Q)" & @TAB & "CTRL+Q", $_GMFile)
	GUICtrlCreateMenuItem("", $_GMFile)
	$_GMFile_Exit = GUICtrlCreateMenuItem("끝내기(&X)", $_GMFile)

	$_GMAccelTable[$iGMACount][0] = "^n"
	$_GMAccelTable[$iGMACount][1] = $_GMFile_NewFile

	$iGMACount += 1
	$_GMAccelTable[$iGMACount][0] = "^o"
	$_GMAccelTable[$iGMACount][1] = $_GMFile_Oepn

	$iGMACount += 1
	$_GMAccelTable[$iGMACount][0] = "^w"
	$_GMAccelTable[$iGMACount][1] = $_GMFile_Close

	$iGMACount += 1
	$_GMAccelTable[$iGMACount][0] = "^s"
	$_GMAccelTable[$iGMACount][1] = $_GMFile_Save

	$iGMACount += 1
	$_GMAccelTable[$iGMACount][0] = "^q"
	$_GMAccelTable[$iGMACount][1] = $_GMFile_ClipboardOpen

	; 편집
	$_GMEdit = GUICtrlCreateMenu("편집(&E)")
	$_GMEdit_Undo = GUICtrlCreateMenuItem("실행 취소(&U)" & @TAB & "CTRL+Z", $_GMEdit)
	$_GMEdit_Cut = GUICtrlCreateMenuItem("잘라내기(&T)" & @TAB & "CTRL+X", $_GMEdit)
	$_GMEdit_Copy = GUICtrlCreateMenuItem("복사(&C)" & @TAB & "CTRL+C", $_GMEdit)
	$_GMEdit_Paste = GUICtrlCreateMenuItem("붙여넣기(&P)" & @TAB & "CTRL+V", $_GMEdit)
	$_GMEdit_Delete = GUICtrlCreateMenuItem("삭제(&D)" & @TAB & "DEL", $_GMEdit)
	GUICtrlCreateMenuItem("", $_GMEdit)
	$_GMEdit_SelectAll = GUICtrlCreateMenuItem("전체 선택(&A)" & @TAB & "CTRL+A", $_GMEdit)
	GUICtrlCreateMenuItem("", $_GMEdit)
	$_GMEdit_Found = GUICtrlCreateMenuItem("찾기/바꾸기(&F)" & @TAB & "CTRL+F", $_GMEdit)
	$_GMEdit_Go = GUICtrlCreateMenuItem("이동(&M)" & @TAB & "CTRL+G", $_GMEdit)

	GUICtrlCreateMenuItem("", $_GMEdit)
	$_GMEdit_CommentSet = GUICtrlCreateMenuItem("주석 설정/해제(&O)" & @TAB & "CTRL+E", $_GMEdit)

	GUICtrlCreateMenuItem("", $_GMEdit)
	$_GMEdit_XPathVerify = GUICtrlCreateMenuItem("XPath 재검증 (&B)" & @TAB & "CTRL+B", $_GMEdit)

	GUICtrlCreateMenuItem("", $_GMEdit)
	$_GMEdit_TargetRename = GUICtrlCreateMenuItem("대상 변경(&R)", $_GMEdit)
	$_GMEdit_TargetDelete = GUICtrlCreateMenuItem("대상 삭제(&L)", $_GMEdit)

	GUICtrlCreateMenuItem("", $_GMEdit)
	$_GMEdit_CommandTemplate = GUICtrlCreateMenuItem("명령 템플릿 추가(&T)" & @TAB & "CTRL+T", $_GMEdit)

	GUICtrlCreateMenuItem("", $_GMEdit)
	$_GMEdit_TestCaseImport = GUICtrlCreateMenuItem("TestCase -> Comment 변환(&I)", $_GMEdit)

	$iGMACount += 1
	$_GMAccelTable[$iGMACount][0] = "^e"
	$_GMAccelTable[$iGMACount][1] = $_GMEdit_CommentSet


	$iGMACount += 1
	$_GMAccelTable[$iGMACount][0] = "^f"
	$_GMAccelTable[$iGMACount][1] = $_GMEdit_Found

	$iGMACount += 1
	$_GMAccelTable[$iGMACount][0] = "^g"
	$_GMAccelTable[$iGMACount][1] = $_GMEdit_Go

	$iGMACount += 1
	$_GMAccelTable[$iGMACount][0] = "^t"
	$_GMAccelTable[$iGMACount][1] = $_GMEdit_CommandTemplate

	$iGMACount += 1
	$_GMAccelTable[$iGMACount][0] = "^b"
	$_GMAccelTable[$iGMACount][1] = $_GMEdit_XPathVerify

	; 실행
	$_GMRum = GUICtrlCreateMenu("실행(&R)")
	$_GMRum_Run = GUICtrlCreateMenuItem("전체 실행(&R)" & @TAB & "F5", $_GMRum)
	$_GMRum_RunBlock = GUICtrlCreateMenuItem("부분 실행(&B)" & @TAB & "F8", $_GMRum)
	$_GMRum_RunLoop = GUICtrlCreateMenuItem("반복 실행(&L)" & @TAB & "CTRL+L", $_GMRum)
	$_GMRum_Pause = GUICtrlCreateMenuItem("일시 중지(&P)" & @TAB & "PAUSE", $_GMRum)
	$_GMRum_Stop = GUICtrlCreateMenuItem("중지(&S)" & @TAB & "ESC", $_GMRum)

	GUICtrlCreateMenuItem("", $_GMRum)
	$_GMRum_RestBrowser = GUICtrlCreateMenuItem("테스트 대상 브라우저 초기화(&C)" & @TAB & "CTRL+R", $_GMRum)

	$iGMACount += 1
	$_GMAccelTable[$iGMACount][0] = "{F5}"
	$_GMAccelTable[$iGMACount][1] = $_GMRum_Run

	$iGMACount += 1
	$_GMAccelTable[$iGMACount][0] = "{F8}"
	$_GMAccelTable[$iGMACount][1] = $_GMRum_RunBlock

	$iGMACount += 1
	$_GMAccelTable[$iGMACount][0] = "^l"
	$_GMAccelTable[$iGMACount][1] = $_GMRum_RunLoop

	$iGMACount += 1
	$_GMAccelTable[$iGMACount][0] = "^r"
	$_GMAccelTable[$iGMACount][1] = $_GMRum_RestBrowser


	; 이미지
	$_GMImage = GUICtrlCreateMenu("이미지(&I)")
	$_GMImage_Capture = GUICtrlCreateMenuItem("이미지 캡쳐(&C)" & @TAB & "CTRL+SHIFT+C", $_GMImage)
	$_GMImage_Edit = GUICtrlCreateMenuItem("이미지 관리(&I)" & @TAB & "CTRL+I", $_GMImage)
	$_GMImage_Explorer = GUICtrlCreateMenuItem("이미지 탐색기(&M)" & @TAB & "CTRL+M", $_GMImage)

	$iGMACount += 1
	$_GMAccelTable[$iGMACount][0] = "^+c"
	$_GMAccelTable[$iGMACount][1] = $_GMImage_Capture

	$iGMACount += 1
	$_GMAccelTable[$iGMACount][0] = "^i"
	$_GMAccelTable[$iGMACount][1] = $_GMImage_Edit

	$iGMACount += 1
	$_GMAccelTable[$iGMACount][0] = "^m"
	$_GMAccelTable[$iGMACount][1] = $_GMImage_Explorer


	; 리포트
	$_GMReport = GUICtrlCreateMenu("리포트(&P)")

	$_GMReport_Report = GUICtrlCreateMenuItem("테스트 결과 리포트 (&R)", $_GMReport)
	$_GMReport_OpenReportFoler = GUICtrlCreateMenuItem("최근 테스트 결과 폴더 열기 (&p)"  & @TAB & "CTRL+P" , $_GMReport)
	GUICtrlCreateMenuItem("", $_GMReport)
	$_GMReport_OpenRemoteManager = GUICtrlCreateMenuItem("원격 관리 (&M)", $_GMReport)

	$iGMACount += 1
	$_GMAccelTable[$iGMACount][0] = "^p"
	$_GMAccelTable[$iGMACount][1] = $_GMReport_OpenReportFoler


	; 도구
	$_GMTool = GUICtrlCreateMenu("도구(&T)")

	$_GMTool_PreRun = GUICtrlCreateMenuItem("PreRun 명령 실행 (&0)" & @TAB & "ALT+0", $_GMTool)
	$_GMTool_UserRun1 = GUICtrlCreateMenuItem("사용자정의 명령1 실행 (&1)" & @TAB & "ALT+1", $_GMTool)
	$_GMTool_UserRun2 = GUICtrlCreateMenuItem("사용자정의 명령2 실행 (&2)" & @TAB & "ALT+2", $_GMTool)
	$_GMTool_UserRun3 = GUICtrlCreateMenuItem("사용자정의 명령3 실행 (&3)" & @TAB & "ALT+3", $_GMTool)
	$_GMTool_UserRun4 = GUICtrlCreateMenuItem("사용자정의 명령4 실행 (&4)" & @TAB & "ALT+4", $_GMTool)
	$_GMTool_UserRun5 = GUICtrlCreateMenuItem("사용자정의 명령5 실행 (&5)" & @TAB & "ALT+5", $_GMTool)

	GUICtrlCreateMenuItem("", $_GMTool)

	$_GMTool_RunTestCaseExport = GUICtrlCreateMenuItem("TestCase 생성기 실행", $_GMTool)

	$iGMACount += 1
	$_GMAccelTable[$iGMACount][0] = "!0"
	$_GMAccelTable[$iGMACount][1] = $_GMTool_PreRun

	$iGMACount += 1
	$_GMAccelTable[$iGMACount][0] = "!1"
	$_GMAccelTable[$iGMACount][1] = $_GMTool_UserRun1

	$iGMACount += 1
	$_GMAccelTable[$iGMACount][0] = "!2"
	$_GMAccelTable[$iGMACount][1] = $_GMTool_UserRun2

	$iGMACount += 1
	$_GMAccelTable[$iGMACount][0] = "!3"
	$_GMAccelTable[$iGMACount][1] = $_GMTool_UserRun3

	$iGMACount += 1
	$_GMAccelTable[$iGMACount][0] = "!4"
	$_GMAccelTable[$iGMACount][1] = $_GMTool_UserRun4

	$iGMACount += 1
	$_GMAccelTable[$iGMACount][0] = "!5"
	$_GMAccelTable[$iGMACount][1] = $_GMTool_UserRun5


	; 도움말
	$_GMHelp = GUICtrlCreateMenu("도움말(&H)")

	$_GMHelp_Help = GUICtrlCreateMenuItem("도움말 (&H)" & @TAB & "F1", $_GMHelp)
	$_GMHelp_HelpAutoitCommand = GUICtrlCreateMenuItem("AutoIt 함수 목록 (&F)" , $_GMHelp)
	$_GMHelp_HelpAutoitKey = GUICtrlCreateMenuItem("AutoIt Key 목록 (&K)" , $_GMHelp)
	$_GMHelp_Keylist = GUICtrlCreateMenuItem("특수문자표 (&E)" , $_GMHelp)
	$_GMHelp_About = GUICtrlCreateMenuItem("GUITAR 정보 (&A)" , $_GMHelp)

	$iGMACount += 1
	$_GMAccelTable[$iGMACount][0] = "{F1}"
	$_GMAccelTable[$iGMACount][1] = $_GMTool_UserRun1


	redim $_GMAccelTable[$iGMACount + 1][2]

	GUISetAccelerators($_GMAccelTable, $_gForm)

endfunc
