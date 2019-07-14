#!/usr/bin/env bats

@test "sash_allow_errors allows errors" {
  run $BATS_TEST_DIRNAME/test-cases/test-err-mode-off.sh
  [ "$status" -eq "0" ]
  [ "${lines[0]}" = "hey" ]
}

@test "sash_allow_errors allows errors if called from an error sensitive context" {
  run $BATS_TEST_DIRNAME/test-cases/test-err-mode-off-inside-err-mode.sh
  [ "$status" -eq "0" ]
  [ "${lines[0]}" = "hey" ]
  [ "${lines[1]}" = "hello" ]
}

@test "sash_guard_errors can cause a script to exit" {
  run $BATS_TEST_DIRNAME/test-cases/test-simple-err-mode.sh
  [ "$status" -eq "1" ]
}

@test "sash_guard_errors doesn't error everything" {
  run $BATS_TEST_DIRNAME/test-cases/test-err-mode-passthrough.sh
  [ "$status" -eq "0" ]
  [ "${lines[0]}" = "hey" ]
}
