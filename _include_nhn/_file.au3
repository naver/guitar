opt("MustDeclareVars",1)
#include-once

#include ".\_include_nhn\_util.au3"



Func _GetLastFromPath($strpath)
	local $temp

	$temp = stringsplit($strpath,"\")

	return $temp[ubound($temp)-1]
endfunc

; =============================================================================================================
Func _GetFileNameFromDir($strTargetDir, $strWildCard, $isIncludeSubdir)
   ; 1차원 배열로 값을 리턴, 없을 경우 "" 값을 리턴
   Local $N_DIRNAMES[400000] ; max number of directories that can be scanned
   Local $N_DIRNAMES_NEW[400000] ; max number of directories that can be scanned
   Local $N_DIRCOUNT = 0
   Local $N_FILE
   Local $N_SEARCH
   Local $N_TFILE
   Local $N_OFILE
   Local $T_FILENAMES
   Local $T_FILECOUNT
   Local $T_Empty[1]
   Local $DirCOUNT = 1
   ; remove the end \ If specified
   If StringRight($strTargetDir,1) = "\" Then $strTargetDir = StringTrimRight($strTargetDir,1)
   $N_DIRNAMES[$DirCOUNT] = $strTargetDir
   ; Exit if base dir doesn't exists
   If Not FileExists($strTargetDir) Then Return $T_Empty
   ; keep on looping until all directories are scanned

   $T_FILECOUNT = 1

   While $DirCOUNT > $N_DIRCOUNT
      $N_DIRCOUNT = $N_DIRCOUNT + 1
      ; find all subdirs in this directory and save them in a array
      $N_SEARCH = FileFindFirstFile($N_DIRNAMES[$N_DIRCOUNT] & "\*.*")
      While 1
         $N_FILE = FileFindNextFile($N_SEARCH)
         If @error Then ExitLoop
         ; skip these references
         If $N_FILE = "." Or $N_FILE = ".." Then ContinueLoop
         $N_TFILE = $N_DIRNAMES[$N_DIRCOUNT] & "\" & $N_FILE
         ; if Directory than add to the list of directories to be processed
         If StringInStr(FileGetAttrib( $N_TFILE ),"D") > 0 and $isIncludeSubdir <> 0 Then
            $DirCOUNT = $DirCOUNT + 1
            $N_DIRNAMES[$DirCOUNT] = $N_TFILE
         EndIf
      Wend
      FileClose($N_SEARCH)
      ; find all Files that mtach the MASK
      $N_SEARCH = FileFindFirstFile($N_DIRNAMES[$N_DIRCOUNT] & "\" & $strWildCard )
      If $N_SEARCH = -1 Then ContinueLoop

      While 1
         $N_FILE = FileFindNextFile($N_SEARCH)
         If @error Then ExitLoop
         ; skip these references
         If $N_FILE = "." Or $N_FILE = ".." Then ContinueLoop
         $N_TFILE = $N_DIRNAMES[$N_DIRCOUNT] & "\" & $N_FILE
         ; if Directory than add to the list of directories to be processed
         If StringInStr(FileGetAttrib( $N_TFILE ),"D") = 0 Then
         	$N_DIRNAMES_NEW[$T_FILECOUNT] =   $N_TFILE
            ;$T_FILENAMES  = $T_FILENAMES & $N_TFILE & @CR
            $T_FILECOUNT = $T_FILECOUNT + 1
            ;MsgBox(0,'filecount ' & $T_FILECOUNT ,$N_TFILE)
         EndIf
      Wend
      FileClose($N_SEARCH)
   Wend

   ;$T_FILENAMES  = StringTrimRight($T_FILENAMES,1)
   ;$N_OFILE = StringSplit($T_FILENAMES,@CR)

   redim $N_DIRNAMES_NEW[$T_FILECOUNT]
   return ($N_DIRNAMES_NEW)
   ;Return( $N_OFILE )
EndFunc   ;==>_GetFileList

; =============================================================================================================


;local $a= _filedbwrite("c:\1db.txt", 1, "한글")
;$a= _filedbwrite("c:\1db.txt", 400, "ABC한글")
;debug(_filedbread("c:\1db.txt", 1))
;debug(_filedbread("c:\1db.txt", 400))
func _filedbwrite($sFile, $iLine, $sContents)

	local $aFile[0], $i, $bRet
	local $sSaveContents
	local $hFilehandle

	if FileExists ($sFile) then

		$bRet = _FileReadToArray($sFile, $aFile)

	endif

	;debug($aFile)
	if ubound($aFile) <= $iLine then ReDim $aFile[$iLine+1]
	;debug($aFile)

	$aFile[$iLine] = $sContents
	$sSaveContents = _ArrayToString( $aFile,@crlf,1,-1)

	$hFilehandle = FileOpen($sFile, $FO_ANSI  + $FO_OVERWRITE)
	FileWrite($hFilehandle, $sSaveContents)
	FileClose($hFilehandle)

endfunc


func _filedbread($sFile, $iLine)

	local $sRet = ""
	local $aFile, $bRet

	if FileExists ($sFile) then

		$bRet = _FileReadToArray($sFile, $aFile)

		if ubound($aFile) > $iLine then
			$sRet = $aFile[$iLine]
		endif

	endif

	return $sRet

endfunc