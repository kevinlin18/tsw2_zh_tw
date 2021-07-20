#Include <File.au3>
#Include <binary.au3>
Global $Uni = 1 ;~change to unicode
_Import()

Func _Import()
	$TxtPath = $CmdLine[1]
	;~ Change working dir to where the txt file is
	$Dir = StringTrimRight($TxtPath,StringLen(CompGetFileName($TxtPath)))
	FileChangeDir($Dir)
	;~
	Dim $NEWdata, $k = 0
	_FileReadToArray($TxtPath,$NEWdata)
	$Name = StringTrimRight(CompGetFileName($TxtPath),4)
	$File = FileOpen ($Name, 0+16)
	If $File = -1 Then
	MsgBox(0,"Error","Can't open "&$Name&" file.")
	Exit
	EndIf
	$hNewfile = FileOpen("NEW_"&$Name, 2+16)
	$Files = FileRead($File,4)
	If $Files = "0x0E147475" Then
		FileSetPos($File,16,0)
		$Byte = FileRead($File,1)
		$Size = FileRead($File,8)
		FileSetPos($File,0,0)
		FileWrite($hNewfile,FileRead($File,$Size))
		$Files = FileRead($File,4)
		FileWrite($hNewfile,$Files)
		For $i = 1 to $Files
			$NEWdata[$i] = StringReplace($NEWdata[$i],"<cf>",@CRLF)
			$NEWdata[$i] = StringReplace($NEWdata[$i],"<lf>",@LF)
			$NEWdata[$i] = StringReplace($NEWdata[$i],"<cr>",@CR)
			$Enc = 0
			$Size = _BinaryToInt32(FileRead($File,4))
			If $Size < 0 Then
				$Size = -$Size*2
				FileRead($File,$Size)
				$Enc = 1
			Else
				FileRead($File,$Size)
			EndIf
			If $Uni = 1 Then $Enc = 1
			If $Enc = 0 Then
				$NewText = StringToBinary($NEWdata[$i],1) & Binary("0x00")
				FileWrite($hNewfile,_BinaryFromInt32(BinaryLen($NewText)) & $NewText)
			Else
				$NewText = StringToBinary($NEWdata[$i],2) & Binary("0x0000")
				FileWrite($hNewfile,_BinaryFromInt32(-int(BinaryLen($NewText)/2)) & $NewText)
			EndIf
			If $Byte > 1 Then FileWrite($hNewfile,FileRead($File,4))
		Next
		FileClose($hNewfile)
	Else
		FileWrite($hNewfile,$Files)
		for $i = 1 to $Files
			$Size = FileRead($File,4)
			FileWrite($hNewfile,$Size)
			$Size = _BinaryToInt32($Size)
			If $Size < 0 Then
				$Size = -$Size*2
				FileWrite($hNewfile,FileRead($File,$Size))
			Else
				FileWrite($hNewfile,FileRead($File,$Size))
			EndIf
			$Ent = FileRead($File,4)
			FileWrite($hNewfile,$Ent)
			For $e = 1 to $Ent
				$Size = FileRead($File,4)
				FileWrite($hNewfile,$Size)
				$Size = _BinaryToInt32($Size)
				If $Size < 0 Then
					$Size = -$Size*2
					FileWrite($hNewfile,FileRead($File,$Size+4))
				Else
					FileWrite($hNewfile,FileRead($File,$Size+4))
				EndIf
				$NEWdata[$e+$k] = StringReplace($NEWdata[$e+$k],"<cf>",@CRLF)
				$NEWdata[$e+$k] = StringReplace($NEWdata[$e+$k],"<lf>",@LF)
				$NEWdata[$e+$k] = StringReplace($NEWdata[$e+$k],"<cr>",@CR)
				$Size = _BinaryToInt32(FileRead($File,4))
				$Enc = 0
				If $Size < 0 Then
					$Size = -$Size*2
					FileRead($File,$Size)
					$Enc = 1
				Else
					FileRead($File,$Size)
				EndIf
				If $Uni = 1 Then $Enc = 1
				If $Enc = 0 Then
					$NewText = StringToBinary($NEWdata[$i],1) & Binary("0x00")
					FileWrite($hNewfile,_BinaryFromInt32(BinaryLen($NewText)) & $NewText)
				Else
					$NewText = StringToBinary($NEWdata[$i],2) & Binary("0x0000")
					FileWrite($hNewfile,_BinaryFromInt32(-int(BinaryLen($NewText)/2)) & $NewText)
				EndIf
			Next
			$k += $e-1
		Next
		FileClose($hNewfile)
	EndIf
	;~ _TrayTip("i")
EndFunc

Func CompGetFileName($Path)
If StringLen($Path) < 4 Then Return -1
$ret = StringSplit($Path,"\",2)
If IsArray($ret) Then
Return $ret[UBound($ret)-1]
EndIf
If @error Then Return -1
EndFunc

;~ Func _TrayTip($mode)
;~ 	If $mode = "e" Then
;~ 		TrayTip("Export","Finish!",3)
;~ 		sleep(3000)
;~ 	Else
;~ 		TrayTip("Import","Finish!",3)
;~ 		sleep(3000)
;~ 	EndIf
;~ EndFunc