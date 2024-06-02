#!/usr/bin/env bats
SPT_SCRIPT=src/setup-nodejs.sh

setup() {
  load 'test_helper/bats-support/load'
  load 'test_helper/bats-assert/load'
  load 'test_helper/bats-file/load'

  SPT_ORIGINAL_PATH="$PATH"
}
teardown() {
    PATH="$SPT_ORIGINAL_PATH"
}













@test "Should only output success message if version is already installed" {
    . $SPT_SCRIPT
    # assert_line "Adding $HOME/opt/node-v20.14.0-linux-x64/bin to PATH"
    # assert_line "Install version: v20.14.0"
    # assert_line "v20.14.0"

    rm /tmp/node-v20.14.0-linux-x64.tar.xz

    run . $SPT_SCRIPT

    refute_line -p "Adding $HOME/opt/"
    refute_line -p "Install version: "
    assert_line "v20.14.0"

    assert_file_not_exists /tmp/node-v20.14.0-linux-x64.tar.xz
}
