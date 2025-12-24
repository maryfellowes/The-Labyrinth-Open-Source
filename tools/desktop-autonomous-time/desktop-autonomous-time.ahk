; Autonomous Time Trigger v5 (FINAL)
; This script sends the autonomous time trigger phrase to Claude Desktop
; 
; Usage: Double-click to run, or set up in Task Scheduler
; Requirements: Claude Desktop must be running

#Requires AutoHotkey v2.0

; Give a moment for the script to initialize
Sleep(1000)

; Find and activate Claude Desktop window
if WinExist("Claude")
{
    WinActivate("Claude")
    WinWaitActive("Claude", , 3)
    Sleep(500)
    
    ; Get window dimensions
    WinGetPos(&X, &Y, &Width, &Height, "Claude")
    
    ; Click near the bottom center where the input box should be
    ClickX := Width // 2
    ClickY := Height - 100
    
    Click(ClickX, ClickY)
    Sleep(300)
    
    ; The message to send
    message := "Autonomous time. Use your tools, follow your curiosity, make something if you want. I'm here but not watching. The time is yours."
    
    ; Put it on the clipboard
    A_Clipboard := message
    Sleep(300)
    
    ; Paste
    SendInput("^v")
    Sleep(500)
    
    ; Hit Enter to send
    SendInput("{Enter}")
}
else
{
    MsgBox("Claude Desktop window not found! Make sure it's running.")
}
