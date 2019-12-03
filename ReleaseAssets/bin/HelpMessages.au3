Func HelpMessage($mode="default")
     If $gValid Then
        Local $error = BoundUncertainty($gSens,$gBounds)
        Local $prcnt = BoundUncertainty($gSens,$gBounds,"%")
        Local $time  = round($gCycle*$gDelay*(int(360/$gSens/$gPartition)+1)/1000)
        If    $mode == "measure" Then
            MsgBox(0, "Info",   "------------------------------------------------------------" & @crlf _
                              & "To match your old sensitivity to a new game:"                 & @crlf _
                              & "------------------------------------------------------------" & @crlf _
                              & "1) Select the preset/game that you are coming from."          & @crlf _
                              & "2) Input your sensitivity value from your old game."          & @crlf _
                              & "3) In your new game, adjust its sens until repeater matches." & @crlf _
                                                                                               & @crlf _
                              & "Press [Alt][ '' ] (quotation mark) to send one turn."         & @crlf _
                              & "Press [Alt][Shift][ '' ] to send " & $gCycle & " turns."      & @crlf _
                              & "Press [Alt][ \ ] to halt (also clears residual)."             & @crlf _
                                                                                               & @crlf _
                              & "------------------------------------------------------------" & @crlf _
                              & "To capture sensitivity manually if your game isn't listed:"   & @crlf _
                              & "------------------------------------------------------------" & @crlf _
                              & "1) Select ''Measure any game'' to enable capture function."   & @crlf _
                              & "2) Record a precise turn in game, then check using repeater." & @crlf _
                              & "3) Use the fine-tuner hotkeys to fine-tune your estimates."   & @crlf _
                                                                                               & @crlf _
                              & "Press [Alt][ / ] to start/finish recording."                  & @crlf _
                              & "Press [Alt][+] to increase counts if repeater undershoots."   & @crlf _
                              & "Press [Alt][ - ] to decrease counts if repeater overshoots."  & @crlf _
                              & "Press [Alt][ 0 ] to clear memory if you made a wrong mark."   & @crlf _
                                                                                               & @crlf _
                              & "The estimates will converge to your exact sensitivity as you "        _
                              & "gradually narrow down its range. You can then use the measured "      _
                              & "sensitivity and match your new game to it."                   & @crlf _
                                                                                               & @crlf _
                              & "------------------------------------------------------------" & @crlf _
                              & "Making precision measurements:"                               & @crlf _
                              & "------------------------------------------------------------" & @crlf _
                              & "1) Record a rotation with slight overshoot as initial guess." & @crlf _
                              & "2) Mark as overshoot. Repeat the process for an undershoot."  & @crlf _
                              & "3) Keep narrowing down estimates by testing w/ the repeater." & @crlf _
                                                                                               & @crlf _
                              & "Under/overshoot drifts can take many cycles to become observable. "   _
                              & "Quantization artifacts can cause phantom shifts up to +/- 0.5 count " _
                              & "that will snap back periodically over many rotations. To positively " _
                              & "qualify under/overshoots, the deviations must equal or exceed +/- 1 " _
                              & "angle increments. Use jog hotkeys to move single incements to check " _
                              & "that deviations are at least one count away from origin."     & @crlf _
                                                                                               & @crlf _
                              & "Press [Alt][>] to jog one count to the right"                 & @crlf _
                              & "Press [Alt][<] to jog one count to the left"                  & @crlf _
                                                                                               & @crlf _
                              & "Remember to undo the jog before resuming cycling. To verify the "     _
                              & "accuracy of your measurement, do at least two measurement sessions "  _
                              & "with different initial values and check that there are no "           _
                              & "contradictions between the MeasureReport files (located at root "     _
                              & "directory of the script.)"                                    & @crlf _
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
        Else
            MsgBox(0, "Info",   "------------------------------------------------------------" & @crlf _
                              & "To match your old sensitivity to a new game:"                 & @crlf _
                              & "------------------------------------------------------------" & @crlf _
                              & "1) Select the preset/game that you are coming from."          & @crlf _
                              & "2) Input your sensitivity value from your old game."          & @crlf _
                              & "3) In your new game, adjust its sens until repeater matches." & @crlf _
                                                                                               & @crlf _
                              & "Press [Alt][ '' ] (quotation mark) to send one turn."         & @crlf _
                              & "Press [Alt][Shift][ '' ] to send " & $gCycle & " turns."      & @crlf _
                              & "Press [Alt][ \ ] to halt (also clears residual)."             & @crlf _
                                                                                               & @crlf _
                              & "------------------------------------------------------------" & @crlf _
                              & "To capture sensitivity manually if your game isn't listed:"   & @crlf _
                              & "------------------------------------------------------------" & @crlf _
                              & "1) Select ''Measure any game'' to enable capture function."   & @crlf _
                              & "2) Record a precise turn in game, then check using repeater." & @crlf _
                              & "3) Use the fine-tuner hotkeys to fine-tune your estimates."   & @crlf _
                                                                                               & @crlf _
                              & "Press [Alt][ / ] to start/finish recording."                  & @crlf _
                              & "Press [Alt][+] to increase counts if repeater undershoots."   & @crlf _
                              & "Press [Alt][ - ] to decrease counts if repeater overshoots."  & @crlf _
                              & "Press [Alt][ 0 ] to clear memory if you made a wrong mark."   & @crlf _
                                                                                               & @crlf _
                              & "The estimates will converge to your exact sensitivity as you "        _
                              & "gradually narrow down its range. You can then use the measured "      _
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
