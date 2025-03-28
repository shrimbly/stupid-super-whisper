; WhisperX Hotkey for Windows
; Hold down Ctrl+Shift+Space to record and transcribe speech

#NoEnv
#Persistent
#SingleInstance Force
SetWorkingDir %A_ScriptDir%

; Configuration
scriptDir := A_ScriptDir
configFile := scriptDir . "\config.json"
pythonScript := scriptDir . "\scripts\win_audio_recorder.py"
transcribeScript := scriptDir . "\scripts\transcribe.py"

; Default audio file location
tempDir := A_Temp . "\whisperx-hotkey"
if !FileExist(tempDir)
    FileCreateDir, %tempDir%
audioFile := tempDir . "\recording.wav"
transcriptionFile := tempDir . "\transcription.txt"

; State variables
isRecording := false
recordingStartTime := 0
recordingPID := 0

; Try to find Python executable
pythonExe := "python.exe"
if (FileExist(A_UserProfile . "\whisperx-hotkey-env\Scripts\python.exe"))
    pythonExe := A_UserProfile . "\whisperx-hotkey-env\Scripts\python.exe"

; Read configuration
LoadConfig()

; Create a GUI for recording indicator
Gui, +AlwaysOnTop +ToolWindow -Caption
Gui, Color, FF0000
Gui, Font, s12 cWhite bold, Arial
Gui, Add, Text, w120 h30 Center vRecordingText, Recording...
Gui, Show, NoActivate Hide, Recording Indicator

; Hotkey: Ctrl+Shift+Space (configurable in the future)
^+Space::
    if (!isRecording) {
        StartRecording()
    }
return

^+Space Up::
    if (isRecording) {
        StopRecording()
    }
return

StartRecording() {
    global isRecording, recordingStartTime, recordingPID, audioFile, pythonExe, pythonScript
    
    ; Show recording indicator
    WinGetPos,,, Width, Height, A
    Gui, Show, % "x" . (Width-140) . " y10 NoActivate", Recording Indicator
    
    ; Start recording using our Python recorder
    recordingCmd := """" . pythonExe . """ """ . pythonScript . """ --output """ . audioFile . """"
    Run, %recordingCmd%,, Hide, recordingPID
    
    isRecording := true
    recordingStartTime := A_TickCount
    
    ; Optional sound effect
    SoundPlay, *48 ; Windows default sound
}

StopRecording() {
    global isRecording, recordingStartTime, recordingPID, audioFile, transcriptionFile, pythonExe, transcribeScript
    
    ; Hide recording indicator
    Gui, Hide
    
    ; Calculate recording duration
    recordingDuration := (A_TickCount - recordingStartTime) / 1000
    
    ; Only process if recording is longer than 0.5 seconds
    if (recordingDuration < 0.5) {
        isRecording := false
        if (recordingPID) {
            Process, Close, %recordingPID%
        }
        ToolTip, Recording too short
        SetTimer, RemoveToolTip, -1000
        return
    }
    
    ; Stop recording
    if (recordingPID) {
        Process, Close, %recordingPID%
        Sleep, 300 ; Give some time for the file to be written
    }
    
    ; Check if audio file exists
    if (!FileExist(audioFile)) {
        isRecording := false
        ToolTip, Recording failed: Audio file not found
        SetTimer, RemoveToolTip, -1500
        return
    }
    
    ; Show transcribing tooltip
    ToolTip, Transcribing...
    
    ; Run transcription
    transcribeCmd := """" . pythonExe . """ """ . transcribeScript . """ --audio_file """ . audioFile . """ --output_file """ . transcriptionFile . """"
    RunWait, %transcribeCmd%,, Hide
    
    ; Check if transcription file exists
    if (!FileExist(transcriptionFile)) {
        isRecording := false
        ToolTip, Transcription failed: Output file not found
        SetTimer, RemoveToolTip, -1500
        return
    }
    
    ; Read transcription
    FileRead, transcription, %transcriptionFile%
    
    ; Remove tooltip
    ToolTip
    
    ; Paste transcription
    if (transcription != "") {
        ClipSaved := ClipboardAll
        Clipboard := transcription
        Sleep, 100
        Send, ^v
        Sleep, 100
        Clipboard := ClipSaved
        ClipSaved := ""
    } else {
        ToolTip, No transcription result
        SetTimer, RemoveToolTip, -1500
    }
    
    isRecording := false
}

LoadConfig() {
    global configFile
    
    ; Default configuration
    global hotkeyKey := "Space"
    global hotkeyModifiers := ["Ctrl", "Shift"]
    global whisperxModel := "base"
    global whisperxLanguage := "en"
    
    ; Try to read config file
    if (FileExist(configFile)) {
        FileRead, configJson, %configFile%
        if (configJson) {
            ; Parse JSON (simple approach)
            ; In a more complex scenario, you'd use a JSON library
            if (InStr(configJson, """model"": ""tiny"""))
                whisperxModel := "tiny"
            else if (InStr(configJson, """model"": ""small"""))
                whisperxModel := "small"
            else if (InStr(configJson, """model"": ""medium"""))
                whisperxModel := "medium"
            else if (InStr(configJson, """model"": ""large-v2"""))
                whisperxModel := "large-v2"
                
            if (InStr(configJson, """language"": """))
                RegExMatch(configJson, """language"": ""([^""]+)""", match)
                if (match1)
                    whisperxLanguage := match1
        }
    }
}

RemoveToolTip:
    ToolTip
return 