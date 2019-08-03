#!/usr/bin/env bats

@test "_sash_safe_add_to_trap can add to an empty trap" {
  run $BATS_TEST_DIRNAME/test-cases/test-add-to-empty-trap.sh
  [ "$status" -eq "0" ]
  [ "${lines[0]}" = "onTrap" ]
  [ "${#lines[@]}" = "1" ]
}

@test "_sash_safe_add_to_trap can add to an empty trap multiple times" {
  run $BATS_TEST_DIRNAME/test-cases/test-add-multiple-to-empty-trap.sh
  [ "$status" -eq "0" ]
  [ "${lines[0]}" = "onTrap" ]
  [ "${lines[1]}" = "onTrap" ]
  [ "${lines[2]}" = "onTrap" ]
  [ "${#lines[@]}" = "3" ]
}

@test "_sash_get_trapped_text can print out a trap" {
  run $BATS_TEST_DIRNAME/test-cases/test-simple-get-tt.sh
  [ "$status" -eq "0" ]
  [ "${lines[0]}" = "onTrap; onTrap; onTrap;" ]
}

@test "_sash_get_trapped_text can print out a quoted trap" {
  run $BATS_TEST_DIRNAME/test-cases/test-simple-quote-get-tt.sh
  [ "$status" -eq "0" ]
  [ "${lines[0]}" = "echo 'hey \"hello\" \\\"sup\\\"'" ]
}
