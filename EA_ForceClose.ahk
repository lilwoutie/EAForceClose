#SingleInstance Force
SendMode("Input")

; Request admin rights if not already running as admin
if (!A_IsAdmin) {
    try {
        Run('*RunAs "' . A_ScriptFullPath . '"')
    }
    ExitApp()
}

; ===== DEBUG MODE =====
DEBUG := false  ; Set to true to enable logging
; ======================

; Debug log file
LogFile := A_ScriptDir . "\ea_debug.log"

; Track EA window state
EAWindowVisible := false
EAWindowID := 0

SetTimer(MonitorEA, 300)

MonitorEA() {
    global EAWindowVisible, EAWindowID
    
    WindowID := 0
    WindowExists := false
    
    ; Check if window exists
    try {
        WindowID := WinGetID("ahk_exe EADesktop.exe")
        WindowExists := (WindowID != 0)
    } catch {
        WindowExists := false
    }
    
    if (WindowExists) {
        ; Window exists - check if visible
        IsVisible := false
        try {
            WindowState := WinGetMinMax("ahk_id " . WindowID)
            IsVisible := (WindowState != -1)
        } catch {
            IsVisible := false
        }
        
        if (IsVisible && !EAWindowVisible) {
            ; Window just became visible
            EAWindowVisible := true
            EAWindowID := WindowID
            Log("EA window visible - ID: " . WindowID)
        }
        else if (!IsVisible && EAWindowVisible) {
            ; Window was visible, now minimized (but still exists)
            Log("EA window minimized (still exists) - allowing this")
            EAWindowVisible := false
        }
    }
    else if (EAWindowVisible) {
        ; Window disappeared completely (closed with X button or game starting)
        Log("EA window closed (disappeared) - waiting to check if game is starting")
        EAWindowVisible := false
        
        ; Wait for anti-cheat to potentially start (games take a moment to launch)
        Sleep(2000)
        
        ; Check if a game is running (anti-cheat process exists)
        if (ProcessExist("EAAnticheat.GameService.exe")) {
            Log("Game is running (anti-cheat detected) - NOT killing EA")
            return
        }
        
        ; Check again if EA process still exists
        if (ProcessExist("EADesktop.exe")) {
            Log("Process still running after close and no game detected - killing it")
            ProcessClose("EADesktop.exe")
            ProcessClose("EAConnect_microsoft.exe")
            try ProcessClose("EABackgroundService.exe")
            TrayTip("EA Desktop force closed (was minimized to tray)", "EA Force Close", "Iconi Mute")
        } else {
            Log("Process already closed normally")
        }
    }
}

Log(message) {
    global LogFile, DEBUG
    if (DEBUG) {
        timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
        FileAppend(timestamp . " - " . message . "`n", LogFile)
    }
}

; Manual close (Ctrl+Alt+E)
^!e:: {
    Log("Manual close triggered")
    
    ; Check if game is running before closing
    if (ProcessExist("EAAnticheat.GameService.exe")) {
        Log("Game is running - NOT closing EA")
        TrayTip("Game is running - cannot close EA", "EA Desktop", "Icon!")
        return
    }
    
    ProcessClose("EADesktop.exe")
    ProcessClose("EAConnect_microsoft.exe")
    try ProcessClose("EABackgroundService.exe")
    TrayTip("Manually force closed EA", "EA Desktop", "Iconi Mute")
}

; Exit script (Ctrl+Alt+Q)
^!q:: {
    Log("Script exiting")
    ExitApp()
}

Log("Script started")
if (DEBUG) {
    TrayTip("EA Force Close running - DEBUG MODE ENABLED", "EA Force Close", "Iconi")
} else {
    TrayTip("EA Force Close running", "EA Force Close", "Iconi Mute")
}