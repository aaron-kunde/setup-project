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

@test "Exported variables must be set if succeeds with default version using Linux" {
    . $SPT_SCRIPT

    assert_equal "$PATH" "$HOME/opt/node-v20.14.0-linux-x64/bin:$SPT_ORIGINAL_PATH"

    rm /tmp/installation.file
}
@test "Exported variables must be set if succeeds with given version using Linux" {
    . $SPT_SCRIPT -v v18.20.3

    assert_equal "$PATH" "$HOME/opt/node-v18.20.3-linux-x64/bin:$SPT_ORIGINAL_PATH"

    rm /tmp/installation.file
}



@test "Should not set variables if version is already installed using Linux" {
    . $SPT_SCRIPT
    assert_equal $OPTIND 1
    assert [ -z $INSTALLATION_BASE_DIR ]
    assert [ -z $VERSION ]
    assert_equal "$PATH" "$HOME/opt/node-v20.14.0-linux-x64/bin:$SPT_ORIGINAL_PATH"

    . $SPT_SCRIPT

    assert_equal $OPTIND 1
    assert [ -z $INSTALLATION_BASE_DIR ]
    assert [ -z $VERSION ]
    assert_equal "$PATH" "$HOME/opt/node-v20.14.0-linux-x64/bin:$SPT_ORIGINAL_PATH"

    assert_file_not_exists  /tmp/installation.file
}
