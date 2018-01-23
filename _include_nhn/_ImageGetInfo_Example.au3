#include "image_get_info.au3"
$file = FileOpenDialog("Please select file", "", "Image files (*.jpg;*.tif;*.gif;*.bmp;*.png)");
If @error Then Exit
$aInfo = _ImageGetInfo($file)
If @error Then
    MsgBox (0, "Error", "Can't open file.")
    Exit
Endif
MsgBox (0, "All Picture Info", $aInfo)
MsgBox (0, "Only Width and Height", _ImageGetParam($aInfo, "Width") & "x" & _ImageGetParam($aInfo, "Height"))

