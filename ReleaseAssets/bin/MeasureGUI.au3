#include <Array.au3>
Global $g_incidental_recordButton
Global $g_incidental_measureGUI[10]
       $g_incidental_measureGUI[0] = "INACTIVE"
Global $gHistory[1] = [0]

Func DestroyMeasurementStatsWindow()
     If $g_incidental_measureGUI[0] == "INACTIVE" Then 
     Else
         for $i=1 to 8
             GUICtrlDelete($g_incidental_measureGUI[$i])
         next
         GUIDelete($g_incidental_measureGUI[0])
         $g_incidental_measureGUI[0] = "INACTIVE"
         $g_isRecording = false
         GUICtrlSetData($g_incidental_recordButton, "Record")
         GUICtrlSetState($g_incidental_recordButton,$GUI_DISABLE)
         GUICtrlSetData($g_incidental_measureGUI[9], String( 360/$gSens))
        _GUICtrlEdit_SetSel($g_incidental_measureGUI[9], 0, 0 )
     EndIf
EndFunc

Func MakeMeasurementStatsWindow()
    $g_incidental_measureGUI[0] = GUICreate("Convergence Log",205,235,-209,-49,$WS_CAPTION,$WS_EX_MDICHILD,WinGetHandle(""))
    GUICtrlCreateLabel( "Lower Bound:",  5,5,70,20)
    GUICtrlCreateLabel( "Upper Bound:",  5,25,70,20)
    GUICtrlCreateLabel( "Uncertainty: ±",  5,45,70,20)
    $g_incidental_measureGUI[1] = GUICtrlCreateLabel($gBounds[0]&"°",75,5,125,20)
    $g_incidental_measureGUI[2] = GUICtrlCreateLabel($gBounds[1]&"°",75,25,125,20)
    $g_incidental_measureGUI[3] = GUICtrlCreateLabel(BoundUncertainty($gSens,$gBounds,"%")&"%",75,45,130,20)
    $g_incidental_measureGUI[4] = GUICtrlCreateButton("Go Shorter", 5, 205,  65, 25)
    $g_incidental_measureGUI[5] = GUICtrlCreateButton("Reset", 70, 205,  65, 25)
    $g_incidental_measureGUI[6] = GUICtrlCreateButton("Go Further", 135, 205,  65, 25)
    $g_incidental_measureGUI[7] = GUICtrlCreateButton("Table", 164, 179,  35, 20)
    $g_incidental_measureGUI[8] = GUICtrlCreateGraphic(5,65,195,135, 0x07)
    GUICtrlSetBkColor($g_incidental_measureGUI[8], 0xffffff)
    GUISetState(@SW_SHOW)
    GUICtrlSetState($g_incidental_measureGUI[7],$GUI_FOCUS)
    GUICtrlSetState($g_incidental_recordButton,$GUI_ENABLE)
EndFunc

Func UpdateMeasurementStatsWindow($mode=0)
    If $g_incidental_measureGUI[0] == "INACTIVE" Then 
    Else
        GUICtrlSetData($g_incidental_measureGUI[1], $gBounds[0]&"°")
        GUICtrlSetData($g_incidental_measureGUI[2], $gBounds[1]&"°")
        GUICtrlSetData($g_incidental_measureGUI[3], BoundUncertainty($gSens,$gBounds,"%")&"%")
        DrawMeasurementStatsGraph($mode)
    EndIf
EndFunc

Func EventMeasurementStatsWindow($idMsg)
  if $g_incidental_measureGUI[0] == "INACTIVE" then
     return
  elseif $idMsg[0] == $g_incidental_recordButton then
      Local $tempPtr = $g_incidental_measureGUI[0] ; save the pointer of the measureGUI window
      $g_incidental_measureGUI[0] = "INACTIVE"     ; lock this function from being executed by hotkey until it has completed
      if $tempPtr == "INACTIVE" then return        ; double check for edge cases of async hijack
      if $g_isRecording then
         $g_isRecording = not $g_isRecording                        ; stop recording first
         local $l_yawbuffer = $g_yawbuffer                          ; store the finalized reference value
         GUICtrlSetData($g_incidental_measureGUI[9], $l_yawbuffer)  ; show the finalized yawbuffer value
         sleep(10)                                                  ; give a pause to make sure the value is fixated a bit
         $l_yawbuffer = Abs($l_yawbuffer)                           ; only want magnitude of counts
         if $l_yawbuffer > 0 then                                   ; check if any counts have been recorded
             if $idMsg[1] == "HOTKEY" then                          ; play sound if ended by hotkey
                $gSens = 360/$l_yawbuffer
                Beep(330,100)
                Beep(220,100)
             elseif MsgBox(260,"","Recorded "&$l_yawbuffer&" counts for one revolution, confirm entry?")==6 then
                $gSens = 360/$l_yawbuffer                           ; if not ended by hotkey, show dialog to confirm entry before committing
             endif
         elseif $idMsg[1] == "HOTKEY" then                          ; play sound if ended by hotkey with no count recorded
             Beep(220,100)
         endif
         GUICtrlSetData($g_incidental_recordButton, "Record")       ; restore button text to normal status
         GUICtrlSetData($g_incidental_measureGUI[9], String( 360/$gSens))
        _GUICtrlEdit_SetSel($g_incidental_measureGUI[9],0,0)
      else
         $g_yawbuffer = 0                                           ; clear buffer first before activating
         GUICtrlSetData($g_incidental_measureGUI[9], "0")           ; initialize recorded count display
         GUICtrlSetData($g_incidental_recordButton, "Recording...") ; change button text to show recording status
         if $idMsg[1] == "HOTKEY" then Beep(330,100)                ; play the commencement beep only if activated by hotkey
         $g_isRecording = not $g_isRecording                        ; toggle rawinput state only after everything is set
      endif
      $g_incidental_measureGUI[0] = $tempPtr       ; release the execution lock
  elseif $idMsg[1] == $g_incidental_measureGUI[0] then
     Switch $idMsg[0]
       Case $g_incidental_measureGUI[4]
            DecreasePolygon()
       Case $g_incidental_measureGUI[5]
            ClearBounds()
       Case $g_incidental_measureGUI[6]
            IncreasePolygon()
       Case $g_incidental_measureGUI[7]
           _ArrayDisplay($gHistory, "Table", UBound($gHistory)>1 ? "1:" : "")
     EndSwitch
  elseif $g_isRecording then                                        ; if no relelvant events but is in measure mode, only then check if recording is active
     GUICtrlSetData($g_incidental_measureGUI[9], $g_yawbuffer&"..."); live update the displayed counts
  endif
EndFunc

Func DrawMeasurementStatsGraph($mode)
  AutoItSetOption ( "GUICoordMode", 0 )
  if $mode=="CLEAR" then
     GUICtrlSetGraphic($g_incidental_measureGUI[8], $GUI_GR_MOVE, 0, 134)
     GUICtrlSetGraphic($g_incidental_measureGUI[8], $GUI_GR_COLOR, 0xffffff)
     Local $yOffset= UBound($gHistory)==1 ? 0 : _ArrayMin($gHistory,1,1)
     Local $yScale = (_ArrayMax($gHistory,1,1)-$yOffset)
     Local $xScale = UBound($gHistory)
     For $i = 1 to UBound($gHistory)-1
         GUICtrlSetGraphic($g_incidental_measureGUI[8], $GUI_GR_LINE, 194*($i-1)/$xScale, 134*(1-($gHistory[$i]-$yOffset)/$yScale))
         GUICtrlSetGraphic($g_incidental_measureGUI[8], $GUI_GR_MOVE, 194*($i-1)/$xScale, 134*(1-($gHistory[$i]-$yOffset)/$yScale))
     Next     
  else
     Local $lastHistory = _ArrayPop($gHistory)

     GUICtrlSetGraphic($g_incidental_measureGUI[8], $GUI_GR_MOVE, 0, 134)
     GUICtrlSetGraphic($g_incidental_measureGUI[8], $GUI_GR_COLOR, 0xffffff)
     Local $yOffset= UBound($gHistory)==1 ? 0 : _ArrayMin($gHistory,1,1)
     Local $yScale = (_ArrayMax($gHistory,1,1)-$yOffset)
     Local $xScale = UBound($gHistory)
     For $i = 1 to UBound($gHistory)-1
         GUICtrlSetGraphic($g_incidental_measureGUI[8], $GUI_GR_LINE, 194*($i-1)/$xScale, 134*(1-($gHistory[$i]-$yOffset)/$yScale))
         GUICtrlSetGraphic($g_incidental_measureGUI[8], $GUI_GR_MOVE, 194*($i-1)/$xScale, 134*(1-($gHistory[$i]-$yOffset)/$yScale))
     Next

     _ArrayAdd($gHistory,$lastHistory)

     GUICtrlSetGraphic($g_incidental_measureGUI[8], $GUI_GR_MOVE, 0, 134)
     GUICtrlSetGraphic($g_incidental_measureGUI[8], $GUI_GR_COLOR, 0x000000)
     $yOffset= UBound($gHistory)==1 ? 0 : _ArrayMin($gHistory,1,1)
     $yScale = (_ArrayMax($gHistory,1,1)-$yOffset)
     $xScale = UBound($gHistory)
     For $i = 1 to UBound($gHistory)-1
         GUICtrlSetGraphic($g_incidental_measureGUI[8], $GUI_GR_LINE, 194*($i-1)/$xScale, 134*(1-($gHistory[$i]-$yOffset)/$yScale))
         GUICtrlSetGraphic($g_incidental_measureGUI[8], $GUI_GR_MOVE, 194*($i-1)/$xScale, 134*(1-($gHistory[$i]-$yOffset)/$yScale))
     Next
  endif

  AutoItSetOption ( "GUICoordMode", 1 )     
  GUICtrlSetGraphic($g_incidental_measureGUI[8], $GUI_GR_REFRESH)
EndFunc
