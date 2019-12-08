If _Singleton("Sensitivity Matcher", 1) == 0 Then
    WinActivate("Sensitivity Matcher")
    Exit
Else
    Opt("GUICloseOnESC",0)
EndIf

#NoTrayIcon
#include <Date.au3>
#include <Misc.au3>
#include <Math.au3>
#include <GuiEdit.au3>
#include <GUIToolTip.au3>
#include <GUIComboBox.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <StringConstants.au3>
#include <WindowsConstants.au3>
#include "HotkeyFunctions.au3"
#include "MiscFunctions.au3"
#include "HelpMessages.au3"
#include "MeasureGUI.au3"
#include "RawInput.au3"
