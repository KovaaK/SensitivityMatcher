Func KeybindSetter($mode,$subset="all")
     Local  $size = 8
     Local  $readval[$size]
     Local  $default[$size] = [   "!{'}"  ,  "!{;}"  ,  "!{\}"  , _
                                  "!{-}"  ,  "!{=}"  ,  "!{0}"  , _
                                  "!{.}"  ,  "!{,}"  ]
     Local  $keyname[$size] = [ "TurnOnce","TurnAlot","StopTurn", _
                                "LessTurn","MoreTurn","ClearMem", _
                                "JogRight","JogLeft"] 
     Local  $fncname[$size] = [ "SingleCycle", _
                                  "AutoCycle", _
                                       "Halt", _
                            "DecreasePolygon", _
                            "IncreasePolygon", _
                                "ClearBounds", _
                                 "NudgeRight", _
                                  "NudgeLeft" ]     
     For    $i = 0 to $size-1
            $readval[$i] = IniRead($gSettingIni,"Hotkeys",$keyname[$i],$default[$i]) 
     Next
     Local  $start  = 0
     Local  $end    = $size-1
     If     $subset = "measure" Then
            $start  = 3
     ElseIf $subset = "turn"    Then
            $end    = 2
     EndIf
     Switch $mode
       Case "initialize"
            Return $readval
       Case "save"
        For $i = $start To $end
         If $gHotkey[$i] Then
            IniWrite($gSettingIni,"Hotkeys",$keyname[$i],$gHotkey[$i]) 
         EndIf
        Next
       Case "disable"
        For $i = $start to $end
         If $gHotkey[$i] Then
            HotKeySet($gHotkey[$i])
         EndIf
        Next
       Case "enable"
        For $i = $start to $end
         If $gHotkey[$i] Then
            HotKeySet($gHotkey[$i],$fncname[$i])
         ElseIf MsgBox(4,"Hotkeys","The hotkey "&$keyname[$i]&" is unbound."&@crlf& _
                          "Use default bind of "&$default[$i]&" instead?") == 6 Then
            $gHotkey[$i] = $default[$i]
            HotKeySet($gHotkey[$i],$fncname[$i])
         EndIf
        Next
     EndSwitch
EndFunc

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
         UpdateMeasurementStatsWindow()
         IniWrite($gReportFile,"Convergence Log",     _
         "lwrbnd:,"&$gBounds[0]&",nxtgss:,"&$gSens&   _
         ",uncrty:+/-,"&BoundUncertainty($gSens,$gBounds)&  _
         ",(+/-"&BoundUncertainty($gSens,$gBounds,"%")&"%),mincycl", _
                 BoundUncertainty($gSens,$gBounds,"rev")             )
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
         UpdateMeasurementStatsWindow()
         IniWrite($gReportFile,"Convergence Log",     _
         "uprbnd:,"&$gBounds[1]&",nxtgss:,"&$gSens&   _
         ",uncrty:+/-,"&BoundUncertainty($gSens,$gBounds)&          _
         ",(+/-"&BoundUncertainty($gSens,$gBounds,"%")&"%),mincycl", _
                 BoundUncertainty($gSens,$gBounds,"rev")             )
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
     $gPartition = NormalizedPartition($gSens,$defaultTurnPeriod,$gDelay)
     $gReportFile= CleanupFileName("MeasureReport"&_Now()&".csv")
     UpdateMeasurementStatsWindow()
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
