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

@test "Should export variables if succeeds with default version using Windows" {
    . $SPT_SCRIPT

    assert_equal "$PATH" "$HOME/opt/node-v20.14.0-win-x64:$SPT_ORIGINAL_PATH"

    rm /tmp/node-v20.14.0-win-x64.zip
}
@test "Should export variables if succeeds with given version using Windows" {
    . $SPT_SCRIPT -v v18.20.3

    assert_equal "$PATH" "$HOME/opt/node-v18.20.3-win-x64:$SPT_ORIGINAL_PATH"

    rm /tmp/node-v18.20.3-win-x64.zip
}
@test "Should not alter environment if version is already installed using Windows" {
    . $SPT_SCRIPT
    assert_equal "$PATH" "$HOME/opt/node-v20.14.0-win-x64:$SPT_ORIGINAL_PATH"
    rm /tmp/node-v20.14.0-win-x64.zip

    . $SPT_SCRIPT

    assert_equal $OPTIND 1
    assert [ -z $INSTALLATION_BASE_DIR ]
    assert [ -z $VERSION ]
    assert_equal "$PATH" "$HOME/opt/node-v20.14.0-win-x64:$SPT_ORIGINAL_PATH"

    assert_file_not_exists /tmp/node-v20.14.0-win-x64.zip
}
@test "Must print success message if installation succeeds with default version using Windows" {
    run . $SPT_SCRIPT

    assert_line 'v20.14.0'

    rm /tmp/node-v20.14.0-win-x64.zip
}
@test "Must print success message if installation succeeds with given version using Windows" {
    run . $SPT_SCRIPT -v v18.20.3

    assert_line 'v18.20.3'

    rm /tmp/node-v18.20.3-win-x64.zip
}
@test "Should not try download if local installation file exists using Windows" {
    touch /tmp/node-v20.14.0-win-x64.zip

    run . $SPT_SCRIPT

    refute_line 'Local installation file not found: /tmp/node-v20.14.0-win-x64.zip. Try, download new one'
    refute_line 'Download installation file'

    rm /tmp/node-v20.14.0-win-x64.zip
}
