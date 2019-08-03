#!/usr/bin/env bats

@test "__sash_parse_args can parse all manner of flags, and stdin" {
  run $BATS_TEST_DIRNAME/test-cases/sash-parse-all.sh
  [ "$status" -eq "0" ]
  [ "${lines[0]}" = "0" ]
  [ "${lines[1]}" = "10" ]
  [ "${lines[2]}" = "is good" ]
  [ "${lines[3]}" = "hey" ]
  [ "${lines[4]}" = "a value with spaces" ]
  [ "${lines[5]}" = "0" ]
  [ "${lines[6]}" = "10" ]
  [ "${lines[7]}" = "or are they" ]
  [ "${lines[8]}" = "10" ]
  [ "${lines[9]}" = "possibly maybe" ]
  [ "${lines[10]}" = "here is some extra flags" ]
}

@test "__sash_parse_args rejects invalid flags" {
  run $BATS_TEST_DIRNAME/test-cases/sash-parse-invalid-flags.sh
  [ "$status" -eq "0" ]
  [ "${lines[0]}" = "Invalid Argument Flag, Unknown Chars: [ @|@@ ]!" ]
  [ "${lines[1]}" = "Invalid Argument Flag, Too Many Pipes: [ a|apples|allples ], Count: [ 2 ]!" ]
}

@test "__sash_parse_args rejects duplicate flags" {
  run $BATS_TEST_DIRNAME/test-cases/sash-parse-duplicate-flag.sh
  [ "$status" -eq "2" ]
  [ "${lines[0]}" = "Duplicate Flag: [ a|aa ]!" ]
}
