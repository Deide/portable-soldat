'------------------------------------------------
' Elevate this script before invoking it.
' 25.2.2011 FNL
'------------------------------------------------
bElevate = False
if WScript.Arguments.Count > 0 Then If WScript.Arguments(WScript.Arguments.Count-1) <> "|" then bElevate = True
if bElevate Or WScript.Arguments.Count = 0 Then ElevateUAC
'------------------------------------------------

Function BrowseForFolder(sTitle)
    Dim objShell : Set objShell = CreateObject("Shell.Application")
    Dim objFolder : Set objFolder = objShell.BrowseForFolder(0, sTitle, &H200, "")
    
    If (Not objFolder Is Nothing) Then
        BrowseForFolder = objFolder.self.Path
    Else
        BrowseForFolder = ""
    End If
    
    Set objFolder = Nothing
    Set objShell = Nothing
End Function

Function FileExists(sFilePath)
    Dim objFSO : Set objFSO = CreateObject("Scripting.FileSystemObject")
    FileExists = objFSO.FileExists(sFilePath)
    Set objFSO = Nothing
End Function
 
Function QuotesWrap(sText)
    QuotesWrap = Chr(34) + sText + Chr(34)
End Function

Function IIf(bClause, sTrue, sFalse)
    If CBool(bClause) Then
        IIf = sTrue
    Else
        IIf = sFalse
    End If
End Function

Sub RegisterURI(sName, sPath, sParameters)
    Set WshShell = WScript.CreateObject("WScript.Shell")
    WshShell.RegWrite "HKCR\" + sName + "\", "URL: " + sName + " Shortcut", "REG_SZ"
    WshShell.RegWrite "HKCR\" + sName + "\URL Protocol", "", "REG_SZ"
    WshShell.RegWrite "HKCR\" + sName + "\DefaultIcon\", QuotesWrap(sPath), "REG_SZ"
    WshShell.RegWrite "HKCR\" + sName + "\shell\open\command\", QuotesWrap(sPath) + IIf(Len(sParameters), " " + sParameters, ""), "REG_SZ"
    Set WshShell = Nothing
End Sub


sPath = BrowseForFolder("Choose Soldat folder please")
If Len(sPath) Then
    If FileExists(sPath + "\soldat.exe") Then
        sPath = sPath + "\soldat.exe"
        iResult = MsgBox("Would you like to run Soldat with a modification" + vbCrLf + _
                         "('-mod <name>' parameter)?", vbYesNo Or vbQuestion, "Run with mod?")
        If iResult = vbYes Then
            sModName = InputBox("Enter mod name:")
        End If
        sParameters = IIf(Len(sModName), " -mod " + QuotesWrap(sModName), "") + " -joinurl ""%1"""

        RegisterURI "Soldat", sPath, sParameters
        
        MsgBox "Soldat URI was successfully registered!", vbInformation, "Done"
    Else
        MsgBox "There is no Soldat.exe in " + sPath, vbExclamation, "Error"
    End If
Else
    WScript.Quit
End If


'------------------------------------------------
' Run this script under elevated privileges
'------------------------------------------------
Sub ElevateUAC
    sParms = " |"
    If WScript.Arguments.Count > 0 Then
            For i = WScript.Arguments.Count-1 To 0 Step -1
            sParms = " " & WScript.Arguments(i) & sParms
        Next
    End If
    Set oShell = CreateObject("Shell.Application")
    oShell.ShellExecute "wscript.exe", WScript.ScriptFullName & sParms, , "runas", 1
    WScript.Quit
End Sub