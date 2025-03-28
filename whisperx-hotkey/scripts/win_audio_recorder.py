#!/usr/bin/env python3
"""
WhisperX Hotkey - Windows Audio Recorder
Provides functionality to record audio on Windows using PyAudio.
"""

import os
import time
import wave
import threading
import argparse
import pyaudio
import numpy as np
from datetime import datetime

# Default audio parameters
DEFAULT_FORMAT = pyaudio.paInt16
DEFAULT_CHANNELS = 1
DEFAULT_RATE = 16000
DEFAULT_CHUNK = 1024
DEFAULT_SILENCE_THRESHOLD = 500  # Silence threshold

class AudioRecorder:
    """Simple audio recorder class for Windows."""
    
    def __init__(self, 
                 output_file=None,
                 format=DEFAULT_FORMAT,
                 channels=DEFAULT_CHANNELS, 
                 rate=DEFAULT_RATE,
                 chunk=DEFAULT_CHUNK,
                 silence_threshold=DEFAULT_SILENCE_THRESHOLD):
        """Initialize the audio recorder."""
        self.format = format
        self.channels = channels
        self.rate = rate
        self.chunk = chunk
        self.silence_threshold = silence_threshold
        
        if output_file is None:
            # Generate output file name based on timestamp
            temp_dir = os.environ.get('TEMP', os.path.expanduser('~'))
            whisperx_dir = os.path.join(temp_dir, 'whisperx-hotkey')
            if not os.path.exists(whisperx_dir):
                os.makedirs(whisperx_dir)
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            self.output_file = os.path.join(whisperx_dir, f"recording_{timestamp}.wav")
        else:
            self.output_file = output_file
        
        self.audio = None
        self.stream = None
        self.frames = []
        self.is_recording = False
        self.stop_event = threading.Event()
    
    def start_recording(self):
        """Start recording audio."""
        self.audio = pyaudio.PyAudio()
        self.stream = self.audio.open(
            format=self.format,
            channels=self.channels,
            rate=self.rate,
            input=True,
            frames_per_buffer=self.chunk
        )
        
        self.frames = []
        self.is_recording = True
        self.stop_event.clear()
        
        # Start recording thread
        threading.Thread(target=self._record_thread, daemon=True).start()
        
        print(f"Recording started... (Press Ctrl+C to stop)")
        return self.output_file
    
    def _record_thread(self):
        """Record audio in a separate thread."""
        try:
            while not self.stop_event.is_set() and self.is_recording:
                data = self.stream.read(self.chunk, exception_on_overflow=False)
                self.frames.append(data)
                
                # Optional: Print audio level for debugging
                # audio_data = np.frombuffer(data, dtype=np.int16)
                # audio_level = np.abs(audio_data).mean()
                # print(f"Audio level: {audio_level}")
        except Exception as e:
            print(f"Error in recording thread: {str(e)}")
        finally:
            if self.is_recording:
                self.stop_recording()
    
    def stop_recording(self):
        """Stop recording and save the audio file."""
        if not self.is_recording:
            return None
        
        self.is_recording = False
        self.stop_event.set()
        
        if self.stream:
            self.stream.stop_stream()
            self.stream.close()
            self.stream = None
        
        if self.audio:
            self.audio.terminate()
            self.audio = None
        
        # Save recording
        if self.frames:
            self._save_wav()
            print(f"Recording saved to: {self.output_file}")
            return self.output_file
        else:
            print("No audio data captured.")
            return None
    
    def _save_wav(self):
        """Save recorded audio as WAV file."""
        try:
            wf = wave.open(self.output_file, 'wb')
            wf.setnchannels(self.channels)
            wf.setsampwidth(self.audio.get_sample_size(self.format))
            wf.setframerate(self.rate)
            wf.writeframes(b''.join(self.frames))
            wf.close()
        except Exception as e:
            print(f"Error saving WAV file: {str(e)}")

def record_for_duration(duration, output_file=None, rate=DEFAULT_RATE, channels=DEFAULT_CHANNELS):
    """Record audio for a specified duration."""
    recorder = AudioRecorder(output_file=output_file, rate=rate, channels=channels)
    output_path = recorder.start_recording()
    
    try:
        # Record for the specified duration
        time.sleep(duration)
    except KeyboardInterrupt:
        print("Recording interrupted by user.")
    finally:
        recorder.stop_recording()
    
    return output_path

def record_until_keypress(output_file=None, rate=DEFAULT_RATE, channels=DEFAULT_CHANNELS):
    """Record audio until Enter key is pressed."""
    recorder = AudioRecorder(output_file=output_file, rate=rate, channels=channels)
    output_path = recorder.start_recording()
    
    try:
        print("Recording... Press Enter to stop.")
        input()
    except KeyboardInterrupt:
        print("Recording interrupted by user.")
    finally:
        recorder.stop_recording()
    
    return output_path

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Record audio on Windows")
    parser.add_argument("--output", help="Output WAV file path")
    parser.add_argument("--duration", type=float, help="Recording duration in seconds")
    parser.add_argument("--rate", type=int, default=DEFAULT_RATE, help="Sample rate")
    parser.add_argument("--channels", type=int, default=DEFAULT_CHANNELS, help="Number of channels")
    
    args = parser.parse_args()
    
    if args.duration:
        record_for_duration(args.duration, args.output, args.rate, args.channels)
    else:
        record_until_keypress(args.output, args.rate, args.channels) 