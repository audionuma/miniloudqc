#!/usr/bin/awk -f

# miniloudqc-parser v 0.1
# licence MIT 
# miniloudqc-parser.awk is used to parse output from FFmpeg's ebur128 filter
# and output json formatted loudness report.

BEGIN {
  FS="t:|M:|S:|I:|LUFS|LRA:|LU|FTPK:|dBFS|TPK:|Peak:";
  integrated=0;
  lra=0;
  maxtp=0;
  max_mom=-500.0;
  max_short=-500.0;
  nr_log_lines=0;
  nr_warnings=0;
  
  # here are the default specs
  # currently these default specs are based on
  # french CST RT 17 delivery specs for content over 30"
  # edit here for your own specs
  if (spec_max_tp=="")
    spec_max_tp=-3.0
  if (spec_target_loudness=="")
    spec_target_loudness=-23.0
  if (spec_loudness_margin=="")
    spec_loudness_margin=1.0
  if (spec_max_lra=="")
    spec_max_lra=20.0
  if (spec_max_mom=="")
    spec_max_mom=0.0
  if (spec_max_short=="")
    spec_max_short=0.0

  # enable/disable log of 100 ms data in the output
  if (with_log=="")
    with_log=0
}

# matching patterns

# getting the file duration from FFmpeg
/^[ ]+Duration:/{
  n=split($0, DUR, " ")
  n=split(DUR[2], DUR, ",")
  duration = DUR[1]
}

# matching lines that actually contain 100 ms frames loudness data
# filling an array for later processing if log enabled
# filling an array for timed warnings, too
/t:(.*)M:/{
  n=split($9, PEAKS, " ")
  fmtp=-500.0
  for (i = 1; i < n; ++i)
    if (PEAKS[i] != "-inf" && PEAKS[i] > fmtp)
      fmtp=PEAKS[i]
  # filling the log array
  if (with_log) {
    l=sprintf("\"t\":%.1f,\"mom\":%.1f,\"short\":%.1f,\"int\":%.1f,\"maxtp\":%.1f",\
 $2, $3, $4, $5, fmtp)
    lines[nr_log_lines]=l
    nr_log_lines+=1
  }

  if ($3 > max_mom) {
    max_mom = $3
  }
  if ($4 > max_short) {
    max_short = $4
  }

  # checking timed warnings
  if (fmtp > spec_max_tp + 0) {
    w=sprintf("\"type\":\"true-peak\",\"value\":%.1f,\"t\":%.1f", fmtp, $2)
    warnings[nr_warnings]=w
    nr_warnings+=1
  }
  if ($3 > spec_max_mom + 0) {
    w=sprintf("\"type\":\"max-mom\",\"value\":%.1f,\"t\":%.1f", $3, $2)
    warnings[nr_warnings]=w
    nr_warnings+=1
  }
  if ($4 > spec_max_short + 0) {
    w=sprintf("\"type\":\"max-short\",\"value\":%.1f,\"t\":%.1f", $4, $2)
    warnings[nr_warnings]=w
    nr_warnings+=1
  }
}

# matching PGM integrated
/^[ ]+I:/{
  integrated=$2
}

# matching PGM LRA
/^[ ]+LRA:/{
  lra=$2
}

# matchning PGM Max TP
/^[ ]+Peak:/{
  maxtp=$2
}


END {
  gsub(/^[ \t]+|[ \t]+$/, "", integrated)
  gsub(/^[ \t]+|[ \t]+$/, "", lra)
  gsub(/^[ \t]+|[ \t]+$/, "", maxtp)
  gsub(/^[ \t]+|[ \t]+$/, "", max_mom)
  gsub(/^[ \t]+|[ \t]+$/, "", max_short)
  
  # checking PGM warnings
  if (integrated + 0 > (spec_target_loudness + spec_loudness_margin) || integrated  + 0 < (spec_target_loudness - spec_loudness_margin)) {
    w=sprintf("\"type\":\"program loudness\",\"value\":%.1f", integrated)
    warnings[nr_warnings]=w
    nr_warnings+=1
  }
  if (lra + 0 > spec_max_lra) {
    w=sprintf("\"type\":\"program LRA\",\"value\":%.1f", lra)
    warnings[nr_warnings]=w
    nr_warnings+=1
  }
  if (maxtp + 0 > spec_max_tp) {
    w=sprintf("\"type\":\"program True-Peak\",\"value\":%.1f", maxtp)
    warnings[nr_warnings]=w
    nr_warnings+=1
  }
  if (max_mom + 0 > spec_max_mom) {
    w=sprintf("\"type\":\"program max mom\",\"value\":%.1f", max_mom)
    warnings[nr_warnings]=w
    nr_warnings+=1
  }
  if (max_short + 0 > spec_max_short) {
    w=sprintf("\"type\":\"program max short\",\"value\":%.1f", max_short)
    warnings[nr_warnings]=w
    nr_warnings+=1
  }
  
  # json formatted output
  printf("{\n")
  print_summary()
  printf(",\n")
  print_warnings()
  if (with_log) {
    printf(",\n")
    print_log()
  }
  printf("}\n")
}

function print_summary() {
  printf("\"summary\":\n{\"file\":\"%s\",\"date\":\"%s\",\"duration\":\"%s\",\"nr warnings\":%d,", filename, date, duration, nr_warnings)
  printf("\"PGM Integrated Loudness\":%.1f,\"PGM LRA\":%.1f,\"PGM Max True-Peak\":%.1f,", integrated, lra, maxtp)
  printf("\"PGM Max Momentary\":%.1f,\"PGM Max Short-Term\":%.1f}\n", max_mom, max_short)
}

function print_log() {
  printf("\"logs\":[\n")
  for (i = 0; i < nr_log_lines - 1; i++)
    printf("{%s},\n", lines[i])
    printf("{%s}]\n", lines[nr_log_lines - 1]) 
}

function print_warnings() {
  printf("\"warnings\":[\n")
  for (i = 0; i < nr_warnings - 1; i++)
    printf("{%s},\n", warnings[i])
  printf("{%s}]\n", warnings[nr_warnings - 1]) 

}