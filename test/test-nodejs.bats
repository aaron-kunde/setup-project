#!/usr/bin/env bats
SPT_SCRIPT=src/setup-nodejs.sh

setup() {
  load 'test_helper/bats-support/load'
  load 'test_helper/bats-assert/load'

  SPT_ORIGINAL_PATH="$PATH"
}
teardown() {
    PATH="$SPT_ORIGINAL_PATH"
}


@test "Must print versions to install with default version" {
    run . $SPT_SCRIPT

    assert_line 'Install version: v20.14.0'

    rm /tmp/installation.file
}
@test "Must print versions to install with given version" {
    run .  $SPT_SCRIPT -v v18.20.3

    assert_line 'Install version: v18.20.3'

    rm /tmp/installation.file
}
