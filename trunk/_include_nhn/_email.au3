#include-once
#Include<file.au3>
#Include <WinAPI.au3>

#include ".\_include_nhn\_util.au3"
#include ".\_include_nhn\_base64.au3"

Global $_oEmailErrorRet[2]
Global $_oEmailError


func _SendNaverMail($sFrom, $sToEmail, $sTitle, $sBody, $AttachFiles = "", $bIsUseCID = False, $SmtpServer = "smtp.naver.com", $FromAddress = "ssmmhh_mail@naver.com", $Username = "ssmmhh_mail", $Password = "mail_ssmmhh" , $IPPort = 465)

	local $bReturn = True
	Local $FromName = $sFrom                      ; name from who the email was sent
	Local $ToAddress = $sToEmail   ; destination address of the email - REQUIRED
	Local $Subject = $sTitle                   ; subject from the email - can be anything you want it to be
	Local $Body = $sBody                             ; the messagebody from the mail - can be left blank but then you get a blank mail
	;Local $AttachFiles = ""                       ; the file(s) you want to attach seperated with a ; (Semicolon) - leave blank if not needed
	Local $CcAddress = ""       ; address for cc - leave blank if not needed
	Local $BccAddress = ""     ; address for bcc - leave blank if not needed
	Local $Importance = "Normal"                  ; Send message priority: "High", "Normal", "Low"
	;Local $IPPort = 587                            ; port used for sending the mail
	;Local $IPPort = 465                            ; 네이버 SSL 사용 465 포트
	Local $ssl = 1 ; 0                               ; enables/disables secure socket layer sending - put to 1 if using httpS
	local $rc
	local $i
	;~ $IPPort=465                          ; GMAIL port used for sending the mail
	;~ $ssl=1                               ; GMAILenables/disables secure socket layer sending - put to 1 if using httpS

	;##################################
	; Script
	;##################################


	;$sBody = _Base64Encode($sBody)

	;$Body = "Content-Type: text/plain; charset=UTF-8" & @crlf & "Content-Transfer-Encoding: base64" & $sBody

	for $i=1 to 3

		$_oEmailError = ObjEvent("AutoIt.Error", "MyErrFunc")

		$rc = _INetSmtpMailCom($SmtpServer, $FromName, $FromAddress, $ToAddress, $Subject, $Body, $AttachFiles, $CcAddress, $BccAddress, $Importance, $Username, $Password, $IPPort, $ssl, $bIsUseCID)

		If @error Then
			$bReturn = False
		else
			$bReturn = True
		EndIf

		$_oEmailError = ""

		if $bReturn = True then exitloop

	next

	return $bReturn

endfunc

;
; The UDF
Func _INetSmtpMailCom($s_SmtpServer, $s_FromName, $s_FromAddress, $s_ToAddress, $s_Subject = "", $as_Body = "", $s_AttachFiles = "", $s_CcAddress = "", $s_BccAddress = "", $s_Importance="Normal", $s_Username = "", $s_Password = "", $IPPort = 25, $ssl = 0, $bIsUseCID = False)
    Local $objEmail = ObjCreate("CDO.Message")

	$objEmail.MimeFormatted = True

    $objEmail.From = '"' & $s_FromName & '" <' & $s_FromAddress & '>'
    $objEmail.To = $s_ToAddress
    Local $i_Error = 0
    Local $i_Error_desciption = ""
    If $s_CcAddress <> "" Then $objEmail.Cc = $s_CcAddress
    If $s_BccAddress <> "" Then $objEmail.Bcc = $s_BccAddress
    $objEmail.Subject = $s_Subject

	$objEmail.bodypart.CharSet = "utf-8"

    If StringInStr($as_Body, "<") And StringInStr($as_Body, ">") Then
        $objEmail.HTMLBody = $as_Body
    Else
        $objEmail.Textbody = $as_Body & @CRLF
    EndIf
    If $s_AttachFiles <> "" Then
        Local $S_Files2Attach = StringSplit($s_AttachFiles, ";")
        For $x = 1 To $S_Files2Attach[0]
            $S_Files2Attach[$x] = _PathFull($S_Files2Attach[$x])
;~          ConsoleWrite('@@ Debug : $S_Files2Attach[$x] = ' & $S_Files2Attach[$x] & @LF & '>Error code: ' & @error & @LF) ;### Debug Console
            If FileExists($S_Files2Attach[$x]) Then
                ;ConsoleWrite('+> File attachment added: ' & $S_Files2Attach[$x] & @LF)
				if $bIsUseCID = False then
					$objEmail.AddAttachment($S_Files2Attach[$x])
				Else
					;_debug(_GetFileNameAndExt($S_Files2Attach[$x]))
					;cdoRefTypeId = 0
					;cdoRefTypeLocation = 1
					$objEmail.AddRelatedBodyPart($S_Files2Attach[$x], _GetFileNameAndExt($S_Files2Attach[$x]), 0)
					$objEmail.Fields.Item("urn:schemas:mailheader:Content-ID") = "<" & _GetFileNameAndExt($S_Files2Attach[$x]) & ">"
					$objEmail.Fields.Update
				endif
            Else
                ;ConsoleWrite('!> File not found to attach: ' & $S_Files2Attach[$x] & @LF)
                SetError(1)
                Return 0
            EndIf
        Next
    EndIf
    $objEmail.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/sendusing") = 2
    $objEmail.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/smtpserver") = $s_SmtpServer
    If Number($IPPort) = 0 then $IPPort = 25
    $objEmail.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/smtpserverport") = $IPPort
    ;Authenticated SMTP
    If $s_Username <> "" Then
        $objEmail.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/smtpauthenticate") = 1
        $objEmail.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/sendusername") = $s_Username
        $objEmail.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/sendpassword") = $s_Password
    EndIf
    If $ssl Then
        $objEmail.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/smtpusessl") = True
    EndIf
    ;Update settings
    $objEmail.Configuration.Fields.Update

    ; Set Email Importance
    Switch $s_Importance
        Case "High"
            $objEmail.Fields.Item ("urn:schemas:mailheader:Importance") = "High"
        Case "Normal"
            $objEmail.Fields.Item ("urn:schemas:mailheader:Importance") = "Normal"
        Case "Low"
            $objEmail.Fields.Item ("urn:schemas:mailheader:Importance") = "Low"
    EndSwitch
    $objEmail.Fields.Update
    ; Sent the Message
    $objEmail.Send
    If @error Then
        SetError(2)
        Return $_oEmailErrorRet[1]
    EndIf
    $objEmail=""
EndFunc   ;==>_INetSmtpMailCom
;
;
; Com Error Handler
Func MyErrFunc()
	local $HexNumber

    $HexNumber = Hex($_oEmailError.number, 8)
    $_oEmailErrorRet[0] = $HexNumber
    $_oEmailErrorRet[1] = StringStripWS($_oEmailError.description, 3)
    ;ConsoleWrite("### COM Error !  Number: " & $HexNumber & "   ScriptLine: " & $_oEmailError.scriptline & "   Description:" & $_oEmailErrorRet[1] & @LF)
    SetError(1); something to check for when this function returns
    Return
EndFunc   ;==>MyErrFunc

