#include-once

#include <ARRAY.au3>
#include <IE.au3>

#include "WinAPIError.au3"

; #FUNCTION# ====================================================================================================================
; Name...........: _IEAttach
; Description ...: Attach to the first existing instance of Internet Explorer where the
;					search string sub-string matches based on the selected mode.
; Parameters ....: $s_string	- String to search for (for "embedded" or "dialogbox", use Title sub-string or HWND of window)
;				   $s_mode		- Optional: specifies search mode
;									Title		= (Default) browser title
;									URL			= url of the current page
;									Text 		= text from the body of the current page
;									HTML 		= html from the body of the current page
;									HWND 		= hwnd of the browser window
;									Embedded 	= title sub-string or hwnd of the window embedding the control
;									DialogBox 	= title sub-string or hwnd of modal/modeless dialogbox
;				   $i_instance	- Optional: specifies the 1-based instance when multiple windows match the criteria.
;									For Embedded, DialogBox and HWND it specifies the embedded browser occurance within
;									the matching window
; Return values .: On Success	- Returns an object variable pointing to the IE Window Object
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_IEStatus_Success) = No Error
;								- 5 ($_IEStatus_InvalidValue) = Invalid Value
;								- 7 ($_IEStatus_NoMatch) = No Match
;					@Extended	- Contains invalid parameter number
; Author ........: Dale Hohm
; ===============================================================================================================================


; $s_htmlFor, $s_event 가 없을 경우 아예 값을 넣지 않음
Func _IEHeadInsertEventScript2(ByRef $o_object, $s_htmlFor, $s_event, $s_script)
	If Not IsObj($o_object) Then
		__IEConsoleWriteError("Error", "_IEHeadInsertEventScript", "$_IEStatus_InvalidDataType")
		Return SetError($_IEStatus_InvalidDataType, 1, 0)
	EndIf

	Local $o_head = $o_object.document.all.tags("HEAD").Item(0)
	Local $o_script = $o_object.document.createElement("script")
	With $o_script
		;.defer = True
		.language = "jscript"
		.type = "text/javascript"
		.text = $s_script
	EndWith

	if $s_htmlFor <> "" then $o_script.htmlFor = $s_htmlFor
	if $s_event <> "" then $o_script.event = $s_event


	$o_head.appendChild($o_script)
	Return SetError($_IEStatus_Success, 0, 1)
EndFunc   ;==>_IEHeadInsertEventScript


Func _IEAttach2($s_string, $s_mode = "Title", $i_instance = 1)
	$s_mode = StringLower($s_mode)

	$i_instance = Int($i_instance)
	If $i_instance < 1 Then
		__IEConsoleWriteError("Error", "_IEAttach", "$_IEStatus_InvalidValue", "$i_instance < 1")
		Return SetError($_IEStatus_InvalidValue, 3, 0)
	EndIf

	If $s_mode = "embedded" Or $s_mode = "dialogbox" Then
		Local $iWinTitleMatchMode = Opt("WinTitleMatchMode", 2)
		If $s_mode = "dialogbox" And $i_instance > 1 Then
			If IsHWnd($s_string) Then
				$i_instance = 1
				__IEConsoleWriteError("Warning", "_IEAttach", "$_IEStatus_GeneralError", "$i_instance > 1 invalid with HWnd and DialogBox.  Setting to 1.")
			Else
				Local $a_winlist = WinList($s_string, "")
				If $i_instance <= $a_winlist[0][0] Then
					$s_string = $a_winlist[$i_instance][1]
					$i_instance = 1
				Else
					__IEConsoleWriteError("Warning", "_IEAttach", "$_IEStatus_NoMatch 1")
					Opt("WinTitleMatchMode", $iWinTitleMatchMode)
					Return SetError($_IEStatus_NoMatch, 1, 0)
				EndIf
			EndIf
		EndIf
		Local $h_control = ControlGetHandle($s_string, "", "[CLASS:Internet Explorer_Server; INSTANCE:" & $i_instance & "]")
		Local $oResult = __IEControlGetObjFromHWND($h_control)
		Opt("WinTitleMatchMode", $iWinTitleMatchMode)
		If IsObj($oResult) Then
			Return SetError($_IEStatus_Success, 0, $oResult)
		Else
			__IEConsoleWriteError("Warning", "_IEAttach", "$_IEStatus_NoMatch 2")
			Return SetError($_IEStatus_NoMatch, 1, 0)
		EndIf
	EndIf

	Local $o_Shell = ObjCreate("Shell.Application")
	Local $o_ShellWindows = $o_Shell.Windows(); collection of all ShellWindows (IE and File Explorer)
	Local $i_tmp = 1
	Local $f_NotifyStatus, $status, $f_isBrowser, $s_tmp

	For $o_window In $o_ShellWindows
		;------------------------------------------------------------------------------------------
		; Check to verify that the window object is a valid browser, if not, skip it
		;
		; Setup internal error handler to Trap COM errors, turn off error notification,
		;     check object property validity, set a flag and reset error handler and notification
		;
		$f_isBrowser = True
		; Trap COM errors and turn off error notification

		If Not $status Then __IEConsoleWriteError("Warning", "_IEAttach", _
				"Cannot register internal error handler, cannot trap COM errors", _
				"Use _IEErrorHandlerRegister() to register a user error handler")
		$f_NotifyStatus = _IEErrorNotify() ; save current error notify status
		_IEErrorNotify(False)

		; Check conditions to verify that the object is a browser
		If $f_isBrowser Then
			$s_tmp = $o_window.type ; Is .type a valid property?
			If @error Then $f_isBrowser = False
		EndIf


		If $f_isBrowser Then
			$s_tmp = $o_window.document.title ; Does object have a .document and .title property?
			If @error Then $f_isBrowser = False

			;ConsoleWrite ("title : " &$o_window.document.title & @cr)
			;ConsoleWrite ("codename : " & $o_window.document.parentWindow.top.navigator.appCodeName() & @cr )

			; *****************************************************************************************************************************
			; 브라우저 타입이 없을 경우 예외처리 할것

			;if $o_window.document.parentWindow.top.navigator.appCodeName() = "" then $f_isBrowser = False
			;If @error Then $f_isBrowser = False


			; IE6 및 이후 버전인경우에만 지원
			if $o_Window.Name() <> "Internet Explorer" and $o_Window.Name() <> "Windows Internet Explorer" and $o_Window.Name() <> "Microsoft Internet Explorer" then $f_isBrowser = False
			;_debug($f_isBrowser)

			$s_tmp =" "
			$s_tmp = $o_Window.Hwnd()

			if $s_tmp = "" then
				$f_isBrowser = False

			endif

			If @error Then $f_isBrowser = False
			;_debug($f_isBrowser)

		EndIf

		; restore error notify and error handler status
		_IEErrorNotify($f_NotifyStatus) ; restore notification status

		;------------------------------------------------------------------------------------------

		If $f_isBrowser Then
			Switch $s_mode
				Case "title"
					If StringInStr($o_window.document.title, $s_string) > 0 Then
						If $i_instance = $i_tmp Then
							Return SetError($_IEStatus_Success, 0, $o_window)
						Else
							$i_tmp += 1
						EndIf
					EndIf
				Case "instance"
					If $i_instance = $i_tmp Then
						Return SetError($_IEStatus_Success, 0, $o_window)
					Else
						$i_tmp += 1
					EndIf
				Case "windowtitle"
					Local $f_found = False
					$s_tmp = RegRead("HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main\", "Window Title")
					If Not @error Then
						If StringInStr($o_window.document.title & " - " & $s_tmp, $s_string) Then $f_found = True
					Else
						If StringInStr($o_window.document.title & " - Microsoft Internet Explorer", $s_string) Then $f_found = True
						If StringInStr($o_window.document.title & " - Windows Internet Explorer", $s_string) Then $f_found = True
					EndIf
					If $f_found Then
						If $i_instance = $i_tmp Then
							Return SetError($_IEStatus_Success, 0, $o_window)
						Else
							$i_tmp += 1
						EndIf
					EndIf
				Case "url"
					If StringInStr($o_window.LocationURL, $s_string) > 0 Then
						If $i_instance = $i_tmp Then
							Return SetError($_IEStatus_Success, 0, $o_window)
						Else
							$i_tmp += 1
						EndIf
					EndIf
				Case "text"
					If StringInStr($o_window.document.body.innerText, $s_string) > 0 Then
						If $i_instance = $i_tmp Then
							Return SetError($_IEStatus_Success, 0, $o_window)
						Else
							$i_tmp += 1
						EndIf
					EndIf
				Case "html"
					If StringInStr($o_window.document.body.innerHTML, $s_string) > 0 Then
						If $i_instance = $i_tmp Then
							Return SetError($_IEStatus_Success, 0, $o_window)
						Else
							$i_tmp += 1
						EndIf
					EndIf
				Case "hwnd"
					If $i_instance > 1 Then
						$i_instance = 1
						__IEConsoleWriteError("Warning", "_IEAttach", "$_IEStatus_GeneralError", "$i_instance > 1 invalid with HWnd.  Setting to 1.")
					EndIf
					If _IEPropertyGet2($o_window, "hwnd") = $s_string Then
						Return SetError($_IEStatus_Success, 0, $o_window)
					EndIf
				Case Else
					; Invalid Mode
					__IEConsoleWriteError("Error", "_IEAttach", "$_IEStatus_InvalidValue", "Invalid Mode Specified")
					Return SetError($_IEStatus_InvalidValue, 2, 0)
			EndSwitch
		EndIf
	Next
	__IEConsoleWriteError("Warning", "_IEAttach", "$_IEStatus_NoMatch 3")
	Return SetError($_IEStatus_NoMatch, 1, 0)
EndFunc   ;==>_IEAttach

; #FUNCTION# ====================================================================================================================
; Name...........: _IEPropertyGet
; Description ...: Returns a select property of the browser
; Parameters ....: $o_object	- Object variable of an InternetExplorer.Application
;				   $s_property	- Property selection
; Return values .: On Success 	- Value of selected Property
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_IEStatus_Success) = No Error
;								- 3 ($_IEStatus_InvalidDataType) = Invalid Data Type
;								- 4 ($_IEStatus_InvalidObjectType) = Invalid Object Type
;								- 5 ($_IEStatus_InvalidValue) = Invalid Value
;					@Extended	- Contains invalid parameter number
; Author ........: Dale Hohm
; ===============================================================================================================================
Func _IEPropertyGet2(ByRef $o_object, $s_property)

	local $sTempHwnd,$OEvent
	If Not IsObj($o_object) Then
		__IEConsoleWriteError("Error", "_IEPropertyGet2", "$_IEStatus_InvalidDataType")
		Return SetError($_IEStatus_InvalidDataType, 1, 0)
	EndIf
	If Not __IEIsObjType($o_object, "browserdom") Then
		__IEConsoleWriteError("Error", "_IEPropertyGet2", "$_IEStatus_InvalidObjectType")
		Return SetError($_IEStatus_InvalidObjectType, 1, 0)
	EndIf
	;
	Local $oTemp, $iTemp
	$s_property = StringLower($s_property)
	Select
		Case $s_property = "browserx"
			If __IEIsObjType($o_object, "browsercontainer") Or __IEIsObjType($o_object, "document") Then
				__IEConsoleWriteError("Error", "_IEPropertyGet2", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			$oTemp = $o_object
			$iTemp = 0
			While IsObj($oTemp)
				$iTemp += $oTemp.offsetLeft
				$oTemp = $oTemp.offsetParent
			WEnd
			Return SetError($_IEStatus_Success, 0, $iTemp)
		Case $s_property = "browsery"
			If __IEIsObjType($o_object, "browsercontainer") Or __IEIsObjType($o_object, "document") Then
				__IEConsoleWriteError("Error", "_IEPropertyGet2", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			$oTemp = $o_object
			$iTemp = 0
			While IsObj($oTemp)
				$iTemp += $oTemp.offsetTop
				$oTemp = $oTemp.offsetParent
			WEnd
			Return SetError($_IEStatus_Success, 0, $iTemp)
		Case $s_property = "screenx"
			If __IEIsObjType($o_object, "window") Or __IEIsObjType($o_object, "document") Then
				__IEConsoleWriteError("Error", "_IEPropertyGet2", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			If __IEIsObjType($o_object, "browser") Then
				Return SetError($_IEStatus_Success, 0, $o_object.left())
			Else
				$oTemp = $o_object
				$iTemp = 0
				While IsObj($oTemp)
					$iTemp += $oTemp.offsetLeft
					$oTemp = $oTemp.offsetParent
				WEnd
			EndIf
			Return SetError($_IEStatus_Success, 0, _
						$iTemp + $o_object.document.parentWindow.screenLeft)
		Case $s_property = "screeny"
			If __IEIsObjType($o_object, "window") Or __IEIsObjType($o_object, "document") Then
				__IEConsoleWriteError("Error", "_IEPropertyGet2", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			If __IEIsObjType($o_object, "browser") Then
				Return SetError($_IEStatus_Success, 0, $o_object.top())
			Else
				$oTemp = $o_object
				$iTemp = 0
				While IsObj($oTemp)
					$iTemp += $oTemp.offsetTop
					$oTemp = $oTemp.offsetParent
				WEnd
			EndIf
			Return SetError($_IEStatus_Success, 0, _
						$iTemp + $o_object.document.parentWindow.screenTop)
		Case $s_property = "height"
			If __IEIsObjType($o_object, "window") Or __IEIsObjType($o_object, "document") Then
				__IEConsoleWriteError("Error", "_IEPropertyGet2", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			If __IEIsObjType($o_object, "browser") Then
				Return SetError($_IEStatus_Success, 0, $o_object.Height())
			Else
				Return SetError($_IEStatus_Success, 0, $o_object.offsetHeight)
			EndIf
		Case $s_property = "width"
			If __IEIsObjType($o_object, "window") Or __IEIsObjType($o_object, "document") Then
				__IEConsoleWriteError("Error", "_IEPropertyGet2", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			If __IEIsObjType($o_object, "browser") Then
				Return SetError($_IEStatus_Success, 0, $o_object.Width())
			Else
				Return SetError($_IEStatus_Success, 0, $o_object.offsetWidth)
			EndIf
		Case $s_property = "isdisabled"
			Return SetError($_IEStatus_Success, 0, $o_object.isDisabled())
		Case $s_property = "addressbar"
			If Not __IEIsObjType($o_object, "browser") Then
				__IEConsoleWriteError("Error", "_IEPropertyGet2", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			Return SetError($_IEStatus_Success, 0, $o_object.AddressBar())
		Case $s_property = "busy"
			If Not __IEIsObjType($o_object, "browser") Then
				__IEConsoleWriteError("Error", "_IEPropertyGet2", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			Return SetError($_IEStatus_Success, 0, $o_object.Busy())
		Case $s_property = "fullscreen"
			If Not __IEIsObjType($o_object, "browser") Then
				__IEConsoleWriteError("Error", "_IEPropertyGet2", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			Return SetError($_IEStatus_Success, 0, $o_object.fullScreen())
		Case $s_property = "hwnd"
			If Not __IEIsObjType($o_object, "browser") Then
				__IEConsoleWriteError("Error", "_IEPropertyGet2", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			$sTempHwnd = HWnd($o_object.HWnd())
			Return SetError($_IEStatus_Success, 0, $sTempHwnd)
		Case $s_property = "left"
			If Not __IEIsObjType($o_object, "browser") Then
				__IEConsoleWriteError("Error", "_IEPropertyGet2", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			Return SetError($_IEStatus_Success, 0, $o_object.Left())
		Case $s_property = "locationname"
			If Not __IEIsObjType($o_object, "browser") Then
				__IEConsoleWriteError("Error", "_IEPropertyGet2", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			Return SetError($_IEStatus_Success, 0, $o_object.LocationName())
		Case $s_property = "locationurl"
			If __IEIsObjType($o_object, "browser") Then
				Return SetError($_IEStatus_Success, 0, $o_object.locationURL())
			EndIf
			If __IEIsObjType($o_object, "window") Then
				Return SetError($_IEStatus_Success, 0, $o_object.location.href())
			EndIf
			If __IEIsObjType($o_object, "document") Then
				Return SetError($_IEStatus_Success, 0, $o_object.parentwindow.location.href())
			EndIf
			Return SetError($_IEStatus_Success, 0, $o_object.document.parentwindow.location.href())
		Case $s_property = "menubar"
			If Not __IEIsObjType($o_object, "browser") Then
				__IEConsoleWriteError("Error", "_IEPropertyGet2", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			Return SetError($_IEStatus_Success, 0, $o_object.MenuBar())
		Case $s_property = "offline"
			If Not __IEIsObjType($o_object, "browser") Then
				__IEConsoleWriteError("Error", "_IEPropertyGet2", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			Return SetError($_IEStatus_Success, 0, $o_object.OffLine())
		Case $s_property = "readystate"
			If Not __IEIsObjType($o_object, "browser") Then
				__IEConsoleWriteError("Error", "_IEPropertyGet2", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			Return SetError($_IEStatus_Success,0, $o_object.ReadyState())
		Case $s_property = "resizable"
			If Not __IEIsObjType($o_object, "browser") Then
				__IEConsoleWriteError("Error", "_IEPropertyGet2", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			Return SetError($_IEStatus_Success, 0, $o_object.Resizable())
		Case $s_property = "silent"
			If Not __IEIsObjType($o_object, "browser") Then
				__IEConsoleWriteError("Error", "_IEPropertyGet2", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			Return SetError($_IEStatus_Success, 0, $o_object.Silent())
		Case $s_property = "statusbar"
			If Not __IEIsObjType($o_object, "browser") Then
				__IEConsoleWriteError("Error", "_IEPropertyGet2", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			Return SetError($_IEStatus_Success, 0, $o_object.StatusBar())
		Case $s_property = "statustext"
			If Not __IEIsObjType($o_object, "browser") Then
				__IEConsoleWriteError("Error", "_IEPropertyGet2", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			Return SetError($_IEStatus_Success, 0, $o_object.StatusText())
		Case $s_property = "top"
			If Not __IEIsObjType($o_object, "browser") Then
				__IEConsoleWriteError("Error", "_IEPropertyGet2", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			Return SetError($_IEStatus_Success, 0, $o_object.Top())
		Case $s_property = "visible"
			If Not __IEIsObjType($o_object, "browser") Then
				__IEConsoleWriteError("Error", "_IEPropertyGet2", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			Return SetError($_IEStatus_Success, 0, $o_object.Visible())
		Case $s_property = "appcodename"
			Return SetError($_IEStatus_Success, 0, $o_object.document.parentWindow.top.navigator.appCodeName())
		Case $s_property = "appminorversion"
			Return SetError($_IEStatus_Success, 0, $o_object.document.parentWindow.top.navigator.appMinorVersion())
		Case $s_property = "appname"
			Return SetError($_IEStatus_Success, 0, $o_object.document.parentWindow.top.navigator.appName())
		Case $s_property = "appversion"
			Return SetError($_IEStatus_Success, 0, $o_object.document.parentWindow.top.navigator.appVersion())
		Case $s_property = "browserlanguage"
			Return SetError($_IEStatus_Success, 0, $o_object.document.parentWindow.top.navigator.browserLanguage())
		Case $s_property = "cookieenabled"
			Return SetError($_IEStatus_Success, 0, $o_object.document.parentWindow.top.navigator.cookieEnabled())
		Case $s_property = "cpuclass"
			Return SetError($_IEStatus_Success, 0, $o_object.document.parentWindow.top.navigator.cpuClass())
		Case $s_property = "javaenabled"
			Return SetError($_IEStatus_Success, 0, $o_object.document.parentWindow.top.navigator.javaEnabled())
		Case $s_property = "online"
			Return SetError($_IEStatus_Success, 0, $o_object.document.parentWindow.top.navigator.onLine())
		Case $s_property = "platform"
			Return SetError($_IEStatus_Success, 0, $o_object.document.parentWindow.top.navigator.platform())
		Case $s_property = "systemlanguage"
			Return SetError($_IEStatus_Success, 0, $o_object.document.parentWindow.top.navigator.systemLanguage())
		Case $s_property = "useragent"
			Return SetError($_IEStatus_Success, 0, $o_object.document.parentWindow.top.navigator.userAgent())
		Case $s_property = "userlanguage"
			Return SetError($_IEStatus_Success, 0, $o_object.document.parentWindow.top.navigator.userLanguage())
		Case $s_property = "vcard"
			Local $aVcard[1][29]
			$aVcard[0][0] = "Business.City"
			$aVcard[0][1] = "Business.Country"
			$aVcard[0][2] = "Business.Fax"
			$aVcard[0][3] = "Business.Phone"
			$aVcard[0][4] = "Business.State"
			$aVcard[0][5] = "Business.StreetAddress"
			$aVcard[0][6] = "Business.URL"
			$aVcard[0][7] = "Business.Zipcode"
			$aVcard[0][8] = "Cellular"
			$aVcard[0][9] = "Company"
			$aVcard[0][10] = "Department"
			$aVcard[0][11] = "DisplayName"
			$aVcard[0][12] = "Email"
			$aVcard[0][13] = "FirstName"
			$aVcard[0][14] = "Gender"
			$aVcard[0][15] = "Home.City"
			$aVcard[0][16] = "Home.Country"
			$aVcard[0][17] = "Home.Fax"
			$aVcard[0][18] = "Home.Phone"
			$aVcard[0][19] = "Home.State"
			$aVcard[0][20] = "Home.StreetAddress"
			$aVcard[0][21] = "Home.Zipcode"
			$aVcard[0][22] = "Homepage"
			$aVcard[0][23] = "JobTitle"
			$aVcard[0][24] = "LastName"
			$aVcard[0][25] = "MiddleName"
			$aVcard[0][26] = "Notes"
			$aVcard[0][27] = "Office"
			$aVcard[0][28] = "Pager"
			For $i = 0 To 28
				$aVcard[1][$i] = Execute('$o_object.document.parentWindow.top.navigator.userProfile.getAttribute("' & $aVcard[0][$i] & '")')
			Next
			Return SetError($_IEStatus_Success, 0, $aVcard)
		Case $s_property = "referrer"
			Return SetError($_IEStatus_Success, 0, $o_object.document.referrer)
		Case $s_property = "theatermode"
			If Not __IEIsObjType($o_object, "browser") Then
				__IEConsoleWriteError("Error", "_IEPropertyGet2", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			Return SetError($_IEStatus_Success, 0, $o_object.TheaterMode)
		Case $s_property = "toolbar"
			If Not __IEIsObjType($o_object, "browser") Then
				__IEConsoleWriteError("Error", "_IEPropertyGet2", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			Return SetError($_IEStatus_Success, 0, $o_object.ToolBar)
		Case $s_property = "contenteditable"
			If __IEIsObjType($o_object, "browser") Or __IEIsObjType($o_object, "document") Then
				$oTemp = $o_object.document.body
			Else
				$oTemp = $o_object
			EndIf
			Return SetError($_IEStatus_Success, 0, $oTemp.isContentEditable)
		Case $s_property = "innertext"
			If __IEIsObjType($o_object, "documentcontainer") Or __IEIsObjType($o_object, "document") Then
				$oTemp = $o_object.document.body
			Else
				$oTemp = $o_object
			EndIf
			Return SetError($_IEStatus_Success, 0, $oTemp.innerText)
		Case $s_property = "outertext"
			If __IEIsObjType($o_object, "documentcontainer") Or __IEIsObjType($o_object, "document") Then
				$oTemp = $o_object.document.body
			Else
				$oTemp = $o_object
			EndIf
			Return SetError($_IEStatus_Success, 0, $oTemp.outerText)
		Case $s_property = "innerhtml"
			If __IEIsObjType($o_object, "documentcontainer") Or __IEIsObjType($o_object, "document") Then
				$oTemp = $o_object.document.body
			Else
				$oTemp = $o_object
			EndIf
			Return SetError($_IEStatus_Success, 0, $oTemp.innerHTML)
		Case $s_property = "outerhtml"
			If __IEIsObjType($o_object, "documentcontainer") Or __IEIsObjType($o_object, "document") Then
				$oTemp = $o_object.document.body
			Else
				$oTemp = $o_object
			EndIf
			Return SetError($_IEStatus_Success, 0, $oTemp.outerHTML)
		Case $s_property = "title"
			Return SetError($_IEStatus_Success, 0, $o_object.document.title)
		Case $s_property = "uniqueid"
			If __IEIsObjType($o_object, "window") Then
				__IEConsoleWriteError("Error", "_IEPropertyGet2", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			Else
				Return SetError($_IEStatus_Success, 0, $o_object.uniqueID)
			EndIf
		Case Else
			; Unsupported Property
			__IEConsoleWriteError("Error", "_IEPropertyGet2", "$_IEStatus_InvalidValue", "Invalid Property")
			Return SetError($_IEStatus_InvalidValue, 2, 0)
	EndSelect
EndFunc   ;==>_IEPropertyGet



func _debugIE($sObj, $bNullSkip = True)

local $oL
local $sValue
local $aList[1]

for $oL in $sObj.attributes

	$sValue = $oL.value()

	if not ($bNullSkip and ($sValue = "null" or  $sValue = "")) then
		_ArrayAdd($aList, $oL.name & "=" & $sValue)
	endif

next

_ArraySort($aList)

for $i=1 to ubound($aList) -1
	;_debug($aList[$i])
next

endfunc


func _IEGetObjByClassName(byref $oIE, $sTagType,$sClassName)

	local $tag, $class_value
	local $tags = $oIE.document.GetElementsByTagName($sTagType)
	local $sRetTag

	For $tag in $tags
		$class_value = $tag.attributes.class.value()
		;_debug($class_value)
		;_debug($tag.tagname)
		If $class_value = $sClassName Then
			;_debug($class_value)
			$sRetTag = $tag
			exitloop
		EndIf
	Next

	return $sRetTag

endfunc


Func _IEGetObjByLinkText(ByRef $o_object, $s_linkText, $i_index = 0, $f_wait = 1)
	If Not IsObj($o_object) Then
		__IEConsoleWriteError("Error", "_IELinkClickByText", "$_IEStatus_InvalidDataType")
		Return SetError($_IEStatus_InvalidDataType, 1, 0)
	EndIf
	;
	Local $found = 0, $linktext, $links = $o_object.document.links
	$i_index = Number($i_index)
	For $link In $links
		$linktext = $link.outerText & "" ; Append empty string to prevent problem with no outerText (image) links
		If $linktext = $s_linkText Then
			If ($found = $i_index) Then
				return $link
			EndIf
			$found = $found + 1
		EndIf
	Next
	__IEConsoleWriteError("Warning", "_IELinkClickByText", "$_IEStatus_NoMatch")
	Return SetError($_IEStatus_NoMatch, 0, 0) ; Could be caused by parameter 2, 3 or both
EndFunc   ;==>_IELinkClickByText
