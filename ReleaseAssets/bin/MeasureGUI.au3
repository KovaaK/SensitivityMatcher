Global $g_incidental_recordButton
Global $g_incidental_measureGUI[10]
Global $g_yawbuffer = 0
Global $g_isRecording = 0

$g_incidental_measureGUI[0] = "INACTIVE"

Func DestroyMeasurementStatsWindow()
     If $g_incidental_measureGUI[0] == "INACTIVE" Then 
     Else
         GUICtrlSetData($g_incidental_measureGUI[9], String( 360/$gSens))
         for $i=1 to 8
             GUICtrlDelete($g_incidental_measureGUI[$i])
         next
         $g_isRecording = 0
         GUICtrlSetData($g_incidental_recordButton, "Record")
         GUICtrlSetState($g_incidental_recordButton,$GUI_DISABLE)
         GUIDelete($g_incidental_measureGUI[0])
         $g_incidental_measureGUI[0] = "INACTIVE"
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
    $g_incidental_measureGUI[6] = GUICtrlCreateButton("Go Farther", 135, 205,  65, 25)
    $g_incidental_measureGUI[7] = GUICtrlCreateButton("Table", 164, 179,  35, 20)
    $g_incidental_measureGUI[8] = GUICtrlCreateGraphic(5,65,195,135,0x07)
    GUICtrlSetBkColor($g_incidental_measureGUI[8], 0xffffff)
    GUISetState(@SW_SHOW)
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

Func EventMeasurementStatsWindow($idMsg)
  if $idMsg[0] == $g_incidental_recordButton then
      if $g_isRecording == 0 then
         $g_isRecording = 1
         $g_yawbuffer = 0
         GUICtrlSetData($g_incidental_measureGUI[9], "0")
         GUICtrlSetData($g_incidental_recordButton, "Recording...")
         if $idMsg[1] == "HOTKEY" then Beep(330,100)
         Sleep(10)
      else
         $g_isRecording = 0
         Sleep(10)
         local $l_yawbuffer = Abs($g_yawbuffer)
         if $l_yawbuffer > 0 then 
             if $idMsg[1] == "HOTKEY" then
                $gSens = 360/$l_yawbuffer
                Beep(330,100)
                Beep(220,100)
             elseif MsgBox(260,"Write to increment","Recorded "&$l_yawbuffer&" counts for one revolution, confirm entry?")==6 then
                $gSens = 360/$l_yawbuffer
             endif
         elseif $idMsg[1] == "HOTKEY" then 
             Beep(220,100)
         endif
         GUICtrlSetData($g_incidental_recordButton, "Record")
         GUICtrlSetData($g_incidental_measureGUI[9], String( 360/$gSens))
        _GUICtrlEdit_SetSel($g_incidental_measureGUI[9],0,0)
      endif
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
  endif
EndFunc
