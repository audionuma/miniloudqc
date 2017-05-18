# miniloudqc
A minimal bash/awk/FFmpeg utility for loudness conformance checking on media files.

## WARNING

miniloudqc has not been extensively tested and therefore should be use with caution in a production environment.

There are currently no tests for potentially erroneous results (wrong file type, wrong channels mapping, ...).

## Why miniloudqc ?
miniloudqc attempts to offer the following functionalities:

- ease the use of FFmpeg's ebur128 filter by allowing to merge several mono audio streams into the filter prior to measurement.
- outputs a json formated summary of several loudness measurements over the whole media file.
- outputs a json formated array of timed warnings based on user-supplied delivery specifications.
- optionally outputs a json formated array of several loudness measurements every 100 ms.

## Requirements
miniloudqc has only been tested on Debian Jessie.

[FFmpeg](https://ffmpeg.org/) with [ebur128](https://ffmpeg.org/ffmpeg-filters.html#ebur128-1) and [amerge](https://ffmpeg.org/ffmpeg-filters.html#amerge-1) filters is required.

awk is required for the parsing of the ebur128 filter output.

## Usage
miniloudqc uses two files : `miniloudqc.sh` and `miniloudqc-parser.awk`. Both files must reside in the same directory.

```
Usage:
miniloudqc.sh [-l] [-s <stream_index>]... input_file
input_file : the media file to be measured.
  Options
-l (--log) : enables logging of data every 100 ms in the output
-s (--stream) stream_index : audio stream_index. Optional sequence of audio streams to merge before measure
  (default : audio stream 0 (first audio stream))
```
Examples :

`$ ./miniloudqc.sh audiofile.wav`

Outputs program loudness data of a multichannel wav file.

`$ ./miniloudqc.sh -l -s 0 -s 1 four-mono-streams.mxf`

Outputs program loudness data of audio streams 0 and 1 mapped as L/R program and a log of data every 100 ms of an mxf file containing four mono audio streams.

## json output

Examples are processed thru [jq](https://stedolan.github.io/jq/) to ease the reading. The actual output is more ugly.

### Example 1

`$ miniloudqc.sh ebu-test-set/seq-3341-1-16bit.wav`

```json
{
  "summary": {
    "file": "seq-3341-1-16bit.wav",
    "date": "20170518_140045Z",
    "duration": "00:00:20.00",
    "nr warnings": 0,
    "PGM Integrated Loudness": -23,
    "PGM LRA": 0,
    "PGM Max True-Peak": -22.9,
    "PGM Max Momentary": -23,
    "PGM Max Short-Term": -23
  },
  "warnings": [
    {}
  ]
}
```
`summary` object :
- "file" : the file processed.
- "date" : the date the measured was launched, expressed in GMT timezone.
- "duration" : file duration as seen by FFmpeg, expressed in HH:MM:SS.MILLISECONDS.
- "nr warnings" : the number of warnings generated with respect to the delivery specifications.
- "PGM Integrated Loudness" : the integrated loudness of the full program.
- "PGM LRA" : the loudness range of the full program.
- "PGM Max True-Peak" : the maximum true-peak of the full program.
- "PGM Max Momentary" : the maximum momentary loudness of the full program.
- "PGM Max Short-Term" : the maximum short-term loudness of the full program.

`warnings` array : an array of warnings.
- empty on this example as there are no warnings.

### Example 2
`$ miniloudqc.sh ebu-test-set/seq-3341-20-24bit.wav.wav`

```json
{
  "summary": {
    "file": "seq-3341-20-24bit.wav.wav",
    "date": "20170518_140821Z",
    "duration": "00:00:03.20",
    "nr warnings": 4,
    "PGM Integrated Loudness": -2.7,
    "PGM LRA": 20.1,
    "PGM Max True-Peak": -0.1,
    "PGM Max Momentary": -2.6,
    "PGM Max Short-Term": -2.7
  },
  "warnings": [
    {
      "type": "true-peak",
      "value": -0.1,
      "t": 1.6
    },
    {
      "type": "program loudness",
      "value": -2.7
    },
    {
      "type": "program LRA",
      "value": 20.1
    },
    {
      "type": "program True-Peak",
      "value": -0.1
    }
  ]
}
```

`warnings` array : an array of warnings.

`warning` objects :

- "type" : the type of warning.
    - "true-peak" : measured true-peak over the last 100 ms was not within specification.
    - "max-mom" : measured momentary loudness over the last 400 ms was not within specification.
    - "max-short" : measured short-term loudness over the last 3 s was not within specification.
    - "program loudness" : measured loudness of the full program is not within specification.
    - "program LRA" : measured loudness range of the full program is not within specification.
    - "program max mom" : measured maximum momentary loudness of the full program is not within specification.
    - "program max short" : measured maximum short-term loudness of the full program is not within specification.

- "value" : the measured value that raised the warning.
- "t" : the time when the warning was raised (expressed in seconds, 0 being the start of the file). This attribute is not present for warnings related to the full program.

### Example 3
`$ miniloudqc.sh -l ebu-test-set/seq-3341-1-16bit.wav`

Notice the `-l` option that enables logging 100 ms frame data.

```json
{
  "summary": {
    "file": "seq-3341-1-16bit.wav",
    "date": "20170518_152118Z",
    "duration": "00:00:20.00",
    "nr warnings": 0,
    "PGM Integrated Loudness": -23,
    "PGM LRA": 0,
    "PGM Max True-Peak": -22.9,
    "PGM Max Momentary": -23,
    "PGM Max Short-Term": -23
  },
  "warnings": [
    {}
  ],
  "logs": [
    {
      "t": 0.1,
      "mom": -120.7,
      "short": -120.7,
      "int": -70,
      "maxtp": -22.9
    },
    {
      "t": 0.2,
      "mom": -120.7,
      "short": -120.7,
      "int": -70,
      "maxtp": -22.9
    },
    {
      "t": 0.3,
      "mom": -120.7,
      "short": -120.7,
      "int": -70,
      "maxtp": -22.9
    },
    {
      "t": 0.4,
      "mom": -23,
      "short": -120.7,
      "int": -23,
      "maxtp": -22.9
    },
    {
      "t": 0.5,
      "mom": -23,
      "short": -120.7,
      "int": -23,
      "maxtp": -22.9
    }
    /* more log objects */
  ]
}
```
`logs` : an array of logs.

`log` objects :

- "t" : the time when the measure was done (expressed in seconds, 0 being the start of the file).
- "mom" : the momentary loudness over the last 400 ms.
- "short" : the short-term loudness over the last 3 s.
- "int" : the integrated loudness measured since the start of the program.
- "maxtp" : the maximum true-peak over the last 100 ms.
