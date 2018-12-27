Func DecreasePolygon()
  If     $gMode>0 Then
         $gMode=0
    If   $gValid  Then
         $gResidual  = 0
         $gBounds[0] = $gSens
      If $gBounds[1] < $gBounds[0] Then
         $gBounds[1] = 0
         $gSens      = $gBounds[0] * 2
      Else
         $gSens      =($gBounds[0] + $gBounds[1]) / 2
      EndIf
         IniWrite($gReportFile,"Convergence Log",     _
         "lwrbnd:,"&$gBounds[0]&",nxtgss:,"&$gSens&   _
         ",uncrty:+/-,"&GlobalUncertainty()&          _
         ",(+/-"&GlobalUncertainty("%")&"%),mincycl", _
                 GlobalUncertainty("rev")             )
    Else
         HelpMessage()
    EndIf
    $gMode=1
  EndIf
EndFunc

Func IncreasePolygon()
  If     $gMode>0 Then
         $gMode=0
    If   $gValid  Then
         $gResidual  = 0
         $gBounds[1] = $gSens
      If $gBounds[1] < $gBounds[0] Then
         $gBounds[0] = 0
         $gSens      = $gBounds[1] / 2
      Else
         $gSens      =($gBounds[0] + $gBounds[1]) / 2
      EndIf
         IniWrite($gReportFile,"Convergence Log",     _
         "uprbnd:,"&$gBounds[1]&",nxtgss:,"&$gSens&   _
         ",uncrty:+/-,"&GlobalUncertainty()&          _
         ",(+/-"&GlobalUncertainty("%")&"%),mincycl", _
                 GlobalUncertainty("rev")             )
    Else
         HelpMessage()
    EndIf
    $gMode=1
  EndIf
EndFunc

Func ClearBounds()
     $gResidual  = 0
     $gBounds[0] = 0
     $gBounds[1] = 0
     $gPartition = NormalizedPartition($defaultTurnPeriod)
     $gReportFile= CleanupFileName("MeasureReport"&_Now()&".csv")
EndFunc

Func NudgeLeft()
  If $gMode = 1 Then
     $gMode = 0
    _MouseMovePlus(-1,0)
     $gMode = 1
  EndIf
EndFunc

Func NudgeRight()
  If $gMode = 1 Then
     $gMode = 0
    _MouseMovePlus(1,0)
     $gMode = 1
  EndIf
EndFunc

Func SingleCycle()
  If $gValid Then
     TestMouse(1)
  Else
     HelpMessage()
  EndIf
EndFunc

Func AutoCycle()
  If $gValid Then
     TestMouse($gCycle)
  Else
     HelpMessage()
  EndIf
EndFunc

Func Halt()
  If $gMode > -1 Then
     $gMode = -1
     $gResidual = 0
  EndIf
EndFunc
