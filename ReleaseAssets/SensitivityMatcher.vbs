If FileExists("bin\AutoIt3.exe") Then
   If FileExists("bin\SensitivityMatcher.a3x") Then
      Set WshShell = WScript.CreateObject("WScript.Shell")
      WshShell.Run "bin\AutoIt3.exe bin\SensitivityMatcher.a3x"
   Else If FileExists("bin\SensitivityMatcher.au3") Then
           Set WshShell = WScript.CreateObject("WScript.Shell")
           WshShell.Run "bin\AutoIt3.exe bin\SensitivityMatcher.au3"
        End If
   End If
Else If FileExists("bin\AutoIt3_x64.exe") Then
        If FileExists("bin\SensitivityMatcher.a3x") Then
           Set WshShell = WScript.CreateObject("WScript.Shell")
           WshShell.Run "bin\AutoIt3_x64.exe bin\SensitivityMatcher.a3x"
        Else If FileExists("bin\SensitivityMatcher.au3") Then
                Set WshShell = WScript.CreateObject("WScript.Shell")
                WshShell.Run "bin\AutoIt3_x64.exe bin\SensitivityMatcher.au3"
             End If
        End If
     End If
End If

Function FileExists(FilePath)
    Set fso = CreateObject("Scripting.FileSystemObject")
    If fso.FileExists(FilePath) Then
       FileExists=CBool(1)
    Else
       FileExists=CBool(0)
    End If
End Function
