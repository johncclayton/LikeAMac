; only in explorer please...
#IfWinActive ahk_class CabinetWClass 

; Go to Home Folder (Alt-Shift-H)
!+h::
GotoExplorerHomeFolder()
return

; Go up a Folder (Alt-Shift-Up Arrow)
; https://www.autohotkey.com/board/topic/33882-unanswered-getting-parent-directory-of-a-file-or-dir/

!+Up::
Originalpath := GetActiveExplorerPath()

StringLen,length, Originalpath  ;get length of original path
StringGetPos, pos, Originalpath, \, r  ;find position of \ starting at the right
EnvSub, length, %pos%  ;subtract pos from the length
StringTrimRight,NewPath,Originalpath,%length%  ;starting on the right trim the original path going left the length of the last folder in the path. This includes the backslash.
Explorer_Navigate(NewPath)
return

; Go to 'everything' folder - based on an environment/machine specific path
!+e::
destination := "E:\"
Explorer_Navigate(destination)
return

; Go to 'external' folder - based on an environment/machine specific path
!+x::
destination := "X:\"
Explorer_Navigate(destination)
return

; Go to the users Downloads folder (Alt-Shift-D)
; https://www.autohotkey.com/boards/viewtopic.php?t=66133
!+d::
FOLDERID_Downloads := "{374DE290-123F-4565-9164-39C4925E467B}"
RegRead, v, HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders, % FOLDERID_Downloads
VarSetCapacity(downloads, (261 + !A_IsUnicode) << !!A_IsUnicode)
DllCall("ExpandEnvironmentStrings", Str, v, Str, downloads, UInt, 260)
Explorer_Navigate(downloads)
return

; From the desktop - Go to Explorer (Alt-Up)
#ifWinActive ahk_class Progman
!Up::
Run, "explorer"
WinWait, ahk_class CabinetWClass ahk_exe explorer.exe
explorerWindow := WinActivate, ahk_class CabinetWClass ahk_exe explorer.exe
ControlFocus explorerWindow
return

; some kind of dialog with a search bar, that I can influence. 


; turning off context sensitivity
#IfWinActive
return

;=== Functions ===

GotoExplorerHomeFolder()
{
    ControlGetFocus, activeWindow 
    EnvGet, vUserProfile, USERPROFILE
    Explorer_Navigate(vUserProfile)
    if (activeWindow)
    {
        ControlFocus activeWindow
    }
}

; https://www.autohotkey.com/boards/viewtopic.php?t=69925

GetActiveExplorerPath()
{
	explorerHwnd := WinActive("ahk_class CabinetWClass")
	if (explorerHwnd)
	{
		for window in ComObjCreate("Shell.Application").Windows
		{
			if (window.hwnd==explorerHwnd)
			{
				return window.Document.Folder.Self.Path
			}
		}
	}
}

; https://www.autohotkey.com/boards/viewtopic.php?t=526

Explorer_Navigate(FullPath, hwnd="") {	; by Learning one
	hwnd := (hwnd="") ? WinExist("A") : hwnd ; if omitted, use active window
	WinGet, ProcessName, ProcessName, % "ahk_id " hwnd
	if (ProcessName != "explorer.exe")	; not Windows explorer
		return
	For pExp in ComObjCreate("Shell.Application").Windows
	{
		if (pExp.hwnd = hwnd) {	; matching window found
			pExp.Navigate("file:///" FullPath)
			return
		}
	}
}