#!/usr/bin/env python3
"""
WhisperX Hotkey - Audio Utilities
Helper functions for audio processing.
"""

import os
import tempfile
import wave
import numpy as np
from datetime import datetime

def ensure_dir(directory):
    """Ensure that a directory exists."""
    if not os.path.exists(directory):
        os.makedirs(directory)
    return directory

def get_temp_filepath(prefix="recording_", suffix=".wav", directory=None):
    """Generate a temporary file path for an audio recording."""
    if directory:
        ensure_dir(directory)
    else:
        directory = tempfile.gettempdir()
    
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"{prefix}{timestamp}{suffix}"
    return os.path.join(directory, filename)

def convert_to_wav(input_file, output_file=None, sample_rate=16000, channels=1):
    """
    Convert audio file to WAV format.
    
    Args:
        input_file: Path to input audio file
        output_file: Path to output WAV file (generated if None)
        sample_rate: Target sample rate
        channels: Number of audio channels
        
    Returns:
        Path to the WAV file
    """
    try:
        import soundfile as sf
        
        if not output_file:
            output_file = get_temp_filepath(suffix=".wav")
        
        # Load the audio file
        data, source_sr = sf.read(input_file)
        
        # Convert to mono if needed
        if data.ndim > 1 and channels == 1:
            data = data.mean(axis=1)
        
        # Resample if needed
        if source_sr != sample_rate:
            from samplerate import resample
            ratio = sample_rate / source_sr
            data = resample(data, ratio, 'sinc_best')
        
        # Save as WAV
        sf.write(output_file, data, sample_rate)
        
        return output_file
    except Exception as e:
        print(f"Error converting audio: {str(e)}")
        return input_file

def detect_silence(audio_file, threshold=0.01, min_silence_duration=0.5):
    """
    Detect silence in an audio file.
    
    Args:
        audio_file: Path to audio file
        threshold: Amplitude threshold for silence detection
        min_silence_duration: Minimum silence duration in seconds
        
    Returns:
        List of tuples (start_time, end_time) for silence segments
    """
    try:
        import soundfile as sf
        
        # Read audio data
        data, sr = sf.read(audio_file)
        
        # Convert to mono if needed
        if data.ndim > 1:
            data = data.mean(axis=1)
        
        # Calculate amplitude
        amplitude = np.abs(data)
        
        # Find regions below threshold
        is_silence = amplitude < threshold
        
        # Convert to silence segments
        silence_segments = []
        silence_start = None
        
        for i, silent in enumerate(is_silence):
            time = i / sr
            
            if silent and silence_start is None:
                silence_start = time
            elif not silent and silence_start is not None:
                duration = time - silence_start
                if duration >= min_silence_duration:
                    silence_segments.append((silence_start, time))
                silence_start = None
        
        # Check for silence at the end
        if silence_start is not None:
            time = len(data) / sr
            duration = time - silence_start
            if duration >= min_silence_duration:
                silence_segments.append((silence_start, time))
        
        return silence_segments
    except Exception as e:
        print(f"Error detecting silence: {str(e)}")
        return []

def trim_silence(audio_file, output_file=None, threshold=0.01, min_silence_duration=0.5):
    """
    Trim silence from the beginning and end of an audio file.
    
    Args:
        audio_file: Path to audio file
        output_file: Path to output file (generated if None)
        threshold: Amplitude threshold for silence detection
        min_silence_duration: Minimum silence duration in seconds
        
    Returns:
        Path to the trimmed audio file
    """
    try:
        import soundfile as sf
        
        if not output_file:
            output_file = get_temp_filepath(prefix="trimmed_", suffix=".wav")
        
        # Read audio data
        data, sr = sf.read(audio_file)
        
        # Convert to mono for silence detection
        if data.ndim > 1:
            mono_data = data.mean(axis=1)
        else:
            mono_data = data
        
        # Calculate amplitude
        amplitude = np.abs(mono_data)
        
        # Find non-silent regions
        is_sound = amplitude > threshold
        
        if not any(is_sound):
            # All silence, return an empty file
            sf.write(output_file, np.zeros(int(0.1 * sr)), sr)
            return output_file
        
        # Find first and last non-silent sample
        first_sound = np.where(is_sound)[0][0]
        last_sound = np.where(is_sound)[0][-1]
        
        # Add a small buffer (100ms) before and after
        buffer_samples = int(0.1 * sr)
        start_idx = max(0, first_sound - buffer_samples)
        end_idx = min(len(data), last_sound + buffer_samples)
        
        # Trim the data
        if data.ndim > 1:
            trimmed_data = data[start_idx:end_idx, :]
        else:
            trimmed_data = data[start_idx:end_idx]
        
        # Save the trimmed audio
        sf.write(output_file, trimmed_data, sr)
        
        return output_file
    except Exception as e:
        print(f"Error trimming silence: {str(e)}")
        return audio_file

def get_audio_duration(audio_file):
    """Get the duration of an audio file in seconds."""
    try:
        import soundfile as sf
        info = sf.info(audio_file)
        return info.duration
    except Exception as e:
        print(f"Error getting audio duration: {str(e)}")
        try:
            # Fallback to wave module for WAV files
            with wave.open(audio_file, 'r') as wf:
                frames = wf.getnframes()
                rate = wf.getframerate()
                duration = frames / float(rate)
                return duration
        except:
            return 0.0 