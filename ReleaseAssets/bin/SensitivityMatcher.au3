#NoTrayIcon
#include <Date.au3>
#include <Misc.au3>
#include <GuiEdit.au3>
#include <GUIToolTip.au3>
#include <GUIComboBox.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <StringConstants.au3>

If _Singleton("Sensitivity Matcher", 1) == 0 Then
    MsgBox(0, "Warning", "An instance of Sensitivity Matcher is already running.")
    Exit
EndIf

Global Const $gPi               = 3.1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679821480865132823066470938446095505822317253594081284811174502841027019385211055596446229489549303819644288109756659334461284756482337867831652712019091456485669234603486104543266482133936072602491412737245870066063155881748815209209628292540917153643678925903600113305305488204665213841469519415116
Global Const $yawQuake          = 0.022
Global Const $yawOverwatch      = 0.0066
Global Const $yawReflex         = 0.018/$gPi
Global Const $defaultTurnPeriod = 1000
Global Const $gSettingIni = "UserSettings.Ini"
Global Const $gYawListIni = "CustomYawList.ini"
Global       $gReportFile = "MeasureReport.csv"
Global       $gHotkey[8]  =  KeybindSetter("initialize")

Global       $gValid     =  1    ; Keeps track of whether all user inputs are valid numbers or not
Global       $gMode      = -1    ; Three states of $gMode: -1, 0, and 1, for halt override, in-progress, and ready.
Global       $gSens      =  1.0
Global       $gPartition =  127
Global       $gDelay     =  10
Global       $gCycle     =  20
Global       $gResidual  =  0.0  ; Residual accumulator
Global       $gBounds[2] = [0,0] ; Upper/lower bounds of increment

    Opt("GUICloseOnESC",0)
     MakeGUI()

Func MakeGUI()
   Local $idGUI = GUICreate("Sensitivity Matcher", 295, 235)

   GUICtrlCreateLabel( "Select preset yaw:"                ,   0,   7,  95, 15, $SS_RIGHT )
   GUICtrlCreateLabel( "Sens"                              ,   5,  50,  80, 15, $SS_CENTER)
   GUICtrlCreateLabel( "×"                                 ,  85,  33,  15, 15, $SS_CENTER)
   GUICtrlCreateLabel( "Yaw (deg)"                         , 100,  50,  95, 15, $SS_CENTER)
   GUICtrlCreateLabel( "="                                 , 195,  33,  15, 15, $SS_CENTER)
   GUICtrlCreateLabel( "Increment"                         , 210,  50,  80, 15, $SS_CENTER)
   GUICtrlCreateGraphic(                                       5,  70, 285,  2, $SS_SUNKEN) ; horizontal line
   GUICtrlCreateLabel( "Optional Testing Parameters"       ,   5,  80, 285, 15, $SS_CENTER)
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
   Local $sYaw        = GUICtrlCreateInput( "0.022"        , 100,  30,  95, 20)
   Local $sIncr       = GUICtrlCreateInput( "0.022"        , 210,  30,  80, 20)
                        GUICtrlSendMsg(     $sIncr  , $EM_SETREADONLY,   1,  0)
   Local $sCounts     = GUICtrlCreateInput(  360/0.022     , 100, 100,  95, 20)
                        GUICtrlSendMsg(     $sCounts, $EM_SETREADONLY,   1,  0)
   Local $sPartition  = GUICtrlCreateInput( "511"          , 100, 125,  95, 20)
   Local $sTickRate   = GUICtrlCreateInput( "100"          , 100, 150,  95, 20)
   Local $sCycle      = GUICtrlCreateInput( "20"           , 100, 175,  95, 20)
   Local $idSave      = GUICtrlCreateButton("Save to Default", 5, 205,  95, 25)
   Local $idHelp      = GUICtrlCreateButton("Info"         , 100, 205,  95, 25)
   Local $idCalc      = GUICtrlCreateButton("Physical Stats...",195,205,95, 25)


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
                       _GUIToolTip_AddTool($hToolTip, 0, "How many full revolutions to perform when pressing Alt+].", $hCycle)


   ; Initialize all inputs to ini or hardcoded defaults
   GUICtrlSetData($sYawPresets, LoadYawList($gYawListIni) )
   GUICtrlSetdata($sPartition , IniRead($gSettingIni,"Default","part","959"  ))
   GUICtrlSetdata($sTickRate  , IniRead($gSettingIni,"Default","freq","60"   ))
   GUICtrlSetdata($sCycle     , IniRead($gSettingIni,"Default","cycl","20"   ))
   GUICtrlSetData($sYaw       , IniRead($gSettingIni,"Default","yaw" ,"0.022"))
   GUICtrlSetData($sSens      , IniRead($gSettingIni,"Default","sens","1"    ))
   GUICtrlSetData($sIncr      ,     _GetNumberFromString(GUICtrlRead($sSens))*_GetNumberFromstring(GUICtrlread($sYaw)))
   GUICtrlSetData($sCounts    , 360/_GetNumberFromString(GUICtrlRead($sSens))/_GetNumberFromstring(GUICtrlread($sYaw)))
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
   Local $lCalculator[7]                             ; ByRef handles for HandyCalc. Never addressed directly in loop.
   
   
   GUISetState(@SW_SHOW)
   KeybindSetter("enable","turn")
   While 1
      Switch $idMsg[0]
        Case $GUI_EVENT_CLOSE
             Switch $idMsg[1]
               Case $idGUI
                    Exit
               Case $idGUICalc
                    GUIDelete($idGUICalc)
                    $idGUICalc="INACTIVE"
             EndSwitch
             
        Case $sCycle
             $gResidual  = 0
             $gCycle     = _GetNumberFromString(GuiCtrlRead($sCycle))

        Case $sTickRate
             $gResidual  = 0
             $gDelay     = 10*Ceiling(100/_GetNumberFromString(GuiCtrlRead($sTickRate)))

        Case $sPartition
             $gResidual  = 0
             $lPartition = _GetNumberFromString(GuiCtrlRead($sPartition))
             $gPartition = $lPartition
          If $lastYawPresets == "Measure any game" Then
             $gPartition = UpdatePartition($gPartition,$gBounds)
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
          ElseIf  $lastYawPresets == "Measure any game"                    Then
                 ; Do nothing if yaw changed during measurement mode
          ElseIf _GetNumberFromString(GuiCtrlRead($sYaw)) == $yawQuake     Then
                 _GUICtrlComboBox_SelectString($sYawPresets, "Quake/Source")
          ElseIf _GetNumberFromString(GuiCtrlRead($sYaw)) == $yawOverwatch Then
                 _GUICtrlComboBox_SelectString($sYawPresets, "Overwatch")
          ElseIf _GetNumberFromString(GuiCtrlRead($sYaw)) == $yawReflex    Then
                 _GUICtrlComboBox_SelectString($sYawPresets, "Rainbow6/Reflex")
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
          EndIf

        Case $idHelp
          If $lastYawPresets == "Measure any game" Then
             HelpMessage("measure")
          Else
             HelpMessage()
          EndIf

      EndSwitch

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
             $gPartition = UpdatePartition( $lPartition , $gBounds )
          If $gCycle < GlobalUncertainty("rev") Then
             $gCycle = GlobalUncertainty("rev")
             GUICtrlSetData($sCycle, $gCycle)
          EndIf
         EndIf
      EndIf

      HandyCalculator($idGUICalc,$lCalculator,$idMsg)
      $gMode  = Abs($gMode)       ; if override then ready, if ready or in progress then no change.
      $gValid = InputsValid($sSens, $sPartition, $sYaw, $sTickRate, $sCycle)
      $idMsg  = GUIGetMsg(1)
   WEnd
EndFunc

Func HandyCalculator($idGUICalc, ByRef $sInput, $idMsg)
  If $idGUICalc == "INACTIVE" Then
      ; do nothing and exit the function
  Else
      If $idGUICalc == "INITIALIZE" Then
         Local $pos=WinGetPos("Sensitivity Matcher")
         $idGUICalc=GUICreate("Physical Sensitivity",200,220,$pos[0]+$pos[2],$pos[1])
         $sInput[0]=GUICtrlCreateInput(                                                  $gSens     , 85,  6, 80, 20)
                    GUICtrlSendMsg($sInput[0],$EM_SETREADONLY,1,0)
         $sInput[1]=GUICtrlCreateInput(     IniRead($gSettingIni,"Default","cpi",800)               , 85, 30, 80, 20)
         $sInput[2]=GUICtrlCreateInput(    _GetNumberFromString(GUICtrlRead($sInput[1]))*$gSens/25.4, 20, 85, 75, 20)
         $sInput[3]=GUICtrlCreateInput(    _GetNumberFromString(GUICtrlRead($sInput[1]))*$gSens*60  ,105, 85, 75, 20)
         $sInput[4]=GUICtrlCreateInput(360/_GetNumberFromString(GUICtrlRead($sInput[1]))/$gSens*2.54, 20,150, 75, 20)
         $sInput[5]=GUICtrlCreateInput(360/_GetNumberFromString(GUICtrlRead($sInput[1]))/$gSens     ,105,150, 75, 20)
         $sInput[6]=GUICtrlCreateCheckbox("Lock physical sensitivity", 35,190,130)
         GUICtrlCreateLabel("Virtual factor:",10,9,75,15,$SS_RIGHT)
         GUICtrlCreateLabel("Physical factor:",10,33,75,15,$SS_RIGHT)
         GUICtrlCreateLabel("deg",170,9,35,15,$SS_LEFT)
         GUICtrlCreateLabel("CPI",170,33,35,15,$SS_LEFT)
         GUICtrlCreateGraphic(10,55,180,2,$SS_SUNKEN)
         GUICtrlCreateLabel("Curvature",10,65,180,15,$SS_CENTER)
         GUICtrlCreateLabel("deg/mm",20,105,75,15,$SS_CENTER)
         GUICtrlCreateLabel("MPI",105,105,75,15,$SS_CENTER)
         GUICtrlCreateLabel("Circumference",10,130,180,15,$SS_CENTER)
         GUICtrlCreateLabel("cm/rev",20,170,75,15,$SS_CENTER)
         GUICtrlCreateLabel("in/rev",105,170,75,15,$SS_CENTER)
         Local $hToolTip=_GUIToolTip_Create(0)
                         _GUIToolTip_SetDelayTime($hToolTip, $TTDT_AUTOPOP, 30000)
                         _GUIToolTip_SetDelayTime($hToolTip, $TTDT_RESHOW, 500)
                         _GUIToolTip_SetMaxTipWidth($hToolTip, 500)
         Local $hInc    = GUICtrlGetHandle($sInput[0])
                         _GUIToolTip_AddTool($hToolTip, 0, "Degree Per Count", $hInc)
         Local $hCPI    = GUICtrlGetHandle($sInput[1])
                         _GUIToolTip_AddTool($hToolTip, 0, "Count Per Inch", $hCPI)
         Local $hDgm    = GUICtrlGetHandle($sInput[2])
                         _GUIToolTip_AddTool($hToolTip, 0, "Degree Per Millimeter = (incre*CPI)/25.4", $hDgm)
         Local $hMPI    = GUICtrlGetHandle($sInput[3])
                         _GUIToolTip_AddTool($hToolTip, 0, "Minute (of arc) Per Inch = (incre*CPI)*60", $hMPI)
         Local $hCcm    = GUICtrlGetHandle($sInput[4])
                         _GUIToolTip_AddTool($hToolTip, 0, "Centimeter Per Revolution = rev/(incre*CPI)*2.54", $hCcm)
         Local $hCin    = GUICtrlGetHandle($sInput[5])
                         _GUIToolTip_AddTool($hToolTip, 0, "Inch Per Revolution = rev/(incre*CPI)", $hCin)
         For $i = 0 to 5
            _GUICtrlEdit_SetSel($sInput[$i], 0, 0 )
         Next
         GUISetState(@SW_SHOW)
         GUICtrlSetState($sInput[1],$GUI_FOCUS)
      EndIf
      Local  $cpi = _GetNumberFromString( GUICtrlRead($sInput[1]) )
      Local  $lock=  GUICtrlRead($sInput[6])
      Switch $idMsg[0]
        Case $sInput[1]
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
    Return $idGUICalc
  EndIf
EndFunc

Func HelpMessage($mode="default")
     If $gValid Then
        Local $error = GlobalUncertainty()
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
                              & "Uncertainty: ±" & $error  & "° (±"&GlobalUncertainty("%")&"%)"& @crlf _
                                                                                               & @crlf _
                              & "------------------------------------------------------------" & @crlf _
                              & "Precision Measurements (Advanced):"                           & @crlf _
                              & "------------------------------------------------------------" & @crlf _
                              & "Under/overshoot drifts can take many cycles to become observable. "   _
                              & "Slight shifts up to half-increment that snaps back periodically are " _
                              & "simply visual artifacts of residual angles that cancels itself out "  _
                              & "over many rotations. To positively qualify under/overshoots, the "    _
                              & "deviations must equal or exceed single increment angles. Use the "    _
                              & "nudge hotkeys in measurement mode to move single increments to check" _
                              & " that deviation is at least one count away from origin."      & @crlf _
                                                                                               & @crlf _
                              & "Press Alt+' (quotation) to nudge one count to the right"      & @crlf _
                              & "Press Alt+; (semicolon) to nudge one count to the left"       & @crlf _
                                                                                               & @crlf _
                              & "Remember to un-nudge if you wish to continue cycling. To share your " _
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
                              & "Press Alt+[ to perform one full revolution."                  & @crlf _
                              & "Press Alt+] to perform " & $gCycle & " full revolutions."     & @crlf _
                              & "Press Alt+\ to halt and/or clear residuals (for realignment)" & @crlf _
                                                                                               & @crlf _
                              & "------------------------------------------------------------" & @crlf _
                              & "If your old game is not listed/yaw is unknown:"               & @crlf _
                              & "------------------------------------------------------------" & @crlf _
                              & "1) Select ''Measure any game'' to enable measurement."        & @crlf _
                              & "2) Perform rotations in old game to test your estimate."      & @crlf _
                              & "3) Use the following hotkeys to adjust the estimate."         & @crlf _
                                                                                               & @crlf _
                              & "Increase counts with Alt+= if it's undershooting."            & @crlf _
                              & "Decrease counts with Alt+- if it's overshooting."             & @crlf _
                              & "Clear all memory with Alt+0 if you made a wrong input."       & @crlf _
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
                              & "Uncertainty: ±" & $error  & "° (±"&GlobalUncertainty("%")&"%)")
        EndIf
     Else
        MsgBox(0, "Error", "Inputs must be positive numbers")
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
       Case "Measure any game","< Swap yaw & sens >"
            KeybindSetter("enable","measure")
           _GUICtrlComboBox_DeleteString($sYawPresets,0)                       ; always set first entry to swap when
           _GUICtrlComboBox_InsertString($sYawPresets,"< Swap yaw & sens >",0) ; measure or swap is selected
           _GUICtrlComboBox_SetEditText( $sYawPresets,"Measure any game")      ; set input box to Measure regardless
            If  $Preset == "< Swap yaw & sens >" Then
                $gPartition = UpdatePartition($gPartition,$gBounds)
                GUICtrlSetData($sYaw,String(GuiCtrlRead($sSens)))              ; set yaw to sens if swap is selected
            Else                                                               ; ElseIf $Preset is Measure any game
                GUICtrlSetData($sYaw,1)                                        ; set yaw to 1 on measure mode select
                ClearBounds()                                                  ; as well as clearing bounds
            EndIf
            Return "Advanced Info"
       Case "< Save current yaw >"
           _GUICtrlComboBox_SetEditText($sYawPresets,InputBox("Set name"," ","Yaw: "&String(GUICtrlRead($sYaw)),"",-1,1))
            If  GUICtrlRead($sYawPresets) Then                                         ; if user input name is valid
                IniWrite($gYawListIni,GUICtrlRead($sYawPresets),"yaw"   ,      GUICtrlRead($sYaw)        )
               If ($gBounds[0]<=$gSens) AND ($gBounds[1]>=$gSens) Then  ; write uncertainty and report info if valid bounds
                IniWrite($gYawListIni,GUICtrlRead($sYawPresets),"uncrty","+/-"&GlobalUncertainty("%")&"%")
                IniWrite($gReportFile,GUICtrlRead($sYawPresets),"uncrty","+/-"&GlobalUncertainty("%")&"%")
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
            EndIf
       Case Else
            GUICtrlSetData($sYaw,String(IniRead($gYawListIni,StringTrimLeft(GUICtrlRead($sYawPresets),2),"yaw",GuiCtrlRead($sYaw))))
     EndSwitch
     Return "Info"
EndFunc

Func KeybindSetter($mode,$subset="all")
     Local  $size = 8
     Local  $readval[$size]
     Local  $default[$size] = [   "!{[}"  ,  "!{]}"  ,  "!{\}"  , _
                                  "!{-}"  ,  "!{=}"  ,  "!{0}"  , _
                                  "!{'}"  ,  "!{;}"  ]
     Local  $keyname[$size] = [ "TurnOnce","TurnAlot","StopTurn", _
                                "LessTurn","MoreTurn","ClearMem", _
                                "NudgeFwd","NudgeBkd"] 
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

Func UpdatePartition($limit,$bound)
  Local $error = 1
     If $bound[1] AND ($bound[1] > $bound[0]) Then
        $error = GlobalUncertainty("%") / 100
     EndIf
  Local $parti = NormalizedPartition( $defaultTurnPeriod * $error )
     If $parti > $limit Then
        $parti = $limit
     EndIf
 Return $parti
EndFunc

Func NormalizedPartition($turntime)
     Local $incre = $gSens
     Local $total = round( 360 / $incre )
     Local $slice = ceiling( $total * $gDelay / $turntime )
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

Func GlobalUncertainty($mode=".")
     Local  $output = ($gBounds[1]-$gBounds[0])/2
     If     $mode  == "%"   Then
            $output = ($gBounds[1]-$gBounds[0])*50/$gSens
     ElseIf $mode  == "rev" Then
            $output = Ceiling($gSens*$gSens/($gBounds[1]-$gBounds[0])/360)
     EndIf
     If $output < 0 OR ($gBounds[1]==0) Then
        Return "infty"
     Else
        Return $output
     EndIf
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
