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

@test "Must print versions to install with default version using Linux" {
    run . $SPT_SCRIPT

    assert_line 'Install version: v20.14.0'
    assert_line "Add $HOME/opt/node-v20.14.0-linux-x64/bin to PATH"

    rm /tmp/node-v20.14.0-*
}
@test "Must print versions to install with given version using Linux" {
    run .  $SPT_SCRIPT -v v18.20.3

    assert_line 'Install version: v18.20.3'
    assert_line "Add $HOME/opt/node-v18.20.3-linux-x64/bin to PATH"

    rm /tmp/node-v18.20.3-*
}
@test "Should export variables if succeeds with default version using Linux" {
    . $SPT_SCRIPT

    assert_equal "$PATH" "$HOME/opt/node-v20.14.0-linux-x64/bin:$SPT_ORIGINAL_PATH"

    rm /tmp/node-v20.14.0-linux-x64.tar.xz
}
@test "Should export variables if succeeds with given version using Linux" {
    . $SPT_SCRIPT -v v18.20.3

    assert_equal "$PATH" "$HOME/opt/node-v18.20.3-linux-x64/bin:$SPT_ORIGINAL_PATH"

    rm /tmp/node-v18.20.3-linux-x64.tar.xz
}
@test "Should not alter environment if version is already installed using Linux" {
    . $SPT_SCRIPT
    assert_equal "$PATH" "$HOME/opt/node-v20.14.0-linux-x64/bin:$SPT_ORIGINAL_PATH"
    rm /tmp/node-v20.14.0-linux-x64.tar.xz

    . $SPT_SCRIPT

    assert_equal $OPTIND 1
    assert [ -z $INSTALLATION_BASE_DIR ]
    assert [ -z $VERSION ]
    assert_equal "$PATH" "$HOME/opt/node-v20.14.0-linux-x64/bin:$SPT_ORIGINAL_PATH"

    assert_file_not_exists /tmp/node-v20.14.0-linux-x64.tar.xz
}
@test "Must print success message if installation succeeds with default version using Linux" {
    run . $SPT_SCRIPT

    assert_line 'v20.14.0'

    rm /tmp/node-v20.14.0-linux-x64.tar.xz
}
@test "Must print success message if installation succeeds with given version using Linux" {
    run . $SPT_SCRIPT -v v18.20.3

    assert_line 'v18.20.3'

    rm /tmp/node-v18.20.3-linux-x64.tar.xz
}
@test "Should not try download if local installation file exists using Linux" {
    touch /tmp/node-v20.14.0-linux-x64.tar.xz

    run . $SPT_SCRIPT

    refute_line 'Local installation file not found: /tmp/node-v20.14.0-linux-x64.tar.xz. Try, download new one'
    refute_line 'Download installation file'

    rm /tmp/node-v20.14.0-linux-x64.tar.xz
}
