Func HelpMessage($mode="default")
     If $gValid Then
        Local $error = BoundUncertainty($gSens,$gBounds)
        Local $prcnt = BoundUncertainty($gSens,$gBounds,"%")
        Local $time  = round($gCycle*$gDelay*(int(360/$gSens/$gPartition)+1)/1000)
        If    $mode == "measure" Then
            MsgBox(0, "Info",   "------------------------------------------------------------" & @crlf _
                              & "Additional Info:"                                             & @crlf _
                              & "------------------------------------------------------------" & @crlf _
                              & "Key bindings can be changed in UserSettings.ini "             & @crlf _
                                                                                               & @crlf _
                              & "Interval: " & $gDelay & " ms (round up to nearest 0.01 sec.)" & @crlf _
                              & "Estimated Completion Time for " & $gCycle                             _
                              & " cycles: " & $time & " sec"                                   & @crlf _
                                                                                               & @crlf _
                              & "Current Residual Angle: " & $gResidual  & "°"                 & @crlf _
                              & "Current Lower Bound: "    & $gBounds[0] & "°"                 & @crlf _
                              & "Current Increment: "      & $gSens      & "°"                 & @crlf _
                              & "Current Upper Bound: "    & $gBounds[1] & "°"                 & @crlf _
                              & "Uncertainty: ±" & $error  & "° (±"      & $prcnt & "%)"       & @crlf _
                                                                                               & @crlf _
                              & "------------------------------------------------------------" & @crlf _
                              & "Precision Measurements (Advanced):"                           & @crlf _
                              & "------------------------------------------------------------" & @crlf _
                              & "Under/overshoot drifts can take many cycles to become observable. "   _
                              & "Slight shifts up to half-increment that snaps back periodically are " _
                              & "simply visual artifacts of residual angles that cancels itself out "  _
                              & "over many rotations. To positively qualify under/overshoots, the "    _
                              & "deviations must equal or exceed single increment angles. Use the "    _
                              & "jog hotkeys in measurement mode to move single increments to check"   _
                              & " that deviation is at least one count away from origin."      & @crlf _
                                                                                               & @crlf _
                              & "Press [Alt][>] to jog one count to the right"                 & @crlf _
                              & "Press [Alt][<] to jog one count to the left"                  & @crlf _
                                                                                               & @crlf _
                              & "Remember to un-jog if you wish to continue cycling. To share your "   _
                              & "measurement results for others to verify, it is recommended that "    _
                              & "at least two measurement sessions with different non-overlapping "    _
                              & "initial values be performed on two separate in-game settings, for a " _
                              & "total of four MeasureReport files that passes validation for "        _
                              & "consistency (no contradiction between files) and continuity (no "     _
                              & "mismatched bound sequence within a file).")
        Else
            MsgBox(0, "Info",   "------------------------------------------------------------" & @crlf _
                              & "To match your old sensitivity to a new game:"                 & @crlf _
                              & "------------------------------------------------------------" & @crlf _
                              & "1) Select the preset/game that you are coming from."          & @crlf _
                              & "2) Input your sensitivity value from your old game."          & @crlf _
                              & "3) In your new game, adjust its sens until the test matches." & @crlf _
                                                                                               & @crlf _
                              & "Press [Alt][ ' ] (single quote) to perform one full revolution."               & @crlf _
                              & "Press [Alt][ ; ] (semicolon) to perform " & $gCycle & " full revolutions."  & @crlf _
                              & "Press [Alt][ \ ] (backslash) to halt and/or clear residuals (realignment)"  & @crlf _
                                                                                               & @crlf _
                              & "------------------------------------------------------------" & @crlf _
                              & "If your old game is not listed/yaw is unknown:"               & @crlf _
                              & "------------------------------------------------------------" & @crlf _
                              & "1) Select ''Measure any game'' to enable measurement."        & @crlf _
                              & "2) Perform rotations in old game to test your estimate."      & @crlf _
                              & "3) Use the following hotkeys to adjust the estimate."         & @crlf _
                                                                                               & @crlf _
                              & "Press [Alt][+] to increase counts if it's undershooting."         & @crlf _
                              & "Press [Alt][ - ] to decrease counts if it's overshooting."          & @crlf _
                              & "Press [Alt][ 0 ] to clear memory if you made a wrong input."        & @crlf _
                                                                                               & @crlf _
                              & "The estimate will converge to your exact sensitivity as you set "     _
                              & "measurement bounds with hotkeys. You can then use the measured "      _
                              & "sensitivity and match your new game to it."                   & @crlf _
                                                                                               & @crlf _
                              & "------------------------------------------------------------" & @crlf _
                              & "Additional Info:"                                             & @crlf _
                              & "------------------------------------------------------------" & @crlf _
                              & "Key bindings can be changed in UserSettings.ini "             & @crlf _
                                                                                               & @crlf _
                              & "Interval: " & $gDelay & " ms (round up to nearest 0.01 sec.)" & @crlf _
                              & "Estimated Completion Time for " & $gCycle                             _
                              & " cycles: " & $time & " sec"                                   & @crlf _
                                                                                               & @crlf _
                              & "Current Residual Angle: " & $gResidual  & "°"                 & @crlf _
                              & "Current Lower Bound: "    & $gBounds[0] & "°"                 & @crlf _
                              & "Current Increment: "      & $gSens      & "°"                 & @crlf _
                              & "Current Upper Bound: "    & $gBounds[1] & "°"                 & @crlf _
                              & "Uncertainty: ±" & $error  & "° (±"      & $prcnt & "%)"               )
        EndIf
     Else
        MsgBox(0, "Error", "Inputs must be positive numbers")
     EndIf
EndFunc
