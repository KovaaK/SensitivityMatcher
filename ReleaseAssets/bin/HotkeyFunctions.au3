Func KeybindSetter($mode,$subset="all")
     Local  $size = 9
     Local  $readval[$size]
     Local  $default[$size] = [   "!{BS}" ,  "!+{BS}",  "!{\}"  , _
                                  "!{-}"  ,  "!{=}"  ,  "!{0}"  , _
                                  "!{.}"  ,  "!{,}"  ,  "!{/}"    ]
     Local  $keyname[$size] = [ "TurnOnce","TurnAlot","StopTurn", _
                                "LessTurn","MoreTurn","ClearMem", _
                                "JogRight","JogLeft","ToggleRec"  ] 
     Local  $fncname[$size] = [ "SingleCycle", _
                                  "AutoCycle", _
                                       "Halt", _
                            "DecreasePolygon", _
                            "IncreasePolygon", _
                                "ClearBounds", _
                                   "JogRight", _
                                    "JogLeft", _
                            "RecordYawToggle"  ]     
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
  If     $gMode>0 and (not $g_isRecording) Then
         $gMode=0
    If   $gValid  Then
         $gResidual  = 0
         $gBounds[0] = $gSens
         _ArrayAdd($gHistory, $gSens)
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
    sleep(10)
    $gMode=1
  EndIf
EndFunc

Func IncreasePolygon()
  If     $gMode>0 and (not $g_isRecording) Then
         $gMode=0
    If   $gValid  Then
         $gResidual  = 0
         $gBounds[1] = $gSens
         _ArrayAdd($gHistory, $gSens)
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
    sleep(10)
    $gMode=1
  EndIf
EndFunc

Func ClearBounds()
     $gResidual  = 0
     $gBounds[0] = 0
     $gBounds[1] = 0
     $gPartition = NormalizedPartition($gSens,$defaultTurnPeriod,$gDelay)
     $gReportFile= CleanupFileName("MeasureReport"&_Now()&".csv")
     UpdateMeasurementStatsWindow("CLEAR")
     Global $gHistory[1] = [0]
EndFunc

Func JogLeft()
  If $gMode > 0 Then
     $gMode = 0
    _MouseMovePlus(-1,0)
     $gMode = 1
  EndIf
EndFunc

Func JogRight()
  If $gMode > 0 Then
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

Func RecordYawToggle()
  If $gMode > 0 Then
     $gMode = 0
     local $idMsg[2] = [$g_incidental_recordButton,"HOTKEY"]
     EventMeasurementStatsWindow($idMsg)
     sleep(10)
     $gMode = 1
  EndIf
EndFunc



Func TestMouse($cycle)
   If $gMode > 0 Then           ; three states of $gMode: -1, 0, 1. A 0 means in-progress and exits the command without doing anything.
      $gMode = 0                ; -1 means manual override and is checked for before performing every operation, 1 means all is good to go.

      $partition  = $gPartition
      $delay      = $gDelay
      $turn       = 0.0
      $totalcount = 1
      $grandtotal = (($cycle*360)+$gResidual)/$gSens

      While $cycle > 0
            $cycle         = $cycle - 1
            $turn          = 360                                               ; one revolution in deg
            $totalcount    = ( $turn + $gResidual ) / ( $gSens )               ; partitioned by user-defined increments
            $totalcount    = Round( $totalcount )                              ; round to nearest integer
            $gResidual     = ( $turn + $gResidual ) - ( $gSens * $totalcount ) ; save the residual angles
         While $totalcount > $partition
            If $gMode < 0 Then
               ExitLoop
            EndIf
            _MouseMovePlus($partition,0)
            $totalcount = $totalcount - $partition
            Sleep($delay)
         WEnd
         If $gMode < 0 Then
            ExitLoop
         EndIf
        _MouseMovePlus($totalcount,0) ; do the leftover
         Sleep($delay)
      WEnd
      
      If $gMode == 0 Then
         $gMode = 1
         $gResidual = $gSens * ( $grandtotal - round($grandtotal) )
      EndIf
   EndIf
EndFunc
