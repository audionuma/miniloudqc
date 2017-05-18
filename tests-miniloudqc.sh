#!/usr/bin/env bash

# tests-miniloudqc.sh v 0.1
# licence MIT 
# checks compliance of miniloudqc.sh
# to EBU Tech 3341 and EBU Tech 3342 tests
# https://tech.ebu.ch/files/live/sites/tech/files/shared/testmaterial/ebu-loudness-test-setv05.zip

source_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
mlqc=$source_dir"/miniloudqc.sh"


failures=0

# $1 file, $2 expected min, $3 expected max
function check_loudness {
  v="$($mlqc $1 | jq '."summary"."PGM Integrated Loudness"')"
  t1="$(echo $v '>=' $2 | bc -l )"
  t2="$(echo $v '<=' $3 | bc -l )"
  if [ "$t1" == "1" ] && [ "$t2" == "1" ]; then
    echo  "Passed $1"
  else
    echo "Failed $1 : expected pgm loudness between $2 and $3, found $v"
    ((failures++))
  fi

}

# $1 file, $2 expected min, $3 expected max
function check_lra {
  v="$($mlqc $1 | jq '."summary"."PGM LRA"')"
  t1="$(echo $v '>=' $2 | bc -l )"
  t2="$(echo $v '<=' $3 | bc -l )"
  if [ "$t1" == "1" ] && [ "$t2" == "1" ]; then
    echo  "Passed $1"
  else
    echo "Failed $1 : expected pgm LRA between $2 and $3, found $v"
    ((failures++))
  fi

}

# $1 file, $2 expected min, $3 expected max
function check_maxtp {
  v="$($mlqc $1 | jq '."summary"."PGM Max True-Peak"')"
  t1="$(echo $v '>=' $2 | bc -l )"
  t2="$(echo $v '<=' $3 | bc -l )"
  if [ "$t1" == "1" ] && [ "$t2" == "1" ]; then
    echo  "Passed $1"
  else
    echo "Failed $1 : expected pgm max tp between $2 and $3, found $v"
    ((failures++))
  fi

}

# $1 file, $2 expected min, $3 expected max
function check_maxmom {
  v="$($mlqc $1 | jq '."summary"."PGM Max Momentary"')"
  t1="$(echo $v '>=' $2 | bc -l )"
  t2="$(echo $v '<=' $3 | bc -l )"
  if [ "$t1" == "1" ] && [ "$t2" == "1" ]; then
    echo  "Passed $1"
  else
    echo "Failed $1 : expected pgm max mom between $2 and $3, found" $v
    ((failures++))
  fi

}

# $1 file, $2 expected min, $3 expected max
function check_maxshort {
  v="$($mlqc $1 | jq '."summary"."PGM Max Short-Term"')"
  t1="$(echo $v '>=' $2 | bc -l )"
  t2="$(echo $v '<=' $3 | bc -l )"
  if [ "$t1" == "1" ] && [ "$t2" == "1" ]; then
    echo  "Passed $1"
  else
    echo "Failed $1 : expected pgm max short between $2 and $3, found $v"
    ((failures++))
  fi

}

echo "*** EBU test set compliance check ***"

check_loudness 'seq-3341-1-16bit.wav' -23.1 -22.9
check_loudness 'seq-3341-2-16bit.wav' -33.1 -32.9
check_loudness 'seq-3341-3-16bit-v02.wav' -23.1 -22.9
check_loudness 'seq-3341-4-16bit-v02.wav' -23.1 -22.9
check_loudness 'seq-3341-5-16bit-v02.wav' -23.1 -22.9
check_loudness 'seq-3341-6-5channels-16bit.wav' -23.1 -22.9
check_loudness 'seq-3341-6-6channels-WAVEEX-16bit.wav' -23.1 -22.9
check_loudness 'seq-3341-7_seq-3342-5-24bit.wav' -23.1 -22.9
check_loudness 'seq-3341-2011-8_seq-3342-6-24bit-v02.wav' -23.1 -22.9

check_maxshort 'seq-3341-10-1-24bit.wav' -23.1 -22.9
check_maxshort 'seq-3341-10-2-24bit.wav' -23.1 -22.9
check_maxshort 'seq-3341-10-3-24bit.wav' -23.1 -22.9
check_maxshort 'seq-3341-10-4-24bit.wav' -23.1 -22.9
check_maxshort 'seq-3341-10-5-24bit.wav' -23.1 -22.9
check_maxshort 'seq-3341-10-6-24bit.wav' -23.1 -22.9
check_maxshort 'seq-3341-10-7-24bit.wav' -23.1 -22.9
check_maxshort 'seq-3341-10-8-24bit.wav' -23.1 -22.9
check_maxshort 'seq-3341-10-9-24bit.wav' -23.1 -22.9
check_maxshort 'seq-3341-10-10-24bit.wav' -23.1 -22.9
check_maxshort 'seq-3341-10-11-24bit.wav' -23.1 -22.9
check_maxshort 'seq-3341-10-12-24bit.wav' -23.1 -22.9
check_maxshort 'seq-3341-10-13-24bit.wav' -23.1 -22.9
check_maxshort 'seq-3341-10-14-24bit.wav' -23.1 -22.9
check_maxshort 'seq-3341-10-15-24bit.wav' -23.1 -22.9
check_maxshort 'seq-3341-10-16-24bit.wav' -23.1 -22.9
check_maxshort 'seq-3341-10-17-24bit.wav' -23.1 -22.9
check_maxshort 'seq-3341-10-18-24bit.wav' -23.1 -22.9
check_maxshort 'seq-3341-10-19-24bit.wav' -23.1 -22.9
check_maxshort 'seq-3341-10-20-24bit.wav' -23.1 -22.9

check_maxmom 'seq-3341-12-24bit.wav' -23.1 -22.9
check_maxmom 'seq-3341-13-1-24bit.wav' -23.1 -22.9
check_maxmom 'seq-3341-13-2-24bit.wav' -23.1 -22.9
check_maxmom 'seq-3341-13-3-24bit.wav.wav' -23.1 -22.9
check_maxmom 'seq-3341-13-4-24bit.wav.wav' -23.1 -22.9
check_maxmom 'seq-3341-13-5-24bit.wav.wav' -23.1 -22.9
check_maxmom 'seq-3341-13-6-24bit.wav.wav' -23.1 -22.9
check_maxmom 'seq-3341-13-7-24bit.wav.wav' -23.1 -22.9
check_maxmom 'seq-3341-13-8-24bit.wav.wav' -23.1 -22.9
check_maxmom 'seq-3341-13-9-24bit.wav.wav' -23.1 -22.9
check_maxmom 'seq-3341-13-10-24bit.wav.wav' -23.1 -22.9
check_maxmom 'seq-3341-13-11-24bit.wav.wav' -23.1 -22.9
check_maxmom 'seq-3341-13-12-24bit.wav.wav' -23.1 -22.9
check_maxmom 'seq-3341-13-13-24bit.wav.wav' -23.1 -22.9
check_maxmom 'seq-3341-13-14-24bit.wav.wav' -23.1 -22.9
check_maxmom 'seq-3341-13-15-24bit.wav.wav' -23.1 -22.9
check_maxmom 'seq-3341-13-16-24bit.wav.wav' -23.1 -22.9
check_maxmom 'seq-3341-13-17-24bit.wav.wav' -23.1 -22.9
check_maxmom 'seq-3341-13-18-24bit.wav.wav' -23.1 -22.9
check_maxmom 'seq-3341-13-19-24bit.wav.wav' -23.1 -22.9
check_maxmom 'seq-3341-13-20-24bit.wav.wav' -23.1 -22.9

check_maxtp 'seq-3341-15-24bit.wav.wav' -6.4 -5.8
check_maxtp 'seq-3341-16-24bit.wav.wav' -6.4 -5.8
check_maxtp 'seq-3341-17-24bit.wav.wav' -6.4 -5.8
check_maxtp 'seq-3341-18-24bit.wav.wav' -6.4 -5.8
check_maxtp 'seq-3341-19-24bit.wav.wav' 2.6 3.2
check_maxtp 'seq-3341-20-24bit.wav.wav' -0.4 0.2
check_maxtp 'seq-3341-21-24bit.wav.wav' -0.4 0.2
check_maxtp 'seq-3341-22-24bit.wav.wav' -0.4 0.2
check_maxtp 'seq-3341-23-24bit.wav.wav' -0.4 0.2

check_lra 'seq-3342-1-16bit.wav' 9 11
check_lra 'seq-3342-2-16bit.wav' 4 6
check_lra 'seq-3342-3-16bit.wav' 19 21
check_lra 'seq-3342-4-16bit.wav' 14 16
check_lra 'seq-3341-7_seq-3342-5-24bit.wav' 4 6
check_lra 'seq-3341-2011-8_seq-3342-6-24bit-v02.wav' 14 16

if [ "$failures" -gt 0 ]; then
   echo "*** WARNING failures : $failures ***"
fi


