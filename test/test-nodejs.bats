#!/usr/bin/env bats
__SP_TESTEE=src/setup-nodejs.sh

setup() {
  load 'test_helper/bats-support/load'
  load 'test_helper/bats-assert/load'
  load 'test_helper/bats-file/load'

  __SP_TEST_ORIGINAL_PATH="$PATH"
}
teardown() {
    PATH="$__SP_TEST_ORIGINAL_PATH"

    # Assert, no custom variable or function is set
    declare | grep -e '^__sp_'
    assert_equal $? 1
}

@test "Environment must be clean after execution if succeeds with default version" {
    . $__SP_TESTEE

    assert_equal $OPTIND 1

    rm /tmp/node-v20.14.0-*
}
@test "Environment must be clean after execution if succeeds with given version" {
    . $__SP_TESTEE -v v18.20.3

    assert_equal $OPTIND 1

    rm /tmp/node-v18.20.3-*
}
@test "Environment must be clean after execution if installation fails" {
    . $__SP_TESTEE -v installation_fail || assert_equal $? 127

    assert_equal $OPTIND 1
}
@test "Should only print success message if version is already installed" {
    . $__SP_TESTEE
    rm /tmp/node-v20.14.0-*

    run . $__SP_TESTEE

    refute_line -p "Add $HOME/opt/"
    refute_line -p 'Install version: '
    assert_line 'v20.14.0'

    assert_file_not_exists /tmp/node-v20.14.0-*
}
@test "Should not alter environment if installation fails" {
    . $__SP_TESTEE -v installation_fail || assert_equal $? 127

    assert_equal "$PATH" "$__SP_TEST_ORIGINAL_PATH"
}
@test "Must print error message if remote installation file not found" {
    run . $__SP_TESTEE -v download_fail

    assert_line 'Install version: download_fail'
    assert_line -e 'Local installation file not found: /tmp/node-download_fail-.*\. Try, download new one'
    assert_line 'ERROR: No remote installation file found. Abort'

    assert_file_not_exists /tmp/node-download_fail-*
}
@test "Should try download if local installation file not exists" {
    run . $__SP_TESTEE

    assert_line -e 'Local installation file not found: /tmp/node-v20\.14\.0-.*\. Try, download new one'
    assert_line 'Download installation file'

    rm /tmp/node-v20.14.0-*
}
@test "Should try download if remote installation file exists" {
    run . $__SP_TESTEE

    assert_line 'Download installation file'

    rm /tmp/node-v20.14.0-*
 }
