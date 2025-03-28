#!/usr/bin/env python3
"""
WhisperX Hotkey - Transcription Module
This script takes an audio file and transcribes it using WhisperX.
"""

import os
import sys
import argparse
import json
import tempfile
import gc
import torch
import whisperx

def load_config(config_path=None):
    """Load configuration from a JSON file."""
    if not config_path:
        # Default config path
        script_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        config_path = os.path.join(script_dir, "config.json")
    
    if os.path.exists(config_path):
        with open(config_path, 'r') as f:
            return json.load(f)
    return {}

def transcribe_audio(audio_file, model_name="base", language="en", compute_type="int8", batch_size=16, output_file=None):
    """
    Transcribe audio using WhisperX.
    
    Args:
        audio_file: Path to the audio file
        model_name: WhisperX model to use
        language: Language code
        compute_type: Computation type (float16, int8)
        batch_size: Batch size for processing
        output_file: Path to write transcription output (optional)
        
    Returns:
        Transcribed text
    """
    try:
        # Check if the audio file exists
        if not os.path.isfile(audio_file):
            raise FileNotFoundError(f"Audio file not found: {audio_file}")
            
        # Use a temporary directory for any temporary files
        with tempfile.TemporaryDirectory() as temp_dir:
            # 1. Load audio
            print(f"Loading audio: {audio_file}", file=sys.stderr)
            audio = whisperx.load_audio(audio_file)
            
            # 2. Load model
            print(f"Loading model: {model_name}", file=sys.stderr)
            device = "cuda" if torch.cuda.is_available() else "cpu"
            model = whisperx.load_model(
                model_name, 
                device, 
                compute_type=compute_type,
                language=language
            )
            
            # 3. Transcribe
            print("Transcribing...", file=sys.stderr)
            result = model.transcribe(audio, batch_size=batch_size)
            
            # Clean up model to free memory
            del model
            gc.collect()
            if torch.cuda.is_available():
                torch.cuda.empty_cache()
            
            # 4. Extract transcription
            if result and "segments" in result and result["segments"]:
                # Extract full text from segments
                transcription = " ".join([segment["text"].strip() for segment in result["segments"]])
                
                # Clean up the text
                transcription = transcription.strip()
                
                # Write to output file if specified
                if output_file:
                    with open(output_file, 'w', encoding='utf-8') as f:
                        f.write(transcription)
                    print(f"Transcription written to: {output_file}", file=sys.stderr)
                
                return transcription
            else:
                # Write empty string to output file if specified
                if output_file:
                    with open(output_file, 'w', encoding='utf-8') as f:
                        f.write("")
                return ""
                
    except Exception as e:
        print(f"Error during transcription: {str(e)}", file=sys.stderr)
        # Write error to output file if specified
        if output_file:
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(f"Error: {str(e)}")
        return ""

def main():
    parser = argparse.ArgumentParser(description="Transcribe audio using WhisperX")
    parser.add_argument("--audio_file", required=True, help="Path to the audio file")
    parser.add_argument("--config", help="Path to configuration file")
    parser.add_argument("--model", default=None, help="WhisperX model to use (tiny, base, small, medium, large)")
    parser.add_argument("--language", default=None, help="Language code (e.g., en, fr, de)")
    parser.add_argument("--compute_type", default=None, help="Computation type (float16, int8)")
    parser.add_argument("--batch_size", type=int, default=None, help="Batch size for processing")
    parser.add_argument("--output_file", help="Path to write transcription output")
    
    args = parser.parse_args()
    
    # Load configuration
    config = load_config(args.config)
    whisperx_config = config.get("whisperx", {})
    audio_config = config.get("audio", {})
    
    # Command line arguments override config file
    model = args.model or whisperx_config.get("model", "base")
    language = args.language or whisperx_config.get("language", "en")
    compute_type = args.compute_type or whisperx_config.get("compute_type", "int8")
    batch_size = args.batch_size or whisperx_config.get("batch_size", 16)
    
    # Default output file
    output_file = args.output_file
    if not output_file and "temp_dir" in audio_config:
        temp_dir = audio_config["temp_dir"]
        if not os.path.exists(temp_dir):
            os.makedirs(temp_dir)
        output_file = os.path.join(temp_dir, "transcription.txt")
    
    # Transcribe audio
    transcription = transcribe_audio(
        args.audio_file,
        model_name=model,
        language=language,
        compute_type=compute_type,
        batch_size=batch_size,
        output_file=output_file
    )
    
    # Output the transcription to stdout as well
    print(transcription)

if __name__ == "__main__":
    main() 