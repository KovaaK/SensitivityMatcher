Set WshShell = WScript.CreateObject("WScript.Shell")

Dim Executable, Script, Command

Executable = false
Script = false
Command = ""

If FileExists("bin\AutoIt3.exe") Then
   Executable = true
   Command = "bin\AutoIt3.exe "
Else If FileExists("bin\AutoIt3_x64.exe") Then
        Executable = true
        Command = "bin\AutoIt3_x64.exe "
     End If
End If

If FileExists("bin\SensitivityMatcher.a3x") Then
   Script = true
   Command = Command + "bin\SensitivityMatcher.a3x"
Else If FileExists("bin\SensitivityMatcher.au3") Then
        Script = true
        Command = Command + "bin\SensitivityMatcher.au3"
     End If
End If

If Executable AND Script Then
   WshShell.Run Command
End If

Function FileExists(FilePath)
    Set fso = CreateObject("Scripting.FileSystemObject")
    If fso.FileExists(FilePath) Then
       FileExists=CBool(1)
    Else
       FileExists=CBool(0)
    End If
End Function
