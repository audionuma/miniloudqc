#!/usr/bin/env bash

# miniloudqc.sh v 0.1
# licence MIT 
# miniloudqc.sh allows to output loudness summary and warnings on media files
# requires FFmpeg and awk
# allows to merge several mono streams to multichannel stream
# the miniloudqc-parser.awk file is expected to be 
# in the same directory than this file

# Usage: 
# minloudqc.sh [-l] [-s <stream_index>]... input_file
# input_file : the media file to be measured.
# -l (--log) : enables logging of data every 100 ms in the output
# -s (--stream) stream_index : audio stream_index. Optional sequence 
# of audio streams to merge before measure
# default : audio stream 0 (first audio stream)


# default FFmpeg filter when no merging occurs
default_filter="ebur128=peak=true"

# no logging by default
with_log=0

# checking wich audio streams we want to merge
# default audio stream 0, no merging
# works for multichannels audio files

while [[ $# -gt 1 ]]; do
    key="$1"
    case $key in
    -s|--stream)
    streams=("${streams[@]}" $2)
    shift
    ;;
    -l|--log)
    with_log=1
    ;;
    *)
    ;;
    esac
    shift 
done

# setting streams merging
if [ ${#streams[@]} -eq 0 ]; then
    filter=$default_filter
else
    for s in "${streams[@]}"; do  
        L="[0:a:$s]"
        merge="$merge$L"
    done
    amerge_inputs=${#streams[@]}
    filter=${merge}amerge=inputs=${amerge_inputs}", "$default_filter
fi

# checking if input file arg found
if [[ -n $1 ]]; then
    input_file=$1
else
    echo "no input file found"; exit 1
fi


# get input file absolute path
abs_input_file=$(readlink -f $input_file)

# check if absolute path is a file
if ! [ -f "${abs_input_file}" ]; then
  echo "${abs_input_file} is not a file";
  exit 1
fi

# getting short file name for output printing
filename=$(basename $abs_input_file)

# check if ffmpeg binary is present
# edit here if FFmpeg is not in $PATH
ff="ffmpeg"
type -P $ff &>/dev/null  || \
{ echo "$ff command not found."; exit 1; }

# path to awk script
# must be in the same directory than this file
source_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
awk_parser=$source_dir"/miniloudqc-parser.awk"

# date formatting for output
current_date=$(date --utc +%Y%m%d_%H%M%SZ)

$ff -i "$abs_input_file" -filter_complex \
"${filter}" -f null - 2>&1 | "${awk_parser}"\
 -v "filename=$filename"\
 -v "date=$current_date"\
 -v "with_log=$with_log"


