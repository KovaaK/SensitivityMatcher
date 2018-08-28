#NoTrayIcon
#include <Misc.au3>
#include <GUIConstantsEx.au3>
#include <EditConstants.au3>
#include <GUIComboBox.au3>
#include <GuiEdit.au3>
#include <StaticConstants.au3>
#include <GUIToolTip.au3>

Global Const $gPi               = 3.1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679821480865132823066470938446095505822317253594081284811174502841027019385211055596446229489549303819644288109756659334461284756482337867831652712019091456485669234603486104543266482133936072602491412737245870066063155881748815209209628292540917153643678925903600113305305488204665213841469519415116
Global Const $yawQuake          = 0.022
Global Const $yawOverwatch      = 0.0066
Global Const $yawReflex         = 0.018/$gPi
Global Const $yawMeasureDeg     = 1
Global Const $yawMeasureMrad    = 0.180/$gPi
Global Const $defaultTurnPeriod = 1000
Global Const $gYawListIni = "CustomYawList.ini"
Global Const $gKeybindIni = "CustomKeybind.ini"

Global $idGUI ; , $idGUICalc
Global $gValid     =  1
Global $gMode      = -1
Global $gSens      =  1.0
Global $gPartition =  127
Global $gDelay     =  10
Global $gCycle     =  20
Global $gResidual  =  0.0
Global $gBounds[2] = [0,0]

If _Singleton("Sensitivity Matcher", 1) == 0 Then
    MsgBox(0, "Warning", "An instance of Sensitivity Matcher is already running.")
    Exit
EndIf

Opt("GUICloseOnESC" , 0)
HotKeySet( IniRead($gKeybindIni, "Hotkeys", "TurnOnce", "!{[}") , "SingleCycle")
HotKeySet( IniRead($gKeybindIni, "Hotkeys", "TurnALot", "!{]}") , "AutoCycle"  )
HotKeySet( IniRead($gKeybindIni, "Hotkeys", "StopTurn", "!{\}") , "Halt"       )
MakeGUI()



Func MakeGUI()
   $idGUI = GUICreate("Sensitivity Matcher", 295, 235)   

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
                        GUICtrlSetData(     $sYawPresets, "Measure any game|" & _
                                                              "Quake/Source|" & _
                                                                 "Overwatch|" & _
                                                           "Rainbow6/Reflex|" & _
                                                   LoadYawList($gYawListIni)  & _
                                                      "< Save current yaw >|"   _
                                                           ,  "Quake/Source"  )
   Local $sSens       = GUICtrlCreateInput( "1"            ,   5,  30,  80, 20)
   Local $sYaw        = GUICtrlCreateInput( "0.022"        , 100,  30,  95, 20)
   Local $sIncr       = GUICtrlCreateInput( "0.022"        , 210,  30,  80, 20)  ; hardcoded to initialize to product of above two
                        GUICtrlSendMsg(     $sIncr  , $EM_SETREADONLY,   1,  0)
   Local $sCounts     = GUICtrlCreateInput(  360/0.022     , 100, 100,  95, 20)  ; once again, hardcoding initialization
                        GUICtrlSendMsg(     $sCounts, $EM_SETREADONLY,   1,  0)
   Local $sPartition  = GUICtrlCreateInput( "959"          , 100, 125,  95, 20)
   Local $sTickRate   = GUICtrlCreateInput( "60"           , 100, 150,  95, 20)
   Local $sCycle      = GUICtrlCreateInput( "20"           , 100, 175,  95, 20)

   Local $idHelp      = GUICtrlCreateButton("Info"            , 100, 205,  95, 25)
   Local $idCalc      = GUICtrlCreateButton("Calculate..."    , 195, 205,  95, 25)


   Local $hToolTip    =_GUIToolTip_Create(0)                                     ; default tooltip
                                                                                 ; Set the tooltip to last 30 seconds.
                       _GUIToolTip_SetDelayTime($hToolTip, $TTDT_AUTOPOP, 30000) ; if I set this to 60 seconds, it seems to go back to 5.
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

   ; Initialize Global Variables to UI Inputs. Once initialized, they are individually self-updating within the main loop
   $gResidual  = 0.0
   $gMode      = 1
   $gSens      = _GetNumberFromString(GuiCtrlRead($sSens)) * _GetNumberFromString(GuiCtrlRead($sYaw))
   $gPartition = _GetNumberFromString(GuiCtrlRead($sPartition))
   $gDelay     =  Ceiling(  1000/_GetNumberFromString( GuiCtrlRead($sTickRate) )  )
   $gCycle     = _GetNumberFromString(GuiCtrlRead($sCycle))



   Local $idMsg, $lBoundedError
   Local $lPartition     = $gPartition
   Local $lastgSens      = $gSens
   Local $lastYawPresets = GUICtrlRead($sYawPresets)

   GUISetState(@SW_SHOW)
   While 1                                  ; Loop until the user exits.
      $idMsg = GUIGetMsg()

      If $gSens == $lastgSens Then
      Else
         $gResidual = 0
         $lastgSens = $gSens
         GUICtrlSetData(     $sCounts, String( 360/$gSens ) )
        _GUICtrlEdit_SetSel( $sCounts, 0, 0 )
         GUICtrlSetData(     $sIncr  , String(     $gSens ) )
        _GUICtrlEdit_SetSel( $sIncr  , 0, 0 )
         GUICtrlSetData(     $sSens  , String(     $gSens / _GetNumberFromString( GuiCtrlRead($sYaw) ) ) )
        _GUICtrlEdit_SetSel( $sSens  , 0, 0 )
         $lBoundedError = 1
         If $gBounds[1] Then ; no need to check min<max because hotkey already checks and clear contradictions
            $lBoundedError = ( $gBounds[1] - $gBounds[0] ) / $gBounds[1]
         EndIf
            $gPartition = NormalizedPartition( $defaultTurnPeriod * $lBoundedError )
         If $gPartition > $lPartition Then
            $gPartition = $lPartition
         EndIf
      EndIf

      Select
         Case $idMsg == $GUI_EVENT_CLOSE
            Exit

         Case $idMsg == $sSens
            $gResidual = 0
            $gSens     = _GetNumberFromString( GuiCtrlRead($sSens) ) * _GetNumberFromString( GuiCtrlRead($sYaw) )
            $lastgSens = $gSens
            GUICtrlSetData(     $sCounts, String( 360/$gSens ) )
           _GUICtrlEdit_SetSel( $sCounts, 0, 0 )
            GUICtrlSetData(     $sIncr  , String(     $gSens ) )
           _GUICtrlEdit_SetSel( $sIncr  , 0, 0 )

         Case $idMsg == $sYaw
            $gResidual = 0
            GUICtrlSetData(     $sSens  , String( $gSens / _GetNumberFromString( GuiCtrlRead($sYaw) ) ) )
           _GUICtrlEdit_SetSel( $sSens  , 0, 0 )
           _GUICtrlEdit_SetSel( $sYaw   , 0, 0 )

            If      GUICtrlRead($sYawPresets) == "Measure any game"               Then
            ElseIf _GetNumberFromString(GuiCtrlRead($sYaw)) == $yawQuake          Then
                   _GUICtrlComboBox_SelectString($sYawPresets, "Quake/Source")
            ElseIf _GetNumberFromString(GuiCtrlRead($sYaw)) == $yawOverwatch      Then
                   _GUICtrlComboBox_SelectString($sYawPresets, "Overwatch")
            ElseIf _GetNumberFromString(GuiCtrlRead($sYaw)) == $yawReflex         Then
                   _GUICtrlComboBox_SelectString($sYawPresets, "Rainbow6/Reflex")
            Else
                   _GUICtrlComboBox_SetEditText($sYawPresets, "Custom")
            EndIf
            $lastYawPresets = GUICtrlRead($sYawPresets)
            
         Case $idMsg == $sYawPresets
            $gResidual  = 0
            $gPartition = $lPartition
            EnableMeasureHotkeys(0)
            If     GUICtrlRead($sYawPresets) == "Custom"               Then
	    ElseIf GUICtrlRead($sYawPresets) == "Quake/Source"         Then
                   GUICtrlSetData($sYaw, String($yawQuake))
            ElseIf GUICtrlRead($sYawPresets) == "Overwatch"            Then
                   GUICtrlSetData($sYaw, String($yawOverwatch))
            ElseIf GUICtrlRead($sYawPresets) == "Rainbow6/Reflex"      Then
                   GUICtrlSetData($sYaw, String($yawReflex))
            ElseIf GUICtrlRead($sYawPresets) == "Measure any game"     Then
                   GUICtrlSetData($sYaw, String($yawMeasureDeg))
                   ClearBounds()
                   EnableMeasureHotkeys(1)
            ElseIf GUICtrlRead($sYawPresets) == "< Save current yaw >" Then
                  _GUICtrlComboBox_SetEditText($sYawPresets, InputBox( "Set name", " " , "Yaw: "&String(GUICtrlRead($sYaw)) , "" , -1 , 1 ) )
                   If GUICtrlRead($sYawPresets) Then
                      If IniRead( $gYawListIni, GUICtrlRead($sYawPresets), "yaw", 0 ) == 0 Then
                         _GUICtrlComboBox_DeleteString(     $sYawPresets , UBound(IniReadSectionNames($gYawListIni))+3 )
                         _GUICtrlComboBox_AddString(        $sYawPresets , "/ " & GUICtrlRead($sYawPresets)            )
                         _GUICtrlComboBox_AddString(        $sYawPresets , "< Save current yaw >"                      )
                      EndIf
                         IniWrite($gYawListIni, GUICtrlRead($sYawPresets), "yaw", GUICtrlRead($sYaw) )
                         _GUICtrlComboBox_SelectString(     $sYawPresets , "/ " & GUICtrlRead($sYawPresets)            )
                   Else
                         _GUICtrlComboBox_SetEditText(      $sYawPresets , $lastYawPresets                             )
                      If $lastYawPresets == "Measure any game" Then
                          EnableMeasureHotkeys(1)
                      EndIf
                   EndIf
            Else
                   GUICtrlSetData( $sYaw, String( IniRead($gYawListIni,StringTrimLeft(GUICtrlRead($sYawPresets),2),"yaw",GuiCtrlRead($sYaw)) ) )
            EndIf

            GUICtrlSetData(     $sSens  , String( $gSens / _GetNumberFromString( GuiCtrlRead($sYaw) ) ) )
           _GUICtrlEdit_SetSel( $sSens  , 0, 0 )
           _GUICtrlEdit_SetSel( $sYaw   , 0, 0 )
            $lastYawPresets = GUICtrlRead($sYawPresets)

         Case $idMsg == $sPartition
            $gResidual  = 0
            $gPartition = _GetNumberFromString( GuiCtrlRead($sPartition) )
            $lPartition = $gPartition

         Case $idMsg == $sTickRate
            $gResidual  = 0
            $gDelay     = Ceiling( 1000 / _GetNumberFromString( GuiCtrlRead($sTickRate) ) )

         Case $idMsg == $sCycle
            $gResidual  = 0
            $gCycle     = _GetNumberFromString( GuiCtrlRead($sCycle)     )

         Case $idMsg == $idCalc
            HandyCalculator()

         Case $idMsg == $idHelp
            If InputsValid($sSens, $sPartition, $sYaw, $sTickRate, $sCycle) Then
               $time = round($gCycle*$gDelay*(int(360/$gSens/$gPartition)+1)/1000)
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
                                 & "The estimate will converge to your exact sensitivity as you nudge "   _
                                 & "measurement bounds with hotkeys. You can then use the measured "      _
                                 & "sensitivity and match your new game to it."                   & @crlf _
                                                                                                  & @crlf _
                                 & "------------------------------------------------------------" & @crlf _
                                 & "Additional Info:"                                             & @crlf _
                                 & "------------------------------------------------------------" & @crlf _
                                 & "Interval: " & $gDelay & " ms (round up to nearest milisecond)"& @crlf _
                                 & "Estimated Completion Time for " & $gCycle                             _
                                 & " cycles: " & $time & " sec"                                   & @crlf _
                                                                                                  & @crlf _
                                 & "Current Residual Angle: " & $gResidual & "°"                  & @crlf _
                                 & "Current Lower Bound: " & $gBounds[0] & "°"                    & @crlf _
                                 & "Current Increment: "   & $gSens      & "°"                    & @crlf _
                                 & "Current Upper Bound: " & $gBounds[1] & "°"                    & @crlf _
                                                                                                  & @crlf _
                                 & "NOTE: "                                                               _
                                 & "under/overshoot drifts might take multiple cycles before it becomes " _
                                 & "observable. Slight shifts that snaps back periodically are simply "   _
                                 & "visual artifacts of residual angles that cancels itself out over "    _
                                 & "many rotations. It only counts as an under/overshoot if you observe " _
                                 & "systematic drift in spite of the snapback.")
            Else
               MsgBox(0, "Error", "Inputs must be a number")
            EndIf
      EndSelect

      $gValid = InputsValid($sSens, $sPartition, $sYaw, $sTickRate, $sCycle)

      If $gMode == -1 Then
         $gMode = 1
      EndIf

   WEnd
EndFunc

Func HandyCalculator()
   Local $cpi = InputBox( "Enter Mouse CPI", " " , "800" , "" , -1 , 1 )
   Local $mpi = Round(              $cpi * $gSens * 60       )
   Local $dgm = Round(              $cpi * $gSens / 25.4 , 3 )
   Local $cmR = Round( 180 / $gPi / $cpi / $gSens * 2.54 , 1 )
   Local $inR = Round( 180 / $gPi / $cpi / $gSens        , 1 )
   Local $cmC = Round(       360  / $cpi / $gSens * 2.54 , 1 )
   Local $inC = Round(       360  / $cpi / $gSens        , 1 )
   If $cpi Then
      MsgBox(0, "Physical Sensitivity", "Virtual Unit: " & $gSens & "°"    & @crlf & _
                                        "Physical Unit: " & $cpi & " CPI"  & @crlf & _
                                        "----------------------------"     & @crlf & _
                                                                             @crlf & _
                                        "Circumference"                    & @crlf & _
                                        " = " & $cmC & " cm/rev"           & @crlf & _
                                        " = " & $inC & " in/rev"           & @crlf & _
                                                                             @crlf & _
                                        "Curvature"                        & @crlf & _
                                        " = " & $dgm & " deg/mm"           & @crlf & _
                                        " = " & $mpi & " MPI")
   EndIf
EndFunc

Func TestMouse($cycle)
   If $gMode > 0 Then           ; three states of $gMode: -1, 0, 1. A 0 means in-progress and exits the command without doing anything.
      $gMode = 0                ; -1 means manual override and is checked for before performing every operation, 1 means all is good to go.

      $partition  = $gPartition ; how many movements to perform in a single go.  Don't let this exceed half of your resolution.
      $delay      = $gDelay     ; delay in milliseconds between movements.  Making this lower than frametime causes dropped inputs for non-rawinput games.
      $turn       = 0.0
      $totalcount = 1

      While $cycle > 0
         $cycle = $cycle - 1

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
      EndIf
   EndIf
EndFunc

Func Halt()
   If $gMode > -1 Then
      $gMode = -1
      $gResidual = 0
   EndIf
EndFunc

Func SingleCycle()
   if $gValid Then
	  TestMouse(1)
   Else
	  MsgBox(0, "Error", "Inputs must be a number")
   EndIf
EndFunc

Func AutoCycle()
   if $gValid Then
	  TestMouse($gCycle)
   Else
	  MsgBox(0, "Error", "Inputs must be a number")
   EndIf
EndFunc

Func DecreasePolygon()
      $gResidual  = 0
      $gBounds[0] = $gSens
   if $gBounds[1] < $gBounds[0] then
      $gBounds[1] = 0
      $gSens      = $gBounds[0] * 2
   else
      $gSens      =($gBounds[0] + $gBounds[1]) / 2
   endif
EndFunc

Func IncreasePolygon()
      $gResidual  = 0
      $gBounds[1] = $gSens
   if $gBounds[1] < $gBounds[0] then
      $gBounds[0] = 0
      $gSens      = $gBounds[1] / 2
   else
      $gSens      =($gBounds[0] + $gBounds[1]) / 2
   endif
   if $gSens == 0 then
      $gSens =  $gBounds[1]
      if $gSens == 0 then
         $gSens =  0.022
      endif
   endif
EndFunc

Func ClearBounds()
   $gResidual  = 0
   $gBounds[0] = 0
   $gBounds[1] = 0
   $gPartition = NormalizedPartition($defaultTurnPeriod)
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

Func InputsValid($sSens, $sPartition, $sYaw, $sTickRate, $sCycle)
   return _StringIsNumber(GuiCtrlRead($sSens)) AND _StringIsNumber(GuiCtrlRead($sPartition)) AND _StringIsNumber(GuiCtrlRead($sYaw)) AND _StringIsNumber(GuiCtrlRead($sTickrate)) AND _StringIsNumber(GuiCtrlRead($sCycle))
EndFunc

Func LoadYawList($sFilePath)
    Local $aYawList = IniReadSectionNames($sFilePath)
    Local $sYawList = ""
    For $i = 1 to UBound($aYawList)-1
          $sYawList = $sYawList & "/ " & $aYawList[$i] & "|"
    Next
   Return $sYawList
EndFunc

Func EnableMeasureHotkeys($bind)
    If $bind Then
       HotKeySet( IniRead($gKeybindIni, "Hotkeys", "LessTurn", "!{-}"), "DecreasePolygon")
       HotKeySet( IniRead($gKeybindIni, "Hotkeys", "MoreTurn", "!{=}"), "IncreasePolygon")
       HotKeySet( IniRead($gKeybindIni, "Hotkeys", "ClearMem", "!{0}"), "ClearBounds"    )
    Else
       HotKeySet( IniRead($gKeybindIni, "Hotkeys", "LessTurn", "!{-}") )
       HotKeySet( IniRead($gKeybindIni, "Hotkeys", "MoreTurn", "!{=}") )
       HotKeySet( IniRead($gKeybindIni, "Hotkeys", "ClearMem", "!{0}") )
    EndIf
EndFunc

Func _MouseMovePlus($X = "", $Y = "")
        Local $MOUSEEVENTF_MOVE = 0x1
    DllCall("user32.dll", "none", "mouse_event", _
            "long",  $MOUSEEVENTF_MOVE, _
            "long",  $X, _
            "long",  $Y, _
            "long",  0, _
        "long",  0)
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
