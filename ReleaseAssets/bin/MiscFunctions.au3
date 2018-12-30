Func BoundUncertainty($sens,$bounds,$mode=".")
     Local  $output = ($bounds[1]-$bounds[0])/2
     If     $mode  == "%"   Then
            $output = ($bounds[1]-$bounds[0])*50/$sens
     ElseIf $mode  == "rev" Then
            $output = Ceiling($sens*$sens/($bounds[1]-$bounds[0])/360)
     EndIf
     If $output < 0 OR ($bounds[1]==0) Then
        Return "infty"
     Else
        Return $output
     EndIf
EndFunc

Func UpdatePartition($limit,$sens,$bound,$delay)
  Local $error = 1
     If $bound[1] AND ($bound[1] > $bound[0]) Then
        $error = BoundUncertainty($sens,$bound,"%") / 100
     EndIf
  Local $parti = NormalizedPartition($sens, $defaultTurnPeriod*$error, $delay)
     If $parti > $limit Then
        $parti = $limit
     EndIf
 Return $parti
EndFunc

Func NormalizedPartition($incre,$turntime,$delay)
     Local $total = round( 360 / $incre )
     Local $slice = ceiling( $total * $delay / $turntime )
        If $slice > $total Then
           $slice = $total
        EndIf
    Return $slice
EndFunc

Func CleanupFileName($input)
     $input = StringReplace( $input, "?", "" )
     $input = StringReplace( $input, ":", "-" )
     $input = StringReplace( $input, "*", "" )
     $input = StringReplace( $input, "|", "" )
     $input = StringReplace( $input, "/", "-" )
     $input = StringReplace( $input, "\", "" )
     $input = StringReplace( $input, "<", "" )
     $input = StringReplace( $input, ">", "" )
     $input = StringReplace( $input, " ", "_" )
     Return $input
EndFunc

Func InputsValid($sSens, $sPartition, $sYaw, $sTickRate, $sCycle)
     return _StringIsNumber(GuiCtrlRead($sYaw))       AND 0<_GetNumberFromString(GuiCtrlRead($sYaw))      _
        AND _StringIsNumber(GuiCtrlRead($sSens))      AND 0<_GetNumberFromString(GuiCtrlRead($sSens))     _
        AND _StringIsNumber(GuiCtrlRead($sCycle))     AND 0<_GetNumberFromString(GuiCtrlRead($sCycle))    _
        AND _StringIsNumber(GuiCtrlRead($sTickrate))  AND 0<_GetNumberFromString(GuiCtrlRead($sTickrate)) _
        AND _StringIsNumber(GuiCtrlRead($sPartition)) AND 0<_GetNumberFromString(GuiCtrlRead($sPartition))
EndFunc


Func LoadYawList($sFilePath)
     Local $aYawList = IniReadSectionNames($sFilePath)
     Local $sYawList = "Measure any game|" & _
                           "Quake/Source|" & _
                              "Overwatch|" & _
                        "Rainbow6/Reflex|" & _
                                 "Custom|"
     For   $i = 1 to UBound($aYawList)-1
           $sYawList = $sYawList & "/ " & $aYawList[$i] & "|"
     Next
           $sYawList = $sYawList  & "< Save current yaw >|"
    Return $sYawList
EndFunc

Func _MouseMovePlus($X = "", $Y = "")
     Local $MOUSEEVENTF_MOVE = 0x1
     DllCall("user32.dll", "none",     "mouse_event", _
                           "long", $MOUSEEVENTF_MOVE, _
                           "long",                $X, _
                           "long",                $Y, _
                           "long",                 0, _
                           "long",                 0)
EndFunc

Func _StringIsNumber($input) ; Checks if an input string is a number.
;   The default StringIsDigit() function doesn't recognize negatives or decimals.
;   "If $input == String(Number($input))" doesn't recognize ".1" since Number(".1") returns 0.1
;   So, here's a regex I pulled from http://www.regular-expressions.info/floatingpoint.html
   $array = StringRegExp($input, '^[-+]?([0-9]*\.[0-9]+|[0-9]+)$', 3)
   if UBound($array) > 0 Then
      Return True
   EndIf
   Return False
EndFunc

Func _GetNumberFromString($input) ; uses the above regular expression to pull a proper number
;   $array = StringRegExp($input, '^[-+]?([0-9]*\.[0-9]+|[0-9]+)$', 3) ; this didn't return negatives
   $array = StringRegExp($input, '^([-+])?(\d*\.\d+|\d+)$', 3)
   if UBound($array) > 1 Then
      Return Number($array[0] & $array[1]) ; $array[0] is "" or "-", $array[1] is the number.
   EndIf
   Return "error"
EndFunc
