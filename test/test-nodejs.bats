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

@test "Must print versions to install with default version" {
    run . $SPT_SCRIPT

    assert_line 'Install version: v20.14.0'

    rm /tmp/node-v20.14.0-*
}
@test "Must print versions to install with given version" {
    run .  $SPT_SCRIPT -v v18.20.3

    assert_line 'Install version: v18.20.3'

    rm /tmp/node-v18.20.3-*
}
@test "Environment must be clean after execution if succeeds with default version" {
    . $SPT_SCRIPT

    assert_equal $OPTIND 1
    assert [ -z $INSTALLATION_BASE_DIR ]
    assert [ -z $VERSION ]

    rm /tmp/node-v20.14.0-*
}
@test "Environment must be clean after execution if succeeds with given version" {
    . $SPT_SCRIPT -v v18.20.3

    assert_equal $OPTIND 1
    assert [ -z $INSTALLATION_BASE_DIR ]
    assert [ -z $VERSION ]

    rm /tmp/node-v18.20.3-*
}
@test "Environment must be clean after execution if installation fails" {
    . $SPT_SCRIPT -v installation_fail || assert_equal $? 127

    assert_equal $OPTIND 1
    assert [ -z $INSTALLATION_BASE_DIR ]
    assert [ -z $VERSION ]
}
@test "Should only print success message if version is already installed" {
    . $SPT_SCRIPT
    rm /tmp/node-v20.14.0-*

    run . $SPT_SCRIPT

    refute_line -p 'Adding $HOME/opt/'
    refute_line -p 'Install version: '
    assert_line 'v20.14.0'

    assert_file_not_exists /tmp/node-v20.14.0-*
}
@test "Should not alter environment if installation fails" {
    . $SPT_SCRIPT -v installation_fail || assert_equal $? 127

    assert_equal "$PATH" "$SPT_ORIGINAL_PATH"
}
@test "Must print error message if remote installation file not found" {
    run . $SPT_SCRIPT -v download_fail

    assert_line 'Install version: download_fail'
    assert_line -e 'Local installation file not found: /tmp/node-download_fail-.*\. Try, download new one'
    assert_line 'ERROR: No remote installation file found. Abort'
    assert_file_not_exists /tmp/node-download_fail-*
}
@test "Should try download if local installation file not exists" {
    run . $SPT_SCRIPT

    assert_line -e 'Local installation file not found: /tmp/node-v20\.14\.0-.*\. Try, download new one'
    assert_line 'Download installation file'

    rm /tmp/node-v20.14.0-*
}
@test "Should try download if remote installation file exists" {
    run . $SPT_SCRIPT

    assert_line 'Download installation file'

    rm /tmp/node-v20.14.0-*
 }
