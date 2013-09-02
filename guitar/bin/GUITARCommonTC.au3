#include-once


Global enum $_iExportIndex = 0 , $_iExportFile,  $_iExportID, $_iExportDivision, $_iExportPriority,  $_iExportCondition, $_iExportStep, $_iExportExpectResult, $_iExportCommentAll, $_iExportEnd

Global const $_cMaxTestCaseField = 9

Global  $_cTCReportFile
Global  $_cTCReportID
Global  $_cTCReportDivision
Global  $_cTCReportDivision1
Global  $_cTCReportDivision2
Global  $_cTCReportDivision3
Global  $_cTCReportDivision4
Global  $_cTCReportPriority
Global  $_cTCReportCondition
Global  $_cTCReportStep
Global  $_cTCReportExpectResult
Global  $_cTCReportAllComment

func replaceTCFileString(byref $cTCFile)

	$cTCFile  = stringReplace($cTCFile , "¦¢","")
	$cTCFile  = stringReplace($cTCFile , "¦§","")
	$cTCFile  = stringReplace($cTCFile , "¡æ","")
	$cTCFile  = stringReplace($cTCFile , "¦¦","")

endfunc

func _loadTestCaseHeaderText()

	$_cTCReportFile = _getLanguageMsg("testcase_file")
	$_cTCReportID = "ID"
	$_cTCReportDivision = _getLanguageMsg("testcase_division")
	$_cTCReportDivision1 = _getLanguageMsg("testcase_division1")
	$_cTCReportDivision2 = _getLanguageMsg("testcase_division2")
	$_cTCReportDivision3 = _getLanguageMsg("testcase_division3")
	$_cTCReportDivision4 = _getLanguageMsg("testcase_division4")
	$_cTCReportPriority = _getLanguageMsg("testcase_priority")
	$_cTCReportCondition = _getLanguageMsg("testcase_condition")
	$_cTCReportStep = "STEP"
	$_cTCReportExpectResult = _getLanguageMsg("testcase_expectresult")
	$_cTCReportAllComment = _getLanguageMsg("testcase_comment")

endfunc