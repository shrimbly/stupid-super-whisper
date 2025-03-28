#SingleInstance Force
#NoEnv
SetWorkingDir %A_ScriptDir%

; Load configuration
configFile := A_ScriptDir "\config.json"
FileRead, configContent, %configFile%
config := JSON.Parse(configContent)

; Build hotkey string
hotkey := ""
for index, modifier in config.hotkey.modifiers {
    hotkey .= modifier "+"
}
hotkey .= config.hotkey.key

; Set up the hotkey
Hotkey, %hotkey%, RecordAudio, On

; Create GUI for recording indicator
Gui, Add, Text, vStatusText w200 h30 Center, Hold %hotkey% to record
Gui, +AlwaysOnTop -Caption +ToolWindow
Gui, Color, 000000
Gui, Font, cFFFFFF s12 bold, Arial
Gui, Show, w200 h30, Stupid Super Whisper

; Function to record audio
RecordAudio:
    ; Show recording indicator
    GuiControl,, StatusText, Recording... Release to transcribe
    Gui, Color, FF0000
    
    ; Start recording
    RunWait, python scripts/record.py
    
    ; Reset GUI
    Gui, Color, 000000
    GuiControl,, StatusText, Hold %hotkey% to record
return

; Handle GUI close
GuiClose:
ExitApp 