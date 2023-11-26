#!/bin/bash

check_command() {
    local command_name=$1
    local command_path

    if [ -e ./"$command_name" ]; then
        command_path=./"$command_name"
    elif command -v "$command_name" &> /dev/null; then
        command_path=$command_name
    elif [ -e ./"$command_name.exe" ]; then
        command_path=./"$command_name.exe"
    else
        echo "Error: $command_name not found in the current directory or search path."
        exit 1
    fi

    echo "$command_path"
}

FFPROBE=$(check_command "ffprobe")
FFMPEG=$(check_command "ffmpeg")

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <video_input_file>"
    exit 1
fi

video_input_file=$1
input_extension=${video_input_file##*.}

# Use ffprobe to check the audio codec
audio_codec=$("$FFPROBE" -v error -select_streams a:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "$video_input_file")

if [ $? -ne 0 ]; then
    echo "Error: ffprobe command failed."
    echo "$FFPROBE $video_input_file"
    exit 1
fi

output_file=$(basename -s .$input_extension "$video_input_file").$audio_codec

# Use ffmpeg to extract audio based on the audio codec
"$FFMPEG" -i "$video_input_file" -vn -acodec copy "$output_file"

if [ $? -ne 0 ]; then
    echo "Error: ffmpeg command failed."
else
    echo "Extraction complete. Output audio file: $output_file"
fi
