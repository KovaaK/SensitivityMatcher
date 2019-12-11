#include "Header.au3"

Global Const $yawQuake          = 0.022
Global Const $yawOverwatch      = 0.0066
Global Const $yawReflex         = _Degree(0.0001)
Global Const $yawDiabotical     = 1/60
Global Const $gSettingIni = "UserSettings.Ini"
Global Const $gYawListIni = "CustomYawList.ini"
Global       $gReportFile = "MeasureReport.csv"
Global       $gHotkey[8]  =  KeybindSetter("initialize")

Global       $gValid     =  1    ; Keeps track of whether all user inputs are valid numbers or not
Global       $gMode      = -1    ; Three states of $gMode: -1, 0, and 1, for halt override, in-progress, and ready.
Global       $gSens      =  0.022
Global       $gPartition =  480
Global       $gDelay     =  10
Global       $gCycle     =  22
Global       $gResidual  =  0.0  ; Residual accumulator
Global       $gBounds[2] = [0,0] ; Upper/lower bounds of increment

MakeGUI()

Func MakeGUI()
   Global $idGUI = GUICreate("Sensitivity Matcher", 295, 235,-1,-1,BitXOR($GUI_SS_DEFAULT_GUI, $WS_MINIMIZEBOX))
   GUISetIcon("shell32_16739.ico")
   GUICtrlCreateLabel( "Select preset yaw:"                ,   0,   7,  95, 15, $SS_RIGHT )
   GUICtrlCreateLabel( "Sens"                              ,   5,  50,  80, 15, $SS_CENTER)
   GUICtrlCreateLabel( "×"                                 ,  85,  33,  15, 15, $SS_CENTER)
   GUICtrlCreateLabel( "Yaw (deg)"                         , 100,  50,  95, 15, $SS_CENTER)
   GUICtrlCreateLabel( "="                                 , 195,  33,  15, 15, $SS_CENTER)
   GUICtrlCreateLabel( "Increment"                         , 210,  50,  80, 15, $SS_CENTER)
   GUICtrlCreateGraphic(                                       5,  70, 285,  2, $SS_SUNKEN) ; horizontal line
   GUICtrlCreateLabel( "Repeater Function Options"         ,   5,  80, 285, 15, $SS_CENTER)
   GUICtrlCreateLabel( "One Revolution of"                 ,   0, 102,  95, 15, $SS_RIGHT )
   GUICtrlCreateLabel( "counts."                           , 200, 102,  60, 15, $SS_LEFT  )
   GUICtrlCreateLabel( "Move Partitions of"                ,   0, 127,  95, 15, $SS_RIGHT )
   GUICtrlCreateLabel( "counts"                            , 200, 127,  60, 15, $SS_LEFT  )
   GUICtrlCreateLabel( "at a Frequency of"                 ,   0, 152,  95, 15, $SS_RIGHT )
   GUICtrlCreateLabel( "Hz"                                , 200, 152,  60, 15, $SS_LEFT  )
   GUICtrlCreateLabel( "for a Cycle of"                    ,   0, 177,  95, 15, $SS_RIGHT )
   GUICtrlCreateLabel( "revolutions."                      , 200, 177,  60, 15, $SS_LEFT  )


   Local $sYawPresets = GUICtrlCreateCombo( ""             , 100,   5, 110, 20)
   Local $sSens       = GUICtrlCreateInput( "1"            ,   5,  30,  80, 20)
   Local $sYaw        = GUICtrlCreateInput( $gSens         , 100,  30,  95, 20)
   Local $sIncr       = GUICtrlCreateInput( $gSens         , 210,  30,  80, 20)
                        GUICtrlSendMsg(     $sIncr  , $EM_SETREADONLY,   1,  0)
   Local $sCounts     = GUICtrlCreateInput( 360/$gSens     , 100, 100,  95, 20)
                        GUICtrlSendMsg(     $sCounts, $EM_SETREADONLY,   1,  0)
   Local $sPartition  = GUICtrlCreateInput( $gPartition    , 100, 125,  95, 20)
   Local $sTickRate   = GUICtrlCreateInput( 1000/$gDelay   , 100, 150,  95, 20)
   Local $sCycle      = GUICtrlCreateInput( $gCycle        , 100, 175,  95, 20)
   Local $idSave      = GUICtrlCreateButton("Save to Default", 5, 205,  95, 25)
   Local $idHelp      = GUICtrlCreateButton("Instructions" , 100, 205,  95, 25)
   Local $idCalc      = GUICtrlCreateButton("Physical Stats...",195,205,95, 25)

$g_incidental_recordButton = GUICtrlCreateButton("Record", 213, 4,  78, 23)
GUICtrlSetState($g_incidental_recordButton,$GUI_DISABLE)
$g_incidental_measureGUI[9]=$sCounts


   Local $hToolTip    =_GUIToolTip_Create(0)                                     ; default tooltip
                       _GUIToolTip_SetDelayTime($hToolTip, $TTDT_AUTOPOP, 30000) ; Set the tooltip to last 30 seconds. If I set this to 60 seconds, it seems to go back to 5.
                       _GUIToolTip_SetDelayTime($hToolTip, $TTDT_RESHOW, 500)    ; don't show a new tooltip till 0.5 secs later
                       _GUIToolTip_SetMaxTipWidth($hToolTip, 500)
   Local $hSens       = GUICtrlGetHandle($sSens)
                       _GUIToolTip_AddTool($hToolTip, 0, "Enter your game's sensitivity here", $hSens)
   Local $hYaw        = GUICtrlGetHandle($sYaw)
                       _GUIToolTip_AddTool($hToolTip, 0, "Base rotator unit for yaw associated with game/configuration (use dropdown menu above if possible).", $hYaw)
   Local $hIncr       = GUICtrlGetHandle($sIncr)
                       _GUIToolTip_AddTool($hToolTip, 0, "The smallest angle you could possibly rotate in-game, given your sensitivity configuration.", $hIncr)
   Local $hCounts     = GUICtrlGetHandle($sCounts)
                       _GUIToolTip_AddTool($hToolTip, 0, "A full rotation with your sensitivity configuration requires this many mouse counts to complete.", $hCounts)
   Local $hPartition  = GUICtrlGetHandle($sPartition)
                       _GUIToolTip_AddTool($hToolTip, 0, "Send this many mouse counts at a time to the game when testing. For non-rawinput games, don't let this exceed half of your in-game horizontal resolution (e.g.: if you use 1920x1080, don't use numbers greater than 960).", $hPartition)
   Local $hTickRate   = GUICtrlGetHandle($sTickRate)
                       _GUIToolTip_AddTool($hToolTip, 0, "How many times per second to send mouse movements. Make sure this isn't higher than your framerate, especially for non-rawinput games.", $hTickRate)
   Local $hCycle      = GUICtrlGetHandle($sCycle)
                       _GUIToolTip_AddTool($hToolTip, 0, "How many full revolutions to perform when pressing the multicycle hotkey.", $hCycle)


   ; Initialize all inputs to ini or hardcoded defaults
   GUICtrlSetData( $sYawPresets , LoadYawList($gYawListIni)                                                         )
   GUICtrlSetdata( $sPartition  , IniRead( $gSettingIni,"Default","part",GUICtrlRead($sPartition) )                 )
   GUICtrlSetdata( $sTickRate   , IniRead( $gSettingIni,"Default","freq",GUICtrlRead($sTickRate)  )                 )
   GUICtrlSetdata( $sCycle      , IniRead( $gSettingIni,"Default","cycl",GUICtrlRead($sCycle)     )                 )
   GUICtrlSetData( $sYaw        , IniRead( $gSettingIni,"Default","yaw" ,GUICtrlRead($sYaw)       )                 )
   GUICtrlSetData( $sSens       , IniRead( $gSettingIni,"Default","sens",GUICtrlRead($sSens)      )                 )
   GUICtrlSetData( $sIncr       ,_GetNumberFromstring(GUICtrlread($sYaw))*_GetNumberFromString(GUICtrlRead($sSens)) )
   GUICtrlSetData( $sCounts     ,                                     360/_GetNumberFromString(GUICtrlRead($sIncr)) )
  _GUICtrlEdit_SetSel($sCounts,0,0)


   ; Initialize Global Variables to UI Inputs. Once initialized, they are individually self-updating within the main loop
   $gSens      = _GetNumberFromString(GuiCtrlRead($sSens)) * _GetNumberFromString(GuiCtrlRead($sYaw))
   $gDelay     =  10 * Ceiling( 100 / _GetNumberFromString( GuiCtrlRead($sTickRate) ) )
   $gPartition = _GetNumberFromString(GuiCtrlRead($sPartition))
   $gCycle     = _GetNumberFromString(GuiCtrlRead($sCycle))
   $gResidual  =  0.0
   $gMode      =  1
   
   
   ; Declare adhoc local variables outside the loop
   Local $idMsg[2]       = [$sYaw,$idGUI]            ; Variable to save GUIGetMsg(1).  Initialized to "detect change in Yaw input box from main GUI".
   Local $idGUICalc      = "INACTIVE"                ; Handle of stats calculator. When not open, manually set to "INACTIVE" so it won't execute anything
   Local $lPartition     = $gPartition               ; Local copy of user-entered partition value, passed to UpdatePartition to clip the NormalizedPartition result
   Local $lastgSens      = $gSens                    ; Keeps track of whether there was an event that changed gSens outside of the main loop. This can happen either by hotkeys in Measurement Mode or by tweaking the Physical Sensitivities in the calc window
   Local $lastYawPresets = GUICtrlRead($sYawPresets) ; Used by Case "<save current yaw>" to keep track of yawpreset state prior to the most recent yawpreset event, so that in the event the user cancels after selecting <save current yaw>, it restores the yaw preset that was last selected.
   Local $lCalculator[10]                             ; ByRef handles for HandyCalc. Never addressed directly in loop.
   
   FirstLaunchCheck()
   SetupRawinput($idGUI)
   GUISetState(@SW_SHOW)
   KeybindSetter("enable","turn")
   Do
      Switch $idMsg[0]             
        Case $sCycle
             $gResidual  = 0
             $gCycle     = _GetNumberFromString(GuiCtrlRead($sCycle))

        Case $sTickRate
             $gResidual  = 0
             $gDelay     = 10*Ceiling(100/_GetNumberFromString(GuiCtrlRead($sTickRate)))
             GUICtrlSetData( $sTickRate , 1000/$gDelay )

        Case $sPartition
             $gResidual  = 0
             $lPartition = _GetNumberFromString(GuiCtrlRead($sPartition))
             $gPartition = $lPartition
          If $lastYawPresets == "Measure any game" Then
             $gPartition = UpdatePartition($gPartition,$gSens,$gBounds,$gDelay)
          EndIf

        Case $sSens
             $gResidual  = 0
             $gSens      = _GetNumberFromString( GuiCtrlRead($sSens) ) * _GetNumberFromString( GuiCtrlRead($sYaw) )
             $lastgSens  = $gSens
             $idMsg[0]   = -1
             GUICtrlSetData(     $sCounts, String( 360/$gSens ) )
            _GUICtrlEdit_SetSel( $sCounts, 0, 0 )
             GUICtrlSetData(     $sIncr  , String(     $gSens ) )
            _GUICtrlEdit_SetSel( $sIncr  , 0, 0 )

        Case $sYaw, $sYawPresets
             $gResidual  = 0
          If $idMsg[0]  == $sYawPresets Then
             $gPartition = $lPartition
             GUICtrlSetData(   $idHelp, YawPresetHandler($lastYawPresets,$sYawPresets,$sYaw,$sSens)   )
          ElseIf  $lastYawPresets == "Measure any game"                     Then
                 ; Do nothing if yaw changed during measurement mode
          ElseIf _GetNumberFromString(GuiCtrlRead($sYaw)) == $yawQuake      Then
                 _GUICtrlComboBox_SelectString($sYawPresets, "Quake/Source")
          ElseIf _GetNumberFromString(GuiCtrlRead($sYaw)) == $yawOverwatch  Then
                 _GUICtrlComboBox_SelectString($sYawPresets, "Overwatch")
          ElseIf _GetNumberFromString(GuiCtrlRead($sYaw)) == $yawReflex     Then
                 _GUICtrlComboBox_SelectString($sYawPresets, "Rainbow6/Reflex")
          ElseIf _GetNumberFromString(GuiCtrlRead($sYaw)) == $yawDiabotical Then
                 _GUICtrlComboBox_SelectString($sYawPresets, "Diabotical")
          Else
                 _GUICtrlComboBox_SetEditText($sYawPresets, "Custom")
          EndIf
             GUICtrlSetData(    $sSens, String( $gSens / _GetNumberFromString( GuiCtrlRead($sYaw) ) ) )
            _GUICtrlEdit_SetSel($sSens, 0, 0 )
            _GUICtrlEdit_SetSel($sYaw , 0, 0 )
             $lastYawPresets = GUICtrlRead($sYawPresets)

        Case $idSave
          If $gValid Then
           If MsgBox(1,"Save values","Save current values to startup default?") == 1 Then
              KeybindSetter("save")
              IniWrite($gSettingIni,"Default","sens",_GetNumberFromString(GuiCtrlRead($sSens)))
              IniWrite($gSettingIni,"Default","yaw" ,_GetNumberFromString(GuiCtrlRead($sYaw)))
              IniWrite($gSettingIni,"Default","part",_GetNumberFromString(GuiCtrlRead($sPartition)))
              IniWrite($gSettingIni,"Default","freq",_GetNumberFromString(GuiCtrlRead($sTickRate)))
              IniWrite($gSettingIni,"Default","cycl",_GetNumberFromString(GuiCtrlRead($sCycle)))
             If NOT ($idGUICalc == "INACTIVE") Then
              IniWrite($gSettingIni,"Default","cpi" ,_GetNumberFromString(GuiCtrlRead($lCalculator[1])))
              MsgBox(0,"Success","Saved CPI, Sens, Yaw, Partition, Frequency, Cycle, and Hotkeys.")
             Else
              MsgBox(0,"Success","Saved Sens, Yaw, Partition, Frequency, Cycle, and Hotkeys.")
             EndIf
           EndIf
          Else
             HelpMessage()
          EndIf

        Case $idCalc
          If $idGUICalc == "INACTIVE" Then
             $idGUICalc = HandyCalculator("INITIALIZE",$lCalculator,$idMsg)
          Else
             GUISetState(@SW_RESTORE,$idGUICalc)
             GUIDelete($idGUICalc)
             $idGUICalc="INACTIVE"
             $g_isCalibratingCPI = false
          EndIf

        Case $idHelp
          If $lastYawPresets == "Measure any game" Then
             HelpMessage("measure")
          Else
             HelpMessage()
          EndIf

      EndSwitch
      
      If not ($idGUICalc == "INACTIVE") Then
        if $idMsg[0] == $lCalculator[8] then
          Local $chatbot_string = InputBox("Chat Bot Command - Click OK to Copy", _
                                                                             " ", _
                                                                  "My sens is " & _
                    0.001*round(1000*_GetNumberFromString(GUICtrlRead($lCalculator[2]))) & "deg/mm (" & _
                      0.01*round(100*_GetNumberFromString(GUICtrlRead($lCalculator[4]))) & "cm/rev) at " & _
                               round(_GetNumberFromString(GUICtrlRead($lCalculator[1]))) & "cpi, <" & _
                                                       GUICtrlRead($sYawPresets) & "> " & GUICtrlRead($sSens), _
                                                                  "",495,1)
          If $chatbot_string then ClipPut($chatbot_string)
        endif
      EndIf


      If $lastgSens <> $gSens Then
         $lastgSens =  $gSens
         $gResidual =  0
         $idMsg[0]  = -1
         GUICtrlSetData(     $sSens  , String(     $gSens / _GetNumberFromString( GuiCtrlRead($sYaw) ) ) )
         GUICtrlSetData(     $sIncr  , String(     $gSens ) )
         GUICtrlSetData(     $sCounts, String( 360/$gSens ) )
        _GUICtrlEdit_SetSel( $sCounts, 0, 0 )
        _GUICtrlEdit_SetSel( $sIncr  , 0, 0 )
        _GUICtrlEdit_SetSel( $sSens  , 0, 0 )
         If  $lastYawPresets == "Measure any game" Then
             $gPartition = UpdatePartition( $lPartition, $gSens, $gBounds, $gDelay)
         EndIf
      EndIf

      HandyCalculator($idGUICalc,$lCalculator,$idMsg)
      EventMeasurementStatsWindow($idMsg)
      $gMode  = Abs($gMode)       ; if override then ready, if ready or in progress then no change.
      $gValid = InputsValid($sSens, $sPartition, $sYaw, $sTickRate, $sCycle)
   Until GetEvent($idMsg)
EndFunc

Func GetEvent(ByRef $idMsg)
     $idMsg = GUIGetMsg(1)
  If $idMsg[0] == $GUI_EVENT_CLOSE and $idMsg[1]==$idGUI Then
     Return 1
  EndIf
EndFunc

Func HandyCalculator($idGUICalc, ByRef $sInput, $idMsg)
  If $idGUICalc == "INACTIVE" Then
      ; do nothing and exit the function
  Else
      If $idGUICalc == "INITIALIZE" Then
         $idGUICalc=GUICreate("Physical Sensitivity",200,235,293,-49,$WS_CAPTION,BitOR($WS_EX_MDICHILD,$WS_EX_TOOLWINDOW),$idGUI)
         GUICtrlCreateLabel("Game (DAC):",10,9,70,15,$SS_RIGHT)
         GUICtrlCreateLabel("Mouse (ADC):",10,33,70,15,$SS_RIGHT)
         GUICtrlCreateLabel("deg",170,9,35,15,$SS_LEFT)
         GUICtrlCreateLabel("CPI",170,33,35,15,$SS_LEFT)
         GUICtrlCreateGraphic(10,80,180,2,$SS_SUNKEN)
         GUICtrlCreateLabel("Aim Curvature",50,87,100,15,$SS_CENTER)
         GUICtrlCreateLabel("deg/mm",20,127,75,15,$SS_CENTER)
         GUICtrlCreateLabel("MPI",105,127,75,15,$SS_CENTER)
         GUICtrlCreateLabel("Turn Circumference",10,150,180,15,$SS_CENTER)
         GUICtrlCreateLabel("cm/rev",20,190,75,15,$SS_CENTER)
         GUICtrlCreateLabel("in/rev",105,190,75,15,$SS_CENTER)
         $sInput[0]=GUICtrlCreateInput(                                                  $gSens     , 85,  6, 80, 20)
         GUICtrlSendMsg($sInput[0],$EM_SETREADONLY,1,0)
         $sInput[1]=GUICtrlCreateInput(     IniRead($gSettingIni,"Default","cpi",800)               , 85, 30, 80, 20)
         $sInput[2]=GUICtrlCreateInput(    _GetNumberFromString(GUICtrlRead($sInput[1]))*$gSens/25.4, 20,107, 75, 20)
         $sInput[3]=GUICtrlCreateInput(    _GetNumberFromString(GUICtrlRead($sInput[1]))*$gSens*60  ,105,107, 75, 20)
         $sInput[4]=GUICtrlCreateInput(360/_GetNumberFromString(GUICtrlRead($sInput[1]))/$gSens*2.54, 20,170, 75, 20)
         $sInput[5]=GUICtrlCreateInput(360/_GetNumberFromString(GUICtrlRead($sInput[1]))/$gSens     ,105,170, 75, 20)
         $sInput[6]=GUICtrlCreateCheckbox("Lock physical sensitivity", 35,208,130)
         $sInput[7]=GUICtrlCreateButton("Calibrate Mouse CPI", 45,53,110,23)
         $sInput[8]=GUICtrlCreateButton("Share",164,74,32,17)
         $sInput[9]=GUICtrlCreateLabel("", 10,58,35,15,$SS_RIGHT)
         Local $hToolTip=_GUIToolTip_Create(0)
                         _GUIToolTip_SetDelayTime($hToolTip, $TTDT_AUTOPOP, 30000)
                         _GUIToolTip_SetDelayTime($hToolTip, $TTDT_RESHOW, 500)
                         _GUIToolTip_SetMaxTipWidth($hToolTip, 500)
         Local $hInc    = GUICtrlGetHandle($sInput[0])
                         _GUIToolTip_AddTool($hToolTip, 0, "Degree Per Count", $hInc)
         Local $hCPI    = GUICtrlGetHandle($sInput[1])
                         _GUIToolTip_AddTool($hToolTip, 0, "Count Per Inch", $hCPI)
         Local $hDgm    = GUICtrlGetHandle($sInput[2])
                         _GUIToolTip_AddTool($hToolTip, 0, "degree per mm = incre*CPI/25.4", $hDgm)
         Local $hMPI    = GUICtrlGetHandle($sInput[3])
                         _GUIToolTip_AddTool($hToolTip, 0, "Minute[of arc] Per Inch = incre*CPI*60", $hMPI)
         Local $hCcm    = GUICtrlGetHandle($sInput[4])
                         _GUIToolTip_AddTool($hToolTip, 0, "cm per revolution = 2.54 * 360°/(incre*CPI)", $hCcm)
         Local $hCin    = GUICtrlGetHandle($sInput[5])
                         _GUIToolTip_AddTool($hToolTip, 0, "inch per revolution = 360°/(incre*CPI)", $hCin)
         Local $hCal    = GUICtrlGetHandle($sInput[7])
                         _GUIToolTip_AddTool($hToolTip, 0, "Click to start recording mouse movement, then hit space to end the measurement.", $hCal)
         GUICtrlSetState($sInput[1],$GUI_FOCUS)
         GUISetState(@SW_SHOW)
         For $i = 0 to 5
            _GUICtrlEdit_SetSel($sInput[$i], 0, 0 )
         Next
      EndIf
      Local  $cpi = _GetNumberFromString( GUICtrlRead($sInput[1]) )
      Local  $lock=  GUICtrlRead($sInput[6])
      Switch $idMsg[0]
        Case $sInput[1]
          IniWrite($gSettingIni,"Default","cpi",$cpi)
          If $lock == $GUI_UNCHECKED Then
             $idMsg[0] = -1
          Else
             $gSens    =      _GetNumberFromString( GUICtrlRead($sInput[3]) ) / $cpi / 60
          EndIf
        Case $sInput[2]
             $gSens    =      _GetNumberFromString( GUICtrlRead($sInput[2]) ) / $cpi * 25.4
             $idMsg[0] = -1
        Case $sInput[3]
             $gSens    =      _GetNumberFromString( GUICtrlRead($sInput[3]) ) / $cpi / 60
             $idMsg[0] = -1
        Case $sInput[4]
             $gSens    =  1 / _GetNumberFromString( GUICtrlRead($sInput[4]) ) / $cpi * 2.54 * 360
             $idMsg[0] = -1
        Case $sInput[5]
             $gSens    =  1 / _GetNumberFromString( GUICtrlRead($sInput[5]) ) / $cpi        * 360
             $idMsg[0] = -1
        Case $sInput[6]
          If $lock == $GUI_CHECKED Then
             Local $readonly = 1
          Else
             Local $readonly = 0
          EndIf
          For $i = 2 to 5
              GUICtrlSendMsg($sInput[$i],$EM_SETREADONLY,$readonly,0)
          Next
        Case $sInput[7]
          if $g_isCalibratingCPI then
             Local $deltaMouse = $g_mousePathBuffer
             Local $calibratedCPI = Sqrt(($deltaMouse[0]*$deltaMouse[0]) + ($deltaMouse[1]*$deltaMouse[1]))/5
             GUICtrlSetData($sInput[7], "Calibrate Mouse CPI")
             GUICtrlSetData($sInput[9], "" )
             if $calibratedCPI>0 and MsgBox(260,"", "You moved {" & $deltaMouse[0] & ", " & $deltaMouse[1] & "} counts over 5 inches or 127 mm." & @crlf & @crlf _
                        & "This gives " & $calibratedCPI & " CPI." & @crlf & @crlf _
                        & "Confirm entry?" ) == 6 then
                $cpi=$calibratedCPI
                GUICtrlSetData($sInput[1],$cpi)
                IniWrite($gSettingIni,"Default","cpi",$cpi)
                If $lock == $GUI_UNCHECKED Then
                   $idMsg[0] = -1
                Else
                   $gSens    =      _GetNumberFromString( GUICtrlRead($sInput[3]) ) / $cpi / 60
                EndIf
             else
                ; restore cpi
             endif
          else 
             GUICtrlSetData($sInput[7], "Move 5 inches..." )
             $g_mousePathBuffer[0] = 0
             $g_mousePathBuffer[1] = 0
          endif
          $g_isCalibratingCPI = not $g_isCalibratingCPI          
      EndSwitch
      If $idMsg[0] == -1 Then
            GUICtrlSetData($sInput[0],String(    $gSens          ))
         If $lock == $GUI_CHECKED Then
            GUICtrlSetData($sInput[1],String(_GetNumberFromString(GUICtrlRead($sInput[3]))/$gSens/60))
         Else
            GUICtrlSetData($sInput[2],String(    $gSens*$cpi/25.4))
            GUICtrlSetData($sInput[3],String(    $gSens*$cpi*60  ))
            GUICtrlSetData($sInput[4],String(360/$gSens/$cpi*2.54))
            GUICtrlSetData($sInput[5],String(360/$gSens/$cpi     ))
         EndIf
         For $i = 0 to 5
            _GUICtrlEdit_SetSel($sInput[$i], 0, 0 )
         Next
      EndIf
      if $g_isCalibratingCPI then
         Local $labeldelta = $g_mousePathBuffer
         Local $labelCPI = round(Sqrt(($labeldelta[0]*$labeldelta[0]) + ($labeldelta[1]*$labeldelta[1]))/5)
         if _GetNumberFromString(GUICtrlRead($sInput[9]))<>$labelCPI then
             GUICtrlSetData($sInput[9], $labelCPI )
         endif
      endif
    Return $idGUICalc
  EndIf
EndFunc

Func YawPresetHandler($lastYawPresets, $sYawPresets, $sYaw, $sSens)
     Local  $Preset = GUICtrlRead($sYawPresets)
    _GUICtrlComboBox_DeleteString($sYawPresets,0)                    ; indiscriminately set first entry to measure any game
    _GUICtrlComboBox_InsertString($sYawPresets,"Measure any game",0) ; on any preset event so list is always the same and
    _GUICtrlComboBox_SetEditText( $sYawPresets,$Preset)              ; only set to swap first if you select measure or swap
     KeybindSetter("disable","measure")                              ; indiscriminately disable measure binds till measure
     Switch $Preset
       Case "Custom"
            GUICtrlSetData($sYaw, String($gSens))
       Case "Quake/Source"
            GUICtrlSetData($sYaw, String($yawQuake))
       Case "Overwatch"
            GUICtrlSetData($sYaw, String($yawOverwatch))
       Case "Rainbow6/Reflex"
            GUICtrlSetData($sYaw, String($yawReflex))
       Case "Diabotical"
            GUICtrlSetData($sYaw, String($yawDiabotical))
       Case "Measure any game","< Swap yaw & sens >"
            KeybindSetter("enable","measure")
           _GUICtrlComboBox_DeleteString($sYawPresets,0)                       ; always set first entry to swap when
           _GUICtrlComboBox_InsertString($sYawPresets,"< Swap yaw & sens >",0) ; measure or swap is selected
           _GUICtrlComboBox_SetEditText( $sYawPresets,"Measure any game")      ; set input box to Measure regardless
            If  $Preset == "< Swap yaw & sens >" Then
                $gPartition = UpdatePartition($gPartition,$gSens,$gBounds,$gDelay)
                GUICtrlSetData($sYaw,String(GuiCtrlRead($sSens)))              ; set yaw to sens if swap is selected
            Else                                                               ; ElseIf $Preset is Measure any game
                GUICtrlSetData($sYaw,1)                                        ; set yaw to 1 on measure mode select
                ClearBounds()                                                  ; as well as clearing bounds
                MakeMeasurementStatsWindow()
            EndIf
            Return "Advanced Info"
       Case "< Save current yaw >"
           _GUICtrlComboBox_SetEditText($sYawPresets,InputBox("Set name"," ","Yaw: "&String(GUICtrlRead($sYaw)),"",-1,1))
            If  GUICtrlRead($sYawPresets) Then                                         ; if user input name is valid
                IniWrite($gYawListIni,GUICtrlRead($sYawPresets),"yaw"   ,      GUICtrlRead($sYaw)        )
               If ($gBounds[0]<=$gSens) AND ($gBounds[1]>=$gSens) Then  ; write uncertainty and report info if valid bounds
                IniWrite($gYawListIni,GUICtrlRead($sYawPresets),"uncrty","+/-"&BoundUncertainty($gSens,$gBounds,"%")&"%")
                IniWrite($gReportFile,GUICtrlRead($sYawPresets),"uncrty","+/-"&BoundUncertainty($gSens,$gBounds,"%")&"%")
                IniWrite($gReportFile,GUICtrlRead($sYawPresets),"yaw"   ,      GUICtrlRead($sYaw)        )
                IniWrite($gReportFile,GUICtrlRead($sYawPresets),"sens"  ,      GUICtrlRead($sSens)       )
               EndIf
                $lastYawPresets = GUICtrlRead($sYawPresets)                            ; update preset memory
               _GUICtrlComboBox_ResetContent( $sYawPresets)                            ; clear yaw list to rebuild from ini
                GUICtrlSetData(               $sYawPresets, LoadYawList($gYawListIni)) ; reinitialization
               _GUICtrlComboBox_SelectString( $sYawPresets, "/ "&$lastYawPresets )     ; select the new preset
            Else                                                                       ; if user input name is void
               If $lastYawPresets == "Measure any game" Then                           ; if pre-cancel preset is measure
                KeybindSetter("enable","measure")                                      ; re-enable measure binds
               _GUICtrlComboBox_DeleteString( $sYawPresets, 0 )                        ; delete first item and
               _GUICtrlComboBox_InsertString( $sYawPresets, "< Swap yaw & sens >", 0 ) ; set to swap
               EndIf
               _GUICtrlComboBox_SetEditText(  $sYawPresets, $lastYawPresets )          ; restore box to last selected
               Return "Advanced Info"                                                  ; restore button label
            EndIf
       Case Else
            GUICtrlSetData($sYaw,String(IniRead($gYawListIni,StringTrimLeft(GUICtrlRead($sYawPresets),2),"yaw",GuiCtrlRead($sYaw))))
     EndSwitch
     DestroyMeasurementStatsWindow()
     Return "Instructions"
EndFunc
