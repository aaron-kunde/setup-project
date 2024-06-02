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
@test "Environment must be clean after execution if succeeds with default version" {
    . $SPT_SCRIPT

    assert_equal $OPTIND 1
    assert [ -z $INSTALLATION_BASE_DIR ]
    assert [ -z $VERSION ]

    rm /tmp/installation.file
}
@test "Environment must be clean after execution if succeeds with given version" {
    . $SPT_SCRIPT -v v18.20.3

    assert_equal $OPTIND 1
    assert [ -z $INSTALLATION_BASE_DIR ]
    assert [ -z $VERSION ]

    rm /tmp/installation.file
}












@test "Should only output success message if version is already installed" {
    . $SPT_SCRIPT
    assert_line "Adding $HOME/opt/node-v20.14.0-linux-x64/bin to PATH"
    assert_line "Install version: v20.14.0"
    assert_line "TMPL successfully installed"

    run . $SPT_SCRIPT

    refute_line -p "Adding $HOME/opt/"
    refute_line -p "Install version: "
    assert_line "TMPL successfully installed"

    assert_file_not_exists  /tmp/installation.file
}
