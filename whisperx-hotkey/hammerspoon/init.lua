-- WhisperX Hotkey Transcription
-- Hammerspoon configuration for recording and transcribing speech with a hotkey

local log = hs.logger.new('whisperX', 'debug')
local audioRecorder = nil
local isRecording = false
local recordingStartTime = nil
local audioFile = os.getenv("HOME") .. "/Library/Application Support/Hammerspoon/whisperx_recording.wav"
local configFile = hs.spoons.resourcePath("whisperx_config.json")
local config = {}

-- Load configuration
local function loadConfig()
    local file = io.open(configFile, "r")
    if file then
        local content = file:read("*all")
        file:close()
        local status, configTable = pcall(function() return hs.json.decode(content) end)
        if status then
            config = configTable
            log.i("Loaded configuration")
        else
            log.e("Failed to parse config.json: " .. configTable)
        end
    else
        log.w("No config file found, using defaults")
        config = {
            hotkey = {
                key = "space",
                modifiers = {"cmd", "shift"}
            },
            whisperx = {
                model = "base",
                language = "en"
            }
        }
    end
end

-- Setup audio recorder
local function setupAudioRecorder()
    if audioRecorder then
        audioRecorder:stop()
        audioRecorder = nil
    end
    
    audioRecorder = hs.audiodevice.defaultInputDevice():record()
end

-- Start recording
local function startRecording()
    if isRecording then return end
    
    log.i("Starting recording")
    setupAudioRecorder()
    
    if audioRecorder then
        isRecording = true
        recordingStartTime = os.time()
        
        -- Add visual indicator that recording is active
        if hs.canvas then
            local screen = hs.screen.mainScreen()
            local frame = screen:frame()
            recordingIndicator = hs.canvas.new({x = frame.w - 100, y = 10, w = 90, h = 30})
            recordingIndicator:appendElements({
                type = "rectangle",
                action = "fill",
                fillColor = {red = 1, green = 0, blue = 0, alpha = 0.7},
                roundedRectRadii = {xRadius = 5, yRadius = 5}
            }, {
                type = "text",
                text = "Recording",
                textSize = 14,
                textColor = {white = 1, alpha = 1},
                textAlignment = "center"
            })
            recordingIndicator:show()
        end
        
        -- Optional sound effect
        hs.sound.getByName("Tink"):play()
    else
        log.e("Failed to start audio recording")
        hs.alert.show("Failed to start recording!")
    end
end

-- Stop recording and process
local function stopRecording()
    if not isRecording then return end
    
    log.i("Stopping recording")
    isRecording = false
    
    -- Hide recording indicator
    if recordingIndicator then
        recordingIndicator:delete()
        recordingIndicator = nil
    end
    
    -- Save recording
    if audioRecorder then
        local recordingDuration = os.time() - recordingStartTime
        log.i("Recording duration: " .. recordingDuration .. " seconds")
        
        -- Only process if recording is longer than 0.5 seconds
        if recordingDuration >= 0.5 then
            local success = audioRecorder:saveToFile(audioFile)
            audioRecorder:stop()
            audioRecorder = nil
            
            if success then
                hs.alert.show("Transcribing...")
                processAudio()
            else
                log.e("Failed to save audio file")
                hs.alert.show("Failed to save recording!")
            end
        else
            audioRecorder:stop()
            audioRecorder = nil
            log.i("Recording too short, ignored")
            hs.alert.show("Recording too short")
        end
    end
end

-- Process the audio with WhisperX
local function processAudio()
    local pythonScript = os.getenv("HOME") .. "/whisperx-hotkey/scripts/transcribe.py"
    local modelArg = config.whisperx and config.whisperx.model or "base"
    local languageArg = config.whisperx and config.whisperx.language or "en"
    
    local command = string.format("python3 '%s' --audio_file '%s' --model %s --language %s", 
                                 pythonScript, audioFile, modelArg, languageArg)
    
    log.i("Running command: " .. command)
    
    -- Run the transcription script asynchronously
    hs.task.new("/bin/bash", function(exitCode, stdOut, stdErr)
        if exitCode == 0 and stdOut then
            -- Trim whitespace
            local transcription = string.gsub(stdOut, "^%s*(.-)%s*$", "%1")
            log.i("Transcription: " .. transcription)
            
            -- Copy to clipboard and paste
            hs.pasteboard.setContents(transcription)
            hs.eventtap.keyStrokes(transcription)
            
            -- Success notification
            hs.alert.show("Transcribed!")
        else
            log.e("Transcription failed: " .. (stdErr or "Unknown error"))
            hs.alert.show("Transcription failed!")
        end
    end, {"-c", command}):start()
end

-- Initialize the module
local function init()
    loadConfig()
    
    -- Register hotkey
    local mods = config.hotkey.modifiers or {"cmd", "shift"}
    local key = config.hotkey.key or "space"
    
    hs.hotkey.bind(mods, key, startRecording, stopRecording)
    log.i("Registered hotkey: " .. table.concat(mods, "+") .. "+" .. key)
    
    hs.alert.show("WhisperX Hotkey Ready!")
end

-- Initialize when Hammerspoon loads this script
init() 